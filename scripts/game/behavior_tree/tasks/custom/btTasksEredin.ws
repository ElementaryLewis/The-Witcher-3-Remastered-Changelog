/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EBossAction
{
	EBA_Parry,
	EBA_Siphon,
	EBA_Dodge,
	EBA_StaminaRegen,
	EBA_PhaseChange
};

enum EBossSpecialAttacks
{
	EBSA_Lightbringer,
	EBSA_Meteorites,
	EBSA_IceSpikes,
	EBSA_BlinkCombo,
	EBSA_SpecialAttacks
};




class BTTaskEredinChangeArena extends IBehTreeTask
{
	var resourceName : name;
	var eventName : name;
	var spawnPortalInTaggedNode : bool;
	var nodeTag : name;
	var destinationTag : name;
	var factOnPlayerTeleport : string;
	var entityTemplate : CEntityTemplate;
	var shouldCreateRift : bool;
	
	latent function Main() : EBTNodeStatus
	{
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );
	
		while( !shouldCreateRift )
			SleepOneFrame();
			
		CreateRift();
		
		return BTNS_Active;	
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if( animEventName == eventName )
		{
			shouldCreateRift = true;
			return true;
		}
			
		return false;
	}
	
	function CreateRift()
	{
		var npc : CNewNPC = GetNPC();
		var spawnPos : Vector;
		var rotation : EulerAngles;
		var entity : CEntity;
		var teleport : CTeleportEntity;
		var node : CNode;
		
		if( spawnPortalInTaggedNode )
		{
			if( nodeTag == 'None' )
				return;
				
			node = theGame.GetNodeByTag( nodeTag );
			
			if( node )
			{
				spawnPos = node.GetWorldPosition();
				rotation = node.GetWorldRotation();
			}
		}
		else
		{
			spawnPos = npc.GetWorldPosition();
			spawnPos += npc.GetHeadingVector() * 3.0;
			rotation = npc.GetWorldRotation();
		}
		
		entity = theGame.CreateEntity( entityTemplate, spawnPos, rotation );
		
		teleport = (CTeleportEntity)entity;
		
		if( teleport )
		{
			teleport.SetDestinationParameters( destinationTag, factOnPlayerTeleport );
			teleport.ActivateTeleport( 0.5 );
			
		}	
	}
}

class BTTaskEredinChangeArenaDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskEredinChangeArena';

	editable var resourceName : name;
	editable var eventName : name;
	editable var spawnPortalInTaggedNode : bool;
	editable var nodeTag : name;
	editable var destinationTag : name;
	editable var factOnPlayerTeleport : string;
	
	default resourceName = 'player_rift';
	default eventName = 'OpenRift';
}




class BTTaskSpawnEntitiesAttack extends IBehTreeTask
{
	var resourceName : name;
	var eventName : name;
	var numberOfEntities : int;
	var timeBetweenSpawn : float;
	var minDistFromTarget : float;
	var maxDistFromTarget : float;
	var minDistFromEachOther : float;
	var initialDelay : float;
	var behVariableToSetOnEnd : name;
	var shouldStart : bool;
	var lastSpawnTimestamp : float;
	var spawnTimeout : float;
	var checkDistanceOfNpcToTarget : bool;
	var spawnEntitiesAroundOwner : bool;
	
	var entityTemplate : CEntityTemplate;
	var usedPos : array<Vector>;
	
	default checkDistanceOfNpcToTarget = true;
	default spawnEntitiesAroundOwner = false;
	
	function OnActivate() : EBTNodeStatus
	{
		GetNPC().SetBehaviorVariable( behVariableToSetOnEnd, 0.0 );
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		GetNPC().SetBehaviorVariable( behVariableToSetOnEnd, 1.0 ); 
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if( animEventName == eventName )
		{
			shouldStart = true;
			return true;
		}
			
		return false;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var pos : Vector;
		var i : int;
		
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );
		
		while( !shouldStart )
			SleepOneFrame();
			
		usedPos.Clear();
		spawnTimeout = timeBetweenSpawn * 3;
		
		Sleep( initialDelay );
		
