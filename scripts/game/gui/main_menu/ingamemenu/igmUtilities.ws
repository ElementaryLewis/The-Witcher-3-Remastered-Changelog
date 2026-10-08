/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
function IngameMenu_UpdateDLCScriptTags()
{
	var inGameConfigWrapper : CInGameConfigWrapper;
	
	
}

function IngameMenu_PopulateSaveDataForSlotType(flashStorageUtility : CScriptedFlashValueStorage, saveType:int, parentObject:CScriptedFlashArray, allowEmptySlot:bool):void
{
	var currentData		: CScriptedFlashObject;
	var numSaveSlots	: int;
	var saveDisplayName : string;
	var currentSave		: SSavegameInfo;
	var i				: int;
	var saveGames		: array< SSavegameInfo >;
	var numSavesAdded	: int;
	var isModdedSave	: bool;
	
	
	theGame.ListSavedGames( saveGames, saveType );
	if (saveType == -1)
	{
		numSaveSlots = 0;
	}
	else
	{	
		numSaveSlots = theGame.GetNumSaveSlots(saveType);
	}
	
	numSavesAdded = 0;
	
	for (i = 0; i < saveGames.Size(); i += 1)
	{
		currentSave = saveGames[i];
		
		saveDisplayName = theGame.GetDisplayNameForSavedGame(currentSave);
		
		if (saveType == currentSave.slotType || saveType == -1)
		{
			numSavesAdded += 1;
		}
	}
	
	if (allowEmptySlot && (numSaveSlots == -1 || numSavesAdded < numSaveSlots) )
	{
		currentData = flashStorageUtility.CreateTempFlashObject();	
		currentData.SetMemberFlashString("id", "EMPTY");
		currentData.SetMemberFlashString("label", GetPlatformLocString("Empty_Save_Slot"));
		currentData.SetMemberFlashString("filename", "");
		currentData.SetMemberFlashInt("tag", -1);
		currentData.SetMemberFlashUInt("saveType", saveType);
		if(theGame.IsGalaxyUserSignedIn() && theGame.GetInGameConfigWrapper().GetVarValue( 'Gameplay', 'CrossProgression')) {
			currentData.SetMemberFlashUInt("cloudStatus", SCO_Uploading);
		} else {
			currentData.SetMemberFlashUInt("cloudStatus", SCO_Local);
		}
		
		currentData.SetMemberFlashBool("modded", false);
		currentData.SetMemberFlashBool("trophiesDisabled", false);
		
		parentObject.PushBackFlashObject(currentData);
	}
	
	for (i = 0; i < saveGames.Size(); i += 1)
	{
		currentSave = saveGames[i];
		
		saveDisplayName = theGame.GetDisplayNameForSavedGame(currentSave);
		
		if (saveType == currentSave.slotType || saveType == -1)
		{
			currentData = flashStorageUtility.CreateTempFlashObject();
			
			currentData.SetMemberFlashString("id", saveDisplayName);
			currentData.SetMemberFlashString("label", saveDisplayName);
			currentData.SetMemberFlashString("filename", currentSave.filename);
			currentData.SetMemberFlashInt("tag", i);
			
			currentData.SetMemberFlashUInt("saveType", currentSave.slotType);
			currentData.SetMemberFlashUInt("cloudStatus", currentSave.comboStatus );
			
			isModdedSave = theGame.GetModHandlerSystem().IsModdedSave(currentSave);
			currentData.SetMemberFlashBool("modded", isModdedSave);
			currentData.SetMemberFlashBool("trophiesDisabled", theGame.GetPlatform() != Platform_PC && theGame.GetPlatform() != Platform_PC_GDK && isModdedSave);
			
			parentObject.PushBackFlashObject(currentData);
		}
	}
}

function IngameMenu_PopulateImportSaveData(flashStorageUtility : CScriptedFlashValueStorage, parentObject:CScriptedFlashArray):void
{
	var saveGames : array< SSavegameInfo >;
	var currentSave		: SSavegameInfo;
	var i				: int;
	var saveDisplayName : string;
	var currentData		: CScriptedFlashObject;
	var isModdedSave	: bool;
	
	theGame.ListW2SavedGames( saveGames );
	
	for (i = 0; i < saveGames.Size(); i += 1)
	{
		currentSave = saveGames[i];
	
		saveDisplayName = theGame.GetDisplayNameForSavedGame(currentSave);
	
		currentData = flashStorageUtility.CreateTempFlashObject();
	
		currentData.SetMemberFlashString("id", saveDisplayName);
		currentData.SetMemberFlashString("label", saveDisplayName);
		currentData.SetMemberFlashString("filename", currentSave.filename);
		currentData.SetMemberFlashInt("tag", i);
	
		currentData.SetMemberFlashUInt("saveType", currentSave.slotType);
		currentData.SetMemberFlashUInt("cloudStatus", currentSave.comboStatus );
	
		isModdedSave = theGame.GetModHandlerSystem().IsModdedSave(currentSave);
		currentData.SetMemberFlashBool("modded", isModdedSave);
		currentData.SetMemberFlashBool("trophiesDisabled", theGame.GetPlatform() != Platform_PC && theGame.GetPlatform() != Platform_PC_GDK && isModdedSave);
	
		parentObject.PushBackFlashObject(currentData);
	}
}

