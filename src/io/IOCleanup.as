// Owns: ModWork cleanup entrypoints.

bool DeleteModWorkFolderForModlessHandoff() {
    EnsureModWorkPaths();

    if (!IO::FolderExists(MODWORK_FOLDER)) {
        warn("[Modless Handoff] ModWork folder not found; nothing to delete.");
        stagedFilesReady = false;
        ResetRuntimeSwapState();
        return true;
    }

    trace("[Modless Handoff] Deleting ModWork folder: " + MODWORK_FOLDER);
    try {
        IO::DeleteFolder(MODWORK_FOLDER, true);
    } catch {
        warn("[Modless Handoff] Failed to delete ModWork folder due to exception.");
        return false;
    }

    if (IO::FolderExists(MODWORK_FOLDER)) {
        warn("[Modless Handoff] Delete completed with leftovers; ModWork still exists.");
        return false;
    }

    stagedFilesReady = false;
    ResetRuntimeSwapState();

    trace("[Modless Handoff] ModWork deleted. Load next map so Modless-Skids can repopulate.");
    return true;
}

void CleanupModWork() {
    EnsureModWorkPaths();

    for (uint i = 0; i < kSurfaces.Length; i++) {
        SkidSurface surfaceKind = kSurfaces[i];

        string live = LivePath(surfaceKind);
        DeleteFileIfExists(live);

        array<string>@ texList = TextureListForSurface(surfaceKind);
        for (uint t = 0; t < texList.Length; t++) {
            string staged = StagedPath(surfaceKind, texList[t]);
            if (IO::FileExists(staged)) {
                DeleteFileIfExists(staged);
                dbg("[Cleanup] Deleted staged file: " + staged);
            }
        }

        string defaultStaged = StagedPath(surfaceKind, kDefaultSkidTexture);
        if (IO::FileExists(defaultStaged)) {
            DeleteFileIfExists(defaultStaged);
        }
    }

    stagedFilesReady = false;
    ResetRuntimeSwapState();
    RefreshGameTextures();
}

void OnDestroyed() { CleanupModWork(); }
void OnDisabled() { CleanupModWork(); }
