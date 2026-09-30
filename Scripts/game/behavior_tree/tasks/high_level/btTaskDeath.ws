/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBehTreeTaskFlyingMonsterDeath extends IBehTreeTask
{
	var 	wasFlying : bool;
	var		forceDeath : bool;
	var 	onGround : bool;
	
	default wasFlying 	= false;
	default onGround 	= false;
	
	 
	function OnActivate() : EBTNodeStatus
	{
		var owner : CNewNPC = GetNPC();
		
		if ( owner.GetCurrentStance() == NS_Fly || owner.GetCurrentStance() == NS_Swim )
		{
			owner.SetBehaviorVariable( 'GroundContact', 0.0 );
			owner.EnablePhysicalMovement( true ); 
			((CMovingPhysicalAgentComponent)owner.GetComponentByClassName('CMovingPhysicalAgentComponent')).SetAnimatedMovement( true );
			wasFlying = true;
		}
		return BTNS_Active;
	}

	latent function Main() : EBTNodeStatus
	{
		var owner 				: CNewNPC = GetNPC();
		var groundPos, normal	: Vector;
		
		owner.AddTimer( 'ForceDeathTimer', 3.0, false, , , true );		
		
		while ( wasFlying )
		{
			if (  owner.IsOnGround() ||  forceDeath || theGame.GetWorld().StaticTrace ( owner.GetWorldPosition(), owner.GetWorldPosition() - Vector( 0,0,0.15f), groundPos, normal ) )
			{
				OnGroundContact();
				break;
			}
			SleepOneFrame();
		}
		
		return BTNS_Active;
	}
	
	function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		if ( eventName == 'OnDeath' )
		{
			return true;
		}
		return false;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var owner : CActor = GetActor();
		
		if( animEventName == 'OnGround' )
		{
			onGround = true;
			return true;
		}
		return false;
	}	
	
	timer function ForceDeathTimer( t : float , id : int)
	{
		forceDeath = true;
	}
	
	function OnGroundContact()
	{
		var owner 	: CNewNPC = GetNPC();
		var mac 	: CMovingPhysicalAgentComponent;
		owner.SetBehaviorVariable( 'GroundContact', 1.0 );		
		
		mac = ((CMovingPhysicalAgentComponent)owner.GetMovingAgentComponent());
		mac.SetAnimatedMovement( false );
		owner.EnablePhysicalMovement( false );
	}
};

class CBehTreeTaskFlyingMonsterDeathDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskFlyingMonsterDeath';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'OnDeath' );
		listenToGameplayEvents.PushBack( 'OnGround' );
	}
}



class CBehTreeCondChooseUnconscious extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		if ( GetActor().WillBeUnconscious() )
		{
			return true;
		}
		return false;		
	}
};


class CBehTreeCondChooseUnconsciousDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBehTreeCondChooseUnconscious';
};



class CBehTreeCondWasDefeatedFromFistFight extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		return GetActor().WasDefeatedFromFistFight();	
	}
};


class CBehTreeCondWasDefeatedFromFistFightDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBehTreeCondWasDefeatedFromFistFight';
};



class CBehTreeTaskDeathState extends IBehTreeTask
{
	var destroyAfterAnimDelay 			: float;
	var	destroyAnimEvent 				: bool;
	var fxName			 				: name;
	var setAppearanceTo 				: name;
	var createReactionEvent				: name;
	var changeAppearanceAfter 			: float;
	var saveLockID						: int;
	var dropWeapons						: bool;
	
	private var deadDestructSquaredDist : float; 
	
	default deadDestructSquaredDist 	= 0;
	default destroyAnimEvent 			= false;
	
	default saveLockID = -1;
	
