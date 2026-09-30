/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CFairytaleWitchTrigger extends CGameplayEntity
{
	editable var areaNumber : int;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( activator.GetEntity() == thePlayer )
		{
			thePlayer.SetInsideDiveAttackArea( true );
			thePlayer.SetDiveAreaNumber( areaNumber );
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		if( activator.GetEntity() == thePlayer )
		{
			if( areaNumber == 0 )
			{
				thePlayer.SetInsideDiveAttackArea( false );
			}
			thePlayer.SetDiveAreaNumber( -1 );
		}
	}
}