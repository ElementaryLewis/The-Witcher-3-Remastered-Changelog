/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import abstract class IActorLatentAction extends IAIParameters
{
	function ConvertToActionTree( parentObj : IScriptable ) : IAIActionTree
	{
		return NULL;
	}
}

import abstract class IPresetActorLatentAction extends IActorLatentAction
{
	import var resName : string;
}
