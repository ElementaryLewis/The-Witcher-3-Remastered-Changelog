/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import state Base in CNewNPC
{
	event OnEnterState( prevStateName : name )
	{	
		parent.ActionCancelAll();
	}
};


import state ReactingBase in CNewNPC extends Base
{	
};