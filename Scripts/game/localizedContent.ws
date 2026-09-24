/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import function GetLocStringById( stringId : int ) : string;

import function GetLocStringByKey( stringKey : string ) : string;


import function GetLocStringByKeyExt( stringKey : string ) : string;



import function FixStringForFont( originalString : string ) : string;

function GetPlatformLocString( stringKey : string, optional fallbackKey : string ) : string
{
	var foundString : string;
	foundString = "";

	switch( theGame.GetPlatform() )
	{
		case Platform_PS5:
			foundString = GetLocStringByKey( stringKey + "_ps5");
			
			
			if( foundString != "" )
				break;		
		case Platform_PS4:
			foundString = GetLocStringByKey( stringKey + "_ps4");
			break;
		case Platform_Xbox1:
		case Platform_Xbox_SCARLETT_ANACONDA:
		case Platform_Xbox_SCARLETT_LOCKHART:
			foundString = GetLocStringByKey( stringKey + "_x1");
			break;
	}
	
	if ( foundString != "" )
		return foundString;
		
	if ( fallbackKey != "" )
		return GetLocStringByKeyExt( fallbackKey );
		
	return GetLocStringByKeyExt( stringKey );
}


function GetItemCategoryLocalisedString(cat : name) : string
{
	if(!IsNameValid(cat))
		return "";

	return GetLocStringByKeyExt("item_category_" + StrReplaceAll( StrLower(NameToString(cat)), " ", "_") );
}


function GetAttributeNameLocStr(attName : name, isMult : bool) : string
{
	if(isMult)
		return GetLocStringByKeyExt("attribute_name_"+StrLower(attName)+"_mult");
	else
		return GetLocStringByKeyExt("attribute_name_"+StrLower(attName));
}


function GetLocStringByKeyExtWithParams(stringKey : string , optional intParamsArray : array<int>, optional floatParamsArray : array<float>, optional stringParamsArray : array<string>, optional addNbspTag:bool) : string
{
	var i : int;
	var resultString : string;
	var prefix : string;
	
	resultString = GetLocStringByKeyExt( stringKey );
	
	if (addNbspTag)
	{
		prefix = "&nbsp;";
	}
	else
	{
		prefix = "";
	}
	
	for( i = 0; i < intParamsArray.Size(); i += 1 )
	{
		resultString = StrReplace( resultString, "$I$", prefix + IntToString(intParamsArray[i]) ); 
	}
	for( i = 0; i < floatParamsArray.Size(); i += 1 )
	{
		resultString = StrReplace( resultString, "$F$", prefix + NoTrailZeros(floatParamsArray[i]) );
	}
	for( i = 0; i < stringParamsArray.Size(); i += 1 )
	{
		resultString = StrReplace( resultString, "$S$", prefix + stringParamsArray[i] );
	}
	
	return resultString;
}


function GetLocStringByIdWithParams( stringId : int , optional intParamsArray : array<int>, optional floatParamsArray : array<float>, optional stringParamsArray : array<string>) : string
{
	var i : int;
	var resultString : string;
	
	resultString = GetLocStringById( stringId );

	for( i = 0; i < intParamsArray.Size(); i += 1 )
	{
		resultString = StrReplace( resultString, "$I$", IntToString(intParamsArray[i]) ); 
	}
	for( i = 0; i < floatParamsArray.Size(); i += 1 )
	{
		resultString = StrReplace( resultString, "$F$", NoTrailZeros(floatParamsArray[i]) );
	}
	for( i = 0; i < stringParamsArray.Size(); i += 1 )
	{
		resultString = StrReplace( resultString, "$S$", stringParamsArray[i] );
	}
	
	return resultString;
}

function GetItemTooltipText(item : SItemUniqueId, inv : CInventoryComponent) : string
{
	var itemStats : array<SAttributeTooltip>;
	var i, price : int;
	var nam, descript, fluff, category, strStats : string;
	
	inv.GetTooltipData(item, nam, descript, price, category, itemStats, fluff);
	strStats = "";
	for(i=0; i<itemStats.Size(); i+=1)
	{
		strStats += itemStats[i].attributeName + " ";
		if( itemStats[i].percentageValue )
		{
			strStats += NoTrailZeros(itemStats[i].value * 100 ) + " %<br>";
		}
		else
		{
			strStats += NoTrailZeros(itemStats[i].value) + "<br>";
		}
	}	
	return GetLocStringByKeyExt(nam) + "<br>" + category + "<br><br>" + strStats + "<br><br>" + GetLocStringByKeyExt(descript) + "<br><br>" + fluff + "<br><br>" + "fixme_Price: " + price;
}

function GetBaseStatLocalizedName(stat : EBaseCharacterStats) : string
{
	switch(stat)
	{
		case BCS_Vitality : return GetLocStringByKeyExt("vitality");
		case BCS_Stamina : return GetLocStringByKeyExt("stamina");
		case BCS_Toxicity : return GetLocStringByKeyExt("toxicity");
		case BCS_Focus : return GetLocStringByKeyExt("focus");
		case BCS_Air : return GetLocStringByKeyExt("air");
		case BCS_Panic : return GetLocStringByKeyExt("panic");
		default : return "";
	}
}

function GetBaseStatLocalizedDesc(stat : EBaseCharacterStats) : string
{
	switch(stat)
	{
		case BCS_Vitality : return GetLocStringByKeyExt("vitality_desc");
		case BCS_Stamina : return GetLocStringByKeyExt("stamina_desc");
		case BCS_Toxicity : return GetLocStringByKeyExt("toxicity_desc");
		case BCS_Focus : return GetLocStringByKeyExt("focus_desc");
		case BCS_Air : return GetLocStringByKeyExt("air_desc");
		case BCS_Panic : return GetLocStringByKeyExt("panic_desc");
		default : return "";
	}
}

function GetRegenStatLocalizedName(stat : ECharacterRegenStats) : string
{
	switch(stat)
	{
		case CRS_Vitality : return GetLocStringByKeyExt("vitalityRegen");
		case CRS_Stamina : return GetLocStringByKeyExt("staminaRegen");
		default : return "";
	}
}

function GetRegenStatLocalizedDesc(stat : ECharacterRegenStats) : string
{
	switch(stat)
	{
		case CRS_Vitality : return GetLocStringByKeyExt("vitalityRegen_desc");
		case CRS_Stamina : return GetLocStringByKeyExt("staminaRegen_desc");
		default : return "";
	}
}

function GetPowerStatLocalizedName(stat : ECharacterPowerStats) : string
{
	switch(stat)
	{
		case CPS_AttackPower : return GetLocStringByKeyExt("attack_power");
		case CPS_SpellPower : return GetLocStringByKeyExt("spell_power");
		default : return "";
	}
}

function GetPowerStatLocalizedDesc(stat : ECharacterPowerStats) : string
{
	switch(stat)
	{
		case CPS_AttackPower : return GetLocStringByKeyExt("attack_power_desc");
		case CPS_SpellPower : return GetLocStringByKeyExt("spell_power_desc");
		default : return "";
	}
}

function GetResistStatLocalizedName(s : ECharacterDefenseStats, isPointResistance : bool) : string
{
	if(isPointResistance)
	{
		switch(s)
		{
			case CDS_PhysicalRes :	return GetLocStringByKeyExt("physical_resistance");
			case CDS_PoisonRes :	return GetLocStringByKeyExt( "poison_resistance");
			case CDS_FireRes :		return GetLocStringByKeyExt( "fire_resistance");
			case CDS_FrostRes :		return GetLocStringByKeyExt( "frost_resistance");
			case CDS_ShockRes :		return GetLocStringByKeyExt( "shock_resistance");
			case CDS_ForceRes :		return GetLocStringByKeyExt( "force_resistance");
			default :				return "";
		}
	}
	else
	{
		switch(s)
		{
			case CDS_PhysicalRes :	return GetLocStringByKeyExt( "physical_resistance_perc");
			case CDS_BleedingRes : 	return GetLocStringByKeyExt( "bleeding_resistance_perc");
			case CDS_PoisonRes :	return GetLocStringByKeyExt( "poison_resistance_perc");
			case CDS_FireRes :		return GetLocStringByKeyExt( "fire_resistance_perc");
			case CDS_FrostRes :		return GetLocStringByKeyExt( "frost_resistance_perc");
			case CDS_ShockRes :		return GetLocStringByKeyExt( "shock_resistance_perc");
			case CDS_ForceRes :		return GetLocStringByKeyExt( "force_resistance_perc");
			case CDS_WillRes :		return GetLocStringByKeyExt( "will_resistance_perc");
			case CDS_BurningRes : 	return GetLocStringByKeyExt( "burning_resistance_perc");
			default :				return "";
		}
	}
}

