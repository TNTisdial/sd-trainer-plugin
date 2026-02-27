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
