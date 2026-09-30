/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EScriptedEventCategory
{
	SEC_Empty,
	SEC_OnReusableClueUsed,		
	SEC_OnItemEquipped,			
	SEC_OnOilApplied,			
	SEC_OnAmmoChanged,			
	SEC_GameplayFact,			
	SEC_AlchemyRecipe,			
	SEC_CraftingSchematics,		
	SEC_OnMapPinChanged,		
	SEC_OnHudTimeOut,			
}

enum EScriptedEventType
{
	SET_Unknown,	
}

class IGlobalEventScriptedListener
{
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name ) {}
	event OnGlobalEventString( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : string ) {}
}

function GetGlobalEventCategory( scriptedCategory : EScriptedEventCategory ) : EGlobalEventCategory
{
	if ( scriptedCategory == SEC_OnReusableClueUsed ) 	return GEC_ScriptsCustom0;
	if ( scriptedCategory == SEC_OnItemEquipped ) 		return GEC_ScriptsCustom1;
	if ( scriptedCategory == SEC_OnOilApplied ) 		return GEC_ScriptsCustom2;
	if ( scriptedCategory == SEC_OnAmmoChanged ) 		return GEC_ScriptsCustom3;
	if ( scriptedCategory == SEC_GameplayFact ) 		return GEC_ScriptsCustom4;
	if ( scriptedCategory == SEC_AlchemyRecipe ) 		return GEC_ScriptsCustom5;
	if ( scriptedCategory == SEC_CraftingSchematics ) 	return GEC_ScriptsCustom6;
	if ( scriptedCategory == SEC_OnMapPinChanged ) 		return GEC_ScriptsCustom7;
	if ( scriptedCategory == SEC_OnHudTimeOut ) 		return GEC_ScriptsCustom8;
	return GEC_Empty;
}

function GetScriptedEventCategory( globalCategory : EGlobalEventCategory ) : EScriptedEventCategory
{
	if ( globalCategory == GEC_ScriptsCustom0 ) return SEC_OnReusableClueUsed;
	if ( globalCategory == GEC_ScriptsCustom1 ) return SEC_OnItemEquipped;
	if ( globalCategory == GEC_ScriptsCustom2 ) return SEC_OnOilApplied;
	if ( globalCategory == GEC_ScriptsCustom3 ) return SEC_OnAmmoChanged;
	if ( globalCategory == GEC_ScriptsCustom4 ) return SEC_GameplayFact;
	if ( globalCategory == GEC_ScriptsCustom5 ) return SEC_AlchemyRecipe;
	if ( globalCategory == GEC_ScriptsCustom6 ) return SEC_CraftingSchematics;
	if ( globalCategory == GEC_ScriptsCustom7 ) return SEC_OnMapPinChanged;
	if ( globalCategory == GEC_ScriptsCustom8 ) return SEC_OnHudTimeOut;
	return SEC_Empty;
}

function GetGlobalEventType( scriptedType : EScriptedEventType ) : EGlobalEventType
{
	return GET_Unknown;
}

function GetScriptedEventType( globalType : EGlobalEventType ) : EScriptedEventType
{
	return SET_Unknown;
}

