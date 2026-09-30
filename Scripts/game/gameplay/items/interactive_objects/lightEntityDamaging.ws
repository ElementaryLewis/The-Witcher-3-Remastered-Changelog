/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3LightEntityDamaging extends CLightEntitySimple
{
	editable var hitReactionType : EHitReactionType;
	editable var damagePerSec : float;
	editable var appliesBurning : bool;

		default hitReactionType = EHRT_None;
		default damagePerSec = 10;
		default appliesBurning = false;
		default damageDealingEnabled = true;
		default spawned = false;

	protected var entitiesInRange : array<CGameplayEntity>;
	private var entitiesInRangeEnterTime : array<EngineTime>;
	private var area : CTriggerAreaComponent;
	private var buffDamageVal : SAbilityAttributeValue;
	private var damageDealingEnabled : bool;
	private var buffParams : SCustomEffectParams;
	private var spawned : bool;
	private const var FIRE_DAMAGE_FX : name;						

		default FIRE_DAMAGE_FX = 'critical_burning';

	event OnSpawned( spawnData : SEntitySpawnData )
	{

		area = (CTriggerAreaComponent)GetComponentByClassName('CTriggerAreaComponent');
		LogAssert(area, "W3LightEntityDamaging.OnSpawned: damageable light source has no damage area!!!!");

		if(appliesBurning)
			buffDamageVal.valueAdditive = damagePerSec;

		spawned = true;
		
		super.OnSpawned( spawnData );
	}

	protected function TurnLightOn()
	{
		var ents : array<CGameplayEntity>;
		var time : EngineTime;
		var i : int;

		

		if(!spawned)
			return;

		super.TurnLightOn();

		area.SetEnabled(true);
		area.GetGameplayEntitiesInArea( ents, 10 );
		ArrayOfGameplayEntitiesAppendUnique(entitiesInRange, ents);
		time = theGame.GetEngineTime();

		for(i=0; i<ents.Size(); i+=1)
			entitiesInRangeEnterTime.PushBack(time);

		if(entitiesInRange.Size() > 0)
			AddTimer('TickTimer', 0.0001, true);
	}

	protected function TurnLightOff()
	{
		if(!spawned)
			return;

		super.TurnLightOff();
		area.SetEnabled(false);
		entitiesInRange.Clear();
		entitiesInRangeEnterTime.Clear();
		RemoveTimer('TickTimer');
	}

	public function EnableDamage(en : bool)
	{
		damageDealingEnabled = en;
	}

	timer function TickTimer(dt : float, id : int)
	{
		var action : W3DamageAction;
		var i : int;
		var actor : CActor;

		if(entitiesInRange.Size() <= 0)
		{
			RemoveTimer('TickTimer');
			return;
		}

		if(!damageDealingEnabled)
			return;

		if(appliesBurning && buffParams.effectType == EET_Undefined)
		{
			buffParams.effectType == EET_Burning;
			buffParams.creator = this;
			buffParams.sourceName = "damageable_light_source";
			buffParams.duration = 0.5;
			buffParams.effectValue = buffDamageVal;
		}

		if( entitiesInRange.Size() > 0 )
		{
			action = new W3DamageAction in this;
			for(i=entitiesInRange.Size()-1; i>=0; i-=1)
			{
				actor = (CActor)entitiesInRange[i];
				if(actor)
				{
					if(!actor.IsAlive())
					{
						entitiesInRange.EraseFast(i);
						entitiesInRangeEnterTime.EraseFast(i);
						continue;
					}

					if(appliesBurning)
					{
						actor.AddEffectCustom(buffParams);
					}
					else
					{
						action.Initialize(this, actor, this, 'damageable_light_source', hitReactionType, CPS_Undefined, false, false, false, true, FIRE_DAMAGE_FX, FIRE_DAMAGE_FX);

						
						if(actor.IsEffectActive(FIRE_DAMAGE_FX) || EngineTimeToFloat(theGame.GetEngineTime() - entitiesInRangeEnterTime[i]) < 1)
						{
							action.SetCanPlayHitParticle(false);
						}

						action.SetIsDoTDamage(dt);
						action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, damagePerSec * dt);
						theGame.damageMgr.ProcessAction( action );
					}
				}
				else
				{
					entitiesInRange[i].OnFireHit(this);
				}
			}
			delete action;
		}
	}

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var ent : CGameplayEntity;
		var actor : CActor;

		if(!spawned)
			return false;

		ent = (CGameplayEntity)activator.GetEntity();
		if(ent && !entitiesInRange.Contains(ent))
		{
			entitiesInRange.PushBack(ent);
			entitiesInRangeEnterTime.PushBack(theGame.GetEngineTime());
			actor = (CActor)ent;
			if(actor)
				actor.PauseHPRegenEffects( 'W3LightEntityDamaging', -1 );

			if(entitiesInRange.Size() == 1)
				AddTimer('TickTimer', 0.0001, true);
		}
	}

	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var ent : CGameplayEntity;
		var actor : CActor;

		if(!spawned)
			return false;

		ent = (CGameplayEntity)activator.GetEntity();
		if(ent)
		{
			entitiesInRangeEnterTime.Erase( entitiesInRange.FindFirst(ent) );
			entitiesInRange.Remove(ent);

			actor = (CActor)ent;
			if(actor)
			{
				actor.ResumeHPRegenEffects( 'W3LightEntityDamaging' );

				if(actor.IsEffectActive(FIRE_DAMAGE_FX))
					actor.StopEffect(FIRE_DAMAGE_FX);
			}
		}
	}
}