function GetResistStatLocalizedDesc(s : ECharacterDefenseStats, isPointResistance : bool) : string
{
	if(isPointResistance)
	{
		switch(s)
		{
			case CDS_PhysicalRes :	return GetLocStringByKeyExt( "physical_resistance_desc");
			case CDS_PoisonRes :	return GetLocStringByKeyExt( "poison_resistance_desc");
			case CDS_FireRes :		return GetLocStringByKeyExt( "fire_resistance_desc");
			case CDS_FrostRes :		return GetLocStringByKeyExt( "frost_resistance_desc");
			case CDS_ShockRes :		return GetLocStringByKeyExt( "shock_resistance_desc");
			case CDS_ForceRes :		return GetLocStringByKeyExt( "force_resistance_desc");
			default :				return "";
		}
	}
	else
	{
		switch(s)
		{
			case CDS_PhysicalRes :	return GetLocStringByKeyExt( "physical_resistance_perc_desc");
			case CDS_BleedingRes : 	return GetLocStringByKeyExt( "bleeding_resistance_perc_desc");
			case CDS_PoisonRes :	return GetLocStringByKeyExt( "poison_resistance_perc_desc");
			case CDS_FireRes :		return GetLocStringByKeyExt( "fire_resistance_perc_desc");
			case CDS_FrostRes :		return GetLocStringByKeyExt( "frost_resistance_perc_desc");
			case CDS_ShockRes :		return GetLocStringByKeyExt( "shock_resistance_perc_desc");
			case CDS_ForceRes :		return GetLocStringByKeyExt( "force_resistance_perc_desc");
			case CDS_WillRes :		return GetLocStringByKeyExt( "will_resistance_perc_desc");
			case CDS_BurningRes : 	return GetLocStringByKeyExt( "burning_resistance_perc_desc");
			default :				return "";
		}
	}
}


function HasLolcalizationTags(s : string) : bool
{
	return StrFindFirst(s, "<<") >= 0;
}

function GetIconByPlatform(tag : string) : string
{
	var icon 	  : string;
	var isGamepad : bool;
	
	isGamepad = theInput.LastUsedGamepad() || theInput.GetLastUsedGamepadType() == IDT_Steam;
	
	if (tag == "GUI_GwintPass")
	{
		if(isGamepad)
			icon = GetIconForKey(IK_Pad_Y_TRIANGLE, true);
		else
			icon = GetIconForKey(IK_Space);
	}
	if (tag == "GUI_GwintChoose")
	{
		if(isGamepad)
			icon = GetIconForKey(IK_Pad_A_CROSS, true);
		else
			icon = GetIconForKey(IK_Enter);
	}
	else if(tag == "GUI_GwintZoom")
	{
		if(isGamepad)
			icon = GetIconForKey(IK_Pad_RightTrigger);
		else
			icon = GetIconForKey(IK_Shift);
	}
	else if (tag == "GUI_GwintLeader")
	{
		if(isGamepad)
			icon = GetIconForKey(IK_Pad_X_SQUARE, true);
		else
			icon = GetIconForKey(IK_X);	
	}
	else if (tag == "GUI_Close")
	{
		if(isGamepad)
			icon = GetIconForKey(IK_Pad_B_CIRCLE, true);
		else
			icon = GetIconForKey(IK_Escape);	
	}
	
	return icon;
}





function ReplaceTagsToIcons(s : string) : string
{
	var start, stop, keyIdx, commaIdx : int;
	var tag, icon, keyIdxAsString, bracketOpeningSymbol, bracketClosingSymbol : string;
	var keys : array<EInputKey>;
	
	var alterAttackKeysPC 	    : array< EInputKey >;
	var attackModKeysPC 	    : array< EInputKey >;
	
	while(true)
	{
		
		start = StrFindFirst(s, "<<");
		if(start < 0)
			break;
		
		stop = StrFindFirst(s, ">>");
		if(stop < 0)
			break;
			
		
		if(stop < start)
		{
			
			s = StrReplace(s, ">>", "");
			continue;
		}
		
		
		tag = StrMid(s, start+2, stop-start-2);
				
		
		commaIdx = StrFindFirst(tag, ",");
		if(commaIdx >= 0)
		{
			keyIdxAsString = StrRight(tag, StrLen(tag) - commaIdx - 1);
			keyIdx = StringToInt(keyIdxAsString);
			tag = StrLeft(tag, commaIdx);
		}
		else
		{
			keyIdx = 0;
		}
		
		
		
		
		
		
		
		
		
		
		
		if (tag == "PCAlternate")
		{
			keys.Clear();
			attackModKeysPC.Clear();
			alterAttackKeysPC.Clear();
			
			theInput.GetPCKeysForAction('AttackWithAlternateHeavy', keys );
			theInput.GetPCKeysForAction('AttackWithAlternateLight', alterAttackKeysPC );
			theInput.GetPCKeysForAction('PCAlternate', attackModKeysPC );
			
			if (attackModKeysPC.Size() > 0 && alterAttackKeysPC.Size() > 0 && attackModKeysPC[0] != IK_None && alterAttackKeysPC[0] != IK_None)
			{
				icon = GetIconForKey(attackModKeysPC[0]);
			}
			else			
			{
				icon = "##"; 
			}
		}
		else
		if (tag == "AttackWithAlternateLight_mod" || tag == "SpecialAttackWithAlternateLight_mod")
		{
			
			
			
			keys.Clear();
			attackModKeysPC.Clear();
			alterAttackKeysPC.Clear();
			
			theInput.GetPCKeysForAction('AttackWithAlternateHeavy', keys );
			theInput.GetPCKeysForAction('AttackWithAlternateLight', alterAttackKeysPC );
			theInput.GetPCKeysForAction('PCAlternate', attackModKeysPC );
			
			if (attackModKeysPC.Size() > 0 && alterAttackKeysPC.Size() > 0 && attackModKeysPC[0] != IK_None && alterAttackKeysPC[0] != IK_None)
			{
				icon = GetIconForKey(alterAttackKeysPC[0]);
			}
			else
			if (keys.Size() > 0 && keys[0] != IK_None)
			{
				icon = GetIconForKey(keys[0]);
			}
			else
			{
				keys.Clear();
				theInput.GetCurrentKeysForActionStr(tag, keys);
				theInput.GetPCKeysForAction('AttackWithAlternateLight', keys );
				if (keys.Size() > 0 && keys[0] != IK_None) 
				{
					icon = GetIconForKey(keys[0]);
				}
				else
				{
					icon = "##";
				}
			}
			
		}
		else
		if (tag == "AttackWithAlternateLight" || tag == "SpecialAttackWithAlternateLight")
		{
			keys.Clear();
			theInput.GetCurrentKeysForActionStr(tag, keys);
			theInput.GetPCKeysForAction('AttackWithAlternateLight', keys );
			
			if (keys.Size() > 0 && keys[0] != IK_None) 
			{
				icon = GetIconForKey(keys[0]);
			}
			else
			{
				alterAttackKeysPC.Clear();
				attackModKeysPC.Clear();
				
				theInput.GetPCKeysForAction('AttackWithAlternateHeavy', alterAttackKeysPC );
				theInput.GetPCKeysForAction('PCAlternate', attackModKeysPC );
				
				if (attackModKeysPC.Size() > 0 && alterAttackKeysPC.Size() > 0 && attackModKeysPC[0] != IK_None && alterAttackKeysPC[0] != IK_None)
				{
					icon = GetIconForKey(alterAttackKeysPC[0]) + " + " + GetIconForKey(attackModKeysPC[0]);
				}
				else
				{
					icon = "##"; 
				}
			}
		}
		else 
		if (tag == "AttackWithAlternateHeavy" || tag == "SpecialAttackWithAlternateHeavy")
		{
			keys.Clear();
			alterAttackKeysPC.Clear();
			attackModKeysPC.Clear();
			
			theInput.GetPCKeysForAction('AttackWithAlternateHeavy', keys );
			theInput.GetPCKeysForAction('AttackWithAlternateLight', alterAttackKeysPC );
			theInput.GetPCKeysForAction('PCAlternate', attackModKeysPC );
			
			if (attackModKeysPC.Size() > 0 && alterAttackKeysPC.Size() > 0 && attackModKeysPC[0] != IK_None && alterAttackKeysPC[0] != IK_None)
			{
				icon = GetIconForKey(alterAttackKeysPC[0]);
			}
			else
			{
				icon = GetIconForKey(keys[0]);
			}
		}
		else
		{
			keys.Clear();
			theInput.GetCurrentKeysForActionStr(tag, keys);
			
			
			if(keys.Size() == 0)
			{
				
				icon = GetIconForTag(tag);
			}
			else
			{
				
				icon = GetIconForKey(keys[keyIdx]);
			}
		}
		
		if(theGame.IsLanguageArabic())
			icon = icon + " ";
		
		
		if(StrStartsWith(icon, "##"))
		{
			
			GetBracketSymbols(bracketOpeningSymbol, bracketClosingSymbol);
			icon = " " + bracketOpeningSymbol + "<font color=\"" + theGame.params.KEYBOARD_KEY_FONT_COLOR + "\">" + GetLocStringByKeyExt("input_device_key_name_IK_none") + "</font>" + bracketClosingSymbol + " ";
			s = StrReplaceAll(s, "<<" + tag + ">>", icon);
		}
		else if(commaIdx >= 0)
		{
			s = StrReplaceAll(s, "<<" + tag + "," + keyIdxAsString +">>", icon);
		}
		else
		{
			s = StrReplaceAll(s, "<<" + tag + ">>", icon);
		}
	}

	return s;
}



