/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskTaunt extends CBTTaskPlayAnimationEventDecorator
{
	public var tauntType			: ETauntType;
	public var tauntDelay 			: float;
	public var useXMLTauntChance	: bool;
	
	private var chance				: int;
	
	private var timeStamp : float;
	
	function IsAvailable() : bool
	{
		InitializeCombatDataStorage();
		timeStamp = combatDataStorage.GetTauntTimeStamp();
		if ( tauntDelay > 0 && timeStamp > 0 && ( timeStamp + tauntDelay > GetLocalTime() ) )
		{
			return false;
		}
		
		if ( useXMLTauntChance )
		{
			chance = (int)(100*CalculateAttributeValue(GetActor().GetAttributeValue('taunt_chance')));
			if ( !Roll(chance) )
				return false;
		}
		
		
		if ( GetActor().HasTag('mq1060_pv_boss') )
			return false;
		
		
		return true;
	}

	function OnActivate() : EBTNodeStatus
	{
		InitializeCombatDataStorage();
		GetNPC().SetBehaviorVariable( 'TauntType', (int)tauntType );
		combatDataStorage.SetIsTaunting( true, GetLocalTime() );
		return super.OnActivate();
	}
	
	function OnDeactivate()
	{
		combatDataStorage.SetIsTaunting( false );
		super.OnDeactivate();
	}
};

class CBTTaskTauntDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskTaunt';

	editable var tauntType			: ETauntType;
	editable var tauntDelay 		: float;
	editable var useXMLTauntChance	: bool;

	default tauntDelay = 10.0;
	default useXMLTauntChance = false;
};