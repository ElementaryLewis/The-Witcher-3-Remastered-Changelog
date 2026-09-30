/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SummonedFlies extends CGameplayEntity
{
	
	
	
	private editable var	fleeDuration		: float;
	private editable var	lookForTarget		: bool;
	private editable var	detectionDistance	: float;
	private editable var	pursueDistance		: float;
	private editable var	ignoreTag			: name;
	
	private var m_Target			: CNode;
	private var m_StartPos			: Vector;
	
	private var m_SummonedCmp		: W3SummonedEntityComponent;
	private var m_SlideCmp			: W3SlideToTargetComponent;
	
	default fleeDuration 		= 3;
	default detectionDistance 	= 10;
	default pursueDistance 		= 15;
	
	
	public function SetTarget( _Target : CNode ) { m_Target = _Target; } 	
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		m_SummonedCmp 	= ( W3SummonedEntityComponent ) GetComponentByClassName('W3SummonedEntityComponent');
		m_SlideCmp 		= ( W3SlideToTargetComponent ) 	GetComponentByClassName('W3SlideToTargetComponent');
		m_StartPos		= GetWorldPosition();
		
		if( !m_Target )
		{
			m_SlideCmp.SetTargetVector( m_StartPos );
		}
		
		if( lookForTarget )
		{
			AddTimer( 'LookForTarget', 1.0f, true,,,true);
		}
	}
	
	
	public function Init( _Summoner : CActor, _Target : CEntity )
	{
		m_SummonedCmp.Init( _Summoner );
		m_Target = _Target.GetComponent("torso3effect");
		
		m_SlideCmp.SetTargetNode( m_Target );
		StartFlee();
	}	
	
	
	public function OnSummonerEnterCombat()
	{		
		RemoveTimer( 'Die' );
	}	
	
	
	public function OnSummonerLeaveCombat()
	{
		AddTimer( 'Die', 5.0f, true,,,true);		
	}
	
	
	
	private timer function LookForTarget( _Dt : float, id : int)
	{
		var	i					: int;
		var l_pos 				: Vector;
		var l_actor				: CActor;
		var l_actorPos			: Vector;
		var l_submersionLevel	: float;
		var l_waterLevel 		: float;
		var l_entities 			: array<CGameplayEntity>;
		var l_closestTarget		: CActor;
		var l_closestDistance	: float;
		
		
		if( theGame.IsDialogOrCutscenePlaying() )
		{
			StopPursue();
			return;
		}
		
		l_pos = GetWorldPosition();
		l_closestDistance = -1;
		
		FindGameplayEntitiesInSphere( l_entities, m_StartPos, detectionDistance, 20 );
		
		for( i = 0; i < l_entities.Size(); i += 1 )
		{
			l_actor = (CActor) l_entities[i];
			if( !l_actor ) continue;
			
			if( IsNameValid( ignoreTag ) && l_actor.HasTag( ignoreTag ) ) continue;
			
			
			l_actorPos 		= l_actor.GetWorldPosition();
			l_waterLevel 	= theGame.GetWorld().GetWaterLevel ( l_actorPos, true );
			
			l_submersionLevel = l_waterLevel - l_actorPos.Z;
			
			if( l_submersionLevel > 0.5f ) 
				continue;
			
			if( !l_actor.IsAlive() )
				continue;
			
			if( VecDistance( l_actorPos, l_pos ) < l_closestDistance || l_closestDistance < 0 )
			{
				l_closestDistance 	= VecDistance( l_actorPos, l_pos );
				l_closestTarget 	= l_actor;
			}
		}		
			
		if( l_closestTarget )
		{
			m_Target = l_closestTarget;
			m_SlideCmp.SetTargetNode( m_Target );
			m_SlideCmp.SetOffset( Vector( 0, 0, 1.5f ) );
			AddTimer( 'PursueTarget', 1.0f, true,,,true);
		}
		else
		{
			StopPursue();
		}
		
		if( m_SlideCmp.GetTargetPosition() == m_StartPos && m_SlideCmp.GetDistanceToTarget() < 0.5f )
		{
			m_SlideCmp.StopTicking();
		}
		else
		{
			m_SlideCmp.StartTicking();
		}
		
	}
	
	
	private timer function PursueTarget( _Dt : float, id : int )
	{
		var l_pos 				: Vector;
		var l_distance			: float;
		var l_actor				: CActor;
		var l_targetPos			: Vector;
		var l_submersionLevel 	: float;
		var l_waterLevel 		: float;
		
		l_pos 		= GetWorldPosition();		
		l_distance  = VecDistance( l_pos, m_SlideCmp.GetTargetPosition() );  
		
		
		l_targetPos 	= m_SlideCmp.GetTargetPosition();
		l_waterLevel 	= theGame.GetWorld().GetWaterLevel ( l_targetPos, true );
		
		l_submersionLevel = l_waterLevel - l_targetPos.Z;
		
		if( l_distance > pursueDistance || l_submersionLevel > 0.5f )
		{
			StopPursue();
		}
	}
	
	
	private final function StopPursue()
	{
		m_SlideCmp.SetTargetVector( m_StartPos );
		m_Target = NULL;
		RemoveTimer( 'PursueTarget');
	}
	
	
	public function Die( optional _Dt : float, optional id : int )
	{		
		StopEffect('flies');
		m_SummonedCmp.GetSummoner().SignalGameplayEvent('FliesDestroyed');
		DestroyAfter( 3 );
	}
	
	
	public function StartFlee()
	{		
		AddTimer( 'Flee', 0.0f, true,,,false, true );
		AddTimer( 'StopFlee', fleeDuration, false,,,false, true );
	}
	
	
	private timer function Flee( _Dt : float, id : int )
	{		
		m_SlideCmp.SetStopDistance( 10 );
		m_SlideCmp.SetFallBackSpeed( 5 );
	}
	
	
	private timer function StopFlee( _Dt : float, id : int )
	{
		RemoveTimer('Flee');
	}
	
	
	
	event OnAardHit( sign : W3AardProjectile )
	{
		super.OnAardHit( sign );
		StartFlee();
	}
	event OnWeaponHit (act : W3DamageAction)
	{	
		super.OnWeaponHit(act);
		StartFlee();
	}
	event OnFireHit(source : CGameplayEntity)
	{
		super.OnFireHit( source );
		Die();
		PlayEffect('fire');
	}
	event OnYrdenHit( caster : CGameplayEntity )
	{	
		super.OnYrdenHit( caster );
		Die();
	}
}