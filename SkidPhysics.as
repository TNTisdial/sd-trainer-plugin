// acceleration/drift math, gates, and tier decisions.
// Credit to MagpieAI, this project would not exist without your work. 

// --- Model Constants ---
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

// --- Vector Helpers ---
float CalculateVectorMagnitude(vec3 vector1) {
    return Math::Sqrt(vector1.x * vector1.x + vector1.y * vector1.y + vector1.z * vector1.z);
}

float CalculateVectorDotProduct(vec3 vector1, vec3 vector2) {
    return (vector1.x * vector2.x + vector1.y * vector2.y + vector1.z * vector2.z);
}

vec3 CalculateCrossProduct(vec3 vector1, vec3 vector2) {
    float vecX = vector1.y * vector2.z - vector1.z * vector2.y;
    float vecY = vector1.z * vector2.x - vector1.x * vector2.z;
    float vecZ = vector1.x * vector2.y - vector1.y * vector2.x;
    return vec3(vecX, vecY, vecZ);
}

float CalculateAngle(vec3 vector1, vec3 vector2) {
    float adjacent = CalculateVectorDotProduct(vector1, vector2);
    float magVector1 = CalculateVectorMagnitude(vector1);
    float magVector2 = CalculateVectorMagnitude(vector2);
    float hypot = magVector1 * magVector2;

    if (hypot < 0.000001f) {
        return 0;
    }

    float ratio = adjacent / hypot;
    ratio = Math::Clamp(ratio, -1.0f, 1.0f);

    return Math::Acos(ratio) * 1000;
}

void CalculateVelocityAngleDelta() {
    prevDriftDirVec = driftDirVec;
    driftDirVec = CalculateCrossProduct(worldNormalVec, normalisedCurrentVelocity);
    driftAngleDeltaArray[accelArrayIndex] = CalculateAngle(prevDriftDirVec, driftDirVec);

    float sum = 0;
    for (int n = 0; n < ACCEL_ARRAY_SIZE; n++) {
        sum += driftAngleDeltaArray[n];
    }
    averageAngleDifference = (sum / ACCEL_ARRAY_SIZE) / 1000;
}

// --- Surface and Forgiveness Helpers ---
SkidSurface SurfaceFromMaterial(CSceneVehicleVisState::EPlugSurfaceMaterialId mat) {
    if (mat == CSceneVehicleVisState::EPlugSurfaceMaterialId::Dirt) return SkidSurface::Dirt;
    if (mat == CSceneVehicleVisState::EPlugSurfaceMaterialId::Green) return SkidSurface::Grass;
    return SkidSurface::Asphalt;
}

float ComputeAdjustedMaxAccelSpeedSlide(float speedKmh, SkidSurface surfaceKind) {
    float adjustedMax = ASPHALT_BASE_MAX_ACCEL;
    if (speedKmh > ASPHALT_HIGH_SPEED_THRESHOLD_KMH) {
        adjustedMax = ASPHALT_HIGH_SPEED_BASE + speedKmh * ASPHALT_HIGH_SPEED_SLOPE + PERFECT_BUFFER;
    }

    if (surfaceKind == SkidSurface::Dirt) {
        adjustedMax = DIRT_MAX_ACCEL + PERFECT_BUFFER;
    } else if (surfaceKind == SkidSurface::Grass) {
        adjustedMax = GRASS_MAX_ACCEL + PERFECT_BUFFER;
    }

    return adjustedMax;
}
// At lower speeds, getting a perfect slide is harder, so to prevent flickering, we give the player a buffer.
void GetForgivenessParams(SkidSurface surfaceKind, float &out maxSpeed, float &out minSpeed, float &out factor) {
    if (surfaceKind == SkidSurface::Dirt) {
        maxSpeed = forgivenessMaxSpeed_Dirt;
        minSpeed = forgivenessMinSpeed_Dirt;
        factor = forgivenessFactor_Dirt;
        return;
    }

    if (surfaceKind == SkidSurface::Grass) {
        maxSpeed = forgivenessMaxSpeed_Grass;
        minSpeed = forgivenessMinSpeed_Grass;
        factor = forgivenessFactor_Grass;
        return;
    }

    maxSpeed = forgivenessMaxSpeed_Asphalt;
    minSpeed = forgivenessMinSpeed_Asphalt;
    factor = forgivenessFactor_Asphalt;
}