	function OnActivate() : EBTNodeStatus
	{
		var owner : CNewNPC = GetNPC();
		var i : int;
		
		
		if( owner.isDead )
		{
			owner.DestroyAfter(0);
			return BTNS_Active;
		}
		
		SetCombatTarget(NULL);
		owner.SignalGameplayEvent( 'Death' );
		owner.SignalGameplayEventParamInt( 'RidingManagerDismountHorse', DT_ragdoll );
		
		if( owner.GetMovingAgentComponent().GetName() == "woman_base" )
		{
			owner.DisableAgony();
		}		
		
		owner.SetAlive(false);
		owner.DisableLookAt();
		
		if ( owner.GetComponent('talk') )
			owner.GetComponent('talk').SetEnabled(false);
		
		if( IsNameValid( createReactionEvent ) )
		{
			theGame.GetBehTreeReactionManager().CreateReactionEvent( owner, createReactionEvent, 1.0f, 20.0f, -1.0f, -1 );
		}
		
		
		owner.ReportDeathToSpawnSystems();
		
		
		ChangeHeldItemAppearance();
		
		theGame.CreateNoSaveLock("dudeIsDying",saveLockID);
		owner.SignalGameplayEventParamInt('DyingSaveLockID', saveLockID);
		
		return BTNS_Active;
	}
	
	function ChangeHeldItemAppearance()
	{
		var inv : CInventoryComponent;
		var weapon : SItemUniqueId;
		var heldItemsNames : array<name>;
		
		inv = GetNPC().GetInventory();
		
		inv.GetAllHeldItemsNames( heldItemsNames );
		
		if( heldItemsNames.Contains( 'fists_lightning' ) || heldItemsNames.Contains( 'fists_fire' ) )
		{
			GetNPC().StopEffect( 'hand_fx' );
		}
		
		weapon = inv.GetItemFromSlot('l_weapon');
		
		if ( inv.IsIdValid( weapon ) )
		{
			if ( inv.ItemHasTag(weapon,'bow') || inv.ItemHasTag(weapon,'crossbow') )
				inv.GetItemEntityUnsafe(weapon).ApplyAppearance("rigid");
			return;
		}
		
		weapon = inv.GetItemFromSlot('r_weapon');
		
		if ( inv.IsIdValid( weapon ) )
		{
			if ( inv.ItemHasTag(weapon,'bow') || inv.ItemHasTag(weapon,'crossbow') )
				inv.GetItemEntityUnsafe(weapon).ApplyAppearance("rigid");
			return;
		}
	}
	
