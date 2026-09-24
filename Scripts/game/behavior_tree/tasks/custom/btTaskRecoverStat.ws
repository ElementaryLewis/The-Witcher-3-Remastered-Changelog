/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskRecoverStat extends IBehTreeTask
{
	var npc 			: CNewNPC;
	var percentReturn	: int;
	var onActivate		: bool;
	var onDeactivate	: bool;
	
	default percentReturn = 100;
	
	function OnActivate() : EBTNodeStatus
	{
		npc = GetNPC();
		
		if( onActivate )
		{
			RecoverStat();
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( onDeactivate )
		{
			RecoverStat();
		}
	}
	
	private function RecoverStat()
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
		
		if( percentReturn > 100 )
		{
			percentReturn = 100;
		}
		
		npc.GainStat( stat, ( maxStat * percentReturn ) / 100 );
	}
}


class BTTaskRecoverStatDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskRecoverStat';

	editable var percentReturn	: int;
	editable var onActivate		: bool;
	editable var onDeactivate	: bool;
}