import class CR4GlobalEventsScriptsDispatcher
{
	import final function RegisterForCategoryFilterName( eventCategory : EGlobalEventCategory, filter : name ) : bool;
	import final function RegisterForCategoryFilterNameArray( eventCategory : EGlobalEventCategory, filter : array< name > ) : bool;
	import final function RegisterForCategoryFilterString( eventCategory : EGlobalEventCategory, filter : string ) : bool;
	import final function RegisterForCategoryFilterStringArray( eventCategory : EGlobalEventCategory, filter : array< string > ) : bool;
	
	import final function UnregisterFromCategoryFilterName( eventCategory : EGlobalEventCategory, filter : name ) : bool;
	import final function UnregisterFromCategoryFilterNameArray( eventCategory : EGlobalEventCategory, filter : array< name > ) : bool;
	import final function UnregisterFromCategoryFilterString( eventCategory : EGlobalEventCategory, filter : string ) : bool;
	import final function UnregisterFromCategoryFilterStringArray( eventCategory : EGlobalEventCategory, filter : array< string > ) : bool;

	import final function AddFilterNameForCategory( eventCategory : EGlobalEventCategory, filter : name ) : bool;	
	import final function AddFilterNameArrayForCategory( eventCategory : EGlobalEventCategory, filter : array< name > ) : bool;	
	import final function AddFilterStringForCategory( eventCategory : EGlobalEventCategory, filter : string ) : bool;	
	import final function AddFilterStringArrayForCategory( eventCategory : EGlobalEventCategory, filter : array< string > ) : bool;	

	import final function RemoveFilterNameFromCategory( eventCategory : EGlobalEventCategory, filter : name ) : bool;	
	import final function RemoveFilterNameArrayFromCategory( eventCategory : EGlobalEventCategory, filter : array< name > ) : bool;	
	import final function RemoveFilterStringFromCategory( eventCategory : EGlobalEventCategory, filter : string ) : bool;	
	import final function RemoveFilterStringArrayFromCategory( eventCategory : EGlobalEventCategory, filter : array< string > ) : bool;	

	var listenersByCategory 	: array< array< IGlobalEventScriptedListener > >;

	
	event OnScriptedEvent( scriptedEventCategory : EScriptedEventCategory, optional scriptedEventType : EScriptedEventType, optional eventParam : name )
	{
		OnGlobalEventName( GetGlobalEventCategory( scriptedEventCategory ), GetGlobalEventType( scriptedEventType ), eventParam );
	}

	event OnScriptedEventName( scriptedEventCategory : EScriptedEventCategory, optional scriptedEventType : EScriptedEventType, optional eventParam : name )
	{
		OnGlobalEventName( GetGlobalEventCategory( scriptedEventCategory ), GetGlobalEventType( scriptedEventType ), eventParam );
	}

	event OnScriptedEventString( scriptedEventCategory : EScriptedEventCategory, optional scriptedEventType : EScriptedEventType, optional eventParam : string )
	{
		OnGlobalEventString( GetGlobalEventCategory( scriptedEventCategory ), GetGlobalEventType( scriptedEventType ), eventParam );
	}

	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		var index : int;
		var i, size : int;
				
		if ( listenersByCategory.Size() == 0 )
		{
			return false;
		}
		
		index = (int)eventCategory;
		
		if ( index > 0 && index < listenersByCategory.Size() )
		{
			size = listenersByCategory[ index ].Size();
			if ( size == 0 )
			{
				return false;
			}
			for ( i = 0; i < size; i+=1 )
			{
				listenersByCategory[index][i].OnGlobalEventName( eventCategory, eventType, eventParam );
			}
		}	
		return true;
	}	
	
	
	event OnGlobalEventString( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : string )
	{
		var index : int;
		var i, size : int;
				
		if ( listenersByCategory.Size() == 0 )
		{
			return false;
		}
		
		index = (int)eventCategory;
		
		if ( index > 0 && index < listenersByCategory.Size() )
		{
			size = listenersByCategory[ index ].Size();
			if ( size == 0 )
			{
				return false;
			}
			for ( i = 0; i < size; i+=1 )
			{
				listenersByCategory[index][i].OnGlobalEventString( eventCategory, eventType, eventParam );
			}
		}
		return true;
	}
	
	function Init()
	{
		listenersByCategory.Resize( (int)GEC_Last );
	}
	
	function IsCustomScriptsCategory( eventCategory : EGlobalEventCategory ) : bool
	{
		return eventCategory >= GEC_ScriptsCustom0;
	}
		
	public function AddListener( eventCategory : EGlobalEventCategory, listener : IGlobalEventScriptedListener ) : bool
	{
		var index : int;
		
		if ( listenersByCategory.Size() == 0 )
		{
			Init();
		}
		index = (int)eventCategory;
		
		if ( index > 0 && index < listenersByCategory.Size() )
		{
			
			if ( listenersByCategory[ index ].FindFirst( listener ) == -1 )
			{
				listenersByCategory[ index ].PushBack( listener );
				return true;
			}
		}
		return false;
	}
	
	public function AddListenerFilterName( eventCategory : EGlobalEventCategory, listener : IGlobalEventScriptedListener, filter : name ) : bool
	{
		var index : int;
		if ( AddListener( eventCategory, listener ) )
		{
			if ( !IsCustomScriptsCategory( eventCategory ) )
			{
				index = (int)eventCategory;
				
				if ( listenersByCategory[ index ].Size() == 1 )
				{
					RegisterForCategoryFilterName( eventCategory, filter );
				}
				else
				{
					AddFilterNameForCategory( eventCategory, filter );
				}
			}
			return true;
		}
		return false;
	}

	public function AddListenerFilterNameArray( eventCategory : EGlobalEventCategory, listener : IGlobalEventScriptedListener, filter : array< name > ) : bool
	{
		var index : int;
		if ( AddListener( eventCategory, listener ) )
		{
			if ( !IsCustomScriptsCategory( eventCategory ) )
			{
				index = (int)eventCategory;
				
				if ( listenersByCategory[ index ].Size() == 1 )
				{
					RegisterForCategoryFilterNameArray( eventCategory, filter );
				}
				else
				{
					AddFilterNameArrayForCategory( eventCategory, filter );
				}
			}
			return true;
		}
		return false;
	}

	public function AddListenerFilterString( eventCategory : EGlobalEventCategory, listener : IGlobalEventScriptedListener, filter : string ) : bool
	{
		var index : int;
		if ( AddListener( eventCategory, listener ) )
		{
			if ( !IsCustomScriptsCategory( eventCategory ) )
			{
				index = (int)eventCategory;
				
				if ( listenersByCategory[ index ].Size() == 1 )
				{
					RegisterForCategoryFilterString( eventCategory, filter );
				}
				else
				{
					AddFilterStringForCategory( eventCategory, filter );
				}
			}
			return true;
		}
		return false;
	}

	public function AddListenerFilterStringArray( eventCategory : EGlobalEventCategory, listener : IGlobalEventScriptedListener, filter : array< string > ) : bool
	{
		var index : int;
		if ( AddListener( eventCategory, listener ) )
		{
			if ( !IsCustomScriptsCategory( eventCategory ) )
			{
				index = (int)eventCategory;
				
				if ( listenersByCategory[ index ].Size() == 1 )
				{
					RegisterForCategoryFilterStringArray( eventCategory, filter );
				}
				else
				{
					AddFilterStringArrayForCategory( eventCategory, filter );
				}
			}
			return true;
		}
		return false;
	}

	public function RemoveListener( eventCategory : EGlobalEventCategory, listener : IGlobalEventScriptedListener ) : bool
	{
		var index : int;
		
		if ( listenersByCategory.Size() == 0 )
		{
			return false;
		}
		index = (int)eventCategory;
		
		if ( index > 0 && index < listenersByCategory.Size() )
		{
			
			if ( listenersByCategory[ index ].Remove( listener ) )
			{
				return true;
			}
		}
		return false;
	}	
	
	public function RemoveListenerFilterName( eventCategory : EGlobalEventCategory, listener : IGlobalEventScriptedListener, filter : name ) : bool
	{
		var index : int;
		if ( RemoveListener( eventCategory, listener ) )
		{
			if ( !IsCustomScriptsCategory( eventCategory ) )
			{
				index = (int)eventCategory;
				
				if ( listenersByCategory[ index ].Size() == 0 )
				{
					UnregisterFromCategoryFilterName( eventCategory, filter );
				}
				else
				{
					RemoveFilterNameFromCategory( eventCategory, filter );
				}
			}
			return true;
		}
		return false;
	}

	public function RemoveListenerFilterNameArray( eventCategory : EGlobalEventCategory, listener : IGlobalEventScriptedListener, filter : array< name > ) : bool
	{
		var index : int;
		if ( RemoveListener( eventCategory, listener ) )
		{
			if ( !IsCustomScriptsCategory( eventCategory ) )
			{
				index = (int)eventCategory;
				
				if ( listenersByCategory[ index ].Size() == 0 )
				{
					UnregisterFromCategoryFilterNameArray( eventCategory, filter );
				}
				else
				{
					RemoveFilterNameArrayFromCategory( eventCategory, filter );
				}
			}
			return true;
		}
		return false;
	}

	public function RemoveListenerFilterString( eventCategory : EGlobalEventCategory, listener : IGlobalEventScriptedListener, filter : string ) : bool
	{
		var index : int;
		if ( RemoveListener( eventCategory, listener ) )
		{
			if ( !IsCustomScriptsCategory( eventCategory ) )
			{
				index = (int)eventCategory;
				
				if ( listenersByCategory[ index ].Size() == 0 )
				{
					UnregisterFromCategoryFilterString( eventCategory, filter );
				}
				else
				{
					RemoveFilterStringFromCategory( eventCategory, filter );
				}
			}
			return true;
		}
		return false;
	}

	public function RemoveListenerFilterStringArray( eventCategory : EGlobalEventCategory, listener : IGlobalEventScriptedListener, filter : array< string > ) : bool
	{
		var index : int;
		if ( RemoveListener( eventCategory, listener ) )
		{
			if ( !IsCustomScriptsCategory( eventCategory ) )
			{
				index = (int)eventCategory;
				
				if ( listenersByCategory[ index ].Size() == 0 )
				{
					UnregisterFromCategoryFilterStringArray( eventCategory, filter );
				}
				else
				{
					RemoveFilterStringArrayFromCategory( eventCategory, filter );
				}
			}
			return true;
		}
		return false;
	}
}