/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EMonsterNestType
{
	EMNT_Regular,
	EMNT_InfestedWineyard
};

struct SMonsterNestUpdateDefinition
{
	editable saved var isRebuilding					: bool; 
	editable saved  var defaultPhaseToActivate 		: name;
	editable saved var bossPhaseToActivate 			: name;
	editable var hasBoss							: bool; 
	editable var bossSpawnDelay						: float; 
	editable inlined var nestRebuildSchedule    	: GameTimeWrapper;
	
	default defaultPhaseToActivate = 'default';
	default bossPhaseToActivate = 'boss';
}

statemachine class CMonsterNestEntity extends CInteractiveEntity
{
	editable var bombActivators 							: array<name>;
	editable var lootOnNestDestroyed						: CEntityTemplate;
	editable var interactionOnly							: bool; default interactionOnly = true;
	editable var desiredPlayerToEntityDistance				: float; default desiredPlayerToEntityDistance = -1;
	editable var matchPlayerHeadingWithHeadingOfTheEntity	: bool;	default matchPlayerHeadingWithHeadingOfTheEntity = true;		
	editable var settingExplosivesTime 						: float;
	editable var shouldPlayFXOnExplosion					: bool;
	editable var appearanceChangeDelayAfterExplosion		: float;
	editable var shouldDealDamageOnExplosion				: bool;
	editable var factSetAfterFindingNest 					: string;
	editable var factSetAfterSuccessfulDestruction 			: string;
	editable var linkingMode								: bool;
	editable var linkedEncounterHandle 						: EntityHandle;
	editable var linkedEncounterTag							: name;
	editable var setDestructionFactImmediately 				: bool;
	editable var expOnNestDestroyed							: int; default expOnNestDestroyed = 20;
	editable var bonusExpOnBossKilled						: int; default expOnNestDestroyed = 100;
	editable var addExpOnlyOnce								: bool; default addExpOnlyOnce = false;
	editable saved var nestUpdateDefintion					: SMonsterNestUpdateDefinition;
	editable var monsterNestType							: ENestType; 
	editable var regionType									: EEP2PoiType;
	editable var entityType									: EMonsterNestType; default entityType = EMNT_Regular;
	
		hint desiredPlayerToEntityDistance = "if set to < 0 player will stay in position where interaction was pressed";
		hint setDestructionFactImmediately = "if set then destrution fact is added immediately on destruction";
	
	var explodeAfter 			: float;
	var nestBurnedAfter 		: float;
	var playerInventory 		: CInventoryComponent;
	var usedBomb 				: SItemUniqueId;
	var encounter 				: CEncounter;
	saved var nestFound 		: bool;
	var messageTimestamp 		: float;
	var bossKilled				: bool;
	var container				: W3Container;
	var bossKilledCounter 		: int;
	saved var expWasAdded		: bool;
	var bombEntity				: CEntity;
	var bombEntityTemplate		: CEntityTemplate;
	var bombName				: name;
	var actionBlockingExceptions : array<EInputActionBlock>;
	var saveLockIdx				: int;
	saved var voicesetTime		: float;
	saved var voicesetPlayed 	: bool;
	saved var canPlayVset		: bool;
	saved var l_enginetime		: float;
	
	 var airDmg			: bool;
	
	
	autobind interactionComponent 		: CInteractionComponent 	= "CInteractionComponent0";
	
	saved var wasExploded : bool;	default wasExploded = false;
	
	default shouldPlayFXOnExplosion = true;
	default shouldDealDamageOnExplosion = true;
	default linkingMode = true;
	default settingExplosivesTime = 3.0;
	default explodeAfter = 4.0;
	default nestBurnedAfter = 4.0;
	default nestFound = false;
	default messageTimestamp = 0.0;
	default autoState = 'Intact';
	default bossKilled = false;
	default bombName = 'petard';
	default voicesetPlayed = false;
	default canPlayVset = true;
	default monsterNestType = EN_None;
		
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		
		if ( spawnData.restored )
		{
			SetMappinOnLoad ();
			if ( wasExploded )
			{
				SetFocusModeVisibility(0);
				
				if ( IsBossProtectingNest() )
				{
					ApplyAppearance( 'nest_destroyed' );
					GotoState( 'NestDestroyedBoss' );
				}
				else
				{
					ApplyAppearance( 'nest_destroyed' );
					GotoState( 'NestDestroyed' );
				}
			}
			else
			{
				SetFocusModeVisibility(FMV_Interactive);
				GotoStateAuto();
			}
		}
		
		else
		{
			GotoStateAuto();
			
			SetFocusModeVisibility(FMV_Interactive);
		}
	}
		
		
	event OnFireHit(source : CGameplayEntity)
	{
		if ( !interactionOnly && !wasExploded )
		{
			GetEncounter();
			wasExploded = true;
			
			interactionComponent.SetEnabled( false );
			airDmg = false;
			GotoState( 'Explosion' );	
		}
	}
	
	event OnAardHit( sign : W3AardProjectile)
	{
		if ( !interactionOnly && !wasExploded )
		{
			GetEncounter();
			wasExploded = true;
			interactionComponent.SetEnabled( false );
			airDmg = true;
			GotoState( 'Explosion' );	
		}
	}
	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		
	}
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		var commonMapManager : CCommonMapManager = theGame.GetCommonMapManager();
		
		if ( !wasExploded && !interactionComponent.IsEnabled() && interactionComponent  )
		{
			interactionComponent.SetEnabled( true );
		}	
		if( !nestFound )
		{
			if( interactionComponentName != "triggerQuestArea" )
				return false;
			FactsAdd( factSetAfterFindingNest, 1 );
			
			commonMapManager.SetEntityMapPinDiscoveredScript( false, entityName, true );
			
			nestFound = true;
		}
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if ( activator != thePlayer || !thePlayer.CanPerformPlayerAction())
		{
			return false;
		}
	
		if( interactionComponent && wasExploded && interactionComponent.IsEnabled() )
		{
			interactionComponent.SetEnabled( false );
		}
		
		if( PlayerHasBombActivator() )
		{
			if( interactionComponent && interactionComponent.IsEnabled() )
			{
				thePlayer.SetBehaviorVariable( 'NestAnimType', 0 );
				theGame.CreateNoSaveLock( 'nestSettingExplosives', saveLockIdx );
				wasExploded = true;
				GetEncounter();
				interactionComponent.SetEnabled( false );
				GotoState( 'SettingExplosives' );
			}
			return true;
		}
		else
		{
			GetWitcherPlayer().DisplayHudMessage( GetLocStringByKeyExt( "panel_hud_message_destroy_nest_bomb_lacking" ) );
			messageTimestamp = theGame.GetEngineTimeAsSeconds();
		}
		return false;
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if ( area == (CTriggerAreaComponent)this.GetComponent( "VoiceSetTrigger" ) && CanPlayVoiceSet() )
		{ 
			l_enginetime = theGame.GetEngineTimeAsSeconds();
			
			if ( !voicesetPlayed || ( l_enginetime > voicesetTime + 60.0f ) )
			{
				thePlayer.PlayVoiceset( 90, GetVoicesetName( monsterNestType ) );
				voicesetTime = theGame.GetEngineTimeAsSeconds();
				voicesetPlayed = true;
			}
			
		}
	}
	
	
	public function GetRegionType() : int
	{
		return (int) regionType;
	}

	
	public function GetEntityType() : int
	{
		return (int) entityType;
	}

	function CanPlayVoiceSet() : bool
	{
		return !thePlayer.IsSpeaking() && !thePlayer.IsInNonGameplayCutscene() && !thePlayer.IsCombatMusicEnabled() && canPlayVset && !wasExploded;
	}
	
	function GetVoicesetName( val : ENestType ) : name
	{
		switch ( val )
		{
			case EN_Drowner 		: return 'MonsterNestDrowners';
			case EN_Draconid 		: return 'MonsterNestDraconids';
			case EN_Endriaga 		: return 'MonsterNestEndriags';
			case EN_Ghoul 			: return 'MonsterNestGhuls';
			case EN_Harpy 			: return 'MonsterNestHarpies';
			case EN_Nekker 			: return 'MonsterNestNekkers';
			case EN_Rotfiend 		: return 'MonsterNestRorfiends';
			case EN_Siren 			: return 'MonsterNestSirens';
			case EN_Wyvern	 		: return 'MonsterNestWiwerns';
			case EN_BlackSpider		: return 'DetectNestArachnomorphs';
			case EN_Kikimora		: return 'MonsterNestKikimoras';
			case EN_Archespore		: return 'MonsterNestArchespores';
			case EN_Scolopendromorph: return 'MonsterNestScolopendromorps';
			default					: return ''; 				
		}
		
	}

	function SetMappinOnLoad ()
	{
		var commonMapManager : CCommonMapManager = theGame.GetCommonMapManager();
		
		if ( wasExploded || expWasAdded )
		{
			commonMapManager.SetEntityMapPinDisabled( entityName, true );
		}
		else if ( nestFound )
		{
			commonMapManager.SetEntityMapPinDiscoveredScript( false, entityName, true );
		}
	}
	
	function PlayerHasBombActivator() : bool
	{
		var i,j : int;
		var items : array<SItemUniqueId>;
		
		playerInventory = thePlayer.GetInventory();
		
		for( i = 0; i < bombActivators.Size(); i += 1 )
		{
			
			if( playerInventory.HasItem( bombActivators[i] ))
			{
				items.Clear();
				items = playerInventory.GetItemsByName(bombActivators[i]);				
				for(j=0; j<items.Size(); j+=1)
				{
					
					if( playerInventory.SingletonItemGetAmmo(items[j]) > 0 )
					{
						usedBomb = items[j];
						return true;
					}
				}
			}
		}
		return false;
	}
	
	
	event OnAnimEvent_Custom( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
			
		if ( animEventName == 'AttachBomb' && IsNameValid( bombName ))
		{
			bombEntityTemplate = ( CEntityTemplate )LoadResource( bombName );
			bombEntity = theGame.CreateEntity( bombEntityTemplate, thePlayer.GetWorldPosition() );
			bombEntity.CreateAttachment( thePlayer, 'l_weapon');
		}
		else if ( animEventName == 'DetachBomb' )
		{
			bombEntity.DestroyAfter( 0.5 );
			bombEntity.BreakAttachment();
			this.PlayEffect('deploy');
		}
	}
	
	event OnAnimEvent_AttachBomb( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventType == AET_DurationEnd &&IsNameValid( bombName ))
		{
			bombEntityTemplate = ( CEntityTemplate )LoadResource( bombName );
			bombEntity = theGame.CreateEntity( bombEntityTemplate, thePlayer.GetWorldPosition() );
			bombEntity.CreateAttachment( thePlayer, 'l_weapon');
			thePlayer.RemoveAnimEventChildCallback(this,'AttachBomb');
		}
	}
	event OnAnimEvent_DetachBomb( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventType == AET_DurationEnd )
		{
			bombEntity.DestroyAfter( 0.5 );
			bombEntity.BreakAttachment();
			this.PlayEffect('deploy');
			thePlayer.BlockAllActions( 'DestroyNest', false );
			thePlayer.RemoveAnimEventChildCallback(this,'DetachBomb');
			
		}
	}
	
	function AddExp ()
	{
		if ( addExpOnlyOnce && expWasAdded )
		{
			return;
		}
		
		expWasAdded = true;
		GetWitcherPlayer().AddPoints(EExperiencePoint, expOnNestDestroyed, true );
		
	}
	
	function BlockPlayerNestInteraction()
	{
		actionBlockingExceptions.PushBack(EIAB_RunAndSprint);
		actionBlockingExceptions.PushBack(EIAB_Sprint);
		thePlayer.BlockAllActions( 'DestroyNest', true, actionBlockingExceptions );
	}
	
	function AddBonusExp ()
	{
		GetWitcherPlayer().AddPoints(EExperiencePoint, bonusExpOnBossKilled, true );
	}
	
	function GetEncounter()
	{
		if ( linkingMode )
		{
			encounter = ( CEncounter )EntityHandleGet( linkedEncounterHandle );
		}
		else
		{
			encounter = ( CEncounter )theGame.GetEntityByTag( linkedEncounterTag );
		}

		if( !encounter )
			LogChannel( 'Error', "Encounter not connected with " + this.GetName() );
	}
	
	
	
	public function SetBossKilled ( killed : bool )
	{
		if ( !encounter )
		{
			GetEncounter();
		}
		bossKilled = killed;
		encounter.EnableEncounter ( false );
		AddBonusExp ();
	}
	public function SetRebuild ( isRebuilding : bool )
	{
		nestUpdateDefintion.isRebuilding = isRebuilding;
	}
	
	public function IncrementBossKilledCounter ()
	{
		bossKilledCounter += 1;
	}
	
	public function GetBossKilledCounter () : int
	{
		return bossKilledCounter;
	}
		
	timer function ProcessRebuildingSchedule( timeDelta : GameTime, id : int )
	{
		
		if ( nestUpdateDefintion.isRebuilding )
		{
			if ( encounter )
			{
				if ( !encounter.IsPlayerInEncounterArea() )
				{				
					GotoState( 'NestRebuild' );			
				}
				else
				{	
					AddGameTimeTimer( 'ProcessRebuildingSchedule', GameTimeCreate( 0,2,0,0 ), false , , , true, true );	
				}
			}
			else 
			{
				if ( VecDistance2D ( GetWorldPosition(), thePlayer.GetWorldPosition() ) > 30.0 )
				{
					GotoState( 'NestRebuild' );	
				}
				else
				{	
					AddGameTimeTimer( 'ProcessRebuildingSchedule', GameTimeCreate( 0,2,0,0 ), false , , , true, true );				
				}
			}
		}
	}
	
	timer function SpawnBoss ( time : float , id : int)
	{
		encounter.SetSpawnPhase ( nestUpdateDefintion.bossPhaseToActivate );
	}
	

    function IsBossProtectingNest () : bool
	{
		if (nestUpdateDefintion.hasBoss && !bossKilled )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	public function RebuildNest ()
	{
		 AddGameTimeTimer( 'ProcessRebuildingSchedule', nestUpdateDefintion.nestRebuildSchedule.gameTime, false , , , true, true );				
	}
	
	public function IsSetDestructionFactImmediately() : bool
	{
		return setDestructionFactImmediately;
	}
}

