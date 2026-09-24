/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum W3TableState
	{
		TS_Clue,
		TS_Table,
	};
	
class W3AlchemyTable extends  CR4MapPinEntity
{	
	private saved var m_tableState 		: W3TableState;
	
		default m_tableState = TS_Clue;
		default focusModeVisibility = FMV_Interactive;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();

		if( activator.GetEntity() == GetWitcherPlayer() )
		{
			mapManager.SetEntityMapPinDiscoveredScript( false, entityName, true );
			area.SetEnabled( false );
		}
	}
	
	event OnInteractionAttached( interaction : CInteractionComponent )
	{		
		if( interaction == GetComponent( "Examine" ) && m_tableState == TS_Clue )
		{
			interaction.SetEnabled( true );
			SetFocusModeVisibility( FMV_Clue );
		}
		else if( interaction == GetComponent( "Use" ) && m_tableState == TS_Clue )
		{
			interaction.SetEnabled( false );
		}
	}

	event OnInteraction( actionName : string, activator : CEntity )
	{
		var l_witcherInv	: CInventoryComponent;
		var l_component		: CInteractionComponent;
		
		if( actionName == "Examine" )
		{	
			SetFocusModeVisibility( FMV_Interactive );
			m_tableState = TS_Table;
		
			l_component = (CInteractionComponent)GetComponent( "Examine" );
			l_component.SetEnabled( false );
			
			l_component = (CInteractionComponent)GetComponent( "Use" );
			l_component.SetEnabled( true );
			
		}
	}
}