function GetIconForKey(key : EInputKey, optional isGuiKey:bool) : string
{
	var inGameConfigWrapper : CInGameConfigWrapper;
	var configValue : bool;
	
	var icon, keyText        : string;
	var bracketOpeningSymbol : string;
	var bracketClosingSymbol : string;
	
	if (isGuiKey && (key == IK_Pad_A_CROSS || key == IK_Pad_B_CIRCLE))
	{
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		configValue = inGameConfigWrapper.GetVarValue('Controls', 'SwapAcceptCancel');
		if (configValue )
		{
			if (key == IK_Pad_A_CROSS)
			{
				key = IK_Pad_B_CIRCLE;
			}
			else
			if (key == IK_Pad_B_CIRCLE)
			{
				key = IK_Pad_A_CROSS;
			}
		}
	}
	
	
	icon = GetIconNameForKey(key);
	
	GetBracketSymbols(bracketOpeningSymbol, bracketClosingSymbol);
	if(icon == "")
	{
		
		switch(key)
		{
			
			case IK_Backspace:
			case IK_Tab:
			case IK_Enter:
			case IK_Shift:
			case IK_Ctrl:
			case IK_Alt:
			case IK_Pause:
			case IK_CapsLock:
			case IK_Escape:
			case IK_Space:
			case IK_PageUp:
			case IK_PageDown:
			case IK_End:
			case IK_Home:
			case IK_Left:
			case IK_Up:
			case IK_Right:
			case IK_Down:
			case IK_Select:
			case IK_Print:
			case IK_Execute:
			case IK_PrintScrn:
			case IK_Insert:
			case IK_Delete:
			case IK_NumPad0:
			case IK_NumPad1:
			case IK_NumPad2:
			case IK_NumPad3:
			case IK_NumPad4:
			case IK_NumPad5:
			case IK_NumPad6:
			case IK_NumPad7:
			case IK_NumPad8:
			case IK_NumPad9:
			case IK_NumStar:
			case IK_NumPlus:
			case IK_Separator:
			case IK_NumMinus:
			case IK_NumPeriod:
			case IK_NumSlash:
			case IK_NumLock:
			case IK_ScrollLock:
			case IK_LShift:
			case IK_RShift:
			case IK_LControl:
			case IK_RControl:
			case IK_Mouse4:
			case IK_Mouse5:
			case IK_Mouse6:
			case IK_Mouse7:
			case IK_Mouse8:
				keyText = GetLocStringByKeyExt("input_device_key_name_" + key);
				break;
				
			
			default:
				keyText = StrChar(key);
		}
		icon = " " + bracketOpeningSymbol + "<font color=\"" + theGame.params.KEYBOARD_KEY_FONT_COLOR + "\">" + keyText + "</font>" + bracketClosingSymbol + " ";
	}
	else
	{
		icon = GetHTMLForICO(icon);
	}
	
	return icon;
}

function GetHoldLabel():string
{
	var bracketOpeningSymbol : string;
	var bracketClosingSymbol : string;
	
	GetBracketSymbols(bracketOpeningSymbol, bracketClosingSymbol);
	return "<font color=\"#CD7D03\">" + bracketOpeningSymbol + GetLocStringByKeyExt("ControlLayout_hold") + bracketClosingSymbol + "</font>";
}

function GetBracketSymbols(out openingSymbol:string, out closingSymbol:string, optional isRoundBrackets:bool):void
{
	var language, audioLanguage : string;
	
	theGame.GetGameLanguageName(audioLanguage,language);
	if (language == "AR")
	{
		openingSymbol = "";
		closingSymbol = "";
	}
	else
	{
		if (isRoundBrackets)
		{
			openingSymbol = "(";
			closingSymbol = ")";
		}
		else
		{
			openingSymbol = "[";
			closingSymbol = "]";
		}
	}
}


function GetHTMLForICO(icon : string) : string
{
	
	
	
	if (icon == "Mouse_LeftBtn" || icon == "Mouse_RightBtn" || icon == "Mouse_MiddleBtn" || icon == "Mouse_ScrollUp" || icon == "Mouse_ScrollDown")
	{
		icon = " <img src=\"" + icon + ".png\" vspace=\"-10\" />";
	}
	else
	{
		icon = " <img src=\"" + icon + ".png\" vspace=\"-20\" />";
	}

	return icon;
}

function GetHTMLForMouseICO(icon : string) : string
{
	
	icon = " <img src=\"" + icon + ".png\" vspace=\"-10\" />";

	return icon;
}

function GetHTMLForItemICO(icon : string, optional vspace : float) : string
{
	
	if (vspace == 0)
	{
		icon = " <img src=\"" + icon + ".png\" vspace=\"-10\" />";
	}
	else
	{
		icon = " <img src=\"" + icon + ".png\" vspace=\"" + NoTrailZeros(vspace) + "\" />";
	}

	return icon;
}


function GetBookTexture(tag : string) : string
{
	var retStr : string;
	
	retStr = "<p align=\"center\">"+" <img src=\"" + tag + ".png\" vspace=\"-20\" align=\"middle\" /> "+ "</p>";

	return retStr;
}