state Intact in CMonsterNestEntity
{
	event OnEnterState( prevStateName : name )
	{
		parent.canPlayVset = true;
		super.OnEnterState( prevStateName );
		parent.ApplyAppearance( 'nest_intact' );
	}
}

state SettingExplosives in CMonsterNestEntity
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		if(ShouldProcessTutorial('TutorialMonsterNest'))
			FactsAdd("tut_nest_blown");
		
		PlayAnimationAndSetExplosives();
	}
	
	
	
	entry function PlayAnimationAndSetExplosives()
	{	
		var movementAdjustor 				: CMovementAdjustor = thePlayer.GetMovingAgentComponent().GetMovementAdjustor();
		var ticket 							: SMovementAdjustmentRequestTicket = movementAdjustor.CreateNewRequest( 'InteractionEntity' );
		
		thePlayer.OnHolsterLeftHandItem();		
		thePlayer.AddAnimEventChildCallback(parent,'AttachBomb','OnAnimEvent_AttachBomb');
		thePlayer.AddAnimEventChildCallback(parent,'DetachBomb','OnAnimEvent_DetachBomb');
		
		
		movementAdjustor.AdjustmentDuration( ticket, 0.5 );
		
		if ( parent.matchPlayerHeadingWithHeadingOfTheEntity )
			movementAdjustor.RotateTowards( ticket, parent );
		if ( parent.desiredPlayerToEntityDistance >= 0 )
			movementAdjustor.SlideTowards( ticket, parent, parent.desiredPlayerToEntityDistance );
		
		
		thePlayer.PlayerStartAction( PEA_SetBomb );
		
		
		parent.BlockPlayerNestInteraction();
			
		Sleep( parent.settingExplosivesTime );
		
		parent.playerInventory.SingletonItemRemoveAmmo(parent.usedBomb, 1);
			
		if ( parent.IsBossProtectingNest() )
		{
			parent.AddTimer('SpawnBoss', parent.nestUpdateDefintion.bossSpawnDelay, false, , , true );
		}
		
		Sleep( parent.explodeAfter );
		
		parent.GotoState( 'Explosion' );
	}
}

