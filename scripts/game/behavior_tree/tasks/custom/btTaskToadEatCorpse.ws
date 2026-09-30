/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskToadEatCorpse extends IBehTreeTask
{
	var npc 		: CNewNPC;
	var corpsePos 	: Vector;
	var corpse		: CEntity;
	var distance	: float;
	

	function OnActivate() : EBTNodeStatus
	{
		npc = GetNPC();
		corpse = (CEntity)GetActionTarget();
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		corpsePos = GetActionTarget().GetWorldPosition();
		distance = VecDistance2D( npc.GetWorldPosition(), corpsePos );
		npc.SetBehaviorVariable('bodyDistance', distance );
		npc.SetBehaviorVectorVariable( 'lookAtTarget', corpsePos );
		Sleep(0.5);
		npc.RaiseEvent( 'ShootTongue');
		
		corpse.CreateAttachment( npc, 'bodyAttach' );
		
			
			
		return BTNS_Completed;
	}
	
	function OnDeactivate()
	{
		if( corpse.HasAttachment() )
		{
			corpse.BreakAttachment();
			corpse.Destroy();
		}
	}
}
class CBTTaskToadEatCorpseDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskToadEatCorpse';
}