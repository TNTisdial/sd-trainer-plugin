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

DriftTier CurrentTierForSurface(SkidSurface surfaceKind) {
    int index = SurfaceIndex(surfaceKind);
    if (index < 0 || index >= int(currentTierBySurface.Length)) {
        return DriftTier::Default;
    }
    return currentTierBySurface[index];
}

void SetCurrentTierForSurface(SkidSurface surfaceKind, DriftTier tier) {
    int index = SurfaceIndex(surfaceKind);
    if (index < 0 || index >= int(currentTierBySurface.Length)) {
        return;
    }
    currentTierBySurface[index] = tier;
}

uint64 LastSwapTimeForSurface(SkidSurface surfaceKind) {
    int index = SurfaceIndex(surfaceKind);
    if (index < 0 || index >= int(lastSkidSwapTimeBySurface.Length)) {
        return 0;
    }
    return lastSkidSwapTimeBySurface[index];
}

void SetLastSwapTimeForSurface(SkidSurface surfaceKind, uint64 swapTimeMs) {
    int index = SurfaceIndex(surfaceKind);
    if (index < 0 || index >= int(lastSkidSwapTimeBySurface.Length)) {
        return;
    }
    lastSkidSwapTimeBySurface[index] = swapTimeMs;
}

DriftTier PendingTierForSurface(SkidSurface surfaceKind) {
    int index = SurfaceIndex(surfaceKind);
    if (index < 0 || index >= int(pendingTierBySurface.Length)) {
        return DriftTier::Default;
    }
    return pendingTierBySurface[index];
}

void SetPendingTierForSurface(SkidSurface surfaceKind, DriftTier tier) {
    int index = SurfaceIndex(surfaceKind);
    if (index < 0 || index >= int(pendingTierBySurface.Length)) {
        return;
    }
    pendingTierBySurface[index] = tier;
}

int PendingTierFramesForSurface(SkidSurface surfaceKind) {
    int index = SurfaceIndex(surfaceKind);
    if (index < 0 || index >= int(pendingTierFramesBySurface.Length)) {
        return 0;
    }
    return pendingTierFramesBySurface[index];
}

void SetPendingTierFramesForSurface(SkidSurface surfaceKind, int frames) {
    int index = SurfaceIndex(surfaceKind);
    if (index < 0 || index >= int(pendingTierFramesBySurface.Length)) {
        return;
    }
    pendingTierFramesBySurface[index] = frames;
}

void ResetPendingGateForSurface(SkidSurface surfaceKind) {
    SetPendingTierForSurface(surfaceKind, CurrentTierForSurface(surfaceKind));
    SetPendingTierFramesForSurface(surfaceKind, 0);
}

void UpdateStableSurface(SkidSurface detectedSurface) {
    if (detectedSurface == rawSurfaceKind) {
        rawSurfaceFrames += 1;
    } else {
        dbg("[Surface] Raw candidate changed: " + SurfaceId(rawSurfaceKind) + " -> " + SurfaceId(detectedSurface));
        rawSurfaceKind = detectedSurface;
        rawSurfaceFrames = 1;
    }

    int requiredFrames = Math::Max(1, surfaceStabilityFrames);
    if (detectedSurface == stableSurfaceKind || rawSurfaceFrames < requiredFrames) {
        return;
    }

    SkidSurface previousSurface = stableSurfaceKind;
    stableSurfaceKind = detectedSurface;
    lastSurfaceTransitionTimeMs = Time::Now;
    ResetPendingGateForSurface(stableSurfaceKind);
    dbg("[Surface] Stable transition: " + SurfaceId(previousSurface) + " -> " + SurfaceId(stableSurfaceKind)
        + " (frames=" + rawSurfaceFrames + ", required=" + requiredFrames + ")");
}

