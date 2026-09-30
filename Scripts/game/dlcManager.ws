/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CDLCManager extends CObject
{
	import final function GetDLCs(names : array<name>) : void;
	import final function EnableDLC(id : name, isEnabled : bool) : void;
	import final function IsDLCEnabled(id : name) : bool;
	import final function IsDLCAvailable(id : name) : bool;
	import final function GetDLCName(id : name) : string;
	import final function GetDLCDescription(id : name) : string;
	import final function SimulateDLCsAvailable(shouldSimulate : bool) : void;
	
	public function IsNewGamePlusAvailable():bool
	{
		return IsDLCAvailable('dlc_009_001') && hasSaveDataToLoad();
	}
	
	public function IsEP1Available():bool
	{
		return IsDLCAvailable('ep1');
	}	
	
	public function IsEP1Enabled():bool
	{
		return IsDLCEnabled('ep1');
	}
	
	public function IsEP2Available():bool
	{
		return IsDLCAvailable('abob_001_001');
	}

	public function IsEP2Enabled():bool
	{
		return IsDLCEnabled('abob_001_001');
	}



	public function IsAnyDLCAvailable():bool
	{
		var dlcList : array<name>;
		var i:int;
		
		GetDLCs(dlcList);
		
		for (i = 0; i < dlcList.Size(); i += 1)
		{
			if (IsDLCAvailable(dlcList[i]))
			{
				return true;
			}
		}
		
		return false;
	}
}