/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_AutoStaminaRegen extends W3AutoRegenEffect
{
	private var regenModeIsCombat : bool;		
	private var cachedPlayer : CR4Player;
	
		default regenStat = CRS_Stamina;	
		default effectType = EET_AutoStaminaRegen;
		default regenModeIsCombat = true;		
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		regenModeIsCombat = true;
		
		if(isOnPlayer)
			cachedPlayer = (CR4Player)target;
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		if(isOnPlayer)
			cachedPlayer = (CR4Player)target;
	}
	
	event OnUpdate(dt : float)
	{
		if(isOnPlayer)
		{
			
			if ( regenModeIsCombat != cachedPlayer.IsInCombat() )
			{
				regenModeIsCombat = !regenModeIsCombat;
				if(regenModeIsCombat)
					attributeName = RegenStatEnumToName(regenStat);
				else
					attributeName = 'staminaOutOfCombatRegen';
					
				SetEffectValue();			
			}
			
			
			if ( cachedPlayer.IsInCombat() )
			{
				if ( thePlayer.IsGuarded() )
					effectValue = target.GetAttributeValue( 'staminaRegenGuarded' );
				else
				{
					attributeName = RegenStatEnumToName(regenStat);
					SetEffectValue();
				}
			}
		}

		super.OnUpdate( dt );
		
		if( target.GetStatPercents( BCS_Stamina ) >= 1.0f )
		{
			target.StopStaminaRegen();
		}
	}
	
	protected function SetEffectValue()
	{
		effectValue = target.GetAttributeValue(attributeName);
	}
}
