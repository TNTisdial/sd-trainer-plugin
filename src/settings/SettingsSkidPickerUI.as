// Owns: skid picker menu, tab, and texture preview UI.

void RenderMenu() {
    if (UI::MenuItem(MENU_TITLE, "", S_ShowSkidPicker)) {
        S_ShowSkidPicker = !S_ShowSkidPicker;
    }
}

[SettingsTab name="Skid Skins" icon="PaintBrush"]
void R_S_SkidSettingsTab() {
    DrawSkidPickerUI();
}

void RenderInterface() {
    if (!S_ShowSkidPicker) return;
    UI::SetNextWindowSize(560, 560, UI::Cond::FirstUseEver);
    if (UI::Begin(MENU_TITLE, S_ShowSkidPicker, UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize)) {
        DrawSkidPickerUI();
    }
    UI::End();
}

void DrawSkidPickerUI() {
    UI::TextWrapped("Choose skid textures for each drift-quality tier, per surface.");
    UI::Separator();

    UI::BeginTabBar("skid-surface-tabs");

    if (UI::BeginTabItem("Asphalt")) {
        array<string> asphaltFiles = { S_AsphaltHighSkidFile, S_AsphaltMidSkidFile, S_AsphaltPoorSkidFile };
        DrawSurfacePicker(
            "Asphalt", SKID_OPTIONS_DIR_ASPHALT, "",
            skidOptionFiles_Asphalt, skidOptionPretty_Asphalt,
            asphaltFiles
        );
        S_AsphaltHighSkidFile = asphaltFiles[0];
        S_AsphaltMidSkidFile = asphaltFiles[1];
        S_AsphaltPoorSkidFile = asphaltFiles[2];
        UI::EndTabItem();
    }

    if (UI::BeginTabItem("Dirt")) {
        array<string> dirtFiles = { S_DirtHighSkidFile, S_DirtMidSkidFile, S_DirtPoorSkidFile };
        DrawSurfacePicker(
            "Dirt", SKID_OPTIONS_DIR_DIRT,
            "Dirt skids use thinner textures to compensate for the engine rendering them larger.",
            skidOptionFiles_Dirt, skidOptionPretty_Dirt,
            dirtFiles
        );
        S_DirtHighSkidFile = dirtFiles[0];
        S_DirtMidSkidFile = dirtFiles[1];
        S_DirtPoorSkidFile = dirtFiles[2];
        UI::EndTabItem();
    }

    if (UI::BeginTabItem("Grass")) {
        array<string> grassFiles = { S_GrassHighSkidFile, S_GrassMidSkidFile, S_GrassPoorSkidFile };
        DrawSurfacePicker(
            "Grass", SKID_OPTIONS_DIR_GRASS,
            "Grass uses the same texture scale as asphalt.",
            skidOptionFiles_Grass, skidOptionPretty_Grass,
            grassFiles
        );
        S_GrassHighSkidFile = grassFiles[0];
        S_GrassMidSkidFile = grassFiles[1];
        S_GrassPoorSkidFile = grassFiles[2];
        UI::EndTabItem();
    }

    UI::EndTabBar();
}

void DrawSurfacePicker(
    const string &in idSuffix,
    const string &in optionsDir,
    const string &in surfaceNote,
    array<string> &in fileList,
    array<string> &in prettyList,
    array<string> &inout tierFiles
) {
    if (tierFiles.Length < 3) {
        tierFiles.Resize(3);
    }

    if (surfaceNote.Length > 0) {
        UI::TextWrapped("\\$888" + surfaceNote + "\\$z");
    }

    if (fileList.Length == 0) {
        UI::TextWrapped("No .dds files found. Expected: " + optionsDir);
        if (UI::Button("Refresh##" + idSuffix + "_empty")) {
            RefreshAllSkidOptionLists();
        }
        return;
    }

    tierFiles[0] = DrawTierCombo("High##" + idSuffix, "High Tier", tierFiles[0], "\\$0f0", fileList, prettyList);
    tierFiles[1] = DrawTierCombo("Mid##" + idSuffix, "Mid Tier", tierFiles[1], "\\$ff0", fileList, prettyList);
    tierFiles[2] = DrawTierCombo("Poor##" + idSuffix, "Poor Tier", tierFiles[2], "\\$f00", fileList, prettyList);

    UI::Separator();

    if (UI::Button("Refresh##" + idSuffix)) {
        RefreshAllSkidOptionLists();
    }
    UI::SameLine();
    if (UI::Button(Icons::FolderO + "##" + idSuffix + "Folder")) {
        OpenExplorerPath(optionsDir);
    }

    UI::SetNextItemOpen(true, UI::Cond::FirstUseEver);
    if (UI::CollapsingHeader("Preview##" + idSuffix)) {
        UI::BeginTabBar("preview-tabs-" + idSuffix);
        if (UI::BeginTabItem("High##prev" + idSuffix)) {
            DrawPreview(optionsDir, tierFiles[0]);
            UI::EndTabItem();
        }
        if (UI::BeginTabItem("Mid##prev" + idSuffix)) {
            DrawPreview(optionsDir, tierFiles[1]);
            UI::EndTabItem();
        }
        if (UI::BeginTabItem("Poor##prev" + idSuffix)) {
            DrawPreview(optionsDir, tierFiles[2]);
            UI::EndTabItem();
        }
        UI::EndTabBar();
    }
}

