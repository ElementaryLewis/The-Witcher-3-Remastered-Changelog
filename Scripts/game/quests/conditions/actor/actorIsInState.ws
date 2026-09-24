/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_IsInState extends CQCActorScriptedCondition
{
	editable var actorState : EQuestNPCStates;

	function Evaluate(act : CActor) : bool
	{
		if( actorState == EQNS_Dead )
		{
			return !act.IsAlive();			
		}
		else if( actorState == EQNS_Agony )
		{
			return act.IsInAgony();			
		}
		else if( actorState == EQNS_Default )
		{
			return act.IsAlive() && !act.IsInAgony() && !act.IsKnockedUnconscious();
		}
		else if ( actorState == EQNS_KnockedUnconscious )
		{
			return act.IsKnockedUnconscious();
		}
		else if( actorState == EQNS_Combat)
		{
			return act.IsInCombat();
		}
		else
		{	
			LogAssert(false, "Quest Condition ActorIsInState: checked for wrong state index ("+actorState+"), report as bug!");
			LogQuest("Quest Condition ActorIsInState: checked for wrong state index ("+actorState+"), report as bug!");
			return false;
		}
	}
}