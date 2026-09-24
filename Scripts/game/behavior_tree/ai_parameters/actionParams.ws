/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class IAIBaseAction extends IAIActionTree 
{
	editable var enterExplorationOnStart : bool;
	
	default enterExplorationOnStart = true;
};


class CAIFollowAction extends IAIBaseAction
{
	editable inlined var params : CAIFollowParams;
	
	default aiTreeName = "resdef:ai\scripted_actions/follow";

	function Init()
	{
		params = new CAIFollowParams in this;
		params.OnCreated();
	}
};

class CAIFollowParams extends IAIActionParameters
{
	
	
	
	editable var targetTag 				: CName;
	editable var moveType 				: EMoveType;
	editable var keepDistance 			: bool;
	editable var followDistance 		: float;
	editable var moveSpeed 				: float;
	editable var followTargetSelection 	: bool;
	editable var teleportToCatchup		: bool;
	editable var cachupDistance			: float;
	editable var rotateToWhenAtTarget	: bool;	
	

	default targetTag 				= "PLAYER";
	default moveType 				= MT_Walk;
	default moveSpeed 				= 1.0;
	default followDistance 			= 2.0;
	default keepDistance 			= true;
	default followTargetSelection 	= true;
	default teleportToCatchup		= false;
	default cachupDistance			= 75.0;
	default rotateToWhenAtTarget	= true;
	
	hint rotateToWhenAtTarget = "After reaching the follow distance, NPC will rotate towards the target";
	
	function Init()
	{
		super.Init();
	}
};



class CAIFollowSideBySideAction extends CAIFollowAction
{
	function Init()
	{
		super.Init();		
		customSteeringGraph 	= LoadSteeringGraph( "gameplay/behaviors/npc/steering/action/follow_side_by_side.w2steer" );
		params.followDistance 	= 0.25;
		params.moveType 		= MT_Sprint;
	}
	
	editable var useCustomSteering		: bool;
	editable var customSteeringGraph	: CMoveSteeringBehavior;
	
	default useCustomSteering 	= true;
};



class CAIRiderFollowAction extends IRiderActionTree
{
	editable inlined var params 		: CAIRiderFollowActionParams;
	
	default aiTreeName = "resdef:ai\scripted_actions/rider_follow";

	function Init()
	{
		params = new CAIRiderFollowActionParams in this;
		params.OnCreated();
	}
};


class CAIRiderFollowActionParams extends IRiderActionParameters
{
	editable var targetTag 				: CName;
	editable var moveType 				: EMoveType;
	editable var keepDistance 			: bool;
	editable var followDistance 		: float;
	editable var moveSpeed 				: float;
	editable var followTargetSelection 	: bool;
	editable var matchRiderMountStatus	: bool;
	
	default targetTag 				= "PLAYER";
	default moveType 				= MT_Walk;
	default moveSpeed 				= 1.0;
	default followDistance 			= 2.0;
	default keepDistance 			= true;
	default followTargetSelection 	= true;
	default matchRiderMountStatus	= true;
	
	
	function Init()
	{
		super.Init();
		followTargetSelection 	= false;		
	}
	
	
	
	
	function CopyTo( followParams : CAIFollowParams )
	{
		followParams.targetTag 				= targetTag;
		followParams.moveType 				= moveType;
		followParams.keepDistance 			= keepDistance;
		followParams.followDistance 		= followDistance;
		followParams.moveSpeed 				= moveSpeed;
		
	}
};




class CAIRiderFollowSideBySideAction extends IRiderActionTree
{

	
	editable inlined var params 		: CAIRiderFollowSideBySideActionParams;
	
	default aiTreeName = "resdef:ai\scripted_actions/rider_follow_side_by_side";

	function Init()
	{
		params = new CAIRiderFollowSideBySideActionParams in this;
		params.OnCreated();
	}
};



class CAIRiderFollowSideBySideActionParams extends CAIRiderFollowActionParams
{		
	editable var useCustomSteering			: bool;
	editable var customSteeringGraph		: CMoveSteeringBehavior;
	editable var horseCustomSteeringGraph	: CMoveSteeringBehavior;
	
	default useCustomSteering 			= true;
	
