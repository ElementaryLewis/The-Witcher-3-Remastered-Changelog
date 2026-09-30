/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class W3ReplacerCiri extends W3Replacer
{
	private var isInitialized : bool;
	private var ciriPhantoms : array<W3CiriPhantom>;
	
	private var bloodExplode : CEntityTemplate;
	
		default explorationInputContext = 'Exploration_Replacer_Ciri';
		default combatInputContext = 'Combat_Replacer_Ciri';
		default isInitialized = false;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		
		if ( spawnData.restored && !inputHandler )
		{
			spawnData.restored = false;
		}
	
		super.OnSpawned( spawnData );
		
		
		RemoveNotNeededWeaponsFromInventory();
		
		
		BlockAction( EIAB_Signs, 'being_ciri' );
		BlockAction( EIAB_OpenInventory, 'being_ciri' );
		BlockAction( EIAB_OpenGwint, 'being_ciri' );
		BlockAction( EIAB_FastTravel, 'being_ciri' );
		BlockAction( EIAB_Fists, 'being_ciri' );
		BlockAction( EIAB_OpenMeditation, 'being_ciri' );
		BlockAction( EIAB_OpenCharacterPanel, 'being_ciri' );
		BlockAction( EIAB_OpenJournal, 'being_ciri' );
		BlockAction( EIAB_OpenAlchemy, 'being_ciri' );	
		BlockAction( EIAB_OpenGlossary, 'being_ciri' );	
		BlockAction( EIAB_CallHorse, 'being_ciri' );
		
		
		SetBehaviorVariable( 'test_ciri_replacer', 1.0f);
		
		this.DrainStamina(ESAT_FixedValue, 99.f);
		this.AddEffectDefault(EET_StaminaDrain, this, this.GetName());
		
		isInitialized = true;
		
		AddAnimEventCallback( 'ActionBlend', 	'OnAnimEvent_ActionBlend' );
		AddAnimEventCallback( 'fx_trail', 		'OnAnimEvent_fx_trail' );
		AddAnimEventCallback( 'rage', 			'OnAnimEvent_rage' );
		AddAnimEventCallback( 'SlideToTarget', 	'OnAnimEvent_SlideToTarget' );
		
		if ( !bloodExplode )
			bloodExplode = (CEntityTemplate)LoadResource('blood_explode');
		
		
		theGame.UpdateStatsForDifficultyLevel( MinDiffMode( theGame.GetDifficultyMode(), EDM_Medium ) );
		
		if ( spawnData.restored )
		{
			
			theGame.RemoveTimeScale( 'CiriSpecialAttackHeavy' );
			theGame.RemoveTimeScale( 'CiriPhantom' );
		}
		
		
		if ( !this.HasAbility( 'Ciri_CombatRegen' ) )
		{
			this.AddAbility( 'Ciri_CombatRegen' );
		}
		
		
		theGame.GameplayFactsRemove( "PlayerIsGeralt" );
	}
	
	public function IsInitialized() : bool
	{
		return isInitialized;
	}
	
	private function NewGamePlusInitialize()
	{
		var questItems : array<name>;
		var i : int;
		
		super.NewGamePlusInitialize();
		
		
		RemoveAbility('Ciri_Q205');
		RemoveAbility('Ciri_Q305');
		RemoveAbility('Ciri_Q403');
		RemoveAbility('Ciri_Q111');
		RemoveAbility('Ciri_Q501');
		RemoveAbility('Ciri_CombatRegen');
		RemoveAbility('Ciri_Rage');
		RemoveAbility('CiriBlink');
		RemoveAbility('CiriCharge');
		
		
		
		
		
		inv.RemoveItemByTag('Quest', -1);

		
		
		theGame.GetDefinitionsManager().GetItemsWithTag('Quest');
		for(i=0; i<questItems.Size(); i+=1)
		{
			inv.RemoveItemByName(questItems[i], -1);
		}
		
		
		RemoveAllNonAutoBuffs();
		
		
		inv.RemoveItemByCategory('usable', -1);
		
		
		RemoveAbility('StaminaTutorialProlog');
    	RemoveAbility('TutorialStaminaRegenHack');
    	RemoveAbility('area_novigrad');
    	RemoveAbility('NoRegenEffect');
    	RemoveAbility('HeavySwimmingStaminaDrain');
    	RemoveAbility('AirBoost');
    	RemoveAbility('area_nml');
    	RemoveAbility('area_skellige');
    	
    	newGamePlusInitialized = true;
	}
	
	
	public function ProcessCombatActionBuffer() : bool
	{
		var action	 			: EBufferActionType			= this.BufferCombatAction;
		var stage	 			: EButtonStage 				= this.BufferButtonStage;		
		var throwStage			: EThrowStage;		
		var actionResult : bool = true;
		
		
		
		if(super.ProcessCombatActionBuffer())
			return true;		
			
		switch ( action )
		{
			case EBAT_LightAttack :
			{
				switch ( stage )
				{
					case BS_Pressed :
					{
						DrainStamina(ESAT_LightAttack);
						if ( this.HasAbility('Ciri_Rage') )
							actionResult = this.OnPerformDashAttack();
						else
							actionResult = OnPerformAttack(theGame.params.ATTACK_NAME_LIGHT);
					} break;
					
					default :
					{
						actionResult = false;
					}break;
				}
			}break;
			
			case  EBAT_HeavyAttack :
			{
				switch ( stage )
				{
					case BS_Released :
					{
						DrainStamina(ESAT_HeavyAttack);
						if ( this.HasAbility('Ciri_Rage') )
							actionResult = this.OnPerformDashAttack();
						else
							actionResult = this.OnPerformAttack(theGame.params.ATTACK_NAME_LIGHT);
					} break;
					
					case BS_Pressed :
					{
						if ( this.GetCurrentStateName() == 'CombatFists' )
						{
							DrainStamina(ESAT_HeavyAttack);
							if ( this.HasAbility('Ciri_Rage') )
							actionResult = this.OnPerformDashAttack();
						else
							actionResult = this.OnPerformAttack(theGame.params.ATTACK_NAME_LIGHT);
						}
					} break;					
					
					default :
					{
						actionResult = false;
						
					} break;
				}
			} break;
			case EBAT_Ciri_SpecialAttack :
			{
				switch ( stage )
				{
					case BS_Pressed :
					{
						actionResult = this.OnPerformSpecialAttack( true );
					} break;
					
					case BS_Released :
					{
						actionResult = this.OnPerformSpecialAttack( false );
					} break;
					
					default :
					{
						actionResult = false;
					} break;
				}
			} break;
			case EBAT_Ciri_SpecialAttack_Heavy :
			{
				switch ( stage )
				{
					case BS_Pressed :
					{
						actionResult = this.OnPerformSpecialAttackHeavy( true );
					} break;
					
					case BS_Released :
					{
						actionResult = this.OnPerformSpecialAttackHeavy( false );
					} break;
					
					default :
					{
						actionResult = false;
					} break;
				}
			} break;
			case EBAT_Ciri_Counter :
			{
				switch ( stage )
				{
					case BS_Pressed :
					{
						actionResult = this.OnPerformSpecialAttack( true );
					} break;
					
					case BS_Released :
					{
						actionResult = this.OnPerformSpecialAttack( false );
					} break;
					
					default :
					{
						actionResult = false;
					} break;
				}
			} break;
			case EBAT_Ciri_Dodge :
			{
				switch ( stage )
				{
					case BS_Pressed :
					{
						actionResult = this.OnPerformDodge();
					} break;
					default :
					{
						actionResult = false;
					} break;
				}
			} break;
			
			case EBAT_Roll :
			{
				switch ( stage )
				{
					case BS_Released :
					{
						actionResult = this.OnPerformDash();
					} break;
					default :
					{
						actionResult = false;
					} break;
				}
			} break;
			
			default:
				return false;	
		}
		
		
		this.CleanCombatActionBuffer();
		
		if (actionResult)
		{
			SetCombatAction( action ) ;
		}
		
		return true;
	}
	
	public function AddPhantom( phantom : W3CiriPhantom )
	{
		ciriPhantoms.PushBack(phantom);
	}
	
	public function DestroyPhantoms()
	{
		var i : int;
		
		for ( i=0 ; i < ciriPhantoms.Size() ; i+=1 )
		{
			ciriPhantoms[i].DestroyAfter(0.8);
		}
		
		ciriPhantoms.Clear();
	}
	
	
	function GetCriticalHitChance( isLightAttack : bool, isHeavyAttack : bool, target : CActor, victimMonsterCategory : EMonsterCategory, isBolt : bool ) : float
	{
		var ret : float;
		
		ret = 0;
		if ( ciriPhantoms.Size() > 0 )
			ret = 1;
		
		ret += super.GetCriticalHitChance( isLightAttack, isHeavyAttack, target, victimMonsterCategory, isBolt );
		
		return ret;
	}
	
	function GetSelectedItemId() : SItemUniqueId
	{
		var items : array<SItemUniqueId>;
		
		if ( !GetInventory().IsIdValid(selectedItemId) )
		{
			items = GetInventory().GetItemsByName('q403_ciri_meteor');
			
			if ( items.Size() > 0 )
				selectedItemId = items[0];
		}
			
		return super.GetSelectedItemId();
	}
	
	private function GoToCombat( weaponType : EPlayerWeapon, optional initialAction : EInitialAction )
	{			
		((W3PlayerWitcherStateCombatSteel) GetState('CombatSteel')).SetupState( initialAction );
		GoToStateIfNew( 'CombatSteel' );
	}
	
	private function RemoveNotNeededWeaponsFromInventory()
	{
		var i : int;
		var quantity : int;
		var inv : CInventoryComponent;
		var weapons : array<SItemUniqueId>;
		
		inv = GetInventory();
		
		weapons = inv.GetItemsByCategory('steelsword');
		
		for ( i=weapons.Size()-1 ; i >=0 ; i-=1 )
		{
			if ( inv.GetItemName( weapons[i] ) != theGame.params.CIRI_SWORD_NAME )
			{
				quantity = inv.GetItemQuantity(weapons[i]);
				inv.RemoveItem(weapons[i],quantity);
			}
		}
		
	}
	
	 event OnProcessActionPost(action : W3DamageAction)
	{
		var attackAction : W3Action_Attack;
		
		super.OnProcessActionPost(action);
		
		attackAction = (W3Action_Attack)action;
		
		
		if(attackAction && attackAction.IsActionMelee() && action.DealsAnyDamage())
		{
			GainResource();
		}
	}
	
	public function DisplayCannotAttackMessage( actor : CActor ) : bool
	{
		DisplayHudMessage(GetLocStringByKeyExt("panel_hud_message_cant_attack_this_target"));
		return true;
	}
	
	
	
	
	
	event OnPerformSpecialAttack( enableAttack : bool ){}
	event OnPerformSpecialAttackHeavy( enableAttack : bool ){}
	event OnPerformCounter(){}
	event OnPerformDodge(){}
	event OnPerformDash(){}
	event OnPerformDashAttack(){}
	
	
	
	
	event OnAnimEvent_ActionBlend( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventType == AET_DurationStart )
		{	
			if ( theInput.IsActionPressed('CiriSpecialAttack') && HasAbility('CiriBlink') && HasStaminaForSpecialAction(true) )
				thePlayer.PushCombatActionOnBuffer( EBAT_Ciri_SpecialAttack, BS_Pressed );
			else if ( theInput.IsActionPressed('CiriSpecialAttackHeavy') && HasAbility('CiriCharge') && HasStaminaForSpecialAction(true) )
				thePlayer.PushCombatActionOnBuffer( EBAT_Ciri_SpecialAttack_Heavy, BS_Pressed );
				
			SetCanPlayHitAnim( true );
			if (this.BufferCombatAction != EBAT_EMPTY )
			{
				this.ProcessCombatActionBuffer();
			}
			else
			{
				this.SetBIsCombatActionAllowed( true );
			}
		}
	}
	
	event OnAnimEvent_fx_trail( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( HasAbility('Ciri_Rage') )
		{
			this.PlayEffectOnHeldWeapon('fury_trail');
		}
		else
		{
			this.PlayEffectOnHeldWeapon('light_trail_fx');
		}
	}
	
	
	event OnAnimEvent_rage( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( HasAbility('Ciri_Rage') )
			this.PlayEffect('rage');
	}
	
	event OnAnimEvent_SlideToTarget( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var movementAdjustor	: CMovementAdjustor;
		var ticket 				: SMovementAdjustmentRequestTicket;
		var minDistance			: float;
		
		if( !HasAbility('Ciri_Rage') )
			return false;
		
		if ( animEventType == AET_DurationStart )
			slideNPC = (CNewNPC)slideTarget;
		
		if ( !slideNPC )
			return false;
		
		if ( VecDistanceSquared(this.GetWorldPosition(),slideNPC.GetWorldPosition()) > 12*12 )
			return false;
		
		if ( animEventType == AET_DurationStart && slideNPC.GetGameplayVisibility() )
		{
			movementAdjustor = GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelAll();
			slideTicket = movementAdjustor.CreateNewRequest( 'SlideToTarget' );
			movementAdjustor.BindToEventAnimInfo( slideTicket, animInfo );
			
			movementAdjustor.ScaleAnimation( slideTicket );
			minSlideDistance = this.GetRadius() + slideNPC.GetRadius() + 0.01f;
			movementAdjustor.SlideTowards( slideTicket, slideNPC, minSlideDistance, minSlideDistance );					
		}
		else if ( !slideNPC.GetGameplayVisibility() )
		{
			movementAdjustor = GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelByName( 'SlideToTarget' );
			slideNPC = NULL;
		}
		else 
		{
			movementAdjustor = GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.SlideTowards( slideTicket, slideNPC, minSlideDistance, minSlideDistance );				
		}
	}
	
	event OnSpecialActionHeavyEnd()
	{
		theInput.ForceDeactivateAction('CiriSpecialAttackHeavy');
		theInput.ForceDeactivateAction('SpecialAttackWithAlternateLight');
		theInput.ForceDeactivateAction('SpecialAttackWithAlternateHeavy');
	}
	
	event OnCombatActionEnd()
	{
		super.OnCombatActionEnd();
		EnableSpecialAttackHeavyCollsion(false);
	}
	
	event OnCombatStart()
	{
		super.OnCombatStart();
		
		
		this.RemoveAllBuffsOfType(EET_StaminaDrain);
		this.AddEffectDefault(EET_AutoStaminaRegen, this, this.GetName());
		
		thePlayer.SetBehaviorVariable( 'playerWeapon', (int) PW_Steel );
		thePlayer.SetBehaviorVariable( 'playerWeaponForOverlay', (int) PW_Steel );
	}
	
	event OnCombatFinished()
	{
		super.OnCombatFinished();
		
		this.RemoveAllBuffsOfType(EET_AutoStaminaRegen);
		this.AddEffectDefault(EET_StaminaDrain, this, this.GetName());
		
		if ( !HasAbility('Ciri_Rage') )
		{
			AddTimer( 'DelayedSheathSword', 2.f );
		}
	}
	
	event OnAbilityAdded( abilityName : name )
	{
		super.OnAbilityAdded(abilityName);
		if ( abilityName == 'Ciri_Rage' )
		{
			EnableRageEffect(true);
			this.PauseEffects(EET_StaminaDrain, 'CiriRage', true );
		}
	}
	
	event OnAbilityRemoved( abilityName : name )
	{
		super.OnAbilityRemoved( abilityName );
		if ( abilityName == 'Ciri_Rage' )
		{
			EnableRageEffect(false);
			this.ResumeEffects(EET_StaminaDrain, 'CiriRage' );
		}
	}
	
	public function ToggleRageEffect( toggle : bool )
	{
		if ( toggle && HasAbility('Ciri_Rage') )
		{
			EnableRageEffect(true);
		}
		else if ( !toggle )
		{
			EnableRageEffect(false);
		}
	}
	
	private var rageEffectEnabled : bool;
	
	private function EnableRageEffect( enable : bool )
	{
		if ( enable && !rageEffectEnabled )
		{
			PlayEffect('fury');
			PlayRageEffectOnWeapon('fury_sword_fx');
			rageEffectEnabled = true;
		}
		else if ( !enable && rageEffectEnabled )
		{
			StopEffect('fury');
			PlayRageEffectOnWeapon('fury_sword_fx',true);
			rageEffectEnabled = false;
		}
	}
	
	function PlayRageEffectOnWeapon( effectName : name, optional disable : bool ) : bool
	{
		var itemId : SItemUniqueId;
		var inv : CInventoryComponent;
		
		inv = GetInventory();		
		itemId = inv.GetItemFromSlot('r_weapon');
		
		if ( !inv.IsIdValid(itemId) )
		{
			itemId = inv.GetItemFromSlot('l_weapon');
			
			if ( !inv.IsIdValid(itemId) )
			{
				itemId = inv.GetItemFromSlot('steel_sword_back_slot');
				if ( !inv.IsIdValid(itemId) )
					return false;
			}
		}
		if ( disable )
			inv.StopItemEffect(itemId,effectName);
		else
			inv.PlayItemEffect(itemId,effectName);
		
		return true;
	}
	
	
	
	
	
	protected function ShouldDrainStaminaWhileSprinting() : bool
	{
		return false;
	}
	
	protected function ShouldUseStaminaWhileSprinting() : bool
	{
		return false;
	}

	public function GainResource()
	{
		
		if(!HasAbility('CiriBlink') && !HasAbility('CiriCharge'))
			return;
		
		if ( !IsInCombatAction_SpecialAttack() || HasAbility('Ciri_Rage')  )
		{
			GainStat(BCS_Stamina,GetStatMax(BCS_Stamina)/5);
			
			if(ShouldProcessTutorial('TutorialCiriStamina'))
			{
				FactsAdd("tut_ciri_stamina", 1, 1);
			}
		}
	}
	
	public function DrainResourceForSpecialAttack()
	{
		DrainStamina(ESAT_FixedValue, 100.f);
	}
	
	public function DrainResourceForDodge()
	{
		DrainStamina(ESAT_FixedValue, GetStatMax(BCS_Stamina)/10);
	}
	
	public function DrainResourceForDash()
	{
		DrainStamina(ESAT_FixedValue, GetStatMax(BCS_Stamina)/5);
	}
	
	public function HasStaminaForDash( optional dontPlaySound : bool ) : bool
	{
		var res : bool;
		
		if ( HasAbility('Ciri_Rage') )
			return true;
		
		res = GetStatPercents( BCS_Stamina ) >= (GetStatMax(BCS_Stamina)/5)*0.01;
		
		if ( !res && !dontPlaySound )
		{
			SetShowToLowStaminaIndication(GetStatMax(BCS_Stamina));
			SoundEvent( "gui_ingame_low_stamina_warning" );
		}
		
		return res;
	}
	
	public function HasStaminaForSpecialAction( optional dontPlaySound : bool ) : bool
	{
		var res : bool;
		
		if ( HasAbility('Ciri_Rage') )
			return true;
		
		res = GetStatPercents( BCS_Stamina ) >= 1.f;
		
		if ( !res && !dontPlaySound )
		{
			SetShowToLowStaminaIndication(GetStatMax(BCS_Stamina));
			SoundEvent( "gui_ingame_low_stamina_warning" );
		}
		
		return res;
	}
	
	public function HasStaminaToParry( attActionName : name ) : bool
	{
		return true;
	}
	
	public function SmartSetVisible( toggle : bool )
	{
		MakeInvulnerable(!toggle);
	}
	
	public function MakeInvulnerable( toggle : bool )
	{
		if ( toggle )
		{
			SetImmortalityMode(AIM_Invulnerable, AIC_Combat);
			SetCanPlayHitAnim(false);
			EnableCharacterCollisions(false);
			AddBuffImmunity_AllNegative('CiriMakeInvulnerable', true);
		}
		else
		{
			SetImmortalityMode(AIM_None, AIC_Combat);
			SetCanPlayHitAnim(true);
			EnableCharacterCollisions(true);
			RemoveBuffImmunity_AllNegative('CiriMakeInvulnerable');
		}
	}
	
	private var tempIsCollisionDisabled : bool;		default tempIsCollisionDisabled = true;
	
	public function EnableSpecialAttackHeavyCollsion( enable : bool )
	{
		var collision : CComponent;
		collision = this.GetComponent("SpecialAttackHeavyHitBox");
		
		if ( collision )
			collision.SetEnabled(enable);
		
		tempIsCollisionDisabled = !enable;
		
		if ( !enable)
			collidedEnemies.Clear();
	}
	
	public function IsInCombatAction_SpecialAttack() : bool
	{
		if ( IsInCombatAction() && ( GetCombatAction() == EBAT_Ciri_SpecialAttack || GetCombatAction() == EBAT_Ciri_SpecialAttack_Heavy ) )
			return true;
		else
			return false;
	}
	
	public final function GetMostConvenientMeleeWeapon( targetToDrawAgainst : CActor, optional ignoreActionLock : bool ) : EPlayerWeapon
	{
		if ( !targetToDrawAgainst )
			return PW_None;
		
		return PW_Steel;
	}
	
	protected function PerformCounterCheck(parryInfo: SParryInfo) : bool
	{
		return false;
	}
	
	private var collidedEnemies : array<CActor>;
	
	event OnSpecialAttackHeavyCollision( object : CObject, physicalActorindex : int, shapeIndex : int  )
	{
		var collidedActor 		: CActor;
		var action 				: W3Action_Attack;
		var dismembermentComp 	: CDismembermentComponent;
		var wounds				: array< name >;
		var usedWound			: name;
		var component 			: CComponent;
		var bloodEntity			: CEntity;
		var position			: Vector;
		
		component = (CComponent) object;
		
		if( !component || tempIsCollisionDisabled )
		{
			return false;
		}
		
		collidedActor = (CActor)(component.GetEntity());
		
		if ( collidedActor == this || !collidedActor.IsAlive() || GetAttitudeBetween( this, collidedActor ) != AIA_Hostile )
			return true;
		
		if ( collidedActor && !collidedEnemies.Contains(collidedActor) )
		{
			
			action = new W3Action_Attack in this;
			action.Init((CGameplayEntity)this,collidedActor,NULL,this.GetInventory().GetItemFromSlot( 'r_weapon' ),'attack_heavy',this.GetName(),EHRT_Heavy, false, false, 'attack_heavy', AST_Jab, ASD_NotSet, true, false, false, false );
			action.SetCriticalHit();
			action.SetForceExplosionDismemberment();
			action.AddEffectInfo(EET_Knockdown);
			action.SetProcessBuffsIfNoDamage(true);
			
			theGame.damageMgr.ProcessAction( action );
			
			delete action;	
			
			position = collidedActor.GetWorldPosition();
			position.Z += 0.7;
			bloodEntity = theGame.CreateEntity(bloodExplode,position);
			bloodEntity.PlayEffect('blood_explode');
			bloodEntity.DestroyAfter(5.0);
			collidedEnemies.PushBack(collidedActor);
			AddTimer('SlowMoStart', 0.1f );
		}
	}
	
	private var slidingToNewPosition : bool;
	private var cameraDesiredHeading : Vector;
	
	private timer function SlowMoStart( dt : float, id : int )
	{
		theGame.SetTimeScale( 0.1f, 'CiriSpecialAttackHeavy', 500, true, true );
		AddTimer('SlowMoEnd', 0.05f );
	}
	
	private timer function SlowMoEnd( dt : float, id : int )
	{
		theGame.RemoveTimeScale( 'CiriSpecialAttackHeavy' );
	}
	
	function OnSlideToNewPositionStart( duration : float, newPos : Vector, optional newHeading : Vector  )
	{
		if ( IsInCombatAction_SpecialAttack() && newHeading != Vector(0,0,0) )
		{
			
			cameraDesiredHeading = newHeading;
			slidingToNewPosition = true;
			AddTimer('SlideToNewPositionEnd',duration,false);
			theGame.GetGameCamera().ForceManualControlVerTimeout();
			theGame.GetGameCamera().ForceManualControlHorTimeout();
		}
	}
	
	private timer function SlideToNewPositionEnd( dt : float , id : int)
	{
		slidingToNewPosition = false;
	}
	
	protected function UpdateCameraForSpecialAttack( out moveData : SCameraMovementData, timeDelta : float ) : bool
	{
		if ( specialAttackCamera )
		{
			
		}
		else if ( slidingToNewPosition )
		{
			moveData.pivotRotationController.SetDesiredHeading( VecHeading(cameraDesiredHeading),5 );
			return true;
		}
		
		return false;
	}
	
	
	
	
	protected function SpecialHeavyAttackCamera( out moveData : SCameraMovementData, timeDelta : float ) 
	{
		theGame.GetGameCamera().ForceManualControlHorTimeout();
		theGame.GetGameCamera().ForceManualControlVerTimeout();	
		
		moveData.pivotRotationController.SetDesiredHeading( VecHeading(cameraDesiredHeading), 2.f );
	}
	
	public function SetAttackData( data : CPreAttackEventData )
	{
		if ( HasAbility('Ciri_Rage') )
		{
			data.canBeDodged = false;
			data.Can_Parry_Attack = false;
			data.hitFX = 'hit_ciri_power';
			data.hitBackFX = 'hit_ciri_power'; 
		}
		super.SetAttackData( data );
	}
	
	function ReduceDamage(out damageData : W3DamageAction)
	{
		var actorAttacker : CActor;
		var quen : W3QuenEntity;
		
		super.ReduceDamage(damageData);
		
		
		if(!damageData.DealsAnyDamage())
			return;
		
		actorAttacker = (CActor)damageData.attacker;
		
		
		if(actorAttacker)
		{			
			if(IsCurrentlyDodging() && damageData.CanBeDodged())
			{
				
				
				if(	( AbsF(AngleDistance(evadeHeading, actorAttacker.GetHeading())) < 150 ) )
				{
					if ( theGame.CanLog() )
					{
						LogDMHits("W3ReplacerCiri.ReduceDamage: Attack dodged by Ciri - no damage done", damageData);
					}
					damageData.SetAllProcessedDamageAs(0);
					damageData.SetWasDodged();
					GainResource();
				}
			}
		}
	}
	
		
	
	
	
	
	
	
	
	public function GetEquippedSword(steel : bool) : SItemUniqueId
	{
		var ids : array<SItemUniqueId>;
		var i : int;
		
		ids = inv.GetWeapons();
		for(i=0; i<ids.Size(); i+=1)
		{
			if(!inv.IsItemMounted(ids[i]) && !inv.IsItemHeld(ids[i]))
				continue;
				
			if(steel && inv.IsItemSteelSwordUsableByPlayer(ids[i]))
			{
				return ids[i];
			}
			else if(!steel && inv.IsItemSilverSwordUsableByPlayer(ids[i]))
			{
				return ids[i];
			}
		}
		
		return GetInvalidUniqueId();
	}
	
	
	public final function HasSword() : bool
	{
		if(inv.IsIdValid( GetEquippedSword(true) ))
			return true;
			
		return inv.IsIdValid(inv.GetItemFromSlot('r_weapon'));
	}
	
	public function CanApplyOilOnItem(oilId : SItemUniqueId, usedOnItem : SItemUniqueId) : bool
	{
		if(inv.IsItemSteelSwordUsableByPlayer(usedOnItem) || inv.IsItemSilverSwordUsableByPlayer(usedOnItem))
			return true;
			
		return false;
	}
}

function GetCiriPlayer() : W3ReplacerCiri
{
	return (W3ReplacerCiri)thePlayer;
}