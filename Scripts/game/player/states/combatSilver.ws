/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state CombatSilver in W3PlayerWitcher extends CombatSword
{	
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		parent.OnEquipMeleeWeapon( PW_Silver, true );
		
		this.CombatSilverInit( prevStateName );
	}
	
	
	event OnLeaveState( nextStateName : name )
	{ 
		
		this.CombatSilverDone( nextStateName );
		
		
		super.OnLeaveState(nextStateName);
	}
	
	public function GetSwordType() : name
	{ 
		return 'silversword';
	}

	
	entry function CombatSilverInit( prevStateName : name )
	{
		parent.OnEquipMeleeWeapon( PW_Silver, false );
		
		parent.SetBIsCombatActionAllowed( true );
		
		
		BuildComboPlayer();
		
		super.ProcessStartupAction( startupAction );		
		
		CombatSilverLoop();
	}

	
	entry function CombatSilverDone( nextStateName : name )
	{
		if ( nextStateName != 'AimThrow' && nextStateName != 'CombatSteel' && nextStateName != 'CombatFists' )
			parent.SetBehaviorVariable( 'playerCombatStance', (float)( (int)PCS_Normal ) );
	}

	
	private latent function CombatSilverLoop()
	{
		while( true )
		{
			Sleep( 0.5 );
		}
		
	}
	
	
	
	
	public final function HACK_ExternalCombatComboUpdate( timeDelta : float )
	{
		InteralCombatComboUpdate( timeDelta );
	}		
}