function GetIconForTag(tag : string) : string
{	
	var icon : string;
	
	if(tag == "GUI_LootPanel_LootAll")				icon = GetIconForKey(IK_Pad_A_CROSS, true);
	else if(tag == "GUI_PC_LootPanel_LootAll")			icon = GetIconForKey(IK_Space);
	else if(tag == "GI_AxisRight")					icon = GetHTMLForICO(GetPadFileName("RS"));
	else if(tag == "GI_AxisLeft")					icon = GetHTMLForICO(GetPadFileName("LS"));
	else if(tag == "GUI_LootPanel_Close")			icon = GetIconForKey(IK_Pad_B_CIRCLE, true);
	else if(tag == "GUI_PC_LootPanel_Close")		icon = GetIconForKey(IK_Escape);
	else if(tag == "GUI_MoveDown")					icon = GetIconForKey(IK_Pad_DigitDown);
	else if(tag == "GUI_MoveUp")					icon = GetIconForKey(IK_Pad_DigitUp);
	else if(tag == "GUI_Navigate")					icon = GetHTMLForICO(GetPadFileName("LS"));
	else if(tag == "GUI_SwitchTabLeft")				icon = GetIconForKey(IK_Pad_LeftTrigger);
	else if(tag == "GUI_SwitchTabRight")			icon = GetIconForKey(IK_Pad_RightTrigger);
	else if(tag == "GUI_SwitchPageLeft")			icon = GetIconForKey(IK_Pad_LeftShoulder);
	else if(tag == "GUI_SwitchPageRight")			icon = GetIconForKey(IK_Pad_RightShoulder);
	else if(tag == "GUI_SwitchInnerTabLeft")		icon = GetIconForKey(IK_Pad_LeftShoulder);
	else if(tag == "GUI_SwitchInnerTabRight")		icon = GetIconForKey(IK_Pad_RightShoulder);
	else if(tag == "GUI_Select")					icon = GetIconForKey(IK_Pad_A_CROSS, true);
	else if(tag == "GUI_Select2")					icon = GetIconForKey(IK_Pad_X_SQUARE, true);	
	else if(tag == "GUI_NavigateUpDown")			icon = GetIconForKey(IK_Pad_LeftAxisY);
	else if(tag == "ICO_DialogAxii")				icon = GetHTMLForItemICO("ICO_AxiiIcoPin");
	else if(tag == "ICO_DialogShop")				icon = GetHTMLForItemICO("ICO_ShopIcoDialog");	
	else if(tag == "ICO_QuestGiver")				icon = GetHTMLForItemICO("ICO_QuestIcoPin");
	else if(tag == "ICO_DialogGwint")				icon = GetHTMLForItemICO("ICO_DialogGwint");
	else if(tag == "ICO_NoticeBoard" || tag == "ICO_Noticeboard")	icon = GetHTMLForItemICO("ICO_NoticeBoard");
	else if(tag == "PAD_LSUp")						icon = GetHTMLForICO(GetPadFileName("LS_Up"));
	else if(tag == "PAD_LS_LeftRight")				icon = GetHTMLForICO(GetPadFileName("LS_LeftRight"));
	else if(tag == "PAD_RS_LeftRight")				icon = GetHTMLForICO(GetPadFileName("RS_LeftRight"));
	else if(tag == "Cross_UpDown")  				icon = GetHTMLForICO(GetPadFileName("Cross_UpDown"));
	else if(tag == "PAD_RS_UpDown")					icon = GetHTMLForICO(GetPadFileName("RS_UpDown"));
	else if(tag == "ICO_DialogEnd")					icon = GetHTMLForItemICO("ICO_DialogEnd");
	else if(tag == "GUI_RS_Press")					icon = GetHTMLForICO(GetPadFileName("RS_PRESS"));
	else if(tag == "GUI_DPAD_LeftRight")			icon = GetHTMLForICO(GetPadFileName("Cross_LeftRight"));
	else if(tag == "IK_LeftMouse")					icon = GetIconForKey(IK_LeftMouse);
	else if(tag == "IK_RightMouse")					icon = GetIconForKey(IK_RightMouse);
	else if(tag == "Mouse")							icon = GetHTMLForICO("Mouse_Pan");
	else if(tag == "GUI_PC_Close")					icon = GetIconForKey(IK_Escape);
	else
	{
		
		return GetIconOrColorForTag2(tag);
	}
	
	if(icon == "")
	{
		LogLocalization("GetIconForTag: cannot find icon for tag <<" + tag + ">>");
		icon = "##_" + tag + "_##";
	}
		
	return icon;
}

function GetIconOrColorForTag2(tag : string) : string
{
	var icon : string;
	
	if(tag == "ICO_ActiveQuestPin")					icon = GetHTMLForItemICO("ICO_ActiveQuestPin");
	else if(tag == "ICO_NewQuest")					icon = GetHTMLForItemICO("ICO_NewQuest");
	else if(tag == "ICO_EP1Quest")					icon = GetHTMLForItemICO("ICO_EP1Quest", -25);
	else if(tag == "ICO_Destructible")				icon = GetHTMLForItemICO("ICO_Destructible");
	else if(tag == "ICO_BoatFastTravel")			icon = GetHTMLForItemICO("ICO_minimap_harbor"); 
	else if(tag == "ICO_Overencumbered")			icon = GetHTMLForItemICO("ICO_Overencumbered");
	else if(tag == "ICO_UnknownPOI")				icon = GetHTMLForItemICO("ICO_UnknownPOI");
	else if(tag == "ICO_ThunderboltPotion")			icon = GetHTMLForItemICO("ICO_ThunderboltPotion");
	else if(tag == "ICO_ArmorUpgrade")				icon = GetHTMLForItemICO("ICO_ArmorUpgrade");
	else if(tag == "ICO_Rune")						icon = GetHTMLForItemICO("ICO_Rune");
	else if(tag == "ICO_Skull")						icon = GetHTMLForItemICO("ICO_Skull");
	else if(tag == "ICO_DungeonCrawl")			    icon = GetHTMLForItemICO("ICO_DungeonCrawl");
	else if(tag == "ICO_ShopMapPin")				icon = GetHTMLForItemICO("ICO_ShopIcoPin");
	else if(tag == "ICO_Enchanter")					icon = GetHTMLForItemICO("ICO_Enchanter", -2);
	else if(tag == "ICO_Cammerlengo")				icon = GetHTMLForItemICO("ICO_bob_cammerlengo");
	else if(tag == "ICO_DyeMerchant")				icon = GetHTMLForItemICO("ICO_bob_dye_merchant");
	else if(tag == "ICO_HansaHideout")				icon = GetHTMLForItemICO("ICO_bob_hansa_hideout");
	else if(tag == "ICO_HansaRunner")				icon = GetHTMLForItemICO("ICO_bob_hansa_runner");
	else if(tag == "ICO_HansaSignal")				icon = GetHTMLForItemICO("ICO_bob_hansa_signal");
	else if(tag == "ICO_InfestedVineyard")			icon = GetHTMLForItemICO("ICO_bob_infested_vineyard");
	else if(tag == "ICO_KnightErrant")				icon = GetHTMLForItemICO("ICO_bob_knight_errant");
	else if(tag == "ICO_Plegmund")					icon = GetHTMLForItemICO("ICO_bob_plegmund");
	else if(tag == "ICO_WineContract")				icon = GetHTMLForItemICO("ICO_wine_contract");
	else if(tag == "ICO_WineMerchant")				icon = GetHTMLForItemICO("ICO_bob_wine_merchant");
	else if(tag == "ICO_Map_Pin_Normal")			icon = GetHTMLForItemICO("ICO_custom_pin_waypoint");
	else if(tag == "ICO_Map_Pin_Special1")			icon = GetHTMLForItemICO("ICO_custom_pin_danger");
	else if(tag == "ICO_Map_Pin_Special2")			icon = GetHTMLForItemICO("ICO_custom_pin_mark");
	else if(tag == "ICO_Map_Pin_Special3")			icon = GetHTMLForItemICO("ICO_custom_pin_info");
	else if(tag == "ICO_ArchMaster")				icon = GetHTMLForItemICO("ICO_bob_archmaster");
	else if(tag == "GUI_Ingredient_Unfold_Icon")	icon = GetHTMLForItemICO("ICO_crafting_indicator");
	else if(tag == "ICO_Vermentino")				icon = GetHTMLForItemICO("ICO_vermentino");
	else if(tag == "ICO_Coronata")					icon = GetHTMLForItemICO("ICO_coronata");
	else if(tag == "ICO_Belgaard")					icon = GetHTMLForItemICO("ICO_belgaard");
	else if(tag == "ICO_Mutagen_Table")				icon = GetHTMLForItemICO("ICO_mutagen_table");
	
	
	else if(tag == "IK_Tab")						icon = GetIconForKey(IK_Tab);
	else if( tag == "GUI_PAD_Preview" )				icon = GetIconForKey( IK_Pad_A_CROSS, true );
	else if( tag == "GUI_PC_Preview" )				icon = GetIconForKey( IK_E );
	else if( tag == "ICO_POI_EP2_1" )				icon = GetHTMLForItemICO( "ICO_POI_EP2_1", -2 );
	else if( tag == "ICO_POI_EP2_2" )				icon = GetHTMLForItemICO( "ICO_POI_EP2_2", -2 );	
	else
	{
		
		return GetIconOrColorForTag3(tag);
	}
	
	return icon;
}