	latent function Main() : EBTNodeStatus
	{
		var owner 					: CNewNPC = GetNPC();
		var forceDestructionCounter : int = 300;
		var summonerCmp 			: W3SummonerComponent;
		var summonedEntityCmp 		: W3SummonedEntityComponent;
		
		if ( dropWeapons )
		{
			SleepOneFrame();
			owner.DropItemFromSlot( 'l_weapon', true );
			owner.DropItemFromSlot( 'r_weapon', true );
		}
		
		if( IsNameValid( fxName ) ) 
		{
			owner.PlayEffect( fxName );
		}	
		
		summonerCmp = (W3SummonerComponent) GetNPC().GetComponentByClassName( 'W3SummonerComponent' );
		if( summonerCmp )
		{
			summonerCmp.OnDeath();
		}
		summonedEntityCmp = (W3SummonedEntityComponent) GetNPC().GetComponentByClassName( 'W3SummonedEntityComponent' );
		if( summonedEntityCmp )
		{
			summonedEntityCmp.OnDeath();
		}
		
		if ( IsNameValid( setAppearanceTo ))
		{
			if ( changeAppearanceAfter > 0 )
			{
				Sleep( changeAppearanceAfter );
				owner.SetAppearance( setAppearanceTo );
			}
			else
			{
				owner.SetAppearance( setAppearanceTo );
			}
		}
		
		if ( destroyAfterAnimDelay > 0 )
		{
			
			owner.RemoveAllBuffsOfType(EET_Burning);
			owner.DestroyAfter( destroyAfterAnimDelay ); 
		}
		else
		{
			deadDestructSquaredDist = 100.f * 100.f;
 			while( CanBeDesctructed() == false && forceDestructionCounter > 0 )
			{
				Sleep( 1.0f );
				forceDestructionCounter = forceDestructionCounter - 1;
			}
			owner.Destroy();
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( saveLockID != -1 )
			theGame.ReleaseNoSaveLock(saveLockID);
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var damageAction 	: CDamageData;
		var owner 			: CNewNPC;

		if ( animEventName == 'Destroy' )
		{
			destroyAnimEvent = true;
			return true;
		}
		return false;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var damageAction : CDamageData;
		
		if( eventName == 'OnDeath' )
		{
			damageAction = (CDamageData)GetEventParamObject();
			if( damageAction )
			{
				if( damageAction.attacker )
				{
					ChooseDeathAnim( damageAction.attacker, damageAction.causer );
					GetNPC().SetHitReactionDirection( damageAction.attacker );
				}
				
				return true;
			}
		}
		else if( eventName == 'DropWeaponsInDeathTask')
		{
			dropWeapons = true;
		}
		
		return false;
	}
	
	function ChooseDeathAnim( attacker : CGameplayEntity, optional damageCauser : IScriptable )
	{
		var npc	: CNewNPC;
		
		npc = GetNPC();

		if( damageCauser && ( (W3IgniProjectile)damageCauser || (W3Effect_Burning)damageCauser  ) )
		{
			npc.SetBehaviorVariable( 'DeathType',(int)EDT_IgniDeath );
			npc.DisableAgony();
		}
		else if( damageCauser && (W3AardProjectile)damageCauser )
		{
			npc.SetBehaviorVariable( 'DeathType',(int)EDT_AardDeath );
			npc.DisableAgony();
		}
		else
		{
			npc.SetBehaviorVariable( 'DeathType',(int)EDT_Default );
		}
	}
	
	public function CanBeDesctructed() : bool
	{
		if ( deadDestructSquaredDist > 0 )
		{
			if ( VecDistanceSquared( thePlayer.GetWorldPosition(), GetNPC().GetWorldPosition() ) < deadDestructSquaredDist )
			{
				return false;
			}
		}
		
		
		return true;
	}
};

class CBehTreeTaskDeathStateDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskDeathState';

	editable var destroyAfterAnimDelay : CBehTreeValFloat;
	editable var fxName : CBehTreeValCName;
	editable var setAppearanceTo : CBehTreeValCName;
	editable var changeAppearanceAfter : CBehTreeValFloat;
	editable var createReactionEvent : CBehTreeValCName;
	
	default changeAppearanceAfter = 0;
	
	public function Initialize()
	{
		SetValCName(fxName,'death');
		SetValCName(setAppearanceTo,'');
		SetValFloat(changeAppearanceAfter,0);
		SetValCName(createReactionEvent,'NPCDeath');
		super.Initialize();
	}
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'OnDeath' );
		listenToGameplayEvents.PushBack( 'DropWeaponsInDeathTask' );
	}
}





class CBehTreeTaskDeathIdle extends IBehTreeTask
{
	public var setAppearanceTo 			: name;
	public var changeAppearanceAfter 	: float;
	public var disableRagdollAfter 		: float;
	public var disableCollision 		: bool;
	public var disableCollisionDelay 	: float;
	public var tag						: array<name>;
	
	private var timeStamp 				: float;
	
