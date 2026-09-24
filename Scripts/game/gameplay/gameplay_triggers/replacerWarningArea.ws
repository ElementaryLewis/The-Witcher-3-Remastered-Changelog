/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ReplacerWarningArea extends CEntity
{
	editable var messageKey : string;
	editable var messageInterval : float;
	editable var invertLogic : bool;
	
	default messageInterval = 3.f;
	default invertLogic = false;
	
	private var isPlayerInArea : bool;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		actor = (CActor)activator.GetEntity();
		
		if ( actor && actor == thePlayer )
		{
			Toggle(!invertLogic);
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		
		actor = (CActor)(activator.GetEntity());		
		if (actor && actor == thePlayer )
		{
			Toggle(invertLogic);
		}
	}
	
	function Toggle( toggle : bool )
	{
		if ( toggle && !isPlayerInArea )
		{
			isPlayerInArea = true;
			ShowMessage(0,0);
			AddTimer('ShowMessage',messageInterval, true);
		}
		else if ( !toggle && isPlayerInArea )
		{
			isPlayerInArea = false;
			RemoveTimer('ShowMessage');
			HideMessage();
		}
	}
	
	timer function ShowMessage( dt : float , id : int)
	{
		
		
		if( !((W3Replacer)thePlayer) )
			return;
			
		thePlayer.DisplayHudMessage( GetLocStringByKeyExt(messageKey) );
	}	

	function HideMessage()
	{
		var hud : CR4ScriptedHud;
		var messageModule : CR4HudModuleMessage;
		
		thePlayer.RemoveHudMessageByString(GetLocStringByKeyExt(messageKey), true);
		
		if( thePlayer.GetHudPendingMessage() == GetLocStringByKeyExt(messageKey) )
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			if( hud )
			{
				messageModule = (CR4HudModuleMessage)hud.GetHudModule("MessageModule");
				if( messageModule )
				{
					messageModule.OnMessageHidden();
				}
			}
		}
	}
	
	public final function SetEnabled(en : bool)
	{
		GetComponentByClassName('CTriggerAreaComponent').SetEnabled(en);
		
		if(!en)
		{
			RemoveTimer('ShowMessage');
			HideMessage();
		}
	}
}