		for( i = 0; i < numberOfEntities; i += 1 )
		{
			if( ( VecDistance2D( GetNPC().GetWorldPosition(), GetCombatTarget().GetWorldPosition() ) < 7.5 ) && checkDistanceOfNpcToTarget )
			{
				break;
			}
			
			pos = FindPosition();
			
			while( !IsPositionValid( pos ) )
			{
				SleepOneFrame();
				pos = FindPosition();
			}
			
			Spawn( pos );
			usedPos.PushBack( pos );
			lastSpawnTimestamp = theGame.GetEngineTimeAsSeconds();
			Sleep( timeBetweenSpawn );
		}
		
		GetNPC().SetBehaviorVariable( behVariableToSetOnEnd, 1.0 );
		
		return BTNS_Active;	
	}
	
	function Spawn( position : Vector )
	{
		var npc : CNewNPC = GetNPC();
		var entity : CEntity;
		var randYaw : float;
		var rotation : EulerAngles;
		
		if( entityTemplate )
		{
			randYaw = RandRangeF( 180.0, -180.0 );
			rotation.Yaw = randYaw;
			entity = theGame.CreateEntity( entityTemplate, position, rotation );
		}
	}
	
	function FindPosition() : Vector
	{
		var randVec : Vector = Vector( 0.f, 0.f, 0.f );
		var targetPos : Vector;
		var outPos : Vector;
		
		targetPos = GetCombatTarget().GetWorldPosition();
		randVec = VecRingRand( minDistFromTarget, maxDistFromTarget );
		
		if( spawnEntitiesAroundOwner )
		{
			targetPos = GetNPC().GetWorldPosition();
		}
		outPos = targetPos + randVec;
		
		return outPos;
	}
	
	protected function IsPositionValid( out whereTo : Vector ) : bool
	{
		var newPos : Vector;
		var radius : float;
		var z : float;
		var i : int;

		radius = 0.1;
		
		if( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, radius, radius*3, newPos ) )
		{
			if( theGame.GetWorld().NavigationComputeZ( whereTo, whereTo.Z - 5.0, whereTo.Z + 5.0, z ) )
			{
				whereTo.Z = z;
				if( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, radius, radius*3, newPos ) )
					return false;
			}
			return false;
		}
		
		if( lastSpawnTimestamp + spawnTimeout > theGame.GetEngineTimeAsSeconds() )
		{
			for( i = 0; i < usedPos.Size(); i += 1 )
			{
				if( VecDistance2D( newPos, usedPos[i] ) < minDistFromEachOther )
					return false;
			}
		}
		
		whereTo = newPos;
		
		return true;
	}
}

class BTTaskSpawnEntitiesAttackDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSpawnEntitiesAttack';

	editable var resourceName : name;
	editable var eventName : name;
	editable var numberOfEntities : int;
	editable var timeBetweenSpawn : float;
	editable var minDistFromTarget : float;
	editable var maxDistFromTarget : float;
	editable var minDistFromEachOther : float;
	editable var initialDelay : float;
	editable var behVariableToSetOnEnd : name;
	editable var checkDistanceOfNpcToTarget : bool;
	editable var spawnEntitiesAroundOwner 	: bool;
}




class BTTaskEredinIceSpikesAttack extends BTTaskSpawnEntitiesAttack
{
	function Spawn( position : Vector )
	{
		var npc : CNewNPC = GetNPC();
		var entity : CEntity;
		var spike : W3EredinIceSpike;
		var randYaw : float;
		var rotation : EulerAngles;
		
		if( entityTemplate )
		{
			randYaw = RandRangeF( 180.0, -180.0 );
			rotation.Yaw = randYaw;
			entity = theGame.CreateEntity( entityTemplate, position, rotation );
			spike = (W3EredinIceSpike)entity;
			if( spike )
			{
				spike.Appear();
			}
		}
	}
}

class BTTaskEredinIceSpikesAttackDef extends BTTaskSpawnEntitiesAttackDef
{
	default instanceClass = 'BTTaskEredinIceSpikesAttack';

	default resourceName = 'eredin_ice_spike';
	default eventName = 'IceSpikes';
	default numberOfEntities = 5;
	default timeBetweenSpawn = 1.5;
	default minDistFromTarget = 1.0;
	default maxDistFromTarget = 1.5;
	default minDistFromEachOther = 2.0;
	default initialDelay = 0.0;
	default behVariableToSetOnEnd = 'bIceSpikesEnd';
}




