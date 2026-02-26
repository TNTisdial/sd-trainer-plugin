// Owns: persisted settings declarations and settings/picker UI.

// --- Core Plugin Settings ---
[Setting hidden name="Enable Plugin" description="Enables/ Disables the plugin."]
bool pluginEnabled = true;

[Setting hidden name="Gravity Acceleration Adjustment" description="Calculate acceleration independently of gravity"]
bool useSlopeAdjustedAcc = true;

[Setting hidden name="Debug Logging" description="Print verbose debug info to the Openplanet console."]
bool debugLogging = false;

[Setting hidden name="Show Advanced Settings" description="Show advanced tuning controls in the Runtime settings tab."]
bool showAdvancedSettings = false;

// --- Runtime Tuning Settings ---
[Setting hidden name="Swap Debounce (ms)" description="Minimum time between color swaps in milliseconds. Lower = more responsive, higher = more stable." min=50 max=2000 drag]
uint swapDebounceMs = 260;

[Setting hidden name="Asphalt Green Skid Threshold" description="Minimum drift quality ratio for green (perfect) skid color on asphalt. 1.00 is a perfect SD." min=0.50 max=1.00 drag]
float greenSkidThreshold_Asphalt = 0.910f;

[Setting hidden name="Asphalt Yellow Skid Threshold" description="Minimum drift quality ratio for yellow (good) skid color on asphalt. 1.00 is a perfect SD." min=0.30 max=0.99 drag]
float yellowSkidThreshold_Asphalt = 0.70f;

[Setting hidden name="Asphalt Red Skid Threshold" description="Minimum drift quality ratio for red (poor) skid color on asphalt. Below this stays default. 1.00 is a perfect SD." min=0.0 max=0.70 drag]
float redSkidThreshold_Asphalt = 0.10f;

[Setting hidden name="Dirt Green Skid Threshold" description="Minimum drift quality ratio for green (perfect) skid color on dirt. 1.00 is a perfect SD." min=0.50 max=1.00 drag]
float greenSkidThreshold_Dirt = 0.910f;

[Setting hidden name="Dirt Yellow Skid Threshold" description="Minimum drift quality ratio for yellow (good) skid color on dirt. 1.00 is a perfect SD." min=0.30 max=0.99 drag]
float yellowSkidThreshold_Dirt = 0.70f;

[Setting hidden name="Dirt Red Skid Threshold" description="Minimum drift quality ratio for red (poor) skid color on dirt. Below this stays default. 1.00 is a perfect SD." min=0.0 max=0.70 drag]
float redSkidThreshold_Dirt = 0.10f;

[Setting hidden name="Grass Green Skid Threshold" description="Minimum drift quality ratio for green (perfect) skid color on grass. 1.00 is a perfect SD." min=0.50 max=1.00 drag]
float greenSkidThreshold_Grass = 0.910f;

[Setting hidden name="Grass Yellow Skid Threshold" description="Minimum drift quality ratio for yellow (good) skid color on grass. 1.00 is a perfect SD." min=0.30 max=0.99 drag]
float yellowSkidThreshold_Grass = 0.70f;

[Setting hidden name="Grass Red Skid Threshold" description="Minimum drift quality ratio for red (poor) skid color on grass. Below this stays default. 1.00 is a perfect SD." min=0.0 max=0.70 drag]
float redSkidThreshold_Grass = 0.10f;

[Setting hidden name="Upgrade Hysteresis" description="Buffer for upgrading color (e.g. red->yellow, yellow->green). Higher = harder to upgrade." min=0.0 max=0.15 drag]
float skidHysteresisUp = 0.015f;

[Setting hidden name="Downgrade Hysteresis" description="Buffer for downgrading color (e.g. green->yellow, yellow->red). Lower = faster downgrade." min=0.0 max=0.15 drag]
float skidHysteresisDown = 0.015f;

[Setting hidden name="Promotion Persistence Frames" description="Frames required before upgrading skid tier. 0 disables persistence."]
int promotionPersistenceFrames = 4;

[Setting hidden name="Downgrade Persistence Frames" description="Frames required before downgrading skid tier. 0 disables persistence."]
int downgradePersistenceFrames = 4;

[Setting hidden name="Surface Stability Frames" description="Consecutive frames required before a detected surface becomes active. Higher values resist one-frame surface spikes."]
int surfaceStabilityFrames = 2;

[Setting hidden name="Surface Transition Grace (ms)" description="Briefly bypass swap debounce after active surface changes. 0 disables transition grace."]
int surfaceTransitionGraceMs = 100;

