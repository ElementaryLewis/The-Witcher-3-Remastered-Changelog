/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3UnlimitedDivingArea extends CEntity
{
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var entity : CEntity;
		
		entity = activator.GetEntity();
		if ( entity == thePlayer )
		{
			((CR4PlayerStateSwimming)thePlayer.GetState('Swimming')).EnableUnlimitedDiving( true );
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var entity : CEntity;
		
		entity = activator.GetEntity();
		if ( entity == thePlayer )
		{
			((CR4PlayerStateSwimming)thePlayer.GetState('Swimming')).EnableUnlimitedDiving( false );
		}
	}
}