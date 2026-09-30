/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskCrabAttack extends IBehTreeTask
{

	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var crab : CNewNPC = GetNPC();
		
		var action : W3DamageAction = new W3DamageAction in theGame.damageMgr;
		
		if ( animEventName == 'AttackLight' && animEventType == AET_DurationStart)
		{
			if ( crab.GetTarget() && crab.InAttackRange( crab.GetTarget() ) )
			{
				action.Initialize( crab, crab.GetTarget(), NULL, "boid", EHRT_None, CPS_Undefined, true, false, false, false, theGame.params.LIGHT_HIT_FX, theGame.params.LIGHT_HIT_BACK_FX, theGame.params.LIGHT_HIT_PARRIED_FX, theGame.params.LIGHT_HIT_BACK_PARRIED_FX);
				action.SetHitAnimationPlayType(EAHA_Default);
				action.AddDamage('PhysicalDamage', 3);
				theGame.damageMgr.ProcessAction( action );
				delete action;
			}			
			return true;
		}
		return false;
	}
}

class CBTTaskCrabAttackDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskCrabAttack';
}