/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3AirDrainEntity extends CGameplayEntity
{
	editable var customDrainPoints : float;
	editable var customDrainPercents : float;
	editable var factOnActivated : string;
	editable var factOnDeactivated : string;
	
		hint customDrainPoints = "Custom air loss in points per second";
		hint customDrainPercents = "Custom air loss in percents of max per second (0..1)";
		hint factOnActivated = "Fact added upon air drain activation";
		hint factOnDeactivated = "Fact added upon air drain deactivation";
		
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		var params : SCustomEffectParams;
		
		actor = (CActor) activator.GetEntity();
		
		if(customDrainPoints > 0 || customDrainPercents > 0)
		{
			params.effectType = EET_AirDrain;
			params.creator = this;
			params.sourceName = GetName();
			params.duration = -1;
			params.effectValue.valueAdditive = customDrainPoints;
			params.effectValue.valueMultiplicative = customDrainPercents;
			
			actor.AddEffectCustom(params);
		}
		else
		{
			actor.AddEffectDefault(EET_AirDrain, this, GetName());
		}
		
		if((CPlayer)actor)
		{
			theGame.GetGuiManager().GetHudEventController().RunEvent_OxygenBarModule_SetInGasArea( true );
			
			if(factOnActivated != "")
				FactsAdd( factOnActivated, 1 );
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		
		actor = (CActor) activator.GetEntity();
		
		if(actor)
			actor.RemoveBuff(EET_AirDrain, false, GetName());
		
		if((CPlayer)actor)
		{
			theGame.GetGuiManager().GetHudEventController().RunEvent_OxygenBarModule_SetInGasArea( false );
			
			FactsAdd("player_was_in_gas_area", 1, 5);
			
			if(factOnDeactivated != "")
				FactsAdd( factOnDeactivated, 1 );
		}		
	}
}