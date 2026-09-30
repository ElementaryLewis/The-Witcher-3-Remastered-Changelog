/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class CMeteoriteStormEntity extends CGameplayEntity
{		
	editable var resourceName : name;
	editable var timeBetweenSpawn : float;
	editable var minDistFromTarget : float;
	editable var maxDistFromTarget : float;
	editable var minDistFromEachOther : float;
	
	var victim : CActor;
	var entityTemplate : CEntityTemplate;
	
	default resourceName = 'eredin_meteorite';
	default timeBetweenSpawn = 1.0;
	default minDistFromTarget = 1.5;
	default maxDistFromTarget = 8.0;
	default minDistFromEachOther = 3.0;
	
	default autoState = 'Idle';
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		entityTemplate = (CEntityTemplate)LoadResource( resourceName );
		GotoStateAuto();
	}
	
	public function Execute( actor : CActor )
	{
		victim = actor;
		GotoState( 'Storm' );
	}
}

state Idle in CMeteoriteStormEntity
{
}

state Storm in CMeteoriteStormEntity
{
	var usedPos : array<Vector>;
	
	event OnEnterState( prevStateName : name )
	{	
		Run();
	}
	
	event OnLeaveState( nextStateName : name )
	{
	}
	
	entry function Run()
	{
		var pos : Vector;
		var i : int;
		
		usedPos.Clear();
		
		while( VecDistance2D( parent.victim.GetWorldPosition(), parent.GetWorldPosition() ) < 100.0 )
		{
			pos = FindPosition();
			
			while( !IsPositionValid( pos ) )
			{
				SleepOneFrame();
				pos = FindPosition();
			}
			
			Spawn( pos );
			usedPos.PushBack( pos );
			if( usedPos.Size() > 5 )
				usedPos.Clear();
			Sleep( parent.timeBetweenSpawn );
		}
	}
	
	function Spawn( position : Vector )
	{
		var entity : CEntity;
		var meteorite : W3MeteorProjectile;
		var spawnPos : Vector;
		var randY : float;
		var rotation : EulerAngles;
		var collisionGroups : array<name>;
		
		if( parent.entityTemplate )
		{
			collisionGroups.PushBack( 'Terrain' );
			collisionGroups.PushBack( 'Static' );
		
			randY = RandRangeF( 30.0, 20.0 );
			spawnPos = position;
			spawnPos.Y += randY;
			spawnPos.Z += 50;
			
			entity = theGame.CreateEntity( parent.entityTemplate, spawnPos, rotation );
			meteorite = (W3MeteorProjectile)entity;
			if( meteorite )
			{
				meteorite.Init( NULL );
				meteorite.ShootProjectileAtPosition( meteorite.projAngle, meteorite.projSpeed, position, 500, collisionGroups );
			}
		}
	}
	
	function FindPosition() : Vector
	{
		var randVec : Vector = Vector( 0.f, 0.f, 0.f );
		var targetPos : Vector;
		var outPos : Vector;
		
		targetPos = parent.victim.GetWorldPosition();
		randVec = VecRingRand( parent.minDistFromTarget, parent.maxDistFromTarget );
		
		outPos = targetPos + randVec;
		
		return outPos;
	}
	
	protected function IsPositionValid( out whereTo : Vector ) : bool
	{
		var newPos : Vector;
		var radius : float;
		var z : float;
		var i : int;

		radius = parent.victim.GetRadius();
		
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
		
		for( i = 0; i < usedPos.Size(); i += 1 )
		{
			if( VecDistance2D( newPos, usedPos[i] ) < parent.minDistFromEachOther )
				return false;
		}
		

		whereTo = newPos;
		
		return true;
	}
}