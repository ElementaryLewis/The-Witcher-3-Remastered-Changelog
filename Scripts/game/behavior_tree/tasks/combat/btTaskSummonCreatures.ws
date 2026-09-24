/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSummonCreatures extends CBTTaskAttack
{
	var dontResummonUntilMinionsAreDead 		: bool;
	var preventActivationUntilMinionsAreDead 	: bool;
	var teleportOutsidePlayerFOV 				: bool;
	var killSummonedCreaturesOnSummonerDeath	: bool;
	var spawnOnAnimEventName					: name;
	var entityToSummonName						: name;
	var raiseEventOnSummon						: name;
	var entityTemplate 							: CEntityTemplate;
	var overrideAttitude						: bool;
	var attitudeToPlayer						: EAIAttitude;
	var count 									: int;
	var minDistance, maxDistance 				: float;
	var spawnAnimation 							: EExplorationMode;
	var forcedSpawnAnim 						: int;
	var spawnTag 								: name;
	var spawnedNPCs 							: array< CNewNPC >;
	var minions 								: array< CGameplayEntity >;
	var respawnTime 							: array< EngineTime >;
	var respawnNeeded 							: array< bool >;
	var respawnDelay 							: float;
	var targetShouldBeAccessible				: bool;
	var spawnerShouldBeAccessible				: bool;
	var summonActivated							: bool;
	var spawnConditionsCheckInterval			: float;
	var spawnConditionsChecksNumber				: int;
	
	
	function IsAvailable() 	: bool
	{
		if ( preventActivationUntilMinionsAreDead )
		{
			return MinionNumberCheck();
		}
		return true;
	}
	
	latent function Main() : EBTNodeStatus
	{
		if( IsNameValid( entityToSummonName ) )
		{
			entityTemplate = ( CEntityTemplate ) LoadResourceAsync( entityToSummonName );
		}
		
		if ( !IsNameValid( spawnOnAnimEventName ) )
		{
			spawnedNPCs.Clear(); 
			respawnTime.Clear();
			respawnNeeded.Clear();
			
			spawnedNPCs.Grow(count);
			respawnTime.Grow(count);
			respawnNeeded.Grow(count);		
			
			summonActivated = true;
		}
		while ( !summonActivated )
		{
			SleepOneFrame();
		}
		
		if ( ( dontResummonUntilMinionsAreDead && MinionNumberCheck() ) || !dontResummonUntilMinionsAreDead )
		{
			SummonCreatures();
		}
		
		return BTNS_Active;
	}

	function OnDeactivate()
	{
		super.OnDeactivate();
	}
	
	latent function SummonCreatures() : bool
	{
		var i 						: int;		
		var npc 					: CNewNPC = GetNPC();
		var spawnPos 				: Vector;
		var spawnRot 				: EulerAngles;
		var freeSpawnPos 			: Vector;
		var	normal					: Vector;
		var cameraToPlayerDistance 	: float;
		var failed 					: bool;
		var createEntityHelper		: CCreateEntityHelper;
		var numberOfTries			: int;
		
		
		
		
		for ( i = 0; i < count; i += 1 )
		{	
			numberOfTries = 0;
			do
			{
				if ( teleportOutsidePlayerFOV )
				{
					cameraToPlayerDistance = VecDistance( theCamera.GetCameraPosition(), thePlayer.GetWorldPosition() );
					if ( cameraToPlayerDistance*1.2 > minDistance )
					{
						minDistance = cameraToPlayerDistance*1.2;
						maxDistance = ( maxDistance + ( cameraToPlayerDistance - minDistance ))*1.2;
					}
					spawnPos = VecConeRand( (theCamera.GetCameraHeading() ), 180, minDistance, maxDistance );
					freeSpawnPos = theCamera.GetCameraPosition() - spawnPos;
					theGame.GetWorld().StaticTrace( freeSpawnPos + Vector(0,0,3), freeSpawnPos - Vector(0,0,3), freeSpawnPos, normal );
				}
				else
				{
					spawnPos = VecRingRand( minDistance, maxDistance );
					freeSpawnPos = npc.GetWorldPosition() + spawnPos;
					theGame.GetWorld().StaticTrace( freeSpawnPos + Vector(0,0,3), freeSpawnPos - Vector(0,0,3), freeSpawnPos, normal );
				}
				spawnRot = VecToRotation( spawnPos - GetCombatTarget().GetWorldPosition() );
				
				if ( !NavTest( freeSpawnPos ) )
				{
					failed = true;
					Sleep( spawnConditionsCheckInterval );
				}
				else
				{
					failed = false;
				}
				numberOfTries+=1;
			}while( failed && numberOfTries < spawnConditionsChecksNumber );
			
			if( !failed )
			{
				createEntityHelper = new CCreateEntityHelper in this;
				createEntityHelper.SetPostAttachedCallback( this, 'OnMinionAttached' );
				theGame.CreateEntityAsync( createEntityHelper, entityTemplate, freeSpawnPos, spawnRot, true, false, false, PM_DontPersist );
				summonActivated = false;
			}
		}
		
		return failed;
	}
	
	function NavTest( _PosToTest : Vector ) : bool
	{	
		var l_targetPos, l_ownerPos : Vector;
		var npc 					: CNewNPC = GetNPC();
		
		if ( !theGame.GetWorld().NavigationCircleTest( _PosToTest, npc.GetRadius() ) )
		{
			return false;
		}		
		
		if( targetShouldBeAccessible )
		{
			l_targetPos = GetCombatTarget().GetWorldPosition();
			if( !theGame.GetWorld().NavigationLineTest( _PosToTest, l_targetPos, npc.GetRadius(), false, true ) )
			{
				return false;
			}
		}
		
		if ( spawnerShouldBeAccessible )
		{
			l_ownerPos = GetNPC().GetWorldPosition();
			if( !theGame.GetWorld().NavigationLineTest( _PosToTest, l_ownerPos, npc.GetRadius(), false, true ) )
			{
				return false;
			}
		}
		
		return true;
	}
	
	function OnMinionAttached( minionEntity : CEntity )
	{
		var i 		: int;
		var summon 	: CNewNPC;
		var npc 	: CNewNPC = GetNPC();
		
		summon = ( CNewNPC ) minionEntity;
		if ( summon )
		{
			spawnedNPCs[i] = summon;
			if ( overrideAttitude )
			{
				summon.SetAttitude( thePlayer, attitudeToPlayer );
			}
			else
			{
				summon.SetBaseAttitudeGroup( npc.GetAttitudeGroup() );
			}
			summon.SetBehaviorVariable( 'SpawnAnim', (int)spawnAnimation );
			summon.AddTag( spawnTag );
			summon.DeriveGuardArea( npc );
			
			if( forcedSpawnAnim >= 0 )
			{
				summon.SetBehaviorVariable( 'ForcedSpawnAnim', forcedSpawnAnim );
			}
			
			if ( summon.GetBehaviorVariable( 'SpawnAnim' ) == 1.f && summon.GetDistanceFromGround( 3 ) > 1.5f )
			{
				((CMovingPhysicalAgentComponent)summon.GetMovingAgentComponent()).SetAnimatedMovement( false );
			}
			
			if ( IsNameValid( raiseEventOnSummon ) )
			{
				summon.RaiseEvent( raiseEventOnSummon );
			}
		}
	}
	
	function MinionNumberCheck() : bool
	{
		var npc : CNewNPC = GetNPC();
		var i : int;
		var minionsSize: int;
		
		if ( !IsNameValid( spawnTag ))
		{
			Log ( "no tag has been set for spawned actors" );
			return false;
		}
		minions.Clear();
		FindGameplayEntitiesInRange( minions, npc, 250, 5, spawnTag, FLAG_OnlyAliveActors );
		minionsSize = minions.Size();
		
		if ( minions.Size() < 1 )
		{
			return true;
		}
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var i : int;
	
		if ( killSummonedCreaturesOnSummonerDeath && eventName == 'Death' )
		{
			if ( minions.Size() < 1 )
			{
				MinionNumberCheck();
			}
			for ( i = 0; i < minions.Size(); i += 1 )
			{
				((CActor)minions[i]).Kill( 'Summoner Death', true );
			}
			return true;
		}
		return false;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var i, j : int;
		var encounters : array< CGameplayEntity >;
		var creatureEntries : array< CCreatureEntry >;
		var npc : CNewNPC = GetNPC();
		
		if ( IsNameValid( spawnOnAnimEventName ) && animEventName == spawnOnAnimEventName )
		{
			spawnedNPCs.Clear(); 
			respawnTime.Clear();
			respawnNeeded.Clear();
			
			spawnedNPCs.Grow(count);
			respawnTime.Grow(count);
			respawnNeeded.Grow(count);		
			
			summonActivated = true;
			
			
		}
		return super.OnAnimEvent(animEventName,animEventType,animInfo);
	}
};

class CBTTaskSummonCreaturesDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskSummonCreatures';

	editable var dontResummonUntilMinionsAreDead 		: bool;
	editable var preventActivationUntilMinionsAreDead	: bool;
	editable var teleportOutsidePlayerFOV 				: bool;
	editable var killSummonedCreaturesOnSummonerDeath	: bool;
	editable var spawnOnAnimEventName					: name;
	editable var entityToSummonName						: name;
	editable var raiseEventOnSummon						: name;
	editable var overrideAttitude						: bool;
	editable var attitudeToPlayer						: EAIAttitude;
	editable var count 									: int;
	editable var minDistance, maxDistance 				: float;
	editable var spawnAnimation 						: EExplorationMode;
	editable var forcedSpawnAnim 						: int;
	editable var spawnTag 								: name;
	editable var targetShouldBeAccessible				: bool;
	editable var spawnerShouldBeAccessible				: bool;
	editable var spawnConditionsCheckInterval			: float;
	editable var spawnConditionsChecksNumber			: int;
	
	default dontResummonUntilMinionsAreDead = true;
	default teleportOutsidePlayerFOV = true;
	default overrideAttitude = true;
	default spawnOnAnimEventName = 'Summon';
	default attitudeToPlayer = AIA_Hostile;
	default count = 1;
	default minDistance = 5;
	default maxDistance = 10;
	default spawnAnimation = EM_Ground;
	default spawnConditionsCheckInterval = 0.1;
	default spawnConditionsChecksNumber = 100;
	default forcedSpawnAnim = -1;
	
	hint entityToSummonName = "resource name from globals\resources\gameplay.xml";
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'Death' );
	}
};
