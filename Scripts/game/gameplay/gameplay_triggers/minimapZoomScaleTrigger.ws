/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3MinimapZoomScaleTrigger extends CGameplayEntity 
{
	private editable var zoomScale : float;
	default zoomScale = 1.0f;
	
	private var previousZoomScale : float;

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		
		
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		
		
	}
}