	function OnActivate() : EBTNodeStatus
	{
		var actor: CActor = GetActor();
		SetCombatTarget(NULL);
		thePlayer.AddToFinishableEnemyList( GetNPC(), false );
		
		actor.EnableFinishComponent( false );
		actor.RaiseForceEvent('FinisherDeath');
		
		timeStamp = GetLocalTime();
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var owner : CNewNPC = GetNPC();
		
		while ( true )
		{
			if ( IsNameValid( setAppearanceTo ) && GetLocalTime() > timeStamp + changeAppearanceAfter )
			{
				owner.SetAppearance( setAppearanceTo );
				setAppearanceTo = '';
			}
			if ( disableRagdollAfter > 0 && GetLocalTime() > timeStamp + disableRagdollAfter  )
			{
				owner.GetRootAnimatedComponent().SetEnabled( false );
				disableRagdollAfter = 0;
			}
			if ( disableCollision && GetLocalTime() > timeStamp + disableCollisionDelay )
			{
				owner.EnableCharacterCollisions( false );
				disableCollision = false;
			}
			
			SleepOneFrame();
		}
		return BTNS_Active;
	}
};

class CBehTreeTaskDeathIdleDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskDeathIdle';

	editable var setAppearanceTo 		: CBehTreeValCName;
	editable var changeAppearanceAfter 	: CBehTreeValFloat;
	editable var disableCollision 		: CBehTreeValBool;
	editable var disableCollisionDelay 	: CBehTreeValFloat;
	editable var disableRagdollAfter 	: CBehTreeValFloat;
	
	default changeAppearanceAfter 		= 0;
	default disableCollision 			= true;
	default disableCollisionDelay 		= 1.0;
	default disableRagdollAfter 		= 5.0;
	
};



class CBTTaskDropLoot extends IBehTreeTask
{
	public var onActivate 		: bool;
	public var delay 			: float;
	
	private var lootDropped 	: bool;			
	private var attacker 		: CGameplayEntity;
	private var causer 			: IScriptable;
	private var saveLockID 		: int;
	
	default lootDropped 		= false;
	default saveLockID 			= -1;
	
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		if ( onActivate )
		{
			if ( false == npc.isDead ) 
			{
				LootDrop();
				if ( !npc.HasAbility( 'DontAddFactsOnDeath' ) )
				{
					AddWasKilledFacts();
				}
			}
			RemoveSaveLock();
		}		
		
		npc.isDead = true;
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		if ( !onActivate && delay > 0 )
		{
			Sleep( delay );
			LootDrop();
			if ( !GetActor().HasAbility( 'DontAddFactsOnDeath' ) )
			{
				AddWasKilledFacts();
			}
			RemoveSaveLock();
		}
		return BTNS_Active;
	}
	
	function LootDrop()
	{
		var owner 				: CNewNPC = GetNPC();
		var tags 				: array< name >;
		var inventory 			: CInventoryComponent;
		var lootEntity 			: CEntity;
		var lootContainer 		: W3Container;
		var i 					: int;
		var loot 				: W3ActorRemains;
		var commonMapManager 	: CCommonMapManager;
		var lootPos				: Vector;
		var l_pos 				: Vector;
		var l_groundZ			: float;
		var waterLevel 			: float;
		var submersionLevel 	: float;
		var world				: CWorld;
		
		
		if ( lootDropped || owner.clearInvOnDeath || owner.isDead )
		{
			return;
		}
		
		world = theGame.GetWorld();
		l_pos = owner.GetWorldPosition();
		waterLevel = world.GetWaterLevel ( l_pos, true );
		
		submersionLevel = waterLevel - l_pos.Z;
		
		
		if( submersionLevel >= 1 )
			return;
		
		lootDropped = true;		
		
		inventory = owner.GetInventory();
		inventory.UpdateLoot();
		lootEntity = inventory.ThrowAwayLootableItems( true );
		
		loot = (W3ActorRemains)lootEntity;
		if ( lootEntity && loot )
		{
			if ( loot.HasQuestItem() )
			{
				commonMapManager = theGame.GetCommonMapManager();
				commonMapManager.AddQuestLootContainer( loot );
				loot.LootDropped(owner);
			}
			else
			{
				loot.LootDropped(owner);
			}
			
			
			if ( owner.RemainsTags.Size() > 0 )
			{
				tags = loot.GetTags();	
				for ( i = 0; i < owner.RemainsTags.Size(); i+=1 )
				{
					tags.PushBack( owner.RemainsTags[i] );					
				}
				loot.SetTags( tags );
			}
			
			
			lootPos = owner.GetWorldPosition();
			
			if( !world.NavigationFindSafeSpot( lootPos, 0.45, 10, lootPos ) )
			{
				if ( world.NavigationComputeZ( lootPos, lootPos.Z - 128.0, lootPos.Z + 1.0, l_groundZ ) )
				{
					lootPos.Z = l_groundZ;
					
					world.NavigationFindSafeSpot( lootPos, 0.45, 10, lootPos );
				}
			}
			
			if ( world.PhysicsCorrectZ( lootPos, l_groundZ ) )
			{
				lootPos.Z = l_groundZ;
			}
			
			loot.Teleport( lootPos );
		}
	}
	
	function RemoveSaveLock()
	{
		if ( saveLockID != -1 )
			theGame.ReleaseNoSaveLock(saveLockID);
	}
	
	function AddWasKilledFacts()
	{
		var tags : array<name>;
		var attackerTags : array<name>;
		
		attackerTags = attacker.GetTags();
		tags = GetNPC().GetTags();
		AddHitFacts( tags, attackerTags, "_was_killed", true, "actor_" );	
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var damageAction : CDamageData;
		
		if ( eventName == 'OnDeath' )
		{
			damageAction 	= (CDamageData)GetEventParamObject();
			attacker 		= damageAction.attacker;
			causer 			= damageAction.causer;
		}
		else if ( eventName == 'DyingSaveLockID' )
		{
			saveLockID = GetEventParamInt(-1);
		}
		
		return false;
	}
	
}

class CBTTaskDropLootDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDropLoot';

	editable var onActivate 		: bool;
	editable var delay 				: float;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'DyingSaveLockID' );
		listenToGameplayEvents.PushBack( 'OnDeath' );
	}
}



class CBehTreeHLTaskUnconscious extends IBehTreeTask
{
	private var syncInstance	: CAnimationManualSlotSyncInstance;
	private var finisherEnabled : bool;
	
	function OnActivate() : EBTNodeStatus
	{
		var i : int;
		var tags : array<name>;
		
		tags = GetActor().GetTags();
		for(i=0; i<tags.Size(); i+=1)
		{
			FactsAdd("actor_"+NameToString(tags[i])+"_was_knocked_unconscious");
		}
		GetActor().EnterKnockedUnconscious();
		GetActor().EnableCharacterCollisions(false);
		GetActor().DisableLookAt();
		GetActor().SetAlive(false);
		GetActor().SignalGameplayEvent('GuardUnconsciousAction');
		return BTNS_Active;
	}
	function OnDeactivate()
	{
		GetActor().EndKnockedUnconscious();
		GetActor().EnableCharacterCollisions(true);
		
		if( GetActor().GetBehaviorVariable( 'unconsciousFinisher' ) == 1.0 )
		{
			GetActor().SetBehaviorVariable( 'unconsciousFinisher', 0.0 );
			GetNPC().FinisherAnimInterrupted();
			GetNPC().ResetFinisherAnimInterruptionState();
		}
	}
	
	function OnGameplayEvent( eventName : CName ) : bool
	{
		if ( eventName == 'OnDeath' )
		{
			if ( !GetActor().WillBeUnconscious() )
				Complete(true);
			return true;
		}
		else if ( eventName == 'Finisher' )
		{
			GetActor().EnableFinishComponent( false );
			thePlayer.AddToFinishableEnemyList( GetActor(), false );
			theGame.GetSyncAnimManager().SetupSimpleSyncAnim('DeathFinisher', thePlayer, GetActor() );		
			GetNPC().FinisherAnimStart();
			GetNPC().AddTimer( 'SetUnconsciousFinisher', 1.0 );
			return true;
		}
		else if ( eventName == 'SetupSyncInstance' )
		{
			syncInstance = theGame.GetSyncAnimManager().GetSyncInstance( GetEventParamInt( -1 ) );
		}
		return false;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'ForceFinisher' )
		{
			finisherEnabled = true;
			GetActor().EnableFinishComponent( true );
			thePlayer.AddToFinishableEnemyList( GetActor(), true );
			return true;
		}
		return false;
	}
};

