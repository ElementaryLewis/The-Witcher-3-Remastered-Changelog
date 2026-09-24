/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSwarmSpawnAnim extends IBehTreeTask
{
	
	var spawned 				: bool;
	var spawnCondition			: ESpawnCondition;
	var lair					: CFlyingSwarmMasterLair;
	var swarmStabilizeTime		: float;
	var delayMain				: float;
	var time					: float;
	var distToActors			: float;
	var currTime				: float;
	var initialTime 			: float;
	var useSwarms				: bool;
	var manageGravity 			: bool;
	var animEventOccured		: bool;
	var despawnCalled			: bool;
	var raiseEventName			: name;
	var fxName			 		: name;
	var initialAppearance		: name;
	var setAppearanceTo 		: name;
	var playFXOnAnimEvent		: bool;
	var res, fail, despawn		: bool;
	var animEventNameActivator	: name;
	var spawnCount				: int;
	
	
	default spawnCondition		= SC_PlayerInRange;
	default spawned 			= false;
	default manageGravity 		= false;
	default playFXOnAnimEvent	= false;
	default distToActors		= 30.f;
	default animEventOccured	= false;
	default despawnCalled		= false;
	
	hint initialAppearance = "ignore enemies in range check for availability test";
	hint initialAppearance = "won't affect entity settings if left empty";
	hint setAppearanceTo = "works only when anim event name is specified";
	hint playFXOnAnimEvent = "if false, will play FX on activate";
	
	
	function IsAvailable() : bool
	{
		if ( GetNPC().GetBehaviorVariable( 'Spawn' ) == 1 )
		{
			return false;
		}
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var pos	: Vector;
		var swarmGroupId : CFlyingGroupId;
		var componentArray: array<CComponent>;
		var lairEntities : array<CGameplayEntity>;
		
		npc.SetCanPlayHitAnim( false );
		if( raiseEventName )
		{
			npc.RaiseForceEvent( raiseEventName );
		}
		
		if( initialAppearance )
		{
			npc.SetAppearance( initialAppearance );
		}
		
		if ( useSwarms && !lair )
		{
			FindGameplayEntitiesInRange( lairEntities, GetActor(), 150, 1, 'SwarmMasterLair' );
			if ( lairEntities.Size() > 0 )
				lair = (CFlyingSwarmMasterLair)lairEntities[0];
			lair.SetBirdMaster( npc );
			swarmGroupId = lair.GetGroupId( 'teleport' );
			lair.SignalArrivalAtNode( 'shield', npc, 'shield', swarmGroupId );
		}
		
		componentArray = npc.GetComponentsByClassName( 'CBoidPointOfInterestComponent' );
		if ( componentArray.Size() > 0 )
		{
			LogChannel( 'swarmDebug', "Number of CBoidPointOfInterestComponents: " + componentArray.Size() );
		}
		
		pos = npc.GetWorldPosition();
		
		if( ((CMovingPhysicalAgentComponent) npc.GetMovingAgentComponent()).GetWaterLevel() > pos.Z )
		{
			npc.SetBehaviorVariable( 'SpawnAnim', 3 );
		}
		
		else if( npc.GetDistanceFromGround( 2 ) > 1 && npc.HasAbility('Flying') )
		{
			npc.SetBehaviorVariable( 'SpawnAnim', 2 );
			npc.ChangeStance( NS_Fly );
		}
		else
		{
			npc.SetBehaviorVariable( 'SpawnAnim', 1 );
		}
		
		return BTNS_Active;
	}
	
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC 	= GetNPC();
		var success 		: bool;
		var switchGravity 	: bool;
		var actors 			: array<CActor>;
		var dist 			: float;
		var i 				: int;
		
		((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetAnimatedMovement( false );
		
		while ( npc.GetBehaviorVariable( 'SpawnAnim' ) != 0.f && !spawned )
		{			
			if ( spawnCondition == SC_PlayerInRange )
			{
				if ( VecDistance2D( thePlayer.GetWorldPosition(), npc.GetWorldPosition() ) < distToActors )
				{
					if ( useSwarms )
					{
						SpawnFromSwarm();
					}
					ActivateSpawn();
				}
			}
			else if ( npc.GetBehaviorVariable( 'SpawnAnim' ) >= 1.f )
			{
				if ( useSwarms )
				{
					SpawnFromSwarm();
				}
				ActivateSpawn();
			}
			
			Sleep( 0.1 );
		}
		return BTNS_Completed;
	}
	
	latent function SpawnFromSwarm()
	{
		var npc : CNewNPC = GetNPC();
		
		initialTime = GetLocalTime();
		initialTime += 30;
		
		if ( !spawnCount )
		{
			spawnCount = lair.GetSpawnCount();
		}
		
		
		while ( !res && !fail )
		{
			if ( lair.GetTeleportBirdCount() < spawnCount )
			{
				Sleep( 0.25 );
			}
			else
			{
				
				res = true;
			}
			TimeOut();
		}
		
		res = false;
		while ( !res )
		{
			
			if( animEventOccured )
			{					
				
				Sleep ( swarmStabilizeTime );
				
				lair.DespawnFromBirdMaster( spawnCount );
				despawnCalled = true;
				res = true;
			}
			Sleep( 0.01 );
		}
		
		if ( !fail )
		{
			Sleep( 0.25 );
			if( fxName )
			{
				npc.PlayEffect( fxName );
			}
		}
		
		res = false;
		while ( !res && !fail )
		{
			if ( lair.GetTeleportBirdCount() == 0 )
			{
				Sleep( 0.25 );
			}
			else
			{
				if( setAppearanceTo )
				{
					npc.SetAppearance( setAppearanceTo );
				}
				res = true;
			}
			TimeOut();
		}
	}
	
	function TimeOut()
	{
		
		currTime = GetLocalTime();
		if ( currTime > initialTime )
		{
			fail = true;
		}
	}
	
	latent function ActivateSpawn()
	{
		var npc : CNewNPC 	= GetNPC();
		var success 		: bool;
		var switchGravity 	: bool;
		var actors 			: array<CActor>;
		var dist 			: float;
		var i 				: int;
		
		time = GetLocalTime();
		
		if ( manageGravity && npc.GetBehaviorVariable( 'SpawnAnim' ) == 1.f )
		{
			((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetAnimatedMovement( false );
		}
		
		while ( time + delayMain > GetLocalTime() )
		{
			Sleep( 0.01f );
		}
		
		npc.SetBehaviorVariable( 'Spawn', 1.f );
		
		switchGravity = npc.GetBehaviorVariable( 'SpawnAnim' ) >= 2.f ;
		
		if ( switchGravity && manageGravity )
		{
			((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).SetAnimatedMovement( true );
		}
		if ( npc.GetBehaviorVariable( 'SpawnAnim' ) == 1.f )
		{
			success = npc.WaitForBehaviorNodeDeactivation('SpawnEnd', 6.f );
		}
		else if ( npc.GetBehaviorVariable( 'SpawnAnim' ) > 1.f )
		{
			
			success = npc.WaitForBehaviorNodeDeactivation('SpawnEndShort', 6.f );
		}
		if ( success )
		{
			spawned = true;
		}
	}
	
	function FailSafeCheck()
	{
		var npc : CNewNPC 	= GetNPC();
		
		if ( ( !animEventOccured && !useSwarms ) || ( useSwarms && ( fail || !res )) )
		{
			if( setAppearanceTo )
			{
				npc.SetAppearance( setAppearanceTo );
			}
			if( IsNameValid(fxName) && playFXOnAnimEvent )
			{
				npc.PlayEffect( fxName );
			}
		}
		if ( useSwarms && !despawnCalled )
		{
			lair.DespawnFromBirdMaster( spawnCount );
		}
	}
	
	function OnDeactivate() : EBTNodeStatus
	{
		var npc 	: CNewNPC = GetNPC();
		
		FailSafeCheck();
		npc.SetCanPlayHitAnim( true );
		return BTNS_Completed;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if ( animEventName == animEventNameActivator && !useSwarms )
		{
			animEventOccured = true;
			if( setAppearanceTo )
			{
				npc.SetAppearance( setAppearanceTo );
			}
			if( IsNameValid(fxName) && playFXOnAnimEvent )
			{
				npc.PlayEffect( fxName );
			}
			return true;
		}
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( useSwarms && eventName == 'BoidGoToRequestCompleted' )
		{
			animEventOccured = true;
			return true;
		}
		return false;
	}
};

class CBTTaskSwarmSpawnAnimDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSwarmSpawnAnim';
	
	editable var useSwarms			: bool;
	editable var manageGravity 		: bool;
	editable var spawnCondition		: ESpawnCondition;
	editable var swarmStabilizeTime	: float;
	editable var distToActors 		: float;
	editable var delayMain			: float;
	editable var raiseEventName		: name;
	editable var fxName 			: name;
	editable var initialAppearance 	: name;
	editable var setAppearanceTo	: name;
	editable var playFXOnAnimEvent 	: bool;
	editable var animEventNameActivator : name;
	
	default useSwarms				= false;
	default swarmStabilizeTime		= 5.0;
	default spawnCondition			= SC_PlayerInRange;
	default manageGravity 			= false;
	default distToActors			= 30.f;
	
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'BoidGoToRequestCompleted' );
	}
};