string DrawTierCombo(
    const string &in comboId,
    const string &in label,
    const string &in currentFile,
    const string &in color,
    array<string> &in fileList,
    array<string> &in prettyList
) {
    string ret = currentFile;
    int selectedIx = fileList.Find(currentFile);

    UI::AlignTextToFramePadding();
    UI::Text(color + label + ":");
    UI::SameLine();

    string prettyPreview = (selectedIx >= 0) ? prettyList[selectedIx] : currentFile;
    if (UI::BeginCombo("##combo_" + comboId, prettyPreview, UI::ComboFlags::HeightLarge)) {
        for (uint i = 0; i < fileList.Length; i++) {
            bool isSelected = (ret == fileList[i]);
            if (UI::Selectable(prettyList[i] + "##sel_" + comboId + "_" + i, isSelected)) {
                ret = fileList[i];
                selectedIx = i;
            }
        }
        UI::EndCombo();
    }

    UI::SameLine();
    if (UI::Button(Icons::ChevronLeft + "##prv_" + comboId)) {
        if (fileList.Length > 0) {
            selectedIx = (selectedIx <= 0) ? int(fileList.Length) - 1 : selectedIx - 1;
            ret = fileList[selectedIx];
        }
    }

    UI::SameLine();
    if (UI::Button(Icons::ChevronRight + "##nxt_" + comboId)) {
        if (fileList.Length > 0) {
            selectedIx = (selectedIx + 1) % int(fileList.Length);
            ret = fileList[selectedIx];
        }
    }

    return ret;
}

string JoinPath(const string &in dir, const string &in filename) {
    if (dir.EndsWith("/")) return dir + filename;
    return dir + "/" + filename;
}

void DrawPreview(const string &in optionsDir, const string &in filename) {
    if (filename.Length == 0) {
        UI::TextWrapped("No skin selected");
        return;
    }

    string absPath = JoinPath(optionsDir, filename);
    if (!IO::FileExists(absPath)) {
        UI::TextWrapped("File not found: " + absPath);
        return;
    }

    auto @texHandle = texMgr.RequestTexture(absPath, int(PREVIEW_SIZE.x), int(PREVIEW_SIZE.y));
    if (texHandle is null || texHandle.Texture is null) {
        UI::TextWrapped("Loading preview...");
        return;
    }

    UI::Image(texHandle.Texture, PREVIEW_SIZE);
    UI::SameLine();

    auto pos = UI::GetCursorPos();
    auto dl = UI::GetWindowDrawList();
    dl.AddRectFilled(vec4(UI::GetWindowPos() + pos, PREVIEW_SIZE), vec4(.5, .5, .5, 1.));
    UI::Image(texHandle.Texture, PREVIEW_SIZE);
}

void ScanSkidFolder(const string &in dir, array<string> &out fileList, array<string> &out prettyList) {
    fileList.RemoveRange(0, fileList.Length);
    prettyList.RemoveRange(0, prettyList.Length);

    if (dir.Length == 0 || !IO::FolderExists(dir)) {
        warn("[SkidSettings] Skids folder not found: " + dir);
        return;
    }

    auto files = IO::IndexFolder(dir, false);
    for (uint i = 0; i < files.Length; i++) {
        string filePath = files[i].Replace("\\", "/");
        if (!filePath.ToLower().EndsWith(".dds")) continue;

        auto parts = filePath.Split("/");
        fileList.InsertLast(parts[parts.Length - 1]);
    }

    fileList.SortAsc();
    for (uint i = 0; i < fileList.Length; i++) {
        prettyList.InsertLast(fileList[i].SubStr(0, fileList[i].Length - 4));
    }

    trace("[SkidSettings] Found " + fileList.Length + " skins in " + dir);
}

void RefreshAllSkidOptionLists() {
    ScanSkidFolder(SKID_OPTIONS_DIR_ASPHALT, skidOptionFiles_Asphalt, skidOptionPretty_Asphalt);
    ScanSkidFolder(SKID_OPTIONS_DIR_DIRT, skidOptionFiles_Dirt, skidOptionPretty_Dirt);
    ScanSkidFolder(SKID_OPTIONS_DIR_GRASS, skidOptionFiles_Grass, skidOptionPretty_Grass);
}