function GetIconOrColorForTag3(tag : string) : string
{
	var inGameConfigWrapper : CInGameConfigWrapper;
	var configValue : string;
	var icon : string;
	var isGamepad : bool;
	
	isGamepad = theInput.LastUsedGamepad() || theInput.GetLastUsedGamepadType() == IDT_Steam;
	
	if(tag == "ICO_Armorer")						icon = GetHTMLForItemICO("ICO_minimap_armorer");
	else if(tag == "ICO_Smith")						icon = GetHTMLForItemICO("ICO_minimap_blacksmith");
	else if(tag == "ICO_Herbalist")					icon = GetHTMLForItemICO("ICO_minimap_herbalist");
	else if(tag == "ICO_Alchemist")					icon = GetHTMLForItemICO("ICO_minimap_alchemist");
	else if(tag == "ICO_PlaceOfPower")				icon = GetHTMLForItemICO("ICO_place_of_power");
	else if(tag == "ICO_MonsterNest")				icon = GetHTMLForItemICO("ICO_minimap_monster_nest");
	else if(tag == "ICO_RepairArmor")				icon = GetHTMLForItemICO("ICO_minimap_repair");
	else if(tag == "ICO_RepairWeapons")				icon = GetHTMLForItemICO("ICO_minimap_repair_whetstone");
	else if(tag == "ICO_Harbor")					icon = GetHTMLForItemICO("ICO_minimap_harbor");
	else if(tag == "GUI_PC_Select")					icon = GetIconForKey(IK_Enter);
	else if(tag == "GUI_PC_SwitchPageLeft")			icon = GetIconForKey(IK_PageUp);
	else if(tag == "GUI_PC_SwitchPageRight")		icon = GetIconForKey(IK_PageDown);
	else if(tag == "ICO_HiddenTreasure")			icon = GetHTMLForItemICO("ICO_TresureHunt");
	else if(tag == "ICO_Dungeon")					icon = GetHTMLForItemICO("ICO_cave_entrance");
	else if(tag == "ICO_MerchantRescue")			icon = GetHTMLForItemICO("ICO_Cage");
	else if(tag == "ICO_SpoilsOfWar")				icon = GetHTMLForItemICO("ICO_spoils_of_war");
	else if(tag == "ICO_Contraband")				icon = GetHTMLForItemICO("ICO_contraband");
	else if(tag == "ICO_BossAndTreasure")			icon = GetHTMLForItemICO("ICO_boss_and_treasure");
	else if(tag == "ICO_TownRescue")				icon = GetHTMLForItemICO("ICO_town_rescue");
	else if(tag == "ICO_BanditCampfire")			icon = GetHTMLForItemICO("ICO_bandit_campfire");
	else if(tag == "ICO_FastTravel")				icon = GetHTMLForItemICO("ICO_minimap_fast_travel");
	else if(tag == "GUI_LS_Press")					icon = GetHTMLForICO(GetPadFileName("LS_Thumb"));
	else if(tag == "ICO_Stash")						icon = GetHTMLForItemICO("ICO_Stash");
	else if( tag == "IK_Pad_LeftThumb" )								icon = GetIconForKey( IK_Pad_LeftThumb, true );
	else if( tag == "IK_MiddleMouse" )									icon = GetIconForKey( IK_MiddleMouse );
	else if( tag == "GUI_Preview" && theInput.LastUsedGamepad() )		icon = GetIconForKey( IK_Pad_X_SQUARE, true );
	else if( tag == "GUI_Preview" && !theInput.LastUsedGamepad() )		icon = GetIconForKey( IK_X );
	else if( tag == "GUI_Sort" && theInput.LastUsedGamepad() )			icon = GetIconForKey( IK_Pad_RightThumb, true );
	else if( tag == "GUI_Sort" && !theInput.LastUsedGamepad() )			icon = GetIconForKey( IK_F );
	else if( tag == "GUI_Geekpage" && theInput.LastUsedGamepad() )		icon = GetIconForKey( IK_Pad_RightTrigger, true );
	else if( tag == "GUI_Geekpage" && !theInput.LastUsedGamepad() )		icon = GetIconForKey( IK_C );
	else if(tag == "GUI_Close" || tag == "GUI_GwintPass" || tag == "GUI_GwintZoom" || tag == "GUI_GwintChoose" || tag == "GUI_GwintLeader")
	{
		icon = GetIconByPlatform(tag);
	}
	else if(tag == "Color_Gwint")
	{
		icon = " <font color=\"#CD7D03\">"; 
	}
	else if(tag == "Color_Gwint2")
	{
		icon = " <font color=\"#EF1919\">"; 
	}
	else if(tag == "End_Color")
	{
		icon = "</font> ";
	}
	else if (tag == "GUI_GwintFactionLeft")
	{
		if(isGamepad)
			icon = GetIconForKey(IK_Pad_LeftShoulder);
		else
			icon = GetIconForKey(IK_1);
	}
	else if (tag == "GUI_GwintFactionRight")
	{
		if(isGamepad)
			icon = GetIconForKey(IK_Pad_RightShoulder);
		else
			icon = GetIconForKey(IK_3);
	}
	else if (tag == "GUI_GwintPass")
	{
		if(isGamepad)
			icon = GetIconForKey(IK_Pad_Y_TRIANGLE);
		else
			icon = GetIconForKey(IK_Escape);
	}
	else if( tag == "GUI_Mutations_Open" )
	{
		if(isGamepad)
		{
			icon = GetIconForKey( IK_Pad_Y_TRIANGLE );
		}
		else
		{
			icon = GetIconForKey( IK_C );
		}
	}
	else if( tag == "GUI_Mutation_Research" )
	{
		if( isGamepad )
		{
			icon = GetIconForKey( IK_Pad_A_CROSS, true );
		}
		else
		{
			icon = GetIconForKey( IK_Space );
		}
	}
	else if( tag == "GUI_Mutations_Develop" )
	{
		if( isGamepad )
		{
			icon = GetIconForKey( IK_Pad_X_SQUARE );
		}
		else
		{
			icon = GetIconForKey( IK_Space );
		}
	}
	else if( tag == "GUI_Mutations_Equip" )
	{
		if( isGamepad )
		{
			icon = GetIconForKey( IK_Pad_A_CROSS, true );
		}
		else
		{
			icon = GetIconForKey( IK_Enter );
		}
	}
	else if( tag == "GUI_Mutations_Close" )
	{
		if( isGamepad )
		{
			icon = GetIconForKey( IK_Pad_B_CIRCLE, true );
		}
		else
		{
			icon = GetIconForKey( IK_Escape );
		}
	}
	else if( tag == "GUI_Mutations_Research_Accept" )
	{
		if( isGamepad )
		{
			icon = GetIconForKey( IK_Pad_A_CROSS, true );
		}
		else
		{
			icon = GetIconForKey( IK_Enter );
		}
	}
	else if( tag == "GUI_Read_Book" )
	{
		if( isGamepad )
		{
			icon = GetIconForKey( IK_Pad_RightThumb );
		}
		else
		{
			icon = GetIconForKey( IK_V );
		}
	}
	else if( tag == "GUI_Inv_Read_Book" )
	{
		if( isGamepad )
		{
			icon = GetIconForKey( IK_Pad_A_CROSS, true );
		}
		else
		{
			icon = GetIconForKey( IK_E );
		}
	}
	else if( tag == "GUI_Book_Read_Left_Right" )
	{
		icon = GetHTMLForICO( GetPadFileName( "LS_LeftRight" ) );
	}
	else if( tag == "GUI_Book_Read_Left" )
	{
		icon = GetIconForKey( IK_A );
	}
	else if( tag == "GUI_Book_Read_Right" )
	{
		icon = GetIconForKey( IK_D );
	}
	else if( tag == "GUI_Crafting_Buy" )
	{
		if( isGamepad )
		{
			icon = GetIconForKey( IK_Pad_Y_TRIANGLE );
		}
		else
		{
			icon = GetIconForKey( IK_RightMouse );
		}
	}
	else if( tag == "GUI_Worldmap_Zoom" )
	{
		if( isGamepad )
		{
			icon = GetIconForKey( IK_Pad_RightTrigger );
		}
		else
		{
			icon = GetIconForKey( IK_Z );
		}
	}
	else if( tag == "GUI_Map_To_Continent" )
	{
		if( isGamepad )
		{
			icon = GetIconForKey( IK_Pad_Y_TRIANGLE );
		}
		else
		{
			icon = GetIconForKey( IK_MiddleMouse );
		}
	}
	else if( tag == "GUI_Continent_To_Hub" )
	{
		if( isGamepad )
		{
			icon = GetIconForKey( IK_Pad_Y_TRIANGLE );
		}
		else
		{
			icon = GetIconForKey( IK_MiddleMouse );
		}
	}
	else if( tag == "GUI_Map_To_Any_Hub" )
	{
		if( isGamepad )
		{
			icon = GetIconForKey( IK_Pad_A_CROSS, true );
		}
		else
		{
			icon = GetIconForKey( IK_LeftMouse );
		}
	}
	else if( tag == "GUI_Place_Pin" || tag == "GUI_PC_Open_Pin_Menu" )
	{
		if( isGamepad )
		{
			icon = GetIconForKey( IK_Pad_X_SQUARE );
		}
		else
		{
			icon = GetIconForKey( IK_RightMouse );
		}
	}
	else if( tag == "GUI_PC_Select_Pin_Type" )
	{
		icon = GetHTMLForICO( "Mouse_Pan" );
	}
	else if( tag == "GUI_PC_Confirm_Pin_Type" )
	{
		icon = GetIconForKey( IK_LeftMouse );
	}
	else if( tag == "GUI_Pad_Open_Pin_Menu" )
	{
		icon = GetIconForKey( IK_Pad_X_SQUARE );
	}
	else if( tag == "GUI_Pad_Select_Pin_Type" )
	{
		icon = GetHTMLForICO( GetPadFileName( "LS_LeftRight" ) );
	}	
	else if( tag == "GUI_Radial_Swap_Items"  || tag == "GUI_Radial_Select_Bolts" )
	{
		if( isGamepad )
		{
			inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
			configValue = inGameConfigWrapper.GetVarValue( 'Controls', 'AlternativeRadialMenuInputMode' );
			
			if( configValue )
			{
				icon = GetHTMLForICO( GetPadFileName( "LS_LeftRight" ) );
			}
			else
			{
				icon = GetHTMLForICO( GetPadFileName( "RS_LeftRight" ) );
			}
		}
		else
		{
			icon = GetIconForKey( IK_MiddleMouse );
		}
	}
	else
	{
		
		return GetIconOrColorForTag4( tag );
	}
	
	return icon;
}

