// Owns: staging and live swap operations.

void BuildFilesToStageForSurface(SkidSurface surfaceKind, array<string> &out filesToStage) {
    filesToStage.RemoveRange(0, filesToStage.Length);
    filesToStage.InsertLast(kDefaultSkidTexture);

    string highFile = TierToFilenameForSurface(DriftTier::High, surfaceKind);
    string midFile = TierToFilenameForSurface(DriftTier::Mid, surfaceKind);
    string poorFile = TierToFilenameForSurface(DriftTier::Poor, surfaceKind);

    if (filesToStage.Find(highFile) < 0) filesToStage.InsertLast(highFile);
    if (filesToStage.Find(midFile) < 0) filesToStage.InsertLast(midFile);
    if (filesToStage.Find(poorFile) < 0) filesToStage.InsertLast(poorFile);
}

bool RebuildStagedTexture(SkidSurface surfaceKind, const string &in filename) {
    string dstAbs = StagedPath(surfaceKind, filename);
    DeleteFileIfExists(dstAbs);
    return EnsureStagedTexture(surfaceKind, filename);
}

bool EnsureStagedTexture(SkidSurface surfaceKind, const string &in filename) {
    string stagedPath = StagedPath(surfaceKind, filename);
    if (IO::FileExists(stagedPath)) return true;

    string sourcePath = SourceDirForSurface(surfaceKind) + "/" + filename;
    if (!IO::FileExists(sourcePath)) {
        warn("[IO ERROR] Source texture not found: " + sourcePath);
        return false;
    }

    if (!CopyFileAbs(sourcePath, stagedPath)) {
        warn("[IO ERROR] Failed to stage texture: " + sourcePath);
        return false;
    }

    dbg("[IO] Re-staged missing file: " + SurfaceId(surfaceKind) + "/" + filename);
    return true;
}

bool StageRequiredTexturesForSurface(SkidSurface surfaceKind) {
    array<string> filesToStage;
    BuildFilesToStageForSurface(surfaceKind, filesToStage);

    bool stagedOk = true;
    for (uint t = 0; t < filesToStage.Length; t++) {
        yield();
        if (!RebuildStagedTexture(surfaceKind, filesToStage[t])) {
            stagedOk = false;
            warn("[Init] Failed to stage: " + SurfaceId(surfaceKind) + "/" + filesToStage[t]);
        }
    }

    return stagedOk;
}

bool StageRequiredTexturesForAllSurfaces() {
    bool allStaged = true;
    for (uint i = 0; i < kSurfaces.Length; i++) {
        if (!StageRequiredTexturesForSurface(kSurfaces[i])) {
            allStaged = false;
        }
    }
    return allStaged;
}

bool PrimeLiveDefaultsForAllSurfaces() {
    bool allPrimed = true;
    for (uint i = 0; i < kSurfaces.Length; i++) {
        SkidSurface surfaceKind = kSurfaces[i];
        string livePath = LivePath(surfaceKind);
        DeleteFileIfExists(livePath);

        if (!EnsureStagedTexture(surfaceKind, kDefaultSkidTexture)
            || !CopyFileAbs(StagedPath(surfaceKind, kDefaultSkidTexture), livePath)) {
            allPrimed = false;
            warn("[Init] Failed to prime live slot for " + SurfaceId(surfaceKind));
        } else {
            SetTrackedLiveFilename(surfaceKind, kDefaultSkidTexture);
        }
    }
    return allPrimed;
}

bool RePromoteTrackedLiveTextureIfMissing(
    SkidSurface surfaceKind,
    const string &in trackedFile,
    const string &in livePath,
    const string &in targetStagedPath
) {
    if (IO::FileExists(livePath)) {
        return true;
    }

    if (!EnsureStagedTexture(surfaceKind, trackedFile)) {
        return false;
    }

    IO::Move(targetStagedPath, livePath);
    if (!IO::FileExists(livePath)) {
        warn("[IO ERROR] Failed to re-promote missing live texture: " + livePath);
        return false;
    }

    SetTrackedLiveFilename(surfaceKind, trackedFile);
    dbg("[IO] Re-promoted tracked live texture: " + SurfaceId(surfaceKind) + " (" + trackedFile + ")");
    return true;
}

bool TryStashCurrentLiveTexture(const string &in livePath, const string &in sourceStagedPath) {
    DeleteFileIfExists(sourceStagedPath);
    IO::Move(livePath, sourceStagedPath);
    if (IO::FileExists(livePath)) {
        warn("[IO ERROR] Failed to stash live texture: " + livePath);
        return false;
    }
    return true;
}

void TryRestorePreviousLiveTexture(
    SkidSurface surfaceKind,
    const string &in fromFile,
    const string &in sourceStagedPath,
    const string &in livePath
) {
    if (!IO::FileExists(sourceStagedPath)) {
        return;
    }

    IO::Move(sourceStagedPath, livePath);
    if (IO::FileExists(livePath)) {
        SetTrackedLiveFilename(surfaceKind, fromFile);
        warn("[IO] Restored previous live texture after failed promote: " + SurfaceId(surfaceKind)
            + " (" + fromFile + ")");
    }
}

bool SwapSkidTextureForSurface(DriftTier toTier, SkidSurface surfaceKind) {
    string fromFile = TrackedLiveFilename(surfaceKind);
    if (fromFile.Length == 0) {
        fromFile = kDefaultSkidTexture;
    }
    string toFile = TierToFilenameForSurface(toTier, surfaceKind);
    string livePath = LivePath(surfaceKind);
    string sourceStagedPath = StagedPath(surfaceKind, fromFile);
    string targetStagedPath = StagedPath(surfaceKind, toFile);

    if (fromFile == toFile) {
        return RePromoteTrackedLiveTextureIfMissing(surfaceKind, toFile, livePath, targetStagedPath);
    }

    if (!EnsureStagedTexture(surfaceKind, toFile)) {
        return false;
    }

    bool hadLive = IO::FileExists(livePath);

    if (hadLive) {
        if (!TryStashCurrentLiveTexture(livePath, sourceStagedPath)) {
            return false;
        }
    }

    IO::Move(targetStagedPath, livePath);
    if (!IO::FileExists(livePath)) {
        warn("[IO ERROR] Failed to promote texture to live path: " + livePath);
        if (hadLive) {
            TryRestorePreviousLiveTexture(surfaceKind, fromFile, sourceStagedPath, livePath);
        }
        return false;
    }

    SetTrackedLiveFilename(surfaceKind, toFile);
    dbg("[IO] Promoted " + toFile + " -> live (" + SurfaceId(surfaceKind) + ", previous=" + fromFile + ")");
    return true;
}

bool SwapSkidTextureAllSurfaces(DriftTier targetTier, bool &out anyChanged) {
    bool allOk = true;
    anyChanged = false;

    for (uint i = 0; i < kSurfaces.Length; i++) {
        SkidSurface surfaceKind = kSurfaces[i];
        string targetFile = TierToFilenameForSurface(targetTier, surfaceKind);
        if (TrackedLiveFilename(surfaceKind) == targetFile) {
            continue;
        }

        anyChanged = true;
        if (!SwapSkidTextureForSurface(targetTier, surfaceKind)) {
            allOk = false;
        }
    }

    return allOk;
}
