// Owns: General and Runtime settings tab rendering.

void RunGeneralStartupRebuildAsync() {
    bool rebuiltOk = BootstrapSkidRuntimeAssets();
    if (rebuiltOk) {
        generalActionsStatus = "Startup rebuild finished. Skids reloaded and primed.";
    } else {
        generalActionsStatus = "Startup rebuild completed with warnings. Check logs for missing files or staging issues.";
    }
    generalRebuildInProgress = false;
}

bool RequestGeneralStartupRebuild() {
    if (generalRebuildInProgress) {
        generalActionsStatus = "Startup rebuild already in progress.";
        return false;
    }
    if (settingsProfileLoadInProgress) {
        generalActionsStatus = "Wait for profile load to finish before rebuilding.";
        return false;
    }

    generalRebuildInProgress = true;
    generalActionsStatus = "Running startup rebuild...";
    startnew(RunGeneralStartupRebuildAsync);
    return true;
}

[SettingsTab name="General" icon="Cogs"]
void R_S_GeneralSettingsTab() {
    pluginEnabled = UI::Checkbox("Enable Plugin", pluginEnabled);
    debugLogging = UI::Checkbox("Debug Logging", debugLogging);

    UI::Separator();
    UI::Text("Modless handoff");
    UI::TextWrapped("When done using this plugin, disable it, delete ModWork, then load the next map so Modless-Skids can repopulate its files.");
    if (pluginEnabled) {
        UI::TextWrapped("\\$f93Tip: turn off 'Enable Plugin' before deleting ModWork for a clean handoff.\\$z");
    }

    if (UI::Button(Icons::TrashO + " Delete ModWork Folder (Modless handoff)")) {
        bool deletedOk = DeleteModWorkFolderForModlessHandoff();
        if (deletedOk) {
            generalActionsStatus = "ModWork deleted. Load next map to let Modless-Skids repopulate.";
        } else {
            generalActionsStatus = "Could not fully delete ModWork. Check Openplanet logs and try again.";
        }
    }

    UI::Separator();
    UI::Text("Runtime rebuild");
    UI::TextWrapped("Re-runs skid checks, install/fallback download, texture list refresh, staging, and default priming like plugin startup.");
    if (UI::Button("Repopulate Skids (Startup Rebuild)")) {
        RequestGeneralStartupRebuild();
    }

    if (generalActionsStatus.Length > 0) {
        UI::Separator();
        UI::TextWrapped(generalActionsStatus);
    }
}

void DrawHelpIcon(const string &in infoText) {
    UI::SameLine();
    UI::Text(Icons::QuestionCircle);
    if (UI::IsItemHovered()) {
        UI::BeginTooltip();
        UI::PushTextWrapPos(UI::GetCursorPos().x + 420.0f);
        UI::TextWrapped(infoText);
        UI::PopTextWrapPos();
        UI::EndTooltip();
    }
}

void ResetRuntimeTuningDefaults() {
    swapDebounceMs = 260;
    greenSkidThreshold_Asphalt = 0.910f;
    yellowSkidThreshold_Asphalt = 0.70f;
    redSkidThreshold_Asphalt = 0.10f;
    greenSkidThreshold_Dirt = 0.910f;
    yellowSkidThreshold_Dirt = 0.70f;
    redSkidThreshold_Dirt = 0.10f;
    greenSkidThreshold_Grass = 0.910f;
    yellowSkidThreshold_Grass = 0.70f;
    redSkidThreshold_Grass = 0.10f;
    skidHysteresisUp = 0.015f;
    skidHysteresisDown = 0.015f;

    promotionPersistenceFrames = 4;
    downgradePersistenceFrames = 4;
    surfaceStabilityFrames = 2;
    surfaceTransitionGraceMs = 100;
    landingLockoutMs = 30;
    minSlipCoefToDrift = 0.150f;
    slipHysteresis = 0.020f;
    postLandingImpactGuardMs = 30;
    impactSpikeThreshold = 3.000f;
    impactExtraPromotionFrames = 2;
    postBoostImpactGuardMs = 100;
    boostSpikeThreshold = 2.500f;
    boostExtraPromotionFrames = 2;
    allowLiveBoostGrading = true;
    boostBaselineFollowRate = 0.080f;
    boostHeadroomScale = 0.45f;
    uphillSlopeLeniency = 0.030f;
    downhillSlopeStrictness = 0.050f;

    lowSpeedForgivenessEnabled = true;
    forgivenessMaxSpeed_Asphalt = 550.0f;
    forgivenessMinSpeed_Asphalt = 400.0f;
    forgivenessFactor_Asphalt = 0.90f;
    forgivenessMaxSpeed_Dirt = 300.0f;
    forgivenessMinSpeed_Dirt = 150.0f;
    forgivenessFactor_Dirt = 0.90f;
    forgivenessMaxSpeed_Grass = 300.0f;
    forgivenessMinSpeed_Grass = 150.0f;
    forgivenessFactor_Grass = 0.90f;

    trace("[Settings] Runtime tuning reset to defaults.");
}