[Setting hidden name="Landing Lockout (ms)" description="Block tier upgrades briefly after landing. 0 disables lockout."]
int landingLockoutMs = 30;

[Setting hidden name="Min SlipCoef To Drift" description="Minimum FLSlipCoef required to count as drifting. 0 keeps current behavior." min=0.00 max=0.30 drag]
float minSlipCoefToDrift = 0.150f;

[Setting hidden name="Slip Hysteresis" description="Extra FLSlipCoef margin to stop drifting. Exit threshold = Min SlipCoef To Drift - Slip Hysteresis. 0 disables."]
float slipHysteresis = 0.020f;

[Setting hidden name="Post-Landing Impact Guard (ms)" description="Window after landing where spike detection can add extra upgrade persistence frames. 0 disables."]
int postLandingImpactGuardMs = 30;

[Setting hidden name="Impact Spike Threshold" description="Minimum accel delta between frames to treat post-landing signal as an impact spike. 0 disables impact guard."]
float impactSpikeThreshold = 3.000f;

[Setting hidden name="Impact Extra Promotion Frames" description="Extra upgrade persistence frames applied during post-landing impact spikes."]
int impactExtraPromotionFrames = 2;

[Setting hidden name="Post-Boost Impact Guard (ms)" description="Window after boost ends where spike detection can add extra upgrade persistence frames. 0 disables."]
int postBoostImpactGuardMs = 100;

[Setting hidden name="Boost Spike Threshold" description="Minimum accel delta between frames to treat post-boost signal as a boost spike. 0 disables boost guard."]
float boostSpikeThreshold = 2.500f;

[Setting hidden name="Boost Extra Promotion Frames" description="Extra upgrade persistence frames applied during post-boost spikes."]
int boostExtraPromotionFrames = 2;

[Setting hidden name="Allow Live Grading During Boost" description="If enabled, boosted runs are graded live using boost-relative acceleration instead of freezing the current tier."]
bool allowLiveBoostGrading = true;

[Setting hidden name="Boost Baseline Follow Rate" description="EMA follow rate for boost baseline while boosted and not drifting. Higher tracks changes faster."]
float boostBaselineFollowRate = 0.080f;

[Setting hidden name="Boost Headroom Scale" description="Scales grading denominator while boosted. Lower = easier to reach high tiers under boost."]
float boostHeadroomScale = 0.45f;

[Setting hidden name="Uphill Slope Leniency" description="Slight ratio boost while moving uphill. 0 disables uphill slope bias."]
float uphillSlopeLeniency = 0.030f;

[Setting hidden name="Downhill Slope Strictness" description="Slight ratio reduction while moving downhill. 0 disables downhill slope bias."]
float downhillSlopeStrictness = 0.050f;

[Setting hidden name="Low Speed Forgiveness" description="Relax skid quality criteria at lower speeds where physics make speed gains harder."]
bool lowSpeedForgivenessEnabled = true;

[Setting hidden name="Asphalt Forgiveness Max Speed" description="Speed (km/h) above which no forgiveness is applied on asphalt." min=500 max=900 drag]
float forgivenessMaxSpeed_Asphalt = 550.0f;

[Setting hidden name="Asphalt Forgiveness Min Speed" description="Speed (km/h) at which maximum forgiveness is applied on asphalt." min=400 max=600 drag]
float forgivenessMinSpeed_Asphalt = 400.0f;

[Setting hidden name="Asphalt Forgiveness Factor" description="Multiplier at minimum speed on asphalt. Lower = more forgiving." min=0.60 max=1.00 drag]
float forgivenessFactor_Asphalt = 0.90f;

[Setting hidden name="Dirt Forgiveness Max Speed" description="Speed (km/h) above which no forgiveness is applied on dirt." min=100 max=500 drag]
float forgivenessMaxSpeed_Dirt = 300.0f;

[Setting hidden name="Dirt Forgiveness Min Speed" description="Speed (km/h) at which maximum forgiveness is applied on dirt." min=50 max=300 drag]
float forgivenessMinSpeed_Dirt = 150.0f;

[Setting hidden name="Dirt Forgiveness Factor" description="Multiplier at minimum speed on dirt. Lower = more forgiving." min=0.60 max=1.00 drag]
float forgivenessFactor_Dirt = 0.90f;

[Setting hidden name="Grass Forgiveness Max Speed" description="Speed (km/h) above which no forgiveness is applied on grass." min=100 max=500 drag]
float forgivenessMaxSpeed_Grass = 300.0f;

