/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBehTreeCombatTargetSelectionTask extends IBehTreeTask
{	
	var maxTargetDistance : float;
	var testMaxFrequency : float;
	var nextTestDelay : float;
	var nextTarget : CActor;
	var playerPriority : int;
	var targetOnlyPlayer : bool;
	var ForceTarget : CActor;
	
	default maxTargetDistance = 10.0;
	default testMaxFrequency = 1.0;
	default nextTestDelay = -1.0;
	default playerPriority = 100;
	
	function IsAvailable() : bool
	{		
		var owner : CNewNPC = GetNPC();
		var tooFar : bool;
		var target : CActor;
		var localTime : float;
		
		
		if ( ForceTarget )
		{
			if ( ForceTarget != GetCombatTarget() )
			{
				nextTarget = ForceTarget;
				return true;
			}
			return false;
		}
		
		localTime = GetLocalTime();
		
		if ( nextTestDelay > localTime )
		{
			return false;
		}
		nextTestDelay = localTime + testMaxFrequency;
		
		target = GetCombatTarget(); 
		tooFar = (target && !IsTargetInRange());
		
		
		
		
		
		if( !target || (target && !target.IsAlive()) || owner.lastAttacker || tooFar )
		{
			if( FindTarget() )
			{
				return true;
			}
		}
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		SetCombatTarget( nextTarget );
		nextTarget = NULL;
		return BTNS_Completed;
	} 
	
	
	function EvaluatePotentialTarget( target : CActor) : float
	{	
		var owner : CNewNPC = GetNPC();
		var sum : float;
		var npcTarget : CNewNPC;
		var dist : float;
		
		npcTarget = (CNewNPC)target;
		
		
		if ( !owner.IsDangerous( target ) )
		{
			return 0;
		}
		
		
		
		if ( npcTarget && owner.GetAttitude( thePlayer ) != npcTarget.GetAttitude( thePlayer ) )
		{
			sum = sum + 10.0;
		}
		
		
		if( target == GetCombatTarget() && target.IsAlive() )
		{
			sum = sum + 50.0;
		}
		
		
		if( target == owner.lastAttacker )
		{
			sum = sum + 100.0;
		}	
		
		
		dist = VecDistance2D( owner.GetWorldPosition(), target.GetWorldPosition() );
		sum = sum + 1000.0 * (1.0 - (dist / maxTargetDistance));
		
		
		if( target == thePlayer )
		{
			if( RandRange(100) < playerPriority )
			{
				sum = sum + 600.0f;
			}
		}
		
		
		return sum;		
	}
	
	function FindTarget() : bool
	{
		var score : float;
		var maxScore : float;
		var bestTarget : CActor;
		var newTarget : CActor;
		var index : int;
		var owner : CNewNPC = GetNPC();
		
		if( targetOnlyPlayer )
		{
			bestTarget = NULL;
			if( thePlayer.IsAlive() && owner.IsDangerous( thePlayer ) )
			{
				bestTarget = thePlayer;
			}
		}
		else
		{	
			
			maxScore = 0;
			index = 0;
			newTarget = owner.GetNoticedObject( index );
			while( newTarget )
			{		
				if(newTarget.IsAlive())
				{
					score = EvaluatePotentialTarget( newTarget );
				
					if( score > maxScore )
					{
						maxScore = score;
						bestTarget = newTarget;
					}
				}
			
				index = index + 1;
				newTarget = owner.GetNoticedObject( index );
			}
		}
		
		
		owner.lastAttacker = NULL;
		
		
		if( bestTarget != GetCombatTarget() )
		{
			nextTarget = bestTarget;
			
			return true;
		}
		
		
		return false;
	}

	function IsTargetInRange() : bool
	{
		var owner : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		var res : bool = false;
		
		if( target )
		{
			res = VecDistance2D( owner.GetWorldPosition(), target.GetWorldPosition() ) < maxTargetDistance;
		}
		
		return res;
	}
	
	function OnGameplayEvent( eventName : CName ) : bool
	{		
		var owner 	: CNewNPC = GetNPC();
		var data 	: CDamageData;
		
		if ( eventName == 'BeingHit' )
		{
			data 				= (CDamageData) GetEventParamBaseDamage();
			owner.lastAttacker 	= (CActor)data.attacker;
			return true;
		}
		if ( eventName == 'ForceTarget' )
		{
			this.ForceTarget = (CActor)GetEventParamObject();
			return true;
		}
		if ( eventName == 'UnforceTarget' )
		{
			this.ForceTarget = NULL;
			SetCombatTarget(NULL);
			return true;
		}
		if ( eventName == 'ReevaluateCombatTarget' )
		{
			SetCombatTarget(NULL);
		}
		return false;
	}
};

class CBehTreeCombatTargetSelectionTaskDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeCombatTargetSelectionTask';
	
	editable var maxTargetDistance : float;
	editable var playerPriority : int;
	editable var targetOnlyPlayer : bool;
	
	default maxTargetDistance 	= 10;
	default playerPriority 		= 100;
	default targetOnlyPlayer 	= true;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'BeingHit' );
		listenToGameplayEvents.PushBack( 'ForceTarget' );
		listenToGameplayEvents.PushBack( 'UnforceTarget' );
		listenToGameplayEvents.PushBack( 'ReevaluateCombatTarget' );
	}
}