	function Init()
	{
		customSteeringGraph 		= LoadSteeringGraph( "gameplay/behaviors/npc/steering/action/follow_side_by_side.w2steer" );
		horseCustomSteeringGraph 	= LoadSteeringGraph( "gameplay/behaviors/npc/steering/action/horse_follow_side_by_side.w2steer" );
		followDistance 				= 0.0;
		moveType 					= MT_Sprint;
		
		super.Init();	
	}
	
	
	
	
	function CopyTo_SideBySide( followSideBySideAction : CAIFollowSideBySideAction )
	{
		super.CopyTo( followSideBySideAction.params );
		
		followSideBySideAction.useCustomSteering 		= true;
		followSideBySideAction.customSteeringGraph 		= horseCustomSteeringGraph;
	}
};



class CAIHorseDoNothingAction extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/horse_do_nothing";
};


class CAIDoNothingAction extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/horse_do_nothing";
};



class CAIMoveAlongPathAction extends IAIBaseAction
{	
	editable inlined var params : CAIMoveAlongPathParams;
	
	default aiTreeName = "resdef:ai\scripted_actions/move_along_path";
	
	function Init()
	{
		params = new CAIMoveAlongPathParams in this;
		params.OnCreated();
	}
	function OnPostLoad() : bool
	{
		if ( params && !params.steeringGraph )
		{
			params.steeringGraph = LoadSteeringGraph( "gameplay/behaviors/npc/steering/action/manual_pathfollow/manual_pathfollow.w2steer" );
			return true;
		}
		return false;
	}
};


class CAIMoveAlongPathParams extends IAIActionParameters
{
	
	
	
	editable var pathTag 				: CName;
	editable var upThePath 				: bool;
	editable var fromBeginning 			: bool;
	editable var pathMargin				: float;
	editable var moveTypeBeforePath		: EMoveType;
	editable var moveType 				: EMoveType;
	editable var moveSpeed				: float;
	editable var steeringGraph			: CMoveSteeringBehavior;
	editable var arrivalDistance		: Float;
	editable var rotateAfterReachStart 	: bool;
	editable var useExplorations 		: bool;
	editable var dontCareAboutNavigable	: bool;
	editable var tolerance				: float;
	
	default upThePath 				= true;
	default fromBeginning 			= true;
	default pathMargin 				= 1.25;
	default moveTypeBeforePath		= MT_Run;
	default moveType 				= MT_Run;
	default moveSpeed 				= 1.0;
	default arrivalDistance			= 0.5;
	default rotateAfterReachStart 	= true;
	default useExplorations 		= false;
	default dontCareAboutNavigable	= false;
	default tolerance				= 0.5;
	
	function Init()
	{
		super.Init();
		
		steeringGraph = LoadSteeringGraph( "gameplay/behaviors/npc/steering/action/manual_pathfollow/manual_pathfollow.w2steer" );
	}
};


class CAIMoveAlongPathWithCompanionAction extends CAIMoveAlongPathAction
{
	default aiTreeName = "resdef:ai\scripted_actions/move_along_path_companion";

	function Init()
	{
		params = new CAIMoveAlongPathWithCompanionParams in this;
		params.OnCreated();
	}
};

class CAIMoveAlongPathWithCompanionParams extends CAIMoveAlongPathParams
{
	editable var companionTag 						: CName;
	editable var maxDistance						: float;
	editable var minDistance						: float;
	editable var companionOffset					: float;
	editable var progressWhenCompanionIsAhead		: bool;
	editable var progressOnlyWhenCompanionIsAhead	: bool;
	editable var matchCompanionSpeed				: bool;
	editable var allowLeaderToRideOff				: bool;
	editable var moveTypeAfterMaxDistance			: EMoveType;
	
	default matchCompanionSpeed						= true;
	default companionTag 							= 'PLAYER';
	default maxDistance 							= 10.0f;
	default minDistance 							= 4.0f;
	default companionOffset							= -3.0f;
	default progressWhenCompanionIsAhead 			= false;
	default progressOnlyWhenCompanionIsAhead 		= false;
	default allowLeaderToRideOff					= false;
	default moveTypeAfterMaxDistance				= MT_Run;
};


class CAIMoveAlongPathAwareOfTailAction extends CAIMoveAlongPathAction
{
	default aiTreeName = "resdef:ai\scripted_actions/move_along_path_tail";

	function Init()
	{
		params = new CAIMoveAlongPathAwareOfTailParams in this;
		params.OnCreated();
	}
};

class CAIMoveAlongPathAwareOfTailParams extends CAIMoveAlongPathParams
{
	editable var tailTag					: CName;
	editable var startMovementDistance		: float;
	editable var stopDistance				: float;
	
	default tailTag 				= 'PLAYER';
	default startMovementDistance 	= 15.0f;
	default stopDistance 			= 10.0f;
};



