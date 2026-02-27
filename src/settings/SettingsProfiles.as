// Owns: settings profile serialization and profile panel actions.

bool ParseIntToken(const string &in token, int &out value) {
    if (token.Length == 0) return false;
    value = Text::ParseInt(token);
    return true;
}

bool ParseFloatToken(const string &in token, float &out value) {
    if (token.Length == 0) return false;
    value = Text::ParseFloat(token);
    return true;
}

bool ParseUintToken(const string &in token, uint &out value) {
    int parsed = 0;
    if (!ParseIntToken(token, parsed)) return false;
    if (parsed < 0) parsed = 0;
    value = uint(parsed);
    return true;
}

string EncodeProfileToken(const string &in token) {
    string encoded = token;
    encoded = encoded.Replace("%", "%25");
    encoded = encoded.Replace("\n", "%0A");
    encoded = encoded.Replace("\r", "%0D");
    encoded = encoded.Replace("\t", "%09");
    encoded = encoded.Replace("|", "%7C");
    return encoded;
}

string DecodeProfileToken(const string &in token) {
    string decoded = token;
    decoded = decoded.Replace("%7C", "|");
    decoded = decoded.Replace("%09", "\t");
    decoded = decoded.Replace("%0D", "\r");
    decoded = decoded.Replace("%0A", "\n");
    decoded = decoded.Replace("%25", "%");
    return decoded;
}

bool IsValidProfileName(const string &in profileName) {
    if (profileName.Length == 0) return false;
    string compact = profileName.Replace(" ", "").Replace("\t", "");
    return compact.Length > 0;
}

string NormalizeProfileName(const string &in rawName) {
    string name = rawName;
    name = name.Replace("\n", " ").Replace("\r", " ").Replace("\t", " ");
    return name;
}

int FindSettingsProfileIndexByName(const string &in profileName) {
    for (uint i = 0; i < settingsProfileNames.Length; i++) {
        if (settingsProfileNames[i] == profileName) return int(i);
    }
    return -1;
}

string JoinProfileTokens(const array<string> &in tokens) {
    string outText = "";
    for (uint i = 0; i < tokens.Length; i++) {
        if (i > 0) outText += "|";
        outText += tokens[i];
    }
    return outText;
}

string BuildCurrentSettingsProfilePayload() {
    array<string> tokens;
    tokens.InsertLast("" + kSettingsProfileVersion);
    tokens.InsertLast(useSlopeAdjustedAcc ? "1" : "0");
    tokens.InsertLast("" + swapDebounceMs);
    tokens.InsertLast("" + greenSkidThreshold_Asphalt);
    tokens.InsertLast("" + yellowSkidThreshold_Asphalt);
    tokens.InsertLast("" + redSkidThreshold_Asphalt);
    tokens.InsertLast("" + greenSkidThreshold_Dirt);
    tokens.InsertLast("" + yellowSkidThreshold_Dirt);
    tokens.InsertLast("" + redSkidThreshold_Dirt);
    tokens.InsertLast("" + greenSkidThreshold_Grass);
    tokens.InsertLast("" + yellowSkidThreshold_Grass);
    tokens.InsertLast("" + redSkidThreshold_Grass);
    tokens.InsertLast("" + skidHysteresisUp);
    tokens.InsertLast("" + skidHysteresisDown);
    tokens.InsertLast("" + promotionPersistenceFrames);
    tokens.InsertLast("" + downgradePersistenceFrames);
    tokens.InsertLast("" + surfaceStabilityFrames);
    tokens.InsertLast("" + surfaceTransitionGraceMs);
    tokens.InsertLast("" + landingLockoutMs);
    tokens.InsertLast("" + minSlipCoefToDrift);
    tokens.InsertLast("" + slipHysteresis);
    tokens.InsertLast("" + postLandingImpactGuardMs);
    tokens.InsertLast("" + impactSpikeThreshold);
    tokens.InsertLast("" + impactExtraPromotionFrames);
    tokens.InsertLast("" + postBoostImpactGuardMs);
    tokens.InsertLast("" + boostSpikeThreshold);
    tokens.InsertLast("" + boostExtraPromotionFrames);
    tokens.InsertLast(allowLiveBoostGrading ? "1" : "0");
    tokens.InsertLast("" + boostBaselineFollowRate);
    tokens.InsertLast("" + boostHeadroomScale);
    tokens.InsertLast("" + uphillSlopeLeniency);
    tokens.InsertLast("" + downhillSlopeStrictness);
    tokens.InsertLast(lowSpeedForgivenessEnabled ? "1" : "0");
    tokens.InsertLast("" + forgivenessMaxSpeed_Asphalt);
    tokens.InsertLast("" + forgivenessMinSpeed_Asphalt);
    tokens.InsertLast("" + forgivenessFactor_Asphalt);
    tokens.InsertLast("" + forgivenessMaxSpeed_Dirt);
    tokens.InsertLast("" + forgivenessMinSpeed_Dirt);
    tokens.InsertLast("" + forgivenessFactor_Dirt);
    tokens.InsertLast("" + forgivenessMaxSpeed_Grass);
    tokens.InsertLast("" + forgivenessMinSpeed_Grass);
    tokens.InsertLast("" + forgivenessFactor_Grass);
    tokens.InsertLast(EncodeProfileToken(S_AsphaltHighSkidFile));
    tokens.InsertLast(EncodeProfileToken(S_AsphaltMidSkidFile));
    tokens.InsertLast(EncodeProfileToken(S_AsphaltPoorSkidFile));
    tokens.InsertLast(EncodeProfileToken(S_DirtHighSkidFile));
    tokens.InsertLast(EncodeProfileToken(S_DirtMidSkidFile));
    tokens.InsertLast(EncodeProfileToken(S_DirtPoorSkidFile));
    tokens.InsertLast(EncodeProfileToken(S_GrassHighSkidFile));
    tokens.InsertLast(EncodeProfileToken(S_GrassMidSkidFile));
    tokens.InsertLast(EncodeProfileToken(S_GrassPoorSkidFile));
    return JoinProfileTokens(tokens);
}

