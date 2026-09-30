/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskFrostSnakeAttack extends CBTTaskAttack
{
	
	
	
	
	public var useActionTarget					: bool;
	public var spawnedEntityTemplates			: array<CEntityTemplate>;
	public var duration							: SRangeF;
	public var clampDurationWhenTargetReached	: float;
	public var speed							: float;
	public var radius							: float;
	public var spawnAtOnce						: SRange;
	public var spawnAttackDelay					: SRangeF;
	public var maxDistance						: float;
	public var abortAttackOnTargetReached		: bool;
	public var ThreeStateAttack					: bool;
	public var loopHeadFX						: bool;
	public var waitForAnimEventToSummon			: name;
	
	public var snakeHeadTemplate				: CEntityTemplate;
	public var playEffectOnOwner				: name;
	public var additionalSnakeHeadFXName		: name;
	public var destroyEffectDelay				: float;
	public var canTriggerFrenzySlowmo			: bool;
	
	
	private var m_Npc							: CNewNPC;	
	private var m_SnakeHead						: CEntity;
	private var m_SnakeHeadPos					: Vector;
	private var m_LastSnakeHeadPos				: Vector;
	private var m_effectDummyComp				: CEffectDummyComponent;
	private var m_PlayEffect					: bool;
	private var m_CanStartSummon				: bool;
	
	
	
	
	final function Initialize()
	{
		m_Npc				= GetNPC();
		m_effectDummyComp 	= (CEffectDummyComponent) GetNPC().GetComponentByClassName( 'CEffectDummyComponent' );
		
		if( IsNameValid( waitForAnimEventToSummon ) )
			m_CanStartSummon = false;
		else
			m_CanStartSummon = true;
	}
	
	
	
	final function OnActivate() : EBTNodeStatus
	{
		if ( ThreeStateAttack )
		{
			
			GetNPC().SetBehaviorVariable( 'AttackEnd', 0, true );
		}
		m_PlayEffect = true;
		
		if( canTriggerFrenzySlowmo  )
		{
			
			if( ( (W3PlayerWitcher) GetCombatTarget() ) && ( thePlayer.IsActionAllowed(EIAB_Dodge) || thePlayer.IsActionAllowed(EIAB_Roll) ) && thePlayer.GetStat(BCS_Toxicity) > 0 && thePlayer.CanUseSkill(S_Alchemy_s16))
				((W3PlayerWitcher) GetCombatTarget()).StartFrenzy();
		}
		
		return super.OnActivate();
	}
	
	
	
	latent function Main() : EBTNodeStatus
	{
		var i						: int;
		var l_npcPos				: Vector;
		var l_targetPos				: Vector;
		var l_gameplayFX 			: CGameplayFXSurfacePost = theGame.GetSurfacePostFX();
		var l_timeLeft				: float;
		var l_lastLocalTime			: float;
		var l_deltaTime				: float;
		var l_timeUntilNextAttack	: float;
		var l_spawnQuantity			: int;
		
		var l_timeBeforeWarning		: float;
		var l_warningDone			: bool;
		var l_warningPos			: Vector;
		var l_headingToTarget		: float;
		var l_startHeading			: float;
		
		var	l_delayToSaveSnakePos	: float;
		
		if ( IsNameValid(playEffectOnOwner) )
			m_Npc.PlayEffect(playEffectOnOwner);
			
			
		l_npcPos 			= m_Npc.GetWorldPosition();		
		m_LastSnakeHeadPos 	= l_npcPos;
		m_SnakeHeadPos 		= l_npcPos + m_Npc.GetWorldForward() * 0.1f;
		
		if( useActionTarget )
		{
			l_targetPos = GetActionTarget().GetWorldPosition();
		}
		else
		{
			l_targetPos = GetCombatTarget().GetWorldPosition();
		}
		
		l_timeBeforeWarning = 0;
		
		
		while( !m_CanStartSummon )
		{			
			l_lastLocalTime = GetLocalTime();			
			SleepOneFrame();
			l_deltaTime = GetLocalTime() - l_lastLocalTime;
			
			l_timeBeforeWarning -= l_deltaTime;
			
			if( !l_warningDone && l_timeBeforeWarning < 0 )
			{
				l_headingToTarget	= VecHeading( l_targetPos - l_npcPos );
				l_startHeading		= l_headingToTarget - 53;
				
				for( i = 0; i < 7; i += 1 )
				{
					l_warningPos = l_npcPos + VecConeRand( l_startHeading - i * 37, 2 , 2, 2.3f );
					SpawnAttack( l_warningPos );
				}
				l_warningDone = true;
			}
		}
		
		l_timeLeft 		= RandRangeF( duration.max, duration.min );		
		
		
		
		m_SnakeHead = theGame.CreateEntity( snakeHeadTemplate, m_SnakeHeadPos, m_Npc.GetWorldRotation() );
		
		while( l_timeLeft > 0 )
		{
			l_lastLocalTime = GetLocalTime();
			SleepOneFrame();			
			l_deltaTime = GetLocalTime() - l_lastLocalTime;
			l_timeLeft -= l_deltaTime;
			
			MoveHead( l_deltaTime );
			if( maxDistance > 0 && VecDistance( m_SnakeHeadPos, l_npcPos ) > maxDistance )
			{
				return BTNS_Completed;
			}
			
			if( useActionTarget )
			{
				l_targetPos = GetActionTarget().GetWorldPosition();
			}
			else
			{
				l_targetPos = GetCombatTarget().GetWorldPosition();
			}
			
			if( clampDurationWhenTargetReached >= 0 && VecDistance( l_targetPos, m_SnakeHeadPos ) < radius * 0.3f )
			{
				l_timeLeft = ClampF( l_timeLeft, 0, clampDurationWhenTargetReached ); 
			}
			
			l_timeUntilNextAttack 	-= l_deltaTime;
			if( l_timeUntilNextAttack <= 0 && VecDistance( l_targetPos, m_SnakeHeadPos ) < 3 &&  ( maxDistance < 0 || VecDistance( l_targetPos, l_npcPos ) < maxDistance ) )
			{
				l_spawnQuantity		= RandRange( spawnAtOnce.max, spawnAtOnce.min );
				l_spawnQuantity		= Clamp( l_spawnQuantity, Min( 1, spawnAtOnce.min ), spawnAtOnce.max );
				for( i = 0; i < l_spawnQuantity; i += 1 )
				{
					SpawnAttack( );
				}
				l_timeUntilNextAttack = RandRangeF( spawnAttackDelay.max, spawnAttackDelay.min );
			}
			
			l_delayToSaveSnakePos -= l_deltaTime;
			if( l_delayToSaveSnakePos <= 0 )
			{	
				m_LastSnakeHeadPos 		= m_SnakeHeadPos;
				l_delayToSaveSnakePos 	= 0.5f;
			}
		}
		
		if ( ThreeStateAttack )
		{
			
			GetNPC().SetBehaviorVariable( 'AttackEnd', 1, true );
		}
		
		return BTNS_Completed;
	}	
	
	
	private final function MoveHead( _DeltaTime : float )
	{
		var l_targetPos, l_normal		: Vector;
		
		if( useActionTarget )
		{
			l_targetPos = GetActionTarget().GetWorldPosition();
		}
		else
		{
			l_targetPos = GetCombatTarget().GetWorldPosition();
		}
		m_SnakeHeadPos 	= InterpTo_V( m_SnakeHeadPos, l_targetPos, _DeltaTime, speed );
		
		theGame.GetWorld().StaticTrace( m_SnakeHeadPos + Vector(0,0,3), m_SnakeHeadPos - Vector(0,0,3), m_SnakeHeadPos, l_normal );
		
		m_SnakeHead.Teleport( InterpTo_V( m_SnakeHeadPos, m_SnakeHead.GetWorldPosition(), 0.05f, 0.5f ) );
		
		if ( IsNameValid( additionalSnakeHeadFXName ) && m_PlayEffect )
		{
			m_SnakeHead.PlayEffect(additionalSnakeHeadFXName);
			if ( !loopHeadFX )
			{
				m_PlayEffect = false;
			}
		}
		
		
	}
	
	
	private final function SpawnAttack( optional _Pos : Vector )
	{
		var l_npcPos			: Vector;
		var l_targetPos			: Vector;
		var l_vectToTarget		: Vector;
		var l_spawnPos 			: Vector;
		var l_forwardVector		: Vector;
		var l_rotation			: EulerAngles;
		var l_headingToTarget	: float;
		
		l_npcPos 			= m_Npc.GetWorldPosition();		
		if( useActionTarget )
		{
			l_targetPos = GetActionTarget().GetWorldPosition();
		}
		else
		{
			l_targetPos = GetCombatTarget().GetWorldPosition();
		}
		
		l_vectToTarget 		= l_targetPos - m_SnakeHeadPos;
		l_headingToTarget 	= VecHeading( l_vectToTarget );
		
		if( _Pos == Vector( 0,0,0 ) )
		{
			l_spawnPos 		= l_targetPos + VecRingRand( 0, radius );
		}
		else
		{
			l_spawnPos = _Pos;
		}
		
		
		l_forwardVector 	= m_SnakeHeadPos - m_LastSnakeHeadPos;
		l_rotation 			= VecToRotation( l_forwardVector );
		
		if( VecDistance( l_npcPos, l_spawnPos ) < 1.5f )
		{	 
			return;
		}
		
		CreateEntity( l_spawnPos, l_rotation );
	}	
	
	
	private final function CreateEntity( _SpawnPos : Vector, _Rotation : EulerAngles ) : CEntity
	{		
		var l_spawnedEntity 			: CEntity;
		var l_damageAreaEntity 			: CDamageAreaEntity;
		var l_summonedEntityComponent	: W3SummonedEntityComponent;
		var l_normal					: Vector;
		var l_entityToSpawn				: CEntityTemplate;
		var l_randValue					: int;
		
		theGame.GetWorld().StaticTrace( _SpawnPos + Vector(0,0,5), _SpawnPos - Vector(0,0,5), _SpawnPos, l_normal );
		
		l_randValue		= RandRange( spawnedEntityTemplates.Size() );		
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
		m_SnakeHead.DestroyAfter( destroyEffectDelay );
		if ( IsNameValid(additionalSnakeHeadFXName) )
			m_SnakeHead.StopEffect(additionalSnakeHeadFXName);
		if ( IsNameValid(playEffectOnOwner) )
			m_Npc.StopEffect(playEffectOnOwner);
		if( IsNameValid( waitForAnimEventToSummon ) )
			m_CanStartSummon = false;
			
		if ( ThreeStateAttack )
		{
			
			GetNPC().SetBehaviorVariable( 'AttackEnd', 1, true );
		}
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == 'AllowBlend' && animEventType == AET_DurationStart )
		{
			if ( ThreeStateAttack )
			{
				
				GetNPC().SetBehaviorVariable( 'AttackEnd', 1, true );
			}
			else
			{
				Complete(true);
			}
		}
		
		if ( IsNameValid( waitForAnimEventToSummon ) && animEventName == waitForAnimEventToSummon )
		{
			m_CanStartSummon = true;
		}
		
		return super.OnAnimEvent( animEventName, animEventType, animInfo );
	}
}