function InGameMenu_CreateControllerData(flashStorageUtility : CScriptedFlashValueStorage) : CScriptedFlashArray
{
	var dataFlashArray 	: CScriptedFlashArray;
	var currentData		: CScriptedFlashObject;
	
	var htmlNewline 			: string = "&#10;";
	var actionPress				: string;
	var actionHold				: string;
	var actionDoubleTap			: string;
	var txtPanelSelection   	: string;
	var txtGameMenu   			: string;
	var txtCameraControl		: string;
	var txtDPad					: string;
	var txtMovement				: string;
	var txtMountDismount		: string;
	var txtLeftJoyRightJoy		: string;
	
	
	var inGameConfigWrapper : CInGameConfigWrapper;
	var quickSignCasting, leftStickSprint : bool;
	
	inGameConfigWrapper = theGame.GetInGameConfigWrapper();
	leftStickSprint = (bool)inGameConfigWrapper.GetVarValue('Controls', 'LeftStickSprint');
	quickSignCasting = (bool)inGameConfigWrapper.GetVarValue('Gameplay', 'EnableAlternateSignCasting');
	
	actionPress = GetLocStringByKeyExt("ControlLayout_press") + " ";
	actionHold = GetLocStringByKeyExt("ControlLayout_hold") + " - ";
	actionDoubleTap = GetLocStringByKeyExt("ControlLayout_doubleTap") + " - ";
	txtCameraControl = GetLocStringByKeyExt("ControlLayout_ControlCamera") + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_LockTarget");
	if (theGame.GetPlatform() == Platform_PS5)
		txtDPad = GetPlatformLocString("ControlLayout_LeftSteelSword_ps5") 
		+ htmlNewline + GetPlatformLocString("ControlLayout_RightSilverSword_ps5") 
		+ htmlNewline + GetPlatformLocString("ControlLayout_UpPotions_ps5") 
		+ htmlNewline + GetPlatformLocString("ControlLayout_DownHideSword_ps5");
	else if(theGame.GetPlatform() == Platform_Switch2_Ounce)
		txtDPad = GetPlatformLocString("ControlLayout_LeftSteelSword_nx") 
		+ htmlNewline + GetPlatformLocString("ControlLayout_RightSilverSword_nx") 
		+ htmlNewline + GetPlatformLocString("ControlLayout_UpPotions_nx") 
		+ htmlNewline + GetPlatformLocString("ControlLayout_DownHideSword_nx");
	else
		txtDPad = GetPlatformLocString("ControlLayout_LeftSteelSword") 
		+ htmlNewline + GetPlatformLocString("ControlLayout_RightSilverSword") 
		+ htmlNewline + GetPlatformLocString("ControlLayout_UpPotions") 
		+ htmlNewline + GetPlatformLocString("ControlLayout_DownHideSword");
	txtMovement = GetLocStringByKeyExt("ControlLayout_Movement");
	txtMountDismount = GetLocStringByKeyExt("panel_button_common_dismount");

	if (theGame.GetPlatform() == Platform_PS4 )
	{
		txtPanelSelection = GetLocStringByKeyExt("PANEL_MENUSELECTOR_ps4");
		txtGameMenu = GetLocStringByKeyExt("ControlLayout_system_menu_ps4");
		txtLeftJoyRightJoy = GetLocStringByKeyExt("ControlLayout_pressLeftJoyRightJoy_ps5")+" "+GetLocStringByKeyExt("ControlLayout_PhotoMode");
	}
	else if(theGame.GetPlatform() == Platform_PS5)
	{
		
		if (!theGame.IsFinalBuild())
		{
			txtPanelSelection = GetLocStringByKeyExt("PANEL_MENUSELECTOR_ps4") + htmlNewline + actionHold + inGameMenu_TryLocalize("panel_video_value_ray_tracing");
		}
		else
		{
			txtPanelSelection = GetLocStringByKeyExt("PANEL_MENUSELECTOR_ps4");
		}
		txtGameMenu = GetLocStringByKeyExt("ControlLayout_system_menu_ps4");
		txtLeftJoyRightJoy = GetLocStringByKeyExt("ControlLayout_pressLeftJoyRightJoy_ps5")+" "+GetLocStringByKeyExt("ControlLayout_PhotoMode");
	}
	else if(theGame.GetPlatform() == Platform_Xbox1)
	{
		txtPanelSelection = GetLocStringByKeyExt("PANEL_MENUSELECTOR");
		txtGameMenu = GetLocStringByKeyExt("ControlLayout_system_menu");
		txtLeftJoyRightJoy = GetLocStringByKeyExt("ControlLayout_pressLeftJoyRightJoy")+" "+GetLocStringByKeyExt("ControlLayout_PhotoMode");
	}
	else if(theGame.GetPlatform() == Platform_Switch2_Ounce)
	{
		txtPanelSelection = GetLocStringByKeyExt("PANEL_MENUSELECTOR");
		
		
		if (theGame.IsRayTracingSupported() && !theGame.IsFinalBuild())
		{
			txtGameMenu = GetLocStringByKeyExt("ControlLayout_system_menu") + htmlNewline + actionHold + inGameMenu_TryLocalize("panel_video_value_ray_tracing");
		}
		else
		{
			txtGameMenu = GetLocStringByKeyExt("ControlLayout_system_menu");
		}
		txtLeftJoyRightJoy = GetLocStringByKeyExt("ControlLayout_pressLeftJoyRightJoy_switch2")+" - "+GetLocStringByKeyExt("ControlLayout_PhotoMode");
	}
	else
	{
		txtPanelSelection = GetLocStringByKeyExt("PANEL_MENUSELECTOR");
		
		
		if (theGame.IsRayTracingSupported() && !theGame.IsFinalBuild())
		{
			txtGameMenu = GetLocStringByKeyExt("ControlLayout_system_menu") + htmlNewline + actionHold + inGameMenu_TryLocalize("panel_video_value_ray_tracing");
		}
		else
		{
			txtGameMenu = GetLocStringByKeyExt("ControlLayout_system_menu");
		}
		txtLeftJoyRightJoy = GetLocStringByKeyExt("ControlLayout_pressLeftJoyRightJoy")+" "+GetLocStringByKeyExt("ControlLayout_PhotoMode");
	}
	
	dataFlashArray = flashStorageUtility.CreateTempFlashArray();
	

	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_ExplorationLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", GetLocStringByKeyExt("ControlLayout_ControlCamera") + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
	
	if(leftStickSprint)
	{
		
		if(quickSignCasting)
		{
			if (theGame.GetPlatform() == Platform_Switch2_Ounce)
			{
				currentData.SetMemberFlashString("txtXButton",
					"X - " + GetLocStringByKeyExt("panel_groupname_strong_attack") +
					htmlNewline + actionPress + GetLocStringByKeyExt("Yrden") +
					htmlNewline +
					htmlNewline + "Y - " + GetLocStringByKeyExt("panel_groupname_fast_attack")  +
					htmlNewline + actionPress + GetLocStringByKeyExt("Axii") +
					htmlNewline +
					htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_jump") +
					htmlNewline + actionPress + GetLocStringByKeyExt("Quen") +
					htmlNewline +
					htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact") +
					htmlNewline + actionPress + GetLocStringByKeyExt("Aard")
				);
			}
			else
			{
				currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("panel_groupname_fast_attack") + htmlNewline + actionPress + GetLocStringByKeyExt("Axii"));
			}
		}
		else
		{
			if (theGame.GetPlatform() == Platform_Switch2_Ounce)
			{
				currentData.SetMemberFlashString("txtXButton",
					"X - " + GetLocStringByKeyExt("panel_groupname_strong_attack") +
					htmlNewline + "Y - " + GetLocStringByKeyExt("panel_groupname_fast_attack") +
					htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_jump") +
					htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact")
				);
			}
			else
			{
				currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("panel_groupname_fast_attack"));
			}
		}
	}
	else
	{
	
		if(quickSignCasting)
		{
			if (theGame.GetPlatform() == Platform_Switch2_Ounce)
			{
				currentData.SetMemberFlashString("txtXButton",
					"X - " + GetLocStringByKeyExt("panel_groupname_strong_attack") +
					htmlNewline + actionPress +  GetLocStringByKeyExt("Yrden") +
					htmlNewline +
					htmlNewline + "Y - " + GetLocStringByKeyExt("panel_groupname_fast_attack") +
					htmlNewline + actionPress + GetLocStringByKeyExt("Axii") +
					htmlNewline +
					htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_jump") +
					htmlNewline + actionPress + GetLocStringByKeyExt("Quen") +
					htmlNewline +
					htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact") +
					htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_RunSprint") +
					htmlNewline + actionPress + GetLocStringByKeyExt("Aard")
				);
			}
			else
			{
				currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("panel_groupname_fast_attack") + htmlNewline + actionPress + GetLocStringByKeyExt("Axii"));
			}
		}
		else
		{
			if (theGame.GetPlatform() == Platform_Switch2_Ounce)
			{
				currentData.SetMemberFlashString("txtXButton",
					"X - " + GetLocStringByKeyExt("panel_groupname_strong_attack") +
					htmlNewline + "Y - " + GetLocStringByKeyExt("panel_groupname_fast_attack") +
					htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_jump") +
					htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact") +
					htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_RunSprint")
				);
			}
			else
			{
				currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("panel_groupname_fast_attack"));
			}
		}
	}

	
	if(leftStickSprint)
	{
		if(quickSignCasting)
			currentData.SetMemberFlashString("txtAButton", GetLocStringByKeyExt("ControlLayout_Interact") + htmlNewline + actionPress + GetLocStringByKeyExt("Aard"));
		else
			currentData.SetMemberFlashString("txtAButton", GetLocStringByKeyExt("ControlLayout_Interact"));
	}
	else
	{
		if(quickSignCasting)
			currentData.SetMemberFlashString("txtAButton", GetLocStringByKeyExt("ControlLayout_Interact") + htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_RunSprint") + htmlNewline + actionPress + GetLocStringByKeyExt("Aard"));
		else
			currentData.SetMemberFlashString("txtAButton", GetLocStringByKeyExt("ControlLayout_Interact") + htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_RunSprint"));
	}
	
	if(quickSignCasting)
		currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("panel_button_common_jump") + htmlNewline + actionPress + GetLocStringByKeyExt("Quen"));
	else
		currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("panel_button_common_jump"));
	
		
	
	if(quickSignCasting)
		currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("panel_groupname_strong_attack") + htmlNewline + actionPress + GetLocStringByKeyExt("Yrden"));
	else
		currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("panel_groupname_strong_attack"));
	
	
	currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("ControlLayout_UseQuickSlot"));
		
	
	if(quickSignCasting)
		currentData.SetMemberFlashString("txtRightTrigger", actionHold + GetLocStringByKeyExt("ControlLayout_CastSign"));
	else
		currentData.SetMemberFlashString("txtRightTrigger", GetLocStringByKeyExt("ControlLayout_CastSign"));
	
	
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	
	
	if(quickSignCasting)
		currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("ControlLayout_Focus") + htmlNewline + actionPress + GetLocStringByKeyExt("Igni"));
	else
		currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("ControlLayout_Focus"));
	
	
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	
	
	if(leftStickSprint)
		currentData.SetMemberFlashString("txtLeftJoy", txtMovement + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_RunSprint") + htmlNewline + actionDoubleTap + GetLocStringByKeyExt("ControlLayout_SummonHorse"));
	else
		currentData.SetMemberFlashString("txtLeftJoy", txtMovement + htmlNewline + actionDoubleTap + GetLocStringByKeyExt("ControlLayout_SummonHorse"));
	
	
	currentData.SetMemberFlashString("txtDPad", txtDPad);
	currentData.SetMemberFlashString("txtLeftJoyRightJoy", txtLeftJoyRightJoy);
	dataFlashArray.PushBackFlashObject(currentData);
	

	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_SwinningLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", GetLocStringByKeyExt("ControlLayout_ControlCamera") + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest") + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_LockTarget"));
		
	if(leftStickSprint)
	{
		if (theGame.GetPlatform() == Platform_Switch2_Ounce)
		{
			currentData.SetMemberFlashString("txtXButton",
				"Y - " + actionHold + GetLocStringByKeyExt("ControlLayout_Dive") +
				
				htmlNewline + "B - " + actionHold + GetLocStringByKeyExt("ControlLayout_Emerge") +
				htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact")
			);
		}
		else
		{
			currentData.SetMemberFlashString("txtXButton", actionHold + GetLocStringByKeyExt("ControlLayout_Dive"));
		}
	}
	else
	{
		if (theGame.GetPlatform() == Platform_Switch2_Ounce)
		{
			currentData.SetMemberFlashString("txtXButton",
				"Y - " + actionHold + GetLocStringByKeyExt("ControlLayout_Dive") +
				
				htmlNewline + "B - " + actionHold + GetLocStringByKeyExt("ControlLayout_Emerge") +
				htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact") +
				htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_FastSwim")
			);
		}
		else
		{
			currentData.SetMemberFlashString("txtXButton", actionHold + GetLocStringByKeyExt("ControlLayout_Dive"));
		}
	}
		
	
	if(leftStickSprint)
		currentData.SetMemberFlashString("txtAButton",  GetLocStringByKeyExt("ControlLayout_Interact"));
	else
		currentData.SetMemberFlashString("txtAButton",  GetLocStringByKeyExt("ControlLayout_Interact") + htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_FastSwim"));
	
	
	currentData.SetMemberFlashString("txtBButton", actionHold + GetLocStringByKeyExt("ControlLayout_Emerge"));
	currentData.SetMemberFlashString("txtYButton", "");
	currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("ControlLayout_UseQuickSlot"));
	currentData.SetMemberFlashString("txtRightTrigger", "");
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("ControlLayout_Focus"));
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	
	
	if(leftStickSprint)
		currentData.SetMemberFlashString("txtLeftJoy", txtMovement + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_FastSwim"));
	else
		currentData.SetMemberFlashString("txtLeftJoy", txtMovement);
	
	
	
	if (theGame.GetPlatform() == Platform_PS5)
		currentData.SetMemberFlashString("txtDPad", GetPlatformLocString("ControlLayout_UpPotions_ps5") + htmlNewline + GetPlatformLocString("ControlLayout_DownHideSword_ps5"));
	else if(theGame.GetPlatform() == Platform_Switch2_Ounce )
		currentData.SetMemberFlashString("txtDPad", GetPlatformLocString("ControlLayout_UpPotions_nx") + htmlNewline + GetPlatformLocString("ControlLayout_DownHideSword_nx"));
	else
		currentData.SetMemberFlashString("txtDPad", GetPlatformLocString("ControlLayout_UpPotions") + htmlNewline + GetPlatformLocString("ControlLayout_DownHideSword"));
	
	currentData.SetMemberFlashString("txtLeftJoyRightJoy", txtLeftJoyRightJoy);
	dataFlashArray.PushBackFlashObject(currentData);
	

	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_CombatLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", txtCameraControl);
	
	if(leftStickSprint)
	{
		
		if(quickSignCasting)
		{
			if (theGame.GetPlatform() == Platform_Switch2_Ounce)
			{
				currentData.SetMemberFlashString("txtXButton",
					"X - " + GetLocStringByKeyExt("panel_groupname_strong_attack") +
					htmlNewline + actionPress + GetLocStringByKeyExt("Yrden") +
					htmlNewline +
					htmlNewline + "Y - " + GetLocStringByKeyExt("panel_groupname_fast_attack") +
					htmlNewline + actionPress + GetLocStringByKeyExt("Axii")  +
					htmlNewline +
					htmlNewline + "B - " + GetLocStringByKeyExt("ControlLayout_Dodge") +
					htmlNewline + actionPress + GetLocStringByKeyExt("Quen") +
					htmlNewline +
					htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Roll") +
					htmlNewline + actionPress + GetLocStringByKeyExt("Aard")
				);
			}
			else
			{
				currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("panel_groupname_fast_attack") + htmlNewline + actionPress + GetLocStringByKeyExt("Axii"));
			}
		}
		else
		{
			if (theGame.GetPlatform() == Platform_Switch2_Ounce)
			{
				currentData.SetMemberFlashString("txtXButton",
					"X - " + GetLocStringByKeyExt("panel_groupname_strong_attack") +
					htmlNewline + "Y - " + GetLocStringByKeyExt("panel_groupname_fast_attack") +
					htmlNewline + "B - " + GetLocStringByKeyExt("ControlLayout_Dodge") +
					htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Roll")
				);
			}
			else
			{
				currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("panel_groupname_fast_attack"));
			}
		}
	}
	else
	{
	
		if (quickSignCasting)
		{
			if (theGame.GetPlatform() == Platform_Switch2_Ounce)
			{
				currentData.SetMemberFlashString("txtXButton",
					"X - " + GetLocStringByKeyExt("panel_groupname_strong_attack")  +
					htmlNewline + actionPress + GetLocStringByKeyExt("Yrden") +
					htmlNewline +
					htmlNewline + "Y - " + GetLocStringByKeyExt("panel_groupname_fast_attack") +
					htmlNewline + actionPress + GetLocStringByKeyExt("Axii") +
					htmlNewline +
					htmlNewline + "B - " + GetLocStringByKeyExt("ControlLayout_Dodge") +
					htmlNewline + actionPress + GetLocStringByKeyExt("Quen") +
					htmlNewline +
					htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Roll") +
					htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_RunSprint") +
					htmlNewline + actionPress + GetLocStringByKeyExt("Aard")
				);
			}
			else
			{
				currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("panel_groupname_fast_attack") + htmlNewline + actionPress + GetLocStringByKeyExt("Axii"));
			}
		}
		else
		{
			if (theGame.GetPlatform() == Platform_Switch2_Ounce)
			{
				currentData.SetMemberFlashString("txtXButton",
					"X - " + GetLocStringByKeyExt("panel_groupname_strong_attack") +
					htmlNewline + "Y - " + GetLocStringByKeyExt("panel_groupname_fast_attack")  +
					htmlNewline + "B - " + GetLocStringByKeyExt("ControlLayout_Dodge") +
					htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Roll") +
					htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_RunSprint")
				);
			}
			else
			{
				currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("panel_groupname_fast_attack"));
			}
		}
	}
	
	
	
	
	if(quickSignCasting)
		currentData.SetMemberFlashString("txtAButton", GetLocStringByKeyExt("ControlLayout_Roll") + htmlNewline + actionPress + GetLocStringByKeyExt("Aard"));
	else
		currentData.SetMemberFlashString("txtAButton", GetLocStringByKeyExt("ControlLayout_Roll"));
	
	
	
	if(quickSignCasting)
		currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("ControlLayout_Dodge") + htmlNewline + actionPress + GetLocStringByKeyExt("Quen"));
	else
		currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("ControlLayout_Dodge"));
	
		
	
	if(quickSignCasting)
		currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("panel_groupname_strong_attack") + htmlNewline + actionPress + GetLocStringByKeyExt("Yrden"));
	else
		currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("panel_groupname_strong_attack"));
	
	
	currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("ControlLayout_UseQuickSlot"));
	
	
	if(quickSignCasting)
		currentData.SetMemberFlashString("txtRightTrigger", actionHold + GetLocStringByKeyExt("ControlLayout_CastSign"));
	else
		currentData.SetMemberFlashString("txtRightTrigger", GetLocStringByKeyExt("ControlLayout_CastSign"));
	
	
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	
	
	if(quickSignCasting)
		currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("panel_input_action_lockandguard") + htmlNewline + actionPress + GetLocStringByKeyExt("Igni"));
	else
		currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("panel_input_action_lockandguard"));
	
	
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	
	
	if(leftStickSprint)
		currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement") + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_RunSprint"));
	else
		currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement"));
	
	
	currentData.SetMemberFlashString("txtDPad", txtDPad);
	currentData.SetMemberFlashString("txtLeftJoyRightJoy", txtLeftJoyRightJoy);
	dataFlashArray.PushBackFlashObject(currentData);
	

	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_HorseLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", txtCameraControl + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
		
	if (theGame.GetPlatform() == Platform_Switch2_Ounce)
	{
		currentData.SetMemberFlashString("txtXButton",
			"X - " + GetLocStringByKeyExt("ControlLayout_DrawSwordAttack") +
			htmlNewline +
			htmlNewline + "Y - " + GetLocStringByKeyExt("ControlLayout_DrawSwordAttack") +
			htmlNewline +
			htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_jump") +
			htmlNewline + actionHold + txtMountDismount +
			htmlNewline +
			 htmlNewline + "A - " + actionHold + GetLocStringByKeyExt("ControlLayout_Canter") + "<br/>" + GetLocStringByKeyExt("ControlLayout_doubleTap") +
			 " + " + actionHold + GetLocStringByKeyExt("ControlLayout_Gallop")
		);
	}
	else
	{
		currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("ControlLayout_DrawSwordAttack"));
	}
	
	
		currentData.SetMemberFlashString("txtAButton",  actionHold + GetLocStringByKeyExt("ControlLayout_Canter") + "<br/>" + GetLocStringByKeyExt("ControlLayout_doubleTap") + " + " + actionHold + GetLocStringByKeyExt("ControlLayout_Gallop"));
	
	currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("panel_button_common_jump") + htmlNewline + actionHold + txtMountDismount );
	currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("ControlLayout_DrawSwordAttack"));
	currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("ControlLayout_UseQuickSlot"));
	currentData.SetMemberFlashString("txtRightTrigger", GetLocStringByKeyExt("panel_button_hud_interaction_axii_calm_horse"));
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("ControlLayout_Focus"));
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement"));
	currentData.SetMemberFlashString("txtDPad", txtDPad);
	currentData.SetMemberFlashString("txtLeftJoyRightJoy", txtLeftJoyRightJoy);
	dataFlashArray.PushBackFlashObject(currentData);
	

	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_BoatLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", txtCameraControl + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
	
	if (theGame.GetPlatform() == Platform_Switch2_Ounce)
	{
		currentData.SetMemberFlashString("txtXButton",
			"Y - " + actionHold + GetLocStringByKeyExt("ControlLayout_Stop") +
			
			htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_disembark") +
			htmlNewline + "A - " + actionHold + GetLocStringByKeyExt("ControlLayout_Accelerate")
		);
	}
	else
	{
		currentData.SetMemberFlashString("txtXButton", actionHold + GetLocStringByKeyExt("ControlLayout_Stop"));
	}
	
	currentData.SetMemberFlashString("txtAButton", actionHold + GetLocStringByKeyExt("ControlLayout_Accelerate"));
	currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("panel_button_common_disembark"));
	currentData.SetMemberFlashString("txtYButton", "");
	currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("ControlLayout_UseQuickSlot"));
	currentData.SetMemberFlashString("txtRightTrigger", "");
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("ControlLayout_Focus"));
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement"));
	
	
	if (theGame.GetPlatform() == Platform_PS5)
		currentData.SetMemberFlashString("txtDPad", GetPlatformLocString("ControlLayout_UpPotions_ps5") + htmlNewline + GetPlatformLocString("ControlLayout_DownHideSword_ps5"));
	else if(theGame.GetPlatform() == Platform_Switch2_Ounce)
		currentData.SetMemberFlashString("txtDPad", GetPlatformLocString("ControlLayout_UpPotions_nx") + htmlNewline + GetPlatformLocString("ControlLayout_DownHideSword_nx"));
	else
		currentData.SetMemberFlashString("txtDPad", GetPlatformLocString("ControlLayout_UpPotions") + htmlNewline + GetPlatformLocString("ControlLayout_DownHideSword"));
	
	currentData.SetMemberFlashString("txtLeftJoyRightJoy", txtLeftJoyRightJoy);
	dataFlashArray.PushBackFlashObject(currentData);
	

	if (theGame.GetPlatform() == Platform_Switch2_Ounce)
	{
		switch(theInput.GetMouserControllerScheme())
		{
			case MouserControllerScheme_None:
			{	
				
				if(quickSignCasting)
				{
					currentData = flashStorageUtility.CreateTempFlashObject();
					currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("controller_scheme_category_mouser"));
					currentData.SetMemberFlashString("txtRightJoy",actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest") );
					currentData.SetMemberFlashString("txtXButton",
						"X - " +GetLocStringByKeyExt("panel_groupname_strong_attack")  +
						htmlNewline + actionPress + GetLocStringByKeyExt("nAxii") +
						htmlNewline +
						htmlNewline + "Y - " + GetLocStringByKeyExt("panel_groupname_fast_attack")  +
						htmlNewline + actionPress + GetLocStringByKeyExt("Yrde") +
						htmlNewline +
						htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_jump") +
						htmlNewline + actionPress + GetLocStringByKeyExt("Quen") +
						htmlNewline +
						htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact") + 
						htmlNewline + actionPress + GetLocStringByKeyExt("Aard")
					);
					currentData.SetMemberFlashString("txtAButton", "");
					currentData.SetMemberFlashString("txtBButton", "");
					currentData.SetMemberFlashString("txtYButton", "");
					currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("ControlLayout_UseQuickSlot"));
					currentData.SetMemberFlashString("txtRightTrigger", "");
					currentData.SetMemberFlashString("txtStartButton", GetLocStringByKeyExt("ControlLayout_CastSign"));
					currentData.SetMemberFlashString("txtSelectButton","" );
					currentData.SetMemberFlashString("txtLeftTrigger",  GetLocStringByKeyExt("ControlLayout_Focus") + htmlNewline + actionPress + GetLocStringByKeyExt("Igni"));
					currentData.SetMemberFlashString("txtLeftBumper",  GetLocStringByKeyExt("ControlLayout_RadialMenu") );
					currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement"));
					currentData.SetMemberFlashString("txtDPad",txtDPad);
					dataFlashArray.PushBackFlashObject(currentData);
				}
				else
				{
					currentData = flashStorageUtility.CreateTempFlashObject();
					currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("controller_scheme_category_mouser"));
					currentData.SetMemberFlashString("txtRightJoy",actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest") );
					currentData.SetMemberFlashString("txtXButton",
						"X - " +GetLocStringByKeyExt("panel_groupname_strong_attack")  +
						htmlNewline + "Y - " + GetLocStringByKeyExt("panel_groupname_fast_attack")  +
						htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_jump") +
						htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact") 
					);
					currentData.SetMemberFlashString("txtAButton", "");
					currentData.SetMemberFlashString("txtBButton", "");
					currentData.SetMemberFlashString("txtYButton", "");
					currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("ControlLayout_UseQuickSlot"));
					currentData.SetMemberFlashString("txtRightTrigger", "");
					currentData.SetMemberFlashString("txtStartButton", GetLocStringByKeyExt("ControlLayout_CastSign"));
					currentData.SetMemberFlashString("txtSelectButton","" );
					currentData.SetMemberFlashString("txtLeftTrigger",  GetLocStringByKeyExt("ControlLayout_Focus"));
					currentData.SetMemberFlashString("txtLeftBumper",  GetLocStringByKeyExt("ControlLayout_RadialMenu") );
					currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement"));
					currentData.SetMemberFlashString("txtDPad",txtDPad);
					dataFlashArray.PushBackFlashObject(currentData);
				}		
				
				break;
			}

			case MouserControllerScheme_Comfort:
			{	
				
				if(quickSignCasting)
				{
					currentData = flashStorageUtility.CreateTempFlashObject();
					currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("controller_scheme_category_mouser"));
					currentData.SetMemberFlashString("txtRightJoy", actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
					
					currentData.SetMemberFlashString("txtXButton",
						"X - " + GetLocStringByKeyExt("ControlLayout_UseQuickSlot") +
						htmlNewline + actionPress + GetLocStringByKeyExt("Axii") +
						htmlNewline +
						htmlNewline + "Y - " + GetLocStringByKeyExt("ControlLayout_Focus") +
						htmlNewline + actionPress + GetLocStringByKeyExt("Yrden") +
						htmlNewline +
						htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_jump") +
						htmlNewline + actionPress + GetLocStringByKeyExt("Quen") +
						htmlNewline +
						htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact") +
						htmlNewline + actionPress + GetLocStringByKeyExt("Aard")
						);
					currentData.SetMemberFlashString("txtAButton", "");
					currentData.SetMemberFlashString("txtBButton", "");
					currentData.SetMemberFlashString("txtYButton", "");
					currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("panel_groupname_fast_attack"));
					currentData.SetMemberFlashString("txtRightTrigger", "");
					currentData.SetMemberFlashString("txtStartButton", GetLocStringByKeyExt("panel_groupname_strong_attack") +  htmlNewline + actionPress + GetLocStringByKeyExt("Igni"));
					currentData.SetMemberFlashString("txtSelectButton","" );
					currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("ControlLayout_CastSign"));
					currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu") );
					currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement"));
					currentData.SetMemberFlashString("txtDPad",txtDPad);
					dataFlashArray.PushBackFlashObject(currentData);
				}
				else
				{				
					currentData = flashStorageUtility.CreateTempFlashObject();
					currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("controller_scheme_category_mouser"));
					currentData.SetMemberFlashString("txtRightJoy", actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
					
					currentData.SetMemberFlashString("txtXButton",
						"X - " + GetLocStringByKeyExt("ControlLayout_UseQuickSlot") +
						htmlNewline + "Y - " + GetLocStringByKeyExt("ControlLayout_Focus") +
						htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_jump") +
						htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact")
						);
					currentData.SetMemberFlashString("txtAButton", "");
					currentData.SetMemberFlashString("txtBButton", "");
					currentData.SetMemberFlashString("txtYButton", "");
					currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("panel_groupname_fast_attack"));
					currentData.SetMemberFlashString("txtRightTrigger", "");
					currentData.SetMemberFlashString("txtStartButton", GetLocStringByKeyExt("panel_groupname_strong_attack"));
					currentData.SetMemberFlashString("txtSelectButton","" );
					currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("ControlLayout_CastSign"));
					currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu") );
					currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement"));
					currentData.SetMemberFlashString("txtDPad",txtDPad);
					dataFlashArray.PushBackFlashObject(currentData);
				}
				break;
			}

			case MouserControllerScheme_Dynamic:
			{
				
				if(quickSignCasting)
				{
					if(theGame.GetPlatform() == Platform_Switch2_Ounce)
					{
						txtDPad = 
							GetPlatformLocString("ControlLayout_LeftSteelSword_nx") +
							htmlNewline + actionPress + GetLocStringByKeyExt("Yrden") +
							htmlNewline +
							htmlNewline + GetPlatformLocString("ControlLayout_RightSilverSword_nx") + 
							htmlNewline + actionPress + GetLocStringByKeyExt("Aard") +
							htmlNewline +
							htmlNewline + GetPlatformLocString("ControlLayout_UpPotions_nx") + 
							htmlNewline + actionPress + GetLocStringByKeyExt("Axii") +
							htmlNewline +
							htmlNewline + GetPlatformLocString("ControlLayout_DownHideSword_nx") +
							htmlNewline + actionPress + GetLocStringByKeyExt("Quen");
					}
					else
					{
						txtDPad = 
							GetPlatformLocString("ControlLayout_LeftSteelSword") +
							htmlNewline + actionPress + GetLocStringByKeyExt("Yrden") +
							htmlNewline +
							htmlNewline + GetPlatformLocString("ControlLayout_RightSilverSword") + 
							htmlNewline + actionPress + GetLocStringByKeyExt("Aard") +
							htmlNewline +
							htmlNewline + GetPlatformLocString("ControlLayout_UpPotions") + 
							htmlNewline + actionPress + GetLocStringByKeyExt("Axii") +
							htmlNewline +
							htmlNewline + GetPlatformLocString("ControlLayout_DownHideSword") +
							htmlNewline + actionPress + GetLocStringByKeyExt("Quen");
					}
					
					currentData = flashStorageUtility.CreateTempFlashObject();
					currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("controller_scheme_category_mouser"));
					currentData.SetMemberFlashString("txtRightJoy", actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
					currentData.SetMemberFlashString("txtXButton",
						"X - " + GetLocStringByKeyExt("ControlLayout_UseQuickSlot") +
						htmlNewline + "Y - " + GetLocStringByKeyExt("ControlLayout_CastSign") +
						htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_jump") +
						htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact") 
					);
					currentData.SetMemberFlashString("txtAButton", "");
					currentData.SetMemberFlashString("txtBButton", "");
					currentData.SetMemberFlashString("txtYButton", "");
					currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("panel_groupname_fast_attack"));
					currentData.SetMemberFlashString("txtRightTrigger", "");
					currentData.SetMemberFlashString("txtStartButton", GetLocStringByKeyExt("panel_groupname_strong_attack"));
					currentData.SetMemberFlashString("txtSelectButton","" );
					currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("ControlLayout_Focus")  + htmlNewline + actionPress + GetLocStringByKeyExt("Igni"));
					currentData.SetMemberFlashString("txtLeftBumper",  GetLocStringByKeyExt("ControlLayout_RadialMenu") );
					currentData.SetMemberFlashString("txtLeftJoy",GetLocStringByKeyExt("ControlLayout_Movement"));
					currentData.SetMemberFlashString("txtDPad",txtDPad);
					dataFlashArray.PushBackFlashObject(currentData);
				}
				else
				{
					currentData = flashStorageUtility.CreateTempFlashObject();
					currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("controller_scheme_category_mouser"));
					currentData.SetMemberFlashString("txtRightJoy", actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
					currentData.SetMemberFlashString("txtXButton",
						"X - " + GetLocStringByKeyExt("ControlLayout_UseQuickSlot") +
						htmlNewline + "Y - " + GetLocStringByKeyExt("ControlLayout_CastSign") +
						htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_jump") +
						htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact") 
					);
					currentData.SetMemberFlashString("txtAButton", "");
					currentData.SetMemberFlashString("txtBButton", "");
					currentData.SetMemberFlashString("txtYButton", "");
					currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("panel_groupname_fast_attack"));
					currentData.SetMemberFlashString("txtRightTrigger", "");
					currentData.SetMemberFlashString("txtStartButton", GetLocStringByKeyExt("panel_groupname_strong_attack"));
					currentData.SetMemberFlashString("txtSelectButton","" );
					currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("ControlLayout_Focus") );
					currentData.SetMemberFlashString("txtLeftBumper",  GetLocStringByKeyExt("ControlLayout_RadialMenu") );
					currentData.SetMemberFlashString("txtLeftJoy",GetLocStringByKeyExt("ControlLayout_Movement"));
					currentData.SetMemberFlashString("txtDPad",txtDPad);
					dataFlashArray.PushBackFlashObject(currentData);
				}	
				
				break;
			}
		}		
	}

	return dataFlashArray;
}