bool ApplySettingsProfilePayload(const string &in payload) {
    auto tokens = payload.Split("|");
    if (tokens.Length != kSettingsProfileFieldCount) {
        return false;
    }

    int ix = 0;
    int profileVersion = 0;
    if (!ParseIntToken(tokens[ix++], profileVersion) || profileVersion != kSettingsProfileVersion) {
        return false;
    }

    uint parsedSwapDebounceMs = 0;
    float parsedGreenSkidThreshold_Asphalt = 0;
    float parsedYellowSkidThreshold_Asphalt = 0;
    float parsedRedSkidThreshold_Asphalt = 0;
    float parsedGreenSkidThreshold_Dirt = 0;
    float parsedYellowSkidThreshold_Dirt = 0;
    float parsedRedSkidThreshold_Dirt = 0;
    float parsedGreenSkidThreshold_Grass = 0;
    float parsedYellowSkidThreshold_Grass = 0;
    float parsedRedSkidThreshold_Grass = 0;
    float parsedSkidHysteresisUp = 0;
    float parsedSkidHysteresisDown = 0;
    int parsedPromotionPersistenceFrames = 0;
    int parsedDowngradePersistenceFrames = 0;
    int parsedSurfaceStabilityFrames = 0;
    int parsedSurfaceTransitionGraceMs = 0;
    int parsedLandingLockoutMs = 0;
    float parsedMinSlipCoefToDrift = 0;
    float parsedSlipHysteresis = 0;
    int parsedPostLandingImpactGuardMs = 0;
    float parsedImpactSpikeThreshold = 0;
    int parsedImpactExtraPromotionFrames = 0;
    int parsedPostBoostImpactGuardMs = 0;
    float parsedBoostSpikeThreshold = 0;
    int parsedBoostExtraPromotionFrames = 0;
    float parsedBoostBaselineFollowRate = 0;
    float parsedBoostHeadroomScale = 0;
    float parsedUphillSlopeLeniency = 0;
    float parsedDownhillSlopeStrictness = 0;
    float parsedForgivenessMaxSpeed_Asphalt = 0;
    float parsedForgivenessMinSpeed_Asphalt = 0;
    float parsedForgivenessFactor_Asphalt = 0;
    float parsedForgivenessMaxSpeed_Dirt = 0;
    float parsedForgivenessMinSpeed_Dirt = 0;
    float parsedForgivenessFactor_Dirt = 0;
    float parsedForgivenessMaxSpeed_Grass = 0;
    float parsedForgivenessMinSpeed_Grass = 0;
    float parsedForgivenessFactor_Grass = 0;

    bool parsedUseSlopeAdjustedAcc = tokens[ix++] == "1";
    if (!ParseUintToken(tokens[ix++], parsedSwapDebounceMs)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedGreenSkidThreshold_Asphalt)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedYellowSkidThreshold_Asphalt)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedRedSkidThreshold_Asphalt)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedGreenSkidThreshold_Dirt)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedYellowSkidThreshold_Dirt)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedRedSkidThreshold_Dirt)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedGreenSkidThreshold_Grass)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedYellowSkidThreshold_Grass)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedRedSkidThreshold_Grass)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedSkidHysteresisUp)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedSkidHysteresisDown)) return false;
    if (!ParseIntToken(tokens[ix++], parsedPromotionPersistenceFrames)) return false;
    if (!ParseIntToken(tokens[ix++], parsedDowngradePersistenceFrames)) return false;
    if (!ParseIntToken(tokens[ix++], parsedSurfaceStabilityFrames)) return false;
    if (!ParseIntToken(tokens[ix++], parsedSurfaceTransitionGraceMs)) return false;
    if (!ParseIntToken(tokens[ix++], parsedLandingLockoutMs)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedMinSlipCoefToDrift)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedSlipHysteresis)) return false;
    if (!ParseIntToken(tokens[ix++], parsedPostLandingImpactGuardMs)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedImpactSpikeThreshold)) return false;
    if (!ParseIntToken(tokens[ix++], parsedImpactExtraPromotionFrames)) return false;
    if (!ParseIntToken(tokens[ix++], parsedPostBoostImpactGuardMs)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedBoostSpikeThreshold)) return false;
    if (!ParseIntToken(tokens[ix++], parsedBoostExtraPromotionFrames)) return false;
    bool parsedAllowLiveBoostGrading = tokens[ix++] == "1";
    if (!ParseFloatToken(tokens[ix++], parsedBoostBaselineFollowRate)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedBoostHeadroomScale)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedUphillSlopeLeniency)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedDownhillSlopeStrictness)) return false;
    bool parsedLowSpeedForgivenessEnabled = tokens[ix++] == "1";
    if (!ParseFloatToken(tokens[ix++], parsedForgivenessMaxSpeed_Asphalt)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedForgivenessMinSpeed_Asphalt)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedForgivenessFactor_Asphalt)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedForgivenessMaxSpeed_Dirt)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedForgivenessMinSpeed_Dirt)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedForgivenessFactor_Dirt)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedForgivenessMaxSpeed_Grass)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedForgivenessMinSpeed_Grass)) return false;
    if (!ParseFloatToken(tokens[ix++], parsedForgivenessFactor_Grass)) return false;

    useSlopeAdjustedAcc = parsedUseSlopeAdjustedAcc;
    swapDebounceMs = parsedSwapDebounceMs;
    greenSkidThreshold_Asphalt = parsedGreenSkidThreshold_Asphalt;
    yellowSkidThreshold_Asphalt = parsedYellowSkidThreshold_Asphalt;
    redSkidThreshold_Asphalt = parsedRedSkidThreshold_Asphalt;
    greenSkidThreshold_Dirt = parsedGreenSkidThreshold_Dirt;
    yellowSkidThreshold_Dirt = parsedYellowSkidThreshold_Dirt;
    redSkidThreshold_Dirt = parsedRedSkidThreshold_Dirt;
    greenSkidThreshold_Grass = parsedGreenSkidThreshold_Grass;
    yellowSkidThreshold_Grass = parsedYellowSkidThreshold_Grass;
    redSkidThreshold_Grass = parsedRedSkidThreshold_Grass;
    skidHysteresisUp = parsedSkidHysteresisUp;
    skidHysteresisDown = parsedSkidHysteresisDown;
    promotionPersistenceFrames = parsedPromotionPersistenceFrames;
    downgradePersistenceFrames = parsedDowngradePersistenceFrames;
    surfaceStabilityFrames = parsedSurfaceStabilityFrames;
    surfaceTransitionGraceMs = parsedSurfaceTransitionGraceMs;
    landingLockoutMs = parsedLandingLockoutMs;
    minSlipCoefToDrift = parsedMinSlipCoefToDrift;
    slipHysteresis = parsedSlipHysteresis;
    postLandingImpactGuardMs = parsedPostLandingImpactGuardMs;
    impactSpikeThreshold = parsedImpactSpikeThreshold;
    impactExtraPromotionFrames = parsedImpactExtraPromotionFrames;
    postBoostImpactGuardMs = parsedPostBoostImpactGuardMs;
    boostSpikeThreshold = parsedBoostSpikeThreshold;
    boostExtraPromotionFrames = parsedBoostExtraPromotionFrames;
    allowLiveBoostGrading = parsedAllowLiveBoostGrading;
    boostBaselineFollowRate = parsedBoostBaselineFollowRate;
    boostHeadroomScale = parsedBoostHeadroomScale;
    uphillSlopeLeniency = parsedUphillSlopeLeniency;
    downhillSlopeStrictness = parsedDownhillSlopeStrictness;
    lowSpeedForgivenessEnabled = parsedLowSpeedForgivenessEnabled;
    forgivenessMaxSpeed_Asphalt = parsedForgivenessMaxSpeed_Asphalt;
    forgivenessMinSpeed_Asphalt = parsedForgivenessMinSpeed_Asphalt;
    forgivenessFactor_Asphalt = parsedForgivenessFactor_Asphalt;
    forgivenessMaxSpeed_Dirt = parsedForgivenessMaxSpeed_Dirt;
    forgivenessMinSpeed_Dirt = parsedForgivenessMinSpeed_Dirt;
    forgivenessFactor_Dirt = parsedForgivenessFactor_Dirt;
    forgivenessMaxSpeed_Grass = parsedForgivenessMaxSpeed_Grass;
    forgivenessMinSpeed_Grass = parsedForgivenessMinSpeed_Grass;
    forgivenessFactor_Grass = parsedForgivenessFactor_Grass;

    S_AsphaltHighSkidFile = DecodeProfileToken(tokens[ix++]);
    S_AsphaltMidSkidFile = DecodeProfileToken(tokens[ix++]);
    S_AsphaltPoorSkidFile = DecodeProfileToken(tokens[ix++]);
    S_DirtHighSkidFile = DecodeProfileToken(tokens[ix++]);
    S_DirtMidSkidFile = DecodeProfileToken(tokens[ix++]);
    S_DirtPoorSkidFile = DecodeProfileToken(tokens[ix++]);
    S_GrassHighSkidFile = DecodeProfileToken(tokens[ix++]);
    S_GrassMidSkidFile = DecodeProfileToken(tokens[ix++]);
    S_GrassPoorSkidFile = DecodeProfileToken(tokens[ix++]);

    return true;
}

