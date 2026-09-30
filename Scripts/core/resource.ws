/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import function LoadResource( resource : string, optional isDepotPath : bool ) : CResource;


import latent function LoadResourceAsync( resource : string, optional isDepotPath : bool ) : CResource;




import class CResource extends CObject
{
	import final function GetPath() : string;
}

import class CGameResource extends CResource
{
	import final function GetDefaultCameraTemplate() : CEntityTemplate;
}

import class CCommonGameResource extends CGameResource
{

}