class CAIRaceAlongPathAction extends CAIMoveAlongPathAction
{	
	default aiTreeName = "resdef:ai\scripted_actions/race_along_path";
	
	function Init()
	{
		params = new CAIRaceAlongPathParams in this;
		params.OnCreated();
	}
};


class CAIRaceAlongPathParams extends CAIMoveAlongPathParams
{
	function Init()
	{
		super.Init();
		
		steeringGraph = LoadSteeringGraph( "gameplay/behaviors/npc/steering/action/manual_pathfollow/manual_pathfollow_racing.w2steer" );
	}
};



class CAIRiderMoveAlongPathAction extends IRiderActionTree
{	
	default aiTreeName = "resdef:ai\scripted_actions/rider_move_along_path";
	
	editable inlined var params : CAIRiderMoveAlongPathActionParams;
	
	function Init()
	{
		params = new CAIRiderMoveAlongPathActionParams in this;
		params.OnCreated();
	}
};


class CAIRiderMoveAlongPathActionParams extends IRiderActionParameters
{
	editable var pathTag 				: CName;
	editable var upThePath 				: bool;
	editable var fromBeginning 			: bool;
	editable var pathMargin				: float;
	editable var moveTypeBeforePath		: EMoveType;
	editable var moveType 				: EMoveType;
	editable var moveSpeed				: float;
	editable var steeringGraph			: CMoveSteeringBehavior;
	editable var arrivalDistance		: Float;
	editable var rotateAfterReachStart 	: bool;
	editable var useExplorations 		: bool;	
	editable var dontCareAboutNavigable	: bool;
	editable var tolerance				: float;
	
	
	default upThePath 				= true;
	default fromBeginning 			= true;
	default pathMargin 				= 1.25;
	default moveTypeBeforePath		= MT_Run;
	default moveType 				= MT_Run;
	default moveSpeed 				= 1.0;
	default arrivalDistance			= 0.5;
	default rotateAfterReachStart 	= false;
	default useExplorations 		= false;
	default dontCareAboutNavigable 	= false;
	default tolerance				= 0.5;
	
	
	function Init()
	{		
		steeringGraph = LoadSteeringGraph( "gameplay/behaviors/npc/steering/action/manual_pathfollow/manual_pathfollow.w2steer" );
	}
	
	
	
	function CopyTo( moveAlongPathParams : CAIMoveAlongPathParams )
	{
		moveAlongPathParams.pathTag 				= pathTag;
		moveAlongPathParams.upThePath 				= upThePath;
		moveAlongPathParams.fromBeginning 			= fromBeginning;
		moveAlongPathParams.pathMargin 				= pathMargin;
		moveAlongPathParams.moveTypeBeforePath		= moveTypeBeforePath;
		moveAlongPathParams.moveType 				= moveType;
		moveAlongPathParams.moveSpeed 				= moveSpeed;
		moveAlongPathParams.steeringGraph 			= steeringGraph;
		moveAlongPathParams.arrivalDistance			= arrivalDistance;
		moveAlongPathParams.rotateAfterReachStart	= rotateAfterReachStart;
		moveAlongPathParams.useExplorations			= useExplorations;
		moveAlongPathParams.dontCareAboutNavigable	= dontCareAboutNavigable;
		moveAlongPathParams.tolerance				= tolerance;
	}
};


class CAIRiderMoveAlongPathWithCompanionAction extends CAIRiderMoveAlongPathAction
{
	default aiTreeName = "resdef:ai\scripted_actions/rider_move_along_path_companion";

	function Init()
	{
		params = new CAIRiderMoveAlongPathWithCompanionActionParams in this;
		params.OnCreated();
	}
};

class CAIRiderMoveAlongPathWithCompanionActionParams extends CAIRiderMoveAlongPathActionParams
{
	editable var companionTag 						: CName;
	editable var maxDistance						: float;
	editable var minDistance						: float;
	editable var companionOffset					: float;
	editable var progressWhenCompanionIsAhead		: bool;
	editable var progressOnlyWhenCompanionIsAhead	: bool;
	editable var matchCompanionSpeed				: bool;
	editable var allowLeaderToRideOff				: bool;
	editable var moveTypeAfterMaxDistance			: EMoveType;
	
