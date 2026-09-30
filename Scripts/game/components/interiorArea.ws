/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CR4InteriorAreaComponent extends CTriggerAreaComponent
{
	editable var isDarkPlace : bool;	
		default isDarkPlace = false;
		hint isDarkPlace = "If set area is considered a dark place (player should use torch / cat potion)";
		
		editable var useInteriorDefinitionsForLy : bool;	
		default useInteriorDefinitionsForLy = true;
		hint useInteriorDefinitionsForLy = "Use the color, fog and SSAO NV varaibles from the Env defs for interiors";
		
		editable var isCave : bool;
		default isCave = false;
		hint isCave = "If interior is cave. Only used in postprocessing with useInteriorDefinitions";
		
		editable var InteriorDefBlendingEnter : float;
		default InteriorDefBlendingEnter = 3.f;
		
		editable var InteriorDefBlendingExit : float;
		default InteriorDefBlendingExit = 3.f;
	
	editable var allowHorseInThisInterior : bool;
		default allowHorseInThisInterior = false;
		hint allowHorseInThisInterior = "If left at false Geralt won't be able to mount, summon or ride horse inside this area and will be automatically dismount on enter";
	
	
	editable var movementLock : EPlayerMovementLockType;	default movementLock	= PMLT_NoSprint;
	
	
	event OnPlayerEntered( entered : bool )
	{
		var environment : CEnvironmentDefinition;
		var envID : int;
			switch( movementLock )
			{
				case PMLT_NoSprint :
					thePlayer.interiorTracker.LockSprint( entered );
				break;
				case PMLT_NoRun :
					thePlayer.interiorTracker.LockRun( entered );
				break;
			}
		

		
		
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var inv 	     			: CInventoryComponent;

		if(activator.GetEntity() != thePlayer)
			return false;
		
		
		
		

	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var inv 	     			: CInventoryComponent;

		if(activator.GetEntity() != thePlayer)
		{
			return false;
		}
		LogGalaxy(" exited ");
		
		
		if(isDarkPlace)
		{
			FactsSubstract("tut_in_dark_place");
			
			
			if( FactsQuerySum( "tut_in_dark_place" ) <= 0 )
			{
				thePlayer.RemoveBuff( EET_Mutation12Cat );

			}
		}
	}
}