class BTTaskEredinMeteoriteAttack extends BTTaskSpawnEntitiesAttack
{
	var collisionGroups : array<name>;
	
	function OnActivate() : EBTNodeStatus
	{
		super.OnActivate();
		
		collisionGroups.PushBack( 'Terrain' );
		collisionGroups.PushBack( 'Static' );
		
		return BTNS_Active;
	}
	
	function Spawn( position : Vector )
	{
		var npc : CNewNPC = GetNPC();
		var entity : CEntity;
		var meteorite : W3MeteorProjectile;
		var spawnPos : Vector;
		var randY : float;
		var randYaw : float;
		var rotation : EulerAngles;
		
		if( entityTemplate )
		{
			randY = RandRangeF( 30.0, 20.0 );
			spawnPos = position;
			spawnPos.Y += randY;
			spawnPos.Z += 50;
			
			randYaw = RandRangeF( 180.0, -180.0 );
			rotation.Yaw = randYaw;
			
			entity = theGame.CreateEntity( entityTemplate, spawnPos, rotation );
			meteorite = (W3MeteorProjectile)entity;
			if( meteorite )
			{
				
				meteorite.Init( NULL );
				meteorite.ShootProjectileAtPosition( meteorite.projAngle, meteorite.projSpeed, position, 500, collisionGroups );
			}
		}
	}
}
class BTTaskEredinMeteoriteAttackDef extends BTTaskSpawnEntitiesAttackDef
{
	default instanceClass = 'BTTaskEredinMeteoriteAttack';

	default resourceName = 'eredin_meteorite';
	default eventName = 'SummonMeteorites';
	default numberOfEntities = 9;
	default timeBetweenSpawn = 1.5;
	default minDistFromTarget = 0.0;
	default maxDistFromTarget = 0.5;
	default minDistFromEachOther = 1.0;
	default initialDelay = 0.0;
	default behVariableToSetOnEnd = 'bSummonMeteoritesEnd';
}




class BTTaskEredinSummonMeteoriteStorm extends IBehTreeTask
{
	var resourceName : name;
	var eventName : name;
	var shouldSpawn : bool;
	
	var entityTemplate : CEntityTemplate;

	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if( animEventName == eventName )
		{
			shouldSpawn = true;
			
			return true;
		}
			
		return false;
	}
	
	latent function Main() : EBTNodeStatus
	{
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );
	
		while( !shouldSpawn )
			SleepOneFrame();
			
		Spawn();
		
		return BTNS_Active;	
	}
	
	function Spawn()
	{
		var entity : CEntity;
		var meteoriteStorm : CMeteoriteStormEntity;
		var spawnPos : Vector;
		var rotation : EulerAngles;
		
		spawnPos = GetCombatTarget().GetWorldPosition();
		rotation = GetCombatTarget().GetWorldRotation();
		
		if( entityTemplate )
		{
			entity = theGame.CreateEntity( entityTemplate, spawnPos, rotation );
			meteoriteStorm = (CMeteoriteStormEntity)entity;
			if( meteoriteStorm )
			{
				meteoriteStorm.Execute( GetCombatTarget() );
			}
		}
	}
}

class BTTaskEredinSummonMeteoriteStormDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskEredinSummonMeteoriteStorm';

	editable var resourceName : name;
	editable var eventName : name;
	
	default resourceName = 'meteorite_storm';
	default eventName = 'SummonMeteorites';
}




class BTTaskBlockPlayerActions extends IBehTreeTask
{
	var block : bool;
	var onActivate : bool;
	
	function OnActivate() : EBTNodeStatus
	{
		if( onActivate )
		{
			thePlayer.BlockAllActions( 'BTTaskBlockPlayerActions', block );
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{	
		if( !onActivate )
		{
			thePlayer.BlockAllActions( 'BTTaskBlockPlayerActions', block );
		}
	}
}

class BTTaskBlockPlayerActionsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskBlockPlayerActions';

	editable var block : bool;
	editable var onActivate : bool;
	
	default block = true;
	default onActivate = true;
}




class BTTaskEredinMonitorSignCast extends IBehTreeTask
{
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		npc.SetBehaviorVariable( 'bIsSignReleased', 0.0 );
		
