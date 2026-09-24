/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CCenserTrigger extends CGameplayEntity
{
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( activator.GetEntity() == thePlayer )
		{
			thePlayer.SetBehaviorVariable( 'censerSwinging', 1.0, true );
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		if( activator.GetEntity() == thePlayer )
		{
			thePlayer.SetBehaviorVariable( 'censerSwinging', 0.0, true );
		}
	}
}