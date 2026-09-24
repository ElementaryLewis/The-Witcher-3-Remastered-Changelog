/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskWraithDrainDance extends CBTTaskPlayAnimationEventDecorator
{
	
	
	
	
	public  var	drainDistance			: float;
	public 	var drainTemplate			: CEntityTemplate;
	
	private var m_isDraining			: bool;
	private var m_DrainEffectEntity		: CEntity;
	private var m_Disappeared			: bool;
		
	
	
	private final function OnDeactivate()
	{
		var l_npc 						: CNewNPC 			= GetNPC();
		var summonedEntityComponent 	: W3SummonedEntityComponent;
		
		if( m_DrainEffectEntity )
		{
			m_DrainEffectEntity.StopEffect( 'drain_energy' );
			m_DrainEffectEntity.DestroyAfter( 3  );
		}
		
		if( m_Disappeared )
		{
			summonedEntityComponent = (W3SummonedEntityComponent) l_npc.GetComponentByClassName('W3SummonedEntityComponent');
			summonedEntityComponent.GetSummoner().SignalGameplayEventParamObject( 'SummonedEntityDisappear', l_npc );
			l_npc.SetVisibility( false );
			l_npc.SetGameplayVisibility( false );
			l_npc.DestroyAfter( 2 );
		}
	}
	
	
	latent function Main() : EBTNodeStatus
	{
		var l_npc 						: CNewNPC 			= GetNPC();
		var l_target 					: CActor 			= l_npc.GetTarget();
		var l_npcPos, l_targetPos 		: Vector;
		var l_dist						: float;
		var l_summonerHealth			: float;
		
		var summonedEntityComponent 	: W3SummonedEntityComponent;
		
		var l_sourceNode				: CNode;
		var l_targetNode				: CNode;
		
		summonedEntityComponent = (W3SummonedEntityComponent) l_npc.GetComponentByClassName('W3SummonedEntityComponent');
		l_targetNode			= GetNPC().GetComponent("DrainEnergyTarget");
		if( !l_targetNode )
		{
			l_targetNode = GetNPC();
		}
		l_sourceNode			= GetCombatTarget().GetComponent("torso3effect");
		if( !l_sourceNode )
		{
			l_sourceNode = GetCombatTarget();
		}
		
		while ( !m_Disappeared )
		{			
			l_npcPos 		= l_npc.GetWorldPosition();
			l_targetPos 	= l_target.GetWorldPosition();
			
			l_dist 			= VecDistance( l_npcPos, l_targetPos );
			
			if( !summonedEntityComponent.GetSummoner() || !summonedEntityComponent.GetSummoner().IsAlive() )
			{
				l_npc.SignalGameplayEvent('Disappear');
				return BTNS_Active;
			}
			
			if( l_dist < 4 )
			{
				if( !l_target.HasBuff( EET_VitalityDrain ) )
				{
					AddDrainBuff();
				}				
				
				if( summonedEntityComponent )
				{
					
					l_summonerHealth = summonedEntityComponent.GetSummoner().GetCurrentHealth();
					summonedEntityComponent.GetSummoner().Heal( l_summonerHealth * 0.002f );
				}
				
				if( !m_DrainEffectEntity )
				{
					m_DrainEffectEntity = theGame.CreateEntity( drainTemplate, GetNPC().GetWorldPosition(), GetNPC().GetWorldRotation() );
				}
				
				if( !m_DrainEffectEntity.IsEffectActive('drain_energy') )
				{
					m_DrainEffectEntity.PlayEffect( 'drain_energy', l_targetNode );
				}
			}
			else
			{
				m_DrainEffectEntity.StopEffect( 'drain_energy' );
			}
			
			if( m_DrainEffectEntity )
			{
				m_DrainEffectEntity.Teleport( l_sourceNode.GetWorldPosition() );
			}
			
			Sleep( 0.01f );
		}
		return BTNS_Active;
	}
	
	
	private function AddDrainBuff()
	{
		var i			: int;
		var l_actor		: CActor;
		var l_params	: SCustomEffectParams;
		
		l_actor				= GetCombatTarget();
		
		l_params.effectType = EET_VitalityDrain;
		l_params.creator 	= l_actor;
		l_params.sourceName = l_actor.GetName();
		l_params.duration 	= 1;
			
		l_actor.AddEffectCustom( l_params );
		
	}
	
	
	function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		if ( eventName == 'OnDeath' )
		{
			GetNPC().StopEffect('drain_energy');
			return true;
		}
		else if ( eventName == 'Disappear' )
		{
			m_Disappeared = true;
			if( m_DrainEffectEntity )
			{
				m_DrainEffectEntity.StopEffect( 'drain_energy' );
				m_DrainEffectEntity.DestroyAfter( 3  );
			}
			return true;
		}
		
		return false;
	}
}



class CBTTaskWraithDrainDanceDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskWraithDrainDance';
	private editable var drainTemplate	: CEntityTemplate;

	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'OnDeath' );
		listenToGameplayEvents.PushBack( 'Disappear' );
		
	}
};