		while( thePlayer.IsCastingSign() )
		{			
			Sleep( 0.1 );
		}
		
		npc.SetBehaviorVariable( 'bIsSignReleased', 1.0 );
		
		return BTNS_Active;
	}
}

class BTTaskEredinMonitorSignCastDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskEredinMonitorSignCast';
}




class BTTaskEredinCanSpawnRift extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return PerformTestForSyncedAnim();
	}
	
	function PerformTestForSyncedAnim() : bool
	{
		var playerPos, cameraMaxBackPos, portalPos : Vector;
		var playerHeading : Vector;
		var combatActionType : int;
		
		if( FactsQuerySum( "phaseChangeStarted" ) )
		{
			return true;
		}
		
		playerPos = thePlayer.GetWorldPosition();
		playerHeading = thePlayer.GetHeadingVector();
		
		cameraMaxBackPos = playerPos - playerHeading * 4.0;
		
		if( !theGame.GetWorld().NavigationLineTest( playerPos, cameraMaxBackPos, 0.4 ) ) 
		{
			return false;
		}
		
		portalPos = playerPos + playerHeading * 2.8;
		
		if( !theGame.GetWorld().NavigationLineTest( playerPos, portalPos, 1.0 ) ) 
		{
			return false;
		}
		
		if( thePlayer.HasBuff( EET_Stagger ) )
		{
			return false;
		}
		else if( thePlayer.IsCurrentlyDodging() )
		{
			combatActionType = (int)( thePlayer.GetBehaviorVariable( 'combatActionType' ) );
			
			if( combatActionType == (int)CAT_Roll || combatActionType == (int)CAT_Dodge )
			{
				return false;
			}
		}
		else if( thePlayer.IsInCombatAction_Attack() || thePlayer.IsInCombatAction_SpecialAttack() )
		{
			return false;
		}
		
		return true;
	}
}

class BTTaskEredinCanSpawnRiftDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskEredinCanSpawnRift';
}




class BTTaskEredinCanPerformAction extends IBehTreeTask
{
	protected var combatDataStorage : CBossAICombatStorage;
	
	editable var action : EBossAction;
	
	function IsAvailable() : bool
	{
		switch( action )
		{
			case EBA_Parry:
				return combatDataStorage.GetIsParryAvailable();
				
			case EBA_Siphon:
				return combatDataStorage.GetIsSiphonAvailable();
				
			case EBA_Dodge:
				return combatDataStorage.GetIsDodgeAvailable();
				
			case EBA_Dodge:
				return combatDataStorage.GetIsDodgeAvailable(); 
				
			case EBA_StaminaRegen:
				return combatDataStorage.GetIsStaminaRegenAvailable();
				
			case EBA_PhaseChange:
				return combatDataStorage.GetIsPhaseChangeAvailable();
			
			default:
				return false;
		}
	}
	
	function Initialize()
	{
		combatDataStorage = (CBossAICombatStorage)InitializeCombatStorage();
	}
}

class BTTaskEredinCanPerformActionDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskEredinCanPerformAction';

	editable var action : EBossAction;
}




class BTTaskEredinSetCanPerformAction extends IBehTreeTask
{
	protected var combatDataStorage : CBossAICombatStorage;
	private var npc : CNewNPC;
	
	var action : EBossAction;
	var value : bool;
	var onActivate : bool;
	
