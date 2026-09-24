/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskManageFXInstance extends IBehTreeTask
{
	public var hasAbilityCondition		: name;
	public var fxName 					: name;
	public var fxTickets				: int;
	public var distanceToAnotherFx 		: float;
	public var fxInstanceCheckInterval 	: float;
	public var stopFxAfterDeath			: bool;
	
	private var npcPos					: Vector;
	private var fxInstances				: int;
	
	
	
	latent function Main() : EBTNodeStatus
	{
		var actors 	: array<CActor>;
		var npc		: CNewNPC = GetNPC();
		var i 		: int;
		
		if ( IsNameValid( hasAbilityCondition ) )
		{
			if ( npc.HasAbility( hasAbilityCondition ) )
			{
				Execute();
			}
		}
		else
		{
			Execute();
		}
		
		return BTNS_Active;
	}
	
	private function OnDeactivate()
	{
		var npc		: CNewNPC = GetNPC();
		
		if ( !npc.IsAlive() && stopFxAfterDeath && npc.IsEffectActive( fxName) )
		{
			npc.StopEffect( fxName );
		}
	}
	
	private latent function Execute()
	{
		var actors 	: array<CActor>;
		var npc		: CNewNPC = GetNPC();
		var i 		: int;
		
		while ( npc.IsAlive() )
		{
			actors = GetActorsInRange( npc, distanceToAnotherFx, 999, '', true );
			fxInstances = 0;
			
			if ( actors.Size() > 0 )
			{
				for ( i = 0 ; i < actors.Size() ; i += 1 )
				{
					if ( actors[i].IsEffectActive( fxName ) )
					{
						fxInstances += 1;
					}
				}
			}
			
			if ( fxTickets > fxInstances )
			{
				if ( IsNameValid( fxName ) )
				{
					npc.PlayEffect( fxName );
				}
			}
			else if ( fxTickets < fxInstances )
			{
				if ( IsNameValid( fxName ) && npc.IsEffectActive( fxName ) )
				{
					npc.StopEffect( fxName );
				}
			}
			
			if ( fxInstanceCheckInterval > 0 )
			{
				Sleep( fxInstanceCheckInterval );
			}
			else
			{
				Sleep( 1.0 );
			}
		}
	}
}




class BTTaskManageFXInstanceDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskManageFXInstance';
	
	private editable var hasAbilityCondition		: name;
	private editable var fxName 					: name;
	private editable var fxTickets					: int;
	private editable var distanceToAnotherFx 		: float;
	private editable var fxInstanceCheckInterval 	: float;
	private editable var stopFxAfterDeath			: bool;
	
	default distanceToAnotherFx = 50;
	default stopFxAfterDeath = true;
	default fxTickets = 1;
}