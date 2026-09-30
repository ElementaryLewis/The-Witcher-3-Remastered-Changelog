/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskDropProjectilesFromAbove extends IBehTreeTask
{
	public var resourceName 					: name;
	public var activeOnAnimEvent 				: name;
	public var chanceToGuaranteePlayerHit 		: float;
	public var timeBetweenSpawn 				: float;
	public var timeBetweenSpawnRandomizationPerc: float;
	public var minDistFromTarget 				: float;
	public var maxDistFromTarget 				: float;
	public var minDistFromEachOther 			: float;
	public var minYOffset 						: float;
	public var maxYOffset 						: float;
	public var useCombatTarget 					: bool;
	public var useOwnerAsTarget 				: bool;
	
	private var target 							: CActor;
	private var entityTemplate 					: CEntityTemplate;
	private var usedPos 						: array<Vector>;
	private var activated 						: bool;
	
	
	function Initialize()
	{
		entityTemplate = (CEntityTemplate)LoadResource( resourceName );	
	}
	
	function OnActivate() : EBTNodeStatus
	{
		activated = false;
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var pos 			: Vector;
		var spawnInterval 	: float;
		var i 				: int;
		
		
		usedPos.Clear();
		timeBetweenSpawnRandomizationPerc = timeBetweenSpawn * timeBetweenSpawnRandomizationPerc;
		if ( useOwnerAsTarget )
		{
			target = GetNPC();
		}
		else if ( useCombatTarget )
		{
			target = GetCombatTarget();
		}
		else
		{
			target = (CActor) GetActionTarget();
		}
		
		if ( !IsNameValid( activeOnAnimEvent ) )
		{
			activated = true;
		}
		else
		{
			while ( !activated )
			{
				SleepOneFrame();
			}
		}
		
		while( activated )
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
			
			if ( timeBetweenSpawnRandomizationPerc > 0 )
			{
				spawnInterval = RandRangeF( timeBetweenSpawn + timeBetweenSpawnRandomizationPerc, timeBetweenSpawn - timeBetweenSpawnRandomizationPerc );
				Sleep( spawnInterval );
			}
			else
			{
				Sleep( timeBetweenSpawn );
			}
		}
		
		return BTNS_Active;
	}
	
	final function Spawn( position : Vector )
	{
		var entity 				: CEntity;
		var projectile 			: W3AdvancedProjectile;
		var spawnPos 			: Vector;
		var traceStart 			: Vector;
		var traceOffset			: Vector;
		var normal 				: Vector;
		var rotation 			: EulerAngles;
		var collisionGroups 	: array<name>;
		var randY 				: float;
		
		if( entityTemplate )
		{
			collisionGroups.PushBack( 'Terrain' );
			collisionGroups.PushBack( 'Static' );
			collisionGroups.PushBack( 'Ragdoll' );
			collisionGroups.PushBack( 'Character' );
			
			randY = RandRangeF( maxYOffset, minYOffset );
			traceOffset = position;
			traceOffset.Y += randY;
			traceStart = traceOffset;
			traceStart.Z += 1;
			traceOffset.Z += 50;
			
			theGame.GetWorld().StaticTrace( traceStart, traceOffset, spawnPos, normal );
			spawnPos.Z -= 1.5;
			
			entity = theGame.CreateEntity( entityTemplate, spawnPos, rotation );
			projectile = (W3AdvancedProjectile)entity;
			if( projectile )
			{
				projectile.Init( NULL );
				projectile.ShootProjectileAtPosition( projectile.projAngle, projectile.projSpeed, position, 500, collisionGroups );
			}
		}
	}
	
	final function FindPosition() : Vector
	{
		var randVec 	: Vector = Vector( 0.f, 0.f, 0.f );
		var targetPos 	: Vector;
		var outPos 		: Vector;
		
		if ( RandF() > chanceToGuaranteePlayerHit )
		{
			targetPos = target.GetWorldPosition();
			randVec = VecRingRand( minDistFromTarget, maxDistFromTarget );
			outPos = targetPos + randVec;
		}
		else
		{
			outPos = thePlayer.GetWorldPosition();
		}
		
		return outPos;
	}
	
	final function IsPositionValid( out whereTo : Vector ) : bool
	{
		var newPos 	: Vector;
		var z 		: float;
		var i 		: int;
		
		
		if( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, -1, 1, newPos ) )
		{
			if( theGame.GetWorld().NavigationComputeZ( whereTo, whereTo.Z - 5.0, whereTo.Z + 5.0, z ) )
			{
				whereTo.Z = z;
				if( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, 0, 1, newPos ) )
					return false;
			}
		}
		
		for( i = 0; i < usedPos.Size(); i += 1 )
		{
			if( VecDistance2D( newPos, usedPos[i] ) < minDistFromEachOther )
				return false;
		}
		
		whereTo = newPos;
		return true;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( IsNameValid( activeOnAnimEvent ) && animEventName == activeOnAnimEvent )
		{
			activated = true;
			return true;
		}
		
		return false;
	}
};

class CBTTaskDropProjectilesFromAboveDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDropProjectilesFromAbove';
	
	editable var resourceName 						: name;
	editable var activeOnAnimEvent 					: name;
	editable var chanceToGuaranteePlayerHit 		: float;
	editable var timeBetweenSpawn 					: float;
	editable var timeBetweenSpawnRandomizationPerc	: float;
	editable var minDistFromTarget 					: float;
	editable var maxDistFromTarget 					: float;
	editable var minDistFromEachOther 				: float;
	editable var minYOffset 						: float;
	editable var maxYOffset 						: float;
	editable var useCombatTarget 					: bool;
	editable var useOwnerAsTarget 					: bool;
	
	default resourceName 							= 'sharley_stone_proj';
	default chanceToGuaranteePlayerHit 				= 0.2;
	default timeBetweenSpawn 						= 1.0;
	default timeBetweenSpawnRandomizationPerc 		= 1.0;
	default minDistFromTarget 						= 0.0;
	default maxDistFromTarget 						= 50.0;
	default minDistFromEachOther 					= 3.0;
	default useCombatTarget 						= true;
};
