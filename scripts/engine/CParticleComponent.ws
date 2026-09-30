/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CParticleComponent extends CDrawableComponent {
    import var particleSystem: CParticleSystem;
    import var transparencySortGroup: ETransparencySortGroup;
    import var envAutoHideGroup: EEnvAutoHideGroup;
}

import class CParticleSystem extends CResource {
    import var previewBackgroundColor: Color;
    import var previewShowGrid: Bool;
    import var visibleThroughWalls: Bool;
    import var prewarmingTime: Float;
    
    import var lods: array<SParticleSystemLODLevel>;
    import var autoHideDistance: Float;
    import var autoHideRange: Float;
    import var renderingPlane: ERenderingPlane;
}

import struct SParticleSystemLODLevel {
    import var distance: Float;
}