class CBehTreeHLTaskUnconsciousDef extends IBehTreeHLTaskDefinition
{
	default instanceClass = 'CBehTreeHLTaskUnconscious';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'ForceFinisher' );
	}
}




class CBehTreeTaskRevive extends IBehTreeTask
{
	function OnActivate() : EBTNodeStatus
	{
		GetActor().Revive();
		
		if( GetNPC().GetNPCType() == ENGT_Guard )
		{
			GetActor().ResetAttitude( thePlayer );
		}
		
		return BTNS_Active;
	}
}
class CBehTreeTaskReviveDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskRevive';
}





class CBehTreeTaskDeathAnimDecorator extends IBehTreeTask
{
	var disableThisBranch 				: bool;
	var enabledRagdoll					: bool;
	var disableCollisionOnAnim			: bool;
	var ignoreForceFinisher				: bool;
	var disableCollisionOnAnimDelay 	: float;
	var completeTimer					: float;
	var playFXOnActivate				: name;
	var playFXOnDeactivate				: name;
	var stopFXOnActivate				: name;
	var stopFXOnDeactivate				: name;
	var playSFXOnActivate 				: name;
	
	private var syncInstance	: CAnimationManualSlotSyncInstance;
	private var finisherEnabled : bool;
	
	default disableThisBranch = false;
	
	function IsAvailable () : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if ( disableThisBranch )
		{
			return false;
		}
		
		if ( npc.IsRagdolled() && !GetActor().HasAbility( 'PoisonDeath' ) )
		{
			npc.SetKinematic(false);
			return false;
		}
		
		
		if ( GetActor().isDead )
		{
			return false;
		}
		
		if ( npc.ShouldPlayDeathAnim() )
		{
			return true;
		}
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var actor : CActor = GetActor();
		
		if ( finisherEnabled )
		{
			actor.SetBehaviorVariable('DeathType',(int)EDT_Agony);
			actor.SetBehaviorVariable('AgonyType',(int)AT_ThroatCut);
		}
		
		if ( IsNameValid( stopFXOnActivate ) )
			actor.StopEffect( stopFXOnActivate );
		
		if ( IsNameValid( playFXOnActivate ) )
			actor.PlayEffect( playFXOnActivate );
		
		if ( IsNameValid( playSFXOnActivate ) )
			
			actor.SoundEvent( playSFXOnActivate );
		
		actor.SetBehaviorMimicVariable( 'gameplayMimicsMode', (float)(int)GMM_Death );
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var owner 						: CNewNPC = GetNPC();
		var timeStamp 					: float;
		var activateDisableCollision	: bool;
		
		timeStamp = GetLocalTime();
		
