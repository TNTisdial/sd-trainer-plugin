// Owns: startup/bootstrap and frame entrypoints.

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
    DriftTier targetTier = DetermineTargetTier(driftQualityRatio, activeSurface, currentSurfaceTier);
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
