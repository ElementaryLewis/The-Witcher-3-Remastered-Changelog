/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_HasModifier extends CQCActorScriptedCondition
{
	editable var modifier 		: EEffectType;
	editable var timePercents 	: int;
	editable var condition		: ECompareOp;
	editable var modifierParam1	: name;
	editable var sourceName		: name;
	editable var sourceNamePartialSearch : bool;
	
	default timePercents		= 0;
	default condition			= CO_Greater;
	
	hint timePercents = "The percentage of effect time that will be compared using specified condition";
	hint condition = "Condition for timePercents comparision";
	hint modifierParam1	= "Parameter of the modifier - depends on type";
	hint sourceNamePartialSearch = "If set, checks if sourceName includes given string instead of being equal to it";

	function Evaluate(act : CActor) : bool
	{
		var p : int;
		var factBuff : W3Potion_Fact;
		var i : int;
		var found : bool;
		var buffs : array<CBaseGameplayEffect>;
		
		
		if(modifier == EET_Fact && IsNameValid(modifierParam1))
		{
			buffs = act.GetBuffs(EET_Fact, sourceName, sourceNamePartialSearch);
			found = false;
			for(i=0; i<buffs.Size(); i+=1)
			{
				factBuff = (W3Potion_Fact)buffs[i];
				if(factBuff.GetFactName() == modifierParam1)
				{
					found = true;
					break;
				}
			}
			
			if(!found)
				return false;
		}
		else
		{
			buffs = act.GetBuffs(modifier, sourceName, sourceNamePartialSearch);
		}
		
		if (buffs.Size() > 0)
		{
			
			if ( timePercents == 0 )
			{
				if ( condition == CO_Greater || condition == CO_GreaterEq )
				{
					return true;
				}
			}
			else if ( timePercents == 100 )
			{
				if ( condition == CO_LesserEq )
				{
					return true;
				}			
			}
			else
			{
				if(factBuff)
				{
					p = act.GetBuffTimePercentage( factBuff );
					return ProcessCompare( condition, p, timePercents );
				}
				else
				{
					for(i=0; i<buffs.Size(); i+=1)
					{
						p = act.GetBuffTimePercentage(buffs[i]);
						if(ProcessCompare( condition, p, timePercents ))
							return true;
					}
				}
			}
		}
		return false;
	}
}