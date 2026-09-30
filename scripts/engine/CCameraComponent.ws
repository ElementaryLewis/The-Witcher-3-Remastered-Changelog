/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SCustomClippingPlanes {
    import var nearPlaneDistance: Float;
    import var farPlaneDistance: Float;
}

import class CCameraComponent extends CSpriteComponent {
    import var fov: Float;
    import var nearPlane: ENearPlaneDistance;
    import var farPlane: EFarPlaneDistance;
    import var customClippingPlanes: SCustomClippingPlanes;
    import var aspect: Float;
    import var lockAspect: Bool;
    import var defaultCamera: Bool;
}