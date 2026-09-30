/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CTicketsDefaultConfiguration extends CObject
{
	import function SetupTicketSource( ticketName : name, ticketPoolSize : int, minimalImportance : float );

	private function Init()
	{
		SetupTicketSource( 'TICKET_Melee', 100, 100.0, );
		SetupTicketSource( 'TICKET_Charge', 100, 100.0, );
		SetupTicketSource( 'TICKET_Special', 100, 100.0 );
		SetupTicketSource( 'TICKET_Taunt', 100, 100.0 );
		SetupTicketSource( 'TICKET_Range', 100, 100.0 );
		SetupTicketSource( 'TICKET_Aim', 100, 100.0 );
		SetupTicketSource( 'TICKET_Approach', 100, 100.0 );
		SetupTicketSource( 'TICKET_Swim', 100, 100.0 );
		SetupTicketSource( 'TICKET_ReactionScene', 5, 0.0 );
		SetupTicketSource( 'TICKET_PreCombatWarning', 100, 0.0 );
		SetupTicketSource( 'TICKET_Tutorial', 100, 0.0 );
	}
};





import abstract class ITicketAlgorithmScriptDefinition extends IBehTreeObjectDefinition
{
};

import abstract class ITicketAlgorithmScript extends IScriptable
{
	import final function GetActor() : CActor;
	import final function GetNPC() : CNewNPC;
	import final function GetLocalTime() : float;
	import final function GetActionTarget() : CNode;
	import final function GetCombatTarget() : CActor;
	import final function GetTimeSinceMyAcquisition() : float;
	import final function GetTimeSinceAnyAcquisition() : float;
	import final function IsActive() : bool;
	import final function HasTicket() : bool;
	
	import var overrideTicketsCount : int;

	public function CalculateTicketImportance() : float
	{
		return 1.f;
	}
};





class CTicketAlgorithmSimple extends ITicketAlgorithmScript
{
	public function CalculateTicketImportance() : float
	{
		return 100.f;
	}
}
class CTicketAlgorithmSimpleDefinition extends ITicketAlgorithmScriptDefinition
{
	default instanceClass = 'CTicketAlgorithmSimple';
};




class CTicketAlgorithmCheckHP extends ITicketAlgorithmScript
{
	public function CalculateTicketImportance() : float
	{
		var actor : CActor = GetActor();
		
		if(actor.UsesEssence())
			return actor.GetStatPercents(BCS_Essence);
		else
			return actor.GetStatPercents(BCS_Vitality);
	}
};

class CTicketAlgorithmCheckHPDefinition extends ITicketAlgorithmScriptDefinition
{
	default instanceClass = 'CTicketAlgorithmCheckHP';
};





abstract class CTicketBaseAlgorithm extends ITicketAlgorithmScript
{
	protected var resetImportanceOnSpecialCombatAction : bool;
	
	public var threatLevelBonus : float;
	public var activationBonus : float;
	
	
	function ShouldAskForTicket() : bool
	{
		var target 				: CActor = GetCombatTarget();
		var owner 				: CActor = GetActor();
		var morale : float;
		var playerState : name;
		
		if ( target == thePlayer )
		{
			playerState = thePlayer.substateManager.GetStateCur();
			
			if ( playerState == 'Climb' || playerState == 'Interaction' )
			{
				return false;
			}
			
			if ( thePlayer.IsInHitAnim() )
				return false;
				
			if ( thePlayer.IsCurrentlyDodging() )
				return false;
			
			if ( resetImportanceOnSpecialCombatAction && ((W3PlayerWitcher)target) )
			{
				if ( ((W3PlayerWitcher)target).IsInCombatAction_SpecialAttackHeavy() )
					return false;
			}
			
			if ( thePlayer.IsPerformingFinisher() )
				return false;
				
			
			
		}
		
		
		
		
		
		if ( !( ( CNewNPC ) owner ).CanAttackKnockeddownTarget() && ( target.HasBuff(EET_Knockdown) || target.HasBuff(EET_HeavyKnockdown) ) )
		{
			return false;
		}
		
		
		morale = owner.GetStatPercents(BCS_Morale);
		if( morale != -1 && morale < 1.f )
			return false;
		
		
		if ( owner == thePlayer.GetTarget() && thePlayer.IsInCombatAction_Attack() && !thePlayer.GetBIsInputAllowed() )
		{
			return false;
		}
		
		
		if ( target != thePlayer && !target.GetGameplayVisibility() && !owner.HasTag( 'regis' ) ) 
		{
			return false;
		}
		
		return true;
	}
	
	
	function GetDistanceImportance() : float
	{
		var distance : float;
		
		distance = VecDistance(GetActor().GetWorldPosition(),GetCombatTarget().GetWorldPosition());
		
		if ( distance <= 2 )
			return 500;
		
		return ClampF(100 * ( 1.0f - ( distance / 100 )), 0, 100);
	}
	
	
	function GetInvertedDistanceImportance() : float
	{
		var distance : float;
		
		distance = VecDistance(GetActor().GetWorldPosition(),GetCombatTarget().GetWorldPosition());
		
		return ClampF( 100 * ( distance / 100 ), 0, 100);
	}
	
	
	function GetThreatLevelImportance() : float
	{
		var threatLevel : float;
		
		threatLevel = GetNPC().GetThreatLevel();
		if ( threatLevel < 0 )
			threatLevel = 0;
			
		return threatLevel * threatLevelBonus;
	}
	
