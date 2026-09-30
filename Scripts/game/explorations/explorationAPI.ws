/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SExplorationQueryContext
{
	import var inputDirectionInWorldSpace : Vector;
	import var maxAngleToCheck : float;
	import var forJumping : bool;
	
	import var dontDoZAndDistChecks : bool;
	import var laddersOnly : bool;
	import var forAutoTraverseSmall : bool;
	import var forAutoTraverseBig : bool;
	import var maxDistToCheck : float;
}

import struct SExplorationQueryToken 
{
	import var valid : bool;
	import var type : EExplorationType;
	import var pointOnEdge : Vector;
	import var normal : Vector;
	import var usesHands : bool;
	import var start : Vector; 
	import var end : Vector;
	import var isCart : bool;
	import var isRootLadder : bool;
}


function IsExplorationOneSided( exploration : SExplorationQueryToken ) : bool
{
	return exploration.type	== ET_Ladder 
		|| exploration.type	== ET_Fence_OneSided;
}

import class CExplorationComponent extends CComponent
{
	import var start : Vector;
	import var end : Vector;
}

import class CScriptedExplorationTraverser extends IScriptable
{
	import function Update( deltaTime : float );
	import function GetExplorationType( out expType : EExplorationType ) : bool;

	
	import final function AtEndOfLadder() : int;
	import final function IsAbove() : bool;
	import final function IsFrontside() : bool;
	import final function SideOfApproach() : float;
	import final function CheckWaterBelow() : bool;
	import final function AdjustStep() : void;
	import final function ShouldJumpOffLadder() : bool;
	import final function CalculateTargetPosition( out targetPosition : Vector, transStart : float, transDuration : float,  animName : name, aboveStart : bool, grabStart : bool, leftLegUp : bool ) : void;
	import final function CalculateTargetYaw( out targetYaw : float, rotStart : float, rotDuration : float,  animName : name ) : void;
	import final function CalculateEndTargetMotion( out targetPosition : Vector, transStart : float, transDuration : float, animName : name ) : bool;
	import final function CalculateInitialJumpYaw( out yawDiff : float, targetPosOffset : float );
	import final function GetExplorationComponent() : CExplorationComponent;
}

abstract class W3ExplorationObject extends CEntity
{
	event OnExplorationStarted( entity : CEntity );
	
	event OnExplorationFinished( entity : CEntity );
	
	event OnAnimationStarted( entity : CEntity, data : name );
	
	event OnAnimationFinished( entity : CEntity, data : name );
	
	event OnSlideFinished( entity : CEntity );
	
	event OnExplorationEvent( entity : CEntity, data : name );
}