class BTTaskFrostSnakeAttackDef extends CBTTaskAttackDef
{
	default instanceClass = 'BTTaskFrostSnakeAttack';
	
	
	
	private editable var useActionTarget					: bool;
	private editable var spawnedEntityTemplates				: array<CEntityTemplate>;
	private editable var clampDurationWhenTargetReached		: CBehTreeValFloat;
	private editable var duration							: SRangeF;
	private editable var maxDistance						: float;
	private editable var speed								: float;
	private editable var radius								: float;
	private editable var spawnAtOnce						: SRange;
	private editable var spawnAttackDelay					: SRangeF;
	private editable var snakeHeadTemplate					: CEntityTemplate;
	private editable var additionalSnakeHeadFXName			: name;
	private editable var playEffectOnOwner					: name;
	private editable var ThreeStateAttack					: bool;
	private editable var loopHeadFX							: bool;
	private editable var destroyEffectDelay					: float;
	private editable var waitForAnimEventToSummon			: name;
	private editable var canTriggerFrenzySlowmo				: bool;
	
	
	default speed 								= 1;
	default radius 								= 2.5;
	default clampDurationWhenTargetReached 		= 2;
	default maxDistance 						= -1;
	default destroyEffectDelay					= 5;
	default additionalSnakeHeadFXName			= 'ice_line';
	default playEffectOnOwner					= 'marker';
	default loopHeadFX							= true;
	
	hint spawnedEntities 						= "Name of entities to spawn";
	hint clampDurationWhenTargetReached 		= "When the target is reached, the time left for the attack is clamped to this value";
	hint duration 								= "Duration of the attack";
	hint maxDistance 							= "The attack will stop when the head of the snake is further than this distance";
	hint speed 									= "speed of snake's head movement m.s-1";
	hint radius 								= "radius of snake's head in meters";
	hint spawnAtOnce 							= "entities to spawn at once";
	hint spawnAttackDelay 						= "delay between each spawn";
}