	function GetActivationImportance() : float
	{
		if ( IsActive() )
		{
			return activationBonus;
		}
		return 0.f;
	}
}

abstract class CTicketBaseAlgorithmDefinition extends ITicketAlgorithmScriptDefinition
{
};


class CTicketAlgorithmApproach extends CTicketBaseAlgorithm
{
	default activationBonus = 5;
	default threatLevelBonus = 2;
	
	public function CalculateTicketImportance() : float
	{
		var importance : float = 100.f;
		
		if ( !ShouldAskForTicket() )
			return 0;	
		
		importance += GetDistanceImportance();
		
		importance += GetActivationImportance();
		
		importance += GetThreatLevelImportance();
		
		return importance;
	}
	
	final function ShouldAskForTicket() : bool
	{
		var owner : CActor = GetActor();
		var targetNPC : CNewNPC;
		
		targetNPC = (CNewNPC)GetCombatTarget();
		
		if ( owner.IsHuman() && !owner.HasAbility('IsNotScaredOfMonsters') && targetNPC && targetNPC.IsMonster() && targetNPC.GetThreatLevel() > 1 )
		{
			return false;
		}
		
		return true;
	}
};

class CTicketAlgorithmApproachDefinition extends CTicketBaseAlgorithmDefinition
{
	default instanceClass = 'CTicketAlgorithmApproach';
};


class CTicketAttackAlgorithm extends CTicketBaseAlgorithm
{
	default resetImportanceOnSpecialCombatAction = true;
	
	public var invertDistanceImportance			: bool;
	public var overrideDefaultTicketCount 		: bool;
	public var overridenValueWhenInFront 		: int;
	public var overridenValueWhenInBack 		: int;
	public var denyTicketWhenNotInFrame			: bool;
	
	default activationBonus = 5;
	default threatLevelBonus = 2;
	
	public function CalculateTicketImportance() : float
	{
		var importance 			: float = 100.f;
		var npc					: CNewNPC = GetNPC();
		
		
		if ( npc && npc.ShouldAttackImmidiately() )
		{
			overrideTicketsCount = 0;
			return 10000;
		}
		
		if ( !ShouldAskForTicket() )
			return 0;
		
		if ( denyTicketWhenNotInFrame && !thePlayer.WasVisibleInScaledFrame( npc, 1.f, 1.f ) )
			return 0;
			
		if ( !invertDistanceImportance )
			importance += GetDistanceImportance();
		else
			importance += GetInvertedDistanceImportance();
		
		importance += GetActivationImportance();
		
		importance += GetThreatLevelImportance();
		
		if ( importance <= 100 )
		{
			LogChannel('CombatTicketSystem',"Warning! Ticket Importance for: " + GetActor() + " less then 100.");
		}
		
		if ( overrideDefaultTicketCount )
		{
			if ( !GetCombatTarget().IsRotatedTowards( npc, 150 ) )
			{
				overrideTicketsCount = overridenValueWhenInBack;
			}
			else
				overrideTicketsCount = overridenValueWhenInFront;
		}
		
		return importance;
	}
};

class CTicketAttackAlgorithmDefinition extends CTicketBaseAlgorithmDefinition
{
	default instanceClass = 'CTicketAttackAlgorithm';

	editable var overrideDefaultTicketCount		: CBehTreeValBool;
	editable var overridenValueWhenInFront		: CBehTreeValInt;
	editable var overridenValueWhenInBack		: CBehTreeValInt;
	editable var invertDistanceImportance		: bool;
	editable var denyTicketWhenNotInFrame		: bool;
	
	hint invertDistanceImportance = "the npc furthest from the target will have the most importance";
};






class CTicketAlgorithmMelee extends ITicketAlgorithmScript
{
	public var priority 				: float;
	public var activationBonus 			: float;
	public var threatLevelBonus 		: float;
	public var moraleBonus 				: float;
	public var hpBonus 					: float;
	public var timeBonus 				: float;
	public var distanceBonus 			: float;
	public var desiredDistance 			: float;
	public var desiredTime 				: float;
	public var isAttackedBonus 			: float;
	public var isAttackedStateDuration 	: float;
	public var isInVicinityBonus 		: float;
	public var vicinityMax 				: float;
	public var vicinityMin 				: float;
	public var inTargetBackBonus 		: float;
	