void PersistSettingsProfiles() {
    string blob = "";
    for (uint i = 0; i < settingsProfileNames.Length; i++) {
        if (i > 0) blob += "\n";
        blob += EncodeProfileToken(settingsProfileNames[i]) + "\t" + settingsProfilePayloads[i];
    }
    S_SettingsProfilesBlob = blob;
}

void EnsureSettingsProfilesLoaded() {
    if (settingsProfilesLoaded) return;
    settingsProfilesLoaded = true;

    settingsProfileNames.RemoveRange(0, settingsProfileNames.Length);
    settingsProfilePayloads.RemoveRange(0, settingsProfilePayloads.Length);

    if (S_SettingsProfilesBlob.Length == 0) return;

    auto lines = S_SettingsProfilesBlob.Split("\n");
    for (uint i = 0; i < lines.Length; i++) {
        string line = lines[i];
        if (line.Length == 0) continue;

        auto cols = line.Split("\t");
        if (cols.Length < 2) continue;

        string name = DecodeProfileToken(cols[0]);
        string payload = cols[1];
        if (!IsValidProfileName(name)) continue;
        if (FindSettingsProfileIndexByName(name) >= 0) continue;

        settingsProfileNames.InsertLast(name);
        settingsProfilePayloads.InsertLast(payload);
    }

    int selectedIx = FindSettingsProfileIndexByName(S_SelectedSettingsProfile);
    if (selectedIx < 0 && settingsProfileNames.Length > 0) {
        S_SelectedSettingsProfile = settingsProfileNames[0];
    }
}

