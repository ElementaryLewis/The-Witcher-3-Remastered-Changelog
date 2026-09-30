/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class W3RepairObjectEnhancement extends CBaseGameplayEffect
{
	protected var usesPerkBonus : bool;
	protected var durUpdates : bool;
	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	default usesPerkBonus = false;
	
	public function OnTimeUpdated(dt : float)
	{
		var hasRuneword5 : bool;
		
		
		if(isOnPlayer)
			hasRuneword5 = GetWitcherPlayer().HasRunewordActive('Runeword 5 _Stats');
		else
			hasRuneword5 = false;
		
		if(hasRuneword5)
		{
			if( isActive && pauseCounters.Size() == 0)
			{
				timeActive += dt;	
			}
			
			timeLeft = 0.f;
			durUpdates = false;
			return;
		}
		else if(!durUpdates)
		{
			timeLeft = duration - timeActive;
			durUpdates = true;
		}
		
		super.OnTimeUpdated(dt);
	}
}