/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskManageFlies extends IBehTreeTask
{
	
	
	
	public 	var entityToSummon			: CEntityTemplate;
	
	public 	var maxFliesAlive			: int;
	public 	var delayBetweenSpawns		: SRangeF;
	public 	var delayToRespawn			: SRangeF;
	
	private var m_summonerCmp			: W3SummonerComponent;
	private var m_DelayToNextSpawn		: float;
	
	
	
	function Initialize()
	{
		m_summonerCmp = ( W3SummonerComponent ) GetNPC().GetComponentByClassName('W3SummonerComponent');
		m_DelayToNextSpawn = RandRangeF( delayToRespawn.max, delayToRespawn.min );
	}
	
	
	function IsAvailable() : bool
	{
		return true;
	}
	
	
	function OnActivate() : EBTNodeStatus
	{
		var i 					: int;
		var l_summonedEntities 	: array<CEntity>;
		var l_entity			: CEntity;
		var l_flies 			: W3SummonedFlies;		
		
		if( !m_summonerCmp )
				m_summonerCmp = ( W3SummonerComponent ) GetNPC().GetComponentByClassName('W3SummonerComponent');
		
		l_summonedEntities = m_summonerCmp.GetSummonedEntities();
		for( i = 0; i < l_summonedEntities.Size(); i += 1 )
		{
			l_flies = (W3SummonedFlies) l_summonedEntities[i];
			if( l_flies )
			{
				l_flies.OnSummonerEnterCombat();
			}
		}
		
		return BTNS_Active;
	}
	
	
	latent function Main() : EBTNodeStatus
	{
		var l_numOfFlies 		: int;
		var l_deltaTime			: float;
		var l_lastFrameTime		: float;
		var l_npcPos			: Vector;
		var l_targetPos			: Vector;
		
		while ( true )
		{
			if( !m_summonerCmp )
				m_summonerCmp = ( W3SummonerComponent ) GetNPC().GetComponentByClassName('W3SummonerComponent');
			
			l_deltaTime 		= GetLocalTime() - l_lastFrameTime;
			if( m_DelayToNextSpawn <= 0 )
			{			
				l_npcPos = GetNPC().GetWorldPosition();
				l_numOfFlies 	= m_summonerCmp.GetNumberOfSummonedEntities();
				if( l_numOfFlies < maxFliesAlive )
				{
					SummonFlies( l_npcPos + Vector( 0, 0, 1.5f ) );
					m_DelayToNextSpawn = RandRangeF( delayBetweenSpawns.max, delayBetweenSpawns.min );
				}
			}
			else
			{
				m_DelayToNextSpawn -= l_deltaTime;
			}
			
			l_lastFrameTime = GetLocalTime();
			SleepOneFrame();
		}
		
		return BTNS_Active;
	}
	
	
	private function SummonFlies( _Pos : Vector, optional _Rotation : EulerAngles )
	{
		var l_flies 			: W3SummonedFlies;
		var l_sumonedCmp		: W3SummonedEntityComponent;
		
		l_flies = (W3SummonedFlies) theGame.CreateEntity( entityToSummon, _Pos, _Rotation );
		
		l_flies.Init( GetNPC(), GetCombatTarget() );
		
		m_summonerCmp.AddEntity( l_flies );
	}
	
	
	private function OnDeactivate()
	{
		var i 					: int;
		var l_summonedEntities 	: array<CEntity>;
		var l_entity			: CEntity;
		var l_flies 			: W3SummonedFlies;		
		
		if( !m_summonerCmp )
				m_summonerCmp = ( W3SummonerComponent ) GetNPC().GetComponentByClassName('W3SummonerComponent');
		
		l_summonedEntities = m_summonerCmp.GetSummonedEntities();
		for( i = 0; i < l_summonedEntities.Size(); i += 1 )
		{
			l_flies = (W3SummonedFlies) l_summonedEntities[i];
			if( l_flies )
			{
				l_flies.OnSummonerLeaveCombat();
			}
		}
	}
	
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if( eventName == 'FliesDestroyed' )
		{
			m_DelayToNextSpawn = RandRangeF( delayToRespawn.max, delayToRespawn.min );
		}
		return true;
	}

}




class BTTaskManageFliesDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskManageFlies';
	
	
	private editable var entityToSummon			: CEntityTemplate;
	private editable var maxFliesAlive			: int;
	private editable var delayBetweenSpawns		: SRangeF;
	private editable var delayToRespawn			: SRangeF;
	
	default maxFliesAlive = 3;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'FliesDestroyed' );
	}
}