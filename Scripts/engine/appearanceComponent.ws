/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CAppearanceComponent extends CComponent
{
	import final function IncludeAppearanceTemplate(template : CEntityTemplate); 
	import final function ExcludeAppearanceTemplate(template : CEntityTemplate); 
	
	
	import final function ApplyAppearance( appearanceName : string );
}



function GetAppearanceNames2( path : string, output : array< name> ) 
{
	var temp : CEntityTemplate;
	temp = (CEntityTemplate)LoadResource( path, true );
	return GetAppearanceNames( temp, output );	
}

import function GetAppearanceNames( template : CEntityTemplate, output : array< name> );