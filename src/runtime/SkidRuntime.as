// Owns: shared runtime enums and state.

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

// --- Runtime State ---
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
float currentSlopeEstimateRad = 0.0f;
float frameDtMs = 0;

string MODWORK_FOLDER;
string MODWORK_CARFX_FOLDER;
string SKIDS_SOURCE_DIR_ASPHALT;
string SKIDS_SOURCE_DIR_DIRT;
string SKIDS_SOURCE_DIR_GRASS;

array<DriftTier> currentTierBySurface = {DriftTier::Default, DriftTier::Default, DriftTier::Default};
array<uint64> lastSkidSwapTimeBySurface = {0, 0, 0};
array<DriftTier> pendingTierBySurface = {DriftTier::Default, DriftTier::Default, DriftTier::Default};
array<int> pendingTierFramesBySurface = {0, 0, 0};

SkidSurface rawSurfaceKind = SkidSurface::Asphalt;
SkidSurface stableSurfaceKind = SkidSurface::Asphalt;
int rawSurfaceFrames = 0;
uint64 lastSurfaceTransitionTimeMs = 0;
bool wasGroundedLastFrame = false;
uint64 landingLockoutUntilMs = 0;
uint64 lastLandingTimeMs = 0;
float postLandingAccelDelta = 0.0f;
bool wasBoostedLastFrame = false;
uint64 lastBoostEndTimeMs = 0;
float boostBaselineAccel = 0.0f;
bool boostBaselineReady = false;

array<string> skidTexturesAsphalt;
array<string> skidTexturesDirt;
array<string> skidTexturesGrass;
array<string> liveTextureBySurface = {"Default.dds", "Default.dds", "Default.dds"};

bool stagedFilesReady = false;
string bundledSkidsRoot;
