/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class W3BeehiveStandingEntity extends W3AnimatedContainer
{
	editable var damageVal : SAbilityAttributeValue;

	private var actorsInRange : array<CActor>;
	private var wasInteracted : bool;
	
		default wasInteracted = false;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		
		GotoState('Idle');
	}
	
	event OnItemGiven(data : SItemChangedData)
	{
		
		
		
		if(wasInteracted)
			GotoState('Agitated');
		
		super.OnItemGiven(data);
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		wasInteracted = true;
		super.OnInteraction(actionName, activator);
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
	
		actor = (CActor)activator.GetEntity();
		if(actor && !actorsInRange.Contains(actor))
			actorsInRange.PushBack(actor);
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		
		actor = (CActor)activator.GetEntity();
		if(actor)
			actorsInRange.Remove(actor);
	}
	
	public function ClearActorsInRange()
	{
		actorsInRange.Clear();
	}
	
	public function GetActorsInArea() : array<CActor>
	{
		return actorsInRange;
	}
}


state Idle in W3BeehiveStandingEntity {}


state Agitated in W3BeehiveStandingEntity
{
	event OnEnterState( prevStateName : name )
	{
		var entityTemplate : CEntityTemplate;
		
		parent.PlayEffect('bee_cloud');
		parent.GetComponentByClassName('CTriggerAreaComponent').SetEnabled(true);
		
		
		entityTemplate = (CEntityTemplate)LoadResource('bees');		
		if ( entityTemplate )
			theGame.CreateEntity( entityTemplate, parent.GetWorldPosition());
		
		W3BeehiveStandingEntity_Agitated_Loop();
	}
	
	entry function W3BeehiveStandingEntity_Agitated_Loop()
	{
		var i : int;
		var actors : array<CActor>;
		var params : SCustomEffectParams;
	
		params.effectType = EET_Swarm;
		params.creator = parent;
		params.duration = 0.5;
		params.vibratePadLowFreq = 0.1;
		params.vibratePadHighFreq = 0.2;
		params.effectValue = parent.damageVal;
		
		while(true)
		{
			actors = parent.GetActorsInArea();			
			for(i=0; i<actors.Size(); i+=1)
				actors[i].AddEffectCustom(params);
				
			Sleep(0.1);
		}
	}
	
	event OnIgniHit( sign : W3IgniProjectile )
	{
		parent.OnIgniHit(sign);
		parent.StopEffect('bee_cloud');
		parent.PlayEffect('bee_fire');
		parent.ClearActorsInRange();
		parent.GetComponentByClassName('CTriggerAreaComponent').SetEnabled(false);
		GotoState('Idle');
	}
}