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

const string kDefaultSkidTexture = "Default.dds";
array<string> kLiveFilenameBySurface = {
    "CarAsphaltMarks.dds",
    "DirtMarks.dds",
    "CarGrassMarks.dds"
};

bool DeleteFileIfExists(const string &in filePath) {
    if (!IO::FileExists(filePath)) return true;
    IO::Delete(filePath);
    return !IO::FileExists(filePath);
}

void EnsureModWorkPaths() {
    if (MODWORK_FOLDER == "") {
        MODWORK_FOLDER = IO::FromUserGameFolder("Skins/Stadium/ModWork").Replace("\\", "/");
    }
    if (MODWORK_CARFX_FOLDER == "") {
        MODWORK_CARFX_FOLDER = MODWORK_FOLDER + "/CarFxImage";
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
// TODO: Get Vistas working too
bool IsValidSurfaceIndex(int index) {
    return index >= 0 && index < int(liveTextureBySurface.Length);
}

bool IsValidLiveFilenameIndex(int index) {
    return index >= 0 && index < int(kLiveFilenameBySurface.Length);
}

int SurfaceIndex(SkidSurface surfaceKind) {
    if (surfaceKind == SkidSurface::Dirt) return 1;
    if (surfaceKind == SkidSurface::Grass) return 2;
    return 0;
}

string SourceDirForSurfaceIndex(int index) {
    if (index == 1) return SKIDS_SOURCE_DIR_DIRT;
    if (index == 2) return SKIDS_SOURCE_DIR_GRASS;
    return SKIDS_SOURCE_DIR_ASPHALT;
}

array<string>@ TextureListForSurfaceIndex(int index) {
    if (index == 1) return skidTexturesDirt;
    if (index == 2) return skidTexturesGrass;
    return skidTexturesAsphalt;
}

string SurfaceToLiveFilenameIndex(int index) {
    if (!IsValidLiveFilenameIndex(index)) {
        return kLiveFilenameBySurface[0];
    }
    return kLiveFilenameBySurface[index];
}

string SurfaceToLiveFolderIndex(int index) {
    if (index == 1) return MODWORK_FOLDER;
    return MODWORK_CARFX_FOLDER;
}

string SourceDirForSurface(SkidSurface surfaceKind) {
    return SourceDirForSurfaceIndex(SurfaceIndex(surfaceKind));
}

array<string>@ TextureListForSurface(SkidSurface surfaceKind) {
    return TextureListForSurfaceIndex(SurfaceIndex(surfaceKind));
}

string SurfaceToLiveFilename(SkidSurface surfaceKind) {
    return SurfaceToLiveFilenameIndex(SurfaceIndex(surfaceKind));
}

string SurfaceToLiveFolder(SkidSurface surfaceKind) {
    return SurfaceToLiveFolderIndex(SurfaceIndex(surfaceKind));
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
        return kDefaultSkidTexture;
    }

    if (surfaceKind == SkidSurface::Grass) {
        if (tier == DriftTier::High) return S_GrassHighSkidFile;
        if (tier == DriftTier::Mid) return S_GrassMidSkidFile;
        if (tier == DriftTier::Poor) return S_GrassPoorSkidFile;
        return kDefaultSkidTexture;
    }

    if (tier == DriftTier::High) return S_AsphaltHighSkidFile;
    if (tier == DriftTier::Mid) return S_AsphaltMidSkidFile;
    if (tier == DriftTier::Poor) return S_AsphaltPoorSkidFile;
    return kDefaultSkidTexture;
}

string TrackedLiveFilename(SkidSurface surfaceKind) {
    int index = SurfaceIndex(surfaceKind);
    if (!IsValidSurfaceIndex(index)) {
        return kDefaultSkidTexture;
    }
    return liveTextureBySurface[index];
}

void SetTrackedLiveFilename(SkidSurface surfaceKind, const string &in filename) {
    int index = SurfaceIndex(surfaceKind);
    if (!IsValidSurfaceIndex(index)) {
        return;
    }
    liveTextureBySurface[index] = filename;
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

// --- Live Swapping --- 
// We use IO::Move instead of IO::Copy to avoid writing every swap,
// and to force the game to notice the live texture update.

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

// --- Bundled Install ---
// These .dds skids are tuned for visibility in peripheral vision.
// If packaged assets are unavailable, we fetch missing files from GitHub.
bool HasBundledSkidsAtRoot(const string &in root) {
    if (!IO::FolderExists(root)) return false;
    return IO::FolderExists(root + "/Asphalt")
        && IO::FolderExists(root + "/Dirt")
        && IO::FolderExists(root + "/Grass");
}

const string REMOTE_SKIDS_TAG = "v1.0.2";
const string REMOTE_SKIDS_BASE_URL = "https://raw.githubusercontent.com/TNTisdial/sd-trainer-plugin/" + REMOTE_SKIDS_TAG + "/SkidOptions";
array<string> kRemoteBundledSkidFiles = {
    kDefaultSkidTexture,
    "BlueFadeThicc.dds",
    "GreenFadeThicc.dds",
    "YellowFadeThicc.dds",
    "RedFadeThicc.dds"
};

bool TrySetBundledSkidsRoot(const string &in candidateRoot, const string &in sourceLabel) {
    string normalized = candidateRoot.Replace("\\", "/");
    if (!HasBundledSkidsAtRoot(normalized)) return false;
    bundledSkidsRoot = normalized;
    dbg("[Install] Resolved bundled skids root via " + sourceLabel + ": " + bundledSkidsRoot);
    return true;
}

bool TryResolveFromSourcePath(const string &in sourcePath) {
    if (sourcePath.Length == 0) return false;

    if (TrySetBundledSkidsRoot(sourcePath + "/SkidOptions", "plugin source path")) {
        return true;
    }

    if (sourcePath.ToLower().EndsWith(".op")) {
        string withoutExt = sourcePath.SubStr(0, sourcePath.Length - 3);
        if (TrySetBundledSkidsRoot(withoutExt + "/SkidOptions", "plugin source sibling folder")) {
            return true;
        }
    }

    return false;
}

bool HasLegacyOrSrcRuntimeMarker(const string &in entryPath) {
    if (IO::FileExists(entryPath + "/SkidRuntime.as")) return true;
    if (IO::FileExists(entryPath + "/src/runtime/SkidRuntime.as")) return true;
    return false;
}

bool TryResolveFromPreferredPluginEntry(const string &in entryPath) {
    if (IO::FolderExists(entryPath) && HasLegacyOrSrcRuntimeMarker(entryPath)) {
        if (TrySetBundledSkidsRoot(entryPath + "/SkidOptions", "plugins folder preferred scan")) {
            return true;
        }
    }

    if (entryPath.ToLower().EndsWith(".op")) {
        if (TrySetBundledSkidsRoot(entryPath + "/SkidOptions", "plugins .op mount")) {
            return true;
        }

        string withoutExt = entryPath.SubStr(0, entryPath.Length - 3);
        if (TrySetBundledSkidsRoot(withoutExt + "/SkidOptions", "plugins .op sibling folder")) {
            return true;
        }
    }

    return false;
}

bool TryResolveFromFallbackPluginEntry(const string &in entryPath) {
    if (IO::FolderExists(entryPath)) {
        if (TrySetBundledSkidsRoot(entryPath + "/SkidOptions", "plugins folder fallback scan")) {
            return true;
        }
    }

    if (entryPath.ToLower().EndsWith(".op")) {
        if (TrySetBundledSkidsRoot(entryPath + "/SkidOptions", "plugins .op fallback mount")) {
            return true;
        }

        string withoutExt = entryPath.SubStr(0, entryPath.Length - 3);
        if (TrySetBundledSkidsRoot(withoutExt + "/SkidOptions", "plugins .op fallback sibling folder")) {
            return true;
        }
    }

    return false;
}

bool TryResolveFromPluginsDirectory() {
    string pluginsDir = IO::FromDataFolder("Plugins").Replace("\\", "/");
    if (!IO::FolderExists(pluginsDir)) {
        return false;
    }

    auto entries = IO::IndexFolder(pluginsDir, false);
    entries.SortAsc();

    for (uint i = 0; i < entries.Length; i++) {
        string entryPath = entries[i].Replace("\\", "/");
        if (TryResolveFromPreferredPluginEntry(entryPath)) {
            return true;
        }
    }

    for (uint i = 0; i < entries.Length; i++) {
        string entryPath = entries[i].Replace("\\", "/");
        if (TryResolveFromFallbackPluginEntry(entryPath)) {
            return true;
        }
    }

    return false;
}

string ResolveBundledSkidsRoot() {
    if (bundledSkidsRoot.Length > 0 && HasBundledSkidsAtRoot(bundledSkidsRoot)) {
        return bundledSkidsRoot;
    }

    auto plugin = Meta::ExecutingPlugin();
    if (plugin !is null) {
        string sourcePath = plugin.SourcePath.Replace("\\", "/");
        if (TryResolveFromSourcePath(sourcePath)) {
            return bundledSkidsRoot;
        }
    }

    if (TryResolveFromPluginsDirectory()) {
        return bundledSkidsRoot;
    }

    return "";
}

string UserSkidsDirForSurfaceName(const string &in surfaceName) {
    return IO::FromUserGameFolder("Skins/Stadium/Skids/" + surfaceName).Replace("\\", "/");
}

// .op packages may not include SkidOptions at runtime, so we fetch missing files remotely.
bool DownloadBundledSkidFile(const string &in surfaceName, const string &in filename) {
    string destDir = UserSkidsDirForSurfaceName(surfaceName);
    EnsureDir(destDir);

    string destPath = destDir + "/" + filename;
    if (IO::FileExists(destPath)) {
        return true;
    }

    string url = REMOTE_SKIDS_BASE_URL + "/" + surfaceName + "/" + filename;
    trace("[Install] Downloading fallback skid: " + surfaceName + "/" + filename);
    auto req = Net::HttpGet(url);
    while (!req.Finished()) {
        yield();
    }

    if (req.ResponseCode() != 200) {
        warn("[Install] Failed to download " + surfaceName + "/" + filename + " from " + url + " (HTTP " + req.ResponseCode() + ")");
        if (req.Error().Length > 0) {
            warn("[Install] Download error: " + req.Error());
        }
        return false;
    }

    auto buf = req.Buffer();
    if (buf is null) {
        warn("[Install] Downloaded empty response for " + surfaceName + "/" + filename);
        return false;
    }

    IO::File outFile(destPath, IO::FileMode::Write);
    outFile.Write(buf);
    outFile.Close();
    trace("[Install] Downloaded fallback skid: " + surfaceName + "/" + filename);
    return true;
}

bool DownloadBundledSkidsFromRemote() {
    int downloaded = 0;
    int skipped = 0;
    int failed = 0;

    for (uint i = 0; i < kSurfaces.Length; i++) {
        string surfaceName = SurfaceFolderName(kSurfaces[i]);
        for (uint f = 0; f < kRemoteBundledSkidFiles.Length; f++) {
            string filename = kRemoteBundledSkidFiles[f];
            string destPath = UserSkidsDirForSurfaceName(surfaceName) + "/" + filename;
            if (IO::FileExists(destPath)) {
                skipped++;
                continue;
            }

            if (DownloadBundledSkidFile(surfaceName, filename)) {
                downloaded++;
            } else {
                failed++;
            }
        }
    }

    trace("[Install] Remote skid fallback complete. downloaded=" + downloaded + ", skipped=" + skipped + ", failed=" + failed);
    return failed == 0;
}

void InstallBundledSkidsForSurface(SkidSurface surfaceKind) {
    if (bundledSkidsRoot.Length == 0) {
        warn("[Install] Bundled SkidOptions root is empty. Skipping packaged install.");
        return;
    }

    string surfaceName = SurfaceFolderName(surfaceKind);
    string pluginSkidsDir = bundledSkidsRoot + "/" + surfaceName;
    dbg("[Install] Looking for bundled skids at: " + pluginSkidsDir);
    if (!IO::FolderExists(pluginSkidsDir)) {
        warn("[Install] Bundled SkidOptions/" + surfaceName + " folder not found - skipping install.");
        return;
    }

    string destDir = UserSkidsDirForSurfaceName(surfaceName);
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

        if (filename == kDefaultSkidTexture && IO::FileExists(destFile)) {
            DeleteFileIfExists(destFile);
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
    bundledSkidsRoot = ResolveBundledSkidsRoot();
    if (bundledSkidsRoot.Length == 0) {
        trace("[Install] Packaged SkidOptions not accessible in this install; using GitHub fallback for missing files.");
        if (!DownloadBundledSkidsFromRemote()) {
            warn("[Install] GitHub fallback did not fully complete; missing files may remain.");
        }
        return;
    }

    for (uint i = 0; i < kSurfaces.Length; i++) {
        InstallBundledSkidsForSurface(kSurfaces[i]);
    }
}

// --- Cleanup Entrypoints ---

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