float ApplyLowSpeedForgiveness(float accelMax, float speedKmh, SkidSurface surfaceKind) {
    float maxSpeed, minSpeed, factor;
    GetForgivenessParams(surfaceKind, maxSpeed, minSpeed, factor);

    if (maxSpeed <= minSpeed) {
        return accelMax;
    }

    if (speedKmh < maxSpeed && speedKmh >= minSpeed) {
        float t = (speedKmh - minSpeed) / (maxSpeed - minSpeed);
        float forgiveness = Math::Lerp(factor, 1.0f, t);
        return accelMax * forgiveness;
    }

    return accelMax;
}
// This is the core of the drift quality calculation.
float ComputeDriftQualityRatio(float adjustedMaxAccelSpeedSlide) {
    float denom = Math::Max(MIN_ACCEL_DENOM, adjustedMaxAccelSpeedSlide);
    float numerator = slopeAdjustedAcceleration;

    if (isBoosted && allowLiveBoostGrading) {
        if (!boostBaselineReady) {
            boostBaselineAccel = slopeAdjustedAcceleration;
            boostBaselineReady = true;
            dbg("[Boost] Initialized baseline accel=" + boostBaselineAccel);
        }

        numerator = slopeAdjustedAcceleration - boostBaselineAccel;
        float headroomScale = Math::Max(0.05f, boostHeadroomScale);
        denom = Math::Max(MIN_ACCEL_DENOM, denom * headroomScale);
    }

    float ratio = numerator / denom;

    float slopeDeg = currentSlopeEstimateRad * 57.29578f;
    float slopeNorm = Math::Clamp(slopeDeg / 10.0f, -1.0f, 1.0f);
    if (slopeNorm > 0.0f && uphillSlopeLeniency > 0.0f) {
        ratio += uphillSlopeLeniency * slopeNorm;
    } else if (slopeNorm < 0.0f && downhillSlopeStrictness > 0.0f) {
        ratio -= downhillSlopeStrictness * -slopeNorm;
    }

    if (ratio > 1.0f) {
        return 1.0f;
    }
    if (ratio < -1.0f) {
        return -1.0f;
    }
    return ratio;
}

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
    // Smoothing guard to reduce noisy visual upgrades right after landing.
    if (TierRank(candidateTier) > TierRank(currentTierForSurface)) {
        dbg("[Gate] Landing lockout blocked upgrade: surface=" + SurfaceId(surfaceKind)
            + " " + TierName(currentTierForSurface) + " -> " + TierName(candidateTier)
            + " (remaining=" + int(landingLockoutUntilMs - Time::Now) + "ms)");
        return currentTierForSurface;
    }

    return candidateTier;
}
// Prevent rapid tier oscillation when short-lived spikes occur.
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

// --- Tier Selection ---
// Hysteresis is used to prevent the tier from changing too rapidly
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

// --- Main Simulation Entrypoints ---
void Update(float dt) {
    frameDtMs = dt;
}

