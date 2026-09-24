/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskTackle extends IBehTreeTask
{
	var dealDamage				: bool;
	var activeOnAnimEvent		: bool;
	var bCollisionWithActor 	: bool;
	var activated				: bool;
	var xmlDamageName			: name;
	var collidedActor 			: CActor;
	
	default bCollisionWithActor = false;
	
	function OnActivate() : EBTNodeStatus
	{
		if ( !activeOnAnimEvent )
		{
			activated = true;
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		bCollisionWithActor = false;
		collidedActor = NULL;
		activated = false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc 			: CNewNPC = GetNPC();
		var damageAction 	: W3DamageAction;
		var action			: W3Action_Attack;
		var damage 			: float;
		
		if ( activated && !bCollisionWithActor && eventName == 'CollisionWithActor' )
		{
			collidedActor = (CActor)GetEventParamObject();
			if ( IsRequiredAttitudeBetween(npc,collidedActor,true) )
			{
				
				bCollisionWithActor = true;
				if ( !dealDamage )
				{
					collidedActor.AddEffectDefault( EET_KnockdownTypeApplicator, GetNPC(), "Tackle" );
				}
				else
				{
					
					action = new W3Action_Attack in theGame.damageMgr;
					action.Init( npc, collidedActor, NULL, npc.GetInventory().GetItemFromSlot( 'r_weapon' ), 'attack_super_heavy', npc.GetName(), EHRT_None, false, true, 'attack_super_heavy', AST_Jab, ASD_UpDown,false,false,false,false );
					theGame.damageMgr.ProcessAction( action );
					delete action;
				}
			}
			return true;
		}
		
		return false;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res : bool;
		
		if ( activeOnAnimEvent )
		{
			if ( animEventName == 'attackStart')
			{
				activated = true;
				return true;
			}
			else if ( animEventName == 'Knockdown' && animEventType == AET_DurationStart )
			{
				activated = true;
				return true;
			}
			else if ( animEventName == 'Knockdown' && animEventType == AET_DurationEnd )
			{
				activated = false;
				return true;
			}
		}		
		return false;
	}
};

class CBTTaskTackleDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskTackle';

	editable var dealDamage 		: bool;
	editable var activeOnAnimEvent 	: bool;
	
	default dealDamage = true;
	default activeOnAnimEvent = false;
};
