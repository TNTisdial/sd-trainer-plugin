// --- Constants and Enums ---
const int ACCEL_ARRAY_SIZE = 4;

const float MIN_XZ_CHANGE_ESTIMATE = 0.01f;
const float MIN_EFFECTIVE_DT_MS = 1.0f;
const float GRAVITY_COMPENSATION = 29.0f;
const float ACCEL_NOISE_FLOOR = 0.2f;
const float MIN_ACCEL_DENOM = 0.001f;

const float PERFECT_BUFFER = 0.3f;
const float ASPHALT_BASE_MAX_ACCEL = 16.0f;
const float ASPHALT_HIGH_SPEED_THRESHOLD_KMH = 400.0f;
const float ASPHALT_HIGH_SPEED_BASE = 4.915f;
const float ASPHALT_HIGH_SPEED_SLOPE = 0.003984518249f;
const float DIRT_MAX_ACCEL = 9.39951f;
const float GRASS_MAX_ACCEL = 9.10985f;

enum SkidSurface {
    Asphalt,
    Dirt,
    Grass
}

enum DriftTier {
    Default,
    Poor,
    Mid,
    High
}

array<SkidSurface> kSurfaces = {SkidSurface::Asphalt, SkidSurface::Dirt, SkidSurface::Grass};

// --- Settings ---
[Setting name="Enable Plugin" description="Enables/ Disables the plugin."]
bool pluginEnabled = true;

[Setting hidden name="Gravity Acceleration Adjustment" description="Calculate acceleration independently of gravity"]
bool useSlopeAdjustedAcc = true;

[Setting name="Debug Logging" description="Print verbose debug info to the Openplanet console."]
bool debugLogging = false;

[Setting hidden name="Show Advanced Settings" description="Show advanced tuning controls in the Runtime settings tab."]
bool showAdvancedSettings = false;

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
int landingLockoutMs = 80;

[Setting hidden name="Min SlipCoef To Drift" description="Minimum FLSlipCoef required to count as drifting. 0 keeps current behavior." min="0.00" max="0.30" drag="true"]
float minSlipCoefToDrift = 0.150f;

[Setting hidden name="Slip Hysteresis" description="Extra FLSlipCoef margin to stop drifting. Exit threshold = Min SlipCoef To Drift - Slip Hysteresis. 0 disables."]
float slipHysteresis = 0.020f;

[Setting hidden name="Post-Landing Impact Guard (ms)" description="Window after landing where spike detection can add extra upgrade persistence frames. 0 disables."]
int postLandingImpactGuardMs = 60;

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

// --- State ---
float prevSpeed;
array<float> accelArray = {0, 0, 0, 0};
array<float> accelArrayNoAdjust = {0, 0, 0, 0};

vec3 worldNormalVec;
vec3 driftDirVec = vec3(0, 0, 0);
vec3 prevDriftDirVec = vec3(0, 0, 0);
array<float> driftAngleDeltaArray = {0, 0, 0, 0};
float averageAngleDifference = 0;
bool isDrifting = false;
bool isBoosted = false;

vec3 currentVelocity;
vec3 normalisedCurrentVelocity;
int accelArrayIndex = 0;

CSceneVehicleVisState::EPlugSurfaceMaterialId currentSurfaceMaterial;

float averageAcceleration = 0;
float slopeAdjustedAcceleration = 0;
float frameDtMs = 0;

string MODWORK_FOLDER;
string MODWORK_CARFX_FOLDER;
string SKIDS_SOURCE_DIR_ASPHALT;
string SKIDS_SOURCE_DIR_DIRT;
string SKIDS_SOURCE_DIR_GRASS;

DriftTier currentTier = DriftTier::Default;
uint64 lastSkidSwapTime = 0;
DriftTier pendingTier = DriftTier::Default;
int pendingTierFrames = 0;
bool wasGroundedLastFrame = false;
uint64 landingLockoutUntilMs = 0;
uint64 lastLandingTimeMs = 0;
float postLandingAccelDelta = 0.0f;
bool wasBoostedLastFrame = false;
uint64 lastBoostEndTimeMs = 0;

array<string> skidTexturesAsphalt;
array<string> skidTexturesDirt;
array<string> skidTexturesGrass;

bool stagedFilesReady = false;
string bundledSkidsRoot;

// Snapshot of settings values - used to detect changes in OnSettingsChanged.
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

