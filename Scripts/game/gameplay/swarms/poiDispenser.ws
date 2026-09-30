/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3PointOfInterestEntity extends CGameplayEntity
{
	editable var toDestroy : bool;
	var assignedDispenser : W3POIDispenser;
	
	default toDestroy = true;
	
	function AssignDispenser( activator : W3POIDispenser )
	{
		assignedDispenser = activator;
	}
	
	function GetDispenser() : W3POIDispenser
	{
		return assignedDispenser;
	}
	
	function CanBeDestroyed() : bool
	{
		return toDestroy;
	}
}

struct W3POIEntities
{
	editable var poiEntityTemplate : CEntityTemplate;
	editable var maxSpawnedEntities : int;
	
	default maxSpawnedEntities = 3;
}

statemachine class W3POIDispenser extends CGameplayEntity
{
	editable var pointsTag : name;
	editable var onExitDespawnAllAfter : int;
	editable var shouldUseRandomRespawnTime : bool;
	editable var respawnInterval : float;
	editable var poiEntity: W3POIEntities;
	
	var spawnedPOIs : array< W3PointOfInterestEntity >;
	var activatorArea : CTriggerAreaComponent;
	
	default autoState = 'Inactive';
	default onExitDespawnAllAfter = 10;
	default shouldUseRandomRespawnTime = true;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		GotoStateAuto();
		
		activatorArea = (CTriggerAreaComponent)this.GetComponentByClassName( 'CTriggerAreaComponent' );
		
		if( IsPlayerNear() )
		{
			ActivateFoodDispenser( true );
		}
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{		
		if( area == activatorArea && IsDispenserAvailable() )
		{
			ActivateFoodDispenser( true );
		}
	}
	
	event OnAreaExtit( area : CTriggerAreaComponent, activator : CComponent )
	{
		ActivateFoodDispenser( false );
	}
	
	function IsDispenserAvailable() : bool
	{
		var allPoints : array< CNode >;
		
		allPoints = GetPOISpawnPoints();
		
		if ( pointsTag != '' && allPoints.Size() > 0 )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	function GetPOISpawnPoints() : array< CNode >
	{
		var points : array< CNode >;
		
		theGame.GetNodesByTag( pointsTag, points );
		
		return points;
	}
	
	function GetPointToActive() : CNode
	{
		var allPoints : array< CNode >;
		var i : int;
		
		allPoints = GetPOISpawnPoints();
		i = RandRange( allPoints.Size() );
		
		return allPoints[i];
	}
	
	function GetEntitySpawnPos( selectedPoint : CNode ) : Vector
	{
		var local2world : Matrix;
		var offset : Vector;
		var entSpawnPos : Vector;
		var terrainHeight : float;
		
		local2world = selectedPoint.GetLocalToWorld();
		
		offset = Vector( RandRangeF( 1.5f, -1.5f ), RandRangeF( 1.5f, -1.5f ), 0.f );
		
		entSpawnPos = VecTransform( local2world, offset );
		
		terrainHeight = entSpawnPos.Z;
		theGame.GetWorld().NavigationComputeZ( selectedPoint.GetWorldPosition(), terrainHeight - 2.0, terrainHeight + 2.0, terrainHeight );
		
		entSpawnPos.Z = terrainHeight + 0.05f;
		
		
		return entSpawnPos;
	}
	
	function GetRespawnInterval() : float
	{
		if( respawnInterval < 5 )
		{
			return respawnInterval;
		}
		else
		{
			return 10.f;
		}
		
	}
	
	function SpawnPOI()
	{
		var i : int;
		var entSpawnPoint : CNode;
		var spawnedFoodEntity : W3PointOfInterestEntity;
		
		entSpawnPoint = GetPointToActive();
		
		if( spawnedPOIs.Size() <= poiEntity.maxSpawnedEntities )
		{
			for( i = spawnedPOIs.Size(); i < poiEntity.maxSpawnedEntities; i += 1 )
			{
				spawnedFoodEntity = (W3PointOfInterestEntity)theGame.CreateEntity( poiEntity.poiEntityTemplate, GetEntitySpawnPos( entSpawnPoint ) );
				spawnedFoodEntity.AssignDispenser( this );
				spawnedPOIs.PushBack( spawnedFoodEntity );
			}
		}	
	}
	
	timer function RespawnPOI( deltaTime : float , id : int)
	{
		SpawnPOI();
	}
	
	function DespawnPOI( entity : W3PointOfInterestEntity )
	{
		var i : int;
		
		for(i=spawnedPOIs.Size()-1; i>=0; i-=1 )
		{
			if( entity == spawnedPOIs[i] )
			{
				spawnedPOIs.Erase(i);
				
				if(entity)		
					entity.Destroy();
			}
		}
	}
	
	function DeactivatePOI( entity : W3PointOfInterestEntity )
	{
		var i : int;
		
		for( i = 0; i < spawnedPOIs.Size(); i += 1 )
		{
			if( entity == spawnedPOIs[i] )
			{
				entity.GetComponentByClassName( 'CFoodBoidPointOfInterest' ).SetEnabled( false );
			}
		}
	}
	
	timer function DespawnAllPOIs( deltaTime : float , id : int)
	{
		var i : int;
		
		for(i=spawnedPOIs.Size()-1; i>=0; i-=1 )
		{
			spawnedPOIs[i].Destroy();
			spawnedPOIs.Erase(i);			
		}
	}
	
	function IsPlayerNear() : bool
	{
		var dispenserArea : CAreaComponent;
		
		dispenserArea = (CAreaComponent)activatorArea;
		
		return dispenserArea.TestEntityOverlap( (CEntity)thePlayer );
	}
	
	function ActivateFoodDispenser( isOn : bool )
	{
		if( isOn )
		{
			PushState( 'Active' );
		}
		else
		{
			PopState( true );
		}
	}
}

state Active in W3POIDispenser
{
	event OnEnterState( prevStateName : name )
	{
		ActivationInit();
	}
	
	entry function ActivationInit()
	{
		parent.SpawnPOI();
		
		if ( parent.shouldUseRandomRespawnTime )
		{
			parent.AddTimer( 'RespawnPOI', RandRangeF( 35.f, 25.f ), true );
		}
		else
		{
			parent.AddTimer( 'RespawnPOI', parent.respawnInterval, true );
		}
	}
}

state Inactive in W3POIDispenser
{
	event OnEnterState( prevStateName : name )
	{
		DeactivationInit();
	}
	
	entry function DeactivationInit()
	{
		parent.RemoveTimer( 'RespawnPOI' );
		parent.AddTimer('DespawnAllPOIs', parent.onExitDespawnAllAfter, false );
	}
}