function GetIconOrColorForTag4( tag : string ) : string
{
	var icon : string;
	
	if( tag == "GUI_Map_Filters_Left" || tag == "GUI_Map_Filters_Pin_Left" )
	{
		if( theInput.LastUsedGamepad() )
		{
			icon = GetHTMLForICO( GetPadFileName( "Cross_Left" ) );
		}
		else
		{
			icon = GetIconForKey( IK_Left );
		}
	}
	else if( tag == "GUI_Map_Filters_Right" || tag == "GUI_Map_Filters_Pin_Right" )
	{
		if( theInput.LastUsedGamepad() )
		{
			icon = GetHTMLForICO( GetPadFileName( "Cross_Right" ) );
		}
		else
		{
			icon = GetIconForKey( IK_Right );
		}
	}
	else if( tag == "GUI_Map_Filters_Pin_Up" )
	{
		if( theInput.LastUsedGamepad() )
		{
			icon = GetHTMLForICO( GetPadFileName( "Cross_Up" ) );
		}
		else
		{
			icon = GetIconForKey( IK_Up );
		}
	}
	else if( tag == "GUI_Map_Filters_Pin_Down" )
	{
		if( theInput.LastUsedGamepad() )
		{
			icon = GetHTMLForICO( GetPadFileName( "Cross_Down" ) );
		}
		else
		{
			icon = GetIconForKey( IK_Down );
		}
	}
	else if( tag == "GUI_Map_Filters_Customize" )
	{
		if( theInput.LastUsedGamepad() )
		{
			icon = GetIconForKey( IK_Pad_LeftTrigger );
		}
	}
	else if( tag == "ICO_EP2NewQuest" )
	{
		icon = GetHTMLForItemICO("ICO_EP2Newquest");
	}
	else if( IsBookTextureTag(tag) )
	{
		icon = GetBookTexture(tag);
	}
		
	return icon;
}


function GetIconNameForKey(key : EInputKey) : string
{
	if(key == IK_Pad_A_CROSS)			return GetPadFileName("A");
	if(key == IK_Pad_B_CIRCLE)			return GetPadFileName("B");
	if(key == IK_Pad_X_SQUARE)			return GetPadFileName("X");
	if(key == IK_Pad_Y_TRIANGLE)		return GetPadFileName("Y");
	if(key == IK_Pad_LeftThumb)			return GetPadFileName("LS_Thumb");
	if(key == IK_Pad_RightThumb)		return GetPadFileName("RS_Thumb");
	if(key == IK_Pad_LeftShoulder)		return GetPadFileName("LB");
	if(key == IK_Pad_RightShoulder)		return GetPadFileName("RB");
	if(key == IK_Pad_LeftTrigger)		return GetPadFileName("LT");
	if(key == IK_Pad_RightTrigger)		return GetPadFileName("RT");
	if(key == IK_Pad_Start)				return GetPadFileName("Start");
	if(key == IK_Pad_Back_Select)		return GetPadFileName("Back");
	if(key == IK_Pad_DigitUp)			return GetPadFileName("Cross_Up");
	if(key == IK_Pad_DigitDown)			return GetPadFileName("Cross_Down");
	if(key == IK_Pad_DigitLeft)			return GetPadFileName("Cross_Left");
	if(key == IK_Pad_DigitRight)		return GetPadFileName("Cross_Right");
	if(key == IK_Pad_LeftAxisY)			return GetPadFileName("LS_Up_Down");
	if(key == IK_LeftMouse)				return "Mouse_LeftBtn";
	if(key == IK_RightMouse)			return "Mouse_RightBtn";
	if(key == IK_MiddleMouse)			return "Mouse_MiddleBtn";
	if(key == IK_MouseWheelUp)			return "Mouse_ScrollUp";
	if(key == IK_MouseWheelDown)		return "Mouse_ScrollDown";
	if(key == IK_PS4_TOUCH_PRESS)		return GetPadFileName("TouchPad");
	
	return "";
}


