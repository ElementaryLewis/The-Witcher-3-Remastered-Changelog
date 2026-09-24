/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskPlayerBehaviorMonitor extends IBehTreeTask
{
	var eventNameToRaise : name;
	var scanningCooldown : float;
	var extraWindow : float;
	var sendEvent : bool;
	
	default extraWindow = 0.0;
	default sendEvent = false;
	
	latent function Main() : EBTNodeStatus
	{
		while( true )
		{		
			ResetValues();
			
			if( thePlayer.GetIsRunning() )
			{
				sendEvent = true;
			}
			else if( thePlayer.substateManager.GetStateCur() == 'Jump' )
			{
				sendEvent = true;
			}
			else if( thePlayer.IsInCombatAction() )
			{
				if( thePlayer.GetBehaviorVariable( 'combatActionType' ) == 0.0 || 
					thePlayer.GetBehaviorVariable( 'combatActionType' ) == 1.0 || 
					thePlayer.GetBehaviorVariable( 'combatActionType' ) == 2.0 || 
					thePlayer.GetBehaviorVariable( 'combatActionType' ) == 3.0 || 
					thePlayer.GetBehaviorVariable( 'combatActionType' ) == 7.0 || 
					thePlayer.GetBehaviorVariable( 'combatActionType' ) == 6.0 )  
				{
					sendEvent = true;
				}
			}
		
			if( sendEvent )
			{
				SendEvent();
				extraWindow = 1.0;
			}
			
			Sleep( scanningCooldown + extraWindow );
		}
		
		return BTNS_Active;
	}
	
	function SendEvent()
	{
		GetActor().SignalGameplayEvent( eventNameToRaise );
	}
	
	function ResetValues()
	{
		sendEvent = false;
		extraWindow = 0.0;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{	
		var node : CNode;
		if ( eventName == 'shootAtPoint' )
		{		
			node = (CNode)GetEventParamObject();
			SetActionTarget( node );
			
			return true;
		}
		
		return false;
	}
}

class CBTTaskPlayerBehaviorMonitorDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskPlayerBehaviorMonitor';

	editable var eventNameToRaise : name;
	editable var scanningCooldown : float;
	
	default eventNameToRaise = 'shootAtPlayer';
	default scanningCooldown = 0.1;
}

class CBTTaskFindNodeClosestToPlayer extends IBehTreeTask
{
	var nodeTag : name;
	var range : float;
		
	function OnActivate() : EBTNodeStatus
	{	
		var npc	: CNewNPC = GetNPC();
		var nodes : array< CGameplayEntity >;
		var minDistance : float;
		var distance : float;
		var closestNode : CNode;
		var i : int;
		
		FindGameplayEntitiesInRange( nodes, npc, range, 99, nodeTag );
		
		if( nodes.Size() )
		{
			for( i = 0; i < nodes.Size(); i += 1 )
			{
				distance = VecDistance( nodes[i].GetWorldPosition(), thePlayer.GetWorldPosition() );
				
				if( distance < minDistance || !minDistance )
				{
					minDistance = distance;
					closestNode = (CNode)nodes[i];
				}
			}
			
			SetActionTarget( closestNode );
		}
		
		return BTNS_Active;
	}
}

class CBTTaskFindNodeClosestToPlayerDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskFindNodeClosestToPlayer';

	editable var nodeTag : name;
	editable var range : float;
	
	default nodeTag = 'philippaTarget';
	default range = 50.0;
}