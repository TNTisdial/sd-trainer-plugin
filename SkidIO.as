// --- Core IO Helpers ---
bool CopyFileAbs(const string &in fromAbs, const string &in toAbs) {
    if (!IO::FileExists(fromAbs)) {
        warn("[IO ERROR] Source not found: " + fromAbs);
        return false;
    }

    IO::File src(fromAbs, IO::FileMode::Read);
    string content = src.ReadToEnd();
    src.Close();

    IO::File dst(toAbs, IO::FileMode::Write);
    dst.Write(content);
    dst.Close();

    dbg("[IO] Copied " + content.Length + " bytes -> " + toAbs);
    return true;
}

void EnsureDir(const string &in path) {
    string normPath = path.Replace("\\", "/");
    if (!IO::FolderExists(normPath)) {
        IO::CreateFolder(normPath, true);
    }
}

void RefreshGameTextures() {
    try {
        auto app = cast<CTrackMania>(GetApp());
        if (app is null) return;
        if (app.MenuManager !is null && app.MenuManager.MenuCustom_CurrentManiaApp !is null) {
            app.MenuManager.MenuCustom_CurrentManiaApp.DataFileMgr.Media_RefreshFromDisk(CGameDataFileManagerScript::EMediaType::Skins, 4);
            dbg("[IO] Fired Media_RefreshFromDisk");
        }
    } catch {
        warn("[IO ERROR] RefreshGameTextures threw an exception");
    }
}

// --- Path and Surface Mapping ---
string SourceDirForSurface(SkidSurface surfaceKind) {
    if (surfaceKind == SkidSurface::Dirt) return SKIDS_SOURCE_DIR_DIRT;
    if (surfaceKind == SkidSurface::Grass) return SKIDS_SOURCE_DIR_GRASS;
    return SKIDS_SOURCE_DIR_ASPHALT;
}

array<string>@ TextureListForSurface(SkidSurface surfaceKind) {
    if (surfaceKind == SkidSurface::Dirt) return skidTexturesDirt;
    if (surfaceKind == SkidSurface::Grass) return skidTexturesGrass;
    return skidTexturesAsphalt;
}

string SurfaceToLiveFilename(SkidSurface surfaceKind) {
    if (surfaceKind == SkidSurface::Dirt) return "DirtMarks.dds";
    if (surfaceKind == SkidSurface::Grass) return "CarGrassMarks.dds";
    return "CarAsphaltMarks.dds";
}

string SurfaceToLiveFolder(SkidSurface surfaceKind) {
    if (surfaceKind == SkidSurface::Dirt) return MODWORK_FOLDER;
    return MODWORK_CARFX_FOLDER;
}

string LivePath(SkidSurface surfaceKind) {
    return SurfaceToLiveFolder(surfaceKind) + "/" + SurfaceToLiveFilename(surfaceKind);
}

string StagedPath(SkidSurface surfaceKind, const string &in texName) {
    return MODWORK_CARFX_FOLDER + "/_staged_" + SurfaceId(surfaceKind) + "_" + texName;
}

string TierToFilenameForSurface(DriftTier tier, SkidSurface surfaceKind) {
    if (surfaceKind == SkidSurface::Dirt) {
        if (tier == DriftTier::High) return S_DirtHighSkidFile;
        if (tier == DriftTier::Mid) return S_DirtMidSkidFile;
        if (tier == DriftTier::Poor) return S_DirtPoorSkidFile;
        return "Default.dds";
    }

    if (surfaceKind == SkidSurface::Grass) {
        if (tier == DriftTier::High) return S_GrassHighSkidFile;
        if (tier == DriftTier::Mid) return S_GrassMidSkidFile;
        if (tier == DriftTier::Poor) return S_GrassPoorSkidFile;
        return "Default.dds";
    }

    if (tier == DriftTier::High) return S_AsphaltHighSkidFile;
    if (tier == DriftTier::Mid) return S_AsphaltMidSkidFile;
    if (tier == DriftTier::Poor) return S_AsphaltPoorSkidFile;
    return "Default.dds";
}

// --- Texture Discovery ---
void RefreshTextureListForSurface(array<string> &out list, const string &in srcDir) {
    list.RemoveRange(0, list.Length);
    if (!IO::FolderExists(srcDir)) return;

    auto files = IO::IndexFolder(srcDir, false);
    for (uint i = 0; i < files.Length; i++) {
        string filePath = files[i].Replace("\\", "/");
        if (!filePath.ToLower().EndsWith(".dds")) continue;

        auto parts = filePath.Split("/");
        list.InsertLast(parts[parts.Length - 1]);
    }

    list.SortAsc();
}