bool SaveCurrentSettingsAsProfile(const string &in rawName) {
    EnsureSettingsProfilesLoaded();

    string profileName = NormalizeProfileName(rawName);
    if (!IsValidProfileName(profileName)) {
        settingsProfileStatus = "Profile name cannot be empty.";
        return false;
    }

    if (profileName.Length > 48) {
        settingsProfileStatus = "Profile name is too long (max 48 chars).";
        return false;
    }

    string payload = BuildCurrentSettingsProfilePayload();
    int existingIx = FindSettingsProfileIndexByName(profileName);
    if (existingIx >= 0) {
        settingsProfilePayloads[existingIx] = payload;
        settingsProfileStatus = "Updated profile: " + profileName;
    } else {
        settingsProfileNames.InsertLast(profileName);
        settingsProfilePayloads.InsertLast(payload);
        settingsProfileStatus = "Saved profile: " + profileName;
    }

    S_SelectedSettingsProfile = profileName;
    settingsProfileNameInput = profileName;
    PersistSettingsProfiles();
    return true;
}

bool DuplicateSelectedSettingsProfile(const string &in rawName) {
    EnsureSettingsProfilesLoaded();

    int selectedIx = FindSettingsProfileIndexByName(S_SelectedSettingsProfile);
    if (selectedIx < 0) {
        settingsProfileStatus = "Select a saved profile first.";
        return false;
    }

    string duplicateName = NormalizeProfileName(rawName);
    if (!IsValidProfileName(duplicateName)) {
        settingsProfileStatus = "Duplicate name cannot be empty.";
        return false;
    }

    if (duplicateName.Length > 48) {
        settingsProfileStatus = "Duplicate name is too long (max 48 chars).";
        return false;
    }

    if (FindSettingsProfileIndexByName(duplicateName) >= 0) {
        settingsProfileStatus = "A profile with that name already exists.";
        return false;
    }

    settingsProfileNames.InsertLast(duplicateName);
    settingsProfilePayloads.InsertLast(settingsProfilePayloads[selectedIx]);
    S_SelectedSettingsProfile = duplicateName;
    settingsProfileNameInput = duplicateName;
    PersistSettingsProfiles();
    settingsProfileStatus = "Duplicated profile to: " + duplicateName;
    return true;
}

