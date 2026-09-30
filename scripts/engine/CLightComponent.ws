/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SLightFlickering {
    import var positionOffset: Float;
    import var flickerStrength: Float;
    import var flickerPeriod: Float;
}

import class CLightComponent extends CSpriteComponent {
    import var isEnabled: Bool;
    import var shadowCastingMode: ELightShadowCastingMode;
    import var shadowFadeDistance: Float;
    import var shadowFadeRange: Float;
    import var shadowBlendFactor: Float;
    import var radius: Float;
    import var brightness: Float;
    import var attenuation: Float;
    import var color: Color;
    import var envColorGroup: EEnvColorGroup;
    import var autoHideDistance: Float;
    import var autoHideRange: Float;
    import var lightFlickering: SLightFlickering;
    import var allowDistantFade: Bool;
    
}

import class CPointLightComponent extends CLightComponent {
    import var cacheStaticShadows: Bool;
    
}

import class CSpotLightComponent extends CLightComponent {
    import var innerAngle: Float;
    import var outerAngle: Float;
    import var softness: Float;
}