/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3MarketingPopupData extends W3CheckboxListPopupData
{
	public var valid : bool; default valid = true;

	public function Init( checkedConsentChoices : int ) : void
	{
		LogChannel('GFX ', "Initializing W3MarketingPopupData" );

		SetMessageTitle( GetLocStringByKeyExt( "panel_marketing_title" ) );
		SetMessageText( GetLocStringByKeyExt( "panel_marketing_body" ) );
		SetTextSecondary( GetLocStringByKeyExt( "panel_age_confirmation" ) );

		AddCheckBoxText( GetLocStringByKeyExt( "panel_email_notifications_desc" ), checkedConsentChoices & 1 );
		AddCheckBoxText( GetLocStringByKeyExt( "panel_personalized_offers_desc" ), checkedConsentChoices & 2 );
	}

	protected  function GetContentRef() : string 
	{
		return "MarketingConsentPopupRef";
	}

	protected  function DefineDefaultButtons():void
	{
		var checkboxEnablePadNavCode : string = "gamepad_X";
		var licenseAcceptPadNavCode : string = "gamepad_Y";

		if (theGame.GetPlatform() == Platform_Switch2_Ounce)
		{
			checkboxEnablePadNavCode = "gamepad_Y";
			licenseAcceptPadNavCode = "gamepad_X";
		}

		AddButtonDef( "panel_accept_all", "enter-gamepad_A", IK_Enter );
		AddButtonDef( "panel_accept_decline", "escape-gamepad_B", IK_Escape );
		AddButtonDef( "panel_checkbox_default_enable", checkboxEnablePadNavCode, IK_Space );
		AddButtonDef( "panel_license_accept", licenseAcceptPadNavCode, IK_F );
	}
	
	public  function OnUserFeedback( KeyCode:string ) : void
	{
		var isSwitchPlatform : bool = theGame.GetPlatform() == Platform_Switch2_Ounce;

		
		LogChannel('GFX ', "OnUserFeedbackMarketing " + KeyCode );

		if ( KeyCode == "enter-gamepad_A" ) 
		{								  
			OnUserAcceptAll();				  
		}
		else if ( KeyCode == "escape-gamepad_B" ) 
		{
			OnUserDeclineAll();
		}
		else if ( ( isSwitchPlatform && KeyCode == "gamepad_X" ) ||		
				( !isSwitchPlatform && KeyCode == "gamepad_Y" ) ) 		
		{
			OnUserAccept();
		}
	}
	
	protected function GetConsentChoices() : int
	{
		var choices : int;

		choices = 0;
		if ( m_checkboxes[ 0 ].checked )
		{
			choices |= 1;
		}
		if ( m_checkboxes[ 1 ].checked )
		{
			choices |= 2;
		}

		return choices;
	}

	protected  function OnUserAccept() : void
	{
		theGame.GetMarketingProxy().SendConsentChoices( GetConsentChoices() );
		ClosePopup();
		valid = false;
	}
	
	protected function OnUserAcceptAll() : void
	{
		theGame.GetMarketingProxy().SendConsentChoices( 3 );
		ClosePopup();
		valid = false;
	}
	
	protected function OnUserDeclineAll() : void
	{
		theGame.GetMarketingProxy().SendConsentChoices( 0 );
		ClosePopup();
		valid = false;
	}
}