/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4UIRescaleMenu extends CR4MenuBase
{
	var hud : CR4ScriptedHud;
	private var m_fxSetCurrentUsername  : CScriptedFlashFunction;

	event  OnConfigUI()
	{
		var inGameConfigWrapper : CInGameConfigWrapper;
		var username 			: string;
		var overlayPopupRef  : CR4OverlayPopup;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		super.OnConfigUI();
		
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		
		theGame.SetUIVerticalFrameScale( StringToFloat( inGameConfigWrapper.GetVarValue( 'Hidden', 'uiVerticalFrameScale' ) ) );
		theGame.SetUIHorizontalFrameScale( StringToFloat( inGameConfigWrapper.GetVarValue('Hidden', 'uiHorizontalFrameScale') ) );
		
		m_flashValueStorage.SetFlashNumber( "uirescale.initial.horizontal", theGame.GetUIHorizontalFrameScale() ); 
		m_flashValueStorage.SetFlashNumber( "uirescale.initial.vertical", theGame.GetUIVerticalFrameScale() ); 
		m_flashValueStorage.SetFlashNumber( "uirescale.initial.scale", theGame.GetUIScale() ); 
		m_flashValueStorage.SetFlashNumber( "uirescale.initial.opacity", theGame.GetUIOpacity() ); 
		
		m_fxSetCurrentUsername = m_flashModule.GetMemberFlashFunction("setCurrentUsername");
		
		overlayPopupRef = (CR4OverlayPopup)theGame.GetGuiManager().GetPopup('OverlayPopup');
		if (!overlayPopupRef)
		{
			theGame.RequestPopup( 'OverlayPopup' );
		}
		
		theGame.GetGuiManager().RequestMouseCursor(true);
		
		username = FixStringForFont(theGame.GetActiveUserDisplayName());
		m_fxSetCurrentUsername.InvokeSelfOneArg(FlashArgString(username));
		
		theGame.GetGuiManager().OnEnteredConfigScreen();
	}
	
	event  OnClosingMenu()
	{
		theGame.GetGuiManager().RequestMouseCursor(false);
	}

	event  OnCloseMenu()
	{
		CloseMenu();
	}	
	
	event  OnConfirmRescale( frameScaleX : float, frameScaleY : float )
	{
		UpdateRescale( frameScaleX, frameScaleY, 0, 0 );
		CloseMenu();
	}	

	event  OnUpdateRescale( frameScaleX : float, frameScaleY : float )
	{
		UpdateRescale( frameScaleX, frameScaleY, 0, 0 );
	}
	
	event  OnRefreshActiveUserDisplayName()
	{
		var username 			: string;

		username = FixStringForFont(theGame.GetActiveUserDisplayName());
		m_fxSetCurrentUsername.InvokeSelfOneArg(FlashArgString(username));
	}

	function UpdateRescale( frameScaleX : float, frameScaleY : float, scale : float, opacity : float )
	{
		var inGameConfigWrapper : CInGameConfigWrapper;
		var needRescale : bool;
		
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		needRescale = false;
		
		if( theGame.GetUIHorizontalFrameScale() != frameScaleX )
		{
			theGame.SetUIHorizontalFrameScale(frameScaleX);
			inGameConfigWrapper.SetVarValue('Hidden', 'uiHorizontalFrameScale', FloatToString(frameScaleX));
			needRescale = true;
		}	
		if( theGame.GetUIVerticalFrameScale() != frameScaleY )
		{
			theGame.SetUIVerticalFrameScale(frameScaleY);
			inGameConfigWrapper.SetVarValue('Hidden', 'uiVerticalFrameScale', FloatToString(frameScaleY));
			needRescale = true;
		}		
		
		
		
		
		
		
		
		
		
		
		
		if( needRescale && hud ) 
		{
			hud.RescaleModules();
		}
	}
}

exec function uirescale()
{
	theGame.RequestMenu('RescaleMenu');
}