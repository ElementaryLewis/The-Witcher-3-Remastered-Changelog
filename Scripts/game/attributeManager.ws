/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CDebugAttributesManager extends CObject
{
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	import final function AddAttribute( debugName : name, propertyName : name, context : IScriptable, optional groupName : name ) : bool;
}


exec function AT()
{
	
	var player : CPlayer;
	player = thePlayer;
	
	theDebug.AddAttribute( 'bUseRunLSHold', 'bUseRunLSHold', player );
	theDebug.AddAttribute( 'bUseRunLSToggle', 'bUseRunLSToggle', player );
	theDebug.AddAttribute( 'bForcedCombat', 'bForcedCombat', player );
	
	theDebug.AddAttribute( 'PlayerHealth', 'initialHealth', player, 'InitialValues' );
	
}