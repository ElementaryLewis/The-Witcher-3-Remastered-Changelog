/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskCaretakerManager extends IBehTreeTask
{
	
	
	
	private var drainTemplate			: CEntityTemplate;	
	private var recoverPercPerHit		: float;
	private var shadesModifier			: float;
	
	private var m_Npc					: CNewNPC;
	private var m_HealthObjective		: float;
	private var m_DrainEffectEntity		: CEntity;
	private var m_SummonerComponent		: W3SummonerComponent;
	private var m_RefreshTargetDelay	: float;
	
	
	
	function Initialize()
	{
		m_Npc = GetNPC();
	}
		
	
	
	latent function Main() : EBTNodeStatus
	{
		var i						: int;
		var l_healthCurrent 		: float;
		var l_sourceNode 			: CNode;
		var l_summonedEntity		: array<CEntity>;
		var l_player 				: CR4Player;
		
		m_SummonerComponent = (W3SummonerComponent) m_Npc.GetComponentByClassName('W3SummonerComponent');
		
		l_sourceNode = GetCombatTarget().GetComponent("torso3effect");
		if( !l_sourceNode )
		{
			l_sourceNode = GetCombatTarget();
		}
		
		l_player = thePlayer;
		
		while(true)
		{		
			if( m_SummonerComponent.GetNumberOfSummonedEntities() > 0 )
			{
				m_RefreshTargetDelay -= 1;
				
				
				if( m_RefreshTargetDelay <= 0 && VecDistance( m_Npc.GetWorldPosition(), thePlayer.GetWorldPosition() ) > 5 )
				{
					SetClosestShadeAsTarget();
					m_RefreshTargetDelay = 60;
				}
			}
			else
			{
				
				
				m_RefreshTargetDelay = 60;
			}
			
			
			l_summonedEntity =  m_SummonerComponent.GetSummonedEntities();
			for( i = 0; i < l_summonedEntity.Size(); i += 1 )
			{
				((CNewNPC)l_summonedEntity[i]).SignalGameplayEventParamObject( 'ForceTarget', m_Npc );
			}
			
			
			if( m_DrainEffectEntity )
			{
				m_DrainEffectEntity.Teleport( l_sourceNode.GetWorldPosition() );
			}
			
			SleepOneFrame();
		}
		
		return BTNS_Active;
	}
	
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var l_damage : float ;
		var l_player : CR4Player;
		
		if( eventName == 'CausesDamage' )
		{
			CalculateHealingValues();
			
			l_damage = GetEventParamFloat( 0 );
			
			if( m_SummonerComponent.GetNumberOfSummonedEntities() > 0 )			
				RestoreHealth( m_Npc.GetMaxHealth() * recoverPercPerHit * shadesModifier );
			else 
				RestoreHealth( m_Npc.GetMaxHealth() * recoverPercPerHit );
		}
		if( eventName == 'Death' )
		{
			l_player.AddTimer('RemoveForceFinisher', 3, false, , , true );
			
			m_Npc.PlayEffectOnHeldWeapon( 'summon_shades', true );
		}
		
		return true;
	}
	
	
	function RestoreHealth( _Amount : float )
	{
		
		if( _Amount <= 0 )
			return;
		
		if( m_Npc.GetHealthPercents() == 1 ) 
			return;
			
		m_Npc.Heal( _Amount );
		m_Npc.ShowFloatingValue(EFVT_Heal, _Amount, false );
		
		m_Npc.PlayEffect('drain_energy');
		m_Npc.PlayEffectOnHeldWeapon('absorb_life');
		
		
	}
	
	
	private function CalculateHealingValues()
	{
		recoverPercPerHit = CalculateAttributeValue( m_Npc.GetAttributeValue( 'healing_per_hit_perc' ));
		shadesModifier = CalculateAttributeValue( m_Npc.GetAttributeValue( 'number_of_shades' ));
	}
	
	
	private function PlayDrainEnergy()
	{
		var l_targetNode : CNode;
		var l_sourceNode : CNode;
		
		l_targetNode = m_Npc.GetComponent("DrainEnergyTarget");
		
		l_sourceNode = GetCombatTarget().GetComponent("torso3effect");
		if( !l_sourceNode )
		{
			l_sourceNode = GetCombatTarget();
		}
		
		if( !m_DrainEffectEntity )
		{
			m_DrainEffectEntity = theGame.CreateEntity( drainTemplate, l_sourceNode.GetWorldPosition(), GetNPC().GetWorldRotation() );
		}
		else
		{
			m_DrainEffectEntity.Teleport( l_sourceNode.GetWorldPosition() );
		}		
		
		m_DrainEffectEntity.PlayEffect( 'drain_energy', l_targetNode );		
		
	}
	
	
	private function SetClosestShadeAsTarget()
	{
		var i						: int;
		var l_summonedEntity		: array<CEntity>;
		var l_summonedEntityNode	: array<CNode>;
		var l_newTarget				: CNewNPC;
		
		l_summonedEntity = m_SummonerComponent.GetSummonedEntities();
		
		
		for( i = 0; i < m_SummonerComponent.GetNumberOfSummonedEntities(); i += 1 )
		{				
			l_summonedEntityNode.PushBack( l_summonedEntity[i] );
		}
		
		SortNodesByDistance( GetNPC().GetWorldPosition(), l_summonedEntityNode );
		
		l_newTarget = (CNewNPC) l_summonedEntityNode[0];
		
		GetNPC().SignalGameplayEventParamObject( 'ForceTarget', l_newTarget );
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{	
		var i			: int;
		var l_entities 	: array<CGameplayEntity>;
		var l_actor		: CActor;
		var l_yrden		: W3YrdenEntity;
		
		if( animEventName == 'Dispel' )
		{
			
			m_Npc.RemoveAllBuffsOfType( EET_Burning );
			m_Npc.RemoveAllBuffsOfType( EET_Frozen );
			m_Npc.RemoveAllBuffsOfType( EET_Bleeding );
			m_Npc.RemoveAllBuffsOfType( EET_SlowdownFrost );
			m_Npc.RemoveAllBuffsOfType( EET_Slowdown );
			
			
			
			m_Npc.RemoveAllBuffsOfType( EET_Bleeding1 );
			m_Npc.RemoveAllBuffsOfType( EET_Bleeding2 );
			m_Npc.RemoveAllBuffsOfType( EET_Bleeding3 );
			
			
			
			
			FindGameplayEntitiesInSphere( l_entities, m_Npc.GetWorldPosition(), 10, -1 );
			
			for( i = 0; i < l_entities.Size(); i += 1 )
			{
				l_actor = (CActor) l_entities[i];
				if( l_actor )
				{
					
				}
				l_yrden = (W3YrdenEntity) l_entities[i];
				if( l_yrden )
				{
					l_yrden.TimedCanceled( 0, 0 );
					l_yrden.OnSignAborted( true );
				}
			}
		}
		
		return true;
	}
}



class BTTaskCaretakerManagerDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskCaretakerManager';
	
	private editable var drainTemplate		: CEntityTemplate;
	private var recoverPercPerHit			: float;
	private var shadesModifier				: float;
	
	
	
	
	
	hint shadesModifier = "the recover per hit value is multiplied by this modifier while shades are around";
	
	
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'CausesDamage' );
		listenToGameplayEvents.PushBack( 'Death' );
	}
}