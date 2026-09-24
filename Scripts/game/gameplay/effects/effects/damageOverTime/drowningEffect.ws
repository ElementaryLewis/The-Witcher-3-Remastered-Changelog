/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Drowning extends W3DamageOverTimeEffect
{
	var m_NoSaveLockInt : int;
	var isEffectOn : bool;
	var mac : CMovingPhysicalAgentComponent;
	var submergeDepth : float;
	
	default effectType = EET_Drowning;
	default resistStat = CDS_None;
	default isEffectOn = false;
	default submergeDepth = 0.0;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		mac = (CMovingPhysicalAgentComponent)target.GetMovingAgentComponent();
		submergeDepth = mac.GetSubmergeDepth();
		
		if( submergeDepth < -3.0 )
		{
			target.PlayEffectSingle( 'underwater_drowning' );
			isEffectOn = true;
		}
		
		target.PauseHPRegenEffects( 'drowning' );
		theGame.CreateNoSaveLock( "player_drowning", m_NoSaveLockInt );
	}
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);

		submergeDepth = mac.GetSubmergeDepth();
		if( submergeDepth < -3.0 )
		{
			if( !isEffectOn )
			{
				target.PlayEffectSingle( 'underwater_drowning' );
				isEffectOn = true;
			}
		}
		else
		{
			if( isEffectOn )
			{
				target.StopEffect( 'underwater_drowning' );
				isEffectOn = false;
			}
		}
		
		
		if( target.GetStat(BCS_Air) > 0 || ( isOnPlayer && !thePlayer.OnCheckDiving() ) )
		{
			isActive = false;
			return false;
		}
	}
	
	event OnEffectRemoved()
	{
		target.StopEffect('underwater_drowning');
		super.OnEffectRemoved();
		target.ResumeHPRegenEffects('drowning');
		theGame.ReleaseNoSaveLock( m_NoSaveLockInt );
	}
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		super.CalculateDuration(setInitialDuration);
		
		duration = -1;
	}
}