	default matchCompanionSpeed						= true;	
	default companionTag 							= 'PLAYER';
	default maxDistance 							= 15.0f;
	default minDistance 							= 8.0f;
	default companionOffset							= -9.0f;
	default progressWhenCompanionIsAhead 			= false;
	default progressOnlyWhenCompanionIsAhead 		= false;
	default allowLeaderToRideOff					= false;
	default moveTypeAfterMaxDistance				= MT_Run;
	
	
	
	
	function CopyTo_2( moveAlongPathParams : CAIMoveAlongPathWithCompanionParams )
	{
		super.CopyTo( moveAlongPathParams );
		moveAlongPathParams.matchCompanionSpeed					= matchCompanionSpeed;
		moveAlongPathParams.companionTag 						= companionTag;
		moveAlongPathParams.maxDistance 						= maxDistance;
		moveAlongPathParams.minDistance 						= minDistance;
		moveAlongPathParams.companionOffset 					= companionOffset;
		moveAlongPathParams.progressWhenCompanionIsAhead 		= progressWhenCompanionIsAhead;
		moveAlongPathParams.progressOnlyWhenCompanionIsAhead 	= progressOnlyWhenCompanionIsAhead;
		moveAlongPathParams.allowLeaderToRideOff				= allowLeaderToRideOff;
		moveAlongPathParams.moveTypeAfterMaxDistance			= moveTypeAfterMaxDistance;
	}
};



class CAIRiderRaceAlongPathAction extends IRiderActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/rider_race_along_path";

	editable inlined var params : CAIRiderRaceAlongPathActionParams;
	function Init()
	{
		params = new CAIRiderRaceAlongPathActionParams in this;
		params.OnCreated();
	}
};



class CAIRiderRaceAlongPathActionParams extends IRiderActionParameters
{	
	editable var pathTag 				: CName;
	editable var upThePath 				: bool;
	editable var fromBeginning 			: bool;
	editable var pathMargin				: float;
	editable var tolerance				: float;
	editable var moveTypeBeforePath		: EMoveType;
	editable var moveType 				: EMoveType; 
	editable var moveSpeed				: float;
	editable var steeringGraph			: CMoveSteeringBehavior;
	editable var arrivalDistance		: Float;
	editable var rotateAfterReachStart	: Bool;	
	editable var dontCareAboutNavigable	: bool;
	
	default upThePath 				= true;
	default fromBeginning 			= true;
	default pathMargin 				= 1.25;
	default tolerance				= 0.5;
	default moveTypeBeforePath		= MT_Run;
	default moveType 				= MT_Run;
	default moveSpeed 				= 1.0;
	default arrivalDistance			= 0.5;
	default rotateAfterReachStart	= false;
	default dontCareAboutNavigable	= false;
	
	function Init()
	{
		super.Init();
		steeringGraph = LoadSteeringGraph( "gameplay/behaviors/npc/steering/action/manual_pathfollow/manual_pathfollow_racing.w2steer" );
	}
	
	
	
	function CopyTo( raceAlongPathParams : CAIRaceAlongPathParams )
	{
		raceAlongPathParams.pathTag 				= pathTag;
		raceAlongPathParams.upThePath 				= upThePath;
		raceAlongPathParams.fromBeginning 			= fromBeginning;
		raceAlongPathParams.pathMargin 				= pathMargin;
		raceAlongPathParams.tolerance 				= tolerance;
		raceAlongPathParams.moveTypeBeforePath		= moveTypeBeforePath;
		raceAlongPathParams.moveType 				= moveType;
		raceAlongPathParams.moveSpeed 				= moveSpeed;
		raceAlongPathParams.steeringGraph 			= steeringGraph;
		raceAlongPathParams.arrivalDistance			= arrivalDistance;
		raceAlongPathParams.steeringGraph 			= steeringGraph;
		raceAlongPathParams.rotateAfterReachStart	= rotateAfterReachStart;
		raceAlongPathParams.dontCareAboutNavigable	= dontCareAboutNavigable;
	}
};




class CAIRiderRideHorseAction extends IRiderActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/rider_ride_horse";

	function Init()
	{
	}
	
	function CopyTo( horseDoNothingAction : CAIHorseDoNothingAction )
	{
		
	}
};
abstract class ISailorActionTree extends IAIActionTree
{
};
abstract class ISailorActionParameters extends IAIActionParameters
{
};



class CAISailorMountBoatAction extends ISailorActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/sailor_mount_boat";

	editable inlined var params : CAISailorMountBoatActionParams;
	
	function Init()
	{
		params = new CAISailorMountBoatActionParams in this;
		params.OnCreated();
	}
};



class CAISailorMountBoatActionParams extends ISailorActionParameters
{
	editable var boatTag 			: CName;
	function Init()
	{
		super.Init();
	}
};