state Explosion in CMonsterNestEntity
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.canPlayVset = false;
		
		theGame.ReleaseNoSaveLock( parent.saveLockIdx );
		
		Explosion();
	}
	
	entry function Explosion()
	{
		var wasDestroyed : bool;
		var parentEntity : CR4MapPinEntity;
		var commonMapManager : CCommonMapManager = theGame.GetCommonMapManager();
		var l_pos			: Vector;
		
		ProcessExplosion();
		
		SleepOneFrame();
		if ( parent.appearanceChangeDelayAfterExplosion > 0 )
		{
			Sleep( parent.appearanceChangeDelayAfterExplosion );
		}
		
		parent.ApplyAppearance( 'nest_destroyed' );
		
		if( parent.lootOnNestDestroyed )
		{
			l_pos = parent.GetWorldPosition();
			l_pos.Z += 0.5;
			parent.container = (W3Container)theGame.CreateEntity( parent.lootOnNestDestroyed, l_pos, parent.GetWorldRotation() );
		}
		
		
		parent.SetFocusModeVisibility(0);
		
		
		if(parent.IsSetDestructionFactImmediately())
			FactsAdd( parent.factSetAfterSuccessfulDestruction, 1 );
			
		
		wasDestroyed = parent.HasTag('WasDestroyed');
		parent.AddTag('WasDestroyed');
			
		
		parentEntity = ( CR4MapPinEntity )parent;
		if ( parentEntity )
		{
			
			if(FactsQuerySum(parentEntity.entityName + "_nest_destr") == 0)
			{
				FactsAdd(parentEntity.entityName + "_nest_destr");		
				CheckNestDestructionAchievement();	
			}
		}
		
		
		if(!wasDestroyed && !parent.HasTag('AchievementFireInTheHoleExcluded'))
		{
			theGame.GetGamerProfile().IncStat(ES_DestroyedNests);
		}
		
		
		
		commonMapManager.SetEntityMapPinDisabled( parent.entityName, true );
		parent.AddExp();
		
		if ( !parent.airDmg )
		{
			parent.PlayEffect( 'fire' );
		}
		else
		{
			parent.PlayEffect( 'dust' );
		}
		
		if( parent.nestBurnedAfter != 0 )
		{
						
			Sleep( parent.nestBurnedAfter );
		}
		
		
		if(!parent.IsSetDestructionFactImmediately())
			FactsAdd( parent.factSetAfterSuccessfulDestruction, 1 );
		
		if ( parent.IsBossProtectingNest() )
		{
			parent.GotoState( 'NestDestroyedBoss' );
		}
		else
		{
			parent.GotoState( 'NestDestroyed' );
		}
	}
		
	private function ProcessExplosion()
	{
		ProcessExplosionEffects();
		
		if( parent.shouldDealDamageOnExplosion )
			ProcessExplosionDamage();
	}
	
	private function ProcessExplosionEffects()
	{
		if( parent.shouldPlayFXOnExplosion && !parent.airDmg )
		{
			parent.PlayEffect( 'explosion' );
		}
		GCameraShake( 0.5, true, parent.GetWorldPosition(), 1.0f );
		
		parent.StopEffect('deploy');
	}
	
	private function ProcessExplosionDamage()
	{
		var damage : W3DamageAction;
		var entitiesInRange : array<CGameplayEntity>;
		var explosionRadius : float = 3.0;
		var damageVal : float = 50.0;
		var i : int;
		
		FindGameplayEntitiesInSphere( entitiesInRange, parent.GetWorldPosition(), explosionRadius, 100 );	
		entitiesInRange.Remove( parent );
		for( i = 0; i < entitiesInRange.Size(); i += 1 )
		{
			if( entitiesInRange[ i ] == thePlayer && thePlayer.CanUseSkill( S_Perk_16 ) )
			{
				continue;
			}
			
			if( (CActor)entitiesInRange[i] )
			{
				damage = new W3DamageAction in parent;
				
				damage.Initialize( parent, entitiesInRange[i], NULL, parent, EHRT_None, CPS_Undefined, false, false, false, true );
				damage.AddDamage( theGame.params.DAMAGE_NAME_FIRE, damageVal );
				damage.AddEffectInfo( EET_Burning );
				damage.AddEffectInfo( EET_Stagger );
				theGame.damageMgr.ProcessAction( damage );
				
				delete damage;
			}
			else
			{
				entitiesInRange[i].OnFireHit( parent );
			}
		}
	}
}