function GetPadFileName(type : string) : string
{
	var platformPrefix:string;
	
	if( theInput.GetLastUsedGamepadType() == IDT_PS4 
		|| theInput.GetLastUsedGamepadType() == IDT_PS5 )
	{
		
		switch(type)
		{
			case "LS" :					return "ICO_PlayS_L3";
			case "RS" :					return "ICO_PlayS_R3";
			case "LS_Thumb"	:			return "ICO_PlayS_L3_hold";
			case "RS_Thumb"	:			return "ICO_PlayS_R3_hold";
			case "RS_PRESS"	:			return "ICO_PlayS_R3_hold";
			case "LS_Up_Down" : 		return "ICO_PlayS_L3_scroll";			
			case "LS_LeftRight" : 		return "ICO_PlayS_L3_tabs";
			case "RS_UpDown" : 	  		return "ICO_PlayS_R3_scroll";
			case "RS_LeftRight" : 		return "ICO_PlayS_R3_tabs";
			case "RS_Up" : 				return "ICO_PlayS_R3_up";
			case "RS_Down" : 			return "ICO_PlayS_R3_down";
			case "LS_Up" : 				return "ICO_PlayS_L3_up";
			case "Cross_Right" : 		return "ICO_PlayS_dpad_right";
			case "Cross_Left" : 		return "ICO_PlayS_dpad_left";
			case "Cross_Up" : 			return "ICO_PlayS_dpad_up";
			case "Cross_Down" : 		return "ICO_PlayS_dpad_down";
			case "Cross_LeftRight" :  	return "ICO_PlayS_dpad_left_right";
			case "Cross_UpDown" :  		return "ICO_PlayS_dpad_up_down";
			case "Back" : 				return "ICO_PlayS_Share";
			case "Start" : 				return "ICO_PlayS_Touchpad";
			case "RT" : 				return "ICO_PlayS_R2";
			case "LT" : 				return "ICO_PlayS_L2";
			case "LB" : 				return "ICO_PlayS_L1";
			case "RB" : 				return "ICO_PlayS_R1";
			case "A" : 					return "ICO_PlayS_X";
			case "B" : 					return "ICO_PlayS_Circle";
			case "X" : 					return "ICO_PlayS_Square";
			case "Y" : 					return "ICO_PlayS_Triangle";
			case "TouchPad" :			return "ICO_PlayS_Touchpad";
		}
	}
	else
	{
		if (theInput.GetLastUsedGamepadType() == IDT_Steam)
		{
			platformPrefix = "_Steam_";
		}
		else
		{
			platformPrefix = "_Xbox_";
		}
		
		switch(type)
		{
			case "LS" :					return "ICO" + platformPrefix + "L";
			case "RS" :					return "ICO" + platformPrefix + "R";
			case "LS_Thumb"	:			return "ICO" + platformPrefix + "L_hold";
			case "RS_Thumb"	:			return "ICO" + platformPrefix + "R_hold";
			case "RS_PRESS"	:			return "ICO" + platformPrefix + "R_hold";
			case "LS_Up_Down" : 		return "ICO" + platformPrefix + "L_scroll";
			case "LS_LeftRight" : 		return "ICO" + platformPrefix + "L_tabs";
			case "RS_UpDown" : 		    return "ICO" + platformPrefix + "R_scroll";
			case "RS_LeftRight" :		return "ICO" + platformPrefix + "R_tabs";
			case "RS_Up" : 				return "ICO" + platformPrefix + "R_up";
			case "RS_Down" : 			return "ICO" + platformPrefix + "R_down";
			case "LS_Up" : 				return "ICO" + platformPrefix + "L_up";
			case "Cross_Right" : 		return "ICO" + platformPrefix + "dpad_right";
			case "Cross_Left" : 		return "ICO" + platformPrefix + "dpad_left";
			case "Cross_Up" : 			return "ICO" + platformPrefix + "dpad_up";
			case "Cross_Down" : 		return "ICO" + platformPrefix + "dpad_down";
			case "Cross_LeftRight" :  	return "ICO" + platformPrefix + "dpad_left_right";
			case "Cross_UpDown" :  		return "ICO" + platformPrefix + "dpad_up_down";
			case "Back" : 				return "ICO" + platformPrefix + "Back";
			case "Start" : 				return "ICO" + platformPrefix + "Start";
			case "RT" : 				return "ICO" + platformPrefix + "RT";
			case "LT" : 				return "ICO" + platformPrefix + "LT";
			case "LB" : 				return "ICO" + platformPrefix + "LB";
			case "RB" : 				return "ICO" + platformPrefix + "RB";
			case "A" : 					return "ICO" + platformPrefix + "A";
			case "B" : 					return "ICO" + platformPrefix + "B";
			case "X" : 					return "ICO" + platformPrefix + "X";
			case "Y" : 					return "ICO" + platformPrefix + "Y";
		}
	}
	
	return "";
}

exec function hintloc()
{
	var m_tutorialHintDataObj : W3TutorialPopupData;
	var str : string;
	
	theGame.GetTutorialSystem().TutorialStart(false);
	
	str = "Press <<Jump>> to jump, <<GUI_LootPanel_LootAll>> in lootpanel on pad to loot all. We also have shop icons like this: <<ICO_DialogShop>>";
	str = ReplaceTagsToIcons(str);
	
	m_tutorialHintDataObj = new W3TutorialPopupData in theGame;
	m_tutorialHintDataObj.managerRef = theGame.GetTutorialSystem();
	m_tutorialHintDataObj.scriptTag = 'aaa';
	m_tutorialHintDataObj.messageText = str;
	m_tutorialHintDataObj.duration = 5000;
	
	theGame.RequestMenu('TutorialPopupMenu', m_tutorialHintDataObj);
}





function DEBUG_Test_GetIconForTag(out text : string, tag : string)
{
	text += "<br/>" + tag + "     #" + GetIconForTag(tag) + "#";
}

function DEBUG_Test_GetIconNameForKey(out text : string, key : EInputKey)
{
	var ico : string;
	
	ico = GetIconNameForKey(key);
	text += "<br/>" + key + ", icoFile=" + ico + "      #" + GetHTMLForICO(ico) + "#";
}

