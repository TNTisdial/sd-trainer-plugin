// Owns: persisted settings declarations and settings/picker UI.

// --- Core Plugin Settings ---
[Setting name="Enable Plugin" description="Enables/ Disables the plugin."]
bool pluginEnabled = true;

[Setting hidden name="Gravity Acceleration Adjustment" description="Calculate acceleration independently of gravity"]
bool useSlopeAdjustedAcc = true;

[Setting name="Debug Logging" description="Print verbose debug info to the Openplanet console."]
bool debugLogging = false;

[Setting hidden name="Show Advanced Settings" description="Show advanced tuning controls in the Runtime settings tab."]
bool showAdvancedSettings = false;

// --- Runtime Tuning Settings ---
[Setting hidden name="Swap Debounce (ms)" description="Minimum time between color swaps in milliseconds. Lower = more responsive, higher = more stable." min="50" max="2000" drag="true"]
uint64 swapDebounceMs = 260;

[Setting hidden name="Green Skid Threshold" description="Minimum drift quality ratio for green (perfect) skid color. 1.00 is a perfect SD." min="0.50" max="1.00" drag="true"]
float greenSkidThreshold = 0.910f;

[Setting hidden name="Yellow Skid Threshold" description="Minimum drift quality ratio for yellow (good) skid color. 1.00 is a perfect SD." min="0.30" max="0.99" drag="true"]
float yellowSkidThreshold = 0.70f;

[Setting hidden name="Red Skid Threshold" description="Minimum drift quality ratio for red (poor) skid color. Below this stays default. 1.00 is a perfect SD." min="0.0" max="0.70" drag="true"]
float redSkidThreshold = 0.10f;

[Setting hidden name="Upgrade Hysteresis" description="Buffer for upgrading color (e.g. red->yellow, yellow->green). Higher = harder to upgrade." min="0.0" max="0.15" drag="true"]
float skidHysteresisUp = 0.015f;

[Setting hidden name="Downgrade Hysteresis" description="Buffer for downgrading color (e.g. green->yellow, yellow->red). Lower = faster downgrade." min="0.0" max="0.15" drag="true"]
float skidHysteresisDown = 0.015f;

[Setting hidden name="Promotion Persistence Frames" description="Frames required before upgrading skid tier. 0 disables persistence."]
int promotionPersistenceFrames = 4;

[Setting hidden name="Downgrade Persistence Frames" description="Frames required before downgrading skid tier. 0 disables persistence."]
int downgradePersistenceFrames = 4;

[Setting hidden name="Landing Lockout (ms)" description="Block tier upgrades briefly after landing. 0 disables lockout."]
int landingLockoutMs = 30;

[Setting hidden name="Min SlipCoef To Drift" description="Minimum FLSlipCoef required to count as drifting. 0 keeps current behavior." min="0.00" max="0.30" drag="true"]
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

[Setting hidden name="Asphalt Forgiveness Max Speed" description="Speed (km/h) above which no forgiveness is applied on asphalt." min="500" max="900" drag="true"]
float forgivenessMaxSpeed_Asphalt = 550.0f;

[Setting hidden name="Asphalt Forgiveness Min Speed" description="Speed (km/h) at which maximum forgiveness is applied on asphalt." min="400" max="600" drag="true"]
float forgivenessMinSpeed_Asphalt = 400.0f;

[Setting hidden name="Asphalt Forgiveness Factor" description="Multiplier at minimum speed on asphalt. Lower = more forgiving." min="0.60" max="1.00" drag="true"]
float forgivenessFactor_Asphalt = 0.90f;

[Setting hidden name="Dirt Forgiveness Max Speed" description="Speed (km/h) above which no forgiveness is applied on dirt." min="100" max="500" drag="true"]
float forgivenessMaxSpeed_Dirt = 300.0f;

[Setting hidden name="Dirt Forgiveness Min Speed" description="Speed (km/h) at which maximum forgiveness is applied on dirt." min="50" max="300" drag="true"]
float forgivenessMinSpeed_Dirt = 150.0f;

[Setting hidden name="Dirt Forgiveness Factor" description="Multiplier at minimum speed on dirt. Lower = more forgiving." min="0.60" max="1.00" drag="true"]
float forgivenessFactor_Dirt = 0.90f;

[Setting hidden name="Grass Forgiveness Max Speed" description="Speed (km/h) above which no forgiveness is applied on grass." min="100" max="500" drag="true"]
float forgivenessMaxSpeed_Grass = 300.0f;

[Setting hidden name="Grass Forgiveness Min Speed" description="Speed (km/h) at which maximum forgiveness is applied on grass." min="50" max="300" drag="true"]
float forgivenessMinSpeed_Grass = 150.0f;

[Setting hidden name="Grass Forgiveness Factor" description="Multiplier at minimum speed on grass. Lower = more forgiving." min="0.60" max="1.00" drag="true"]
float forgivenessFactor_Grass = 0.90f;

