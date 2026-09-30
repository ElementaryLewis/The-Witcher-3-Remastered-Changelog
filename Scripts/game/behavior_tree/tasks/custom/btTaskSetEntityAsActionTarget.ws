/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskSetEntityAsActionTarget extends IBehTreeTask
{
	
	
	
	var targetTag			: name;
	var multipleTargetsTags : array<name>;
	var completeImmediately : bool;
	
	
	function OnActivate() : EBTNodeStatus
	{	
		var l_target		: CNode;
		var l_selectedTag	: name;
		var l_size			: int;
		
		l_size = multipleTargetsTags.Size();
		
		if ( l_size > 0 )
			l_selectedTag = multipleTargetsTags[RandRange(l_size)];
		else
			l_selectedTag = targetTag;
		
		l_target = theGame.GetNodeByTag( l_selectedTag );		
		SetActionTarget( l_target );
		
		if ( completeImmediately )
			return BTNS_Completed;
		else
			return BTNS_Active;
	}

}


class BTTaskSetEntityAsActionTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSetEntityAsActionTarget';
	
	
	editable var targetTag	: CBehTreeValCName;
	editable var multipleTargetsObjectName : name;
	editable var completeImmediately : bool;
	
	default multipleTargetsObjectName = 'multipleTargetsTags';
	default completeImmediately = true;
	
	hint multipleTargetsObjectName = "only works for parametrization.";
	
	
	function OnSpawn( taskGen : IBehTreeTask )
	{
		var task : BTTaskSetEntityAsActionTarget;
		task = (BTTaskSetEntityAsActionTarget) taskGen;
		task.multipleTargetsTags =((W3BehTreeValNameArray)GetObjectByVar(multipleTargetsObjectName)).GetArray();
	}
}