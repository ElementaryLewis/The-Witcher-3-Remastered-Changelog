/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class W3WitchesCage extends CEntity
{
	default autoState = 'TurnedOff';
}

state TurnedOff in W3WitchesCage
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.ApplyAppearance("roots_off");
	}
}

state TurnedOn in W3WitchesCage
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.ApplyAppearance("roots_on");
	}
}