	function OnActivate() : EBTNodeStatus
	{
		if( onActivate )
		{
			Execute();
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( !onActivate ) 
		{
			Execute();
		}
	}
	
	private function Execute()
	{
		npc = GetNPC();
		
		switch( action )
		{
			case EBA_Parry:
			{
				if( value )
				{
					npc.RaiseGuard();
					combatDataStorage.SetIsParryAvailable( true );
				}
				else
				{
					npc.LowerGuard();
					combatDataStorage.SetIsParryAvailable( false );
				}
				
				break;
			}
				
			case EBA_Siphon:
			{
				if( value )
				{
					npc.AddAbility( 'EredinFireResistance', false );
					npc.AddAbility( 'IgnoreHitAnimFromSigns', false );
					npc.AddBuffImmunity( EET_KnockdownTypeApplicator, 'BTTaskEredinSetCanPerformAction', true );
					npc.AddBuffImmunity( EET_Burning, 'BTTaskEredinSetCanPerformAction', true );
					combatDataStorage.SetIsSiphonAvailable( true );
				}
				else
				{
					npc.RemoveAbility( 'EredinFireResistance' );
					npc.RemoveAbility( 'IgnoreHitAnimFromSigns' );
					npc.RemoveBuffImmunity( EET_KnockdownTypeApplicator, 'BTTaskEredinSetCanPerformAction' );
					npc.RemoveBuffImmunity( EET_Burning, 'BTTaskEredinSetCanPerformAction' );
					combatDataStorage.SetIsSiphonAvailable( false );
				}
				
				break;
			}
			
			case EBA_Dodge:
			{
				if( value )
				{
					combatDataStorage.SetIsDodgeAvailable( true );
				}
				else
				{
					combatDataStorage.SetIsDodgeAvailable( false );
				}
				
				break;
			}
			
			case EBA_StaminaRegen:
			{
				if( value )
				{
					combatDataStorage.SetIsStaminaRegenAvailable( true );
					
					npc.RemoveBuffImmunity( EET_AutoStaminaRegen, 'BTTaskEredinSetCanPerformAction' );
					npc.AddEffectDefault( EET_AutoStaminaRegen, npc );
				}
				else
				{
					combatDataStorage.SetIsStaminaRegenAvailable( false );
					
					npc.AddBuffImmunity( EET_AutoStaminaRegen, 'BTTaskEredinSetCanPerformAction', true );
					
				}
				
				break;
			}
			
			case EBA_PhaseChange:
			{
				if( value )
				{
					combatDataStorage.SetIsPhaseChangeAvailable( true );
				}
				else
				{
					combatDataStorage.SetIsPhaseChangeAvailable( false );
				}
				
				break;
			}
			
			default:
			{
				break;
			}
		}
	}
	
	function Initialize()
	{
		combatDataStorage = (CBossAICombatStorage)InitializeCombatStorage();
	}
}

class BTTaskEredinSetCanPerformActionDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskEredinSetCanPerformAction';

	editable var action : EBossAction;
	editable var value : bool;
	editable var onActivate : bool;
	
	default onActivate = true;
}




class BTTaskEredinIsAttackAvailable extends IBehTreeTask
{
	protected var combatDataStorage : CBossAICombatStorage;
	
	var attack : EBossSpecialAttacks;

	function IsAvailable() : bool
	{
		return combatDataStorage.IsAttackAvailable( attack );
	}
	
	function Initialize()
	{
		combatDataStorage = (CBossAICombatStorage)InitializeCombatStorage();
	}
}

class BTTaskEredinIsAttackAvailableDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskEredinIsAttackAvailable';

	editable var attack : EBossSpecialAttacks;
}




class BTTaskEredinSetIsAttackAvailable extends IBehTreeTask
{
	protected var combatDataStorage : CBossAICombatStorage;
	
	var attack : EBossSpecialAttacks;
	var val : bool;
	var onActivate : bool;

	function OnActivate() : EBTNodeStatus
	{
		if( onActivate )
		{
			Execute();
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( !onActivate ) 
		{
			Execute();
		}
	}
	
	private function Execute()
	{
		combatDataStorage.SetIsAttackAvailable( attack, val );
	}
	
	function Initialize()
	{
		combatDataStorage = (CBossAICombatStorage)InitializeCombatStorage();
	}
}

class BTTaskEredinSetIsAttackAvailableDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskEredinSetIsAttackAvailable';

	editable var attack : EBossSpecialAttacks;
	editable var val : bool;
	editable var onActivate : bool;
	
	default onActivate = true;
}




class BTTaskEredinSetIsInSpecialAttack extends IBehTreeTask
{
	protected var combatDataStorage : CBossAICombatStorage;

	function OnActivate() : EBTNodeStatus
	{
		combatDataStorage.SetIsInSpecialAttack( true );
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		combatDataStorage.SetIsInSpecialAttack( false );
	}
	
	function Initialize()
	{
		combatDataStorage = (CBossAICombatStorage)InitializeCombatStorage();
	}
}

class BTTaskEredinSetIsInSpecialAttackDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskEredinSetIsInSpecialAttack';
}