bool RenameSelectedSettingsProfile(const string &in rawName) {
    EnsureSettingsProfilesLoaded();

    int selectedIx = FindSettingsProfileIndexByName(S_SelectedSettingsProfile);
    if (selectedIx < 0) {
        settingsProfileStatus = "Select a saved profile first.";
        return false;
    }

    string renamedProfile = NormalizeProfileName(rawName);
    if (!IsValidProfileName(renamedProfile)) {
        settingsProfileStatus = "New profile name cannot be empty.";
        return false;
    }

    if (renamedProfile.Length > 48) {
        settingsProfileStatus = "New profile name is too long (max 48 chars).";
        return false;
    }

    int existingIx = FindSettingsProfileIndexByName(renamedProfile);
    if (existingIx >= 0 && existingIx != selectedIx) {
        settingsProfileStatus = "A profile with that name already exists.";
        return false;
    }

    settingsProfileNames[selectedIx] = renamedProfile;
    S_SelectedSettingsProfile = renamedProfile;
    settingsProfileNameInput = renamedProfile;
    PersistSettingsProfiles();
    settingsProfileStatus = "Renamed profile to: " + renamedProfile;
    return true;
}

void LoadSelectedSettingsProfileAsync() {
    string profileName = pendingSettingsProfileName;
    string payload = pendingSettingsProfilePayload;
    pendingSettingsProfileName = "";
    pendingSettingsProfilePayload = "";

    if (payload.Length == 0) {
        settingsProfileStatus = "No profile payload available to load.";
        settingsProfileLoadInProgress = false;
        return;
    }

    S_SelectedSettingsProfile = profileName;
    if (!ApplySettingsProfilePayload(payload)) {
        settingsProfileStatus = "Profile is invalid or from an unsupported version.";
        settingsProfileLoadInProgress = false;
        return;
    }

    EnsureConfiguredSkidFilesExist();
    bool rebuiltOk = BootstrapSkidRuntimeAssets();
    if (rebuiltOk) {
        settingsProfileStatus = "Loaded profile: " + S_SelectedSettingsProfile;
    } else {
        settingsProfileStatus = "Profile loaded with startup warnings; check logs.";
    }
    settingsProfileLoadInProgress = false;
}