class CAISailorDismountBoatAction extends ISailorActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/sailor_dismount_boat";

	editable var teleportHere		: CName;
};



class CAISailorMoveToAction extends ISailorActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/sailor_move_to";

	editable inlined var params : CAISailorMoveToActionParams;
	
	function Init()
	{
		params = new CAISailorMoveToActionParams in this;
		params.OnCreated();
	}
};



class CAISailorMoveToActionParams extends ISailorActionParameters
{
	editable var boatTag 			: CName;
	editable var entityTag 			: CName;
	
	function Init()
	{
		super.Init();
	}
};


class CAISailorMoveAlongPathAction extends ISailorActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/sailor_move_along_path";

	editable inlined var params : CAISailorMoveAlongPathActionParams;
	
	function Init()
	{
		params = new CAISailorMoveAlongPathActionParams in this;
		params.OnCreated();
	}
};



class CAISailorMoveAlongPathActionParams extends ISailorActionParameters
{
	editable var boatTag 			: CName;
	editable var pathTag 			: CName;
	editable var upThePath 			: bool;
	editable var startFromBeginning : bool;
	
	default upThePath 			=  true;
	default startFromBeginning 	= true;
	function Init()
	{
		super.Init();
	}
};


class CAISailorRaceAlongPathAction extends ISailorActionTree
{	
	default aiTreeName = "resdef:ai\scripted_actions/sailor_race_along_path";

	editable inlined var params : CAISailorRaceAlongPathActionParams;
	
	function Init()
	{
		params = new CAISailorRaceAlongPathActionParams in this;
		params.OnCreated();
	}
};



class CAISailorRaceAlongPathActionParams extends ISailorActionParameters
{
	editable var boatTag 			: CName;
	editable var pathTag 			: CName;
	editable var upThePath 			: bool;
	editable var startFromBeginning : bool;
	
	default upThePath 			=  true;
	default startFromBeginning 	= true;
	function Init()
	{
		super.Init();
	}
};



class CAIMoveToPoint extends IAIBaseAction
{
	default aiTreeName = "resdef:ai\scripted_actions/move_to_point";

	editable inlined var params : CAIMoveToPointParams;
	
	function Init()
	{
		params = new CAIMoveToPointParams in this;
		params.OnCreated();
	}
};


class CAIMoveToPointParams extends IAIActionParameters
{
	editable var maxDistance 			: float;
	editable var moveSpeed 				: float;
	editable var moveType 				: EMoveType;
	editable var destinationPosition	: Vector;
	editable var destinationHeading		: float;
	editable var maxIterationsNumber	: int;
	editable var useTimeout				: bool;
	editable var timeoutValue			: float;
	
	default maxDistance 		= 1.0;
	default moveSpeed 			= 1.0;
	default moveType 			= MT_Walk;
	default maxIterationsNumber = 1;
};



class CAIMoveToAction extends IAIBaseAction
{
	default aiTreeName = "resdef:ai\scripted_actions/move_to";

	editable inlined var params : CAIMoveToParams;
	
	function Init()
	{
		params = new CAIMoveToParams in this;
		params.OnCreated();
	}
};


class CAIMoveToParams extends IAIActionParameters
{
	
	
	
	editable var maxDistance 		: float;
	editable var moveSpeed 			: float;
	editable var moveType 			: EMoveType;
	editable var targetTag 			: CName;
	editable var rotateAfterwards 	: bool;
	editable var tolerance			: float;
	
	default maxDistance 		= 1.0;
	default moveSpeed 			= 1.0;
	default moveType 			= MT_Walk;
	default rotateAfterwards 	= true;
	default tolerance			= 0.0;
};

class CAIMoveToActionAwareOfTail extends IAIBaseAction
{
	default aiTreeName = "resdef:ai\scripted_actions\move_to_tail";
	
	editable inlined var params : CAIMoveToActionAwareOfTailParams;

	function Init()
	{
		params = new CAIMoveToActionAwareOfTailParams in this;
		params.OnCreated();
	}
};

class CAIMoveToActionAwareOfTailParams extends CAIMoveToParams
{
	editable var tailTag					: CName;
	editable var startMovementDistance		: float;
	editable var stopDistance				: float;
	
	default tailTag 				= 'PLAYER';
	default startMovementDistance 	= 15.0f;
	default stopDistance 			= 10.0f;
};



class CAIRiderMoveToAction extends IRiderActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/rider_move_to";

	editable inlined var params : CAIRiderMoveToActionParams;
	
	function Init()
	{
		params = new CAIRiderMoveToActionParams in this;
		params.OnCreated();
	}
};


