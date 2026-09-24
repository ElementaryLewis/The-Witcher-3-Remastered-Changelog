/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ActorLatentActionMoveAlongPath extends IPresetActorLatentAction
{
	default resName = "resdef:ai\scripted_actions/move_along_path";
	
	editable var pathTag 		: CName;
	editable var upThePath 		: bool;
	editable var fromBeginning 	: bool;
	editable var pathMargin		: float;
	editable var moveType 		: EMoveType;
	editable var moveSpeed		: float;
	editable var dontCareAboutNavigable	: bool;
	
	default upThePath = true;
	default fromBeginning = true;
	default pathMargin = 1.25;
	default moveType = MT_Run;
	default moveSpeed = 1.0;
	default dontCareAboutNavigable	= false;
	
	function ConvertToActionTree( parentObj : IScriptable ) : IAIActionTree
	{
		var action : CAIMoveAlongPathAction;
		action = new CAIMoveAlongPathAction in parentObj;
		action.OnCreated();
		
		action.params.pathTag 					= pathTag;
		action.params.upThePath 				= upThePath;
		action.params.fromBeginning 			= fromBeginning;
		action.params.pathMargin				= pathMargin;
		action.params.moveType 					= moveType;
		action.params.moveSpeed					= moveSpeed;
		action.params.dontCareAboutNavigable 	= dontCareAboutNavigable;
		action.params.steeringGraph				= NULL;
		action.params.arrivalDistance			= 0.5;
		action.params.rotateAfterReachStart 	= true;		
		
		return action;
	}
}

class W3ActorLatentActionMoveAlongPathWithCompanion extends W3ActorLatentActionMoveAlongPath
{
	default resName = "resdef:ai\scripted_actions/move_along_path_companion";
	
	editable var companionTag 						: CName;
	editable var maxDistance						: float;
	editable var minDistance						: float;
	editable var progressWhenCompanionIsAhead		: bool;
	
	default companionTag = 'PLAYER';
	default maxDistance = 10.0f;
	default minDistance = 4.0f;
	default progressWhenCompanionIsAhead = false;
	
			
	
	function ConvertToActionTree( parentObj : IScriptable ) : IAIActionTree
	{
		var action : CAIMoveAlongPathWithCompanionAction;
		var params : CAIMoveAlongPathWithCompanionParams;
		action = new CAIMoveAlongPathWithCompanionAction in parentObj;
		action.OnCreated();
		
		params = (CAIMoveAlongPathWithCompanionParams)action.params;
		
		params.pathTag 					= pathTag;
		params.upThePath 				= upThePath;
		params.fromBeginning 			= fromBeginning;
		params.pathMargin				= pathMargin;
		params.moveType 				= moveType;
		params.moveSpeed				= moveSpeed;
		params.steeringGraph			= NULL;
		params.arrivalDistance			= 0.5;
		params.rotateAfterReachStart	= true;
		params.dontCareAboutNavigable	= dontCareAboutNavigable;
		
		params.companionTag 				= companionTag;
		params.maxDistance					= maxDistance;
		params.minDistance					= minDistance;
		params.progressWhenCompanionIsAhead	= progressWhenCompanionIsAhead;
		
		return action;
	}
}

class W3ActorLatentActionMoveAlongPathAwareOfTail extends W3ActorLatentActionMoveAlongPath
{
	default resName = "resdef:ai\scripted_actions/move_along_path_tail";
	
	editable var tailTag					: CName;
	editable var startMovementDistance		: float;
	editable var stopDistance				: float;
	
	default tailTag = 'PLAYER';
	default startMovementDistance = 15.0f;
	default stopDistance = 10.0f;
	
	function ConvertToActionTree( parentObj : IScriptable ) : IAIActionTree
	{
		var action : CAIMoveAlongPathAwareOfTailAction;
		var params : CAIMoveAlongPathAwareOfTailParams;
		
		action = new CAIMoveAlongPathAwareOfTailAction in parentObj;
		action.OnCreated();
		
		params = (CAIMoveAlongPathAwareOfTailParams)action.params;
		
		params.pathTag 					= pathTag;
		params.upThePath 				= upThePath;
		params.fromBeginning 			= fromBeginning;
		params.pathMargin				= pathMargin;
		params.moveType 				= moveType;
		params.moveSpeed				= moveSpeed;
		params.steeringGraph			= NULL;
		params.arrivalDistance			= 0.5;
		params.rotateAfterReachStart	= true;
		params.dontCareAboutNavigable	= dontCareAboutNavigable;
		
		params.tailTag					= tailTag;
		params.startMovementDistance	= startMovementDistance;
		params.stopDistance				= stopDistance;
		
		return action;
	}
}



