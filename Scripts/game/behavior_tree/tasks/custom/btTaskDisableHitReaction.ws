/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskDisableHitReaction extends IBehTreeTask
{
	var onActivate 				: bool;
	var onDeactivate 			: bool;
	var overrideForThisTask 	: bool;
	
	function OnActivate() : EBTNodeStatus
	{
		if ( overrideForThisTask || onActivate )
			GetNPC().SetCanPlayHitAnim( false );
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( overrideForThisTask )
			GetNPC().SetCanPlayHitAnim( true );
		else if ( onDeactivate )
			GetNPC().SetCanPlayHitAnim( false );
	}
};

class CBTTaskDisableHitReactionDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDisableHitReaction';

	editable var onActivate 			: bool;
	editable var onDeactivate 			: bool;
	editable var overrideForThisTask 	: bool;
	
	default overrideForThisTask = true;
};


class CBTTaskSetUnstoppable extends IBehTreeTask
{
	var onActivate 				: bool;
	var onDeactivate 			: bool;
	var onSuccess 				: bool;
	var overrideForThisTask 	: bool;
	var makeUnpushable			: bool;
	var enable 	 				: bool;
	
	var m_savedPriority			: EInteractionPriority;
	
	function OnActivate() : EBTNodeStatus
	{
		
		if ( onActivate || overrideForThisTask )
		{
			GetNPC().SetUnstoppable( enable );
			if( makeUnpushable )
			{
				m_savedPriority  = GetNPC().GetInteractionPriority();
				GetNPC().SetInteractionPriority( IP_Max_Unpushable );
			}
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( overrideForThisTask )
		{
			GetNPC().SetUnstoppable( !enable );
			if( makeUnpushable )
			{
				GetNPC().SetInteractionPriority( m_savedPriority );
			}
		}
		else if ( onDeactivate )
		{
			GetNPC().SetUnstoppable( enable );
		}
	}
	
	function OnCompletion( success : bool )
	{
		
		if ( onSuccess && success )
			GetNPC().SetUnstoppable( enable );
	}
};

class CBTTaskSetUnstoppableDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSetUnstoppable';

	editable var onActivate 			: bool;
	editable var onDeactivate 			: bool;
	editable var onSuccess 				: bool;
	editable var overrideForThisTask 	: bool;
	editable var makeUnpushable			: bool;
	editable var enable  				: bool;
	
	hint makeUnpushable = "increase interaction priority to make the npc unpushable";
	
	default overrideForThisTask = true;
	default enable = true;
};
