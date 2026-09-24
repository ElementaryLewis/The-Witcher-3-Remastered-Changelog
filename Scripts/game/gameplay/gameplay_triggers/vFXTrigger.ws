/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CVFXTrigger extends CGameplayEntity
{
	editable var fxOnEnter : name;
	
	default fxOnEnter = 'none';
	

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var actor : CActor;
		
		actor = (CActor) activator.GetEntity();
		
		if( actor )
		{
			actor.PlayEffect( fxOnEnter );
			
			return true;
		}
		
		return false;
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var actor : CActor;
		
		actor = (CActor) activator.GetEntity();
		
		if( actor )
		{
			actor.StopEffect( fxOnEnter );
			
			return true;
		}
		
		return false;
	}
}