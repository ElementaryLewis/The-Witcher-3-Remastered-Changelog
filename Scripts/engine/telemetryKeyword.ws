/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CR4TelemetryScriptProxy extends CObject
{
	import final function LogWithName( eventType : ER4TelemetryEvents );
	import final function LogWithLabel( eventType : ER4TelemetryEvents, label : String );
	import final function LogWithValue( eventType : ER4TelemetryEvents, value : int );
	import final function LogWithValueStr( eventType : ER4TelemetryEvents, value : String );
	
	import final function LogWithLabelAndValue( eventType : ER4TelemetryEvents, label : String, value : int );
	import final function LogWithLabelAndValueStr( eventType : ER4TelemetryEvents, label : String, value : String );

	import final function SetCommonStatFlt( statType: ER4CommonStats, value : float );	
	import final function SetCommonStatI32( statType: ER4CommonStats, value : int );
	
	import final function SetGameProgress( value : float );
	
	import final function AddSessionTag( tag : String );
	import final function RemoveSessionTag( tag : String );
	
	import final function XDPPrintUserStats( statisticName : String );
	import final function XDPPrintUserAchievement( achievementName : String );
	import final function TelemetryConsentChanged(telemetryConsent : bool);
	import final function WasConsentWindowShown() : bool;
	import final function MarkShownConsentWindow();
	
	import final function NoticeMenuDepth(d : int);
}