state NestRebuilding in CMonsterNestEntity
{
	event OnEnterState( prevStateName : name )
	{	
		super.OnEnterState( prevStateName );
		parent.RebuildNest ();
	}
}

state NestRebuild in CMonsterNestEntity
{
	event OnEnterState( prevStateName : name )
	{	
		
		super.OnEnterState( prevStateName );
		Rebuild ();		
	}
	entry function Rebuild ()
	{
		var commonMapManager : CCommonMapManager = theGame.GetCommonMapManager();
		Sleep ( 3.0 );
		parent.encounter.EnableEncounter( true );
		parent.encounter.SetSpawnPhase( parent.nestUpdateDefintion.defaultPhaseToActivate );
		
		parent.wasExploded = false;
		if( parent.interactionComponent )
		{
			parent.interactionComponent.SetEnabled( true );
		}
		
		if ( !parent.expWasAdded )
		{
			commonMapManager.SetEntityMapPinDisabled( parent.entityName, false );
		}
		if ( parent.container )
		{
			parent.container.Destroy();
		}
		
		parent.GotoState( 'Intact' );
	}
}

state NestDestroyedBoss in CMonsterNestEntity
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.StopAllEffects();		
		
		if ( parent.nestUpdateDefintion.isRebuilding )
		{
			parent.GotoState( 'NestRebuilding' );
		}
	}
}

