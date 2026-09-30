/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CAreaEnvironmentComponent extends CTriggerAreaComponent {
    import var priority: Int32;
    import var blendingDistance: Float;
    import var blendingScale: Float;
    import var blendInTime: Float;
    import var blendOutTime: Float;
    import var terrainBlendingDistance: Float;
    import var blendAboveAndBelow: Bool;
    import var rainDropsParticleSystem: CParticleSystem;
    import var rainSplashesParticleSystem: CParticleSystem;
    import var additionalEnvEntity: CEntityTemplate;
    import var environmentDefinition: CEnvironmentDefinition;
    import var blendingCurveEnabled: Bool;
    import var blendingCurve: SSimpleCurve;
    import var points: array<SAreaEnvironmentPoint>;
}

import struct SAreaEnvironmentPoint {
    import var position: Vector;
    import var direction: EulerAngles;
    import var type: EAreaEnvironmentPointType;
    import var blend: EAreaEnvironmentPointBlend;
    import var innerRadius: Float;
    import var outerRadius: Float;
    import var scaleX: Float;
    import var scaleY: Float;
    import var scaleZ: Float;
    import var useCurve: Bool;
    import var curve: SSimpleCurve;
    import var blendScale: Float;
    import var environmentDefinition: CEnvironmentDefinition;
}