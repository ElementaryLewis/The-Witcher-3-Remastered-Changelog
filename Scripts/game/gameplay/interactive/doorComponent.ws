/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CDoorComponent extends CInteractionComponent
{	
	import function Open( force : bool, unlock : bool );	
	import function Close( force : bool );

	import function IsOpen() : bool;
	import function IsLocked() : bool;
	
	import function AddForceImpulse( origin : Vector, force : float );	
	import function InstantClose();
	import function InstantOpen( unlock : bool );
	import function AddDoorUser( actor : CActor );
	import function EnebleDoors( enable : bool );
	import function IsInteractive( ) : bool;
	import function IsTrapdoor( ) : bool;	
	import function InvertMatrixForDoor( m : Matrix ) : Matrix;	
	import function Unsuppress();
}