string ResolveConfiguredSkidFile(const array<string> &in availableFiles, const string &in currentFile, const string &in preferredFile) {
    if (availableFiles.Find(currentFile) >= 0) return currentFile;
    if (availableFiles.Find(preferredFile) >= 0) return preferredFile;
    if (availableFiles.Find("Default.dds") >= 0) return "Default.dds";
    if (availableFiles.Length > 0) return availableFiles[0];
    return currentFile;
}

void EnsureConfiguredSkidFilesExist() {
    string oldAsphaltHigh = S_AsphaltHighSkidFile;
    string oldAsphaltMid = S_AsphaltMidSkidFile;
    string oldAsphaltPoor = S_AsphaltPoorSkidFile;
    S_AsphaltHighSkidFile = ResolveConfiguredSkidFile(skidOptionFiles_Asphalt, S_AsphaltHighSkidFile, "BlueFadeThicc.dds");
    S_AsphaltMidSkidFile = ResolveConfiguredSkidFile(skidOptionFiles_Asphalt, S_AsphaltMidSkidFile, "YellowFadeThicc.dds");
    S_AsphaltPoorSkidFile = ResolveConfiguredSkidFile(skidOptionFiles_Asphalt, S_AsphaltPoorSkidFile, "RedFadeThicc.dds");
    if (oldAsphaltHigh != S_AsphaltHighSkidFile || oldAsphaltMid != S_AsphaltMidSkidFile || oldAsphaltPoor != S_AsphaltPoorSkidFile) {
        warn("[SkidSettings] Asphalt selection auto-corrected to available files.");
    }

    string oldDirtHigh = S_DirtHighSkidFile;
    string oldDirtMid = S_DirtMidSkidFile;
    string oldDirtPoor = S_DirtPoorSkidFile;
    S_DirtHighSkidFile = ResolveConfiguredSkidFile(skidOptionFiles_Dirt, S_DirtHighSkidFile, "BlueFadeThicc.dds");
    S_DirtMidSkidFile = ResolveConfiguredSkidFile(skidOptionFiles_Dirt, S_DirtMidSkidFile, "YellowFadeThicc.dds");
    S_DirtPoorSkidFile = ResolveConfiguredSkidFile(skidOptionFiles_Dirt, S_DirtPoorSkidFile, "RedFadeThicc.dds");
    if (oldDirtHigh != S_DirtHighSkidFile || oldDirtMid != S_DirtMidSkidFile || oldDirtPoor != S_DirtPoorSkidFile) {
        warn("[SkidSettings] Dirt selection auto-corrected to available files.");
    }

    string oldGrassHigh = S_GrassHighSkidFile;
    string oldGrassMid = S_GrassMidSkidFile;
    string oldGrassPoor = S_GrassPoorSkidFile;
    S_GrassHighSkidFile = ResolveConfiguredSkidFile(skidOptionFiles_Grass, S_GrassHighSkidFile, "BlueFadeThicc.dds");
    S_GrassMidSkidFile = ResolveConfiguredSkidFile(skidOptionFiles_Grass, S_GrassMidSkidFile, "YellowFadeThicc.dds");
    S_GrassPoorSkidFile = ResolveConfiguredSkidFile(skidOptionFiles_Grass, S_GrassPoorSkidFile, "RedFadeThicc.dds");
    if (oldGrassHigh != S_GrassHighSkidFile || oldGrassMid != S_GrassMidSkidFile || oldGrassPoor != S_GrassPoorSkidFile) {
        warn("[SkidSettings] Grass selection auto-corrected to available files.");
    }
}

void InitSkidSettings() {
    EnsureSettingsProfilesLoaded();

    SKID_OPTIONS_DIR_ASPHALT = IO::FromUserGameFolder("Skins/Stadium/Skids/Asphalt/").Replace("\\", "/");
    SKID_OPTIONS_DIR_DIRT = IO::FromUserGameFolder("Skins/Stadium/Skids/Dirt/").Replace("\\", "/");
    SKID_OPTIONS_DIR_GRASS = IO::FromUserGameFolder("Skins/Stadium/Skids/Grass/").Replace("\\", "/");

    trace("[SkidSettings] Asphalt: " + SKID_OPTIONS_DIR_ASPHALT);
    trace("[SkidSettings] Dirt:    " + SKID_OPTIONS_DIR_DIRT);
    trace("[SkidSettings] Grass:   " + SKID_OPTIONS_DIR_GRASS);

    RefreshAllSkidOptionLists();
}