[Setting hidden name="Grass Forgiveness Min Speed" description="Speed (km/h) at which maximum forgiveness is applied on grass." min=50 max=300 drag]
float forgivenessMinSpeed_Grass = 150.0f;

[Setting hidden name="Grass Forgiveness Factor" description="Multiplier at minimum speed on grass. Lower = more forgiving." min=0.60 max=1.00 drag]
float forgivenessFactor_Grass = 0.90f;

// --- Settings Change Tracking State ---
bool _prev_pluginEnabled = true;
bool _prev_useSlopeAdjustedAcc = true;
uint _prev_swapDebounceMs = 225;
float _prev_greenSkidThreshold_Asphalt = 0.93f;
float _prev_yellowSkidThreshold_Asphalt = 0.70f;
float _prev_redSkidThreshold_Asphalt = 0.10f;
float _prev_greenSkidThreshold_Dirt = 0.93f;
float _prev_yellowSkidThreshold_Dirt = 0.70f;
float _prev_redSkidThreshold_Dirt = 0.10f;
float _prev_greenSkidThreshold_Grass = 0.93f;
float _prev_yellowSkidThreshold_Grass = 0.70f;
float _prev_redSkidThreshold_Grass = 0.10f;
float _prev_skidHysteresisUp = 0.015f;
float _prev_skidHysteresisDown = 0.015f;
int _prev_promotionPersistenceFrames = 0;
int _prev_downgradePersistenceFrames = 0;
int _prev_surfaceStabilityFrames = 2;
int _prev_surfaceTransitionGraceMs = 100;
int _prev_landingLockoutMs = 0;
float _prev_minSlipCoefToDrift = 0.00f;
float _prev_slipHysteresis = 0.00f;
int _prev_postLandingImpactGuardMs = 0;
float _prev_impactSpikeThreshold = 0.00f;
int _prev_impactExtraPromotionFrames = 0;
int _prev_postBoostImpactGuardMs = 0;
float _prev_boostSpikeThreshold = 0.00f;
int _prev_boostExtraPromotionFrames = 0;
bool _prev_allowLiveBoostGrading = true;
float _prev_boostBaselineFollowRate = 0.080f;
float _prev_boostHeadroomScale = 0.45f;
float _prev_uphillSlopeLeniency = 0.030f;
float _prev_downhillSlopeStrictness = 0.050f;
bool _prev_lowSpeedForgivenessEnabled = true;
float _prev_forgivenessMaxSpeed_Asphalt = 550.0f;
float _prev_forgivenessMinSpeed_Asphalt = 400.0f;
float _prev_forgivenessFactor_Asphalt = 0.90f;
float _prev_forgivenessMaxSpeed_Dirt = 300.0f;
float _prev_forgivenessMinSpeed_Dirt = 150.0f;
float _prev_forgivenessFactor_Dirt = 0.90f;
float _prev_forgivenessMaxSpeed_Grass = 300.0f;
float _prev_forgivenessMinSpeed_Grass = 150.0f;
float _prev_forgivenessFactor_Grass = 0.90f;

// --- Runtime Settings UI ---
string generalActionsStatus = "";

[Setting hidden]
string S_SettingsProfilesBlob = "";
[Setting hidden]
string S_SelectedSettingsProfile = "";

string settingsProfileNameInput = "";
string settingsProfileStatus = "";
array<string> settingsProfileNames;
array<string> settingsProfilePayloads;
bool settingsProfilesLoaded = false;

void DrawSettingsProfilesPanel();
void EnsureSettingsProfilesLoaded();

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
        bool rebuiltOk = BootstrapSkidRuntimeAssets();
        if (rebuiltOk) {
            generalActionsStatus = "Startup rebuild finished. Skids reloaded and primed.";
        } else {
            generalActionsStatus = "Startup rebuild completed with warnings. Check logs for missing files or staging issues.";
        }
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

bool TrackSettingChangeBool(const string &in label, bool current, bool previous) {
    if (current == previous) return false;
    trace("[Settings] " + label + ": " + previous + " -> " + current);
    return true;
}

bool TrackSettingChangeUint(const string &in label, uint current, uint previous) {
    if (current == previous) return false;
    trace("[Settings] " + label + ": " + previous + " -> " + current);
    return true;
}

bool TrackSettingChangeFloat(const string &in label, float current, float previous) {
    if (current == previous) return false;
    trace("[Settings] " + label + ": " + previous + " -> " + current);
    return true;
}