// --- Helpers ---
void dbg(const string &in msg) {
    if (debugLogging) trace(msg);
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

string SurfaceId(SkidSurface surfaceKind) {
    if (surfaceKind == SkidSurface::Dirt) return "dirt";
    if (surfaceKind == SkidSurface::Grass) return "grass";
    return "asphalt";
}

string SurfaceFolderName(SkidSurface surfaceKind) {
    if (surfaceKind == SkidSurface::Dirt) return "Dirt";
    if (surfaceKind == SkidSurface::Grass) return "Grass";
    return "Asphalt";
}

string TierName(DriftTier tier) {
    if (tier == DriftTier::High) return "high";
    if (tier == DriftTier::Mid) return "mid";
    if (tier == DriftTier::Poor) return "poor";
    return "default";
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
    landingLockoutMs = 80;
    minSlipCoefToDrift = 0.150f;
    slipHysteresis = 0.020f;
    postLandingImpactGuardMs = 60;
    impactSpikeThreshold = 3.000f;
    impactExtraPromotionFrames = 2;
    postBoostImpactGuardMs = 100;
    boostSpikeThreshold = 2.500f;
    boostExtraPromotionFrames = 2;

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
    yellowSkidThreshold = UI::SliderFloat("Yellow Skid Threshold", yellowSkidThreshold, 0.30f, 0.99f);
    redSkidThreshold = UI::SliderFloat("Red Skid Threshold", redSkidThreshold, 0.00f, 0.70f);

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
    if (newSwapDebounceInt != swapDebounceInt) {
        swapDebounceMs = uint64(newSwapDebounceInt);
    }

    UI::Separator();
    UI::Text("Hysteresis");
    skidHysteresisUp = UI::SliderFloat("Upgrade Hysteresis", skidHysteresisUp, 0.00f, 0.15f);
    skidHysteresisDown = UI::SliderFloat("Downgrade Hysteresis", skidHysteresisDown, 0.00f, 0.15f);

    UI::Separator();
    UI::Text("Stability Filters");
    promotionPersistenceFrames = UI::SliderInt("Promotion Persistence Frames", promotionPersistenceFrames, 0, 12);
    downgradePersistenceFrames = UI::SliderInt("Downgrade Persistence Frames", downgradePersistenceFrames, 0, 12);
    landingLockoutMs = UI::SliderInt("Landing Lockout (ms)", landingLockoutMs, 0, 400);
    minSlipCoefToDrift = UI::SliderFloat("Min SlipCoef To Drift", minSlipCoefToDrift, 0.00f, 0.30f);
    slipHysteresis = UI::SliderFloat("Slip Hysteresis", slipHysteresis, 0.00f, 0.15f);
    postLandingImpactGuardMs = UI::SliderInt("Post-Landing Impact Guard (ms)", postLandingImpactGuardMs, 0, 300);
    impactSpikeThreshold = UI::SliderFloat("Impact Spike Threshold", impactSpikeThreshold, 0.00f, 20.00f);
    impactExtraPromotionFrames = UI::SliderInt("Impact Extra Promotion Frames", impactExtraPromotionFrames, 0, 8);
    postBoostImpactGuardMs = UI::SliderInt("Post-Boost Impact Guard (ms)", postBoostImpactGuardMs, 0, 300);
    boostSpikeThreshold = UI::SliderFloat("Boost Spike Threshold", boostSpikeThreshold, 0.00f, 20.00f);
    boostExtraPromotionFrames = UI::SliderInt("Boost Extra Promotion Frames", boostExtraPromotionFrames, 0, 8);

    UI::Separator();
    lowSpeedForgivenessEnabled = UI::Checkbox("Low Speed Forgiveness", lowSpeedForgivenessEnabled);
    UI::Text("Low-speed forgiveness");
    UI::TextWrapped("Interpolation applies from Min Speed up to Max Speed for each surface.");

    UI::Text("Asphalt");
    forgivenessMinSpeed_Asphalt = UI::SliderFloat("Asphalt Forgiveness Min Speed", forgivenessMinSpeed_Asphalt, 400.0f, 600.0f);
    forgivenessMaxSpeed_Asphalt = UI::SliderFloat("Asphalt Forgiveness Max Speed", forgivenessMaxSpeed_Asphalt, 500.0f, 900.0f);
    forgivenessFactor_Asphalt = UI::SliderFloat("Asphalt Forgiveness Factor", forgivenessFactor_Asphalt, 0.60f, 1.00f);

    UI::Text("Dirt");
    forgivenessMinSpeed_Dirt = UI::SliderFloat("Dirt Forgiveness Min Speed", forgivenessMinSpeed_Dirt, 50.0f, 300.0f);
    forgivenessMaxSpeed_Dirt = UI::SliderFloat("Dirt Forgiveness Max Speed", forgivenessMaxSpeed_Dirt, 100.0f, 500.0f);
    forgivenessFactor_Dirt = UI::SliderFloat("Dirt Forgiveness Factor", forgivenessFactor_Dirt, 0.60f, 1.00f);

    UI::Text("Grass");
    forgivenessMinSpeed_Grass = UI::SliderFloat("Grass Forgiveness Min Speed", forgivenessMinSpeed_Grass, 50.0f, 300.0f);
    forgivenessMaxSpeed_Grass = UI::SliderFloat("Grass Forgiveness Max Speed", forgivenessMaxSpeed_Grass, 100.0f, 500.0f);
    forgivenessFactor_Grass = UI::SliderFloat("Grass Forgiveness Factor", forgivenessFactor_Grass, 0.60f, 1.00f);
}

// --- Main Entrypoints ---
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

void Main() {
    InitSkidSettings();

    MODWORK_FOLDER = IO::FromUserGameFolder("Skins/Stadium/ModWork").Replace("\\", "/");
    MODWORK_CARFX_FOLDER = MODWORK_FOLDER + "/CarFxImage";
    EnsureDir(MODWORK_FOLDER);
    EnsureDir(MODWORK_CARFX_FOLDER);

    SKIDS_SOURCE_DIR_ASPHALT = IO::FromUserGameFolder("Skins/Stadium/Skids/Asphalt").Replace("\\", "/");
    SKIDS_SOURCE_DIR_DIRT = IO::FromUserGameFolder("Skins/Stadium/Skids/Dirt").Replace("\\", "/");
    SKIDS_SOURCE_DIR_GRASS = IO::FromUserGameFolder("Skins/Stadium/Skids/Grass").Replace("\\", "/");
    EnsureDir(SKIDS_SOURCE_DIR_ASPHALT);
    EnsureDir(SKIDS_SOURCE_DIR_DIRT);
    EnsureDir(SKIDS_SOURCE_DIR_GRASS);

    InstallBundledSkids();
    RefreshAllSkidOptionLists();
    EnsureConfiguredSkidFilesExist();
    RefreshTextureList();

    int totalTextures = TotalLoadedSkidTextures();
    if (totalTextures == 0) {
        warn("[Init] No .dds textures found in any surface folder. Colored skids disabled.");
        stagedFilesReady = false;
    } else {
        dbg("[Init] Textures loaded - Asphalt: " + skidTexturesAsphalt.Length
            + ", Dirt: " + skidTexturesDirt.Length
            + ", Grass: " + skidTexturesGrass.Length);

        bool allStaged = StageRequiredTexturesForAllSurfaces();

        if (allStaged) {
            allStaged = PrimeLiveDefaultsForAllSurfaces();
        }

        stagedFilesReady = allStaged;
        if (stagedFilesReady) {
            currentTier = DriftTier::Default;
            RefreshGameTextures();
            dbg("[Init] Startup staging and priming completed.");
        } else {
            warn("[Init] One or more textures failed to stage/prime; colored skids disabled.");
        }
    }

    while (Display::GetWidth() == -1) {
        yield();
    }
}

void Render() {
    if (!pluginEnabled) {
        return;
    }

    auto app = GetApp();
    auto sceneVis = app.GameScene;
    if (sceneVis is null || VehicleState::ViewingPlayerState() is null) {
        return;
    }

    SimulationStep();

    float speedKmh = prevSpeed * 3.6f;
    float adjustedMaxAccelSpeedSlide = ComputeAdjustedMaxAccelSpeedSlide(speedKmh);

    if (lowSpeedForgivenessEnabled) {
        adjustedMaxAccelSpeedSlide = ApplyLowSpeedForgiveness(adjustedMaxAccelSpeedSlide, speedKmh, SurfaceFromMaterial(currentSurfaceMaterial));
    }

    float denom = Math::Max(MIN_ACCEL_DENOM, adjustedMaxAccelSpeedSlide);
    float driftQualityRatio = slopeAdjustedAcceleration / denom;
    if (driftQualityRatio > 1.0f) {
        driftQualityRatio = 1.0f;
    } else if (driftQualityRatio < -1.0f) {
        driftQualityRatio = -1.0f;
    }

    DriftTier targetTier = DetermineTargetTier(driftQualityRatio);
    targetTier = ApplyLandingLockoutGate(targetTier);
    targetTier = ApplyTierPersistenceGate(targetTier);
    bool tierChanged = targetTier != currentTier;
    if (!tierChanged || Time::Now - lastSkidSwapTime <= swapDebounceMs) {
        return;
    }

    if (!stagedFilesReady) {
        dbg("[Render] Skipping swap: staged files not ready.");
        return;
    }

    dbg("[Render] Tier changed: " + TierName(currentTier) + " -> " + TierName(targetTier));

    bool anyChanged = false;
    bool allOk = SwapSkidTextureAllSurfaces(targetTier, anyChanged);
    if (anyChanged) {
        RefreshGameTextures();
    }

    if (allOk) {
        currentTier = targetTier;
        lastSkidSwapTime = Time::Now;
        dbg("[Render] Swap complete for all surfaces: tier=" + TierName(targetTier));
    } else {
        warn("[Render] Partial skid swap failure. Keeping previous tier state for retry.");
    }
}