void ResetRuntimeSwapState() {
    rawSurfaceKind = SkidSurface::Asphalt;
    stableSurfaceKind = SkidSurface::Asphalt;
    rawSurfaceFrames = 0;
    lastSurfaceTransitionTimeMs = 0;

    for (uint i = 0; i < kSurfaces.Length; i++) {
        SetCurrentTierForSurface(kSurfaces[i], DriftTier::Default);
        SetPendingTierForSurface(kSurfaces[i], DriftTier::Default);
        SetPendingTierFramesForSurface(kSurfaces[i], 0);
        SetLastSwapTimeForSurface(kSurfaces[i], 0);
        SetTrackedLiveFilename(kSurfaces[i], "Default.dds");
    }
}

bool BootstrapSkidRuntimeAssets() {
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

    ResetRuntimeSwapState();

    int totalTextures = TotalLoadedSkidTextures();
    if (totalTextures == 0) {
        warn("[Init] No .dds textures found in any surface folder. Colored skids disabled.");
        stagedFilesReady = false;
        return false;
    }

    dbg("[Init] Textures loaded - Asphalt: " + skidTexturesAsphalt.Length
        + ", Dirt: " + skidTexturesDirt.Length
        + ", Grass: " + skidTexturesGrass.Length);

    bool allStaged = StageRequiredTexturesForAllSurfaces();
    if (allStaged) {
        allStaged = PrimeLiveDefaultsForAllSurfaces();
    }

    stagedFilesReady = allStaged;
    if (stagedFilesReady) {
        RefreshGameTextures();
        dbg("[Init] Startup staging and priming completed.");
    } else {
        warn("[Init] One or more textures failed to stage/prime; colored skids disabled.");
    }

    return stagedFilesReady;
}

// --- Entrypoints ---
void Main() {
    BootstrapSkidRuntimeAssets();

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
    SkidSurface activeSurface = stableSurfaceKind;
    float adjustedMaxAccelSpeedSlide = ComputeAdjustedMaxAccelSpeedSlide(speedKmh, activeSurface);

    if (lowSpeedForgivenessEnabled) {
        adjustedMaxAccelSpeedSlide = ApplyLowSpeedForgiveness(adjustedMaxAccelSpeedSlide, speedKmh, activeSurface);
    }

    float driftQualityRatio = ComputeDriftQualityRatio(adjustedMaxAccelSpeedSlide);

    DriftTier currentSurfaceTier = CurrentTierForSurface(activeSurface);
    DriftTier targetTier = DetermineTargetTier(driftQualityRatio, currentSurfaceTier);
    targetTier = ApplyLandingLockoutGate(targetTier, activeSurface, currentSurfaceTier);
    targetTier = ApplyTierPersistenceGate(targetTier, activeSurface, currentSurfaceTier);

    bool tierChanged = targetTier != currentSurfaceTier;
    bool inSurfaceTransitionGrace = surfaceTransitionGraceMs > 0
        && Time::Now >= lastSurfaceTransitionTimeMs
        && Time::Now - lastSurfaceTransitionTimeMs <= uint64(surfaceTransitionGraceMs);
    if (!tierChanged || (!inSurfaceTransitionGrace && Time::Now - LastSwapTimeForSurface(activeSurface) <= swapDebounceMs)) {
        return;
    }

    if (!stagedFilesReady) {
        dbg("[Render] Skipping swap: staged files not ready.");
        return;
    }

    dbg("[Render] Surface=" + SurfaceId(activeSurface)
        + " tier changed: " + TierName(currentSurfaceTier) + " -> " + TierName(targetTier)
        + ", ratio=" + driftQualityRatio + ", grace=" + inSurfaceTransitionGrace);

    bool anyChanged = TierToFilenameForSurface(currentSurfaceTier, activeSurface) != TierToFilenameForSurface(targetTier, activeSurface);
    bool allOk = anyChanged ? SwapSkidTextureForSurface(targetTier, activeSurface) : true;
    if (anyChanged && allOk) {
        RefreshGameTextures();
    }

    if (allOk) {
        SetCurrentTierForSurface(activeSurface, targetTier);
        SetLastSwapTimeForSurface(activeSurface, Time::Now);
        dbg("[Render] Swap complete: surface=" + SurfaceId(activeSurface) + ", tier=" + TierName(targetTier));
    } else {
        warn("[Render] Surface swap failure: surface=" + SurfaceId(activeSurface) + ". Keeping previous tier state for retry.");
    }
}
