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

    if (adjacent < 0.000001f || adjacent > hypot) {
        return 0;
    }

    if (hypot < 0.000001f) {
        hypot = 0.000001f;
    }

    return Math::Acos(Math::Abs(adjacent / hypot)) * 1000;
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

float ComputeAdjustedMaxAccelSpeedSlide(float speedKmh) {
    float adjustedMax = ASPHALT_BASE_MAX_ACCEL;
    if (speedKmh > ASPHALT_HIGH_SPEED_THRESHOLD_KMH) {
        adjustedMax = ASPHALT_HIGH_SPEED_BASE + speedKmh * ASPHALT_HIGH_SPEED_SLOPE + PERFECT_BUFFER;
    }

    if (currentSurfaceMaterial == CSceneVehicleVisState::EPlugSurfaceMaterialId::Dirt) {
        adjustedMax = DIRT_MAX_ACCEL + PERFECT_BUFFER;
    } else if (currentSurfaceMaterial == CSceneVehicleVisState::EPlugSurfaceMaterialId::Green) {
        adjustedMax = GRASS_MAX_ACCEL + PERFECT_BUFFER;
    }

    return adjustedMax;
}

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

int TierRank(DriftTier tier) {
    if (tier == DriftTier::Poor) return 1;
    if (tier == DriftTier::Mid) return 2;
    if (tier == DriftTier::High) return 3;
    return 0;
}

DriftTier ApplyLandingLockoutGate(DriftTier candidateTier) {
    if (landingLockoutMs <= 0) {
        return candidateTier;
    }

    if (Time::Now >= landingLockoutUntilMs) {
        return candidateTier;
    }

    if (TierRank(candidateTier) > TierRank(currentTier)) {
        dbg("[Gate] Landing lockout blocked upgrade: " + TierName(currentTier) + " -> " + TierName(candidateTier)
            + " (remaining=" + int(landingLockoutUntilMs - Time::Now) + "ms)");
        return currentTier;
    }

    return candidateTier;
}

DriftTier ApplyTierPersistenceGate(DriftTier candidateTier) {
    if (candidateTier == currentTier) {
        pendingTier = currentTier;
        pendingTierFrames = 0;
        return currentTier;
    }

    int currentRank = TierRank(currentTier);
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
        pendingTier = candidateTier;
        pendingTierFrames = 0;
        return candidateTier;
    }

    if (pendingTier != candidateTier) {
        pendingTier = candidateTier;
        pendingTierFrames = 1;
        dbg("[Gate] Persistence started: " + TierName(currentTier) + " -> " + TierName(candidateTier)
            + " (1/" + requiredFrames + " frames)");
        return currentTier;
    }

    if (pendingTierFrames < requiredFrames) {
        pendingTierFrames += 1;
        dbg("[Gate] Persistence holding: " + TierName(currentTier) + " -> " + TierName(candidateTier)
            + " (" + pendingTierFrames + "/" + requiredFrames + " frames)");
    }

    if (pendingTierFrames >= requiredFrames) {
        return candidateTier;
    }

    return currentTier;
}

// --- Tier Selection ---
DriftTier DetermineTargetTier(float driftQualityRatio) {
    if (isBoosted) {
        return currentTier;
    }

    if (!isDrifting) {
        return DriftTier::Default;
    }

    if (currentTier == DriftTier::High) {
        if (driftQualityRatio < greenSkidThreshold - skidHysteresisDown) {
            if (driftQualityRatio >= yellowSkidThreshold - skidHysteresisDown) return DriftTier::Mid;
            if (driftQualityRatio >= redSkidThreshold) return DriftTier::Poor;
            return DriftTier::Default;
        }
        return DriftTier::High;
    }

    if (currentTier == DriftTier::Mid) {
        if (driftQualityRatio >= greenSkidThreshold + skidHysteresisUp) return DriftTier::High;
        if (driftQualityRatio < yellowSkidThreshold - skidHysteresisDown) {
            if (driftQualityRatio >= redSkidThreshold) return DriftTier::Poor;
            return DriftTier::Default;
        }
        return DriftTier::Mid;
    }

    if (currentTier == DriftTier::Poor) {
        if (driftQualityRatio >= greenSkidThreshold + skidHysteresisUp) return DriftTier::High;
        if (driftQualityRatio >= yellowSkidThreshold + skidHysteresisUp) return DriftTier::Mid;
        if (driftQualityRatio < redSkidThreshold - skidHysteresisDown) return DriftTier::Default;
        return DriftTier::Poor;
    }

    if (driftQualityRatio >= greenSkidThreshold) return DriftTier::High;
    if (driftQualityRatio >= yellowSkidThreshold) return DriftTier::Mid;
    if (driftQualityRatio >= redSkidThreshold) return DriftTier::Poor;
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
    if (wasBoostedLastFrame && !isBoostedNow) {
        lastBoostEndTimeMs = Time::Now;
    }
    wasBoostedLastFrame = isBoostedNow;

    currentSurfaceMaterial = CSceneVehicleVisState::EPlugSurfaceMaterialId(vis.FLGroundContactMaterial);
    bool isGrounded = currentSurfaceMaterial != CSceneVehicleVisState::EPlugSurfaceMaterialId::XXX_Null;
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

    postLandingAccelDelta = Math::Abs(slopeAdjustedAcceleration - previousSlopeAdjustedAcceleration);

    prevSpeed = scalarSpeed;
}
