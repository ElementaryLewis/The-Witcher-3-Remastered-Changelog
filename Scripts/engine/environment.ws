/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import function ActivateEnvironmentDefinition( environmentDefinition : CEnvironmentDefinition, priority : int, blendFactor : float, blendInTime : float ) : int;



import function DeactivateEnvironment( environmentID : int , blendOutTime : float );



import function ActivateQuestEnvironmentDefinition( environmentDefinition : CEnvironmentDefinition, priority : int, blendFactor : float, blendTime : float );


import function GetActiveAreaEnvironmentDefinitions( out defs : array< string > );


import function SetInteriorBlending(isCave : bool, isEnabled: bool, enterBlendTime: float, exitBlendTime: float);



import function EnableDebugOverlayFilter(enumName : int);

import function EnableDebugPostProcess(PostProcessName : int, activate : bool);

import function GetAllEnvironmentDefinitions( out defs : array< string > );






import function GetRainStrength() : float;
import function GetSnowStrength() : float;
import function IsSkyClear() : bool;
	
function AreaIsCold() : bool
{
	var l_currentArea  : CName;		
	l_currentArea = theGame.GetCommonMapManager().GetCurrentArea();		
	if( l_currentArea == 'AN_Prologue_Village_Winter' ||  l_currentArea == 'AN_Skellige_ArdSkellig' ||  l_currentArea == 'AN_Island_of_Myst' )
	{
		return true;
	}
	return false;
}


import function SetUnderWaterBrightness(val : float);

import function GetWeatherConditionName() : name;
import function RequestWeatherChangeTo( weatherName : name, blendTime : float, questPause: bool ) : bool;
import function RequestRandomWeatherChange( blendTime : float, questPause: bool ) : bool;
import function RequestWeatherPause( questPause : bool ) : bool;
import function IsWeatherPauseRequested() : bool;
import function SetWeatherBlendTime( blendTime : float ) : bool;
import function GetWeatherBlendTime( out blendTime : float ) : bool;
import function GetPredictedTimeUntilWeatherChange( out time : float ) : bool;
import function GetWeatherNames( names : array<name> ) : bool;
import function SetWindSpeedTreeTimeScale( timeScale : float ) : bool;
import function SetWindCloudsTimeScale( timeScale : float ) : bool;

import function ForceFakeEnvTime( hour : float );
import function DisableFakeEnvTime();

function TraceFloor( currPosition : Vector ) : Vector
{
	var outPosition, outNormal, tempPosition1, tempPosition2 : Vector;
	
	tempPosition1 = currPosition;
	tempPosition1.Z -= 5;
	
	tempPosition2 = currPosition;
	tempPosition2.Z += 2;
	
	if ( theGame.GetWorld().StaticTrace( tempPosition2, tempPosition1, outPosition, outNormal ) )
	{
		return outPosition;
	}
	
	return currPosition;
}