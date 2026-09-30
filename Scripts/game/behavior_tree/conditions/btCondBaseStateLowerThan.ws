/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EStatOwner
{
	SO_NPC,
	SO_Target,
	SO_ActionTarget
}

class BTCondBaseStatLowerThan extends IBehTreeTask
{
	var checkedActor 	: EStatOwner;
	var baseStatType	: EBaseCharacterStats;
	var statValue 		: float;
	var percentage		: bool;
	var ifNot			: bool;
	
	
	function IsAvailable() : bool
	{
		var target : CActor;
		
		target = GetNPC();
		
		if( checkedActor == SO_Target )
		{
			target = target.GetTarget();
		}
		
		if(ifNot)
		{
			
			if( GetStat(target) > statValue )
			{
				return true;
			}
			
		}
		else
		{
			if( GetStat(target) < statValue )
			{
				return true;
			}
		}
		return false;
	}
	
	function GetStat(target : CActor) : float
	{
		var value : float;
		
		if ( percentage )
		{
			value = 100*target.GetStatPercents( baseStatType );
			return 100*target.GetStatPercents( baseStatType );
		}
		else
		{
			value = target.GetStat( baseStatType );
			return target.GetStat( baseStatType );
		}
	}
	
}

class BTCondBaseStatLowerThanDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondBaseStatLowerThan';

	editable var checkedActor 	: EStatOwner;
	editable var baseStatType	: EBaseCharacterStats;
	editable var statValue		: float;
	editable var percentage		: bool;
	editable var ifNot			: bool;
	
	default checkedActor = SO_NPC;
	default baseStatType = BCS_Vitality;
	default statValue = 30.f;
	
	default ifNot = false;
	default percentage = true;
}

class BTCondStaminaLowerThan extends IBehTreeTask
{
	var baseStatType	: EBaseCharacterStats;
	var statName		: CName;
	var getStat			: bool;
	var statValue		: float;
	
	default getStat = true;
	
	
	function IsAvailable() : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if ( getStat )
		{
			statValue = npc.GetStat(StatNameToEnum(statName));
			getStat = false;
		}
		
		
		if ( npc.GetStat( BCS_Stamina ) < statValue )
		{
			return false;
		}
		
		return true;
	}
	
}

class BTCondStaminaLowerThanDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondStaminaLowerThan';

	editable var statName		: CName;
	
	hint statName = "name of the stat in xml file";
}
