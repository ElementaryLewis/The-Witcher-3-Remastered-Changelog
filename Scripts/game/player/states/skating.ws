/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
function LogSkating(str : string)									
{
	LogChannel('Skate', str);
}



state Skating in CR4Player extends ExtendedMovable
{
	
	event OnEnterState( prevStateName : name )
	{
		theInput.SetContext( 'Skating' );
		
		parent.SetBIsCombatActionAllowed(false);
		
		
		
		SkatingInit();
		
		LogSkating("on enter skating");
	} 
	
	
	event OnLeaveState( nextStateName : name )
	{
		super.OnLeaveState( nextStateName );
		
		parent.SetBIsCombatActionAllowed(true);
		
		LogSkating("on leave skating");
	}
	
	
	entry function SkatingInit()
	{
		var behGraphNames : array< name >;		
		
		
		parent.LockEntryFunction( true );
		
		
		
		parent.BlockAllActions('InitSkating', true, , true);
		
		behGraphNames.PushBack( 'Skating' );
		
		parent.ActivateAndSyncBehaviors( behGraphNames );
		
		parent.BlockAllActions('InitSkating', false);
		
		
		parent.SetBehaviorVariable( 'playerWeapon', (int)PW_Steel );
		parent.SetBehaviorVariable( 'playerWeaponForOverlay', (int)PW_Steel );
		parent.SetBehaviorVariable( 'SelectedWeapon', 0);
		parent.SetBehaviorVariable( 'WeaponType', 0);
		parent.SetRequiredItems( 'None', 'steelsword' );
		
		parent.ProcessRequiredItems();
		
		
		
		parent.SetOrientationTarget( OT_Player );
		parent.ClearCustomOrientationInfoStack();
		
		
		parent.SetBIsInputAllowed(true, 'SkatingInit');
		
		parent.WaitForBehaviorNodeDeactivation( 'StateChangeComplete', 0.1f ); 
		
		parent.LockEntryFunction( false );
	}
}