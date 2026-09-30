/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3GameLog
{
	public const var COLOR_GOLD_BEGIN, COLOR_GOLD_END : string;
	private var cachedCombatMessages : array<SCachedCombatMessage>;		

		default COLOR_GOLD_BEGIN = "<font color=\"#CD7D03\">";
		default COLOR_GOLD_END = "</font>";

	public function AddMessage(m : string)
	{
		var hud : CR4ScriptedHud;
		
		if(m == "")
			return;

		hud = (CR4ScriptedHud)theGame.GetHud();	
		hud.HudConsoleMsg(m);
	}
	
	private function ShouldShowCombatMessage(attacker : CGameplayEntity, victim : CGameplayEntity) : bool
	{
		
		if(!thePlayer.IsThreatened() && !thePlayer.IsInCombat())
			return false;
			
		
		if( (attacker && attacker.GetDisplayName() == "") || (victim && victim.GetDisplayName() == "") )
			return false;
			
		
		if(attacker == thePlayer || (attacker && attacker.HasTag(theGame.params.TAG_NPC_IN_PARTY)) || (victim && victim.HasTag(theGame.params.TAG_NPC_IN_PARTY)) )
			return true;
			
		
		if(victim == thePlayer)
			return true;
			
		return false;
	}
	
	public function AddCombatMessage(m : string, attacker : CGameplayEntity, victim : CGameplayEntity)
	{
		if(ShouldShowCombatMessage(attacker, victim))
			AddMessage(m);
	}
	
	
	public function FormatF(f : float) : string
	{
		var str : string;
		var temp : float;
		
		temp = RoundTo(f, 2);
		str = NoTrailZeros(temp);
		str = "<font size=\"20\">" + str + "</font>";
		
		return str;
	}
	
	
	public function CacheCombatDamageMessage(attacker : CGameplayEntity, victim : CGameplayEntity, finalDamage : float)
	{
		var m : SCachedCombatMessage;
		
		m.finalDamage = finalDamage;
		m.attacker = attacker;
		m.victim = victim;
		
		cachedCombatMessages.PushBack(m);
	}
	
	public function CreateCombatMessage(cachedDamageIndex : int) : string
	{
		var logPoints, logPercents, logPrefix, returnStr : string;
		var arrStr : array<string>;
		var msg : SCachedCombatMessage;
		
		if(!ShouldShowCombatMessage(cachedCombatMessages[cachedDamageIndex].attacker, cachedCombatMessages[cachedDamageIndex].victim))
			return "";
		
		msg = cachedCombatMessages[cachedDamageIndex];
		
		if(FactsQuerySum("q602_geralt_possessed") > 0)
		{
			if(msg.attacker == GetWitcherPlayer())
				arrStr.PushBack( GetLocStringByKey("Witold") );
			else
				arrStr.PushBack(msg.attacker.GetDisplayName());
				
			if(msg.victim == GetWitcherPlayer())
				arrStr.PushBack( GetLocStringByKey("Witold") );
			else
				arrStr.PushBack(msg.victim.GetDisplayName());
		}
		else
		{
			arrStr.PushBack(msg.attacker.GetDisplayName());
			arrStr.PushBack(msg.victim.GetDisplayName());
		}
		arrStr.PushBack(FormatF(msg.finalDamage));
		logPrefix = GetLocStringByKeyExtWithParams("hud_combat_log_hit", , , arrStr);

		if(msg.resistPoints > 0)
			logPoints = COLOR_GOLD_BEGIN + FormatF(msg.resistPoints) + COLOR_GOLD_END;
		else
			logPoints = "";
			
		if(msg.resistPercents > 0)
			logPercents = COLOR_GOLD_BEGIN + FormatF( (1-msg.resistPercents)*100 ) + COLOR_GOLD_END;
		else
			logPercents = "";
					
		if(logPoints == "" && logPercents == "")
		{
			
			if(ShouldShowCombatMessage(msg.attacker, msg.victim))
				returnStr = logPrefix;
		}
		else if(logPoints == "" && logPercents != "")
		{
			
			if(ShouldShowCombatMessage(msg.attacker, msg.victim))
				returnStr = logPrefix + " (" + FormatF(msg.finalIncomingDamage) + " * " + logPercents + "%)";
		}
		else if(logPoints != "" && logPercents == "")
		{
			
			if(ShouldShowCombatMessage(msg.attacker, msg.victim))
				returnStr = logPrefix + " (" + FormatF(msg.finalIncomingDamage) + " - " + logPoints + ")";
		}
		else
		{
			
			if(ShouldShowCombatMessage(msg.attacker, msg.victim))
				returnStr = logPrefix + " ( (" + FormatF(msg.finalIncomingDamage) + " - " + logPoints + ") * " + logPercents + "%)";
		}
		
		return returnStr;
	}
	
	
	public final function CombatMessageAddGlobalDamageMult(mult : float)
	{
		var i : int;
		
		for(i=0; i<cachedCombatMessages.Size(); i+=1)
			cachedCombatMessages[i].finalDamage *= mult;
	}
	
	public final function AddCombatDamageMessage(dealtDamage : bool)
	{
		var i : int;

		for(i=0; i<cachedCombatMessages.Size(); i+=1)
			AddMessage(CreateCombatMessage(i));
			
		cachedCombatMessages.Clear();
	}
}