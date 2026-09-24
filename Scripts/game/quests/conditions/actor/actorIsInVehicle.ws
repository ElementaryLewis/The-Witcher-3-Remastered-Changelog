/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_IsInVehicle extends CQCActorScriptedCondition
{
	editable var vehicleType 	: EVehicleType;
	editable var vehicleTag		: name;
	editable var anyVehicle		: bool;

	function Evaluate(act : CActor) : bool
	{
		var vehicleEntity 		: CGameplayEntity;
		var vehicleComponent	: CVehicleComponent;
		var npc 				: CNewNPC;
		
		vehicleEntity 		= act.GetUsedVehicle();
		
		if( !vehicleEntity )
			return false;
		
		vehicleComponent	= (CVehicleComponent)vehicleEntity.GetComponentByClassName( 'CVehicleComponent' );
		
		if ( !vehicleComponent )
			return false;

		if ( IsNameValid( vehicleTag ) && !vehicleEntity.HasTag( vehicleTag ) )
		{
			return false;
		}
		
		if( (anyVehicle || vehicleType == EVT_Boat) && (CBoatComponent)vehicleComponent )
		{
			return true;
		}
		else if( (anyVehicle || vehicleType == EVT_Horse) && (W3HorseComponent)vehicleComponent )
		{
			return true;
		}
		return false;
	}
}
