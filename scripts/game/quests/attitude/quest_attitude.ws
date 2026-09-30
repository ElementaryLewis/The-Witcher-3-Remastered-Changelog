/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
quest function SetGroupAttitudeQuest( srcGroup : name, dstGroup : name, attitude : EAIAttitude )
{
	theGame.SetGlobalAttitude( srcGroup, dstGroup, attitude );
}

quest function AssignNPCGroupAttitudeQuest( npcTag : name, attGroup : name )
{
	var npcs : array<CNewNPC>;
	var i : int;
	var executed : bool;

	theGame.GetNPCsByTag( npcTag, npcs );
	executed = false;
	for(i=0; i<npcs.Size(); i+=1)
	{
		if(npcs[i])
		{
			npcs[i].SetBaseAttitudeGroup( attGroup );
			executed = true;
		}
	}
	
	if(!executed)
		LogQuest("AssignNPCGroupAttitudeQuest: cannot find any NPC with tag <<" + npcTag + ">>, unable to change attitude group to <<" + attGroup + ">>");
}

quest function AssignNPCTemporaryGroupAttitudeQuest( npcTag : name, attGroup : name, priority : EAttitudeGroupPriority, set : bool )
{
	var npcs : array<CNewNPC>;
	var i : int;
	var executed : bool;

	theGame.GetNPCsByTag( npcTag, npcs );
	executed = false;
	for(i=0; i<npcs.Size(); i+=1)
	{
		if(npcs[i])
		{
			if (set)
			{
				npcs[i].SetTemporaryAttitudeGroup( attGroup, priority );
			}
			else
			{
				npcs[i].ResetTemporaryAttitudeGroup( priority );
			}
			executed = true;
		}
	}
	
	if(!executed)
		LogQuest("AssignNPCTemporaryGroupAttitudeQuest: cannot find any NPC with tag <<" + npcTag + ">>, unable to change attitude group to <<" + attGroup + ">>");
}

quest function ForceTargetQuest( npcTag : name, targetTag : name, unforce : bool )
{
	var npcs : array<CNewNPC>;
	var actor : CActor;
	var i : int;
	var executed : bool;
	
	theGame.GetNPCsByTag( npcTag, npcs );
	actor = theGame.GetActorByTag( targetTag );
	executed = false;
	
	if(!actor)
	{
		LogQuest("ForceTargetQuest: cannot find target Actor with tag <<" + targetTag + ">>!!!");
		return;
	}
	
	for ( i=0; i < npcs.Size(); i+=1 )
	{
		if(npcs[i])
		{
			if ( !unforce )
			{
				npcs[i].NoticeActor( actor );
				npcs[i].SignalGameplayEventParamObject( 'ForceTarget', actor );
				
			}
			else
			{
				npcs[i].SignalGameplayEvent('UnforceTarget');
			}
			executed = true;
		}
	}
	
	if(!executed)
		LogQuest("ForceTargetQuest: cannot find any NPCs with tag <<" + npcTag + ">>!!!");
}

quest function ForgetTargetQuest( npcTag : name )
{
	var npcs : array<CNewNPC>;
	var actor : CActor;
	var i : int;
	
	theGame.GetNPCsByTag( npcTag, npcs );
	
	if(npcs.Size() <= 0)
		LogQuest("ForgetTargetQuest: cannot find any NPCs with tag <<" + npcTag + ">>!!!");
	
	for ( i=0; i < npcs.Size(); i+=1 )
	{
		npcs[i].ForgetAllActors();
	}
	
	
}


quest function SetAttitudeTowardsNPC( npcTag : name, targetTag : name, attitude : EAIAttitude )
{
	var npcs : array<CNewNPC>;
	var target : CActor;
	var i : int;
	
	theGame.GetNPCsByTag( npcTag, npcs );
	target = theGame.GetActorByTag( targetTag );
	
	if(npcs.Size() > 0 && target)
	{
		for ( i=0; i < npcs.Size(); i+=1 )
		{
			npcs[i].SetAttitude( target, attitude );
		}	
	}
}