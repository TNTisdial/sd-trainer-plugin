// Owns: runtime helper functions and surface-tier state accessors.

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
