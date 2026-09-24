/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3KillTrigger extends CEntity
{
	private var postponedTillOnGroundMPAC 	: array<CMovingPhysicalAgentComponent>;	
	editable var postponeTillOnGround 		: bool;
	editable var postponeTillStoppedFalling : bool;
	editable var postponeTillinWater 		: bool;
	
		default postponeTillOnGround = true;
		default postponeTillinWater = true;
		
	hint postponeTillOnGround = "If set, actor won't be killed until it's on ground";
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		
		actor = (CActor)activator.GetEntity();
		
		if ( actor)
		{
			if(postponeTillOnGround || postponeTillStoppedFalling || postponeTillinWater )
			{
				postponedTillOnGroundMPAC.PushBack( (CMovingPhysicalAgentComponent)actor.GetMovingAgentComponent() );
				if(postponedTillOnGroundMPAC.Size() == 1)
					AddTimer('PostponedKills', 0.05, true, , , true);
			}
			else
			{
				actor.Kill( 'Kill Trigger' );
			}
		}
	}
	
	
	timer function PostponedKills(dt : float, id : int)
	{
		var i : int;
		var actor : CActor;
		
		for(i=postponedTillOnGroundMPAC.Size()-1; i>=0; i-=1)
		{
			if( postponeTillStoppedFalling && postponedTillOnGroundMPAC[i].IsFalling() == false)
			{
				((CActor)postponedTillOnGroundMPAC[i].GetEntity()).Kill( 'Kill Trigger' );
				postponedTillOnGroundMPAC.EraseFast(i);
				continue;
			}
			if( postponeTillOnGround && postponedTillOnGroundMPAC[i].IsOnGround())
			{
				((CActor)postponedTillOnGroundMPAC[i].GetEntity()).Kill( 'Kill Trigger' );
				postponedTillOnGroundMPAC.EraseFast(i);
				continue;
			}
			
			actor = (CActor)postponedTillOnGroundMPAC[i].GetEntity();
			
			if(postponeTillinWater && actor.IsSwimming())
			{
				actor.Kill( 'Kill Trigger' );
				postponedTillOnGroundMPAC.EraseFast(i);
				continue;
			}
		}
		
		if(postponedTillOnGroundMPAC.Size() == 0)
			RemoveTimer('PostponedKills');
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		var mpac : CMovingPhysicalAgentComponent;
		
		if(postponeTillOnGround)
		{
			
			
			actor = (CActor)activator.GetEntity();
			
			if ( actor)
			{
				mpac = (CMovingPhysicalAgentComponent)actor.GetMovingAgentComponent();
				postponedTillOnGroundMPAC.Remove(mpac);
			}
		}
	}
}