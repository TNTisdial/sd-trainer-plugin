// Owns: debug tracking for runtime setting changes.

bool TrackSettingChangeBool(const string &in label, bool current, bool previous) {
    if (current == previous) return false;
    trace("[Settings] " + label + ": " + previous + " -> " + current);
    return true;
}

bool TrackSettingChangeUint(const string &in label, uint current, uint previous) {
    if (current == previous) return false;
    trace("[Settings] " + label + ": " + previous + " -> " + current);
    return true;
}

bool TrackSettingChangeFloat(const string &in label, float current, float previous) {
    if (current == previous) return false;
    trace("[Settings] " + label + ": " + previous + " -> " + current);
    return true;
}

bool TrackSettingChangeInt(const string &in label, int current, int previous) {
    if (current == previous) return false;
    trace("[Settings] " + label + ": " + previous + " -> " + current);
    return true;
}

void OnSettingsChanged() {
    if (!debugLogging) return;
    if (TrackSettingChangeBool("Enable Plugin", pluginEnabled, _prev_pluginEnabled)) _prev_pluginEnabled = pluginEnabled;
    if (TrackSettingChangeBool("Gravity Adjustment", useSlopeAdjustedAcc, _prev_useSlopeAdjustedAcc)) _prev_useSlopeAdjustedAcc = useSlopeAdjustedAcc;
    if (TrackSettingChangeUint("Swap Debounce (ms)", swapDebounceMs, _prev_swapDebounceMs)) _prev_swapDebounceMs = swapDebounceMs;
    if (TrackSettingChangeFloat("Asphalt Green Threshold", greenSkidThreshold_Asphalt, _prev_greenSkidThreshold_Asphalt)) _prev_greenSkidThreshold_Asphalt = greenSkidThreshold_Asphalt;
    if (TrackSettingChangeFloat("Asphalt Yellow Threshold", yellowSkidThreshold_Asphalt, _prev_yellowSkidThreshold_Asphalt)) _prev_yellowSkidThreshold_Asphalt = yellowSkidThreshold_Asphalt;
    if (TrackSettingChangeFloat("Asphalt Red Threshold", redSkidThreshold_Asphalt, _prev_redSkidThreshold_Asphalt)) _prev_redSkidThreshold_Asphalt = redSkidThreshold_Asphalt;
    if (TrackSettingChangeFloat("Dirt Green Threshold", greenSkidThreshold_Dirt, _prev_greenSkidThreshold_Dirt)) _prev_greenSkidThreshold_Dirt = greenSkidThreshold_Dirt;
    if (TrackSettingChangeFloat("Dirt Yellow Threshold", yellowSkidThreshold_Dirt, _prev_yellowSkidThreshold_Dirt)) _prev_yellowSkidThreshold_Dirt = yellowSkidThreshold_Dirt;
    if (TrackSettingChangeFloat("Dirt Red Threshold", redSkidThreshold_Dirt, _prev_redSkidThreshold_Dirt)) _prev_redSkidThreshold_Dirt = redSkidThreshold_Dirt;
    if (TrackSettingChangeFloat("Grass Green Threshold", greenSkidThreshold_Grass, _prev_greenSkidThreshold_Grass)) _prev_greenSkidThreshold_Grass = greenSkidThreshold_Grass;
    if (TrackSettingChangeFloat("Grass Yellow Threshold", yellowSkidThreshold_Grass, _prev_yellowSkidThreshold_Grass)) _prev_yellowSkidThreshold_Grass = yellowSkidThreshold_Grass;
    if (TrackSettingChangeFloat("Grass Red Threshold", redSkidThreshold_Grass, _prev_redSkidThreshold_Grass)) _prev_redSkidThreshold_Grass = redSkidThreshold_Grass;
    if (TrackSettingChangeFloat("Upgrade Hysteresis", skidHysteresisUp, _prev_skidHysteresisUp)) _prev_skidHysteresisUp = skidHysteresisUp;
    if (TrackSettingChangeFloat("Downgrade Hysteresis", skidHysteresisDown, _prev_skidHysteresisDown)) _prev_skidHysteresisDown = skidHysteresisDown;
    if (TrackSettingChangeInt("Promotion Persistence Frames", promotionPersistenceFrames, _prev_promotionPersistenceFrames)) _prev_promotionPersistenceFrames = promotionPersistenceFrames;
    if (TrackSettingChangeInt("Downgrade Persistence Frames", downgradePersistenceFrames, _prev_downgradePersistenceFrames)) _prev_downgradePersistenceFrames = downgradePersistenceFrames;
    if (TrackSettingChangeInt("Surface Stability Frames", surfaceStabilityFrames, _prev_surfaceStabilityFrames)) _prev_surfaceStabilityFrames = surfaceStabilityFrames;
    if (TrackSettingChangeInt("Surface Transition Grace (ms)", surfaceTransitionGraceMs, _prev_surfaceTransitionGraceMs)) _prev_surfaceTransitionGraceMs = surfaceTransitionGraceMs;
    if (TrackSettingChangeInt("Landing Lockout (ms)", landingLockoutMs, _prev_landingLockoutMs)) _prev_landingLockoutMs = landingLockoutMs;
    if (TrackSettingChangeFloat("Min SlipCoef To Drift", minSlipCoefToDrift, _prev_minSlipCoefToDrift)) _prev_minSlipCoefToDrift = minSlipCoefToDrift;
    if (TrackSettingChangeFloat("Slip Hysteresis", slipHysteresis, _prev_slipHysteresis)) _prev_slipHysteresis = slipHysteresis;
    if (TrackSettingChangeInt("Post-Landing Impact Guard (ms)", postLandingImpactGuardMs, _prev_postLandingImpactGuardMs)) _prev_postLandingImpactGuardMs = postLandingImpactGuardMs;
    if (TrackSettingChangeFloat("Impact Spike Threshold", impactSpikeThreshold, _prev_impactSpikeThreshold)) _prev_impactSpikeThreshold = impactSpikeThreshold;
    if (TrackSettingChangeInt("Impact Extra Promotion Frames", impactExtraPromotionFrames, _prev_impactExtraPromotionFrames)) _prev_impactExtraPromotionFrames = impactExtraPromotionFrames;
    if (TrackSettingChangeInt("Post-Boost Impact Guard (ms)", postBoostImpactGuardMs, _prev_postBoostImpactGuardMs)) _prev_postBoostImpactGuardMs = postBoostImpactGuardMs;
    if (TrackSettingChangeFloat("Boost Spike Threshold", boostSpikeThreshold, _prev_boostSpikeThreshold)) _prev_boostSpikeThreshold = boostSpikeThreshold;
    if (TrackSettingChangeInt("Boost Extra Promotion Frames", boostExtraPromotionFrames, _prev_boostExtraPromotionFrames)) _prev_boostExtraPromotionFrames = boostExtraPromotionFrames;
    if (TrackSettingChangeBool("Allow Live Grading During Boost", allowLiveBoostGrading, _prev_allowLiveBoostGrading)) _prev_allowLiveBoostGrading = allowLiveBoostGrading;
    if (TrackSettingChangeFloat("Boost Baseline Follow Rate", boostBaselineFollowRate, _prev_boostBaselineFollowRate)) _prev_boostBaselineFollowRate = boostBaselineFollowRate;
    if (TrackSettingChangeFloat("Boost Headroom Scale", boostHeadroomScale, _prev_boostHeadroomScale)) _prev_boostHeadroomScale = boostHeadroomScale;
    if (TrackSettingChangeFloat("Uphill Slope Leniency", uphillSlopeLeniency, _prev_uphillSlopeLeniency)) _prev_uphillSlopeLeniency = uphillSlopeLeniency;
    if (TrackSettingChangeFloat("Downhill Slope Strictness", downhillSlopeStrictness, _prev_downhillSlopeStrictness)) _prev_downhillSlopeStrictness = downhillSlopeStrictness;
    if (TrackSettingChangeBool("Low Speed Forgiveness", lowSpeedForgivenessEnabled, _prev_lowSpeedForgivenessEnabled)) _prev_lowSpeedForgivenessEnabled = lowSpeedForgivenessEnabled;
    if (TrackSettingChangeFloat("Asphalt Forgiveness Max Speed", forgivenessMaxSpeed_Asphalt, _prev_forgivenessMaxSpeed_Asphalt)) _prev_forgivenessMaxSpeed_Asphalt = forgivenessMaxSpeed_Asphalt;
    if (TrackSettingChangeFloat("Asphalt Forgiveness Min Speed", forgivenessMinSpeed_Asphalt, _prev_forgivenessMinSpeed_Asphalt)) _prev_forgivenessMinSpeed_Asphalt = forgivenessMinSpeed_Asphalt;
    if (TrackSettingChangeFloat("Asphalt Forgiveness Factor", forgivenessFactor_Asphalt, _prev_forgivenessFactor_Asphalt)) _prev_forgivenessFactor_Asphalt = forgivenessFactor_Asphalt;
    if (TrackSettingChangeFloat("Dirt Forgiveness Max Speed", forgivenessMaxSpeed_Dirt, _prev_forgivenessMaxSpeed_Dirt)) _prev_forgivenessMaxSpeed_Dirt = forgivenessMaxSpeed_Dirt;
    if (TrackSettingChangeFloat("Dirt Forgiveness Min Speed", forgivenessMinSpeed_Dirt, _prev_forgivenessMinSpeed_Dirt)) _prev_forgivenessMinSpeed_Dirt = forgivenessMinSpeed_Dirt;
    if (TrackSettingChangeFloat("Dirt Forgiveness Factor", forgivenessFactor_Dirt, _prev_forgivenessFactor_Dirt)) _prev_forgivenessFactor_Dirt = forgivenessFactor_Dirt;
    if (TrackSettingChangeFloat("Grass Forgiveness Max Speed", forgivenessMaxSpeed_Grass, _prev_forgivenessMaxSpeed_Grass)) _prev_forgivenessMaxSpeed_Grass = forgivenessMaxSpeed_Grass;
    if (TrackSettingChangeFloat("Grass Forgiveness Min Speed", forgivenessMinSpeed_Grass, _prev_forgivenessMinSpeed_Grass)) _prev_forgivenessMinSpeed_Grass = forgivenessMinSpeed_Grass;
    if (TrackSettingChangeFloat("Grass Forgiveness Factor", forgivenessFactor_Grass, _prev_forgivenessFactor_Grass)) _prev_forgivenessFactor_Grass = forgivenessFactor_Grass;
}