// --- Settings Change Tracking State ---
bool _prev_pluginEnabled = true;
bool _prev_useSlopeAdjustedAcc = true;
uint64 _prev_swapDebounceMs = 225;
float _prev_greenSkidThreshold = 0.93f;
float _prev_yellowSkidThreshold = 0.70f;
float _prev_redSkidThreshold = 0.10f;
float _prev_skidHysteresisUp = 0.015f;
float _prev_skidHysteresisDown = 0.015f;
int _prev_promotionPersistenceFrames = 0;
int _prev_downgradePersistenceFrames = 0;
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
    greenSkidThreshold = 0.910f;
    yellowSkidThreshold = 0.70f;
    redSkidThreshold = 0.10f;
    skidHysteresisUp = 0.015f;
    skidHysteresisDown = 0.015f;

    promotionPersistenceFrames = 4;
    downgradePersistenceFrames = 4;
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
    UI::Separator();

    UI::Text("Tier thresholds (driftQualityRatio)");
    UI::TextWrapped("Reference: 1.00 is a perfect SD.");
    greenSkidThreshold = UI::SliderFloat("Green Skid Threshold", greenSkidThreshold, 0.50f, 1.00f);
    DrawHelpIcon("Minimum drift quality ratio for green (perfect) skid color.");
    yellowSkidThreshold = UI::SliderFloat("Yellow Skid Threshold", yellowSkidThreshold, 0.30f, 0.99f);
    DrawHelpIcon("Minimum drift quality ratio for yellow (good) skid color.");
    redSkidThreshold = UI::SliderFloat("Red Skid Threshold", redSkidThreshold, 0.00f, 0.70f);
    DrawHelpIcon("Minimum drift quality ratio for red (poor) skid color. Below this stays default.");

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
        swapDebounceMs = uint64(newSwapDebounceInt);
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

bool TrackSettingChangeUint64(const string &in label, uint64 current, uint64 previous) {
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

// Makes it easier to see what the hell is happening when debugging
void OnSettingsChanged() {
    if (!debugLogging) return;
    if (TrackSettingChangeBool("Enable Plugin", pluginEnabled, _prev_pluginEnabled)) _prev_pluginEnabled = pluginEnabled;
    if (TrackSettingChangeBool("Gravity Adjustment", useSlopeAdjustedAcc, _prev_useSlopeAdjustedAcc)) _prev_useSlopeAdjustedAcc = useSlopeAdjustedAcc;
    if (TrackSettingChangeUint64("Swap Debounce (ms)", swapDebounceMs, _prev_swapDebounceMs)) _prev_swapDebounceMs = swapDebounceMs;
    if (TrackSettingChangeFloat("Green Threshold", greenSkidThreshold, _prev_greenSkidThreshold)) _prev_greenSkidThreshold = greenSkidThreshold;
    if (TrackSettingChangeFloat("Yellow Threshold", yellowSkidThreshold, _prev_yellowSkidThreshold)) _prev_yellowSkidThreshold = yellowSkidThreshold;
    if (TrackSettingChangeFloat("Red Threshold", redSkidThreshold, _prev_redSkidThreshold)) _prev_redSkidThreshold = redSkidThreshold;
    if (TrackSettingChangeFloat("Upgrade Hysteresis", skidHysteresisUp, _prev_skidHysteresisUp)) _prev_skidHysteresisUp = skidHysteresisUp;
    if (TrackSettingChangeFloat("Downgrade Hysteresis", skidHysteresisDown, _prev_skidHysteresisDown)) _prev_skidHysteresisDown = skidHysteresisDown;
    if (TrackSettingChangeInt("Promotion Persistence Frames", promotionPersistenceFrames, _prev_promotionPersistenceFrames)) _prev_promotionPersistenceFrames = promotionPersistenceFrames;
    if (TrackSettingChangeInt("Downgrade Persistence Frames", downgradePersistenceFrames, _prev_downgradePersistenceFrames)) _prev_downgradePersistenceFrames = downgradePersistenceFrames;
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
string S_DirtHighSkidFile = "BlueDirtFadeThicc.dds";
[Setting hidden]
string S_DirtMidSkidFile = "YellowDirtFadeThicc.dds";
[Setting hidden]
string S_DirtPoorSkidFile = "RedDirtFadeThicc.dds";

[Setting hidden]
string S_GrassHighSkidFile = "BlueFadeThicc.dds";
[Setting hidden]
string S_GrassMidSkidFile = "YellowFadeThicc.dds";
[Setting hidden]
string S_GrassPoorSkidFile = "RedFadeThicc.dds";

[Setting hidden]
bool S_ShowSkidPicker = true;

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
    S_DirtHighSkidFile = ResolveConfiguredSkidFile(skidOptionFiles_Dirt, S_DirtHighSkidFile, "BlueDirtFadeThicc.dds");
    S_DirtMidSkidFile = ResolveConfiguredSkidFile(skidOptionFiles_Dirt, S_DirtMidSkidFile, "YellowDirtFadeThicc.dds");
    S_DirtPoorSkidFile = ResolveConfiguredSkidFile(skidOptionFiles_Dirt, S_DirtPoorSkidFile, "RedDirtFadeThicc.dds");
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
    SKID_OPTIONS_DIR_ASPHALT = IO::FromUserGameFolder("Skins/Stadium/Skids/Asphalt/").Replace("\\", "/");
    SKID_OPTIONS_DIR_DIRT = IO::FromUserGameFolder("Skins/Stadium/Skids/Dirt/").Replace("\\", "/");
    SKID_OPTIONS_DIR_GRASS = IO::FromUserGameFolder("Skins/Stadium/Skids/Grass/").Replace("\\", "/");

    trace("[SkidSettings] Asphalt: " + SKID_OPTIONS_DIR_ASPHALT);
    trace("[SkidSettings] Dirt:    " + SKID_OPTIONS_DIR_DIRT);
    trace("[SkidSettings] Grass:   " + SKID_OPTIONS_DIR_GRASS);

    RefreshAllSkidOptionLists();
}