bool RequestLoadSelectedSettingsProfile() {
    EnsureSettingsProfilesLoaded();

    if (generalRebuildInProgress) {
        settingsProfileStatus = "Startup rebuild in progress. Try loading after it finishes.";
        return false;
    }

    if (settingsProfileLoadInProgress) {
        settingsProfileStatus = "Profile load already in progress.";
        return false;
    }

    int selectedIx = FindSettingsProfileIndexByName(S_SelectedSettingsProfile);
    if (selectedIx < 0) {
        settingsProfileStatus = "Select a saved profile first.";
        return false;
    }

    pendingSettingsProfileName = settingsProfileNames[selectedIx];
    pendingSettingsProfilePayload = settingsProfilePayloads[selectedIx];
    settingsProfileLoadInProgress = true;
    settingsProfileStatus = "Loading profile: " + pendingSettingsProfileName + "...";
    startnew(LoadSelectedSettingsProfileAsync);
    return true;
}

void DeleteSelectedSettingsProfile() {
    EnsureSettingsProfilesLoaded();

    int selectedIx = FindSettingsProfileIndexByName(S_SelectedSettingsProfile);
    if (selectedIx < 0) {
        settingsProfileStatus = "Select a saved profile first.";
        return;
    }

    string deletedName = settingsProfileNames[selectedIx];
    settingsProfileNames.RemoveAt(selectedIx);
    settingsProfilePayloads.RemoveAt(selectedIx);

    if (settingsProfileNames.Length == 0) {
        S_SelectedSettingsProfile = "";
    } else if (selectedIx >= int(settingsProfileNames.Length)) {
        S_SelectedSettingsProfile = settingsProfileNames[settingsProfileNames.Length - 1];
    } else {
        S_SelectedSettingsProfile = settingsProfileNames[selectedIx];
    }

    PersistSettingsProfiles();
    settingsProfileStatus = "Deleted profile: " + deletedName;
}

void DrawSettingsProfilesPanel() {
    EnsureSettingsProfilesLoaded();

    UI::Text("Settings profiles");
    UI::TextWrapped("Save named snapshots of runtime tuning + skid texture selections.");

    settingsProfileNameInput = UI::InputText("Profile Name", settingsProfileNameInput);
    if (UI::Button("Save Profile")) {
        SaveCurrentSettingsAsProfile(settingsProfileNameInput);
    }
    UI::SameLine();
    if (UI::Button("Duplicate")) {
        DuplicateSelectedSettingsProfile(settingsProfileNameInput);
    }
    UI::SameLine();
    if (UI::Button("Rename Selected Profile")) {
        RenameSelectedSettingsProfile(settingsProfileNameInput);
    }
    DrawHelpIcon("Save overwrites an existing name. Duplicate creates a new profile from the selected one. Rename changes only the selected profile name.");

    string comboPreview = S_SelectedSettingsProfile.Length > 0 ? S_SelectedSettingsProfile : "Select profile";
    if (UI::BeginCombo("Saved Profiles", comboPreview)) {
        for (uint i = 0; i < settingsProfileNames.Length; i++) {
            bool isSelected = settingsProfileNames[i] == S_SelectedSettingsProfile;
            if (UI::Selectable(settingsProfileNames[i], isSelected)) {
                S_SelectedSettingsProfile = settingsProfileNames[i];
                settingsProfileNameInput = settingsProfileNames[i];
            }
        }
        UI::EndCombo();
    }

    if (UI::Button("Load Selected Profile")) {
        RequestLoadSelectedSettingsProfile();
    }
    UI::SameLine();
    if (UI::Button(Icons::TrashO + " Delete Selected Profile")) {
        DeleteSelectedSettingsProfile();
    }

    if (settingsProfileStatus.Length > 0) {
        UI::TextWrapped(settingsProfileStatus);
    }
}