	public function CalculateTicketImportance() : float
	{
		var npc					: CNewNPC = GetNPC();
		var target 				: CActor = GetCombatTarget();
		var distance 			: float;
		var proximity 			: float;
		var importance 			: float = 100.f;	
		var hp					: float = 0.f;
		var morale 				: float;
		var bonusMultiplier 	: float = 0.f;
		var threatLevel 		: float = 0.f;
		var time 				: float = 0.f;
		var isAttacked 			: int;
		var vicinityPercentage 	: float;
		var isInTargetBack		: int;
		var isHuman				: bool;
		
		if ( npc.IsHuman() )
		{
			isHuman = true;
			if ( ((W3PlayerWitcher)target).IsInCombatAction_SpecialAttack() )
				return 0;
		}
		
		if ( !npc.CanAttackKnockeddownTarget() && ( target.HasBuff(EET_Knockdown) || target.HasBuff(EET_HeavyKnockdown) ) )
		{
			return 0;
		}
		
		
		threatLevel = npc.GetThreatLevel();
		
		if ( npc.GetStatPercents( BCS_Essence ) > 0 )
			hp += npc.GetStatPercents( BCS_Essence );
		if ( npc.GetStatPercents( BCS_Vitality ) > 0 )
			hp += npc.GetStatPercents( BCS_Vitality );
		
		morale = npc.GetStatPercents( BCS_Morale );
		
		distance  = VecDistance(npc.GetWorldPosition(),target.GetWorldPosition());
		proximity =  distance;
		
		if ( distance <= desiredDistance )
			distance = 1;
		else
		{
			distance = ClampF(2-(distance/desiredDistance),0.f,1.f);
		}
		
		
		time = GetLocalTime() - GetTimeSinceMyAcquisition();
		
		time = ClampF(time/desiredTime,0.f,2.f);
		
		
		isAttacked = 0;
		if( npc.GetDelaySinceLastAttacked()< isAttackedStateDuration ) isAttacked = 1;
		
		
		if ( proximity > vicinityMax )
		{
			vicinityPercentage = 0;
		}
		else if ( proximity <= vicinityMin )
		{
			vicinityPercentage = 1;
		}
		else 
		{
			vicinityPercentage = 1 - ( (proximity - vicinityMin) / (vicinityMax - vicinityMin) );
		}
		
		isInTargetBack = 0;
		if ( !target.IsRotatedTowards( npc, 150 ) )
			isInTargetBack = 1;
		
		if ( isHuman )
		{
			if ( isInTargetBack )
			{
				overrideTicketsCount = 40;
			}
			else
				overrideTicketsCount = 60;
		}
		
		if( npc.HasAbility('RageActive') )
		{
			overrideTicketsCount = 5;
		}
		
		importance += 	hp * hpBonus 
					+ 	morale * moraleBonus 
					+ 	(1-distance) * distanceBonus 
					+ 	time * timeBonus 
					+ 	vicinityPercentage * isInVicinityBonus
					+ 	isAttacked * isAttackedBonus 
					+ 	isInTargetBack * inTargetBackBonus;
		
		if ( IsActive() )
		{
			importance += activationBonus;
		}
		
		
		if ( threatLevel > 0 )
			importance += threatLevel * threatLevelBonus;
		else
			importance += priority;
		
		if ( importance <= 100 )
		{
			LogChannel('CombatTicketSystem',"Warning! Ticket Importance for: "+ npc + " less then 100.");
		}
		
		return importance;
	}
};

class CTicketAlgorithmMeleeDefinition extends ITicketAlgorithmScriptDefinition
{
	default instanceClass = 'CTicketAlgorithmMelee';

	editable var priority 					: CBehTreeValFloat;
	editable var activationBonus 			: CBehTreeValFloat;
	editable var isInVicinityBonus 			: CBehTreeValFloat;
	editable var vicinityMax 				: CBehTreeValFloat;
	editable var vicinityMin 				: CBehTreeValFloat;
	editable var threatLevelBonus 			: CBehTreeValFloat;
	editable var moraleBonus 				: CBehTreeValFloat;
	editable var hpBonus					: CBehTreeValFloat;
	editable var timeBonus 					: CBehTreeValFloat;
	editable var distanceBonus 				: CBehTreeValFloat;
	editable var desiredDistance 			: CBehTreeValFloat;
	editable var desiredTime 				: CBehTreeValFloat;
	editable var isAttackedBonus 			: CBehTreeValFloat;
	editable var isAttackedStateDuration 	: CBehTreeValFloat;

	editable var inTargetBackBonus 		: CBehTreeValFloat;
	
	hint desiredTime 				= "desired time without ticket. After this time timeBonus will be max";
	hint isAttackedStateDuration 	= "how long after being attacked (hit or not) should I benefit from the isAttackedBonus";
	hint vicinityMax				= "I must be less than this distance from the target to benefit from isInVicinityBonus";
	hint vicinityMin				= "If I am closer than this to the target, I benefit from the max of isInVicinityBonus";
	hint threatLevelBonus			= "threatLevelBonus based on threatLevel stat form stats. thretLever varies from 1-5";
	hint priority					= "use insted threatLevel*threatLevelBonus when this stat is not found";
	
	public function Initialize()
	{
		SetValFloat(priority,100.f);
		SetValFloat(activationBonus,50.f);
		SetValFloat(timeBonus,50.f);
		SetValFloat(isAttackedStateDuration, 5.f);
		SetValFloat(threatLevelBonus, 10.f);
	}
};