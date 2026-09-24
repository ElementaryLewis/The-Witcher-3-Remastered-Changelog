/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4PhotomodeMenu extends CR4MenuBase
{	
	private var _cachedTutorialVisibility : bool; default _cachedTutorialVisibility = false;
	private var	_fxOnScreenshotSaved : CScriptedFlashFunction;
	private var _setCurrentFrameScale : CScriptedFlashFunction;
		
	event OnConfigUI()
	{
		super.OnConfigUI();
		HideTutorial();
		FillTabbedMenu();

		_fxOnScreenshotSaved = GetMenuFlash().GetMemberFlashFunction( "onScreenshotSaved" );
		_setCurrentFrameScale = GetMenuFlash().GetMemberFlashFunction( "setCurrentFrameScale" );
		_setCurrentFrameScale.InvokeSelfTwoArgs( FlashArgNumber( theGame.GetUIVerticalFrameScale() ), FlashArgNumber( theGame.GetUIHorizontalFrameScale() ) );
	}
	
	event OnScreenShotRequested()
	{
		if( theGame.GetPlatform() != Platform_PC )
			return false;
			
		theGame.TakeScreenshot();
		_fxOnScreenshotSaved.InvokeSelf();
	}
	
	event OnMenuShown()
	{
		super.OnMenuShown();
		
		theGame.GetPhotomodeEffects().SetPhotomodeMenu( this );
		theGame.GetPhotomodeEffects().SetEnabled( true );
	}
	
	event OnClosingMenu()
	{
		super.OnClosingMenu();
		
		ShowTutorial();
		theGame.GetPhotomodeEffects().SetEnabled( false );
	}
	
	event OnParameterChanged(paramId:int, value:float)
	{
		switch( paramId )
		{
		case PM_Camera_FOV:
			theGame.GetPhotomodeCamera().SetFov( value );
			break;
		case PM_Camera_Tilt:
			theGame.GetPhotomodeCamera().SetTilt( value );
			break;
		case PM_Exposure:
			theGame.GetPhotomodeEffects().SetExposure( value );
			break;
		case PM_Highlights:
			theGame.GetPhotomodeEffects().SetHighlights( value );
			break;
		case PM_Saturation:
			theGame.GetPhotomodeEffects().SetSaturation( value );
			break;
		case PM_Vignette:
			theGame.GetPhotomodeEffects().SetVignette( value );
			break;
		case PM_Contrast:
			theGame.GetPhotomodeEffects().SetContrast( value );
			break;
		case PM_Temperature:
			theGame.GetPhotomodeEffects().SetTemperature( BinToTemperature( value ) );
			break;
		case PM_ChromaticAberration:
			theGame.GetPhotomodeEffects().SetChromaticAberration( value );
			break;
		case PM_Grain:
			theGame.GetPhotomodeEffects().SetFilmGrain( value );
			break;
		case PM_DOF_Enable:
			if( value == 0 )
			{
				theGame.GetPhotomodeEffects().SetDofEnabled( false );
			}
			else
			{
				theGame.GetPhotomodeEffects().SetDofEnabled( true );
			}
			break;
		case PM_DOF_Aperture:
			theGame.GetPhotomodeEffects().SetAperture( value );
			break;
		case PM_DOF_FocusDistance:
			theGame.GetPhotomodeEffects().SetFocusDistance( value );
			break;
		case PM_DOF_Autofocus:
			if( value == 0 )
			{
				theGame.GetPhotomodeEffects().SetAutoFocus( false );
			}
			else
			{
				theGame.GetPhotomodeEffects().SetAutoFocus( true );
			}
			break;
		}
	}
	
	
	private function TemperatureToBin( tempf:float ) : float
	{
		var temp:int;
		temp = (int)tempf;
		if( temp >= 10000 )
		{
			return ( (temp - 5000) / -1000 );
		}
		else
		{
			switch( temp )
			{
				case 9000 	: 	return -4;
					
				case 8000 	: 	return -3;
					
				case 7500 	: 	return -2;
					
				case 7000 	: 	return -1;

				case 6550 	:  	return 0;

				case 5000 	:  	return 1;
			
				case 4500 	:  	return 2;

				case 4000 	:	return 3;

				case 3500 	:	return 4;

				case 3000 	: 	return 5;

				case 2500 	: 	return 6;
		
				case 2300 	: 	return 7;
					
				case 2000 	:	return 8;

				case 1500 	: 	return 9;

				case 1000 	: 	return 10;
			}
		}
	}

	
	private function BinToTemperature( tempf:float ) : float
	{
		var temp:int;
		temp = (int)tempf;
		if( temp <= -5 )
		{
			return ( (temp * -1000) + 5000 );
		}
		else
		{
			switch( temp )
			{
				case -5 	:	return ( (temp * -1000.0) + 5000.0 ); 

				case -4		: 	return 9000;
					
				case -3		: 	return 8000;
					
				case -2		: 	return 7500;
					
				case -1		: 	return 7000;

				case 0		:  	return 6550;

				case 1		:  	return 5000;
			
				case 2		:  	return 4500;

				case 3		:	return 4000;

				case 4 		:	return 3500;

				case 5 		: 	return 3000;

				case 6 		: 	return 2500;
		
				case 7 		: 	return 2300;
					
				case 8 		:	return 2000;

				case 9 		: 	return 1500;

				case 10 	: 	return 1000;
			}
		}
	}




	private function FillTabbedMenu()
	{
		var rootObj : CScriptedFlashObject;
		var rootArray : CScriptedFlashArray;	
		
		var tabData : CScriptedFlashArray;
		
		var stringsArray : array<string>;
		
		rootObj = m_flashValueStorage.CreateTempFlashObject();
		rootArray = m_flashValueStorage.CreateTempFlashArray();


		
		
		tabData = m_flashValueStorage.CreateTempFlashArray();
		
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Camera_FOV, "photomode_params_fov", 15.0, 90.0, 1.0, 60.0)); 	
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Camera_Tilt, "photomode_params_tilt", -90.0, 90.0, 1.0, 0.0));  
		
		rootArray.PushBackFlashObject(CreateTab("photomode_tabs_camera", tabData)); 
		
		
		tabData = m_flashValueStorage.CreateTempFlashArray();
		
		stringsArray.Clear();
		stringsArray.PushBack("panel_mainmenu_option_value_off"); 
		stringsArray.PushBack("panel_mainmenu_option_value_on");  
		tabData.PushBackFlashObject(CreateStringSlider(PM_DOF_Enable, "option_allow_dof", stringsArray)); 
		
		tabData.PushBackFlashObject(CreateStringSlider(PM_DOF_Autofocus, "photomode_params_autofocus", stringsArray)); 
		
		stringsArray.Clear();
		stringsArray.PushBack("f/1.0");
		stringsArray.PushBack("f/1.4");
		stringsArray.PushBack("f/2.0");
		stringsArray.PushBack("f/2.8");
		stringsArray.PushBack("f/4.0");
		stringsArray.PushBack("f/5.6");
		stringsArray.PushBack("f/8.0");
		stringsArray.PushBack("f/11.0");
		stringsArray.PushBack("f/16.0");
		stringsArray.PushBack("f/22.0");
		stringsArray.PushBack("f/32.0");
		tabData.PushBackFlashObject(CreateStringSlider(PM_DOF_Aperture, "photomode_params_aperture", stringsArray, 4, true)); 
		
		tabData.PushBackFlashObject(CreateBasicSlider(PM_DOF_FocusDistance, "photomode_params_focus_distance", 0.0, 10.0, 0.1, theGame.GetPhotomodeEffects().GetFocusDistance())); 

		rootArray.PushBackFlashObject(CreateTab("option_allow_dof", tabData)); 
		
		
		tabData = m_flashValueStorage.CreateTempFlashArray();
		
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Exposure, "photomode_params_exposure", -4.0, 4.0, 0.1, theGame.GetPhotomodeEffects().GetExposure())); 
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Contrast, "photomode_params_contrast", 0.8, 1.2, 0.01, theGame.GetPhotomodeEffects().GetContrast())); 
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Highlights, "photomode_params_highlights", 0.3, 3.0, 0.05, theGame.GetPhotomodeEffects().GetHighlights())); 
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Temperature, "photomode_params_temperature", -10.0, 10.0, 1.0, TemperatureToBin( theGame.GetPhotomodeEffects().GetTemperature() )) ); 
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Saturation, "photomode_params_saturation", 0.0, 2.0, 0.05, theGame.GetPhotomodeEffects().GetSaturation())); 
		tabData.PushBackFlashObject(CreateBasicSlider(PM_ChromaticAberration, "photomode_params_chromatic_aberration", 0.0, 20.0, 0.2, theGame.GetPhotomodeEffects().GetChromaticAberration())); 
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Grain, "photomode_params_grain", 0.0, 0.1, 0.001, 0.0)); 

		rootArray.PushBackFlashObject(CreateTab("photomode_tabs_effect", tabData)); 
		
		
		tabData = m_flashValueStorage.CreateTempFlashArray();
		
		tabData.PushBackFlashObject(CreateBasicSlider(PM_Vignette, "photomode_params_vignette", -0.7, 0.7, 0.01, 0.0)); 
		
		rootArray.PushBackFlashObject(CreateTab("photomode_tabs_overlay", tabData)); 
		
		rootObj.SetMemberFlashArray("tabs", rootArray);
		m_flashValueStorage.SetFlashObject( "photomode.tabs", rootObj );
	}
	
	private function CreateBasicSlider(id:int, label:string, minVal:float, maxVal:float, step:float, optional defVal:float) : CScriptedFlashObject
	{
		var sliderObj : CScriptedFlashObject;
		var sliderArgsArray : CScriptedFlashArray;
		
      		sliderObj = m_flashValueStorage.CreateTempFlashObject();
		sliderArgsArray = m_flashValueStorage.CreateTempFlashArray();
		
		sliderArgsArray.PushBackFlashInt(id);
		sliderArgsArray.PushBackFlashString(GetLocStringByKeyExt(label));
		sliderArgsArray.PushBackFlashNumber(minVal);
		sliderArgsArray.PushBackFlashNumber(maxVal);
		sliderArgsArray.PushBackFlashNumber(step);
		sliderArgsArray.PushBackFlashNumber(defVal);
		
		sliderObj.SetMemberFlashArray("args", sliderArgsArray);
		
		return sliderObj;
	}
	
	private function CreateStringSlider(id:int, label:string, strings:array<string>, optional defIdx:int, optional dontLocalizeValue:bool) : CScriptedFlashObject
	{
		var sliderObj : CScriptedFlashObject;
		var sliderArgsArray : CScriptedFlashArray;
		var stringsArray : CScriptedFlashArray;
		var stringsArrayObj : CScriptedFlashObject;
		var i, length: int;
		
		sliderObj = m_flashValueStorage.CreateTempFlashObject();
		sliderArgsArray = m_flashValueStorage.CreateTempFlashArray();
		stringsArray = m_flashValueStorage.CreateTempFlashArray();
		stringsArrayObj = m_flashValueStorage.CreateTempFlashObject();;
		
		sliderArgsArray.PushBackFlashInt(id);
		sliderArgsArray.PushBackFlashString(GetLocStringByKeyExt(label));

		length = strings.Size();
		for(i = 0; i < length; i += 1)
		{
			if( dontLocalizeValue )
			{
				stringsArray.PushBackFlashString( strings[i] );
			}
			else
			{
				stringsArray.PushBackFlashString( GetLocStringByKeyExt(strings[i]) );
			}
		}

		stringsArrayObj.SetMemberFlashArray("strings", stringsArray);
		sliderArgsArray.PushBackFlashObject(stringsArrayObj);
		sliderArgsArray.PushBackFlashInt(defIdx);
		
		sliderObj.SetMemberFlashArray("args", sliderArgsArray);
		
		return sliderObj;
	}
	
	private function CreateTab( label:string, data:CScriptedFlashArray ) : CScriptedFlashObject
	{
		var tabObj : CScriptedFlashObject;	

		tabObj = m_flashValueStorage.CreateTempFlashObject();
		tabObj.SetMemberFlashString( "label", GetLocStringByKeyExt(label) );
		tabObj.SetMemberFlashArray( "data", data );
		
		return tabObj;
	}
	
	private function HideTutorial()
	{
		var tutorialPopupRef : CR4TutorialPopup;
		
		tutorialPopupRef = (CR4TutorialPopup) theGame.GetGuiManager().GetPopup('TutorialPopup');
		if (tutorialPopupRef && tutorialPopupRef.isVisible)
		{
			tutorialPopupRef.SetInvisible(true, true);
			_cachedTutorialVisibility = true;
		}
	}
	
	private function ShowTutorial()
	{
		var tutorialPopupRef : CR4TutorialPopup;
		
		tutorialPopupRef = (CR4TutorialPopup) theGame.GetGuiManager().GetPopup('TutorialPopup');
		if (tutorialPopupRef && !tutorialPopupRef.isVisible && _cachedTutorialVisibility == true)
		{
			tutorialPopupRef.SetInvisible(false, true);
			_cachedTutorialVisibility = false;
		}
	}
	
	public function UpdateParam( paramId : int, paramValue : float, optional enabled : bool )
	{
		var optionObject : CScriptedFlashObject;
		
		optionObject = m_flashValueStorage.CreateTempFlashObject();
		optionObject.SetMemberFlashUInt( "id", paramId );
		optionObject.SetMemberFlashNumber( "value", paramValue );
		
		m_flashValueStorage.SetFlashObject( "photomode.update_param", optionObject );
}	}