bool TrackSettingChangeInt(const string &in label, int current, int previous) {
    if (current == previous) return false;
    trace("[Settings] " + label + ": " + previous + " -> " + current);
    return true;
}

// Tracks setting changes in debug logs for easier tuning diagnostics.
void OnSettingsChanged() {
    if (!debugLogging) return;
    if (TrackSettingChangeBool("Enable Plugin", pluginEnabled, _prev_pluginEnabled)) _prev_pluginEnabled = pluginEnabled;
    if (TrackSettingChangeBool("Gravity Adjustment", useSlopeAdjustedAcc, _prev_useSlopeAdjustedAcc)) _prev_useSlopeAdjustedAcc = useSlopeAdjustedAcc;
    if (TrackSettingChangeUint("Swap Debounce (ms)", swapDebounceMs, _prev_swapDebounceMs)) _prev_swapDebounceMs = swapDebounceMs;
    if (TrackSettingChangeFloat("Asphalt Green Threshold", greenSkidThreshold_Asphalt, _prev_greenSkidThreshold_Asphalt)) _prev_greenSkidThreshold_Asphalt = greenSkidThreshold_Asphalt;
    if (TrackSettingChangeFloat("Asphalt Yellow Threshold", yellowSkidThreshold_Asphalt, _prev_yellowSkidThreshold_Asphalt)) _prev_yellowSkidThreshold_Asphalt = yellowSkidThreshold_Asphalt;
    if (TrackSettingChangeFloat("Asphalt Red Threshold", redSkidThreshold_Asphalt, _prev_redSkidThreshold_Asphalt)) _prev_redSkidThreshold_Asphalt = redSkidThreshold_Asphalt;
    if (TrackSettingChangeFloat("Dirt Green Threshold", greenSkidThreshold_Dirt, _prev_greenSkidThreshold_Dirt)) _prev_greenSkidThreshold_Dirt = greenSkidThreshold_Dirt;
    if (TrackSettingChangeFloat("Dirt Yellow Threshold", yellowSkidThreshold_Dirt, _prev_yellowSkidThreshold_Dirt)) _prev_yellowSkidThreshold_Dirt = yellowSkidThreshold_Dirt;
    if (TrackSettingChangeFloat("Dirt Red Threshold", redSkidThreshold_Dirt, _prev_redSkidThreshold_Dirt)) _prev_redSkidThreshold_Dirt = redSkidThreshold_Dirt;
    if (TrackSettingChangeFloat("Grass Green Threshold", greenSkidThreshold_Grass, _prev_greenSkidThreshold_Grass)) _prev_greenSkidThreshold_Grass = greenSkidThreshold_Grass;
    if (TrackSettingChangeFloat("Grass Yellow Threshold", yellowSkidThreshold_Grass, _prev_yellowSkidThreshold_Grass)) _prev_yellowSkidThreshold_Grass = yellowSkidThreshold_Grass;
    if (TrackSettingChangeFloat("Grass Red Threshold", redSkidThreshold_Grass, _prev_redSkidThreshold_Grass)) _prev_redSkidThreshold_Grass = redSkidThreshold_Grass;
    if (TrackSettingChangeFloat("Upgrade Hysteresis", skidHysteresisUp, _prev_skidHysteresisUp)) _prev_skidHysteresisUp = skidHysteresisUp;
    if (TrackSettingChangeFloat("Downgrade Hysteresis", skidHysteresisDown, _prev_skidHysteresisDown)) _prev_skidHysteresisDown = skidHysteresisDown;
    if (TrackSettingChangeInt("Promotion Persistence Frames", promotionPersistenceFrames, _prev_promotionPersistenceFrames)) _prev_promotionPersistenceFrames = promotionPersistenceFrames;
    if (TrackSettingChangeInt("Downgrade Persistence Frames", downgradePersistenceFrames, _prev_downgradePersistenceFrames)) _prev_downgradePersistenceFrames = downgradePersistenceFrames;
    if (TrackSettingChangeInt("Surface Stability Frames", surfaceStabilityFrames, _prev_surfaceStabilityFrames)) _prev_surfaceStabilityFrames = surfaceStabilityFrames;
    if (TrackSettingChangeInt("Surface Transition Grace (ms)", surfaceTransitionGraceMs, _prev_surfaceTransitionGraceMs)) _prev_surfaceTransitionGraceMs = surfaceTransitionGraceMs;
    if (TrackSettingChangeInt("Landing Lockout (ms)", landingLockoutMs, _prev_landingLockoutMs)) _prev_landingLockoutMs = landingLockoutMs;
    if (TrackSettingChangeFloat("Min SlipCoef To Drift", minSlipCoefToDrift, _prev_minSlipCoefToDrift)) _prev_minSlipCoefToDrift = minSlipCoefToDrift;
    if (TrackSettingChangeFloat("Slip Hysteresis", slipHysteresis, _prev_slipHysteresis)) _prev_slipHysteresis = slipHysteresis;
    if (TrackSettingChangeInt("Post-Landing Impact Guard (ms)", postLandingImpactGuardMs, _prev_postLandingImpactGuardMs)) _prev_postLandingImpactGuardMs = postLandingImpactGuardMs;
    if (TrackSettingChangeFloat("Impact Spike Threshold", impactSpikeThreshold, _prev_impactSpikeThreshold)) _prev_impactSpikeThreshold = impactSpikeThreshold;
    if (TrackSettingChangeInt("Impact Extra Promotion Frames", impactExtraPromotionFrames, _prev_impactExtraPromotionFrames)) _prev_impactExtraPromotionFrames = impactExtraPromotionFrames;
    if (TrackSettingChangeInt("Post-Boost Impact Guard (ms)", postBoostImpactGuardMs, _prev_postBoostImpactGuardMs)) _prev_postBoostImpactGuardMs = postBoostImpactGuardMs;
    if (TrackSettingChangeFloat("Boost Spike Threshold", boostSpikeThreshold, _prev_boostSpikeThreshold)) _prev_boostSpikeThreshold = boostSpikeThreshold;
    if (TrackSettingChangeInt("Boost Extra Promotion Frames", boostExtraPromotionFrames, _prev_boostExtraPromotionFrames)) _prev_boostExtraPromotionFrames = boostExtraPromotionFrames;
    if (TrackSettingChangeBool("Allow Live Grading During Boost", allowLiveBoostGrading, _prev_allowLiveBoostGrading)) _prev_allowLiveBoostGrading = allowLiveBoostGrading;
    if (TrackSettingChangeFloat("Boost Baseline Follow Rate", boostBaselineFollowRate, _prev_boostBaselineFollowRate)) _prev_boostBaselineFollowRate = boostBaselineFollowRate;
    if (TrackSettingChangeFloat("Boost Headroom Scale", boostHeadroomScale, _prev_boostHeadroomScale)) _prev_boostHeadroomScale = boostHeadroomScale;
    if (TrackSettingChangeFloat("Uphill Slope Leniency", uphillSlopeLeniency, _prev_uphillSlopeLeniency)) _prev_uphillSlopeLeniency = uphillSlopeLeniency;
    if (TrackSettingChangeFloat("Downhill Slope Strictness", downhillSlopeStrictness, _prev_downhillSlopeStrictness)) _prev_downhillSlopeStrictness = downhillSlopeStrictness;
    if (TrackSettingChangeBool("Low Speed Forgiveness", lowSpeedForgivenessEnabled, _prev_lowSpeedForgivenessEnabled)) _prev_lowSpeedForgivenessEnabled = lowSpeedForgivenessEnabled;
    if (TrackSettingChangeFloat("Asphalt Forgiveness Max Speed", forgivenessMaxSpeed_Asphalt, _prev_forgivenessMaxSpeed_Asphalt)) _prev_forgivenessMaxSpeed_Asphalt = forgivenessMaxSpeed_Asphalt;
    if (TrackSettingChangeFloat("Asphalt Forgiveness Min Speed", forgivenessMinSpeed_Asphalt, _prev_forgivenessMinSpeed_Asphalt)) _prev_forgivenessMinSpeed_Asphalt = forgivenessMinSpeed_Asphalt;
    if (TrackSettingChangeFloat("Asphalt Forgiveness Factor", forgivenessFactor_Asphalt, _prev_forgivenessFactor_Asphalt)) _prev_forgivenessFactor_Asphalt = forgivenessFactor_Asphalt;
    if (TrackSettingChangeFloat("Dirt Forgiveness Max Speed", forgivenessMaxSpeed_Dirt, _prev_forgivenessMaxSpeed_Dirt)) _prev_forgivenessMaxSpeed_Dirt = forgivenessMaxSpeed_Dirt;
    if (TrackSettingChangeFloat("Dirt Forgiveness Min Speed", forgivenessMinSpeed_Dirt, _prev_forgivenessMinSpeed_Dirt)) _prev_forgivenessMinSpeed_Dirt = forgivenessMinSpeed_Dirt;
    if (TrackSettingChangeFloat("Dirt Forgiveness Factor", forgivenessFactor_Dirt, _prev_forgivenessFactor_Dirt)) _prev_forgivenessFactor_Dirt = forgivenessFactor_Dirt;
    if (TrackSettingChangeFloat("Grass Forgiveness Max Speed", forgivenessMaxSpeed_Grass, _prev_forgivenessMaxSpeed_Grass)) _prev_forgivenessMaxSpeed_Grass = forgivenessMaxSpeed_Grass;
    if (TrackSettingChangeFloat("Grass Forgiveness Min Speed", forgivenessMinSpeed_Grass, _prev_forgivenessMinSpeed_Grass)) _prev_forgivenessMinSpeed_Grass = forgivenessMinSpeed_Grass;
    if (TrackSettingChangeFloat("Grass Forgiveness Factor", forgivenessFactor_Grass, _prev_forgivenessFactor_Grass)) _prev_forgivenessFactor_Grass = forgivenessFactor_Grass;
}

