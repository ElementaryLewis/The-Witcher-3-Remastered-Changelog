/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class W3DestroyableTerrain extends CInteractiveEntity
{
	var m_destroyableElements 	: array<array< CScriptedDestroyableComponent >>;
	var m_piecesIdToSplit 		: array< int >;

	var m_player 				: CPlayer;
	var m_activated				: bool;
	
	var m_componentName 		: string;
	var m_randNumber			: int;
	
	default m_activated = false;
	
	var tickTime	: float;
	var tickInterval	: float;
	
	default 			tickInterval = 0.0100f;
	default 			tickTime = 0.0f;
	
	var currRandNumbId : int;
	var currRandNumbTime : float;
	
	private editable 	var m_numOfPiecesToDestroy		  : int;
	private editable 	var m_timeBetweenRandomDestroyMin : int;
	private editable 	var m_timeBetweenRandomDestroyMax : int;
	
	function GetDestroyableElement(type : int, id : int) : CScriptedDestroyableComponent
	{
		return m_destroyableElements[type][id];
	}
	
	function GetDestroyableElements(type : int) : array<CScriptedDestroyableComponent>
	{
		return m_destroyableElements[type];
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var tmpString : string;
		var i : int;
		
		var destroyWay : EDestroyWay;
		var	destroyComp : CScriptedDestroyableComponent;
		
		var m_destroyableElementsRandom 	: array< CScriptedDestroyableComponent >;
		var m_destroyableElementsTimed  	: array< CScriptedDestroyableComponent >;
		var m_destroyableElementsOnContact	: array< CScriptedDestroyableComponent >;
		var m_destroyableElementsOnDistance : array< CScriptedDestroyableComponent >;
	
		if ( !spawnData.restored )
		{
		}
		
		for(i = 0; i <m_numOfPiecesToDestroy; i+=1)
		{
			tmpString = m_componentName+i;
			
			destroyComp = (CScriptedDestroyableComponent)GetComponent(tmpString);
			
			destroyWay = destroyComp.GetDestroyWay();
				
			switch( destroyWay )
			{
				case 0:	
					m_destroyableElementsRandom.PushBack(destroyComp);
					break;
				
				case 1:	
					m_destroyableElementsTimed.PushBack(destroyComp);
					break;
				
				case 2:	
					m_destroyableElementsOnContact.PushBack(destroyComp);
					break;
				
				case 3:	
					m_destroyableElementsOnDistance.PushBack(destroyComp);
					break;
			}
		}
		
		currRandNumbId = 1;
		currRandNumbTime = RandRange(m_timeBetweenRandomDestroyMax);
		
		m_destroyableElements.PushBack(m_destroyableElementsRandom);
		m_destroyableElements.PushBack(m_destroyableElementsTimed);
		m_destroyableElements.PushBack(m_destroyableElementsOnContact);
		m_destroyableElements.PushBack(m_destroyableElementsOnDistance);
		
		m_randNumber = RandRange(m_timeBetweenRandomDestroyMax);
		
		AddTimer( 'updateTick', tickInterval, true );
	}
	
	timer function updateTick( time : float, id : int)
	{
		var i : int;
		var dist : float;
		var comp : CScriptedDestroyableComponent;
		var elements 	: array< CScriptedDestroyableComponent >;
	
		if(m_activated)
		{
			tickTime+=time;
			
			
			elements = m_destroyableElements[0];
			for(i = 0; i < elements.Size(); i+=1)
			{
				comp  = (CScriptedDestroyableComponent)elements[i];
				dist = VecDistance(comp.GetWorldPosition(),thePlayer.GetWorldPosition());
				if(tickTime>currRandNumbTime && currRandNumbId == i && elements[i].m_state == DC_Idle)
				{
					elements[i].m_state = DC_PreDestroy;
				}
				else if(elements[i].m_state == DC_PreDestroy)
				{
					elements[i].PreDestroyTick(time);
				}
				else if(elements[i].m_state == DC_Destroy)
				{
					elements[i].DestroyTick(time);
				}
				else if(elements[i].m_state == DC_PostDestroy)
				{
					elements[i].PostDestroyTick(time);
					
					if(currRandNumbId == i)
					{
						currRandNumbId = RandRange(elements.Size());
						currRandNumbTime = tickTime + RandRange(m_timeBetweenRandomDestroyMax);
					}
				}
				else
				{
					elements[i].IdleTick(time);
				}
			}
			
			
			elements = m_destroyableElements[1];
			for(i = 0; i < elements.Size(); i+=1)
			{
				comp  = (CScriptedDestroyableComponent)elements[i];
				dist = VecDistance(comp.GetWorldPosition(),thePlayer.GetWorldPosition());
				
				if(tickTime<elements[i].GetDestroyAtTimeValue() && elements[i].m_state == DC_Idle)
				{
					elements[i].m_state = DC_PreDestroy;
				}
				else if(elements[i].m_state == DC_PreDestroy)
				{
					elements[i].PreDestroyTick(time);
				}
				else if(elements[i].m_state == DC_Destroy)
				{
					elements[i].DestroyTick(time);
				}
				else if(elements[i].m_state == DC_PostDestroy)
				{
					elements[i].PostDestroyTick(time);
				}
				else
				{
					elements[i].IdleTick(time);
				}
			}
			
			
			elements = m_destroyableElements[2];
			for(i = 0; i < elements.Size(); i+=1)
			{
				comp  = (CScriptedDestroyableComponent)elements[i];
				dist = VecDistance(comp.GetWorldPosition(),thePlayer.GetWorldPosition());
				
				if(dist<1.5f && elements[i].m_state == DC_Idle)
				{
					elements[i].m_state = DC_PreDestroy;
				}
				else if(elements[i].m_state == DC_PreDestroy)
				{
					elements[i].PreDestroyTick(time);
				}
				else if(elements[i].m_state == DC_Destroy)
				{
					elements[i].DestroyTick(time);
				}
				else if(elements[i].m_state == DC_PostDestroy)
				{
					elements[i].PostDestroyTick(time);
				}
				else
				{
					elements[i].IdleTick(time);
				}
			}
			
			
			elements = m_destroyableElements[3];
			for(i = 0; i < elements.Size(); i+=1)
			{
				comp  = (CScriptedDestroyableComponent)elements[i];
				dist = VecDistance(comp.GetWorldPosition(),thePlayer.GetWorldPosition());
				
				if(dist<elements[i].GetDistanceToTargetValue() 
					&& elements[i].m_state == DC_Idle)
				{
					elements[i].m_state = DC_PreDestroy;
				}
				else if(m_destroyableElements[3][i].m_state == DC_PreDestroy)
				{
					elements[i].PreDestroyTick(time);
				}
				else if(elements[i].m_state == DC_Destroy)
				{
					elements[i].DestroyTick(time);
				}
				else if(elements[i].m_state == DC_PostDestroy)
				{
					elements[i].PostDestroyTick(time);
				}
				else
				{
					elements[i].IdleTick(time);
				}
			}
		}
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{		
		m_activated = true;
		tickTime = 0;
	}	
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
	}
}

state OnIdle in W3DestroyableTerrain
{
	event OnEnterState( prevStateName : name )
	{
	}
	
	event OnLeaveState( prevStateName : name )
	{
	}
}

state OnPreDestroy in W3DestroyableTerrain
{
	event OnEnterState( prevStateName : name )
	{
	}
	
	event OnLeaveState( prevStateName : name )
	{
	}
}

state OnDestroy in W3DestroyableTerrain
{
	event OnEnterState( prevStateName : name )
	{
	}
	
	event OnLeaveState( prevStateName : name )
	{
	}
}