class CAIRiderMoveToActionParams extends IRiderActionParameters
{
	editable var maxDistance 		: float;
	editable var moveSpeed 			: float;
	editable var moveType 			: EMoveType;
	editable var targetTag 			: CName;
	editable var rotateAfterwards 	: bool;
	
	default maxDistance 		= 1.0;
	default moveSpeed 			= 1.0;
	default moveType 			= MT_Walk;
	default rotateAfterwards 	= true;
	
	
	
	
	function CopyTo( moveToParams : CAIMoveToParams )
	{
		moveToParams.maxDistance 		= maxDistance;
		moveToParams.moveSpeed 			= moveSpeed;
		moveToParams.moveType 			= moveType;
		moveToParams.targetTag 			= targetTag;
		moveToParams.rotateAfterwards 	= rotateAfterwards;
	}
};


class CAIPlayAnimationStateAction extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/play_animation";
	
	editable var eventStateName	: CName;	
};

class CAIPlayAnimationStateParams extends IAIActionParameters
{
	editable var eventStateName: CName;
};


class CAIPlayAnimationSlotAction extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/play_animation_slot";

	editable var animName: CName;
	editable var slotName: CName;
	editable var blendInTime: float;
	editable var blendOutTime: float;
	
	
	default blendInTime = 1.0f;
	default blendOutTime = 1.0f;	
	default slotName = 'NPC_ANIM_SLOT';
};





abstract class IAIFormationActionTree extends IAIBaseAction
{
	editable var formation : CFormation;
};

class CAIFormationFollowActionTree extends IAIFormationActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/follow_leader_by_tag";

	editable var leaderTag : name;
};

class CAIFormationLeadActionTree extends IAIFormationActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/lead_formation";
	
	editable var leaderSteering : CMoveSteeringBehavior;
	editable var reshapeOnMoveAction : Bool;
	editable inlined var leadSubtree : IAIActionTree;
	
	function Init()
	{
		leaderSteering = LoadSteeringGraph( "gameplay/behaviors/npc/formation/steering_leader/leader_default.w2steer" );
		reshapeOnMoveAction = true;
	}
};


class CAIFinishAnimationsAction extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/finish_slot_animations";
};


class CAIBreakAnimationsAction extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/break_slot_animations";
};


class CAIPlayVoiceSetAction extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/play_voice_set";
	
	editable var voiceSet : string;
	editable var priority : int;
};

class CAIPlayVoiceSetParams extends IAIActionParameters
{
	editable var voiceSet : string;
	editable var priority : int;
};


class CAIRotateToAction extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/rotate_towards";
	
	editable var targetTag : CName;
	editable var keepRotating : bool;
};


class CAIWalkToTargetWaitAction extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/walk_to_target";

	editable inlined var params : CAIWalkToTargetWaitParams;
	
	function Init()
	{
		params = new CAIWalkToTargetWaitParams in this;
		params.OnCreated();
	}
};

class CAIWalkToTargetWaitParams extends IAIActionParameters
{
	editable var tag : CName;
	
	editable var maxDistance : float;
	editable var moveSpeed : float;
	editable var moveType : EMoveType;
		
	editable var waitForTag : CName;	
	editable var timeout : float;
	editable var testDistance : float;
	
	default maxDistance = 3.0;
	default moveSpeed = 1.0;
	default moveType = MT_Walk;
		
	default testDistance = 10.0;
};


import class CAIActionSequence extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/action_sequence";
};

class CAIActionSequenceParams extends IAIActionParameters
{
	editable inlined var actions : array<IAIActionTree>;
};


class CAIActionLoop extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/loop";
	
	editable var loopCount : int;
	editable inlined var loopedAction : IAIActionTree;
	
	default loopCount = 0;
};


class CAISyannaCompanionBehavior extends IAIBaseAction
{
	editable inlined var params : CAISyannaCompanionBehaviorParams;
	editable var useCustomSteering		: bool;
	editable var customSteeringGraph	: CMoveSteeringBehavior;
	default useCustomSteering 	= true;
	
	default aiTreeName = "dlc\bob\data\gameplay\trees\scripted_actions\syanna_companion.w2behtree";

	function Init()
	{
		params = new CAISyannaCompanionBehaviorParams in this;
		params.OnCreated();
		
		customSteeringGraph 	= LoadSteeringGraph( "dlc\bob\data\gameplay\behaviors\steering\syanna_follow.w2steer" );
		params.followDistance 	= 0.25;
		params.moveType 		= MT_Sprint;
	}
};

