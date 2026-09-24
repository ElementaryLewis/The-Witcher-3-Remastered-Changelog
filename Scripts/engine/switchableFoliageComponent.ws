/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CSwitchableFoliageComponent extends CComponent
{
	private var currEntryName : name;

	public function SetAndSaveEntry( entryName : name )
	{
		currEntryName = entryName;
		SetEntry( currEntryName );
	}
	
	public function GetEntry() : name
	{
		return currEntryName;
	}

	
	import private final function SetEntry( entryName : name );
}