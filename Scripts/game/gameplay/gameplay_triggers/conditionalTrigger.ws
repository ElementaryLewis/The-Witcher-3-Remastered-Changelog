/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ConditionalTrigger extends CEntity
{
	editable inlined var conditionClass : W3Condition;
	editable inlined var effectorClasses : array< IPerformableAction >;
	editable var affectsPlayer : bool;
	
	default affectsPlayer = true;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		
		if( activator.GetEntity() == thePlayer && !affectsPlayer )
			return false;
			
		actor = (CActor)activator.GetEntity();
		
		if( conditionClass.Test( actor ) )
		{
			TriggerPerformableEventArgNode( effectorClasses, this, actor );
		}
	}
}





abstract class W3Condition
{
	function Test( actor : CActor ) : bool;
}

class W3ConditionHasEffect extends W3Condition
{
	editable var effect : EEffectType;
	
	function Test( actor : CActor ) : bool
	{
		if( actor.HasBuff( effect ) )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}