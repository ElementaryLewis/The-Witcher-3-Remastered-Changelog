/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import state Base in CPlayer 
{
	
	import final function CreateNoSaveLock();
	
	function CanAccesFastTravel( target : W3FastTravelEntity ) : bool
	{
		return true;
	}
}