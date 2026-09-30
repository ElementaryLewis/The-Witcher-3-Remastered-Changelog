/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3TrapProjectileArea_CreateEntityHelper extends CCreateEntityHelper
{
	var owner 		: W3TrapProjectileArea;
	var velocity 	: float;
	var targetPos 	: Vector;
	
	event OnEntityCreated( entity : CEntity )
	{
		var projectileToShoot : W3AdvancedProjectile;
	
		if ( owner )
		{
			projectileToShoot = (W3AdvancedProjectile)entity;			
			projectileToShoot.Init( owner );
			projectileToShoot.ShootProjectileAtPosition( 0, velocity, targetPos );
			owner = NULL;
		}
		else
		{
			entity.Destroy();
		}
	}
}

class W3TrapProjectileArea extends W3Trap
{
	
	
	
	
	private editable var projectile 				: CEntityTemplate;
	private editable var density					: float;
	private editable var maxShots					: int;
	private editable var reloadAtActivation			: bool;
	private editable var projAtOnce					: SRange;
	private editable var delay						: SRangeF;
	private editable var targetPlayerDelay			: SRangeF;
	private editable var height						: SRangeF;
	private editable var velocity					: SRangeF;
	private editable var projectileOriginOffsetX	: SRangeF;
	private editable var projectileOriginOffsetY	: SRangeF;
	private editable var shootOnlyWhenTargetInside	: bool;
	private editable var deactivateAutomatically	: bool;
	private editable var useAdvancedDistribution	: bool;
	private editable var useGridPositioning			: bool;
	private editable var excludedEntityTags			: array <name>;
	private editable var magnetTags					: array<name>;
	private editable var magnetRange				: float;
	private editable var magnetOffset				: Vector;
	private editable var maxDistanceFromPlayer		: float;
	private editable var forbidingAreaRadius		: float;
	
	default density 				= 1;
	default maxShots 				= -1;
	default deactivateAutomatically = false;
	default useGridPositioning 		= true;
	default magnetRange				= 5;
	default maxDistanceFromPlayer	= -1;
	default forbidingAreaRadius		= -1;
	
	hint projectile 				= "Projectile to fire";
	hint density 					= "Projectile by square meter";
	hint maxShots 					= "Negative means infinite - Stop shooting after that much has been fired";
	hint reloadAtActivation 		= "Will shoot maxShots quantity everytime it is activated";
	hint projAtOnce 				= "How many projectile can be shot simultaneously every 'delay'";
	hint delay 						= "Period between each shoot";
	hint targetPlayerDelay 			= "[-1 means never] Everytime this delay is over, a projectile will land in player's vicinity (precision depends on density)";
	hint height 					= "Height of projectile origin from root of the trap entity";
	hint velocity 					= "Velocity of each projectile";
	hint projectileOriginOffsetX 	= "X offset of orgin position from landing position";
	hint projectileOriginOffsetY 	= "Y offset of orgin position from landing position";
	hint shootOnlyWhenTargetInside 	= "When active, the trap will only shoot when a target is inside the trigger";
	hint deactivateAutomatically 	= "Should the trap deactivate automatically when a target leaves its area";
	hint useAdvancedDistribution 	= "[More Costly] Cycle throught all the possible position to make sure everywhere is hit";
	hint useGridPositioning 		= "Using the grid is cheaper - but the result may look unnatural with big projectiles at low density";
	hint excludedEntityTags 		= "Entities with this tag will not trigger the trap";
	hint magnetTags					= "If an entity with one of these tags is at 'magnetRange' distance from the landing position of the projectile, the proj will snap its pos on the entity's";
	hint magnetTags					= "distance to detect entities with magnetTags";
	hint magnetOffset				= "Landing position offest from magnetisation target position";
	hint maxDistanceFromPlayer		= "[More Costly | works poorly with advancedDistribution] No projectile will land further than this distance from player (-1 means no limit)";
	hint forbidingAreaRadius			= "Every projectile landing will create an area around which no other projectile is allowed to land (-1 means no forbiding)";
	
	
	private var m_AreaComponent				: CTriggerAreaComponent;	
	private var m_ProjectilePositionGrid	: array<Vector>;
	private var m_UsedProjectilePosition	: array<Vector>;	
	private var m_AcceptablePos				: array<Vector>;
	private var m_ForbiddenPos				: array<Vector>;
	private var m_LastPlayerCheckedPos		: Vector;
	private var m_LastQuantOfForbidAreas	: int;
	private var m_GridSquareWidth			: float;
	private var m_GridSquareLength			: float;
	private var m_DelayUntilNextShoot		: float;
	private var m_DelayUntilNextPlayerShoot	: float;
	private var m_QuantityShotNext			: int;
	
