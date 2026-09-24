/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class IBehTreeValueEnum extends IScriptable
{
	import editable var varName : name;
};

class CBTEnumBehaviorGraph extends IBehTreeValueEnum
{
	editable var value : EBehaviorGraph;
	
	function SetVal( val : int )
	{
		value = val;
	}
};

class CBTEnumMoveType extends IBehTreeValueEnum
{
	editable var value : EMoveType;
	
	function SetVal( val : int )
	{
		value = val;
	}
};

class CBTEnumCriticalState extends IBehTreeValueEnum
{
	editable var value : ECriticalStateType;
	
	function SetVal( val : int )
	{
		value = val;
	}
}

class CBTEnumHitReactionType extends IBehTreeValueEnum
{
	editable var value : EHitReactionType;
	
	function SetVal( val : int )
	{
		value = val;
	}
}

class CBTEnumHitReactionSide extends IBehTreeValueEnum
{
	editable var value : EHitReactionSide;
	
	function SetVal( val : int )
	{
		value = val;
	}
}

class CBTEnumHitReactionDirection extends IBehTreeValueEnum
{
	editable var value : EHitReactionDirection;
	
	function SetVal( val : int )
	{
		value = val;
	}
}

class CBTEnumAttackSwingType extends IBehTreeValueEnum
{
	editable var value : EAttackSwingType;
	
	function SetVal( val : int )
	{
		value = val;
	}
}

class CBTEnumAttackSwingDriection extends IBehTreeValueEnum
{
	editable var value : EAttackSwingDirection;
	
	function SetVal( val : int )
	{
		value = val;
	}
}
