/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3MedallionController
{
	var deactivateTimer			: float;
	default deactivateTimer		= 0.0f;
	var instantIntensity		: float;
	default instantIntensity 	= 0.0f;
	var isBlocked				: bool;
	default isBlocked			= false;
	var focusModeFactor			: float;
	default focusModeFactor		= 1.0f;
	
	const var defaultDuration	: float;
	default defaultDuration		= 5.0f;
	
	const var defaultTreshold	: float;
	default defaultTreshold		= 4.0f;
	const var maxTreshold		: float;
	default maxTreshold			= 8.0f;
		
	public function SetInstantIntensity( intensity : float )
	{
		instantIntensity = intensity * maxTreshold;
	}
	
	public function Activate( activate : bool, optional duration : float )
	{
		if ( activate )
		{
			if ( duration == 0.0f )
			{
				duration = defaultDuration;
			}
			deactivateTimer = MaxF( deactivateTimer, theGame.GetEngineTimeAsSeconds() + duration );
		}
		else
		{
			deactivateTimer = theGame.GetEngineTimeAsSeconds();
		}
	}

	public function BlockActivation( block : bool )
	{
		isBlocked = block;
	}	

	public function IsActive() : bool
	{
		return ( !isBlocked && ( focusModeFactor > 0.0f ) && ( instantIntensity > 0.0f || theGame.GetEngineTimeAsSeconds() < deactivateTimer ) );
	}
	
	public function GetTreshold() : float
	{
		if ( theGame.GetEngineTimeAsSeconds() < deactivateTimer )
		{
			return MaxF( defaultTreshold, instantIntensity ) * focusModeFactor;
		}
		return instantIntensity * focusModeFactor;
	}
	
	public function SetFocusModeFactor( factor : float )
	{
		focusModeFactor = factor;	
	}
}