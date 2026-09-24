/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ETriggeredDamageType
{
	ETDT_Roots,
	ETDT_Poison
}

class W3DamageAreaTrigger extends CEntity
{
	editable var onlyAffectsPlayer 		: bool;
	editable var activateOnce 			: bool;
	editable var checkTag 				: bool;
	editable var isEnabled				: bool;
	editable var actorTag 				: name;
	editable var excludedActorsTags		: array <name>;
	editable var damage 				: float;
	editable var useDamageFromXML		: name;
	editable var damageFromFXDelay 		: float;
	editable var areaRadius 			: float;
	editable var attackInterval 		: float;
	editable var preAttackDuration 		: float;
	editable var externalFXEntityTag	: name;
	editable var externalFXName			: name;
	editable var attackFX 				: name;
	editable var preAttackFX 			: name;
	editable var attackFXEntity 		: CEntityTemplate;
	editable var soundFX 				: string;
	editable var immunityFact			: string;
	editable var damageType				: ETriggeredDamageType;

	private var action 					: W3DamageAction;
	private var affectedEntity 			: CEntity;
	private	var fxEntity 				: CEntity;
	private var activated 				: bool;
	private var dummyGameplayEntity		: CGameplayEntity;
	private var victim 					: CActor;
	private var externalFXEntity 		: CEntity;
	
	protected var pos 					: Vector;
	
	default activateOnce = false;
	default onlyAffectsPlayer = false;
	default checkTag = false;
	default activated = false;
	default areaRadius = 1;
	default attackInterval = 5;
	default preAttackDuration = 3;
	default damageFromFXDelay = 0.3;
	default attackFX = 'attack_fx1';
	default preAttackFX = 'ground_fx';
	default isEnabled	 = true;
	default useDamageFromXML = 'root_ground_damage_area';
	
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		if( ( FactsQuerySum( immunityFact ) > 0 ) && ( activator.GetEntity() == thePlayer ) )
			return false;
		
