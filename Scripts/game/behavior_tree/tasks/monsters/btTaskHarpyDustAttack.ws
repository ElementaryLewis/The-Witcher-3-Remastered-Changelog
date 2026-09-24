/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskHarpyDustAttack extends CBTTaskAttack
{
	var addtionalFX 	: name;
	var effectRange		: float;
	var effectAngle		: float;
	var eventReceived 	: bool;
	
	latent function Main() : EBTNodeStatus
	{
		var action 				: W3DamageAction;
		var npc 				: CNewNPC = GetNPC();
		var target 				: CActor = npc.GetTarget();
		var npcPos, targetPos 	: Vector;
		var dist				: float;
		var angle				: float;
		
		while ( true )
		{
			if ( eventReceived )
			{
				npcPos = npc.GetWorldPosition();
				targetPos = target.GetWorldPosition();
				
				angle = AbsF( AngleDistance( npc.GetHeading(), VecHeading( targetPos - npcPos )));
				dist = VecDistanceSquared( npcPos, targetPos );
				
				if ( dist <= effectRange*effectRange && angle <= effectAngle )
				{
					
					action = new W3DamageAction in this;			
					action.Initialize( (CGameplayEntity)npc, (CGameplayEntity)target, (CGameplayEntity)npc, npc+"'s dust attack", EHRT_None, CPS_AttackPower, false, false, false, false);
					action.SetHitAnimationPlayType(EAHA_ForceNo);
					action.AddEffectInfo(EET_Swarm);
					
					theGame.damageMgr.ProcessAction( action );
					delete action;
					
					GCameraShake( 0.5, false, target.GetWorldPosition(), 10.0);
					if ( target == thePlayer )
					{
						if ( IsNameValid( addtionalFX ) )
						{
							target.PlayEffect( addtionalFX );
						}
						target.PlayEffect( 'radial_blur' );
					}
				}
				eventReceived = false;
			}
			Sleep( 0.1 );
		}
		return BTNS_Active;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == 'ApplyBlind' )
		{
			eventReceived = true;
			return true;
		}
		return false;
	}
};

class CBTTaskHarpyDustAttackDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskHarpyDustAttack';
	
	editable var addtionalFX 	 : name;
	editable var effectRange 	 : float;
	editable var effectAngle 	 : float;

	default effectRange = 5.0;
	default effectAngle = 20;
};