exec function tutico(optional num : int)
{
	var tag, key : string;
	var message : W3TutorialPopupData;
	
	
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);	
	message = new W3TutorialPopupData in theGame;
	message.managerRef = theGame.GetTutorialSystem();
	message.scriptTag = 'aaa';
	message.duration = -1;
	message.autosize = false;
	
	
	theGame.ClosePopup( 'TutorialPopup');
		
	switch(num)
	{
		case 0 : 
			DEBUG_Test_GetIconForTag(tag, "GUI_LootPanel_LootAll");
			DEBUG_Test_GetIconForTag(tag, "GUI_PC_LootPanel_LootAll");
			DEBUG_Test_GetIconForTag(tag, "GI_AxisRight");
			DEBUG_Test_GetIconForTag(tag, "GI_AxisLeft");
			DEBUG_Test_GetIconForTag(tag, "GUI_LootPanel_Close");
			DEBUG_Test_GetIconForTag(tag, "GUI_PC_LootPanel_Close");
			DEBUG_Test_GetIconForTag(tag, "GUI_MoveDown");
			DEBUG_Test_GetIconForTag(tag, "GUI_MoveUp");
			DEBUG_Test_GetIconForTag(tag, "GUI_Navigate");
			DEBUG_Test_GetIconForTag(tag, "GUI_SwitchTabLeft");
			break;
		case 1 :
			DEBUG_Test_GetIconForTag(tag, "GUI_SwitchTabRight");
			DEBUG_Test_GetIconForTag(tag, "GUI_SwitchPageLeft");
			DEBUG_Test_GetIconForTag(tag, "GUI_SwitchPageRight");
			DEBUG_Test_GetIconForTag(tag, "GUI_SwitchInnerTabLeft");
			DEBUG_Test_GetIconForTag(tag, "GUI_SwitchInnerTabRight");
			DEBUG_Test_GetIconForTag(tag, "GUI_Select");
			DEBUG_Test_GetIconForTag(tag, "GUI_Select2");
			DEBUG_Test_GetIconForTag(tag, "GUI_Close");
			DEBUG_Test_GetIconForTag(tag, "GUI_PC_Close");
			DEBUG_Test_GetIconForTag(tag, "GUI_NavigateUpDown");
			break;
		case 2 :
			DEBUG_Test_GetIconForTag(tag, "ICO_DialogAxii");
			DEBUG_Test_GetIconForTag(tag, "ICO_DialogShop");
			DEBUG_Test_GetIconForTag(tag, "ICO_QuestGiver");
			DEBUG_Test_GetIconForTag(tag, "ICO_DialogGwint");
			DEBUG_Test_GetIconForTag(tag, "PAD_LSUp");
			DEBUG_Test_GetIconForTag(tag, "ICO_DialogEnd");
			DEBUG_Test_GetIconForTag(tag, "GUI_RS_Press");
			DEBUG_Test_GetIconForTag(tag, "GUI_DPAD_LeftRight");
			DEBUG_Test_GetIconForTag(tag, "PAD_LS_LeftRight");
			break;
		case 3 :
			DEBUG_Test_GetIconNameForKey(tag, IK_Pad_A_CROSS);
			DEBUG_Test_GetIconNameForKey(tag, IK_Pad_B_CIRCLE);
			DEBUG_Test_GetIconNameForKey(tag, IK_Pad_X_SQUARE);
			DEBUG_Test_GetIconNameForKey(tag, IK_Pad_Y_TRIANGLE);
			DEBUG_Test_GetIconNameForKey(tag, IK_Pad_LeftThumb);
			DEBUG_Test_GetIconNameForKey(tag, IK_Pad_RightThumb);
			DEBUG_Test_GetIconNameForKey(tag, IK_Pad_LeftShoulder);
			DEBUG_Test_GetIconNameForKey(tag, IK_Pad_RightShoulder);
			DEBUG_Test_GetIconNameForKey(tag, IK_Pad_LeftTrigger);
			DEBUG_Test_GetIconNameForKey(tag, IK_Pad_RightTrigger);
			DEBUG_Test_GetIconNameForKey(tag, IK_Pad_Start);
			break;
		case 4 :		
			DEBUG_Test_GetIconNameForKey(tag, IK_Pad_Back_Select);
			DEBUG_Test_GetIconNameForKey(tag, IK_Pad_DigitUp);
			DEBUG_Test_GetIconNameForKey(tag, IK_Pad_DigitDown);
			DEBUG_Test_GetIconNameForKey(tag, IK_Pad_DigitLeft);
			DEBUG_Test_GetIconNameForKey(tag, IK_Pad_DigitRight);
			DEBUG_Test_GetIconNameForKey(tag, IK_Pad_LeftAxisY);
			DEBUG_Test_GetIconNameForKey(tag, IK_LeftMouse);
			DEBUG_Test_GetIconNameForKey(tag, IK_RightMouse);
			DEBUG_Test_GetIconNameForKey(tag, IK_MiddleMouse);
			DEBUG_Test_GetIconNameForKey(tag, IK_MouseWheelUp);
			DEBUG_Test_GetIconNameForKey(tag, IK_MouseWheelDown);
			break;
		default :
			return;
	}
	
	message.messageText = tag;
	theGame.RequestPopup( 'TutorialPopup',  message );
}

exec function testLocKeyboardKeyNames()
{
	LogChannel('aaa', IK_Backspace + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Backspace"));
	LogChannel('aaa', IK_Tab + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Tab"));
	LogChannel('aaa', IK_Enter + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Enter"));
	LogChannel('aaa', IK_Shift + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Shift"));
	LogChannel('aaa', IK_Ctrl + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Ctrl"));
	LogChannel('aaa', IK_Alt + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Alt"));
	LogChannel('aaa', IK_Pause + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Pause"));
	LogChannel('aaa', IK_CapsLock + " - " + GetLocStringByKeyExt("input_device_key_name_IK_CapsLock"));
	LogChannel('aaa', IK_Escape + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Escape"));
	LogChannel('aaa', IK_Space + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Space"));
	LogChannel('aaa', IK_PageUp + " - " + GetLocStringByKeyExt("input_device_key_name_IK_PageUp"));
	LogChannel('aaa', IK_PageDown + " - " + GetLocStringByKeyExt("input_device_key_name_IK_PageDown"));
	LogChannel('aaa', IK_End + " - " + GetLocStringByKeyExt("input_device_key_name_IK_End"));
	LogChannel('aaa', IK_Home + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Home"));
	LogChannel('aaa', IK_Left + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Left"));
	LogChannel('aaa', IK_Up + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Up"));
	LogChannel('aaa', IK_Right + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Right"));
	LogChannel('aaa', IK_Down + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Down"));
	LogChannel('aaa', IK_Select + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Select"));
	LogChannel('aaa', IK_Print + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Print"));
	LogChannel('aaa', IK_Execute + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Execute"));
	LogChannel('aaa', IK_PrintScrn + " - " + GetLocStringByKeyExt("input_device_key_name_IK_PrintScrn"));
	LogChannel('aaa', IK_Insert + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Insert"));
	LogChannel('aaa', IK_Delete + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Delete"));
	LogChannel('aaa', IK_NumPad0 + " - " + GetLocStringByKeyExt("input_device_key_name_IK_NumPad0"));
	LogChannel('aaa', IK_NumPad1 + " - " + GetLocStringByKeyExt("input_device_key_name_IK_NumPad1"));
	LogChannel('aaa', IK_NumPad2 + " - " + GetLocStringByKeyExt("input_device_key_name_IK_NumPad2"));
	LogChannel('aaa', IK_NumPad3 + " - " + GetLocStringByKeyExt("input_device_key_name_IK_NumPad3"));
	LogChannel('aaa', IK_NumPad4 + " - " + GetLocStringByKeyExt("input_device_key_name_IK_NumPad4"));
	LogChannel('aaa', IK_NumPad5 + " - " + GetLocStringByKeyExt("input_device_key_name_IK_NumPad5"));
	LogChannel('aaa', IK_NumPad6 + " - " + GetLocStringByKeyExt("input_device_key_name_IK_NumPad6"));
	LogChannel('aaa', IK_NumPad7 + " - " + GetLocStringByKeyExt("input_device_key_name_IK_NumPad7"));
	LogChannel('aaa', IK_NumPad8 + " - " + GetLocStringByKeyExt("input_device_key_name_IK_NumPad8"));
	LogChannel('aaa', IK_NumPad9 + " - " + GetLocStringByKeyExt("input_device_key_name_IK_NumPad9"));
	LogChannel('aaa', IK_NumStar + " - " + GetLocStringByKeyExt("input_device_key_name_IK_NumStar"));
	LogChannel('aaa', IK_NumPlus + " - " + GetLocStringByKeyExt("input_device_key_name_IK_NumPlus"));
	LogChannel('aaa', IK_Separator + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Separator"));
	LogChannel('aaa', IK_NumMinus + " - " + GetLocStringByKeyExt("input_device_key_name_IK_NumMinus"));
	LogChannel('aaa', IK_NumPeriod + " - " + GetLocStringByKeyExt("input_device_key_name_IK_NumPeriod"));
	LogChannel('aaa', IK_NumSlash + " - " + GetLocStringByKeyExt("input_device_key_name_IK_NumSlash"));
	LogChannel('aaa', IK_NumLock + " - " + GetLocStringByKeyExt("input_device_key_name_IK_NumLock"));
	LogChannel('aaa', IK_ScrollLock + " - " + GetLocStringByKeyExt("input_device_key_name_IK_ScrollLock"));
	LogChannel('aaa', IK_LShift + " - " + GetLocStringByKeyExt("input_device_key_name_IK_LShift"));
	LogChannel('aaa', IK_RShift + " - " + GetLocStringByKeyExt("input_device_key_name_IK_RShift"));
	LogChannel('aaa', IK_LControl + " - " + GetLocStringByKeyExt("input_device_key_name_IK_LControl"));
	LogChannel('aaa', IK_RControl + " - " + GetLocStringByKeyExt("input_device_key_name_IK_RControl"));
	LogChannel('aaa', IK_Mouse4 + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Mouse4"));
	LogChannel('aaa', IK_Mouse5 + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Mouse5"));
	LogChannel('aaa', IK_Mouse6 + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Mouse6"));
	LogChannel('aaa', IK_Mouse7 + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Mouse7"));
	LogChannel('aaa', IK_Mouse8 + " - " + GetLocStringByKeyExt("input_device_key_name_IK_Mouse8"));
}