class BTTaskEredinGetIsInSpecialAttack extends IBehTreeTask
{
	protected var combatDataStorage : CBossAICombatStorage;

	function IsAvailable () : bool
	{
		return combatDataStorage.GetIsInSpecialAttack();
	}
	
	function Initialize()
	{
		combatDataStorage = (CBossAICombatStorage)InitializeCombatStorage();
	}
}

class BTTaskEredinGetIsInSpecialAttackDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskEredinGetIsInSpecialAttack';
}




class BTTaskEredinIsTaunting extends IBehTreeTask
{
	protected var combatDataStorage : CBossAICombatStorage;

	function IsAvailable () : bool
	{
		return combatDataStorage.GetIsTaunting();
	}
	
	function Initialize()
	{
		combatDataStorage = (CBossAICombatStorage)InitializeCombatStorage();
	}
}

class BTTaskEredinIsTauntingDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskEredinIsTaunting';
}




enum EEredinPhaseChangeAction
{
	EEPCA_PreparePartOne,
	EEPCA_PartOne,
	EEPCA_PreparePartTwo,
	EEPCA_PartTwo,
	EEPCA_AdjustRotation
}

class BTTaskEredinPhaseChange extends IBehTreeTask
{
	var action : EEredinPhaseChangeAction;
	
	function OnActivate() : EBTNodeStatus
	{
		var node, node1 : CNode;
		var pos, pos1 : Vector;
		var rot, rot1 : EulerAngles;
		
		switch( action )
		{
			case EEPCA_PreparePartOne:
			{
				break;
			}
			case EEPCA_PartOne:
			{
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim( 'EredinPhaseChangePartOne', thePlayer, GetActor() );
				break;
			}
			case EEPCA_PreparePartTwo:
			{
				node = theGame.GetNodeByTag( 'eredin_area_2' );
				node1 = theGame.GetNodeByTag( 'eredinPos' );
				if( node && node1 )
				{
					pos = node.GetWorldPosition();
					rot = node.GetWorldRotation();
					thePlayer.TeleportWithRotation( pos, rot );
					
					pos1 = node1.GetWorldPosition();
					rot1 = node1.GetWorldRotation();
					GetActor().TeleportWithRotation( pos1, rot1 );
				}
				
				break;
			}
			case EEPCA_PartTwo:
			{
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim( 'EredinPhaseChangePartTwo', thePlayer, GetActor() );
				break;
			}
			case EEPCA_AdjustRotation:
			{
				node1 = theGame.GetNodeByTag( 'eredinPos' );
				pos1 = node1.GetWorldPosition();
				rot1 = node1.GetWorldRotation();
				GetActor().TeleportWithRotation( pos1, rot1 );
				
				break;
			}
			default:
			{
				break;
			}
		}
		
		return BTNS_Active;
	}
}

class BTTaskEredinPhaseChangeDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskEredinPhaseChange';

	editable var action : EEredinPhaseChangeAction;
}




class BTTaskLockCameraToTarget extends IBehTreeTask
{
	var lock : bool;
	var onActivate : bool;
	
	function OnActivate() : EBTNodeStatus
	{	
		if( onActivate )
		{
			thePlayer.LockCameraToTarget( lock );
			thePlayer.LockActorToTarget( lock, true );
		}

		return BTNS_Active;
	}
	
	function OnDeactivate()
	{	
		if( !onActivate )
		{
			thePlayer.LockCameraToTarget( lock );
			thePlayer.LockActorToTarget( lock, true );
		}
	}
}

class BTTaskLockCameraToTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskLockCameraToTarget';

	editable var lock : bool;
	editable var onActivate : bool;

}




class BTTaskIsPlayerReachable extends IBehTreeTask
{
	var playerPos : Vector;
	
	function IsAvailable() : bool
	{
		playerPos = thePlayer.GetWorldPosition();
		
		return theGame.GetWorld().NavigationCircleTest( playerPos, 0.2 );
	}

}

class BTTaskIsPlayerReachableDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskIsPlayerReachable';
}




class BTCondIsInvulnerable extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return GetNPC().IsInvulnerable();
	}
}

class BTCondIsInvulnerableDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTCondIsInvulnerable';
}