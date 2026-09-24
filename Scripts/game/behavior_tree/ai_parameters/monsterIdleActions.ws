/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class CAIMonsterIdleAction extends IAIActionTree
{
	editable inlined var params : CAIMonsterIdleActionParams;

	function Init()
	{
		params = new CAIMonsterIdleActionParams in this;
		params.Init();
	}
};


abstract class CAIMonsterFlyIdleAction extends CAIMonsterIdleAction
{
	function Init()
	{
		params = new CAIMonsterFlyIdleActionParams in this;
		params.Init();
	}
};


class CAIMonsterIdleActionParams extends CAISubTreeParameters
{
	editable var cooldown 		: float;
	editable var loopTime 		: float;
	editable var actionName		: name;
	editable var onlyOnGround 	: bool;
	
	default cooldown = 5.0;
	default onlyOnGround = true;
};


class CAIMonsterFlyIdleActionParams extends CAIMonsterIdleActionParams
{
	editable var minDistanceFromGround 		: float;
};


class CAIMonsterIdleEat extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.cooldown = 20.0;
		params.loopTime = 10.0;
		params.actionName = 'Eat';
		
	}
};


class CAIMonsterIdleDig extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.loopTime = 10.0;
		params.actionName = 'Dig';
		
	}
};


class CAIMonsterIdleClean extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.loopTime = 5.0;
		params.actionName = 'Clean';
	}
};


class CAIMonsterIdleOnGroundAndClean extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.cooldown = 100.0;
		params.loopTime = 30.0;
		params.actionName = 'OnGroundAndClean';
	}
};


class CAIMonsterIdleSit extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.cooldown = 60.0;
		params.loopTime = 30.0;
		params.actionName = 'Sit';
	}
};


class CAIMonsterIdleLie extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.cooldown = 60.0;
		params.loopTime = 30.0;
		params.actionName = 'Lie';
	}
};


class CAIMonsterIdleOnGround extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.cooldown = 60.0;
		params.loopTime = 30.0;
		params.actionName = 'OnGround';
	}
};


class CAIMonsterIdleHowl extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_howl";

	function Init()
	{
		super.Init();
		
		params.cooldown = 60.0;
		params.loopTime = 5.0;
	}
};


class CAIMonsterIdleSleep extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.cooldown = 200.0;
		params.loopTime = 100.0;
		params.actionName = 'Sleep';
	}
};


class CAIMonsterIdleRoll extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.actionName = 'Roll';
	}
};


class CAIMonsterIdleStretch extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.actionName = 'Stretch';
	}
};


class CAIMonsterIdleCough extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.actionName = 'Cough';
	}
};


class CAIMonsterIdleStrikeFists extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.actionName = 'StrikeFists';
	}
};


class CAIMonsterIdleGrowl extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.actionName = 'Growl';
	}
};


class CAIMonsterIdleWings extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.actionName = 'Wings';
	}
};


class CAIMonsterIdleLookAround extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		params.cooldown = 0;
		params.actionName = 'LookAround';
	}
};


class CAIMonsterIdleYawn extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.actionName = 'Yawn';
	}
};


class CAIMonsterIdleSniff extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.actionName = 'Sniff';
	}
};


class CAIMonsterIdleTail extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.cooldown = 20.0;
		params.loopTime = 10.0;
		params.actionName = 'Tail';
	}
};




class CAIMonsterIdleFlyBarrel extends CAIMonsterFlyIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_flying_idle_action_slot";

	function Init()
	{
		super.Init();		
		params.actionName = 'FlyBarrel';
	}
};


class CAIMonsterIdleFlyAirDive extends CAIMonsterFlyIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_flying_idle_action_slot";

	function Init()
	{
		var flyingParams : CAIMonsterFlyIdleActionParams;
		super.Init();		
		params.actionName = 'FlyAirDive';
		flyingParams = ((CAIMonsterFlyIdleActionParams) params);
		flyingParams.minDistanceFromGround = 13;
	}
};


class CAIMonsterIdlePlayAround extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_play_around_idle";

	function Init()
	{
		super.Init();		
		params.cooldown = 10.0;
	}
};


class CAIAnimalRunWild extends CAIDynamicWander
{
	editable var packRegroupEvent 	: name;
	editable var leaderRegroupEvent : name;
	
	default aiTreeName = "resdef:ai\idle/animal_run_wild_idle";
	
	default packRegroupEvent 	= 'PackRunsWild';
	default leaderRegroupEvent 	= 'LeaderMoves';
	
	default dynamicWanderMoveDuration = 15;
};



class CAIMonsterIdleFlyOnCurve extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_fly_on_curve";

	function Init()
	{
		super.Init();
		
		this.params = new CAIMonsterIdleFlyOnCurveParamsDefault in this;
		this.params.Init();
	}
};


class CAIMonsterIdleFlyOnCurveParamsDefault extends CAIMonsterIdleActionParams
{
	editable var curveTag				: name;
	editable var rotateBeforeTakeOff	: bool;
	
	editable var animationName			: name;
	editable var curveDummyName			: string;
	editable var blendInTime			: float;
	editable var slotAnimation			: name;
		
	editable var animValPitch			: string;
	editable var animValYaw				: string;
	editable var maxPitchInput			: float;
	editable var maxPitchOutput			: float;
	editable var maxYawInput			: float;
	editable var maxYawOutput			: float;
	

	default animationName			= 'Move';
	default blendInTime				= 2.0;
	
	default animValPitch			= "FlyPitch";
	default animValYaw				= "FlyYaw";
	default maxPitchInput			= 15.0;
	default maxPitchOutput			= 1.0;
	default maxYawInput				= 30.0;
	default maxYawOutput			= 1.0;
};