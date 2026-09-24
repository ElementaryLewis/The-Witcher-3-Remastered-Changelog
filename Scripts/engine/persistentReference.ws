/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct PersistentRef
{
};


import function PersistentRefSetNode( out outPersistentRef : PersistentRef, node : CNode );


import function PersistentRefSetOrientation( out outPersistentRef : PersistentRef, position : Vector, rotation : EulerAngles );


import function PersistentRefGetEntity( out persistentRef : PersistentRef ) : CEntity;


import function PersistentRefGetWorldPosition( out persistentRef : PersistentRef ) : Vector;


import function PersistentRefGetWorldRotation( out persistentRef : PersistentRef ) : EulerAngles;


import function PersistentRefGetWorldOrientation( out persistentRef : PersistentRef, out outPosition : Vector, out outRotation : EulerAngles );
