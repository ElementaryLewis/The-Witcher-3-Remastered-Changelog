/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskForceSetStat extends IBehTreeTask
{
	var npc 			: CNewNPC;
	var percent			: int;
	var onActivate		: bool;
	var onDeactivate	: bool;
	
	default percent = 100;
	
	function OnActivate() : EBTNodeStatus
	{
		npc = GetNPC();
		
		if( onActivate )
		{
			ForceStat();
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( onDeactivate )
		{
			ForceStat();
		}
	}
	
	private function ForceStat()
	{
		var stat : EBaseCharacterStats;
		var maxStat : float;
	
		if(	npc.UsesVitality() )
		{
			stat = BCS_Vitality;
			maxStat = npc.GetStatMax( BCS_Vitality );
		}
		else if( npc.UsesEssence() )
		{
			stat = BCS_Essence;
			maxStat = npc.GetStatMax( BCS_Essence );
		}
		
		if( percent > 100 )
		{
			percent = 100;
		}
		
		npc.ForceSetStat( stat, ( maxStat * percent ) / 100 );
	}
}


class CBTTaskForceSetStatDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskForceSetStat';

	editable var percent	: int;
	editable var onActivate		: bool;
	editable var onDeactivate	: bool;
}