/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskCarryBox extends IBehTreeTask
{
	var entityTemplate : CEntityTemplate;
	var pickUpPoint : name;
	var dropPoint : name;
	var box : CEntity;
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var allSPoints : array< CNode >;
		var allEPoints : array< CNode >;
		var boxPoint, endPoint : CNode;
		var startPos, endPos, boxPos : Vector;
		var point : float;
		var res, res2 : bool;
		
		theGame.GetNodesByTag( pickUpPoint, allSPoints );
		boxPoint = FindClosestNode( npc.GetWorldPosition(), allSPoints );
		
		startPos = boxPoint.GetWorldPosition();
		box = (CEntity)theGame.CreateEntity( entityTemplate, startPos );
		
		startPos.Y = startPos.Y + 0.5f;
		res = npc.ActionMoveToWithHeading( startPos, startPos.Y, MT_Walk, 0.f, 0.1f );
		
		if( res )
		{
			res2 = npc.ActionRotateTo( box.GetWorldPosition() );
			if( res2 )
			{
				npc.RaiseForceEvent( 'pickUpBox' );
				npc.SetBehaviorVariable( 'hasBox', 1.f );
				npc.WaitForBehaviorNodeDeactivation( 'boxPickedUp', 5.f );
			}
		}
		theGame.GetNodesByTag( dropPoint, allEPoints );
		endPoint = FindClosestNode( npc.GetWorldPosition(), allEPoints );
		endPos = endPoint.GetWorldPosition();
		
		res = npc.ActionMoveToWithHeading( endPos, endPos.Y, MT_Walk, 0.f, 1.f );
		
		if( res )
		{
			npc.RaiseForceEvent( 'putDownBox' );
			box.DestroyAfter( 20.f );
			npc.WaitForBehaviorNodeDeactivation( 'boxPutDown', 3.f );
		}
		return BTNS_Completed;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if( animEventName == 'TakeItem' )
		{
			box.CreateAttachment( npc, 'r_weapon' );
			return true;
		}
		else if( animEventName == 'LeaveItem' )
		{
			box.BreakAttachment();
			npc.SetBehaviorVariable( 'hasBox', 0.f );
			return true;
		}
		return false;
	}
}

class CTTaskCarryBoxDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskCarryBox';

	editable var entityTemplate : name;
	editable var pickUpPoint : CBehTreeValCName;
	editable var dropPoint : CBehTreeValCName;

	function OnSpawn( taskGen : IBehTreeTask )
	{
		var task : CBTTaskCarryBox;
		task = (CBTTaskCarryBox) taskGen;
		task.entityTemplate = (CEntityTemplate) GetObjectByVar( entityTemplate );
	}
}

class CBTTaskRestBetweenBoxes extends IBehTreeTask
{
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		npc.RaiseForceEvent( 'RestBetweenBoxes' );
		npc.WaitForBehaviorNodeDeactivation( 'restingFinished', 5.f );
		return BTNS_Completed;
	}
}

class CBTTaskRestBetweenBoxesDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskRestBetweenBoxes';
}