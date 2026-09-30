/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CHorseJumpTrigger extends CGameplayEntity
{
	var lastActivation : float;
	var triggerHeading, playerHeading : float;
	var angleDist : float;
	var horse : CGameplayEntity;
	var horseComp : W3HorseComponent;
	var lastArea : CTriggerAreaComponent;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( lastActivation + 0.25 > theGame.GetEngineTimeAsSeconds() )
		{
			return false;
		}
		
		if( activator.GetEntity() == thePlayer && ((CActor)activator.GetEntity()).IsUsingHorse() )
		{
			if ( !lastArea )
			{
				triggerHeading = VecHeading( GetHeadingVector() );
				horse = ((CActor)activator.GetEntity()).GetUsedVehicle();
				horseComp = (W3HorseComponent)horse.GetComponentByClassName( 'W3HorseComponent' );

				AddTimer( 'CheckOrientation', 0.01, true );
				lastActivation = theGame.GetEngineTimeAsSeconds();
				lastArea = area;
			}
		}
	}
	
	private timer function CheckOrientation( dt : float, id : int )
	{
		playerHeading = VecHeading( thePlayer.GetHeadingVector() );
		angleDist = AngleDistance( triggerHeading, playerHeading );
		if( horseComp.InternalGetSpeed() > 2.0 )
		{
			if( AbsF( angleDist ) > 10.0 && AbsF( angleDist ) < 45.0 )
			{
				horseComp.OnHorseStop();
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		if( activator.GetEntity() == thePlayer  )
		{
			if ( ((CActor)activator.GetEntity()).IsUsingHorse() )
			{
				playerHeading = VecHeading( thePlayer.GetHeadingVector() );
				angleDist = AngleDistance( triggerHeading, playerHeading );
				if( AbsF( angleDist ) < 15.0 )
				{
					horseComp.OnJumpHack();
					lastActivation = theGame.GetEngineTimeAsSeconds(); 
				}
			}
			
			if ( lastArea == area )
			{
				RemoveTimer( 'CheckOrientation' );
				lastArea = NULL;
			}
		}
	}
}