// --- Skid Picker Persisted Settings ---
[Setting hidden]
string S_AsphaltHighSkidFile = "BlueFadeThicc.dds";
[Setting hidden]
string S_AsphaltMidSkidFile = "YellowFadeThicc.dds";
[Setting hidden]
string S_AsphaltPoorSkidFile = "RedFadeThicc.dds";

[Setting hidden]
string S_DirtHighSkidFile = "BlueFadeThicc.dds";
[Setting hidden]
string S_DirtMidSkidFile = "YellowFadeThicc.dds";
[Setting hidden]
string S_DirtPoorSkidFile = "RedFadeThicc.dds";

[Setting hidden]
string S_GrassHighSkidFile = "BlueFadeThicc.dds";
[Setting hidden]
string S_GrassMidSkidFile = "YellowFadeThicc.dds";
[Setting hidden]
string S_GrassPoorSkidFile = "RedFadeThicc.dds";

[Setting hidden]
bool S_ShowSkidPicker = false;

const int kSettingsProfileVersion = 1;
const int kSettingsProfileFieldCount = 51;

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

bool LoadSelectedSettingsProfile() {
    EnsureSettingsProfilesLoaded();

    int selectedIx = FindSettingsProfileIndexByName(S_SelectedSettingsProfile);
    if (selectedIx < 0) {
        settingsProfileStatus = "Select a saved profile first.";
        return false;
    }

    if (!ApplySettingsProfilePayload(settingsProfilePayloads[selectedIx])) {
        settingsProfileStatus = "Profile is invalid or from an unsupported version.";
        return false;
    }

    EnsureConfiguredSkidFilesExist();
    bool rebuiltOk = BootstrapSkidRuntimeAssets();
    if (rebuiltOk) {
        settingsProfileStatus = "Loaded profile: " + S_SelectedSettingsProfile;
    } else {
        settingsProfileStatus = "Profile loaded with startup warnings; check logs.";
    }
    return rebuiltOk;
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
    DrawHelpIcon("Saving with an existing name overwrites that profile.");

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
        LoadSelectedSettingsProfile();
    }
    UI::SameLine();
    if (UI::Button("Duplicate To Name")) {
        DuplicateSelectedSettingsProfile(settingsProfileNameInput);
    }
    UI::SameLine();
    if (UI::Button("Rename Selected To Name")) {
        RenameSelectedSettingsProfile(settingsProfileNameInput);
    }
    UI::SameLine();
    if (UI::Button(Icons::TrashO + " Delete Selected Profile")) {
        DeleteSelectedSettingsProfile();
    }

    if (settingsProfileStatus.Length > 0) {
        UI::TextWrapped(settingsProfileStatus);
    }
}

// --- Skid Picker Runtime State ---
array<string> skidOptionFiles_Asphalt;
array<string> skidOptionPretty_Asphalt;
array<string> skidOptionFiles_Dirt;
array<string> skidOptionPretty_Dirt;
array<string> skidOptionFiles_Grass;
array<string> skidOptionPretty_Grass;

string SKID_OPTIONS_DIR_ASPHALT;
string SKID_OPTIONS_DIR_DIRT;
string SKID_OPTIONS_DIR_GRASS;

IMG::TextureManager texMgr = IMG::TextureManager();
const vec2 PREVIEW_SIZE = vec2(200, 200);

const string MENU_TITLE = "\\$a3f" + Icons::PaintBrush + "\\$z Skid Skin Picker";

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
