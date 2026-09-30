/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ReactToBeingHitEntity extends CGameplayEntity
{
	editable var reactsToSwords 			: bool;
	editable var reactsToBolts 				: bool;
	editable var deactivateOnHit 			: bool;
	editable var dealDamage 				: bool;
	editable var debuffType 				: EEffectType;
	editable var debuffDuration 			: float;
	editable var damageTypeName 			: name;
	editable var killOnHpBelowPerc 			: float;
	editable var setBehVarOnKill 			: name;
	editable var behVarValue 				: float;
	
	
	
	editable var gameplayEventOnAttacker 	: name;
	editable var effectOnActivation 		: name;
	editable var durationEffect 			: name;
	editable var effectOnHit 				: name;
	editable var effectOnHitVictim 			: name;
	editable var activeDuration 			: float;
	
	private var active 						: bool;
	private var attributeName 				: name;
	
	default reactsToSwords 					= true;
	default gameplayEventOnAttacker 		= 'ReflectDamageEntityHit';
	default effectOnActivation 				= 'lightning_hit';
	default durationEffect 					= 'charge';
	default effectOnHit 					= 'discharge';
	default effectOnHitVictim 				= 'hit_electric';
	default activeDuration 					= 20;
	default debuffType 						= EET_Knockdown;
	default debuffDuration 					= 2;
	default dealDamage 						= true;
	default damageTypeName 					= 'FireDamage';
	default killOnHpBelowPerc 				= 0.1;
	default setBehVarOnKill 				= 'DeathType';
	default behVarValue 					= 3;
	default deactivateOnHit 				= true;
	
	
	event OnWeaponHit( act : W3DamageAction )
	{
		var attacker 		: CActor;
		
		if ( active && ( reactsToSwords || reactsToBolts ) )
		{
			if( !GetAreFistsEquipped() )
			{
				
				if ( !act.IsActionWitcherSign() ) 
				{
					attacker = (CActor) act.attacker;
					if ( reactsToSwords && act.IsActionMelee() )
					{
						if ( IsNameValid( gameplayEventOnAttacker ) )
						{
							if ( attacker )
							{
								attacker.SignalGameplayEvent( gameplayEventOnAttacker );
								attacker.SignalGameplayEvent( 'StopTaskOnCustomItemCollision' );
								if ( dealDamage )
								{
									DealDamage( act );
								}
								this.PlayEffect( effectOnHit );
								if ( deactivateOnHit )
								{
									this.StopEffect( durationEffect );
									active = false;
								}
							}
						}
					}
					else if ( reactsToBolts && act.IsActionRanged() )
					{
						if ( IsNameValid( gameplayEventOnAttacker ) )
						{
							if ( attacker )
							{
								attacker.SignalGameplayEvent( gameplayEventOnAttacker );
								if ( dealDamage )
								{
									DealDamage( act );
								}
								this.PlayEffect( effectOnHit );
							}
						}
					}
				}
			}
		}
		else
		{
			if( !GetAreFistsEquipped() )
			{
				if ( !act.IsActionWitcherSign() ) 
				{
					attacker = (CActor) act.attacker;
					if ( reactsToSwords && act.IsActionMelee() )
					{
						if ( IsNameValid( gameplayEventOnAttacker ) )
						{
							if ( attacker )
							{
								attacker.SignalGameplayEvent( 'StopTaskOnCustomItemCollision' );
							}
						}
					}
				}
			}
		}
		super.OnWeaponHit( act );
	}
	
	private function DealDamage( action : W3DamageAction )
	{
		var attacker 		: CActor;
		var params 			: SCustomEffectParams;
		var damage 			: float;
		
		if ( !IsNameValid( attributeName ) )
		{
			attributeName = GetBasicAttackDamageAttributeName( theGame.params.ATTACK_NAME_HEAVY, theGame.params.DAMAGE_NAME_PHYSICAL );
		}
		attacker = (CActor) action.attacker;
		if ( attacker )
		{
			damage = CalculateAttributeValue( attacker.GetAttributeValue( attributeName ) );
			if ( killOnHpBelowPerc > 0 && attacker.GetHealthPercents() <= killOnHpBelowPerc )
			{
				if ( IsNameValid( setBehVarOnKill ) )
				{
					attacker.SetBehaviorVariable( setBehVarOnKill, behVarValue );
				}
				attacker.Kill( 'W3ReactToBeingHitEntity' );
			}
			else
			{
				action = new W3DamageAction in this;
				
				if ( debuffType != EET_Undefined )
				{
					params.effectType = debuffType;
					params.creator = this;
					params.sourceName = this.GetName();
					if ( debuffDuration > 0 )
					{
						params.duration = debuffDuration;
					}
					((CActor)attacker).AddEffectCustom(params);
				}
				
				action.attacker = this;
				action.Initialize( this, attacker, NULL, this.GetName(), EHRT_Light, CPS_Undefined, false, false, false, true );
				action.AddDamage( damageTypeName, damage );
				theGame.damageMgr.ProcessAction( action );
				if ( IsNameValid( effectOnHitVictim ) )
				{
					PlayEffectSingle( effectOnHitVictim );
				}
				delete action;
			}
		}
	}
	
	public function GetFocusActionName() : name
	{
		var focusComponent : CFocusActionComponent;
		focusComponent = (CFocusActionComponent)GetComponentByClassName( 'CFocusActionComponent' );
		if ( focusComponent )
		{
			return focusComponent.actionName;		
		}
		return '';
	}	
	
	public function CanShowFocusInteractionIcon() : bool
	{
		return true;
	}

	private function GetAreFistsEquipped() : bool
	{
		var i : int;
		var fistsIds : array<SItemUniqueId>;
		var inv : CInventoryComponent;
		
		inv = thePlayer.inv;
		fistsIds = inv.GetItemsByCategory('fist');
		
		for(i=0; i < fistsIds.Size(); i+=1)
		{
			if( inv.IsItemHeld(fistsIds[i]))
				return true;
		}
		
		return false;
	}
	
	public function ActivateEntity()
	{
		active = true;
		RemoveTimer( 'ActiveDuration' );
		
		if ( IsNameValid( effectOnActivation ) )
		{
			PlayEffect( effectOnActivation );
		}
		if ( IsNameValid( durationEffect ) )
		{
			PlayEffectSingle( durationEffect );
		}
		if ( activeDuration > 0 )
		{
			AddTimer( 'ActiveDuration', activeDuration, false );
		}
	}
	
	timer function ActiveDuration( td : float, id : int )
	{
		active = false;
		if ( IsNameValid( durationEffect ) )
		{
			StopEffect( durationEffect );
		}
	}
	
	
};