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
uint64 swapDebounceMs = 250;

[Setting hidden name="Green Skid Threshold" description="Minimum drift quality ratio for green (perfect) skid color. 1.00 is a perfect SD." min="0.50" max="1.00" drag="true"]
float greenSkidThreshold = 0.94f;

[Setting hidden name="Yellow Skid Threshold" description="Minimum drift quality ratio for yellow (good) skid color. 1.00 is a perfect SD." min="0.30" max="0.99" drag="true"]
float yellowSkidThreshold = 0.75f;

[Setting hidden name="Red Skid Threshold" description="Minimum drift quality ratio for red (poor) skid color. Below this stays default. 1.00 is a perfect SD." min="0.0" max="0.70" drag="true"]
float redSkidThreshold = 0.20f;

[Setting hidden name="Upgrade Hysteresis" description="Buffer for upgrading color (e.g. red->yellow, yellow->green). Higher = harder to upgrade." min="0.0" max="0.15" drag="true"]
float skidHysteresisUp = 0.02f;

[Setting hidden name="Downgrade Hysteresis" description="Buffer for downgrading color (e.g. green->yellow, yellow->red). Lower = faster downgrade." min="0.0" max="0.15" drag="true"]
float skidHysteresisDown = 0.01f;

[Setting hidden name="Low Speed Forgiveness" description="Relax skid quality criteria at lower speeds where physics make speed gains harder."]
bool lowSpeedForgivenessEnabled = true;

[Setting hidden name="Asphalt Forgiveness Max Speed" description="Speed (km/h) above which no forgiveness is applied on asphalt." min="500" max="900" drag="true"]
float forgivenessMaxSpeed_Asphalt = 700.0f;

[Setting hidden name="Asphalt Forgiveness Min Speed" description="Speed (km/h) at which maximum forgiveness is applied on asphalt." min="400" max="600" drag="true"]
float forgivenessMinSpeed_Asphalt = 400.0f;

[Setting hidden name="Asphalt Forgiveness Factor" description="Multiplier at minimum speed on asphalt. Lower = more forgiving." min="0.60" max="1.00" drag="true"]
float forgivenessFactor_Asphalt = 0.80f;

[Setting hidden name="Dirt Forgiveness Max Speed" description="Speed (km/h) above which no forgiveness is applied on dirt." min="100" max="500" drag="true"]
float forgivenessMaxSpeed_Dirt = 300.0f;

[Setting hidden name="Dirt Forgiveness Min Speed" description="Speed (km/h) at which maximum forgiveness is applied on dirt." min="50" max="300" drag="true"]
float forgivenessMinSpeed_Dirt = 150.0f;

[Setting hidden name="Dirt Forgiveness Factor" description="Multiplier at minimum speed on dirt. Lower = more forgiving." min="0.60" max="1.00" drag="true"]
float forgivenessFactor_Dirt = 0.80f;

[Setting hidden name="Grass Forgiveness Max Speed" description="Speed (km/h) above which no forgiveness is applied on grass." min="100" max="500" drag="true"]
float forgivenessMaxSpeed_Grass = 300.0f;

[Setting hidden name="Grass Forgiveness Min Speed" description="Speed (km/h) at which maximum forgiveness is applied on grass." min="50" max="300" drag="true"]
float forgivenessMinSpeed_Grass = 150.0f;

[Setting hidden name="Grass Forgiveness Factor" description="Multiplier at minimum speed on grass. Lower = more forgiving." min="0.60" max="1.00" drag="true"]
float forgivenessFactor_Grass = 0.80f;

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

array<string> skidTexturesAsphalt;
array<string> skidTexturesDirt;
array<string> skidTexturesGrass;

bool stagedFilesReady = false;
string bundledSkidsRoot;

// Snapshot of settings values - used to detect changes in OnSettingsChanged.
bool _prev_pluginEnabled = true;
bool _prev_useSlopeAdjustedAcc = true;
uint64 _prev_swapDebounceMs = 250;
float _prev_greenSkidThreshold = 0.94f;
float _prev_yellowSkidThreshold = 0.75f;
float _prev_redSkidThreshold = 0.20f;
float _prev_skidHysteresisUp = 0.02f;
float _prev_skidHysteresisDown = 0.01f;
bool _prev_lowSpeedForgivenessEnabled = true;
float _prev_forgivenessMaxSpeed_Asphalt = 700.0f;
float _prev_forgivenessMinSpeed_Asphalt = 400.0f;
float _prev_forgivenessFactor_Asphalt = 0.80f;
float _prev_forgivenessMaxSpeed_Dirt = 300.0f;
float _prev_forgivenessMinSpeed_Dirt = 150.0f;
float _prev_forgivenessFactor_Dirt = 0.80f;
float _prev_forgivenessMaxSpeed_Grass = 300.0f;
float _prev_forgivenessMinSpeed_Grass = 150.0f;
float _prev_forgivenessFactor_Grass = 0.80f;

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

[SettingsTab name="Runtime" icon="Sliders"]
void R_S_RuntimeSettingsTab() {
    UI::Separator();

    UI::Text("Tier thresholds (driftQualityRatio)");
    UI::TextWrapped("Reference: 1.00 is a perfect SD.");
    UI::SliderFloat("Green Skid Threshold", greenSkidThreshold, 0.50f, 1.00f);
    UI::SliderFloat("Yellow Skid Threshold", yellowSkidThreshold, 0.30f, 0.99f);
    UI::SliderFloat("Red Skid Threshold", redSkidThreshold, 0.00f, 0.70f);

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
    UI::SliderFloat("Upgrade Hysteresis", skidHysteresisUp, 0.00f, 0.15f);
    UI::SliderFloat("Downgrade Hysteresis", skidHysteresisDown, 0.00f, 0.15f);

    UI::Separator();
    lowSpeedForgivenessEnabled = UI::Checkbox("Low Speed Forgiveness", lowSpeedForgivenessEnabled);
    UI::Text("Low-speed forgiveness");
    UI::TextWrapped("Interpolation applies from Min Speed up to Max Speed for each surface.");

    UI::Text("Asphalt");
    UI::SliderFloat("Asphalt Forgiveness Min Speed", forgivenessMinSpeed_Asphalt, 400.0f, 600.0f);
    UI::SliderFloat("Asphalt Forgiveness Max Speed", forgivenessMaxSpeed_Asphalt, 500.0f, 900.0f);
    UI::SliderFloat("Asphalt Forgiveness Factor", forgivenessFactor_Asphalt, 0.60f, 1.00f);

    UI::Text("Dirt");
    UI::SliderFloat("Dirt Forgiveness Min Speed", forgivenessMinSpeed_Dirt, 50.0f, 300.0f);
    UI::SliderFloat("Dirt Forgiveness Max Speed", forgivenessMaxSpeed_Dirt, 100.0f, 500.0f);
    UI::SliderFloat("Dirt Forgiveness Factor", forgivenessFactor_Dirt, 0.60f, 1.00f);

    UI::Text("Grass");
    UI::SliderFloat("Grass Forgiveness Min Speed", forgivenessMinSpeed_Grass, 50.0f, 300.0f);
    UI::SliderFloat("Grass Forgiveness Max Speed", forgivenessMaxSpeed_Grass, 100.0f, 500.0f);
    UI::SliderFloat("Grass Forgiveness Factor", forgivenessFactor_Grass, 0.60f, 1.00f);
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
