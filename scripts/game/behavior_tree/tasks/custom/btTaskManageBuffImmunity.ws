/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskManageBuffImmunity extends IBehTreeTask
{
	var effects 		: array<EEffectType>;
	var onActivate 		: bool;
	var onDeactivate 	: bool;
	var bRemove			: bool;
	var removeFromTemplate	: bool;
	
	function IsAvailable() : bool
	{
		return true;
	}

	function OnActivate() : EBTNodeStatus
	{
		var npc		: CActor = GetActor();
		var i		: int;
		
		if( onActivate )
		{
			for ( i = 0; i < effects.Size(); i += 1 )
			{
				if( bRemove )
				{
					if( removeFromTemplate )
						npc.RemoveBuffImmunity( effects[i] );
					else
						npc.RemoveBuffImmunity( effects[i], 'CBTTaskManageBuffImmunity' );
				}
				else
				{
					npc.AddBuffImmunity( effects[i], 'CBTTaskManageBuffImmunity', true );
				}
			}
		}

		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var npc		: CActor = GetActor();
		var i		: int;
		
		if( onDeactivate )
		{
			for ( i = 0; i < effects.Size(); i += 1 )
			{
				if( bRemove )
				{
					if( removeFromTemplate )
						npc.RemoveBuffImmunity( effects[i] );
					else
						npc.RemoveBuffImmunity( effects[i], 'CBTTaskManageBuffImmunity' );
				}
				else
				{
					npc.AddBuffImmunity( effects[i], 'CBTTaskManageBuffImmunity', true );
				}
			}
		}
	}
}

class CBTTaskManageBuffImmunityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskManageBuffImmunity';

	editable var effects 			: array<EEffectType>;
	editable var onActivate 		: bool;
	editable var onDeactivate 		: bool;
	editable var bRemove			: bool;
	editable var removeFromTemplate	: bool;
	
	default onActivate = true;
	
	hint bRemove = "false - adding immunities, true - removing immunities";
}