/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskDealDamageToOwner extends CBTTaskPlayAnimationEventDecorator
{
	var owner 					: CNewNPC;
	var attacker				: CActor;
	var damageValue				: float;
	var action					: W3Action_Attack;
	var attackName				: name;
	var skillName				: name;
	var onAnimEventName			: name;
	
	function OnActivate() : EBTNodeStatus
	{
		owner = GetNPC();
		attacker = GetCombatTarget();
		return BTNS_Active;
	}
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if( animEventName == onAnimEventName )
		{
			DealDamage();
			return true;
		}
		else return super.OnAnimEvent(animEventName,animEventType, animInfo);
	}
	
	function DealDamage()
	{
		action = new W3Action_Attack in theGame.damageMgr;
		skillName = 'attack_light';
		attackName = 'attack_light';
		action.Init( attacker, owner, NULL, attacker.GetInventory().GetItemFromSlot( 'r_weapon' ), attackName, attacker.GetName(), EHRT_None, false, true, skillName, AST_Jab, ASD_UpDown, true, false, false, false );
		action.AddDamage(theGame.params.DAMAGE_NAME_BLUDGEONING, damageValue );
		theGame.damageMgr.ProcessAction( action );
		
		delete action;
	}
}
class CBTTaskDealDamageToOwnerDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskDealDamageToOwner';
	
			 var owner 						: CNewNPC;
			 var attacker					: CActor;
			 var damageValue				: float;
			 var action						: W3Action_Attack;
			 var attackName					: name;
			 var skillName					: name;
	editable var onAnimEventName			: name;
}