function InGameMenu_CreateControllerDataCiri(flashStorageUtility : CScriptedFlashValueStorage) : CScriptedFlashArray
{
	var dataFlashArray 	: CScriptedFlashArray;
	var currentData		: CScriptedFlashObject;
	
	var htmlNewline 			: string = "&#10;";
	var actionPress				: string;
	var actionHold				: string;
	var txtPanelSelection   	: string;
	var txtGameMenu   			: string;
	var txtCameraControl		: string;
	var txtDPad					: string;
	var txtMovement				: string;
	var txtMountDismount		: string;
	var txtLeftJoyRightJoy		: string;
	
	if (theGame.GetPlatform() == Platform_PS4)
	{
		txtPanelSelection = GetLocStringByKeyExt("PANEL_MENUSELECTOR_ps4");
		txtGameMenu = GetLocStringByKeyExt("ControlLayout_system_menu_ps4");
		txtLeftJoyRightJoy = GetLocStringByKeyExt("ControlLayout_pressLeftJoyRightJoy_ps5")+" "+GetLocStringByKeyExt("ControlLayout_PhotoMode");
	}
	else if(theGame.GetPlatform() == Platform_PS5)
	{
		txtPanelSelection = GetLocStringByKeyExt("PANEL_MENUSELECTOR");
		txtGameMenu = GetLocStringByKeyExt("ControlLayout_system_menu");
		txtLeftJoyRightJoy = GetLocStringByKeyExt("ControlLayout_pressLeftJoyRightJoy_ps5")+" "+GetLocStringByKeyExt("ControlLayout_PhotoMode");
	}
	else if(theGame.GetPlatform() == Platform_Xbox1)
	{
		txtPanelSelection = GetLocStringByKeyExt("PANEL_MENUSELECTOR");
		txtGameMenu = GetLocStringByKeyExt("ControlLayout_system_menu");
		txtLeftJoyRightJoy = GetLocStringByKeyExt("ControlLayout_pressLeftJoyRightJoy")+" "+GetLocStringByKeyExt("ControlLayout_PhotoMode");
	}
	else if(theGame.GetPlatform() == Platform_Switch2_Ounce)
	{
		txtPanelSelection = GetLocStringByKeyExt("PANEL_MENUSELECTOR");
		txtGameMenu = GetLocStringByKeyExt("ControlLayout_system_menu");
		txtLeftJoyRightJoy ="<p align=\"center\">"+ GetLocStringByKeyExt("ControlLayout_pressLeftJoyRightJoy_switch2")+" - "+GetLocStringByKeyExt("ControlLayout_PhotoMode")+"</p>";
	}
	else
	{	
		txtLeftJoyRightJoy = GetLocStringByKeyExt("ControlLayout_pressLeftJoyRightJoy")+" "+GetLocStringByKeyExt("ControlLayout_PhotoMode");
		txtPanelSelection = GetLocStringByKeyExt("PANEL_MENUSELECTOR");
		txtGameMenu = GetLocStringByKeyExt("ControlLayout_system_menu");
	}

	actionPress = GetLocStringByKeyExt("ControlLayout_press") + " ";
	actionHold = GetLocStringByKeyExt("ControlLayout_hold") + " - ";
	txtCameraControl = GetLocStringByKeyExt("ControlLayout_ControlCamera") + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_LockTarget");
	txtDPad = GetLocStringByKeyExt("ControlLayout_DPadLeftRight") + " - " + GetLocStringByKeyExt("ControlLayout_CiriDrawSword");
	txtMovement = GetLocStringByKeyExt("ControlLayout_Movement");
	txtMountDismount = GetLocStringByKeyExt("panel_button_common_dismount");

	dataFlashArray = flashStorageUtility.CreateTempFlashArray();
	
	
	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_ExplorationLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", GetLocStringByKeyExt("ControlLayout_ControlCamera") + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
	
	if ( thePlayer.HasAbility('CiriCharge') )
	{
		if (theGame.GetPlatform() == Platform_Switch2_Ounce)
		{
			currentData.SetMemberFlashString("txtXButton",
				"X - " + GetLocStringByKeyExt("panel_groupname_fast_attack") +
				htmlNewline +actionHold + GetLocStringByKeyExt("ControlLayout_CiriCharge") +
				htmlNewline +
				htmlNewline + "Y - " + GetLocStringByKeyExt("panel_groupname_fast_attack") +
				htmlNewline +
				htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_jump") +
				htmlNewline +
				htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact") +
				htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_RunSprint")
			);
		}
		else
		{
			currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("panel_groupname_fast_attack"));
		}
	}
	else
	{
		if (theGame.GetPlatform() == Platform_Switch2_Ounce)
		{
			currentData.SetMemberFlashString("txtXButton",
				"X - " + GetLocStringByKeyExt("panel_groupname_fast_attack") +
				htmlNewline + "Y - " + GetLocStringByKeyExt("panel_groupname_fast_attack") +
				htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_jump") +
				htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact") +
				htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_RunSprint")
			);
		}
		else
		{
			currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("panel_groupname_fast_attack"));
		}
	}

	currentData.SetMemberFlashString("txtAButton", GetLocStringByKeyExt("ControlLayout_Interact") + htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_RunSprint"));
	currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("panel_button_common_jump"));
	if ( thePlayer.HasAbility('CiriCharge') )
		currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("panel_groupname_fast_attack") + htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_CiriCharge"));
	else
		currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("panel_groupname_fast_attack"));
	currentData.SetMemberFlashString("txtRightBumper", "");
	if ( thePlayer.HasAbility('CiriBlink') )
		currentData.SetMemberFlashString("txtRightTrigger", GetLocStringByKeyExt("ControlLayout_CiriBlink"));
	else
		currentData.SetMemberFlashString("txtRightTrigger", "");
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", "");
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	currentData.SetMemberFlashString("txtLeftJoy", txtMovement);
	currentData.SetMemberFlashString("txtDPad", txtDPad);
	dataFlashArray.PushBackFlashObject(currentData);
	currentData.SetMemberFlashString("txtLeftJoyRightJoy", txtLeftJoyRightJoy);
	
	
	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_SwinningLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", GetLocStringByKeyExt("ControlLayout_ControlCamera") + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest") + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_LockTarget"));
	
	currentData.SetMemberFlashString("txtXButton","");
	if (theGame.GetPlatform() == Platform_Switch2_Ounce)
	{
		currentData.SetMemberFlashString("txtXButton",
			"Y - " + actionHold + GetLocStringByKeyExt("ControlLayout_Dive") +
			
			htmlNewline + "B - " + actionHold + GetLocStringByKeyExt("ControlLayout_Emerge") +
			htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact") +
			htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_FastSwim")
		);
	}
	else
	{
		currentData.SetMemberFlashString("txtXButton",  actionHold + GetLocStringByKeyExt("ControlLayout_Dive"));
	}
	currentData.SetMemberFlashString("txtAButton",  GetLocStringByKeyExt("ControlLayout_Interact") + htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_FastSwim"));
	currentData.SetMemberFlashString("txtBButton", actionHold + GetLocStringByKeyExt("ControlLayout_Emerge"));
	currentData.SetMemberFlashString("txtYButton", "");
	currentData.SetMemberFlashString("txtRightBumper", "");
	currentData.SetMemberFlashString("txtRightTrigger", "");
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", "");
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	currentData.SetMemberFlashString("txtLeftJoy", txtMovement);
	currentData.SetMemberFlashString("txtDPad", "");
	dataFlashArray.PushBackFlashObject(currentData);
	currentData.SetMemberFlashString("txtLeftJoyRightJoy", txtLeftJoyRightJoy);
	
	
	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_CombatLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", txtCameraControl);

	if ( thePlayer.HasAbility('CiriCharge'))
	{
		if(theGame.GetPlatform() == Platform_Switch2_Ounce)
		{
			currentData.SetMemberFlashString("txtXButton",
				"X - " + GetLocStringByKeyExt("panel_groupname_fast_attack") +
				htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_CiriCharge") +
				htmlNewline +
				htmlNewline + "Y - " + GetLocStringByKeyExt("panel_groupname_fast_attack") +
				htmlNewline +
				htmlNewline + "B - " + GetLocStringByKeyExt("ControlLayout_Dodge") +
				htmlNewline +
				htmlNewline + "A - " + actionHold + GetLocStringByKeyExt("ControlLayout_RunSprint")
			);
		}
		else
		{
			currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("panel_groupname_fast_attack"));
		}
	}
	else
	{
		if(theGame.GetPlatform() == Platform_Switch2_Ounce)
		{
			currentData.SetMemberFlashString("txtXButton",
				"X -" + GetLocStringByKeyExt("panel_groupname_fast_attack") +
				htmlNewline +
				htmlNewline + "Y - " + GetLocStringByKeyExt("panel_groupname_fast_attack") +
				htmlNewline +
				htmlNewline + "B - " + GetLocStringByKeyExt("ControlLayout_Dodge") +
				htmlNewline +
				htmlNewline + "A - " + actionHold + GetLocStringByKeyExt("ControlLayout_RunSprint")
			);
		}
		else
		{
			currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("panel_groupname_fast_attack"));
		}
	}
	
	currentData.SetMemberFlashString("txtAButton", actionHold + GetLocStringByKeyExt("ControlLayout_RunSprint"));
	currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("ControlLayout_Dodge"));
	if ( thePlayer.HasAbility('CiriCharge'))
		currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("panel_groupname_fast_attack") + htmlNewline + actionHold + GetLocStringByKeyExt("ControlLayout_CiriCharge"));
	else
		currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("panel_groupname_fast_attack"));
	currentData.SetMemberFlashString("txtRightBumper", "");
	if ( thePlayer.HasAbility('CiriBlink'))
		currentData.SetMemberFlashString("txtRightTrigger", GetLocStringByKeyExt("ControlLayout_CiriBlink"));
	else
		currentData.SetMemberFlashString("txtRightTrigger", "");
	currentData.SetMemberFlashString("txtRightBumper", "");
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("panel_input_action_guard"));
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement"));
	currentData.SetMemberFlashString("txtDPad", txtDPad);
	dataFlashArray.PushBackFlashObject(currentData);
	currentData.SetMemberFlashString("txtLeftJoyRightJoy", txtLeftJoyRightJoy);
	
	
	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_HorseLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", txtCameraControl + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
	
	if (theGame.GetPlatform() == Platform_Switch2_Ounce)
	{
		currentData.SetMemberFlashString("txtXButton",
			"X - " + GetLocStringByKeyExt("ControlLayout_DrawSwordAttack") +
			htmlNewline +
			htmlNewline + "Y - " + GetLocStringByKeyExt("ControlLayout_DrawSwordAttack") +
			htmlNewline +
			htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_jump") +
			htmlNewline + actionHold + txtMountDismount 
			
			
			
			
		);
	}
	else
	{
		currentData.SetMemberFlashString("txtXButton", GetLocStringByKeyExt("ControlLayout_DrawSwordAttack"));
	}
	currentData.SetMemberFlashString("txtAButton", "");
	currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("panel_button_common_jump") + htmlNewline + actionHold + txtMountDismount );
	currentData.SetMemberFlashString("txtYButton", GetLocStringByKeyExt("ControlLayout_DrawSwordAttack"));
	currentData.SetMemberFlashString("txtRightBumper", "");
	currentData.SetMemberFlashString("txtRightTrigger", "");
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", "");
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	currentData.SetMemberFlashString("txtLeftJoy", 
												GetLocStringByKeyExt("ControlLayout_Movement")
												
												
												
												 );
	currentData.SetMemberFlashString("txtDPad", txtDPad);
	dataFlashArray.PushBackFlashObject(currentData);
	currentData.SetMemberFlashString("txtLeftJoyRightJoy", txtLeftJoyRightJoy);
	
	
	currentData = flashStorageUtility.CreateTempFlashObject();
	currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("ControlLayout_BoatLayoutTitle"));
	currentData.SetMemberFlashString("txtRightJoy", txtCameraControl + htmlNewline + actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
	
	if (theGame.GetPlatform() == Platform_Switch2_Ounce)
	{
		currentData.SetMemberFlashString("txtXButton", 
			"Y - " +  actionHold + GetLocStringByKeyExt("ControlLayout_Stop") +
			
			htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_disembark") +
			htmlNewline + "A - " + actionHold + GetLocStringByKeyExt("ControlLayout_Accelerate")
		);
	}
	else
	{
		currentData.SetMemberFlashString("txtXButton", actionHold + GetLocStringByKeyExt("ControlLayout_Stop"));
	}
	currentData.SetMemberFlashString("txtAButton", actionHold + GetLocStringByKeyExt("ControlLayout_Accelerate"));
	currentData.SetMemberFlashString("txtBButton", GetLocStringByKeyExt("panel_button_common_disembark"));
	currentData.SetMemberFlashString("txtYButton", "");
	currentData.SetMemberFlashString("txtRightBumper", "");
	currentData.SetMemberFlashString("txtRightTrigger", "");
	currentData.SetMemberFlashString("txtStartButton", txtPanelSelection);
	currentData.SetMemberFlashString("txtSelectButton", txtGameMenu);
	currentData.SetMemberFlashString("txtLeftTrigger", "");
	currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu"));
	currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement"));
	currentData.SetMemberFlashString("txtDPad", "");
	dataFlashArray.PushBackFlashObject(currentData);
	currentData.SetMemberFlashString("txtLeftJoyRightJoy", txtLeftJoyRightJoy);


	if (theGame.GetPlatform() == Platform_Switch2_Ounce)
	{
		switch(theInput.GetMouserControllerScheme())
		{
			case MouserControllerScheme_None:
			{
				
				currentData = flashStorageUtility.CreateTempFlashObject();
				currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("controller_scheme_category_mouser"));
				currentData.SetMemberFlashString("txtRightJoy",actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest") );
				currentData.SetMemberFlashString("txtXButton",
					"X - " +GetLocStringByKeyExt("panel_groupname_strong_attack")  +
					htmlNewline + "Y - " + GetLocStringByKeyExt("panel_groupname_fast_attack")  +
					htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_jump") +
					htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact") 
				);
				currentData.SetMemberFlashString("txtAButton", "");
				currentData.SetMemberFlashString("txtBButton", "");
				currentData.SetMemberFlashString("txtYButton", "");
				currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("ControlLayout_UseQuickSlot"));
				currentData.SetMemberFlashString("txtRightTrigger", "");
				currentData.SetMemberFlashString("txtStartButton", GetLocStringByKeyExt("ControlLayout_CastSign"));
				currentData.SetMemberFlashString("txtSelectButton","" );
				currentData.SetMemberFlashString("txtLeftTrigger",  GetLocStringByKeyExt("ControlLayout_Focus"));
				currentData.SetMemberFlashString("txtLeftBumper",  GetLocStringByKeyExt("ControlLayout_RadialMenu") );
				currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement"));
				currentData.SetMemberFlashString("txtDPad",txtDPad);
				dataFlashArray.PushBackFlashObject(currentData);
				break;
			}

			case MouserControllerScheme_Comfort:
			{
				
				currentData = flashStorageUtility.CreateTempFlashObject();
				currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("controller_scheme_category_mouser"));
				currentData.SetMemberFlashString("txtRightJoy", actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
				currentData.SetMemberFlashString("txtXButton",
					"X - " + GetLocStringByKeyExt("ControlLayout_UseQuickSlot") +
					htmlNewline + "Y - " + GetLocStringByKeyExt("ControlLayout_Focus") +
					htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_jump") +
					htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact") 
				);
				currentData.SetMemberFlashString("txtAButton", "");
				currentData.SetMemberFlashString("txtBButton", "");
				currentData.SetMemberFlashString("txtYButton", "");
				currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("panel_groupname_fast_attack"));
				currentData.SetMemberFlashString("txtRightTrigger", "");
				currentData.SetMemberFlashString("txtStartButton", GetLocStringByKeyExt("panel_groupname_strong_attack"));
				currentData.SetMemberFlashString("txtSelectButton","" );
				currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("ControlLayout_CastSign"));
				currentData.SetMemberFlashString("txtLeftBumper", GetLocStringByKeyExt("ControlLayout_RadialMenu") );
				currentData.SetMemberFlashString("txtLeftJoy", GetLocStringByKeyExt("ControlLayout_Movement"));
				currentData.SetMemberFlashString("txtDPad",txtDPad);
				dataFlashArray.PushBackFlashObject(currentData);
				break;
			}

			case MouserControllerScheme_Dynamic:
			{
				
				currentData = flashStorageUtility.CreateTempFlashObject();
				currentData.SetMemberFlashString("layoutName", GetLocStringByKeyExt("controller_scheme_category_mouser"));
				currentData.SetMemberFlashString("txtRightJoy", actionPress + GetLocStringByKeyExt("ControlLayout_ChangeQuest"));
				currentData.SetMemberFlashString("txtXButton",
					"X - " + GetLocStringByKeyExt("ControlLayout_UseQuickSlot") +
					htmlNewline + "Y - " + GetLocStringByKeyExt("ControlLayout_CastSign") +
					htmlNewline + "B - " + GetLocStringByKeyExt("panel_button_common_jump") +
					htmlNewline + "A - " + GetLocStringByKeyExt("ControlLayout_Interact") 
				);
				currentData.SetMemberFlashString("txtAButton", "");
				currentData.SetMemberFlashString("txtBButton", "");
				currentData.SetMemberFlashString("txtYButton", "");
				currentData.SetMemberFlashString("txtRightBumper", GetLocStringByKeyExt("panel_groupname_fast_attack"));
				currentData.SetMemberFlashString("txtRightTrigger", "");
				currentData.SetMemberFlashString("txtStartButton", GetLocStringByKeyExt("panel_groupname_strong_attack"));
				currentData.SetMemberFlashString("txtSelectButton","" );
				currentData.SetMemberFlashString("txtLeftTrigger", GetLocStringByKeyExt("ControlLayout_Focus") );
				currentData.SetMemberFlashString("txtLeftBumper",  GetLocStringByKeyExt("ControlLayout_RadialMenu") );
				currentData.SetMemberFlashString("txtLeftJoy",GetLocStringByKeyExt("ControlLayout_Movement"));
				currentData.SetMemberFlashString("txtDPad",txtDPad);
				dataFlashArray.PushBackFlashObject(currentData);

				break;
			}
		}		
	}
	
	return dataFlashArray;
}