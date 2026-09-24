/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskIfTargetHasEffect extends IBehTreeTask
{
	var effect : EEffectType;
	var useCombatTarget : bool;
	
	function IsAvailable() : bool
	{
		var npc		: CNewNPC = GetNPC();
		var target 	: CActor;
		
		if ( useCombatTarget )
		{
			if ( GetCombatTarget().HasBuff( effect ) )
			{
				return true;
			}
		}
		else
		{
			target = (CActor)GetActionTarget();
			if ( target && target.HasBuff( effect ) )
			{
				return true;
			}
		}
		
		return false;
	}
	
};

class CBTTaskIfTargetHasEffectDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskIfTargetHasEffect';

	editable var effect : EEffectType;
	editable var useCombatTarget : bool;
	
	default useCombatTarget = true;
};




class CBTTaskIfTargetHasEffects extends IBehTreeTask
{
	var effects 			: array<EEffectType>;
	var useCombatTarget 	: bool;
	
	
	function IsAvailable() : bool
	{
		var npc		: CNewNPC = GetNPC();
		var target	: CActor;
		var i		: int;
		
		if ( useCombatTarget )
		{
			target = npc.GetTarget();
			for ( i=0; i < effects.Size(); i+=1 )
			{
				if ( target.HasBuff( effects[i] ) )
				{
					return true;
				}
			}
		}
		else
		{
			target = (CActor)GetActionTarget();
			for ( i=0; i < effects.Size(); i+=1 )
			{
				if ( target && target.HasBuff( effects[i] ) )
				{
					return true;
				}
			}
		}
		return false;
	}
};

class CBTTaskIfTargetHasEffectsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskIfTargetHasEffects';

	editable var effects 			: array<EEffectType>;
	editable var useCombatTarget 	: bool;
	
	
	default useCombatTarget = true;
	
	hint and = "Switcher from 'or' to 'and'";
};





class CBTTaskHasEffects extends IBehTreeTask
{
	var effects 			: array<EEffectType>;
	
	
	function IsAvailable() : bool
	{
		var owner	: CActor = GetActor();
		var i		: int;
		
		for ( i=0; i < effects.Size(); i+=1 )
		{
			if ( owner.HasBuff( effects[i] ) )
			{
				return true;
			}
		}
		
		return false;
	}
};

class CBTTaskHasEffectsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskHasEffects';

	editable var effects 			: array<EEffectType>;
};
