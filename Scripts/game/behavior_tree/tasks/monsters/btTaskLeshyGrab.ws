/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskLeshyGrabAttack extends IBehTreeTask
{
	var attackType				: EAttackType;
	var stopTaskAfterDealingDmg : bool;
	var useDirectionalAttacks 	: bool;
	var fxOnDamageInstigated 	: name;
	var slave 					: CActor;
	var slaveComponent 			: CEffectDummyComponent;
	
	function OnActivate() : EBTNodeStatus
	{
		var master : CNewNPC = GetNPC();
		
		master.SetBehaviorVariable( 'AttackType', (int)attackType );
		
		slave = master.GetTarget();
		slaveComponent = (CEffectDummyComponent)(slave.GetComponentByClassName('CEffectDummyComponent'));
		theGame.GetSyncAnimManager().SetupSimpleSyncAnim('LeshyHeadGrab', master, slaveComponent.GetEntity() );		
		return BTNS_Active;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if ( eventName == 'DamageInstigated' )
		{
			if ( fxOnDamageInstigated != '' )
			{
				npc.PlayEffect(fxOnDamageInstigated);
			}
			if ( stopTaskAfterDealingDmg )
			{
				npc.RaiseEvent('AnimEndAUX');
				Complete(true);
			}
			return true;
		}
		return false;
	}
};

class CBTTaskLeshyGrabAttackDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskLeshyGrabAttack';

	editable var attackType				: EAttackType;
	editable var stopTaskAfterDealingDmg: bool;
	editable var useDirectionalAttacks 	: bool;
	editable var fxOnDamageInstigated : name;
	
	default attackType = EAT_Attack1;
	default stopTaskAfterDealingDmg = false;
	default useDirectionalAttacks = false;
};