		if ( isEnabled)
		{
			if ( activateOnce )
			{
				if ( !activated )
				{
					Activate ( activator.GetEntity() );
				}
			}
			else
			{
				Activate ( activator.GetEntity() );
			}
		}
	}
	
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		if ( isEnabled)
		{
			Deactivate ( activator.GetEntity() );			
		}
	}
	
	function SetEnable ( enable : bool )
	{
		isEnabled = enable;
	}
	
	function Activate( _affectedEntity : CEntity )
	{
		var victim : CActor;
		victim = (CActor)_affectedEntity;
		
		affectedEntity = _affectedEntity;
		
		if ( victim && victim.IsAlive() )
		{
			if ( onlyAffectsPlayer )
			{
				if ( (CPlayer)victim )
				{
					PreAttack();
					if ( activateOnce && !activated )
					{
						activated = true;
					}
				}
			}
			else
			{
				if ( victim.GetDistanceFromGround( 2 ) < 1.5f )
				{
					if ( checkTag )
					{
						if ( affectedEntity.HasTag( actorTag ) )
						{
							PreAttack();
							if ( activateOnce && !activated )
							{
								activated = true;
							}
						}
					}
					else
					{
						PreAttack();
						if ( activateOnce && !activated )
						{
							activated = true;
						}
					}
				}
			}
		}		
	}
	
	function Deactivate ( _affectedEntity : CEntity )
	{
		var victim : CActor;
		victim = (CActor)_affectedEntity;
		
		switch ( damageType )
		{
			case ETDT_Roots:
		
				if ( onlyAffectsPlayer )
				{
					if ( (CPlayer)victim )
					{
						if ( !activateOnce )
						{
							StopRootTimers();
						}
					}
				}
				else if( (CActor)victim )
				{
					if ( checkTag )
					{
						if ( victim.HasTag( actorTag ) )
						{
							if ( !activateOnce )
							{
								StopRootTimers();
							}
						}
					}
					else
					{
						if ( !activateOnce )
						{
							StopRootTimers();
						}
					}
				}
				break;
			
			case ETDT_Poison:
				
				ContinuedPoisoning(false);
				
				break;
		}	
	}
	
	timer function RootAttackTimer( delta : float , id : int)
	{
		RootAttack();
	}
	
	timer function DealDamageDelay( delta : float , id : int)
	{
		DealDamage();
	}
	
	timer function PoisonDamageDelay (delta : float , id : int)
	{
		PoisonVictim();
	}
	
	timer function PreAttackTimer( delta : float, id : int )
	{
		PreAttack();
	}
	
	function ContinuedPoisoning(keepPoisoning : bool)
	{
		if (keepPoisoning)
			AddTimer('PoisonDamageDelay',1.0,true);
		else
			RemoveTimer('PoisonDamageDelay');
	}
	
	function PoisonVictim()
	{
		victim = (CActor)affectedEntity;
		victim.AddEffectDefault( EET_Poison, dummyGameplayEntity, "PopsGasAffliction" );
	}
	
	function PreAttack()
	{
		
		var rot : EulerAngles;
		
		
		victim = (CActor)affectedEntity;
		pos = victim.GetWorldPosition();
		rot = victim.GetWorldRotation();
		switch ( damageType )
		{
			case ETDT_Roots:
				PrepareRootAttack(rot);
				break;
			case ETDT_Poison:
				ContinuedPoisoning(true);
				break;
			default :
				PrepareRootAttack(rot);
		}	
	}
	
	function PrepareRootAttack(rot:EulerAngles)
	{
		

		if( externalFXEntityTag != '' && !externalFXEntity )
		{
			externalFXEntity = theGame.GetEntityByTag( externalFXEntityTag );
		}
	
		fxEntity = theGame.CreateEntity( attackFXEntity, pos, rot );
		fxEntity.PlayEffect( preAttackFX );
		fxEntity.SoundEvent( soundFX );
		fxEntity.DestroyAfter( preAttackDuration+10.0 );
		
		if(externalFXEntity && externalFXName != '' )
		{
			externalFXEntity.PlayEffectSingle( externalFXName );
		}
		
		
		AddTimer( 'RootAttackTimer', preAttackDuration, false );
	}
	
	function RootAttack()
	{
		if ( fxEntity )
		{
			fxEntity.StopEffect( preAttackFX );
			if ( externalFXName != '' )
			{
				externalFXEntity.StopEffect( externalFXName );
			}
			fxEntity.PlayEffect( attackFX, fxEntity );
		}
		
		AddTimer( 'DealDamageDelay', damageFromFXDelay, false );
		if ( !activateOnce )
		{
			AddTimer( 'PreAttackTimer', attackInterval, true );
		}
	}
	
	function DealDamage()
	{
		var victims 	: array<CGameplayEntity>;
		var victimTags 	: array <name>;
		var i : int;
		var k : int;
		var l : int;
		var currentTag 	: name;
		var containExcludedtag : bool;
		var dm 			: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var dmg_max, dmg_min : SAbilityAttributeValue;
		
		
		containExcludedtag = false;
		
		if( IsNameValid( useDamageFromXML ) )
		{
			dm.GetAbilityAttributeValue('environment_DamageStats', useDamageFromXML, dmg_min, dmg_max);
			if ( (dmg_max.valueBase * dmg_max.valueMultiplicative) > 0 )
			{
				damage = dmg_max.valueBase * dmg_max.valueMultiplicative;
			}
		}
		
		if( fxEntity )
		{
			FindGameplayEntitiesInRange( victims, fxEntity, areaRadius, 100, '', FLAG_OnlyAliveActors );
		}
		else
		{
			FindGameplayEntitiesInRange( victims, this, areaRadius, 100, '', FLAG_OnlyAliveActors );
		}
		
		action = new W3DamageAction in this;
		for ( i = 0 ; i < victims.Size() ; i += 1 )
		{
			
			victim = (CActor)victims[i];
			
			if ( excludedActorsTags.Size() > 0 )
			{
				victimTags = victim.GetTags();
				
										
				for ( k = 0 ; k < excludedActorsTags.Size() ; k += 1 )
				{
					currentTag = excludedActorsTags[k];
					if ( victimTags.Contains ( currentTag ))
					{	
						containExcludedtag	= true;			
						break;
					}
				}
				
				if ( containExcludedtag )
				{
					containExcludedtag	= false;
					victim = NULL;
					continue;
				}
			}
			if ( victim )
			{
				action.Initialize( (CGameplayEntity)fxEntity, victim, this, this.GetName()+"_"+"root_attack", EHRT_Light, CPS_AttackPower,false,false,false,true);
				action.SetHitAnimationPlayType(EAHA_ForceYes);
				action.AddDamage(theGame.params.DAMAGE_NAME_PHYSICAL, damage );
				action.attacker = (CGameplayEntity)fxEntity;
				theGame.damageMgr.ProcessAction( action );
			}
		}
		
		delete action;
	}
	
	function StopRootTimers()
	{
		RemoveTimer( 'PreAttackTimer' );
		RemoveTimer( 'RootAttackTimer' );
		RemoveTimer( 'DealDamageDelay' );
	}
}
