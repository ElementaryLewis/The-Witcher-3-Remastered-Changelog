/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state CombatSteel in W3PlayerWitcher extends CombatSword
{
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
	
		this.CombatSteelInit( prevStateName );
	}
	
	
	event OnLeaveState( nextStateName : name )
	{ 
		
		this.CombatSteelDone( nextStateName );
		
		
		super.OnLeaveState(nextStateName);
	}
	
	public function GetSwordType() : name
	{ 
		return 'steelsword';
	}
	
	entry function CombatSteelInit( prevStateName : name )
	{		
		parent.OnEquipMeleeWeapon( PW_Steel, true );
		parent.SetBIsCombatActionAllowed( true );
		
		
		BuildComboPlayer();
		
		super.ProcessStartupAction( startupAction );
		
		CombatSteelLoop();
	}
	
	
	entry function CombatSteelDone( nextStateName : name )
	{
		if ( nextStateName != 'AimThrow' && nextStateName != 'CombatSilver' && nextStateName != 'CombatFists' )
			parent.SetBehaviorVariable( 'playerCombatStance', (float)( (int)PCS_Normal ) );
	}
	
	
	private latent function CombatSteelLoop()
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






state CombatSteel in W3ReplacerCiri extends CombatSword
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
	
		this.CombatSteelInit( prevStateName );
	}
	
	
	event OnLeaveState( nextStateName : name )
	{ 
		
		this.CombatSteelDone( nextStateName );
		
		
		super.OnLeaveState(nextStateName);
	}
	
	
	entry function CombatSteelInit( prevStateName : name )
	{		
		parent.OnEquipMeleeWeapon( PW_Steel, false );
		
		parent.SetBIsCombatActionAllowed( true );
		
		parent.SetBehaviorVariable( 'test_ciri_replacer', 1.0f);
		
		parent.LockEntryFunction( false );
		
		
		BuildComboPlayer();
		
		super.ProcessStartupAction( startupAction );
		
		CombatSteelLoop();
	}
	
	
	entry function CombatSteelDone( nextStateName : name )
	{
		if ( nextStateName != 'AimThrow' && nextStateName != 'CombatSilver' && nextStateName != 'CombatFists' )
			parent.SetBehaviorVariable( 'playerCombatStance', (float)( (int)PCS_Normal ) );
	}
	
	
	private latent function CombatSteelLoop()
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
