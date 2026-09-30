/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3LocationArea extends CGameplayEntity
{
	editable var locationNameKey : name;
	editable var rewardName : name;
	saved var discovered : bool;
	
		hint locationNameKey = "Name of localization key of the area name";
		hint rewardName = "Name of reward to give on first discovery (from Rewards Editor)";
	
		default discovered = false;	
		
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if(IsNameValid(locationNameKey))
		{
			thePlayer.DisplayHudMessage( GetLocStringByKey("panel_hud_message_enter_location") + " " + GetLocStringByKey(locationNameKey) );
			
			if(!discovered && IsNameValid(rewardName))
			{
				discovered = true;
				theGame.GiveReward(rewardName, thePlayer);
			}
		}
	}
}