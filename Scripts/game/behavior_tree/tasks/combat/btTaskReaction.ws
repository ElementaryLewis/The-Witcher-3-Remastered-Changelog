/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskReaction extends IBehTreeTask
{
	var counterChance			: int;
	var dodgeChanceAttacks		: int;
	var dodgeChanceAard			: int;
	var dodgeChanceIgni			: int;
	var dodgeChanceBomb			: int;
	var dodgeChanceProjectile	: int;

	var Time2Dodge		: bool;
	var dodgeType		: EDodgeType;
	var nextReactionTime: float;
	var reactionDelay	: float;
	
	default Time2Dodge = false;
	
	default nextReactionTime = 0.0;
	
	function IsAvailable() : bool
	{
		var target : CActor;
		var npc : CNewNPC;
		
		if ( isActive )
		{
			return true;
		}
		
		if ( nextReactionTime > GetLocalTime() )
		{
			Time2Dodge = false;
			return false;
		}
		
		if (!checkDistance())
		{
			Time2Dodge = false;
			return false;
		}
		
		if( !Time2Dodge )
		{
			return false;
		}
		
		return true;
		
	}
	
	function checkDistance() : bool
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		var dist : float;
		
		if( target )
		{	
			dist = VecDistance2D( npc.GetWorldPosition(), target.GetWorldPosition() );
			
			if( dist >= 0  && dist < 2 )
			{
				return true;
			}
		}
		
		return false;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		if ( (dodgeType == EDT_Attack_Light || dodgeType == EDT_Attack_Heavy ) && counterChance > 0)
		{
			if (RandRange(100) < counterChance)
			{
				if( npc.RaiseForceEvent( 'CounterAttack' ) )
				{
					npc.WaitForBehaviorNodeDeactivation( 'CounterAttackEnd', 10.0f );
					Time2Dodge = false;
					return BTNS_Completed;
				}
			}
		}
		else
		{
			if( !ChooseAndCheckDodge() )
			{
				if( npc.RaiseForceEvent( 'Dodge' ) )
				{
					npc.WaitForBehaviorNodeDeactivation( 'DodgeEnd', 10.0f );
					Time2Dodge = false;
					return BTNS_Completed;
				}
			}
		}
		return BTNS_Failed;
	}
	
	function ChooseAndCheckDodge() : bool
	{
		var npc : CNewNPC = GetNPC();
		var dodgeChance : int;
		
		if( !Time2Dodge )
		{
			return false;
		}
		
		switch (dodgeType)
		{
			case EDT_Attack_Light	: dodgeChance = dodgeChanceAttacks; break;
			case EDT_Attack_Heavy	: dodgeChance = dodgeChanceAttacks; break;
			case EDT_Aard			: dodgeChance = dodgeChanceAard; break;
			case EDT_Igni			: dodgeChance = dodgeChanceIgni; break;
			case EDT_Bomb			: dodgeChance = dodgeChanceBomb; break;
			case EDT_Projectile		: dodgeChance = dodgeChanceProjectile; break;
			default : return false;
		}
		
		if (RandRange(100) < dodgeChance)
		{
			if ( dodgeType == EDT_Attack_Light || dodgeType == EDT_Attack_Heavy )
			{
				npc.SetBehaviorVariable('DodgeDirection',(int)EDD_Back);
			}
			else
			{
				npc.SetBehaviorVariable('DodgeDirection',(int)EDD_Left);
			}
			return true;
		}
		
		return false;
	}
	
	
	function OnDeactivate()
	{
		Time2Dodge = false;
		nextReactionTime = GetLocalTime() + reactionDelay;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc : CNewNPC;
		if ( eventName == 'Time2Dodge' && (nextReactionTime < GetLocalTime()) )
		{
			npc = GetNPC();
			Time2Dodge = true;
			dodgeType = this.GetEventParamInt(-1);
			return true;
		}
		return false;
	}
}

class CBTTaskReactionDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskReaction';

	editable var counterChance			: int;
	editable var dodgeChanceAttacks		: int;
	editable var dodgeChanceAard		: int;
	editable var dodgeChanceIgni		: int;
	editable var dodgeChanceBomb		: int;
	editable var dodgeChanceProjectile	: int;
	
	editable var reactionDelay : float;
	
	default reactionDelay = 4;

	default counterChance			= 0;
	default dodgeChanceAttacks		= 15;
	default dodgeChanceAard			= 15;
	default dodgeChanceIgni			= 15;
	default dodgeChanceBomb			= 15;
	default dodgeChanceProjectile	= 15;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack('Time2Dodge');
	}
}