		while( finisherEnabled )
		{
			if( syncInstance )
			{
				if( syncInstance.HasEnded() )
				{
					return BTNS_Completed;
				}
			}
			else if ( timeStamp + 1.f <= GetLocalTime() ) 
			{
				theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_FinisherInput) );
				thePlayer.OnBlockAllCombatTickets( false );
				Complete(true);
			}
			
			SleepOneFrame();
		}
		
		while ( !enabledRagdoll )
		{
			if ( disableCollisionOnAnim && !activateDisableCollision && timeStamp + disableCollisionOnAnimDelay <= GetLocalTime() )
			{
				activateDisableCollision = true;
				owner.EnableCharacterCollisions( false );
				owner.CanPush( false );
			}
			
			SleepOneFrame();
		}
		if ( enabledRagdoll )
		{
			if ( disableCollisionOnAnim && !activateDisableCollision )
			{
				owner.EnableCharacterCollisions( false );
				owner.CanPush( false );
			}
			Sleep( completeTimer );
			owner.SetBehaviorVariable( 'Ragdoll_Weight', 0.f );
			owner.RaiseForceEvent( 'DeathEndAUX' );
			
			return BTNS_Completed;
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var owner : CNewNPC = GetNPC();
		
		disableThisBranch = true;
		enabledRagdoll = false;
		finisherEnabled = false;
		ignoreForceFinisher = true;
		
		if ( IsNameValid( stopFXOnDeactivate ) )
			owner.StopEffect( stopFXOnDeactivate );
		
		if ( IsNameValid( playFXOnDeactivate ) )
			owner.PlayEffect( playFXOnDeactivate );
		
		owner.EnableFinishComponent( false );
		thePlayer.AddToFinishableEnemyList( owner, false );
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var owner 			: CNewNPC;
		owner = GetNPC();
		if ( animEventName == 'SetRagdoll' )
		{			
			if ( ( ( CMovingPhysicalAgentComponent ) owner.GetMovingAgentComponent() ).HasRagdoll() )
			{
				owner.TurnOnRagdoll();
				enabledRagdoll = true;
			}
		}
		else if ( animEventName == 'Detach')
		{
			owner.BreakAttachment();
			return true;
		}
		else if ( animEventName == 'RotateEventStart')
		{
			owner.SetRotationAdjustmentRotateTo( GetCombatTarget() );
			return true;
		}
		else if ( animEventName == 'RotateAwayEventStart')
		{
			owner.SetRotationAdjustmentRotateTo( GetCombatTarget(), 180.0 );
			return true;
		}
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var owner : CNewNPC = GetNPC();
		
		if ( eventName == 'Finisher' )
		{
			if ( !CombatCheck() )
			{
				return false;
			}
			
			{
				owner.EnableFinishComponent( false );
				thePlayer.AddToFinishableEnemyList( owner, false );
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim('DeathFinisher', thePlayer, GetActor() );		
				owner.FinisherAnimStart();
				owner.SetBehaviorVariable( 'unconsciousFinisher', 1.0 );
				return true;
			}
		}
		else if ( eventName == 'SetupSyncInstance' )
		{
			syncInstance = theGame.GetSyncAnimManager().GetSyncInstance( GetEventParamInt( -1 ) );
		}
		return false;
	}
	
	function CombatCheck() : bool
	{
		if ( thePlayer.IsWeaponHeld( 'steelsword' ) || thePlayer.IsWeaponHeld( 'silversword' ) )
		{
			return true;
		}		
		return false;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'ForceFinisher' && !ignoreForceFinisher )
		{
			finisherEnabled = true;
			GetActor().EnableFinishComponent( true );
			thePlayer.AddToFinishableEnemyList( GetActor(), true );
			return true;
		}
		return false;
	}
};

class CBehTreeTaskDeathAnimDecoratorDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskDeathAnimDecorator';

	editable var completeTimer 					: float;
	editable var disableCollisionOnAnim 		: CBehTreeValBool;
	editable var disableCollisionOnAnimDelay 	: CBehTreeValFloat;
	editable var stopFXOnActivate				: CBehTreeValCName;
	editable var stopFXOnDeactivate				: CBehTreeValCName;
	editable var playFXOnActivate				: CBehTreeValCName;
	editable var playFXOnDeactivate				: CBehTreeValCName;
	editable var playSFXOnActivate 				: CBehTreeValCName;
	
	default disableCollisionOnAnim 				= true;
	default disableCollisionOnAnimDelay 		= 0.5;
	default completeTimer						= 5.0;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'ForceFinisher' );
	}
};
