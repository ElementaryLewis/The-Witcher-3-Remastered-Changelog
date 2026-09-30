/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSirenAttack extends CBTTaskAttack
{
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var actors : array<CActor>;
		var i : int;
		var npc : CNewNPC = GetNPC();
		
		
		
		
		
		
		
		
		
		
		if ( animEventName == 'AttackScream' )
		{
			actors = npc.GetAttackableNPCsAndPlayersInRange(12);
			for ( i = 0 ; i < actors.Size(); i+=1)
			{
				if ( !actors[i].HasAbility( 'mon_siren' ))
				{
					actors[i].AddEffectDefault(EET_Stagger, npc, 'siren_attack' );
				}
			}
			return true;
		}
		return super.OnAnimEvent( animEventName, animEventType, animInfo);
	}
}

class CBTTaskSirenAttackDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskSirenAttack';
}