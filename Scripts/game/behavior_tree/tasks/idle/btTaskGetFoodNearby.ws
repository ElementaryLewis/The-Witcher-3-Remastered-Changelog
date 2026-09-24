/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskGetFoodNearby extends IBehTreeTask
{
	
	
	
	public var foodToLookFor					:	int;
	public var completeIfTargetChange			: 	bool;
	
	private var m_foodFound						: 	W3FoodComponent;
	private var m_scentFound					:	W3ScentComponent;
	private var m_alreadyTrackedScents			: 	array< W3ScentComponent >;
	
	private var m_timeAtLastCheck				: 	float;
	private var m_delayBetweenChecks			: 	float;
	private var m_WasFalse						: 	bool;
	
	private var m_EntitiesAround 				: array<CGameplayEntity>;
	private var m_delayBetweenUpdateEntities	: 	float;
	private var m_timeAtLastUpdateEntities		: 	float;
	
	
	default m_delayBetweenChecks 			= 5.0f;
	default m_delayBetweenUpdateEntities 	= 5.0f;
	
	
	function IsAvailable() : bool
	{
		var l_availableScents		: array<CNode>;
		var l_delaySinceLastCheck	: float;
		
		l_delaySinceLastCheck = GetLocalTime() - m_timeAtLastCheck;
		
		if( m_WasFalse && l_delaySinceLastCheck < m_delayBetweenChecks )
		{	 
			return false;
		}
		
		l_availableScents = GetAvailableScents();
		if( l_availableScents.Size() > 0 )
		{
			m_WasFalse = false;
			return true;
		}
		
		m_timeAtLastCheck = GetLocalTime();
		m_WasFalse = true;
		return false;
	}
	
	
	function OnActivate() : EBTNodeStatus
	{	
		UpdateTarget();
		return BTNS_Active;
	}
	
	
	latent function Main( ) : EBTNodeStatus
	{
		var l_npc			: CNewNPC = GetNPC();
		var l_pos			: Vector;
		var l_targetPos		: Vector;
		var l_heading		: float;
		
		while( true )
		{
			UpdateTarget( );
			
			if( !m_foodFound )
			{
				l_pos 		= l_npc.GetWorldPosition();
				GetCustomTarget( l_targetPos, l_heading );
				
				if( VecDistance( l_targetPos, l_pos ) < 5  )
				{
					m_alreadyTrackedScents.PushBack( m_scentFound );
				}
			}
			SleepOneFrame();
		}
		
		return BTNS_Active;
	}
	
	
	private function GetAvailableScents() : array <CNode>
	{	
		var i					: int;
		var l_npc				: CNewNPC = GetNPC();
		var l_foodComponent		: W3FoodComponent;
		var l_scentComponent	: W3ScentComponent;
		var l_availableScents	: array<CNode>;
		var l_guardArea			: CAreaComponent;
		
		if( GetLocalTime() - m_timeAtLastUpdateEntities > m_delayBetweenUpdateEntities )
		{
			m_EntitiesAround.Clear();
			FindGameplayEntitiesInRange( m_EntitiesAround, l_npc, 500, 100 );
			m_timeAtLastUpdateEntities = GetLocalTime();
		}
		
		for	( i = 0; i < m_EntitiesAround.Size() ; i +=1 )
		{		
			l_scentComponent = (W3ScentComponent)	m_EntitiesAround[i].GetComponentByClassName('W3ScentComponent');
			l_foodComponent  = (W3FoodComponent)	l_scentComponent;
			if( l_scentComponent )
			{			
				l_guardArea = l_npc.GetGuardArea();
				if( l_guardArea && !l_guardArea.TestPointOverlap( l_scentComponent.GetWorldPosition() ) )
				{
					continue;
				}
				
				if( !l_scentComponent.IsInGroup( foodToLookFor ) )
				{
					continue;
				}
				
				if( !l_foodComponent && m_alreadyTrackedScents.Contains( l_scentComponent ) )
				{
					continue;
				}
				
				if ( l_foodComponent && !l_foodComponent.IsAvailable( l_npc ) )
				{
					continue;
				}
				
				if( l_scentComponent.IsDetected( l_npc ) )
				{
					l_availableScents.PushBack( m_EntitiesAround[i] );
				}
			}
		}
		
		return l_availableScents;
	}
	
	
	private function UpdateTarget()
	{		
		var l_availableScents	: array<CNode>;				
		var l_npc				: CNewNPC = GetNPC();
		var l_pos, l_targetPos	: Vector;
		var l_heading			: Vector;
		var l_entity			: CGameplayEntity;
		var l_foodComponent		: W3FoodComponent;
		var l_scentComponent	: W3ScentComponent;
		var l_headingAngle		: EulerAngles;
		
		l_availableScents = GetAvailableScents();
		
		if ( l_availableScents.Size() == 0 )
		{
			m_foodFound 	= NULL;
			m_scentFound 	= NULL;
			return;
		}
		
		
		l_pos 				= l_npc.GetWorldPosition();
		SortNodesByDistance( l_pos, l_availableScents );
		l_entity 			= (CGameplayEntity) 	l_availableScents[0];
		l_scentComponent 	= (W3ScentComponent)	l_entity.GetComponentByClassName('W3ScentComponent');
		l_foodComponent 	= (W3FoodComponent)		l_scentComponent;
		
		
		if( l_foodComponent )
		{
			l_targetPos = l_foodComponent.GetEatingPosition( l_npc );
		}
		else
		{
			l_targetPos = l_scentComponent.GetWorldPosition() + VecRingRand( 0 , 5 );
		}
		
		l_heading		= l_targetPos -  l_scentComponent.GetWorldPosition();
		l_headingAngle 	= VecToRotation( l_heading );
		
		
		if( l_foodComponent && VecDistance( l_targetPos, l_pos ) < l_foodComponent.GetLockDistance() )
		{
			l_foodComponent.AddEater( l_npc );
		}
		
		if( m_foodFound && l_foodComponent != m_foodFound )
		{
			l_npc.SignalGameplayEvent( 'ChangeFoodTarget' );
		}
		
		if( m_scentFound != l_scentComponent )
		{
			m_foodFound 	= l_foodComponent;
			m_scentFound 	= l_scentComponent;
			SetCustomTarget( l_targetPos, l_headingAngle.Yaw );
			SetActionTarget( m_scentFound.GetEntity() );
		}
		GetNPC().GetVisualDebug().AddArrow('toFood', GetNPC().GetWorldPosition(), m_scentFound.GetEntity().GetWorldPosition(), 1.f, 0.2f, 0.2f, true, Color(145,26,98) );
	}
	
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if( eventName == 'ChangeFoodTarget' )
		{
			Complete( false );
		}
		
		return true;
	}
	
	
	function OnCompletion( success : bool )
	{
		var l_npc	: CNewNPC = GetNPC();
		
		if( m_foodFound )
		{
			m_foodFound.RemoveEater( l_npc );
		}
	}
	
	
	function OnDeactivate()
	{
		m_foodFound 	= NULL;
		m_scentFound 	= NULL;
	}
	
}

class BTTaskGetFoodNearbyDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskGetFoodNearby';
	
	
	
	editable var corpse 						: 	CBehTreeValBool;
	editable var meat							: 	CBehTreeValBool;
	editable var vegetable						: 	CBehTreeValBool;
	editable var water 							: 	CBehTreeValBool;
	editable var monster 						: 	CBehTreeValBool;
	editable var completeIfTargetChange			: 	bool;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		
		if ( completeIfTargetChange )
		{
			listenToGameplayEvents.PushBack( 'ChangeFoodTarget' );
		}
	}
	
	function OnSpawn( taskGen : IBehTreeTask )
	{
		var task : BTTaskGetFoodNearby;
		task = (BTTaskGetFoodNearby) taskGen;
		
		if( GetValBool( corpse ) )		task.foodToLookFor = task.foodToLookFor | (int) FG_Corpse;
		if( GetValBool( meat ) )		task.foodToLookFor = task.foodToLookFor | (int) FG_Meat;
		if( GetValBool( vegetable ) )	task.foodToLookFor = task.foodToLookFor | (int) FG_Vegetable;
		if( GetValBool( water ) )		task.foodToLookFor = task.foodToLookFor | (int) FG_Water;
		if( GetValBool( monster ) )		task.foodToLookFor = task.foodToLookFor | (int) FG_Monster;
	}
}