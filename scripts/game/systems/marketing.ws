/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CR4MarketingScriptProxy extends CObject
{
	import final function OnMainMenuLanding();
	import final function OnConsentFlowCompleted();
	import final function SendConsentChoices( choices: int );
	import final function FetchConsentChoicesAndShowPopupAsync();
	
	import final function GetFetchedConsentChoices():int;
	import final function ResetTriggerCountdown();
	import final function TriggerFlow();
	import final function ForceUseQrSignIn( force: bool );
	import final function ForceSignOut();
}



exec function marketing_send( choices: int ):void
{
	theGame.GetMarketingProxy().SendConsentChoices( choices );
}

exec function marketing_fetch():void
{
	theGame.GetMarketingProxy().FetchConsentChoicesAndShowPopupAsync();
}

exec function marketing_reset_countdown():void
{
	theGame.GetMarketingProxy().ResetTriggerCountdown();
}

exec function marketing_trigger():void
{
	theGame.GetMarketingProxy().TriggerFlow();
}

exec function marketing_signout():void
{
	theGame.GetMarketingProxy().ForceSignOut();
}

exec function marketing_force_use_qr( force: bool ):void
{
	theGame.GetMarketingProxy().ForceUseQrSignIn( force );
}