class CAISyannaCompanionBehaviorParams extends IAIActionParameters
{  
	editable var targetTag 					: CName;
	editable var moveType 					: EMoveType;
	editable var keepDistance 				: bool;
	editable var followDistance 			: float;
	editable var moveSpeed 					: float;
	editable var followTargetSelection 		: bool;
	editable var teleportToCatchup			: bool;
	editable var cachupDistance				: float;
	editable var rotateToWhenAtTarget		: bool;
	
	editable var idleTimeToPlaySlotAnim 	: float;
	editable var slotAnimCooldown			: float;
	editable var slotName					: name;
	editable var animName_1_start			: CName;
	editable var animName_1_loop			: CName;
	editable var animName_1_stop			: CName;
	editable var animName_2_start			: CName;
	editable var animName_2_loop			: CName;
	editable var animName_2_stop			: CName;
	editable var animName_3_start			: CName;
	editable var animName_3_loop			: CName;
	editable var animName_3_stop			: CName;
	editable var animName_4_start			: CName;
	editable var animName_4_loop			: CName;
	editable var animName_4_stop			: CName;
	
	default targetTag 				= "PLAYER";
	default moveType 				= MT_Walk;
	default moveSpeed 				= 1.0;
	default followDistance 			= 2.0;
	default keepDistance 			= true;
	default followTargetSelection 	= true;
	default teleportToCatchup		= true;
	default cachupDistance			= 30.0;
	default rotateToWhenAtTarget	= true;
	
	default idleTimeToPlaySlotAnim = 10.0;
	default slotAnimCooldown = 5.0;
	default slotName = "NPC_ANIM_SLOT";
	
	hint rotateToWhenAtTarget = "After reaching the follow distance, NPC will rotate towards the target";
	hint animName_1_start = "Fill ALL animation names, even if you have only one.";
	hint animName_1_loop = "Fill ALL animation names, even if you have only one.";
	hint animName_1_end = "Fill ALL animation names, even if you have only one.";
	
	function Init()
	{
		super.Init();
	}
};



class CAIActionPoke extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/action_poke";

	editable var pokeEvent 						: name;
	editable inlined var pokableScriptedAction 	: IAIActionTree;
};


class CAIRiderActionSequence extends IRiderActionTree
{	
	default aiTreeName = "resdef:ai\scripted_actions/action_sequence";
	editable inlined var actions : array<IRiderActionTree>;
};


class CAIRiderActionPoke extends IRiderActionTree
{	
	default aiTreeName = "resdef:ai\scripted_actions/action_poke";
	editable var pokeEvent 						: name;
	editable inlined var pokableScriptedAction 	: IRiderActionTree;
};



class CAIWalkToTargetWaitingForActorAction extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/walk_to_target_wait";

	editable var tag : CName;
	
	editable var maxDistance : float;
	editable var moveSpeed : float;
	editable var moveType : EMoveType;
		
	editable var waitForTag : CName;	
	editable var timeout : float;
	editable var testDistance : float;
	
	default maxDistance = 3.0;
	default moveSpeed = 1.0;
	default moveType = MT_Walk;
	default testDistance = 10.0;
};



class CAIPlayEffectAction extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/play_effect";

	editable var effectName : CName;
};


class CAIPlayEffectParams extends IAIActionParameters
{
	editable var effectName : CName;
};



class CAIExecuteAttackAction extends IAIActionTree
{
	editable var attackParameter : EAttackType;
	
	default aiTreeName = "resdef:ai\scripted_actions/action_attack";
};



class CAIExecuteRangeAttackAction extends IAIActionTree
{
	editable var attackParameter 	: EAttackType;
	editable var targetTag			: name;
	editable var projectileName		: name;
	
	hint attackParameter = "Attack type being considered a 'range' attack";
	
	default aiTreeName = "resdef:ai\scripted_actions/action_range_attack";
};





class CAIDrawTorchAction extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/draw_torch";
};



class CAIHideTorchAction extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/hide_torch";
};




class CAIAttachToCurve extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/attach_to_curve";
	
	editable var animationName		: name;
	editable var curveTag			: name;
	editable var curveDummyName		: string;
	editable var blendInTime		: float;
	editable var slotAnimation		: name;
	
	default animationName			= 'Move';
	default blendInTime				= 2.0; 
};



class CAIWaitForChangingWeaponEndAction extends IAIActionTree
{
	default aiTreeName = "resdef:ai\scripted_actions/wait_for_changing_weapon_end";
};

