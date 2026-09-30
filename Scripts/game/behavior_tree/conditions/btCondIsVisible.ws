/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsVisible extends IBehTreeTask
{
	public var gameplayVisibility 	: bool;
	public var meshVisibility 		: bool;
	public var forceComplete 		: bool;
	public var target 				: bool;
	public var invert 				: bool;

	function IsAvailable() : bool
	{
		if ( invert )
		{
			return !IsVisible();
		}
		else
		{
			return IsVisible();
		}
	}
	
	latent function Main() : EBTNodeStatus
	{
		if ( forceComplete )
		{
			while ( true )
			{
				if ( invert )
				{
					if ( IsVisible() )
					{
						return BTNS_Completed;
					}
				}
				else
				{
					if ( !IsVisible() )
					{
						return BTNS_Completed;
					}
				}
				SleepOneFrame();
			}
		}
		
		return BTNS_Active;
	}
	
	function IsVisible() : bool
	{
		var npc	: CNewNPC = GetNPC();
		
		if ( meshVisibility )
		{
			if ( target )
			{
				if ( GetCombatTarget().GetVisibility() )
				{
					return true;
				}
				else
				{
					return false;
				}
			}
			else
			{
				if ( npc.GetVisibility() )
				{
					return true;
				}
				else
				{
					return false;
				}
			}
		}
		
		if ( gameplayVisibility )
		{
			if ( target )
			{
				if ( GetCombatTarget().GetGameplayVisibility() )
				{
					return true;
				}
				else
				{
					return false;
				}
			}
			else
			{
				if ( npc.GetGameplayVisibility() )
				{
					return true;
				}
				else
				{
					return false;
				}
			}
		}
		
		if ( invert )
		{
			return false;
		}
		else
		{
			return true;
		}
	}
};

class CBTCondIsVisibleDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsVisible';

	editable var gameplayVisibility 	: bool;
	editable var meshVisibility 		: bool;
	editable var forceComplete 			: bool;
	editable var target 				: bool;
	editable var invert 				: bool;
};