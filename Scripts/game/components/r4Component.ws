/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4Component extends CScriptedComponent
{
	
	public function IgniHit()
	{
		OnIgniHit();
	}
	public function AardHit ()
	{
		OnAardHit();
	}
	
	event OnIgniHit()
	{
		
	}
	
	event OnAardHit()
	{
		
	}
}