/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CVFXPlayerOnTrigger extends CGameplayEntity
{
	editable var fxOnEnter : name;
	
	default fxOnEnter = 'None';
	

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var actor : CActor;
		
		actor = (CR4Player) activator.GetEntity();
		
		if( actor && fxOnEnter != 'None')
		{
			PlayEffect( fxOnEnter );
			return true;
		}
		
		return false;
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var actor : CActor;
		
		actor = (CR4Player) activator.GetEntity();
		
		if( actor && fxOnEnter != 'None')
		{
			StopEffect( fxOnEnter );
			return true;
		}
		
		return false;
	}
}