/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskIceGiantFallingIcicles extends CBTTaskAttack
{
	var icicles : array<CGameplayEntity>;
	var rangeForIcyclesActivation : float;
	var npc : CNewNPC;
	
	function IsAvailable() : bool
	{
		npc = GetNPC();
		
		
		FindGameplayEntitiesInRange( icicles, npc, rangeForIcyclesActivation, 10, 'icicle' );
		
		if( icicles.Size() )
		{	
			return true;
		}
		
		return false;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var i : int;
		
		if( animEventName == 'AttackSuperHeavy' )
		{
			for( i = 0; i < icicles.Size(); i += 1 )
			{
				
				
				
			}
			
			return true;
		}
		
		return false;
	}
	
	function OnDeactivate()
	{
		super.OnDeactivate();
		
		icicles.Clear();		
	}
}

class CBTTaskIceGiantFallingIciclesDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskIceGiantFallingIcicles';

	editable var rangeForIcyclesActivation : float;

	default rangeForIcyclesActivation = 10;
}