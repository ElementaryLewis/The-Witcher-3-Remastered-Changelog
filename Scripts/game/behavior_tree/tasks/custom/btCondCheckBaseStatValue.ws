/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondCheckStatValue extends IBehTreeTask
{
	
	
	
	var checkedActor 	: EStatOwner;
	var baseStatType	: EBaseCharacterStats;
	var autoCheckHPType	: bool;
	var statValue 		: float;
	var percentage		: bool;
	var operator 		: EOperator;
	
	
	
	function IsAvailable() : bool
	{
		var target 	: CActor;		
		var oppNo 	: float;
		
		target = GetNPC();
		
		if( checkedActor == SO_Target )
		{
			target = target.GetTarget();
		}
		
		oppNo = GetStat(target);
		
		switch ( operator )
		{
			case EO_Equal:			return oppNo == statValue;
			case EO_NotEqual:		return oppNo != statValue;
			case EO_Less:			return oppNo < 	statValue;
			case EO_LessEqual:		return oppNo <= statValue;
			case EO_Greater:		return oppNo > 	statValue;
			case EO_GreaterEqual:	return oppNo >= statValue;
			default : 				return false;
		}
	}
	
	
	function GetStat(target : CActor) : float
	{
		var value : float;
		
		if ( percentage )
		{
			if ( autoCheckHPType && ( baseStatType == BCS_Vitality || baseStatType == BCS_Essence ))
			{
				value = 100*target.GetHealthPercents();
				return 100*target.GetHealthPercents();
			}
			value = 100*target.GetStatPercents( baseStatType );
			return 100*target.GetStatPercents( baseStatType );
		}
		else
		{
			if ( autoCheckHPType && ( baseStatType == BCS_Vitality || baseStatType == BCS_Essence ))
			{
				value = target.GetCurrentHealth();
				return target.GetCurrentHealth();
			}
			value = target.GetStat( baseStatType );
			return target.GetStat( baseStatType );
		}
	}
	
}


class BTCondCheckStatValueDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondCheckStatValue';

	editable var checkedActor 		: EStatOwner;
	editable var baseStatType		: EBaseCharacterStats;
	editable var autoCheckHPType	: bool;
	editable var statValue			: float;
	editable var percentage			: bool;
	editable var operator 			: EOperator;
	
	default checkedActor 			= SO_NPC;
	default baseStatType 			= BCS_Vitality;
	default statValue 				= 30.f;
	default autoCheckHPType			= true;
	
	default percentage 				= true;
}
