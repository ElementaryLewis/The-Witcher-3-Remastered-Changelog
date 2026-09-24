/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CHorseCorrectionTrigger extends CGameplayEntity
{
	editable var valueOnEnter : bool;
	editable var valueOnExit : bool;
	
	default valueOnEnter = false;
	default valueOnExit = true;
	
	var horse : CGameplayEntity;
	var horseComp : W3HorseComponent;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		if( activator.GetEntity() == thePlayer && ((CActor)activator.GetEntity()).IsUsingHorse() )
		{
			horse = ((CActor)activator.GetEntity()).GetUsedVehicle();
			horseComp = (W3HorseComponent)horse.GetComponentByClassName( 'W3HorseComponent' );
			
			horseComp.SetIsInCustomSpot( valueOnEnter );
			
			return true;
		}
		
		return false;
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		if( activator.GetEntity() == thePlayer && ((CActor)activator.GetEntity()).IsUsingHorse() )
		{
			horse = ((CActor)activator.GetEntity()).GetUsedVehicle();
			horseComp = (W3HorseComponent)horse.GetComponentByClassName( 'W3HorseComponent' );
			
			horseComp.SetIsInCustomSpot( valueOnExit );
			
			return true;
		}
		
		return false;
	}
}