/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EActionInfoType
{
	EAIT_ApproachAttack,
	EAIT_ApproachAttackEnd,
	EAIT_Attack,
	EAIT_AttackEnd,
	EAIT_BecomeAwareAndCanAttack,
	EAIT_BecomeUnawareOrCannotAttack,
	EAIT_BeingWarnedStart,
	EAIT_BeingWarnedStop,
	EAIT_CanFindPath,
	EAIT_CannotFindPath,
}

class CBTTaskSendInfo extends IBehTreeTask
{
	public var onIsAvailable 						: bool;
	public var onActivate 							: bool;
	public var onDectivate 							: bool;
	public var infoType								: EActionInfoType;
	public var useCombatTarget						: bool;
	public var distanceToBecomeUnawareOfOldTarget	: float;
	
	private var lastTarget							: CNode;
	
	function IsAvailable() : bool
	{
		if ( onIsAvailable )
			SendInfo();
		
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		if ( onActivate )
		{
			SendInfo();
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( onDectivate )
		{
			SendInfo();
		}
	}
	
	function GetTarget() : CActor
	{
		if ( useCombatTarget )
			return GetCombatTarget();
		else
			return (CActor)GetActionTarget();
	}
	
	function GetSender() : CActor
	{
		return GetActor();
	}
	
	function SendInfo ()
	{
		var sender : CActor = GetSender();
		var target : CActor = GetTarget();
		
		if ( !target )
			return;
		
		switch ( infoType )
		{
			case EAIT_ApproachAttack: 
				target.OnApproachAttack( sender );
				return;
			case EAIT_ApproachAttackEnd: 
				target.OnApproachAttackEnd( sender );
				return;
			case EAIT_Attack:
				target.OnAttack( sender );
				return;
			case EAIT_AttackEnd:
				target.OnAttackEnd( sender );
				return;
			case EAIT_BecomeAwareAndCanAttack:
				target.OnBecomeAwareAndCanAttack( sender );
				return;
			case EAIT_BecomeUnawareOrCannotAttack:
				target.OnBecomeUnawareOrCannotAttack( sender );
				return;
			case EAIT_CanFindPath:
				target.OnCanFindPath( sender );
				return;
			case EAIT_CannotFindPath:
				target.OnCannotFindPath( sender );
				return;
			case EAIT_BeingWarnedStart:
				if ( target == thePlayer) thePlayer.OnBeingWarnedStart( sender );
				return;
			case EAIT_BeingWarnedStop:
				if ( target == thePlayer) thePlayer.OnBeingWarnedStop( sender );
				return;
		}
	}	
}

class CBTTaskSendInfoDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSendInfo';

	editable var onIsAvailable		: bool;
	editable var onActivate 		: bool;
	editable var onDectivate 		: bool;
	editable var infoType			: EActionInfoType;
	editable var useCombatTarget	: bool;
	
	default useCombatTarget = true;
}

class CBTTaskStopMovingBack extends IBehTreeTask
{
	private var compTime : float;
	
	default compTime = 0.f;
	
	function IsAvailable() : bool
	{
		if ( GetLocalTime() < compTime )
		{
			return false;
		}
		return true;
	}
	
	function OnDeactivate()
	{
		compTime = 0.f;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'AttackedByPlayer' )
		{
			compTime = GetLocalTime() + 0.5f;
			Complete(false);
			return true;
		}
		
		return false;
	}
}

class CBTTaskStopMovingBackDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskStopMovingBack';
}
