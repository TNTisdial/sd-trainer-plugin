// Owns: per-frame simulation and acceleration state updates.

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
