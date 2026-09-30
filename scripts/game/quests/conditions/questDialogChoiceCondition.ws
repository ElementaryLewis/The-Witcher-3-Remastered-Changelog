/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_DialogChoiceCondition extends CQuestScriptedCondition
{
	private editable var dialogChoice : EDialogActionIcon;
	private editable var onOptionSelected : bool;		
	
	function Evaluate() : bool
	{	
		var flags, value : int;
		
		
		if(!theGame.IsDialogOrCutscenePlaying() || theGame.isCutscenePlaying)
			return false;
			
		
		if(onOptionSelected)
		{
			
			value = GameplayFactsQuerySum('dialog_used_choice_is_set');
		}
		else
		{
			
			value = GameplayFactsQuerySum('dialog_choice_is_set');
		}
		
		if(value <= 0)
			return false;		
		
		if(dialogChoice == 0)
		{
			
			return true;
		}
		else
		{
			if(onOptionSelected)
			{
				
				flags = GameplayFactsQuerySum('dialog_used_choice_flags');
			}
			else
			{
				
				flags = GameplayFactsQuerySum('dialog_choice_flags');
			}
			
			return flags & dialogChoice;
		}
	}
}