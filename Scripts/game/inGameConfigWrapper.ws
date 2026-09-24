/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CInGameConfigWrapper
{
	
	import final function GetGroupDisplayName( groupName : name ) : string;
	import final function GetGroupPresetsNum( groupName : name ) : int;
	import final function GetGroupPresetDisplayName( groupName : name, presetIdx : int ) : string;
	import final function ApplyGroupPreset( groupName : name, presetIdx : int );
	import final function ResetGroupToDefaults( groupName : name );
	
	
	import final function GetVarDisplayType( groupName : name, varName : name ) : string;
	import final function GetVarDisplayName( groupName : name, varName : name ) : string;
	import final function GetVarOptionsNum( groupName : name, varName : name ) : int;
	import final function GetVarOption( groupName : name, varName : name, optionIdx : int ) : string;
	import final function GetVarValue( groupCName : name, varCName : name ) : string;
	import final function GetVarValueByStr( groupNameStr : string, varCName : name ) : string;
	import final function SetVarValue( groupName : name, varName : name, varValue : string );
	import final function SetVarValueByStr( groupNameStr : string, varName : name, varValue : string );
	import final function GetVarNameByGroupName( groupName : name, varIdx : int ) : name;
	import final function GetVarsNumByGroupName( groupName : name ) : int;
	import final function IsVarVisible( groupName : name, varName : name ) : bool;
	import final function DoVarHasTag( groupName : name, varName : name, tag : name ) : bool;
	
	
	import final function GetGroupsNum() : int;
	import final function GetGroupName( groupIdx : int ) : name;
	import final function GetGroupIdx( groupName : string ) : int;
	import final function GetVarsNum( groupIdx : int ) : int;
	import final function GetVarName( groupIdx : int, varIdx : int ) : name;
	import final function IsGroupVisible( groupName : name ) : bool;
	import final function DoGroupHasTag( groupName : name, tag : name ) : bool;
	
	
	import final function IsTagActive( tag : name ) : bool;
	import final function ActivateScriptTag( tag : name );
	import final function DeactivateScriptTag( tag : name );
	
	
	import final function WriteIniFile(iniFileName : string, key : string, newValue : string);
	
	
	import final function GetEntriesNumForOption( groupName : name, varName : name, optionId : int ) : int;
	import final function GetEntryNameForOption( groupName : name, varName : name, optionId : int, entryId : int ) : name;
	import final function GetCurrentOptionId( groupName : name, varName : name ) : int;
}

	function GetVarsNumForGroupDisplayName( displayName : string ) : int
	{
		var totalGroups : int;
		var groupIdx : int;
		var groupName : name;
		var result : int;
		var inGameConfigWrapper	: CInGameConfigWrapper;
		
		inGameConfigWrapper = (CInGameConfigWrapper) theGame.GetInGameConfigWrapper();	
		result = 0;
		totalGroups = inGameConfigWrapper.GetGroupsNum();
		
		for ( groupIdx = 0; groupIdx < totalGroups; groupIdx += 1 )
		{
			groupName = inGameConfigWrapper.GetGroupName( groupIdx );
			
			if( inGameConfigWrapper.GetGroupDisplayName( groupName ) == displayName )
			{
				result += inGameConfigWrapper.GetVarsNum( groupIdx );
			}
		}
		
		return result;
	}

function GetCurrentTextLocCode() : string
{
	var ingameConfigWrapper : CInGameConfigWrapper;
	var selectedIndex : int;
	
	ingameConfigWrapper = theGame.GetInGameConfigWrapper();
	selectedIndex = StringToInt(ingameConfigWrapper.GetVarValue('Localization', 'Virtual_Localization_text'), 0);
	
	return ingameConfigWrapper.GetVarOption('Localization', 'Virtual_Localization_text', selectedIndex);
}

struct SInGameConfigBufferedEntry
{
	var groupName : name;
	var varName : name;
	var varValue : string;
	var startValue : string;
}

class CInGameConfigBufferedWrapper
{
	public var inGameConfig : CInGameConfigWrapper;
	public var buffer : array<SInGameConfigBufferedEntry>;
	
	public function FillAppendWithGroup( groupName : name ) : void
	{
		var varsNum : int;
		var counter : int;
		var varValue : string;
		var bufferEntry : SInGameConfigBufferedEntry;
		var found : bool;
		var i : int;
		
		varsNum = inGameConfig.GetVarsNumByGroupName( groupName );
		
		bufferEntry.groupName = groupName;
		
		for( counter=0; counter<varsNum; counter+=1 )
		{
			bufferEntry.varName = inGameConfig.GetVarNameByGroupName( groupName, counter );
			found = false;
			
			
			for( i=0; i<buffer.Size(); i+=1 )
			{
				if( buffer[i].groupName == bufferEntry.groupName && buffer[i].varName == bufferEntry.varName )
				{
					found = true;
					break;
				}
			}
			
			
			if( found == false )
			{
				bufferEntry.varValue = inGameConfig.GetVarValue( groupName, bufferEntry.varName );
			
				buffer.PushBack( bufferEntry );
			}
		}
	}
	
	
	public function GetVarValue( groupName : name, varName : name ) : string
	{
		var i : int;
		
		
		for( i=0; i<buffer.Size(); i+=1 )
		{
			if( buffer[i].groupName == groupName && buffer[i].varName == varName )
			{
				return buffer[i].varValue;
			}
		}
		
		
		return inGameConfig.GetVarValue( groupName, varName );
	}
	
	
	public function SetVarValue( groupName : name, varName : name, varValue : string ) : void
	{
		var i : int;
		var bufferEntry : SInGameConfigBufferedEntry;
		var found : bool;
		
		found = false;
		
		for( i=0; i<buffer.Size(); i+=1 )
		{
			if( buffer[i].groupName == groupName && buffer[i].varName == varName )
			{
				buffer[i].varValue = varValue;
				found = true;
				break;
			}
		}
		
		
		if( found == false )
		{
			bufferEntry.groupName = groupName;
			bufferEntry.varName = varName;
			bufferEntry.varValue = varValue;
			bufferEntry.startValue = inGameConfig.GetVarValue( groupName, varName );
			buffer.PushBack( bufferEntry );
		}
	}
	
	public function AnyBufferedVarHasTag(tag:name):bool
	{
		var i : int;
		
		
		for( i=0; i<buffer.Size(); i+=1 )
		{
			
			if (inGameConfig.DoVarHasTag( buffer[i].groupName, buffer[i].varName, tag ) && buffer[i].startValue != buffer[i].varValue)
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function ApplyNewValues() : void
	{
		var i : int;
		
		
		for( i=0; i<buffer.Size(); i+=1 )
		{
			inGameConfig.SetVarValue( buffer[i].groupName, buffer[i].varName, buffer[i].varValue );
		}
	}
	
	
	public function FlushBuffer() : void
	{
		ApplyNewValues();
		
		buffer.Clear();
	}
	
	public function UndoAndFlushBuffer() : void
	{
		var i : int;
		
		
		for( i=0; i<buffer.Size(); i+=1 )
		{
			inGameConfig.SetVarValue( buffer[i].groupName, buffer[i].varName, buffer[i].startValue );
		}
		
		buffer.Clear();
	}
	
	
	public function IsEmpty() : bool
	{
		if( buffer.Size() > 0 )
		{
			return false;
		}
		
		return true;
	}
	
	
	public function ClearBuffer() : void
	{
		buffer.Clear();
	}
}
