/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CGameplayEffectsComponent extends CComponent
{
	
	import final function SetGameplayEffectFlag( flag : EEntityGameplayEffectFlags, value : bool );
	
	
	
	import final function GetGameplayEffectFlag( flag : EEntityGameplayEffectFlags ) : bool;
	
	
	import final function ResetGameplayEffectFlag( flag : EEntityGameplayEffectFlags ) : bool;
}



function GetGameplayEffectsComponent( entity : CEntity ) : CGameplayEffectsComponent
{
	if(entity)
		return ( CGameplayEffectsComponent )entity.GetComponentByClassName( 'CGameplayEffectsComponent' );
		
	return NULL;
}
