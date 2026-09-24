/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CReactionsManager
{
	
	import final function BroadcastStaticInterestPoint( interestPoint : CInterestPoint, position : Vector, optional timeout : float );
	
	import final function BroadcastDynamicInterestPoint( interestPoint : CInterestPoint, node : CNode, optional timeout : float );
	
	
	import final function SendStaticInterestPoint( target : CNewNPC, interestPoint : CInterestPoint, position : Vector, optional timeout : float );
	
	import final function SendDynamicInterestPoint( target : CNewNPC, interestPoint : CInterestPoint, node : CNode, optional timeout : float );
};




import class CInterestPoint
{	
};


import class CScriptedInterestPoint extends CInterestPoint
{	
	function SetupInstance( instance : CInterestPointInstance, source : IScriptable )
	{
		
		instance.SetFieldStrengthMultiplier( 0.0f );
	}
};




import class CInterestPointInstance
{
	
	import final function GetParentPoint() : CInterestPoint;
	
	import final function GetWorldPosition() : Vector;
	
	import final function GetNode() : CNode;
	
	
	import final function GetGeneratedFieldName() : name;
	
	import final function GetFieldStrength( position : Vector ) : float;
	
	
	import final function SetFieldStrengthMultiplier( param : float );
	
	import final function GetFieldStrengthMultiplier() : float;

	
	import final function SetTestParameter( param : float );
	
	import final function GetTestParameter() : float;
};




import class CReactionScriptedCondition extends IReactionCondition
{
	function Perform( source : CNode, target : CNode, interestPoint : CInterestPointInstance ) : bool
	{
		
		return true;
	}
};

class CReactionRandomCondition extends CReactionScriptedCondition
{
	editable var percentageChance : int;

	function Perform( source : CNode, target : CNode, interestPoint : CInterestPointInstance ) : bool
	{		
		if ( (RandF() * 100.0f) < (float)percentageChance )
		{
			return true;
		}
		return false;
	}
};




import class CReactionScript extends IReactionAction
{
	function Perform( npc : CNewNPC, interestPoint : CInterestPointInstance, reactionIndex : int )
	{
		
	}
};