/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskCustomApplyEffectAttack extends CBTTaskAttack
{
	var applyEffectInterval 			: float;
	var activateOnAnimEvent 			: name;
	
	private var activationTimeStamp 	: float;
	private var activated 				: bool;
	
	
	latent function Main() : EBTNodeStatus
	{
		var npc 					: CNewNPC = GetNPC();
		var entities 				: array<CGameplayEntity>;
		var destructionComponent 	: CDestructionComponent;
		var timeStamp 				: float;
		var i 						: int;
		
		super.Main();
		
		if ( !IsNameValid( applyEffectInAttackRange ) )
		{
			return BTNS_Failed;
		}
		
		while( true )
		{
			if ( activated )
			{
				if ( GetLocalTime() > activationTimeStamp + 0.01 )
				{
					activated = false;
				}
				
				if ( ( timeStamp + applyEffectInterval ) < GetLocalTime() || timeStamp == 0 )
				{
					timeStamp = GetLocalTime();
					
					npc.GatherEntitiesInAttackRange( entities, applyEffectInAttackRange );
					for ( i = 0 ; i<entities.Size() ; i+=1 )
					{
						if ( (CActor)entities[i] && GetAttitudeBetween( npc, entities[i] ) == AIA_Hostile )
						{
							ApplyCriticalEffectOnTarget( (CActor)entities[i] );
						}
						
						if ( hitDestructablesInAttackRange )
						{
							destructionComponent = (CDestructionComponent) entities[i].GetComponentByClassName( 'CDestructionComponent' );
							if ( destructionComponent )
							{
								destructionComponent.ApplyFracture();
							}
						}
					}
				}
			}
			
			SleepOneFrame();
		}
		
		
		return BTNS_Active;
	}
	
	function OnDeactivate() 
	{
		activated = false;
		
		super.OnDeactivate();
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( IsNameValid( activateOnAnimEvent ) && animEventName == activateOnAnimEvent )
		{
			activationTimeStamp = GetLocalTime();
			activated = true;
			return true;
		}
		
		return super.OnAnimEvent(animEventName, animEventType, animInfo);
	}
};

class CBTTaskCustomApplyEffectAttackDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskCustomApplyEffectAttack';
	
	editable var applyEffectInterval 	: float;
	editable var activateOnAnimEvent 	: name;
	
	default applyEffectInterval  		= 0.5f;
	default activateOnAnimEvent 		= 'Attack';
};