abstract class IActionDecorator extends IAIActionTree
{
	editable inlined var scriptedAction 		: IAIActionTree;
};



class CAIGoToExplorationActionDecorator extends IActionDecorator
{
	default aiTreeName = "resdef:ai\scripted_actions\go_to_exploration_action_decorator";
	
	editable var sheathWeaponsOnStart : bool;
	
	default sheathWeaponsOnStart = true;
};



class CAIPlayAnimationUpperBodySlotAction extends IActionDecorator
{
	default aiTreeName = "resdef:ai\scripted_actions\play_animation_upper_body_slot";

	editable var animName: CName;
	editable var interruptScriptedActionOnSlotAnimEnd : bool;
	
};



class CAIHandsBehindBackOverlayActionTree extends IActionDecorator
{
	default aiTreeName = "resdef:ai\scripted_actions\hands_behind_back_overlay";
	
	editable var duration : float;	default duration = -1.f;
	editable var interruptScriptedActionOnDurationEnd : bool;
};



class CAICombatModeActionDecorator extends IActionDecorator
{
	default aiTreeName = "resdef:ai\scripted_actions\combat_mode_action_decorator";
	
	editable var drawWeaponOnStart 				: bool;
	editable var LeftItemType 					: name;
	editable var RightItemType 					: name;
	
	editable var changeBehaviorGraphOnStart 	: bool;
	editable var behGraph 						: EBehaviorGraph;
	
	editable var changeBahviorGraphToExplorationOnDeacitvate : bool;
	
	editable var forceCombatModeOnPLAYER 		: bool;
	
	hint LeftItemType 				= "only available when <drawWeaponOnStart> is TRUE";
	hint RightItemType 				= "only available when <drawWeaponOnStart> is TRUE";
	hint chooseSilverIfPossible 	= "only available when <drawWeaponOnStart> is TRUE";
	hint behGraph 					= "only available when <changeBehaviorGraphOnStart> is TRUE";
};



class CAIInterruptableByHitAction extends IActionDecorator
{
	default aiTreeName = "resdef:ai\scripted_actions/hit_interruptable_action";
	
	editable var shouldForceHitReaction 		: bool;
	editable var hitReactionType				: EHitReactionType;
	editable var hitReactionSide				: EHitReactionSide;
	editable var hitReactionDirection			: EHitReactionDirection;
	editable var hitSwingType					: EAttackSwingType;
	editable var hitSwingDirection				: EAttackSwingDirection;
	
	hint shouldForceHitReaction = "if the actor gets hit, play a specific hit reaction instead of the usual one";
	
}



class CAIInterruptOnHitOrOnCriticalEffect extends IActionDecorator
{
	default aiTreeName = "resdef:ai\scripted_actions\decorator_interrupt_on_hit_or_on_critical_effect";
	
	editable var completeOnHit 					: bool;
	editable var completeOnCriticalEffect		: bool;
	
	default completeOnHit = true;
	default completeOnCriticalEffect = true;
}



class CAIkLookAtActionDecorator extends IActionDecorator
{
	default aiTreeName = "resdef:ai\scripted_actions\lookat_action_decorator";
	
	editable var lookAtNodeTag : name;
};



class CAIChangeBehaviorGraphDecorator extends IActionDecorator
{
	default aiTreeName = "resdef:ai\scripted_actions\change_behavior_graph";
	
	editable var graphWhenActivate 		: name;
	editable var graphWhenDeactivate 	: name;
}



class CAIScaredActionDecorator extends IActionDecorator
{
	default aiTreeName = "resdef:ai\scripted_actions\scared_action_decorator.w2behtree";
}


class CAICustomSpawnActionDecorator extends IActionDecorator
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_banshee_summon_spawn.w2behtree";
}





abstract class IPlayerActionDecorator extends IAIActionTree
{
	editable inlined var scriptedAction : CAITree;
};

abstract class IPlayerRiderActionDecorator extends IAIActionTree
{
	editable inlined var scriptedAction : IRiderActionTree;
};

class CAIPlayerActionDecorator extends IPlayerActionDecorator
{
	default aiTreeName = "resdef:ai\scripted_actions\player_action_decorator";
	
	editable var interruptOnInput : bool;
	
	default interruptOnInput = true;
};

class CAIPlayerRiderActionDecorator extends IPlayerRiderActionDecorator
{
	default aiTreeName = "resdef:ai\scripted_actions\player_action_decorator";
	
	editable var interruptOnInput : bool;
	
	default interruptOnInput = true;
};
