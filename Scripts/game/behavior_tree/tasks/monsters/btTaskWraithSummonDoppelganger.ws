/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskWraithSummonDoppelganger extends CBTTaskPlayAnimationEventDecorator
{
	
	
	
	
	public var splitEffectEntityTemplate	: CEntityTemplate;
	public var numberToSummon				: int;
	public var summonOnAnimEvent			: name;
	public var summonPositionPattern		: ESpawnPositionPattern;
	public var summonMaxDistance			: float;
	public var summonMinDistance			: float;
	public var entityToSummonName			: name;
	public var splitEffectEntity			: name;
	public var applyBlindnessRange			: float;
	
	
	private var entityToSummon				: CEntityTemplate;
	private var m_shouldSummon				: bool;
	private var m_hasSummoned				: bool;
	private var m_createEntityHelper		: CCreateEntityHelper;
	
	
	function Initialize()
	{		
		m_createEntityHelper = new CCreateEntityHelper in this;
	}
	
	
	final latent function Main() : EBTNodeStatus
	{	
		var l_spawnPosCenter, cameraDir, l_npcPos, l_targetPos, posFin, l_normal, l_spawnVectorFromTarget : Vector;	
		var l_summonedEntity		: CEntity;
		var l_npc			 		: CNewNPC = GetNPC();
		var l_target				: CActor = l_npc.GetTarget();
		var l_rot 					: EulerAngles;
		var l_angleBetweenSpawns	: float;
		var l_angleCur				: float;
		var i, sign 				: int;
		var s,l_radius,x,y 			: float;
		var l_summonerComponent 	: W3SummonerComponent;
		var l_summonedComponent		: W3SummonedEntityComponent;
		var l_splitEntity			: CEntity;
		var l_splitEntities			: array<CEntity>;
		var l_spawnedDoppel			: int;
		var l_lastLocalTime			: float;
		var l_deltaTime				: float;
		var l_slideComponent		: W3SlideToTargetComponent;
		var l_actorsInRange			: array<CActor>;
		var l_maxDelay				: float;
		var l_safePos				: Vector;
		
		LoadResources();
		
		if ( !IsNameValid( summonOnAnimEvent ) )
		{
			m_shouldSummon = true;
		}
		
		while( !m_hasSummoned )
		{
			if( m_shouldSummon == true )
			{					
				
				l_npcPos 	 	= l_npc.GetWorldPosition();
				l_targetPos		= l_target.GetWorldPosition();
				
				l_summonerComponent = (W3SummonerComponent) l_npc.GetComponentByClassName('W3SummonerComponent');
				
				
				switch ( summonPositionPattern )
				{
					case ESPP_AroundTarget:						
						l_spawnPosCenter 		= l_targetPos;
					break;
					case ESPP_AroundSpawner:						
						l_spawnPosCenter 		= l_npcPos;
					break;
				}
				
				if(  !theGame.GetWorld().NavigationCircleTest( l_spawnPosCenter, 0.7 ) )
				{
					theGame.GetWorld().NavigationFindSafeSpot( l_spawnPosCenter, 1, 10, l_spawnPosCenter );	
				}
				
				
				if( applyBlindnessRange > 0 )
				{
					l_actorsInRange = GetActorsInRange( l_npc, applyBlindnessRange, , , true );
					
					for	( i = 0; i < l_actorsInRange.Size(); i += 1 )
					{
						l_actorsInRange[i].AddEffectDefault( EET_Blindness, l_npc );
					}				
				}
				
				posFin.Z = l_spawnPosCenter.Z;				
				l_radius = summonMaxDistance - summonMinDistance;
				
				l_angleBetweenSpawns = 2.0f * Pi() / (float) numberToSummon;
				l_angleCur	= RandF() * 2.0f * Pi() ;
				
				l_splitEntities.Resize( numberToSummon );
				
				
				for ( i = 0; i < numberToSummon ; i += 1 )
				{					
					posFin		= l_spawnPosCenter + Vector( ( summonMinDistance + RandF() * l_radius ) * CosF( l_angleCur ), summonMinDistance * SinF( l_angleCur ), 0.0f );
					l_angleCur	+= l_angleBetweenSpawns;
					
					
					theGame.GetWorld().NavigationFindSafeSpot( posFin, 1, 10, posFin );
					
					
					
					m_createEntityHelper.Reset();
					theGame.CreateEntityAsync( m_createEntityHelper, splitEffectEntityTemplate, l_npcPos, l_rot, true, false, false, PM_DontPersist );
					
					while( m_createEntityHelper.IsCreating() )
					{						
						SleepOneFrame();
						
						l_maxDelay += 1;
						if( l_maxDelay >= 120 )
						{
							return BTNS_Completed;
						}
					}
					l_splitEntity 		= m_createEntityHelper.GetCreatedEntity();
					
					l_slideComponent 	= (W3SlideToTargetComponent) l_splitEntity.GetComponentByClassName( 'W3SlideToTargetComponent' );
					
					l_slideComponent.SetTargetVector( posFin );
					l_slideComponent.SetSpeed( 1 );
					l_slideComponent.SetStopDistance( 0.5f );
					l_slideComponent.SetTriggerOnTarget( true );
					l_slideComponent.SetDestroyDelayAtDest( 5 );
					
					l_splitEntities[i] 	= l_splitEntity;
				}
				
				
				while( l_spawnedDoppel < numberToSummon )
				{
					l_lastLocalTime = GetLocalTime();
					SleepOneFrame();			
					l_deltaTime = GetLocalTime() - l_lastLocalTime;
					
					for ( i = l_splitEntities.Size() - 1 ; i >= 0  ; i -= 1 )
					{
						l_splitEntity 		= l_splitEntities[i];
						l_slideComponent 	= (W3SlideToTargetComponent) l_splitEntity.GetComponentByClassName( 'W3SlideToTargetComponent' );
						
						
						if( l_slideComponent.IsAtDestination() )
						{
							l_rot 				= VecToRotation( l_targetPos - l_splitEntity.GetWorldPosition() );
							
							m_createEntityHelper.Reset();
							
							if( !theGame.GetWorld().NavigationFindSafeSpot( l_splitEntity.GetWorldPosition(), 3, 12, l_safePos ) )
								return BTNS_Completed;
							
							theGame.CreateEntityAsync( m_createEntityHelper, entityToSummon, l_safePos, l_rot, true, false, false, PM_DontPersist );							
							
							l_maxDelay = 0;
							while( m_createEntityHelper.IsCreating() )
							{
								SleepOneFrame();
								
								l_maxDelay += 1;
								if( l_maxDelay >= 120 )
								{
									return BTNS_Completed;
								}
							}
							
							l_summonedEntity 	= m_createEntityHelper.GetCreatedEntity();
							
							if ( l_summonerComponent )
							{
								l_summonerComponent.AddEntity ( l_summonedEntity );
							}
							
							l_summonedComponent	= (W3SummonedEntityComponent) l_summonedEntity.GetComponentByClassName( 'W3SummonedEntityComponent' );
							if( l_summonedComponent )
							{
								l_summonedComponent.Init( GetNPC() );
							}
							
							l_spawnedDoppel +=1 ;
							l_splitEntities.EraseFast( i );
						}					
					}
				}
				
				l_npc.SignalGameplayEvent('SummonedDoppelgangers');
				
				m_hasSummoned = true;		
			}
			
			SleepOneFrame();
		}
		
		return BTNS_Completed;
	}
	
	
	
	private final latent function LoadResources()
	{	
		if( IsNameValid(entityToSummonName) )
		{
			entityToSummon = (CEntityTemplate) LoadResourceAsync( entityToSummonName );	
			if( !entityToSummon )
				LogChannel('Noonwraith', "Couldn't load ressource " + entityToSummonName );
		}
	}
	
	
	private final function OnDeactivate()
	{
		m_hasSummoned = false;
	}
	
	
	final function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{			
		if ( animEventName == summonOnAnimEvent )
		{
			m_shouldSummon = true;
			m_hasSummoned = false;
			return true;
		}
		
		return super.OnAnimEvent( animEventName, animEventType, animInfo);
	}
}



class CBTTaskWraithSummonDoppelgangerDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskWraithSummonDoppelganger';
	
	
	
	
	editable var entityToSummonName				: name;
	editable var entityToSummon				: name;
	editable var splitEffectEntityTemplate		: CEntityTemplate;
	editable var summonOnAnimEvent				: name;
	editable var numberToSummon					: int;
	editable var summonPositionPattern			: ESpawnPositionPattern;	
	editable var summonMaxDistance				: float;
	editable var summonMinDistance				: float;
	editable var applyBlindnessRange			: float;
	
	default numberToSummon 		= 3;
	default summonOnAnimEvent 	= 'Summon';
	default summonMaxDistance 	= 6.f;
	default summonMinDistance 	= 3.f;
	default applyBlindnessRange = 20.f;
	
	hint numberToSummon 		= "Number of doppelgangers to create";
	hint summonOnAnimEvent 		= "When to spawn the doppelgangers. if none is set, they will appear at the beggining";
	hint summonPositionPattern 	= "How does the summon entity should position themselved";
};