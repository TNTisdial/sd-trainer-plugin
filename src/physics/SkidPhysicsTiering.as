// Owns: tier ranking, gates, thresholds, and target-tier selection.

int TierRank(DriftTier tier) {
    if (tier == DriftTier::Poor) return 1;
    if (tier == DriftTier::Mid) return 2;
    if (tier == DriftTier::High) return 3;
    return 0;
}

DriftTier ApplyLandingLockoutGate(DriftTier candidateTier, SkidSurface surfaceKind, DriftTier currentTierForSurface) {
    if (landingLockoutMs <= 0) {
        return candidateTier;
    }

    if (Time::Now >= landingLockoutUntilMs) {
        return candidateTier;
    }
    if (TierRank(candidateTier) > TierRank(currentTierForSurface)) {
        dbg("[Gate] Landing lockout blocked upgrade: surface=" + SurfaceId(surfaceKind)
            + " " + TierName(currentTierForSurface) + " -> " + TierName(candidateTier)
            + " (remaining=" + int(landingLockoutUntilMs - Time::Now) + "ms)");
        return currentTierForSurface;
    }

    return candidateTier;
}

DriftTier ApplyTierPersistenceGate(DriftTier candidateTier, SkidSurface surfaceKind, DriftTier currentTierForSurface) {
    DriftTier pendingTier = PendingTierForSurface(surfaceKind);
    int pendingTierFrames = PendingTierFramesForSurface(surfaceKind);

    if (candidateTier == currentTierForSurface) {
        SetPendingTierForSurface(surfaceKind, currentTierForSurface);
        SetPendingTierFramesForSurface(surfaceKind, 0);
        return currentTierForSurface;
    }

    int currentRank = TierRank(currentTierForSurface);
    int candidateRank = TierRank(candidateTier);
    bool isUpgrade = candidateRank > currentRank;

    int requiredFrames = isUpgrade ? promotionPersistenceFrames : downgradePersistenceFrames;
    if (isUpgrade
        && postLandingImpactGuardMs > 0 && impactExtraPromotionFrames > 0 && impactSpikeThreshold > 0.0f
        && Time::Now >= lastLandingTimeMs && Time::Now - lastLandingTimeMs <= uint64(postLandingImpactGuardMs)
        && postLandingAccelDelta >= impactSpikeThreshold) {
        requiredFrames += impactExtraPromotionFrames;
        dbg("[Gate] Impact guard added frames: +" + impactExtraPromotionFrames
            + " (delta=" + postLandingAccelDelta + ", required=" + requiredFrames + ")");
    }

    if (isUpgrade
        && postBoostImpactGuardMs > 0 && boostExtraPromotionFrames > 0 && boostSpikeThreshold > 0.0f
        && Time::Now >= lastBoostEndTimeMs && Time::Now - lastBoostEndTimeMs <= uint64(postBoostImpactGuardMs)
        && postLandingAccelDelta >= boostSpikeThreshold) {
        requiredFrames += boostExtraPromotionFrames;
        dbg("[Gate] Boost guard added frames: +" + boostExtraPromotionFrames
            + " (delta=" + postLandingAccelDelta + ", required=" + requiredFrames + ")");
    }

    if (requiredFrames <= 0) {
        SetPendingTierForSurface(surfaceKind, candidateTier);
        SetPendingTierFramesForSurface(surfaceKind, 0);
        return candidateTier;
    }

    if (pendingTier != candidateTier) {
        SetPendingTierForSurface(surfaceKind, candidateTier);
        SetPendingTierFramesForSurface(surfaceKind, 1);
        dbg("[Gate] Persistence started: surface=" + SurfaceId(surfaceKind)
            + " " + TierName(currentTierForSurface) + " -> " + TierName(candidateTier)
            + " (1/" + requiredFrames + " frames)");
        return currentTierForSurface;
    }

    if (pendingTierFrames < requiredFrames) {
        pendingTierFrames += 1;
        SetPendingTierFramesForSurface(surfaceKind, pendingTierFrames);
        dbg("[Gate] Persistence holding: surface=" + SurfaceId(surfaceKind)
            + " " + TierName(currentTierForSurface) + " -> " + TierName(candidateTier)
            + " (" + pendingTierFrames + "/" + requiredFrames + " frames)");
    }

    if (pendingTierFrames >= requiredFrames) {
        return candidateTier;
    }

    return currentTierForSurface;
}

void GetTierThresholdsForSurface(SkidSurface surfaceKind, float &out greenThreshold, float &out yellowThreshold, float &out redThreshold) {
    if (surfaceKind == SkidSurface::Dirt) {
        greenThreshold = greenSkidThreshold_Dirt;
        yellowThreshold = yellowSkidThreshold_Dirt;
        redThreshold = redSkidThreshold_Dirt;
        return;
    }

    if (surfaceKind == SkidSurface::Grass) {
        greenThreshold = greenSkidThreshold_Grass;
        yellowThreshold = yellowSkidThreshold_Grass;
        redThreshold = redSkidThreshold_Grass;
        return;
    }

    greenThreshold = greenSkidThreshold_Asphalt;
    yellowThreshold = yellowSkidThreshold_Asphalt;
    redThreshold = redSkidThreshold_Asphalt;
}

DriftTier DetermineTargetTier(float driftQualityRatio, SkidSurface surfaceKind, DriftTier currentTierForSurface) {
    if (isBoosted && !allowLiveBoostGrading) {
        return currentTierForSurface;
    }

    if (!isDrifting) {
        return DriftTier::Default;
    }

    float greenThreshold, yellowThreshold, redThreshold;
    GetTierThresholdsForSurface(surfaceKind, greenThreshold, yellowThreshold, redThreshold);

    if (currentTierForSurface == DriftTier::High) {
        if (driftQualityRatio < greenThreshold - skidHysteresisDown) {
            if (driftQualityRatio >= yellowThreshold - skidHysteresisDown) return DriftTier::Mid;
            if (driftQualityRatio >= redThreshold) return DriftTier::Poor;
            return DriftTier::Default;
        }
        return DriftTier::High;
    }

    if (currentTierForSurface == DriftTier::Mid) {
        if (driftQualityRatio >= greenThreshold + skidHysteresisUp) return DriftTier::High;
        if (driftQualityRatio < yellowThreshold - skidHysteresisDown) {
            if (driftQualityRatio >= redThreshold) return DriftTier::Poor;
            return DriftTier::Default;
        }
        return DriftTier::Mid;
    }

    if (currentTierForSurface == DriftTier::Poor) {
        if (driftQualityRatio >= greenThreshold + skidHysteresisUp) return DriftTier::High;
        if (driftQualityRatio >= yellowThreshold + skidHysteresisUp) return DriftTier::Mid;
        if (driftQualityRatio < redThreshold - skidHysteresisDown) return DriftTier::Default;
        return DriftTier::Poor;
    }

    if (driftQualityRatio >= greenThreshold) return DriftTier::High;
    if (driftQualityRatio >= yellowThreshold) return DriftTier::Mid;
    if (driftQualityRatio >= redThreshold) return DriftTier::Poor;
    return DriftTier::Default;
}
