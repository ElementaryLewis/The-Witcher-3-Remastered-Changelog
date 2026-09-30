/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CNavigationReachabilityQueryInterface extends IScriptable
{
	
	
	import final function GetLastOutput( optional queryValidTime : float ) : EAsyncTestResult;
	
	import final function GetOutputClosestDistance() : float;
	import final function GetOutputClosestEntity() : CEntity;
	
	
	import final function TestActorsList
		( testType : ENavigationReachabilityTestType											
		, originActor : CActor																	
		, list : array< CActor >																
		, optional safeSpotTolerance : float													
		, optional pathfindDinstanceLimit : float )												
		: EAsyncTestResult;
};