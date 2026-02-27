// Owns: persisted settings declarations and shared settings UI/profile state.

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

// --- Runtime Settings UI Shared State ---
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
bool settingsProfileLoadInProgress = false;
bool generalRebuildInProgress = false;
string pendingSettingsProfileName = "";
string pendingSettingsProfilePayload = "";

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
