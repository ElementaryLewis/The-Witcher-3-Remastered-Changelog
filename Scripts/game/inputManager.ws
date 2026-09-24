/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EInputDeviceType
{
	IDT_Xbox1 = 0,
	IDT_PS4 = 1,
	IDT_Steam = 2,
	IDT_KeyboardMouse = 3,
	IDT_Tablet = 4,
	IDT_Unknown = 5,
	IDT_PS5 = 6,
}

import class CInputManager
{
	import final function GetLastActivationTime( actionName : name ) : float; 	
	import final function GetActionValue( actionName : name ) : float; 			
	import final function GetAction( actionName : name ) : SInputAction;

	import final function ClearIgnoredInput();									
	
	import final function IsInputIgnored( actionName : name ) : bool;			
		
	
	import final function RegisterListener( listener : IScriptable, eventName : name, actionName : name );
	import final function UnregisterListener( listener : IScriptable, actionName : name );
	
	import final function SetContext( contextName : name );						
	import final function GetContext() : name;									
	
	
	
	import final function StoreContext( newContext : name );
	
	
	
	import final function RestoreContext( storedContext : name, contextCouldChange : bool );
	
	import final function EnableLog( val : bool );
	
	import final function LastUsedPCInput() : bool;
	import final function LastUsedGamepad() : bool;
	
	import final function GetLastUsedDeviceName() : name;
	public final function GetLastUsedGamepadType() : EInputDeviceType
	{
		var deviceName:name = GetLastUsedDeviceName();				
		
		switch (deviceName)
		{
			case 'xpad':
				return IDT_Xbox1;
				break;
			case 'ps4pad':
				return IDT_PS4;
				break;
			case 'ps5pad':
				return IDT_PS5;
				break;
			case 'steampad':
				return IDT_Steam;
				break;
			case 'keyboardmouse':
				return IDT_KeyboardMouse;
				break;
			case 'tablet':
				return IDT_Tablet;
				break;
			default:
				return IDT_Unknown;
				break;
		}
		
		return IDT_Unknown;
	}
	
	import final function UsesPlaystationPad() : bool;	
	public final function UsesPlaystationPadScript() : bool
	{
		return UsesPlaystationPad() || FactsQuerySum("dbg_force_ps_pad") > 0;
	}
	
	import final function ForceDeactivateAction( actionName : name );
	
	
	
	import final function GetPCKeysForAction( actionName : name, out outKeys : array< EInputKey > );
	
	
	import final function GetPadKeysForAction( actionName : name, out outKeys : array< EInputKey > );
	
	
	import final function GetCurrentKeysForAction( actionName : name, out outKeys : array< EInputKey > );
	
	
	
	import final function GetPCKeysForActionStr( actionName : string, out outKeys : array< EInputKey > );
	
	
	import final function GetPadKeysForActionStr( actionName : string, out outKeys : array< EInputKey > );
	
	
	import final function GetCurrentKeysForActionStr( actionName : string, out outKeys : array< EInputKey > );
	
	import final function SuppressPropagatingEventAfterAction( actionName : name );
	
	function IsActionPressed( actionName : name ) : bool
	{
		var action : SInputAction = GetAction( actionName );
		
		return IsPressed( action, true );
	}

	function IsActionReleased( actionName : name ) : bool
	{
		var action : SInputAction = GetAction( actionName );
		
		return IsReleased( action, true );
	}
	
	function IsActionJustPressed( actionName : name ) : bool
	{
		var action : SInputAction = GetAction( actionName );
		
		return IsPressed( action );
	}

	function IsActionJustReleased( actionName : name ) : bool
	{
		var action : SInputAction = GetAction( actionName );
		
		return IsReleased( action );
	}
	
	
	event OnInputDeviceChanged()
	{
		var guiManager       : CR4GuiManager;
		var hud              : CR4ScriptedHud;
		var overlayPopupRef  : CR4OverlayPopup;
		var tutorialPopupRef : CR4TutorialPopup;
		var glossaryTutorial : CR4GlossaryTutorialsMenu;
		var tutorialSystem   : CR4TutorialSystem;
		var commonMenuRef    : CR4CommonMenu;		
		
		guiManager = theGame.GetGuiManager();
		
		if (guiManager.GetLockedControlScheme() == LCS_None)
		{			
			
			tutorialSystem = theGame.GetTutorialSystem();
			if(tutorialSystem && tutorialSystem.IsRunning())
			{
				tutorialSystem.OnInputDeviceChanged();
			}
			
			tutorialPopupRef = (CR4TutorialPopup) guiManager.GetPopup('TutorialPopup');
			if (tutorialPopupRef)
			{
				tutorialPopupRef.UpdateInputDevice();
			}
			
			overlayPopupRef = (CR4OverlayPopup) guiManager.GetPopup('OverlayPopup');
			if (overlayPopupRef)
			{
				overlayPopupRef.UpdateInputDevice();
			}
			
			hud = (CR4ScriptedHud)theGame.GetHud();
			if(hud)
			{
				hud.UpdateInputDevice();
			}
			
			commonMenuRef = guiManager.GetCommonMenu();
			if (commonMenuRef)
			{
				commonMenuRef.UpdateInputDevice();
				
				glossaryTutorial = (CR4GlossaryTutorialsMenu)commonMenuRef.GetSubMenu();
				if (glossaryTutorial)
				{
					
				}
			}
			
		}
	}
	
	import final function SetInvertCamera( invert : bool );
	
	
	function IsAttackWithAlternateBound() : bool
	{
		var outKeys : array<EInputKey>;
		if ( LastUsedGamepad() )
		{
			return false;
		}
		else if ( LastUsedPCInput() )
		{
			GetPCKeysForAction('PCAlternate',outKeys);
			if ( outKeys.Size() > 0 )
				return true;
		}
		return false;
	}
	
	function IsToggleSprintBound() : bool
	{
		var outKeys : array<EInputKey>;
		if ( LastUsedGamepad() )
		{
			return false;
		}
		else if ( LastUsedPCInput() )
		{
			GetPCKeysForAction('SprintToggle',outKeys);
			if ( outKeys.Size() > 0 )
				return true;
		}
		return false;
	}
}

import struct SInputAction
{
	import const var aName : name;
	import const var value : float;
	import const var lastFrameValue : float;
}

function IsPressed( action : SInputAction, optional justValue : bool ) : bool
{
	return action.value > 0.7f && ( justValue || action.lastFrameValue <= 0.7f );
}

function IsReleased( action : SInputAction, optional justValue : bool ) : bool
{
	return action.value < 0.7f && ( justValue || action.lastFrameValue >= 0.7f );
}
