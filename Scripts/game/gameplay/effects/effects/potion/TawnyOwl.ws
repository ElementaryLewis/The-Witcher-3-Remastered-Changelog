/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Potion_TawnyOwl extends W3RegenEffect
{
	default effectType = EET_TawnyOwl;
	
	public function OnTimeUpdated(deltaTime : float)
	{
		var currentHour, level : int;
		var toxicityThreshold : float;
		
		if( isActive && pauseCounters.Size() == 0)
		{
			timeActive += deltaTime;	
			if( duration != -1 )
			{
				
				level = GetBuffLevel();				
				currentHour = GameTimeHours(theGame.GetGameTime());
				if(level < 3 || (currentHour > GetHourForDayPart(EDP_Dawn) && currentHour < GetHourForDayPart(EDP_Dusk)) )
					timeLeft -= deltaTime;
					
				if( timeLeft <= 0 )
				{
					if ( thePlayer.CanUseSkill(S_Alchemy_s03) )
					{
						toxicityThreshold = thePlayer.GetStatMax(BCS_Toxicity);
						toxicityThreshold *= 1 - CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Alchemy_s03, 'toxicity_threshold', false, true) ) * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s03);
					}
					if(isPotionEffect && target == thePlayer && thePlayer.CanUseSkill(S_Alchemy_s03) && thePlayer.GetStat(BCS_Toxicity, true) > toxicityThreshold)
					{
						
					}
					else
					{
						isActive = false;		
					}
				}
			}
			OnUpdate(deltaTime);	
		}
	}
}