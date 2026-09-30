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
}

import struct SExplorationQueryToken 
{
	import var valid : bool;
	import var type : EExplorationType;
	import var pointOnEdge : Vector;
	import var normal : Vector;
	import var usesHands : bool;
}


function IsExplorationOneSided( exploration : SExplorationQueryToken ) : bool
{
	return exploration.type	== ET_Ladder 
		|| exploration.type	== ET_Fence_OneSided;
}

import class	CScriptedExplorationTraverser extends IScriptable
{
	import function Update( deltaTime : float );
	import function GetExplorationType( out expType : EExplorationType ) : bool;
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
