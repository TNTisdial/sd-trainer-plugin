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