state NestDestroyed in CMonsterNestEntity
{
	event OnEnterState( prevStateName : name )
	{
		var commonMapManager : CCommonMapManager = theGame.GetCommonMapManager();
		
		super.OnEnterState( prevStateName );
		parent.StopAllEffects();
		
		parent.encounter.EnableEncounter( false );
		
		if ( parent.nestUpdateDefintion.isRebuilding )
		{
			parent.GotoState( 'NestRebuilding' );
		}
	}
}
enum ENestType
{
	EN_Drowner,
	EN_Draconid,
	EN_Endriaga,
	EN_Ghoul,
	EN_Harpy,
	EN_Nekker,
	EN_Rotfiend,
	EN_Siren,
	EN_Wyvern,
	EN_None,
	EN_BlackSpider,
	EN_Kikimora,
	EN_Archespore,
	EN_Scolopendromorph
}


function CheckNestDestructionAchievement(optional debugLog : bool)
{
	var entityMapPins : array< SEntityMapPinInfo >;
	var i : int;
	var totalNests : int;
	var doneNests : int;
	var depotPath : string;
	var missesSomeNest : bool;
	
	
	depotPath = theGame.GetWorld().GetDepotPath();
	
	
	
	if(StrFindFirst(depotPath, "novigrad") < 0)
	{
		if(StrFindFirst(depotPath, "skellige") < 0)
		{
			return;
		}
	}	
		
	
	
	entityMapPins = theGame.GetCommonMapManager().GetEntityMapPins(depotPath);
	
	
	
	if(debugLog)
	{
		LogAchievements("");
		LogAchievements("Printing test results for " + EA_PestControl + " achievement");
		LogAchievements("");
	}
	
	totalNests = 0;
	doneNests = 0;
	missesSomeNest = false;
	for(i=0; i<entityMapPins.Size(); i+=1)
	{
		
		if(entityMapPins[i].entityType == 'MonsterNest')
		{
			totalNests+=1;
			
			
			if(FactsQuerySum(entityMapPins[i].entityName + "_nest_destr") < 1)
			{
				missesSomeNest = true;
				
				if(debugLog)
				{
					LogAchievements(EA_PestControl + ": not destroyed nest at: X=" + entityMapPins[i].entityPosition.X + ", Y= " + entityMapPins[i].entityPosition.Y + ", Z= " + entityMapPins[i].entityPosition.Z);
				}
			}
			else
			{
				doneNests+=1;
			}
		}
	}
		
	if(missesSomeNest)
	{
		theGame.GetGamerProfile().NoticeAchievementProgress(EA_PestControl, doneNests, totalNests);
	}
	else
	{
		theGame.GetGamerProfile().AddAchievement(EA_PestControl);
		
		if(debugLog)
		{
			LogAchievements("All nests in region are destroyed");
		}
	}
	
	if(debugLog)
	{
		LogAchievements("");
	}
}


function ProcessVelen(out entityMapPins : array<SEntityMapPinInfo>)
{
	var i : int;
	var velen, isPinVelen : bool;
	var playerPos : Vector;
	
	
	
	playerPos = thePlayer.GetWorldPosition();
	velen = (playerPos.Y < 1350 );
	
	for(i=entityMapPins.Size()-1; i>=0; i-=1)
	{
		
		if(entityMapPins[i].entityType != 'MonsterNest')
		{
			entityMapPins.EraseFast(i);
			continue;
		}				
		
		isPinVelen = (entityMapPins[i].entityPosition.Y < 1350);
		
		if(velen != isPinVelen)
			entityMapPins.EraseFast(i);
	}
}

exec function testpest()
{
	CheckNestDestructionAchievement(true);
}