// Owns: bundled SkidOptions resolution and remote fallback install.

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
