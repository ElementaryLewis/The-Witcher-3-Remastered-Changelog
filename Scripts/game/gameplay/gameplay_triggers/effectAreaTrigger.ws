/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3EffectAreaTrigger extends CGameplayEntity
{
	editable var effect 						: EEffectType;
	editable var useDefaultValuesFromXML 		: bool;
	editable var effectDuration 				: float;
	editable var customDamageValuePerSec 		: SAbilityAttributeValue;
	editable var immunityFact					: string;
	editable inlined var customParams			: W3BuffCustomParams;
	
	private var entitiesInRange : array<CActor>;
	
	default useDefaultValuesFromXML = true;
	default effectDuration = 0.5;
	
	hint effectDuration = "duration in seconds. Buff is refreshed every frame while being inside area.";
	hint useDefaultValuesFromXML = "if marked as false, values from effectDuration and customDamageValuePerSec will be used";
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var victim : CActor;
		
		victim = (CActor)activator.GetEntity();
		
		if( victim && !entitiesInRange.Contains( victim ) )
			entitiesInRange.PushBack( victim );
			
		if( entitiesInRange.Size() == 1 )
			AddTimer( 'ProcessArea', 0.1f, true );
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var victim : CActor;
		victim = (CActor)activator.GetEntity();
		
		if( victim )
			entitiesInRange.Remove( victim );
		
		if( entitiesInRange.Size() == 0 )
			RemoveTimer( 'ProcessArea' );
	}
	
	timer function ProcessArea( dt : float , id : int)
	{
		var i : int;	
		var params : SCustomEffectParams;
		
		params.sourceName = GetName();
		if(!useDefaultValuesFromXML || customParams)
		{
			params.effectType = effect;			
			params.duration = effectDuration;
			params.effectValue = customDamageValuePerSec;
			params.buffSpecificParams = customParams;
		}
		
		for( i = entitiesInRange.Size()-1; i>=0; i -= 1 )
		{
			if(!entitiesInRange[i])
			{
				entitiesInRange.EraseFast(i);
				continue;
			}
				
			if( ( entitiesInRange[i] == thePlayer ) && ( FactsQuerySum( immunityFact ) > 0 ))
				continue;
				
			if ( useDefaultValuesFromXML && !customParams)
				entitiesInRange[i].AddEffectDefault( effect, NULL, params.sourceName );
			else
				entitiesInRange[i].AddEffectCustom(params);
		}
	}
}

class W3EffectImmunityAreaTrigger extends CEntity
{
	editable var effectImmunity : EEffectType;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		
		actor = (CActor)activator.GetEntity();
		actor.AddBuffImmunity( effectImmunity, 'BuffImmunityArea', false );
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		
		actor = (CActor)activator.GetEntity();
		actor.RemoveBuffImmunity( effectImmunity, 'BuffImmunityArea' );
	}
}
