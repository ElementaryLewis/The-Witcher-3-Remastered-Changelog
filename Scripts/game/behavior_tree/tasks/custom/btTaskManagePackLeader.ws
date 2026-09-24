/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskManagePackLeader extends IBehTreeTask
{
	
	
	
	public var packName				: name;
	public var leadingRadius		: float;
	public var forceMeAsLeader		: bool;
	
	private var  m_checkDelay		: float;
	
	default m_checkDelay = 1;
	
	
	private function OnDeactivate()
	{
		var l_npc : CNewNPC = GetNPC();
		l_npc.isPackLeader = false;
	}
	
	
	latent function Main() : EBTNodeStatus
	{
		var i					: int;
		var l_npc				: CNewNPC = GetNPC();
		var l_otherNPC			: CNewNPC;
		var l_delayToNextCheck	: float;
		var l_leaderIsHere		: bool;
		
		var l_actorsAround		: array<CActor>;
		
		l_npc.packName = packName;
		
		while( true )
		{
			
			
			l_actorsAround = GetActorsInRange( l_npc, leadingRadius,,, true );
			l_leaderIsHere = false;
			
			if( forceMeAsLeader  )
			{
				l_npc.isPackLeader = true;
			}
			
			
			for( i = 0 ; i < l_actorsAround.Size() ; i += 1 )
			{
				l_otherNPC = (CNewNPC) l_actorsAround[ i ];
				
				if( l_otherNPC == l_npc )
					continue;
				
				if( l_otherNPC.isPackLeader && l_otherNPC.packName == packName )
				{
					
					if( l_npc.isPackLeader )
					{
						l_otherNPC.isPackLeader = false;
					}
					else
					{
						
					}
					
					l_leaderIsHere = true;
					
					
				}
			}
			
			
			if( !l_npc.isPackLeader && !l_leaderIsHere )
			{
				l_npc.isPackLeader = true;
			}
			
			if( l_npc.isPackLeader )
			{
				GetNPC().GetVisualDebug().AddText('IsLeader', "!!Is Leader!!" + l_npc.isPackLeader , Vector(0,0,1.5f ), false,,Color( 255, 255, 255 ), true, 1.2f );
			}
			
			
			SleepOneFrame();
		}
		return BTNS_Completed;
	}

}



class BTTaskManagePackLeaderDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskManagePackLeader';	
	
	editable var packName			: CBehTreeValCName;
	editable var leadingRadius		: float;
	editable var forceMeAsLeader 	: bool;
}