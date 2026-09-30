/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskRaiseEventOnEntity extends IBehTreeTask
{
	private var entityTag : name;
	private var eventName : name;
	private var forceEvent : bool;
	private var maxDistFromNpc : float;
	private var raiseSameEventOnOwner : bool;

	function OnActivate() : EBTNodeStatus
	{
		var entity : CEntity;
		var npc : CNewNPC;
		
		entity = (CEntity)theGame.GetNodeByTag( entityTag );
		npc = GetNPC();
		
		if( entity )
		{
			if( maxDistFromNpc && VecDistance2D( entity.GetWorldPosition(), npc.GetWorldPosition() ) > maxDistFromNpc )
			{
				return BTNS_Failed;
			}
			
			if( forceEvent )
			{
				entity.RaiseForceEvent( eventName );
				
				if( raiseSameEventOnOwner )
				{
					npc.RaiseForceEvent( eventName );
				}
			}
			else
			{
				entity.RaiseEvent( eventName );
				
				if( raiseSameEventOnOwner )
				{
					npc.RaiseEvent( eventName );
				}
			}
		}
		else
		{
			return BTNS_Failed;
		}
		
		return BTNS_Active;
	}
}




class BTTaskRaiseEventOnEntityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskRaiseEventOnEntity';
	
	editable var entityTag : name;
	editable var eventName : name;
	editable var forceEvent : bool;
	editable var maxDistFromNpc : float;
	editable var raiseSameEventOnOwner : bool;
	
	default forceEvent = false;
}




class BTTaskPlaySyncedAnimWithEntity extends IBehTreeTask
{
	private var entityTag : name;
	private var syncAnimName : name;

	function OnActivate() : EBTNodeStatus
	{
		var entity : CEntity;
		var npc : CNewNPC;
		
		entity = (CEntity)theGame.GetNodeByTag( entityTag );
		npc = GetNPC();
		
		if( entity )
		{
			theGame.GetSyncAnimManager().SetupSimpleSyncAnim2( syncAnimName, npc, entity );
		}
		else
		{
			return BTNS_Failed;
		}
		
		return BTNS_Active;
	}
}




class BTTaskPlaySyncedAnimWithEntityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskPlaySyncedAnimWithEntity';
	
	editable var entityTag : name;
	editable var syncAnimName : name;
}