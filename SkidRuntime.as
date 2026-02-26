// Owns: plugin lifecycle and per-frame orchestration.

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
float boostBaselineAccel = 0.0f;
bool boostBaselineReady = false;

array<string> skidTexturesAsphalt;
array<string> skidTexturesDirt;
array<string> skidTexturesGrass;
array<string> liveTextureBySurface = {"Default.dds", "Default.dds", "Default.dds"};

bool stagedFilesReady = false;
string bundledSkidsRoot;

// --- Shared Helpers ---
void dbg(const string &in msg) {
    if (debugLogging) trace(msg);
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

// --- Entrypoints ---
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

    float driftQualityRatio = ComputeDriftQualityRatio(adjustedMaxAccelSpeedSlide);

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
