/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3BlockGameplayActionsTrigger extends CGameplayEntity 
{
	private editable var blockedActions	: array< EInputActionBlock >;
	private editable var sourceName 	: name;
	private editable var sheatheWeaponIfDrawn : bool;
	private editable var sheatheWeaponIfDrawnNotInCombat : bool;

	hint sheatheWeaponIfDrawn ="Force sheathe weapon";
	hint sheatheWeaponIfDrawnNotInCombat = "Only sheathe weapon if not in combat";

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var i : int;
		
		if ( !((CPlayer)activator.GetEntity()) )
			return false;
		
		for ( i = 0; i < blockedActions.Size(); i += 1 )
		{
			thePlayer.BlockAction( blockedActions[ i ], sourceName, false, false, true );
		}
		
		if(sheatheWeaponIfDrawn)
		{
			
			thePlayer.OnMeleeForceHolster(true);
				
			
			thePlayer.DisableCombatState();
		}

		if(sheatheWeaponIfDrawnNotInCombat && !thePlayer.IsInCombat())
		{
			
			thePlayer.OnMeleeForceHolster(true);
				
			
			thePlayer.DisableCombatState();
		}
	
		UpdateHud( true );
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var i : int;
		
		if ( !((CPlayer)activator.GetEntity()) )
			return false;
		
		for ( i = 0; i < blockedActions.Size(); i += 1 )
		{
			thePlayer.UnblockAction( blockedActions[ i ], sourceName );
		}
		UpdateHud( false );
	}
	 
	private function UpdateHud( block : bool )
	{
		var i : int;
		var hud : CR4ScriptedHud;		
		var moduleSignInfo : CR4HudModuleSignInfo;
		var moduleItemInfo : CR4HudModuleItemInfo;

		hud = (CR4ScriptedHud)theGame.GetHud();
		
		for ( i = 0; i < blockedActions.Size(); i += 1 )
		{
			switch ( blockedActions[ i ] )
			{
			case EIAB_Signs:
				moduleSignInfo = (CR4HudModuleSignInfo)hud.GetHudModule( "SignInfoModule" );
				moduleSignInfo.EnableElement( !block );
				break;
			case EIAB_ThrowBomb:
			case EIAB_Crossbow:

			case EIAB_UsableItem:
				moduleItemInfo = (CR4HudModuleItemInfo)hud.GetHudModule( "ItemInfoModule" );
				moduleItemInfo.EnableElement( !block );
				break;
			}
		}
	}
}