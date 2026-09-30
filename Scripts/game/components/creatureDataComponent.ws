/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CCreatureDataComponent extends CScriptedComponent
{
	
	
	
	editable var itemsUsedAgainstCreature		: array<name>;
	editable var skillsUsedAgainstCreature		: array<name>;
	
	
	
	editable var cameraDistance					: float;
	editable var cameraLookAtZ					: float;
	editable var cameraRotationYaw				: float;
	editable var cameraRotationPitch			: float;
	editable var environmentSunRotationYaw		: float;
	editable var environmentSunRotationPitch	: float;
	editable var appearance						: name;
	editable var position						: Vector;
	
	editable var scale							: float; default scale = 1.0;
	editable var fov							: float; default fov = 70.0f;
	
	function GetItemsUsedAgainstCreature() : array<name>
	{
		return itemsUsedAgainstCreature;
	}
	
	function GetSkillsUsedAgainstCreature() : array<name>
	{
		return skillsUsedAgainstCreature;
	}
	
	function GetCameraDistance() : float
	{
		return cameraDistance;
	}
	
	function GetCameraLookAtZ() : float
	{
		return cameraLookAtZ;
	}
	
	function GetCameraRotationYaw() : float
	{
		return cameraRotationYaw;
	}
	
	function GetCameraRotationPitch() : float
	{
		return cameraRotationPitch;
	}
	
	function GetEnvironmentSunRotationYaw() : float
	{
		return environmentSunRotationYaw;
	}
	
	function GetEnvironmentSunRotationPitch() : float
	{
		return environmentSunRotationPitch;
	}
	
	function GetDesiredAppearance() : name
	{
		return appearance;
	}
	
	function GetEntityPosition() : Vector
	{
		return position;
	}
	
	function GetEntityRotation() : EulerAngles
	{
		var emptyRotation : EulerAngles;
		return emptyRotation;
	}
	
	function getEntityScale() : Vector
	{
		var returnVal : Vector;
		
		if (scale == 0)
		{
			scale = 1;
		}
		
		returnVal.X = scale;
		returnVal.Y = scale;
		returnVal.Z = scale;
		
		return returnVal;
	}
	
	function getFov() : float
	{
		return fov;
	}
}