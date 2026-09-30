/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SMoveLocomotionGoal {};





import abstract class CMoveTRGScript extends CObject
{
	import var agent 				: CMovingAgentComponent;
	import var timeDelta			: float;
	
	
	function UpdateChannels( out goal : SMoveLocomotionGoal );
	
	
	import function SetHeadingGoal( out goal : SMoveLocomotionGoal, heading : Vector );

	
	
	
	import function SetOrientationGoal( out goal : SMoveLocomotionGoal, orientation : float, optional alwaysSet : bool );

	
	import function SetSpeedGoal( out goal : SMoveLocomotionGoal, speed : float );

	
	import function SetMaxWaitTime( out goal : SMoveLocomotionGoal, time : float );

	
	
	import function MatchDirectionWithOrientation( out goal : SMoveLocomotionGoal, enable : bool );
	
	
	
	
	import function SetFulfilled( out goal : SMoveLocomotionGoal, isFulfilled : bool );
	
	
	
	
	
	import final function Seek( pos : Vector ) : Vector;
	import final function Flee( pos : Vector ) : Vector;
	import final function Pursue( agent : CMovingAgentComponent ) : Vector;
	import final function FaceTarget( pos : Vector ) : Vector;
};