void RefreshTextureList() {
    RefreshTextureListForSurface(skidTexturesAsphalt, SKIDS_SOURCE_DIR_ASPHALT);
    RefreshTextureListForSurface(skidTexturesDirt, SKIDS_SOURCE_DIR_DIRT);
    RefreshTextureListForSurface(skidTexturesGrass, SKIDS_SOURCE_DIR_GRASS);
}

int TotalLoadedSkidTextures() {
    return skidTexturesAsphalt.Length + skidTexturesDirt.Length + skidTexturesGrass.Length;
}

// --- Staging and Priming ---
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
    filesToStage.InsertLast("Default.dds");

    string highFile = TierToFilenameForSurface(DriftTier::High, surfaceKind);
    string midFile = TierToFilenameForSurface(DriftTier::Mid, surfaceKind);
    string poorFile = TierToFilenameForSurface(DriftTier::Poor, surfaceKind);
    if (filesToStage.Find(highFile) < 0) filesToStage.InsertLast(highFile);
    if (filesToStage.Find(midFile) < 0) filesToStage.InsertLast(midFile);
    if (filesToStage.Find(poorFile) < 0) filesToStage.InsertLast(poorFile);

    bool stagedOk = true;
    for (uint t = 0; t < filesToStage.Length; t++) {
        yield();
        string dstAbs = StagedPath(surfaceKind, filesToStage[t]);
        if (IO::FileExists(dstAbs)) {
            IO::Delete(dstAbs);
        }
        if (!EnsureStagedTexture(surfaceKind, filesToStage[t])) {
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
        if (IO::FileExists(livePath)) {
            IO::Delete(livePath);
        }

        if (!EnsureStagedTexture(surfaceKind, "Default.dds")
            || !CopyFileAbs(StagedPath(surfaceKind, "Default.dds"), livePath)) {
            allPrimed = false;
            warn("[Init] Failed to prime live slot for " + SurfaceId(surfaceKind));
        }
    }
    return allPrimed;
}

// --- Live Swapping ---
bool SwapSkidTextureForSurface(DriftTier fromTier, DriftTier toTier, SkidSurface surfaceKind) {
    string fromFile = TierToFilenameForSurface(fromTier, surfaceKind);
    string toFile = TierToFilenameForSurface(toTier, surfaceKind);

    if (fromFile == toFile) {
        return true;
    }

    if (!EnsureStagedTexture(surfaceKind, toFile)) {
        return false;
    }

    string livePath = LivePath(surfaceKind);
    string sourceStagedPath = StagedPath(surfaceKind, fromFile);
    string targetStagedPath = StagedPath(surfaceKind, toFile);

    if (IO::FileExists(livePath)) {
        if (IO::FileExists(sourceStagedPath)) {
            IO::Delete(sourceStagedPath);
        }

        IO::Move(livePath, sourceStagedPath);
        if (IO::FileExists(livePath)) {
            warn("[IO ERROR] Failed to stash live texture: " + livePath);
            return false;
        }
    }

    IO::Move(targetStagedPath, livePath);
    if (!IO::FileExists(livePath)) {
        warn("[IO ERROR] Failed to promote texture to live path: " + livePath);
        if (IO::FileExists(sourceStagedPath)) {
            IO::Move(sourceStagedPath, livePath);
        }
        return false;
    }

    dbg("[IO] Promoted " + toFile + " -> live (" + SurfaceId(surfaceKind) + ")");
    return true;
}

bool SwapSkidTextureAllSurfaces(DriftTier targetTier, bool &out anyChanged) {
    bool allOk = true;
    anyChanged = false;

    for (uint i = 0; i < kSurfaces.Length; i++) {
        SkidSurface surfaceKind = kSurfaces[i];
        if (TierToFilenameForSurface(currentTier, surfaceKind) == TierToFilenameForSurface(targetTier, surfaceKind)) {
            continue;
        }

        anyChanged = true;
        if (!SwapSkidTextureForSurface(currentTier, targetTier, surfaceKind)) {
            allOk = false;
        }
    }

    return allOk;
}

// --- Bundled Install ---
bool HasBundledSkidsAtRoot(const string &in root) {
    if (!IO::FolderExists(root)) return false;
    return IO::FolderExists(root + "/Asphalt")
        && IO::FolderExists(root + "/Dirt")
        && IO::FolderExists(root + "/Grass");
}

