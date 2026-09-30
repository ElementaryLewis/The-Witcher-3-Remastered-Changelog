/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskBiesCharge extends CBTTask3StateAttack
{
	var endStuck 				: EAttackType;
	var endHit 					: EAttackType;
	var bCollisionWithObstacle 	: bool;
	var bCollisionWithActor 	: bool;
	var stuckTime 				: float;
	var loopStart 				: bool;
	
	var cameraIndex 			: int;
	var isEnding 				: bool;
	var collidedActor 			: CActor;
	
	default bCollisionWithObstacle = false;
	default bCollisionWithActor = false;
	default cameraIndex = -1;
	default isEnding = false;
	
	
	function IsAvailable() : bool
	{
		var res : bool;
		
		if ( theGame.GetWorld().NavigationLineTest( GetActor().GetWorldPosition(), GetCombatTarget().GetWorldPosition(), 0.5f ) )
		{
			return true;
		}
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		GetActor().SignalGameplayEvent( 'LookatOff' );
		return super.OnActivate();
	}
	
	latent function Loop() : int
	{
		var endTime 			: float;
		var waitTime			: float;
		var npc 				: CNewNPC = GetNPC();
		var action 				: W3DamageAction;
		
		
		endTime = GetLocalTime() + loopTime;
		loopStart = true;
		
		if ( cameraIndex >= 0 )
		{
			thePlayer.DisableCustomCamInStack( cameraIndex );
			cameraIndex = -1;
		}
		
		while ( !bCollisionWithActor && !bCollisionWithObstacle && GetLocalTime() <= endTime )
		{
			Sleep( 0.001 );
			if( !theGame.GetWorld().NavigationLineTest( npc.GetWorldPosition(), npc.GetWorldPosition()+npc.GetHeadingVector(), 1.5 ) )
				break;
		}
		
		waitTime = GetLocalTime() + 0.5;
		while ( !bCollisionWithObstacle && GetLocalTime() <= waitTime )
		{
			SleepOneFrame();
		}
		
		ChooseAnim();
		npc.SetBehaviorVariable( 'AttackEnd', 1.0 );
		
		if ( bCollisionWithObstacle )
		{
			npc.customHits = true;
			npc.SetCanPlayHitAnim( true );
			npc.WaitForBehaviorNodeActivation( 'AttackEndActive', 0.02 );
			npc.SetBehaviorVariable( 'AttackEnd', 0.0 );
			
			endTime = GetLocalTime() + stuckTime;
			while ( !isEnding && GetLocalTime() <= endTime )
			{
				SleepOneFrame();
			}
			
			isEnding = true;
			
			npc.SetBehaviorVariable( 'AttackEnd', 1.0 );
		}
		
		npc.WaitForBehaviorNodeDeactivation('AttackEnd', 10.0f );
		
		return 1;
	}
	
	function OnDeactivate()
	{
		var player 				: CActor;
		var npc 				: CNewNPC = GetNPC();
		
		super.OnDeactivate();
		
		if ( bCollisionWithObstacle && npc.IsAlive() )
		{
			npc.SetBehaviorVariable( 'bStuckDeath',0.0 );
		}
		
		npc.SignalGameplayEvent('LookatOn');
		bCollisionWithObstacle = false;
		bCollisionWithActor = false;
		npc.customHits = false;
		isEnding = false;
		collidedActor = NULL;
		
		if ( cameraIndex >= 0 )
		{
			thePlayer.DisableCustomCamInStack( cameraIndex );
			cameraIndex = -1;
		}
		
		npc.StopEffect( 'charge_dust' );
		loopStart = false;
	}
	
	function ChooseAnim()
	{
		if( bCollisionWithObstacle )
		{
			GetNPC().SetBehaviorVariable( 'AttackType',(int)endStuck );
		}
		else if( bCollisionWithActor )
		{
			GetNPC().SetBehaviorVariable( 'AttackType',(int)endHit );
		}
		else
		{
			super.ChooseAnim();
		}
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc 				: CNewNPC = GetNPC();
		var player 				: CActor;
		var data 				: CDamageData;
		var action				: W3Action_Attack;
		
		if ( loopStart && !bCollisionWithObstacle && eventName == 'CollisionWithObstacle' )
		{
			if ( npc.HasAbility( 'StuckAfterCharge' ) && !GetCombatTarget().HasBuff( EET_Hypnotized ) )
			{
				bCollisionWithObstacle = true;
				npc.SetBehaviorVariable( 'bStuckDeath', 1.0 );
			}
			return true;
		}
		else if ( loopStart && !bCollisionWithActor && eventName == 'CollisionWithActor' && !isEnding )
		{
			bCollisionWithActor = true;
			collidedActor = (CActor)GetEventParamObject();
			
			action = new W3Action_Attack in theGame.damageMgr;
			action.Init( npc, collidedActor, NULL, npc.GetInventory().GetItemFromSlot( 'r_weapon' ), 'attack_super_heavy', npc.GetName(), EHRT_None, false, true, 'attack_super_heavy', AST_Jab, ASD_UpDown, true, false, false, false );
			theGame.damageMgr.ProcessAction( action );
			delete action;
			
			return true;
		}
		else if ( eventName == 'BeingHit' && !isEnding )
		{
			data = (CDamageData) GetEventParamBaseDamage();
			if ( data.customHitReactionRequested )
			{
				npc.RaiseForceEvent('CustomHit');
				npc.IncHitCounter();
				if ( npc.GetHitCounter() >= 2 )
				{
					isEnding = true;
				}
				return true;
			}
		}
		else if ( eventName == 'CameraIndex' )
		{
			cameraIndex = GetEventParamInt( -1 );
			return true;
		}
		
		return super.OnGameplayEvent( eventName );
	}
}

class CBTTaskBiesChargeDef extends CBTTask3StateAttackDef
{
	default instanceClass = 'CBTTaskBiesCharge';

	editable var endStuck 		: EAttackType;
	editable var endHit 		: EAttackType;
	editable var stuckTime 		: float;
	
	default stuckTime = 4.f;
	default stopRotatingWhenTargetIsBehind = true;
}