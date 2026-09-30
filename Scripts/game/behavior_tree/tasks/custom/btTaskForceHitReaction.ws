/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskForceHitReaction extends IBehTreeTask
{
	
	
	
	var hitReactionType			: EHitReactionType;
	var hitReactionSide			: EHitReactionSide;
	var hitReactionDirection	: EHitReactionDirection;
	var hitSwingType			: EAttackSwingType;
	var hitSwingDirection		: EAttackSwingDirection;
	
	
	function OnActivate() : EBTNodeStatus
	{
		var l_npc	: CNewNPC = GetNPC();
		
		l_npc.SetBehaviorVariable( 'HitReactionType', (int) hitReactionType );
		l_npc.SetBehaviorVariable( 'HitReactionSide', (int) hitReactionSide );
		l_npc.SetBehaviorVariable( 'HitReactionDirection', (int) hitReactionDirection );
		l_npc.SetBehaviorVariable( 'HitSwingType', (int) hitSwingType );
		l_npc.SetBehaviorVariable( 'HitSwingDirection', (int) hitSwingDirection );
		
		return BTNS_Active;
	}
	
}


class BTTaskForceHitReactionDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskForceHitReaction';
	
	
	
	editable inlined var hitReactionType		: CBTEnumHitReactionType;
	editable inlined var hitReactionSide		: CBTEnumHitReactionSide;
	editable inlined var hitReactionDirection	: CBTEnumHitReactionDirection;
	editable inlined var hitSwingType			: CBTEnumAttackSwingType;
	editable inlined var hitSwingDirection		: CBTEnumAttackSwingDriection;
}
