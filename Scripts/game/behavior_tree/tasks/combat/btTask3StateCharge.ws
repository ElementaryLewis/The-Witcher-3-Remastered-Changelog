/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTask3StateCharge extends CBTTask3StateAttack
{
	var differentChargeEndings 	: bool;
	var bCollisionWithActor 	: bool;
	var loopStart 				: bool;
	var isEnding 				: bool;
	var attached 				: bool;
	var cameraIndex 			: int;
	var collidedActor 			: CActor;
	var canHitNeutralOrFriend 			: bool;
	
	default bCollisionWithActor = false;
	default isEnding 			= false;
	default canHitNeutralOrFriend 			= false;
	
	function IsAvailable() : bool
	{
		if ( theGame.GetWorld().NavigationLineTest(GetActor().GetWorldPosition(), GetCombatTarget().GetWorldPosition(), GetActor().GetRadius()) )
		{
			return true;
		}
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		combatDataStorage.SetIsCharging( true );
		
		return super.OnActivate();
	}
	
	latent function Loop() : int
	{
		var endTime 		: float;
		var dist 			: float;
		var minDistance 	: float = 6;
		var npcSightCone 	: float = 90;
		var testedAngle 	: float;
		var npc 			: CNewNPC;
		var action 			: W3DamageAction;
		var target 			: CActor;
		
		
		npc = GetNPC();
		endTime = GetLocalTime() + loopTime;
		loopStart = true;
		
		while ( !bCollisionWithActor && GetLocalTime() <= endTime )
		{
			SleepOneFrame();
			
			if( differentChargeEndings )
			{
				dist = VecDistance2D( npc.GetWorldPosition(), npc.GetTarget().GetWorldPosition() );
				if( dist < minDistance )
				{
					testedAngle = AbsF( NodeToNodeAngleDistance( npc.GetTarget(), npc ) );
					if( testedAngle < ( npcSightCone/2 ) )
					{
						npc.SetBehaviorVariable( 'ChargeEndType', 1, true );
						break;
					}
				}
				else
				{
					npc.SetBehaviorVariable( 'ChargeEndType', 0, true );
				}
				
			}
			
			if( !theGame.GetWorld().NavigationLineTest(npc.GetWorldPosition(), npc.GetWorldPosition()+npc.GetHeadingVector(), GetActor().GetRadius()) )
				break;
		}
		
		if ( collidedActor )
		{
			action = new W3DamageAction in this;
			action.Initialize(npc,collidedActor,NULL,npc.GetName(),EHRT_None,CPS_AttackPower,true,false,false,false);
			action.AddDamage(theGame.params.DAMAGE_NAME_BLUDGEONING,20);		
			action.AddEffectInfo(EET_KnockdownTypeApplicator, 2.f );
			theGame.damageMgr.ProcessAction( action );
			delete action;
		}
		
		npc.SetBehaviorVariable( 'AttackEnd', 1.0, true );
		
		npc.WaitForBehaviorNodeDeactivation('AttackEnd', 10.0f );
		
		return 1;
	}
	
	function OnDeactivate()
	{
		super.OnDeactivate();
		
		bCollisionWithActor = false;
		isEnding = false;
		collidedActor = NULL;
		loopStart = false;
		combatDataStorage.SetIsCharging( false );
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc 	: CNewNPC = GetNPC();
		var player 	: CActor;
		
		if ( loopStart && !bCollisionWithActor && eventName == 'CollisionWithActor' )
		{
			
			collidedActor = (CActor)GetEventParamObject();
			if(canHitNeutralOrFriend)
			{
				if ( IsRequiredAttitudeBetween(npc,collidedActor,true,true,true) )
				{
					bCollisionWithActor = true;
				}
			}
			else
			{
				if ( IsRequiredAttitudeBetween(npc,collidedActor,true) )
				{
					bCollisionWithActor = true;
				}
				
			}
			
			
			return true;
		}
		
		return super.OnGameplayEvent( eventName );
	}
}

class CBTTask3StateChargeDef extends CBTTask3StateAttackDef
{
	default instanceClass 					= 'CBTTask3StateCharge';
	
	editable var differentChargeEndings 	: bool;
	editable var canHitNeutralOrFriend 	: bool;
	