[SettingsTab name="Runtime" icon="Sliders"]
void R_S_RuntimeSettingsTab() {
    DrawSettingsProfilesPanel();
    UI::Separator();

    UI::Text("Tier thresholds (driftQualityRatio)");
    UI::TextWrapped("Reference: 1.00 is a perfect SD.");
    UI::Text("Asphalt");
    greenSkidThreshold_Asphalt = UI::SliderFloat("Asphalt Green Skid Threshold", greenSkidThreshold_Asphalt, 0.50f, 1.00f);
    DrawHelpIcon("Minimum drift quality ratio for green (perfect) skid color on asphalt.");
    yellowSkidThreshold_Asphalt = UI::SliderFloat("Asphalt Yellow Skid Threshold", yellowSkidThreshold_Asphalt, 0.30f, 0.99f);
    DrawHelpIcon("Minimum drift quality ratio for yellow (good) skid color on asphalt.");
    redSkidThreshold_Asphalt = UI::SliderFloat("Asphalt Red Skid Threshold", redSkidThreshold_Asphalt, 0.00f, 0.70f);
    DrawHelpIcon("Minimum drift quality ratio for red (poor) skid color on asphalt. Below this stays default.");

    UI::Text("Dirt");
    greenSkidThreshold_Dirt = UI::SliderFloat("Dirt Green Skid Threshold", greenSkidThreshold_Dirt, 0.50f, 1.00f);
    DrawHelpIcon("Minimum drift quality ratio for green (perfect) skid color on dirt.");
    yellowSkidThreshold_Dirt = UI::SliderFloat("Dirt Yellow Skid Threshold", yellowSkidThreshold_Dirt, 0.30f, 0.99f);
    DrawHelpIcon("Minimum drift quality ratio for yellow (good) skid color on dirt.");
    redSkidThreshold_Dirt = UI::SliderFloat("Dirt Red Skid Threshold", redSkidThreshold_Dirt, 0.00f, 0.70f);
    DrawHelpIcon("Minimum drift quality ratio for red (poor) skid color on dirt. Below this stays default.");

    UI::Text("Grass");
    greenSkidThreshold_Grass = UI::SliderFloat("Grass Green Skid Threshold", greenSkidThreshold_Grass, 0.50f, 1.00f);
    DrawHelpIcon("Minimum drift quality ratio for green (perfect) skid color on grass.");
    yellowSkidThreshold_Grass = UI::SliderFloat("Grass Yellow Skid Threshold", yellowSkidThreshold_Grass, 0.30f, 0.99f);
    DrawHelpIcon("Minimum drift quality ratio for yellow (good) skid color on grass.");
    redSkidThreshold_Grass = UI::SliderFloat("Grass Red Skid Threshold", redSkidThreshold_Grass, 0.00f, 0.70f);
    DrawHelpIcon("Minimum drift quality ratio for red (poor) skid color on grass. Below this stays default.");

    if (UI::Button("Reset Runtime Tuning Defaults")) {
        ResetRuntimeTuningDefaults();
    }

    UI::Separator();

    showAdvancedSettings = UI::Checkbox("Show advanced tuning", showAdvancedSettings);
    if (!showAdvancedSettings) {
        UI::TextWrapped("Enable advanced tuning to reveal hysteresis, debounce, and forgiveness controls.");
        return;
    }

    useSlopeAdjustedAcc = UI::Checkbox("Gravity Acceleration Adjustment", useSlopeAdjustedAcc);

    int swapDebounceInt = Math::Clamp(int(swapDebounceMs), 50, 2000);
    int newSwapDebounceInt = UI::SliderInt("Swap Debounce (ms)", swapDebounceInt, 50, 2000);
    DrawHelpIcon("Minimum time between skid texture swaps. Higher values reduce flicker but add response delay.");
    if (newSwapDebounceInt != swapDebounceInt) {
        swapDebounceMs = uint(newSwapDebounceInt);
    }

    UI::Separator();
    UI::Text("Hysteresis");
    skidHysteresisUp = UI::SliderFloat("Upgrade Hysteresis", skidHysteresisUp, 0.00f, 0.15f);
    DrawHelpIcon("Extra ratio required to upgrade tiers. Higher means harder to upgrade.");
    skidHysteresisDown = UI::SliderFloat("Downgrade Hysteresis", skidHysteresisDown, 0.00f, 0.15f);
    DrawHelpIcon("Buffer before downgrading tiers. Lower means faster downgrades.");

    UI::Separator();
    UI::Text("Stability Filters");
    promotionPersistenceFrames = UI::SliderInt("Promotion Persistence Frames", promotionPersistenceFrames, 0, 12);
    DrawHelpIcon("Frames required before a tier upgrade is accepted.");
    downgradePersistenceFrames = UI::SliderInt("Downgrade Persistence Frames", downgradePersistenceFrames, 0, 12);
    DrawHelpIcon("Frames required before a tier downgrade is accepted.");
    surfaceStabilityFrames = UI::SliderInt("Surface Stability Frames", surfaceStabilityFrames, 1, 8);
    DrawHelpIcon("Consecutive frames required before a detected surface becomes the active grading surface.");
    surfaceTransitionGraceMs = UI::SliderInt("Surface Transition Grace (ms)", surfaceTransitionGraceMs, 0, 400);
    DrawHelpIcon("After active surface changes, this window bypasses swap debounce to let the new surface react immediately.");
    landingLockoutMs = UI::SliderInt("Landing Lockout (ms)", landingLockoutMs, 0, 400);
    DrawHelpIcon("Temporarily blocks tier upgrades right after landing.");
    minSlipCoefToDrift = UI::SliderFloat("Min SlipCoef To Drift", minSlipCoefToDrift, 0.00f, 0.30f);
    DrawHelpIcon("Minimum FLSlipCoef required to count as drifting.");
    slipHysteresis = UI::SliderFloat("Slip Hysteresis", slipHysteresis, 0.00f, 0.15f);
    DrawHelpIcon("Exit threshold margin for drift detection. Exit = min slip - hysteresis.");
    postLandingImpactGuardMs = UI::SliderInt("Post-Landing Impact Guard (ms)", postLandingImpactGuardMs, 0, 300);
    DrawHelpIcon("Time window after landing where impact spikes can add upgrade persistence.");
    impactSpikeThreshold = UI::SliderFloat("Impact Spike Threshold", impactSpikeThreshold, 0.00f, 20.00f);
    DrawHelpIcon("Minimum acceleration delta to classify a post-landing spike.");
    impactExtraPromotionFrames = UI::SliderInt("Impact Extra Promotion Frames", impactExtraPromotionFrames, 0, 8);
    DrawHelpIcon("Extra upgrade persistence frames added during post-landing spikes.");
    postBoostImpactGuardMs = UI::SliderInt("Post-Boost Impact Guard (ms)", postBoostImpactGuardMs, 0, 300);
    DrawHelpIcon("Time window after boost ends where spikes can add upgrade persistence.");
    boostSpikeThreshold = UI::SliderFloat("Boost Spike Threshold", boostSpikeThreshold, 0.00f, 20.00f);
    DrawHelpIcon("Minimum acceleration delta to classify a post-boost spike.");
    boostExtraPromotionFrames = UI::SliderInt("Boost Extra Promotion Frames", boostExtraPromotionFrames, 0, 8);
    DrawHelpIcon("Extra upgrade persistence frames added during post-boost spikes.");
    allowLiveBoostGrading = UI::Checkbox("Allow Live Grading During Boost", allowLiveBoostGrading);
    boostBaselineFollowRate = UI::SliderFloat("Boost Baseline Follow Rate", boostBaselineFollowRate, 0.01f, 0.40f);
    DrawHelpIcon("How quickly boost baseline acceleration adapts while boosted and not drifting.");
    boostHeadroomScale = UI::SliderFloat("Boost Headroom Scale", boostHeadroomScale, 0.10f, 1.00f);
    DrawHelpIcon("Scales grading denominator during boost. Lower values make boost grading more lenient.");
    uphillSlopeLeniency = UI::SliderFloat("Uphill Slope Leniency", uphillSlopeLeniency, 0.00f, 0.12f);
    DrawHelpIcon("Adds a small ratio bonus while moving uphill.");
    downhillSlopeStrictness = UI::SliderFloat("Downhill Slope Strictness", downhillSlopeStrictness, 0.00f, 0.12f);
    DrawHelpIcon("Applies a small ratio penalty while moving downhill.");

    UI::Separator();
    lowSpeedForgivenessEnabled = UI::Checkbox("Low Speed Forgiveness", lowSpeedForgivenessEnabled);
    UI::Text("Low-speed forgiveness");
    UI::TextWrapped("Interpolation applies from Min Speed up to Max Speed for each surface.");

    UI::Text("Asphalt");
    forgivenessMinSpeed_Asphalt = UI::SliderFloat("Asphalt Forgiveness Min Speed", forgivenessMinSpeed_Asphalt, 400.0f, 600.0f);
    DrawHelpIcon("At or below this speed, maximum asphalt forgiveness is applied.");
    forgivenessMaxSpeed_Asphalt = UI::SliderFloat("Asphalt Forgiveness Max Speed", forgivenessMaxSpeed_Asphalt, 500.0f, 900.0f);
    DrawHelpIcon("At or above this speed, asphalt forgiveness is fully disabled.");
    forgivenessFactor_Asphalt = UI::SliderFloat("Asphalt Forgiveness Factor", forgivenessFactor_Asphalt, 0.60f, 1.00f);
    DrawHelpIcon("Multiplier applied at minimum speed. Lower = more forgiving.");

    UI::Text("Dirt");
    forgivenessMinSpeed_Dirt = UI::SliderFloat("Dirt Forgiveness Min Speed", forgivenessMinSpeed_Dirt, 50.0f, 300.0f);
    DrawHelpIcon("At or below this speed, maximum dirt forgiveness is applied.");
    forgivenessMaxSpeed_Dirt = UI::SliderFloat("Dirt Forgiveness Max Speed", forgivenessMaxSpeed_Dirt, 100.0f, 500.0f);
    DrawHelpIcon("At or above this speed, dirt forgiveness is fully disabled.");
    forgivenessFactor_Dirt = UI::SliderFloat("Dirt Forgiveness Factor", forgivenessFactor_Dirt, 0.60f, 1.00f);
    DrawHelpIcon("Multiplier applied at minimum speed. Lower = more forgiving.");

    UI::Text("Grass");
    forgivenessMinSpeed_Grass = UI::SliderFloat("Grass Forgiveness Min Speed", forgivenessMinSpeed_Grass, 50.0f, 300.0f);
    DrawHelpIcon("At or below this speed, maximum grass forgiveness is applied.");
    forgivenessMaxSpeed_Grass = UI::SliderFloat("Grass Forgiveness Max Speed", forgivenessMaxSpeed_Grass, 100.0f, 500.0f);
    DrawHelpIcon("At or above this speed, grass forgiveness is fully disabled.");
    forgivenessFactor_Grass = UI::SliderFloat("Grass Forgiveness Factor", forgivenessFactor_Grass, 0.60f, 1.00f);
    DrawHelpIcon("Multiplier applied at minimum speed. Lower = more forgiving.");
}