string ResolveBundledSkidsRoot() {
    if (bundledSkidsRoot.Length > 0 && HasBundledSkidsAtRoot(bundledSkidsRoot)) {
        return bundledSkidsRoot;
    }

    string pluginsDir = IO::FromDataFolder("Plugins").Replace("\\", "/");
    if (IO::FolderExists(pluginsDir)) {
        auto entries = IO::IndexFolder(pluginsDir, false);
        entries.SortAsc();

        for (uint i = 0; i < entries.Length; i++) {
            string pluginDir = entries[i].Replace("\\", "/");
            if (!IO::FolderExists(pluginDir)) continue;
            if (!IO::FileExists(pluginDir + "/SkidRuntime.as")) continue;

            string candidate = pluginDir + "/SkidOptions";
            if (HasBundledSkidsAtRoot(candidate)) {
                bundledSkidsRoot = candidate;
                dbg("[Install] Resolved bundled skids root: " + bundledSkidsRoot);
                return bundledSkidsRoot;
            }
        }

        for (uint i = 0; i < entries.Length; i++) {
            string pluginDir = entries[i].Replace("\\", "/");
            if (!IO::FolderExists(pluginDir)) continue;

            string candidate = pluginDir + "/SkidOptions";
            if (HasBundledSkidsAtRoot(candidate)) {
                bundledSkidsRoot = candidate;
                dbg("[Install] Resolved bundled skids root via fallback scan: " + bundledSkidsRoot);
                return bundledSkidsRoot;
            }
        }
    }

    return "";
}

void InstallBundledSkidsForSurface(SkidSurface surfaceKind) {
    string skidsRoot = ResolveBundledSkidsRoot();
    if (skidsRoot.Length == 0) {
        warn("[Install] Could not resolve plugin SkidOptions folder. Skipping bundled install.");
        return;
    }

    string surfaceName = SurfaceFolderName(surfaceKind);
    string pluginSkidsDir = skidsRoot + "/" + surfaceName;
    dbg("[Install] Looking for bundled skids at: " + pluginSkidsDir);
    if (!IO::FolderExists(pluginSkidsDir)) {
        warn("[Install] Bundled SkidOptions/" + surfaceName + " folder not found - skipping install.");
        return;
    }

    string destDir = IO::FromUserGameFolder("Skins/Stadium/Skids/" + surfaceName).Replace("\\", "/");
    EnsureDir(destDir);

    auto files = IO::IndexFolder(pluginSkidsDir, false);
    files.SortAsc();

    int installed = 0;
    int skipped = 0;
    for (uint i = 0; i < files.Length; i++) {
        if (i > 0 && (i % 8 == 0)) {
            yield();
        }

        string sourceFile = files[i].Replace("\\", "/");
        if (!sourceFile.ToLower().EndsWith(".dds")) continue;

        auto parts = sourceFile.Split("/");
        string filename = parts[parts.Length - 1];
        string destFile = destDir + "/" + filename;

        if (filename == "Default.dds" && IO::FileExists(destFile)) {
            IO::Delete(destFile);
        }

        if (IO::FileExists(destFile)) {
            skipped++;
            continue;
        }

        if (CopyFileAbs(sourceFile, destFile)) {
            installed++;
        }
    }

    dbg("[Install] " + surfaceName + " skids installed: " + installed + ", skipped: " + skipped);
}

void InstallBundledSkids() {
    for (uint i = 0; i < kSurfaces.Length; i++) {
        InstallBundledSkidsForSurface(kSurfaces[i]);
    }
}

// --- Cleanup Entrypoints ---
void CleanupModWork() {
    if (MODWORK_FOLDER == "") {
        MODWORK_FOLDER = IO::FromUserGameFolder("Skins/Stadium/ModWork").Replace("\\", "/");
    }
    if (MODWORK_CARFX_FOLDER == "") {
        MODWORK_CARFX_FOLDER = MODWORK_FOLDER + "/CarFxImage";
    }

    for (uint i = 0; i < kSurfaces.Length; i++) {
        SkidSurface surfaceKind = kSurfaces[i];

        string live = LivePath(surfaceKind);
        if (IO::FileExists(live)) {
            IO::Delete(live);
        }

        array<string>@ texList = TextureListForSurface(surfaceKind);
        for (uint t = 0; t < texList.Length; t++) {
            string staged = StagedPath(surfaceKind, texList[t]);
            if (IO::FileExists(staged)) {
                IO::Delete(staged);
                dbg("[Cleanup] Deleted staged file: " + staged);
            }
        }

        string defaultStaged = StagedPath(surfaceKind, "Default.dds");
        if (IO::FileExists(defaultStaged)) {
            IO::Delete(defaultStaged);
        }
    }

    stagedFilesReady = false;
    currentTier = DriftTier::Default;
    RefreshGameTextures();
}

void OnDestroyed() { CleanupModWork(); }
void OnDisabled() { CleanupModWork(); }
