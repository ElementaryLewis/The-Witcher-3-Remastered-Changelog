/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CApexResource extends CMeshTypeResource {
    import var apexBinaryAsset: array<Uint8>;
    import var apexMaterialNames: array<String>;
    import var shadowDistance: Float;
}

import class CClothComponent extends CMeshTypeComponent {
    import var resource: CApexResource;
    
    import var recomputeNormals: Bool;
    import var correctSimulationNormals: Bool;
    import var slowStart: Bool;
    import var useStiffSolver: Bool;
    import var pressure: Float;
    
    
    
    
    import var maxDistanceBlendTime: Float;
    import var uvChannelForTangentUpdate: Uint32;
    
    
    import var collisionResponseCoefficient: Float;
    import var allowAdaptiveTargetFrequency: Bool;
    import var windScaler: Float;
    import var triggeringCollisionGroupNames: array<CName>;
    import var triggerType: ETriggerShape;
    import var triggerDimensions: Vector;
    
    import var shadowDistanceOverride: Float;

    import final function SetSimulated( value : bool );
    import final function SetMaxDistanceScale( scale : float );
    import final function SetFrozen( frozen : bool );
}