	private var m_PlayerIsInArea			: bool;
	private var m_TargetsInArea				: array<CEntity>;
	
	private var m_CreateEntityHelper		: W3TrapProjectileArea_CreateEntityHelper;
	private var m_EntityCreated				: int;
	private var m_WasCreatingLastFrame		: bool;
	private var m_Shot						: bool;
	
	private var m_DebugFloat				: float;
	private var m_DebugIndex				: int;
	
	
	
	private saved var m_TotalQuantityShot	: int;
	
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		super.OnSpawned( spawnData );
		
		m_AreaComponent = (CTriggerAreaComponent) GetComponentByClassName('CTriggerAreaComponent');
		GeneratePositionGrid();
		
		m_QuantityShotNext 			= RandRange( projAtOnce.max, projAtOnce.min );
		m_DelayUntilNextPlayerShoot = RandRangeF( targetPlayerDelay.max, targetPlayerDelay.min );
		
		m_CreateEntityHelper 		= new W3TrapProjectileArea_CreateEntityHelper in theGame;
		
		
		
	}
	
	
	private function GeneratePositionGrid()
	{
		var x, y			: int;
		var l_cornerA		: Vector;
		var l_cornerB		: Vector;
		var l_length		: float;
		var l_width			: float;
		
		var l_widthVector	: Vector;
		var l_lengthVector	: Vector;
		
		var l_areaPoints	: array<Vector>;
		var l_startPoint	: Vector;
		
		var l_totalSquaresW	: int;
		var l_totalSquaresL	: int;
		
		var l_position		: Vector;
		
		m_AreaComponent.GetWorldPoints( l_areaPoints ) ;
		
		l_startPoint	= l_areaPoints[0];
		
		l_widthVector 	= l_areaPoints[1] - l_startPoint;
		l_lengthVector 	= l_areaPoints[3] - l_startPoint;
		
		l_width 	= VecLength( l_widthVector );
		l_length 	= VecLength( l_lengthVector );
		
		m_GridSquareWidth 	= l_width / ( l_width * density );
		m_GridSquareLength 	= l_length / ( l_length * density );
		
		l_totalSquaresW = CeilF( l_width / m_GridSquareWidth ); 
		l_totalSquaresL = CeilF( l_length / m_GridSquareLength ); 
		
		l_widthVector = VecNormalize( l_widthVector ) * m_GridSquareWidth;
		l_lengthVector = VecNormalize( l_lengthVector ) * m_GridSquareLength;
		
		m_ProjectilePositionGrid.Clear();
		for	( x = 0; x < l_totalSquaresL; x += 1 )
		{
			for ( y = 0; y < l_totalSquaresW ; y += 1 )
			{
				l_position = l_startPoint + l_widthVector * y + l_lengthVector * x;
				m_ProjectilePositionGrid.PushBack( l_position );
			}
		}
		
		if( useAdvancedDistribution )
		{
			ShufflePositionArray();
		}
		
		
	}
	
	
	private function ShufflePositionArray()
	{
		var l_baseArray 	: array<Vector>;
		var l_shuffleArray 	: array<Vector>;		
		var l_randomIndex	: int;
		
		l_baseArray = m_ProjectilePositionGrid;
		
		do
		{
			l_randomIndex 	= RandRange( l_baseArray.Size() );
			l_shuffleArray.PushBack( l_baseArray[ l_randomIndex ] );
			l_baseArray.Erase( l_randomIndex );
			
		} while( l_baseArray.Size() > 0 );
		
		m_ProjectilePositionGrid = l_shuffleArray;
	}
	
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var l_entity : CEntity;
		l_entity = activator.GetEntity();
		
		if( ShouldExcludeEntity( l_entity ) ) return false;
		
		if( !m_TargetsInArea.Contains( l_entity ) )
		{
			m_TargetsInArea.PushBack( l_entity );
		}
		
		if( activator.GetEntity() == thePlayer )
		{
			m_PlayerIsInArea = true;
		}
		
		if( m_IsActive )
		{
			Activate( activator );
		}
	}
	
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var l_entity : CEntity;
		
		l_entity = activator.GetEntity();
		
		if( ShouldExcludeEntity( activator.GetEntity() ) ) return false;
		
		if( activator.GetEntity() == thePlayer )
		{
			m_PlayerIsInArea = false;
		}
		
		m_TargetsInArea.Remove( l_entity );
		
		if( m_TargetsInArea.Size() == 0 && deactivateAutomatically )
		{
			Deactivate( );
		}
	}
	
	
	public function Activate( optional _Target: CNode ):void
	{
		super.Activate( _Target );
		if( reloadAtActivation )
		{
			m_TotalQuantityShot = 0;
		}
	}
	
	
	private function ShouldExcludeEntity( _Entity : CNode ) : bool
	{
		var i			: int;
		var l_entityTags	: array <name>;
		
		if( _Entity && excludedEntityTags.Size() > 0 )
		{
			l_entityTags = _Entity.GetTags();
			for ( i = 0; i < excludedEntityTags.Size(); i += 1 )
			{
				if( l_entityTags.Contains( excludedEntityTags[i] ) )
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	
	
	private timer function Update( _dT:float , id : int):void
	{
		var i 			: int;
		var l_actor		: CActor;
		
		
		if( m_CreateEntityHelper.IsCreating() )
		{
			return;
		}
		else if( m_WasCreatingLastFrame )
		{
			m_WasCreatingLastFrame = false;
			m_EntityCreated += 1;
			
			if( m_EntityCreated < m_QuantityShotNext )
			{
				if( Shoot() )
				{
					m_Shot = true;
					return;
				}
			}
			else if( m_Shot )
			{
				m_DelayUntilNextShoot 	= RandRangeF( delay.max, delay.min );			
				m_QuantityShotNext 		= RandRange( projAtOnce.max, projAtOnce.min );
			}
			else
			{
				
				m_DelayUntilNextShoot	= 0.5f;
				m_QuantityShotNext 		= RandRange( projAtOnce.max, projAtOnce.min );
			}
		}
		
		m_EntityCreated = 0;
		
		for ( i = m_TargetsInArea.Size() - 1; i >= 0; i -= 1 )
		{
			l_actor = (CActor) m_TargetsInArea[i];			
			if( l_actor && !l_actor.IsAlive() )
			{
				m_TargetsInArea.EraseFast(i);
			}
		}
		
		if( shootOnlyWhenTargetInside && m_TargetsInArea.Size() <= 0 ) return;
		
		m_DelayUntilNextShoot 		-= _dT;
		if( targetPlayerDelay.max >= 0 )
		{
			m_DelayUntilNextPlayerShoot -= _dT;
		}
		
		if( m_DelayUntilNextShoot <= 0 &&  ( maxShots < 0 || m_TotalQuantityShot <= maxShots ) )
		{
			m_Shot = false;			
			
			if( Shoot() )
			{
				m_Shot = true;
			}		
		}				
	}
	
	
	private function Shoot( ) : bool
	{
		var l_projectileToShoot : W3AdvancedProjectile;
		var l_targetPos			: Vector;
		var l_originPos			: Vector;
		var l_rotation			: EulerAngles;
		var l_forwardVector		: Vector;
		var l_targetPlayer		: bool;
		
		
		if( m_TotalQuantityShot > maxShots && maxShots >= 0 ) return false;
		
		if( m_DelayUntilNextPlayerShoot <= 0 && m_PlayerIsInArea && targetPlayerDelay.max >= 0)
		{
			l_targetPlayer = true;
			m_DelayUntilNextPlayerShoot = RandRangeF( targetPlayerDelay.max, targetPlayerDelay.min );
		}
		
		if( l_targetPlayer )
		{
			l_targetPos = thePlayer.GetWorldPosition() + VecRingRand( m_GridSquareLength, m_GridSquareWidth );
		}
		else
		{
			l_targetPos 	= PickRandomShootPosition();
			if( l_targetPos == Vector(0,0,0) )
				return false;
		}
		
		if( !useGridPositioning && !l_targetPlayer )
		{
			l_targetPos += VecRingRand( m_GridSquareLength, m_GridSquareWidth );
		}		
		
		MagnetLandingPosition ( l_targetPos );
		
		
		if( maxDistanceFromPlayer >= 0 && VecDistance( thePlayer.GetWorldPosition(), l_targetPos ) > maxDistanceFromPlayer )
		{
			return false;
		}
		
		
		if( forbidingAreaRadius > 0 )
		{
			m_ForbiddenPos.PushBack( l_targetPos );
		}
		
		
		l_originPos 	= l_targetPos + Vector( RandRangeF( projectileOriginOffsetX.max, projectileOriginOffsetX.min ), 
												RandRangeF( projectileOriginOffsetY.max, projectileOriginOffsetY.min ) , 
												RandRangeF( height.max, height.min ) );
		
		
		l_forwardVector = l_targetPos - l_originPos;
		l_rotation 		= VecToRotation( l_forwardVector );
	
		
		m_CreateEntityHelper.Reset();
		m_CreateEntityHelper.owner = this;
		m_CreateEntityHelper.velocity = RandRangeF( velocity.max, velocity.min );
		m_CreateEntityHelper.targetPos = l_targetPos;
		m_CreateEntityHelper.SetPostAttachedCallback( m_CreateEntityHelper, 'OnEntityCreated' );
		
		theGame.CreateEntityAsync( m_CreateEntityHelper, projectile, l_originPos, l_rotation );	
		m_WasCreatingLastFrame = true;
		
		m_TotalQuantityShot += 1;
		
		return true;
	}
	
	
	private function MagnetLandingPosition( out _Position : Vector )
	{
		var t, e		: int;
		var l_magnetPos	: Vector;
		var l_actor		: CActor;
		var l_entities	: array<CGameplayEntity>;
		
		for( t = 0; t < magnetTags.Size(); t += 1 )
		{
			l_entities.Clear();
			FindGameplayEntitiesCloseToPoint( l_entities, _Position, magnetRange, 99, magnetTags[t] );
			for ( e = 0; e < l_entities.Size(); e += 1 )
			{
				
				l_actor = (CActor) l_entities[e];				
				if( l_actor && !l_actor.IsAlive() )
				{ 
					continue;
				}
				
				l_magnetPos = l_entities[e].GetWorldPosition() + magnetOffset;
				
				if( m_AreaComponent.TestPointOverlap( l_magnetPos ) )
				{
					_Position = l_magnetPos;
					return;
				}
			}
		}
	}
	
	
	private function PickRandomShootPosition() : Vector
	{
		var l_randomIndex 		: int;
		var l_playerPos			: Vector;
		var l_position			: Vector;
		var l_minMoveDistance	: float;
		
		
		if( useAdvancedDistribution )
		{	
			if( m_ProjectilePositionGrid.Size() == 0 )
			{
				m_ProjectilePositionGrid = m_UsedProjectilePosition;
				m_UsedProjectilePosition.Clear();
			}
			
			l_position = m_ProjectilePositionGrid[ m_ProjectilePositionGrid.Size() - 1 ];
			
			
			if( maxDistanceFromPlayer >= 0 && VecDistance( thePlayer.GetWorldPosition(), l_position ) > maxDistanceFromPlayer )
			{
				return l_position;
			}
			
			
			m_ProjectilePositionGrid.PopBack();
			m_UsedProjectilePosition.PushBack( l_position );
			
			return l_position;
		}
		else
		{
			if( maxDistanceFromPlayer >= 0 || forbidingAreaRadius > 0 )
			{
				
				if( maxDistanceFromPlayer >= 0 && forbidingAreaRadius > 0 )
					l_minMoveDistance = MinF( maxDistanceFromPlayer, forbidingAreaRadius );
				else
					l_minMoveDistance = MaxF( maxDistanceFromPlayer, forbidingAreaRadius );
				
				l_minMoveDistance *= 0.3f;
				
				if( m_LastQuantOfForbidAreas < m_ForbiddenPos.Size() || VecDistance( thePlayer.GetWorldPosition(), m_LastPlayerCheckedPos ) > l_minMoveDistance )
				{
					l_playerPos		= thePlayer.GetWorldPosition();
					m_AcceptablePos = m_ProjectilePositionGrid;
					if( maxDistanceFromPlayer >= 0 )
					{
						m_AcceptablePos 		= PosCloseToPoint( m_AcceptablePos, l_playerPos, maxDistanceFromPlayer );
					}
					if( forbidingAreaRadius > 0 )
					{
						m_AcceptablePos			= PosNotForbidden( m_AcceptablePos );
					}
					m_LastPlayerCheckedPos 		= l_playerPos;
					m_LastQuantOfForbidAreas 	= m_ForbiddenPos.Size();
				}
				
				if( m_AcceptablePos.Size() == 0 )
				{
					return Vector( 0, 0, 0 );	
				}
				
				l_randomIndex = RandRange( m_AcceptablePos.Size() );
				return m_AcceptablePos[ l_randomIndex ];
			}
			else
			{
				l_randomIndex = RandRange( m_ProjectilePositionGrid.Size() );
				return m_ProjectilePositionGrid[ l_randomIndex ];
			}
		}
	}
	
	
	private function PosCloseToPoint( _PosToFilter: array<Vector>, _Center : Vector, _Distance : float) : array<Vector>
	{
		var i, s, l_numToSkip 	: int;
		var l_playerPos 		: Vector;
		var l_pos				: array<Vector>;
		
		l_pos = _PosToFilter;
		
		
		
		
		l_numToSkip = RoundF( ( _Distance * 0.1f ) / m_GridSquareWidth );
		
		for( i = l_pos.Size() - 1 ; i >= 0 ; i -= i + l_numToSkip )
		{
			if( VecDistance( _Center, l_pos[i] ) > _Distance )
			{	
				
				for( s = 0; s <= l_numToSkip && (i - s) >= 0; s += 1 )
				{
					l_pos.EraseFast( i - s );
				}
			}
		}
		
		return l_pos;
	}
	
	
	private function PosNotForbidden( _PosToFilter: array<Vector> ) : array<Vector>
	{
		var i, f, l_numToSkip 	: int;
		var l_pos				: array<Vector>;
		
		l_pos = _PosToFilter;
		
		for( i = l_pos.Size() - 1 ; i >= 0 ; i -= 1 )
		{
			for( f = 0; f < m_ForbiddenPos.Size(); f += 1 )
			{
				if( VecDistance( m_ForbiddenPos[f], l_pos[i] ) < forbidingAreaRadius )
				{				
					l_pos.EraseFast( i );
					break;
				}
			}
		}
		
		return l_pos;
	}
	
	
}