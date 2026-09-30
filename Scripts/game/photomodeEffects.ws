/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CR4PhotomodeEffects extends CObject
{
	private var photomodeMenu : CR4PhotomodeMenu;
	
	import final function HaveChangesBeenMade() : bool;
	import final function SetEnabled( value : bool );
	import final function SetDofEnabled( value : bool );
	import final function SetAperture( value : float );
	import final function GetAperture() : float;
	import final function SetFocusDistance( value : float );
	import final function GetFocusDistance() : float;
	import final function SetAutoFocus( value : bool );
	import final function GetAutoFocus() :bool;
	import final function SetExposure( value : float );
	import final function GetExposure() : float;
	import final function SetContrast( value : float );
	import final function GetContrast() : float;
	import final function SetHighlights( value : float );
	import final function GetHighlights() : float;
	import final function SetSaturation( value : float );
	import final function GetSaturation() : float;
	import final function SetTemperature( value : float );
	import final function GetTemperature() : float;
	import final function SetChromaticAberration( value : float );
	import final function GetChromaticAberration() : float;
	import final function SetFilmGrain( value : float );
	import final function GetFilmGrain() : float;
	import final function SetVignette( value : float );
	import final function GetVignette() : float;
	import final function SetWeather( value : string );
	import final function GetWeather() : string;
	import final function RestoreWeather();
	import final function SetTimeOfDay( value : float );
	import final function GetTimeOfDay() : float;
	import final function GetEnvDef( out definition : CEnvironmentDefinition );
	import final function SetEnvDefUsingPath( definition : string );
	import final function SetEnvDefNull();
	
	import final function GetEditableCharacterList(maxDist : float, out list : array<CActor>);
	import final function GetCharacterAppearanceList(char : CActor, out list : array<name>);
	import final function SetPhotomodeTickTime(time : float);
	import final function SetPhotomodeClothsSimulationTime(time : float);
	import final function SetPhotomodeCustomAspect(customAspect:bool, xRatio:int, yRatio:int);
	
	public function SetPhotomodeMenu( menu : CR4PhotomodeMenu )
	{
		photomodeMenu = menu;
	}
	
	event OnPhotomodeParameterUpdated( id : int, value : float )
	{
		photomodeMenu.UpdateParam( id, value );
	}
}