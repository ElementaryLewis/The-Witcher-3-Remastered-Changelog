/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTManageIsPlayerFollower extends IBehTreeTask
{
	var targetTagCondition	: name;
	var overrideForThisTask	: bool;
	var disable				: bool;
	var onActivate			: bool;
	var onDeactivate		: bool;
	
	public var targetTagCompare : name;
	
	
	
	
	function OnActivate() : EBTNodeStatus
	{
		if ( IsNameValid( targetTagCondition ) )
		{
			if ( targetTagCondition == targetTagCompare )
				SetIsFollowerFlags( true );
		}
		else
			SetIsFollowerFlags( true );
		
		return BTNS_Active;
	}
	
	
	
	function OnDeactivate()
	{
		if ( IsNameValid( targetTagCondition ) )
		{
			if ( targetTagCondition == targetTagCompare )
				SetIsFollowerFlags( false );
		}
		else
			SetIsFollowerFlags( false );
	}
	
	function SetIsFollowerFlags( activation : bool )
	{
		var npc : CNewNPC = GetNPC();
		
		if ( overrideForThisTask && disable )
			npc.isPlayerFollower = activation;
		else if ( overrideForThisTask )
			npc.isPlayerFollower = !activation;
		
		if ( onDeactivate && !overrideForThisTask )
		{
			if ( disable )
				npc.isPlayerFollower = false;
			else
				npc.isPlayerFollower = true;
		}
	}
}

class CBTManageIsPlayerFollowerDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTManageIsPlayerFollower';
	
	editable var targetTagCondition		: name;
	editable var overrideForThisTask	: bool;
	editable var disable				: bool;
	editable var onActivate				: bool;
	editable var onDeactivate			: bool;
	
	private var params1 : CAIFollowParams;
	private var params2 : CAIMoveAlongPathWithCompanionParams;
	
	default overrideForThisTask = true;
	
	function OnSpawn( task : IBehTreeTask )
	{
		var thisTask : CBTManageIsPlayerFollower;
		
		thisTask = (CBTManageIsPlayerFollower)task;
		
		params1 = (CAIFollowParams)GetAIParametersByClassName( 'CAIFollowParams' );
		if ( IsNameValid( params1.targetTag ) )
			thisTask.targetTagCompare = params1.targetTag;
		
		params2 = (CAIMoveAlongPathWithCompanionParams)GetAIParametersByClassName( 'CAIMoveAlongPathWithCompanionParams' );
		if ( IsNameValid( params2.companionTag ) )
			thisTask.targetTagCompare = params2.companionTag;
	}
}