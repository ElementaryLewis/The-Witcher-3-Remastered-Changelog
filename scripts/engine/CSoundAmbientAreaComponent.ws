/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CSoftTriggerAreaComponent extends CTriggerAreaComponent {
    import var outerClippingAreaTags: TagList;
    
    
    import var invertPenetrationFraction: Bool;
}

import struct SReverbDefinition {
    import var reverbName: String;
    import var enabled: Bool;
}

import struct SSoundGameParameterValue {
    import var gameParameterName: String;
    import var gameParameterValue: Float;
}

import struct SSoundParameterCullSettings {
    import var gameParameterName: String;
    import var gameParameterCullValue: Float;
    import var invertCullCheck: Bool;
}

import struct SSoundAmbientDynamicSoundEvents {
    import var eventName: String;
    import var repeatTime: Float;
    import var repeatTimeVariance: Float;
    import var triggerOnActivation: Bool;
}

import class CSoundAmbientAreaComponent extends CSoftTriggerAreaComponent {
    import var soundEvents: String;
    import var reverb: SReverbDefinition;
    import var customEventOnEnter: String;
    import var soundEventsOnEnter: array<String>;
    import var soundEventsOnExit: array<String>;
    import var enterExitEventsUsePosition: Bool;
    import var intensityParameter: Float;
    import var intensityParameterFadeTime: Float;
    import var maxDistance: Float;
    import var maxDistanceVertical: Float;
    import var banksDependency: array<CName>;
    import var occlusionEnabled: Bool;
    import var outerListnerReverbRatio: Float;
    import var priorityParameterMusic: Bool;
    import var parameterEnteringTime: Float;
    import var parameterEnteringCurve: ESoundParameterCurveType;
    import var parameterExitingTime: Float;
    import var parameterExitingCurve: ESoundParameterCurveType;
    import var useListernerDistance: Bool;
    import var isGate: Bool;
    import var gatewayRotation: Float;
    import var isWalla: Bool;
    import var wallaSoundEvents: array<String>;
    import var wallaEmitterSpread: Float;
    import var wallaOmniFactor: Float;
    import var wallaMinDistance: Float;
    import var wallaMaxDistance: Float;
    import var wallaBoxExtention: Float;
    import var wallaRotation: Float;
    import var wallaAfraidRetriggerTime: Float;
    import var wallaAfraidDecreaseRate: Float;
    import var parameters: array<SSoundGameParameterValue>;
    import var parameterCulling: array<SSoundParameterCullSettings>;
    import var fitWaterShore: Bool;
    import var waterGridCellCount: Uint32;
    import var waterLevelOffset: Float;
    import var fitFoliage: Bool;
    import var foliageMaxDistance: Float;
    import var foliageStepNeighbors: Uint32;
    import var foliageVitalAreaRadius: Float;
    import var foliageVitalAreaPoints: Uint32;
    import var dynamicParameters: array<ESoundAmbientDynamicParameter>;
    import var dynamicEvents: array<SSoundAmbientDynamicSoundEvents>;
}