	default differentChargeEndings 			= false;
	default stopRotatingWhenTargetIsBehind 	= true;
	default canHitNeutralOrFriend 	= false;
}

class CBTTask3StateLightCharge extends CBTTask3StateAttack
{
	var differentChargeEndings 	: bool;
	var bCollisionWithActor 	: bool;
	var loopStart 				: bool;
	var isEnding 				: bool;
	var attached 				: bool;
	var cameraIndex 			: int;
	var collidedActor 			: CActor;
	var canHitNeutralOrFriend 			: bool;
	
	default bCollisionWithActor = false;
	default isEnding 			= false;
	default canHitNeutralOrFriend 			= false;
	
	function IsAvailable() : bool
	{
		if ( theGame.GetWorld().NavigationLineTest(GetActor().GetWorldPosition(), GetCombatTarget().GetWorldPosition(), GetActor().GetRadius()) )
		{
			return true;
		}
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		combatDataStorage.SetIsCharging( true );
		
		return super.OnActivate();
	}
	
	latent function Loop() : int
	{
		var endTime 		: float;
		var dist 			: float;
		var minDistance 	: float = 6;
		var npcSightCone 	: float = 90;
		var testedAngle 	: float;
		var npc 			: CNewNPC;
		var action 			: W3DamageAction;
		var target 			: CActor;
		
		
		npc = GetNPC();
		endTime = GetLocalTime() + loopTime;
		loopStart = true;
		
		while ( !bCollisionWithActor && GetLocalTime() <= endTime )
		{
			SleepOneFrame();
			
			if( differentChargeEndings )
			{
				dist = VecDistance2D( npc.GetWorldPosition(), npc.GetTarget().GetWorldPosition() );
				if( dist < minDistance )
				{
					testedAngle = AbsF( NodeToNodeAngleDistance( npc.GetTarget(), npc ) );
					if( testedAngle < ( npcSightCone/2 ) )
					{
						npc.SetBehaviorVariable( 'ChargeEndType', 1, true );
						break;
					}
				}
				else
				{
					npc.SetBehaviorVariable( 'ChargeEndType', 0, true );
				}
				
			}
			
			if( !theGame.GetWorld().NavigationLineTest(npc.GetWorldPosition(), npc.GetWorldPosition()+npc.GetHeadingVector(), GetActor().GetRadius()) )
				break;
		}
		
		if ( collidedActor )
		{
			action = new W3DamageAction in this;
			action.Initialize(npc,collidedActor,NULL,npc.GetName(),EHRT_Heavy,CPS_AttackPower,true,false,false,false,'null','null','null'); 
			action.AddDamage(theGame.params.DAMAGE_NAME_BLUDGEONING,0);	
			theGame.damageMgr.ProcessAction( action );
			delete action;
		}
		
		npc.SetBehaviorVariable( 'AttackEnd', 1.0, true );
		
		npc.WaitForBehaviorNodeDeactivation('AttackEnd', 10.0f );
		
		return 1;
	}
	
	function OnDeactivate()
	{
		super.OnDeactivate();
		
		bCollisionWithActor = false;
		isEnding = false;
		collidedActor = NULL;
		loopStart = false;
		combatDataStorage.SetIsCharging( false );
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc 	: CNewNPC = GetNPC();
		var player 	: CActor;
		
		if ( loopStart && !bCollisionWithActor && eventName == 'CollisionWithActor' )
		{
			
			collidedActor = (CActor)GetEventParamObject();
			if(canHitNeutralOrFriend)
			{
				if ( IsRequiredAttitudeBetween(npc,collidedActor,true,true,true) )
				{
					bCollisionWithActor = true;
				}
			}
			else
			{
				if ( IsRequiredAttitudeBetween(npc,collidedActor,true) )
				{
					bCollisionWithActor = true;
				}
				
			}
			
			
			return true;
		}
		
		return super.OnGameplayEvent( eventName );
	}
}

class CBTTask3StateLightChargeDef extends CBTTask3StateAttackDef
{
	default instanceClass 					= 'CBTTask3StateLightCharge';
	
	editable var differentChargeEndings 	: bool;
	editable var canHitNeutralOrFriend 	: bool;
	
	default differentChargeEndings 			= false;
	default stopRotatingWhenTargetIsBehind 	= true;
	default canHitNeutralOrFriend 	= false;
}