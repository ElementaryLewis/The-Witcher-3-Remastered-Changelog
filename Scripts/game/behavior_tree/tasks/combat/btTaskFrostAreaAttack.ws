/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskFrostAreaAttack extends IBehTreeTask
{
	
	
	
	public 	var duration							: SRangeF;
	public  var spreadingSpeed						: float;
	public  var maxRadius							: float;
	public  var spawnAtOnce							: SRange;
	public 	var createArena							: bool;
	public 	var arenaAngle							: float;
	public  var scaleSpawnQuantityWithRadius		: bool;
	public  var spawnAttackDelay					: SRangeF;
	public  var spawnAttackOnTargetDelay			: SRangeF;
	public 	var spawnedEntityTemplates				: array<CEntityTemplate>;
	public 	var frostWallReloadDelay				: float;
	
	private var m_Npc								: CNewNPC;
	private var m_MinAttackRange					: float;
	private var m_FrostRange						: float;
	private var m_TimeToAttackOnTarget				: float;
	private var m_PostFxOnGroundCmp					: W3PostFXOnGroundComponent;
	
	default m_MinAttackRange = 3;
	
	
	
	function Initialize()
	{
		m_Npc				= GetNPC();
		m_PostFxOnGroundCmp = (W3PostFXOnGroundComponent) GetNPC().GetComponentByClassName( 'W3PostFXOnGroundComponent' );
	}
	
	
	latent function Main() : EBTNodeStatus
	{	
		var i							: int;
		var l_npcPos					: Vector;
		var l_targetPos					: Vector;
		var l_gameplayFX 				: CGameplayFXSurfacePost = theGame.GetSurfacePostFX();
		var l_timeLeft					: float;
		var l_lastLocalTime				: float;
		var l_deltaTime					: float;
		var l_timeUntilNextAttack		: float;
		var l_spawnQuantity				: int;
		var l_timeBeforeWallIsLoaded	: float;
		var l_radiusPercentage			: float;
		var l_timeToReachMaxRadius		: float;		
		
		
		var l_arenaRange				: float;
		var l_arenaPerimeter			: float;
		var l_spawnedEntityRadius		: float;
		var l_arenaSpawnQt				: float;
		var l_angleBetweenSpikes		: float;
		var l_spawnPos					: Vector;
		var l_forwardVector				: Vector;
		var l_rotation					: EulerAngles;
		var l_headingToTarget			: float;
		var l_startHeading				: float;
		
		l_timeLeft 					= RandRangeF( duration.max, duration.min );
		if( spreadingSpeed > 0 )
		{
			l_timeToReachMaxRadius	= maxRadius / spreadingSpeed;
		}
		else
		{
			l_timeToReachMaxRadius = 1;
		}
		m_TimeToAttackOnTarget	= RandRangeF( spawnAttackOnTargetDelay.max, spawnAttackOnTargetDelay.min );		
		
		
		if( m_PostFxOnGroundCmp ) m_PostFxOnGroundCmp.StopTicking();
		
		
		l_npcPos = m_Npc.GetWorldPosition();
		l_gameplayFX.AddSurfacePostFXGroup( l_npcPos, l_timeToReachMaxRadius, l_timeLeft, 1.0f,  maxRadius * 4, 0 );
		
		
		m_Npc.PlayEffect('marker');
		
		m_FrostRange = 0;
		if( spreadingSpeed < 0 )
		{
			m_FrostRange = maxRadius;
		}
		
		
		if( createArena )
		{
			l_arenaRange			= m_FrostRange * 1.0f;
			l_spawnedEntityRadius 	= 3.0f;
			
			l_arenaPerimeter 		= ( 2 * l_arenaRange * Pi() );
			l_arenaPerimeter		*= ( arenaAngle / 360);
			l_arenaSpawnQt			= l_arenaPerimeter / l_spawnedEntityRadius;
			l_angleBetweenSpikes	= arenaAngle / l_arenaSpawnQt;
			l_targetPos				= GetCombatTarget().GetWorldPosition();
			l_headingToTarget		= VecHeading( l_targetPos - l_npcPos );
			
			l_startHeading			= l_headingToTarget - ( arenaAngle * 0.5f );
			
			for	( i = 0; i < l_arenaSpawnQt ; i += 1 )
			{
				l_spawnPos 		= l_npcPos + VecConeRand( l_startHeading + i * l_angleBetweenSpikes, l_spawnedEntityRadius , l_arenaRange * 0.5f, l_arenaRange );
				
				l_forwardVector = l_npcPos - l_spawnPos; 
				l_rotation 		= VecToRotation( l_forwardVector );
				
				CreateEntity( l_spawnPos, l_rotation );
			}
		}
		
		while( l_timeLeft > 0 )
		{	
			l_lastLocalTime = GetLocalTime();
			SleepOneFrame();			
			l_deltaTime = GetLocalTime() - l_lastLocalTime;
			l_timeLeft -= l_deltaTime;
			
			if( spreadingSpeed > 0 )
			{
				m_FrostRange += spreadingSpeed * l_deltaTime;
			}
			m_FrostRange = ClampF( m_FrostRange, 0, maxRadius );
			
			l_timeUntilNextAttack 	-= l_deltaTime;
			m_TimeToAttackOnTarget 	-= l_deltaTime;
			
			if( l_timeUntilNextAttack <= 0 && m_FrostRange > m_MinAttackRange )
			{
				l_radiusPercentage = 1;
				if( scaleSpawnQuantityWithRadius )
				{
					l_radiusPercentage = m_FrostRange / maxRadius;
				}
				l_spawnQuantity		= RandRange( RoundF( l_radiusPercentage * spawnAtOnce.max ), RoundF( l_radiusPercentage * spawnAtOnce.min ) );
				l_spawnQuantity		= Clamp( l_spawnQuantity, Min( 1, spawnAtOnce.min ), spawnAtOnce.max );
				for( i = 0; i < l_spawnQuantity; i += 1 )
				{
					SpawnAttack();
				}
				
				l_timeUntilNextAttack 	= RandRangeF( spawnAttackDelay.max + ( 1 - l_radiusPercentage ) * spawnAttackDelay.max * 0.5f , spawnAttackDelay.min + ( 1 - l_radiusPercentage ) * spawnAttackDelay.min * 0.5f  );
			}
			
			if( frostWallReloadDelay >= 0  && m_FrostRange > m_MinAttackRange )
			{
				l_timeBeforeWallIsLoaded -= l_deltaTime;
				if( l_timeBeforeWallIsLoaded <= 0 )
				{
					l_targetPos = GetCombatTarget().GetWorldPosition();
					if( VecDistance2D( l_targetPos, l_npcPos ) < 5 )
					{
						SpawnDefenseWall();
						l_timeBeforeWallIsLoaded = frostWallReloadDelay;
					}
				}
			}
			
		}
		
		return BTNS_Completed;
	}
	
	
	private function SpawnDefenseWall()
	{
		var i					: int;
		var l_npcPos			: Vector;
		var l_target 			: CActor;
		var l_targetPos			: Vector;
		var l_spawnPos 			: Vector;
		var l_forwardVector		: Vector;
		var l_rotation			: EulerAngles;
		
		var l_headingToTarget	: float;
		var l_angleBetweenSpawn	: float;
		var l_randomDistance	: float;
		
		l_target 			= GetCombatTarget();
				
		l_npcPos 			= m_Npc.GetWorldPosition();
		l_targetPos 		= l_target.GetWorldPosition();
		
		l_headingToTarget 	= VecHeading( l_targetPos - l_npcPos );
		
		l_angleBetweenSpawn = 45;
		
		l_randomDistance = RandRangeF( 2, 1 );
		
		for( i = -1; i <= 1 ; i += 1 )
		{
			l_spawnPos 		= l_npcPos + VecConeRand( l_headingToTarget + ( i * l_angleBetweenSpawn ) , 1, l_randomDistance, l_randomDistance );
			l_forwardVector = l_spawnPos - l_npcPos;
			l_rotation 		= VecToRotation( l_forwardVector );
			CreateEntity( l_spawnPos, l_rotation );
		}
	}
	
	
	private function SpawnAttack()
	{
		var l_npcPos			: Vector;
		var l_target 			: CActor;
		var l_targetPos			: Vector;
		var l_spawnPos 			: Vector;
		var l_forwardVector		: Vector;
		var l_rotation			: EulerAngles;
		
		l_target 	= GetCombatTarget();		
		
		l_npcPos 	= m_Npc.GetWorldPosition();
		l_targetPos = l_target.GetWorldPosition();
		
		
		if( spawnAttackOnTargetDelay.max >= 0 && m_TimeToAttackOnTarget <= 0 && VecDistance2D( l_targetPos, l_npcPos ) < m_FrostRange && theGame.GetWorld().NavigationLineTest( l_npcPos, l_targetPos, m_Npc.GetRadius())) 
		{
			
			m_TimeToAttackOnTarget = RandRangeF( spawnAttackOnTargetDelay.max, spawnAttackOnTargetDelay.min );
			if( l_target.HasBuff( EET_HeavyKnockdown ) || l_target.HasBuff( EET_Knockdown ) ||  l_target.HasBuff( EET_KnockdownTypeApplicator ) ) 
			{	
				return;
			}
			l_spawnPos 	= l_targetPos;
			l_spawnPos += VecRingRand( 0, 4 );
		}
		else
		{
			l_spawnPos = l_npcPos + VecRingRand( m_MinAttackRange, m_FrostRange );
			
			if ( VecDistance2D( l_spawnPos, l_targetPos ) < 2 )
			{
				return;
			}
		}
		
		l_forwardVector = l_spawnPos - l_npcPos;
		l_rotation 		= VecToRotation( l_forwardVector );
		
		CreateEntity( l_spawnPos, l_rotation );
	}	
	
	
	function CreateEntity( _SpawnPos : Vector, _Rotation : EulerAngles ) : CEntity
	{		
		var l_spawnedEntity 			: CEntity;
		var l_damageAreaEntity 			: CDamageAreaEntity;
		var l_summonedEntityComponent	: W3SummonedEntityComponent;
		var l_normal					: Vector;
		var l_entityToSpawn				: CEntityTemplate;
		var l_randValue					: int;
		
		theGame.GetWorld().StaticTrace( _SpawnPos + Vector(0,0,5), _SpawnPos - Vector(0,0,5), _SpawnPos, l_normal );
		
		l_randValue	= RandRange( spawnedEntityTemplates.Size() );		
		l_entityToSpawn = spawnedEntityTemplates[ l_randValue ];
		
		l_spawnedEntity = theGame.CreateEntity( l_entityToSpawn, _SpawnPos, _Rotation );
		
		l_damageAreaEntity = (CDamageAreaEntity) l_spawnedEntity;
		if ( l_damageAreaEntity )
		{
			l_damageAreaEntity.owner = m_Npc;
		}
		l_summonedEntityComponent = (W3SummonedEntityComponent) l_spawnedEntity.GetComponentByClassName('W3SummonedEntityComponent');
		if( l_summonedEntityComponent )
		{
			l_summonedEntityComponent.Init( m_Npc );
		}
		
		return l_spawnedEntity;
	}
	
	
	function OnDeactivate()
	{
		if( m_PostFxOnGroundCmp ) m_PostFxOnGroundCmp.StartTicking();
		m_Npc.StopEffect('marker');
	}
}


class BTTaskFrostAreaAttackDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskFrostAreaAttack';
	
	
	private editable var spawnedEntities				: array<name>;
	private editable var duration						: SRangeF;
	private editable var spreadingSpeed					: float;
	private editable var maxRadius						: float;
	private editable var spawnAtOnce					: SRange;
	private editable var createArena					: bool;
	private editable var arenaAngle						: float;
	private editable var scaleSpawnQuantityWithRadius	: bool;
	private editable var spawnAttackDelay				: SRangeF;
	private editable var spawnAttackOnTargetDelay		: SRangeF;
	private editable var frostWallReloadDelay			: float;
	
	default spreadingSpeed 					= 2;
	default arenaAngle 						= 160;
	default scaleSpawnQuantityWithRadius 	= true;
	default maxRadius 						= 20;
	
	hint spreadingSpeed 					= "meters per second";
	hint arenaAngle 						= "angle of a circle to block behind the target";
	hint scaleSpawnQuantityWithRadius 		= "spawnAtOnce indicate the value when the range is at max and will be scale down when the radius is smaller";
	hint frostWallReloadDelay 				= "-1 means to not use the frost wall defense";
	
	
	function OnSpawn( taskGen : IBehTreeTask )
	{
		var i		: int;
		var task 	: BTTaskFrostAreaAttack;
		task = (BTTaskFrostAreaAttack) taskGen;
		for( i = 0; i < spawnedEntities.Size() ; i += 1 )
		{
			task.spawnedEntityTemplates.PushBack( ( CEntityTemplate ) LoadResource( spawnedEntities[i] ) );
		}
	}
}