void SimulationStep() {
    auto vis = VehicleState::ViewingPlayerState();
    if (vis is null) return;

    float previousSlopeAdjustedAcceleration = slopeAdjustedAcceleration;
    bool isBoostedNow = vis.IsTurbo;
    if (!wasBoostedLastFrame && isBoostedNow) {
        boostBaselineReady = false;
        boostBaselineAccel = 0.0f;
    }
    if (wasBoostedLastFrame && !isBoostedNow) {
        lastBoostEndTimeMs = Time::Now;
    }
    wasBoostedLastFrame = isBoostedNow;

    currentSurfaceMaterial = CSceneVehicleVisState::EPlugSurfaceMaterialId(vis.FLGroundContactMaterial);
    bool isGrounded = currentSurfaceMaterial != CSceneVehicleVisState::EPlugSurfaceMaterialId::XXX_Null;
    if (isGrounded) {
        UpdateStableSurface(SurfaceFromMaterial(currentSurfaceMaterial));
    }
    if (!wasGroundedLastFrame && isGrounded && landingLockoutMs > 0) {
        landingLockoutUntilMs = Time::Now + uint64(landingLockoutMs);
    }
    if (!wasGroundedLastFrame && isGrounded) {
        lastLandingTimeMs = Time::Now;
    }
    wasGroundedLastFrame = isGrounded;

    float slipCoef = vis.FLSlipCoef;
    if (!isGrounded) {
        isDrifting = false;
    } else {
        float driftEnterSlipCoef = minSlipCoefToDrift;
        float driftExitSlipCoef = Math::Max(0.0f, minSlipCoefToDrift - slipHysteresis);

        bool wasDrifting = isDrifting;
        if (isDrifting) {
            isDrifting = slipCoef > driftExitSlipCoef;
        } else {
            isDrifting = slipCoef > driftEnterSlipCoef;
        }

        if (wasDrifting != isDrifting) {
            dbg("[Drift] " + (isDrifting ? "Enter" : "Exit") + " slip hysteresis: slip=" + slipCoef
                + ", enter=" + driftEnterSlipCoef + ", exit=" + driftExitSlipCoef);
        }
    }

    isBoosted = isBoostedNow;

    worldNormalVec = vis.WorldCarUp;
    currentVelocity = vis.WorldVel;
    normalisedCurrentVelocity = vis.Dir;

    float xzChangeEstimate = Math::Sqrt(currentVelocity.x * currentVelocity.x + currentVelocity.z * currentVelocity.z);
    if (xzChangeEstimate < MIN_XZ_CHANGE_ESTIMATE) {
        xzChangeEstimate = MIN_XZ_CHANGE_ESTIMATE;
    }

    float slopeEstimate = Math::Atan(currentVelocity.y / xzChangeEstimate);
    currentSlopeEstimateRad = slopeEstimate;
    CalculateVelocityAngleDelta();

    float frontSpeed = vis.FrontSpeed;
    float sideSpeed = VehicleState::GetSideSpeed(vis);
    float scalarSpeed = Math::Sqrt(frontSpeed * frontSpeed + sideSpeed * sideSpeed);

    float dtMs = Math::Max(frameDtMs, MIN_EFFECTIVE_DT_MS);
    float rawAcc = (scalarSpeed - prevSpeed) / (dtMs / 1000.0f);
    float trueAcc = rawAcc + GRAVITY_COMPENSATION * Math::Sin(slopeEstimate);

    accelArrayNoAdjust[accelArrayIndex] = useSlopeAdjustedAcc ? trueAcc : rawAcc;

    float noAdjustSum = 0;
    for (int n = 0; n < ACCEL_ARRAY_SIZE; n++) {
        noAdjustSum += accelArrayNoAdjust[n];
    }
    averageAcceleration = noAdjustSum / ACCEL_ARRAY_SIZE;
    if (Math::Abs(averageAcceleration) < ACCEL_NOISE_FLOOR) {
        averageAcceleration = 0;
    }

    accelArray[accelArrayIndex] = trueAcc;
    accelArrayIndex = (accelArrayIndex + 1) % ACCEL_ARRAY_SIZE;

    float sum = 0;
    for (int n = 0; n < ACCEL_ARRAY_SIZE; n++) {
        sum += accelArray[n];
    }
    slopeAdjustedAcceleration = sum / ACCEL_ARRAY_SIZE;
    if (Math::Abs(slopeAdjustedAcceleration) < ACCEL_NOISE_FLOOR) {
        slopeAdjustedAcceleration = 0;
    }

    if (isBoostedNow && !isDrifting) {
        if (!boostBaselineReady) {
            boostBaselineAccel = slopeAdjustedAcceleration;
            boostBaselineReady = true;
            dbg("[Boost] Baseline primed while not drifting: " + boostBaselineAccel);
        } else {
            float followRate = Math::Clamp(boostBaselineFollowRate, 0.01f, 0.40f);
            boostBaselineAccel = Math::Lerp(boostBaselineAccel, slopeAdjustedAcceleration, followRate);
        }
    }

    postLandingAccelDelta = Math::Abs(slopeAdjustedAcceleration - previousSlopeAdjustedAcceleration);

    prevSpeed = scalarSpeed;
}
