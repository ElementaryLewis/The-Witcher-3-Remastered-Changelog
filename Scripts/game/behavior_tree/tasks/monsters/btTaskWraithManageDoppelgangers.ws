/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskWraithManageDoppelgangers extends IBehTreeTask
{
	
	
	
	public var killDoppelgangersAtDeath 		: bool;
	public var killDoppelgangersAfterTime		: float;
	public var splitEffectEntityTemplate		: CEntityTemplate;
	public var healthPercentageToRegen			: float;
	
	private var m_spawnTime						: float;
	private var m_SplitEntities					: array<CEntity>;
	private var m_MergeReceived					: int;
	
	private var m_HealthPercToReach				: float;
	private var m_MergingStarted 				: bool;
	
	
	
	latent function Main() : EBTNodeStatus
	{	
		var l_summonerComponent : W3SummonerComponent;
		var l_npc				: CNewNPC = GetNPC();
		var l_perc				: float;
		var l_target			: CNode;
		
		m_HealthPercToReach = ClampF( l_npc.GetHealthPercents() + healthPercentageToRegen, 0, 1 );
		
		
		l_target = GetCombatTarget();
		SetActionTarget( l_target );
		
		l_summonerComponent = (W3SummonerComponent) l_npc.GetComponentByClassName('W3SummonerComponent');
		m_SplitEntities.Clear();
		m_MergeReceived = 0;		
		while( true )
		{	
			UpdateDoppelGangersHealth();			
			
			l_perc 				= l_npc.GetHealthPercents();			
			if( l_perc >= m_HealthPercToReach )
			{
				StopDoppelgangers();
				return BTNS_Active;
			}
			
			Sleep( 0.5f );
		}
		
		return BTNS_Active;
	}	
	
	
	function UpdateDoppelGangersHealth()
	{
		var l_summonerComponent : W3SummonerComponent;
		var l_npc				: CNewNPC = GetNPC();
		var l_doppelgangers		: array<CEntity>;
		var i					: int;
		var l_actor				: CActor;
		var l_perc				: float;
		var l_doppelHealth		: float;
		
		l_summonerComponent = (W3SummonerComponent) l_npc.GetComponentByClassName('W3SummonerComponent');
		l_doppelgangers 	= l_summonerComponent.GetSummonedEntities();
		l_perc				= l_npc.GetHealthPercents();
		
		for	( i = 0; i < l_doppelgangers.Size(); i += 1 )
		{
			l_actor = (CActor) l_doppelgangers[i];
			if( l_actor )
			{
				l_doppelHealth = l_actor.GetHealthPercents();
				
				if( l_doppelHealth < l_perc )
				{
					l_actor.StartEssenceRegen();
				}
				else
				{
					l_actor.SetHealthPerc( l_perc );
					l_actor.StopEssenceRegen();
				}				
			}
		}
	}
	
	
	function OnGameplayEvent( eventName : CName ) : bool
	{
		var l_deadDoppel	 	: CActor;
		var l_splitEntity		: CEntity;
		var l_slideCmp 			: W3SlideToTargetComponent;
		
		if ( eventName == 'OnDeath' )
		{
			if ( killDoppelgangersAtDeath )
			{
				StopDoppelgangers( true );
			}
			return true;
		}
		else if ( eventName == 'KillDoppelgangers' )
		{
			StopDoppelgangers( );
		}
		else if ( eventName == 'SummonedDoppelgangers' )
		{
			m_spawnTime = GetLocalTime();
			return true;
		}
		else if ( eventName == 'SummonedEntityDeath' || eventName == 'SummonedEntityDisappear' )
		{
			l_deadDoppel = (CActor) GetEventParamObject();
			
			l_splitEntity 	= theGame.CreateEntity( splitEffectEntityTemplate, l_deadDoppel.GetWorldPosition(), l_deadDoppel.GetWorldRotation() );
			l_slideCmp 		= (W3SlideToTargetComponent) l_splitEntity.GetComponentByClassName('W3SlideToTargetComponent');
			l_slideCmp.SetSpeed( 0.1f );
			l_slideCmp.SetTargetNode( GetCombatTarget() );
			l_slideCmp.SetSuccessDelay( -1 );
			l_slideCmp.SetStopDistance( 0 );
			l_slideCmp.SetNormalSpeed( 1 );
			l_slideCmp.SetStopEffect( '' );
			l_slideCmp.SetStayAboveNav( false );
			m_SplitEntities.PushBack( l_splitEntity );
			
			l_deadDoppel.DestroyAfter(1);
			
			
			if( m_MergingStarted )
			{
				Merge();
			}
		}
		else if ( eventName == 'StartMerge' ) 
		{			
			Merge();			
		}
		
		if ( eventName == 'Merge' || ( eventName == 'StartMerge' && m_SplitEntities.Size() == 0 ) ) 
		{
			m_MergeReceived+=1;
			
			if( m_MergeReceived >= m_SplitEntities.Size() )
			{
				GetNPC().SignalGameplayEvent('Appear');
				m_MergeReceived = 0;
			}
		}
		return false;
	}	
	
	
	private function Merge()
	{
		var i : int;
		var l_slideCmp : W3SlideToTargetComponent;
		
		for	( i = 0; i < m_SplitEntities.Size(); i += 1 )
		{
			l_slideCmp = (W3SlideToTargetComponent) m_SplitEntities[i].GetComponentByClassName('W3SlideToTargetComponent');
			l_slideCmp.SetTargetNode( GetNPC() );
			l_slideCmp.SetSpeed( 1 );
			l_slideCmp.SetStopDistance( 0.5f );
			l_slideCmp.SetStopEffect( 'split' );
			l_slideCmp.SetNormalSpeed( 0.5f );			
			l_slideCmp.SetSuccessDelay( 5 );
		}
		
		m_MergingStarted = true;
	}
	
	
	private function DestroySplitEntities()
	{
		var i : int;
		var l_slideCmp : W3SlideToTargetComponent;
		
		for	( i = 0; i < m_SplitEntities.Size(); i += 1 )
		{
			m_SplitEntities[i].Destroy();
		}
	}
	
	
	
	function OnActivate() : EBTNodeStatus
	{			
		return BTNS_Active;
	}
	
	
	function OnDeactivate()
	{
		DestroySplitEntities();
		m_MergingStarted = false;
	}
	
	
	private function StopDoppelgangers( optional Kill : bool)
	{
		var l_summonerComponent : W3SummonerComponent;
		var l_npc				: CNewNPC = GetNPC();
		var l_doppelgangers		: array<CEntity>;
		var i					: int;
		var l_actor				: CActor;
		
		l_summonerComponent = (W3SummonerComponent) l_npc.GetComponentByClassName('W3SummonerComponent');
		l_doppelgangers 	= l_summonerComponent.GetSummonedEntities();
		
		for	( i = 0; i < l_doppelgangers.Size(); i += 1 )
		{
			l_actor = (CActor) l_doppelgangers[i];
			if( l_actor )
			{
				if( Kill ) 
				{
					l_actor.Kill( 'Dopplers' );
				}
				else
				{
					l_actor.SignalGameplayEvent('Disappear');					
				}
					
				l_actor.DestroyAfter(3);
			}
		}
	}
}


class CBTTaskWraithManageDoppelgangersDef extends IBehTreeTaskDefinition
{	
	default instanceClass = 'CBTTaskWraithManageDoppelgangers';
	
	
	
	editable var killDoppelgangersAtDeath 	: bool;
	editable var killDoppelgangersAfterTime	: float;
	editable var splitEffectEntityTemplate	: CEntityTemplate;
	editable var healthPercentageToRegen	: float;
	
	default killDoppelgangersAtDeath 	= true;
	default killDoppelgangersAfterTime 	= -1;
	default healthPercentageToRegen 	= 0.3f;
	
	hint killDoppelgangersAfterTime = "Seconds to wait before killing any doppelgangers alive. -1 means to not kill after time";
};