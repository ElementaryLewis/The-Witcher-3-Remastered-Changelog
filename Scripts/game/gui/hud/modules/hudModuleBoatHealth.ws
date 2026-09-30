/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CR4HudModuleBoatHealth extends CR4HudModuleBase
{	
	
	
	
	private	var m_fxSetVolumeHealth			: CScriptedFlashFunction;

	private var m_wasInBoat : bool;

	 event OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName 			= "mcAnchorBoatHealth";
		
		super.OnConfigUI();
		
		flashModule 			= GetModuleFlash();
		
		m_fxSetVolumeHealth		= flashModule.GetMemberFlashFunction( "setVolumeHealth" );
		
		
		ClearVolumes();
		
		m_wasInBoat = false;

		
		SetTickInterval( 1 );
		
		hud = (CR4ScriptedHud)theGame.GetHud();
						
		if (hud)
		{
			hud.UpdateHudConfig('BoatHealthModule', true);
		}
	}

	function SetEnabled( value : bool )
	{
		super.SetEnabled(value);
		ShowElement( value );
	}	

	event OnTick( timeDelta : float )
	{
		var isInBoat : bool;

		if ( !CanTick( timeDelta ) || !m_bEnabled )
		{
			return true;
		}

		isInBoat = thePlayer.IsSailing();
		if ( isInBoat )
		{
			UpdateVolumes();
			if ( isInBoat != m_wasInBoat )
			{
				ShowElement( true ); 
				m_wasInBoat = isInBoat;
			}
		}
		else
		{
			if ( m_wasInBoat )
			{
				m_wasInBoat = false;
				ClearVolumes();
				ShowElement( false ); 
			}
		}
	}

	private function UpdateVolumes()
	{
		var boat : CGameplayEntity;
		var component : CBoatDestructionComponent;
		var i : int;
		var health : float;

		boat = thePlayer.GetUsedVehicle();
		if ( boat )
		{
			component = (CBoatDestructionComponent)boat.GetComponentByClassName( 'CBoatDestructionComponent' );
			if ( component )
			{
				for ( i = 0; i < component.destructionVolumes.Size(); i += 1 )
				{
					health = component.destructionVolumes[ i ].areaHealth;
					m_fxSetVolumeHealth.InvokeSelfTwoArgs( FlashArgInt( i ), FlashArgNumber( health ) );
				}
			}
		}
	}	

	private function ClearVolumes()
	{
		var i : int;
		
		for ( i = 0; i < 6; i += 1 )
		{
			m_fxSetVolumeHealth.InvokeSelfTwoArgs( FlashArgInt( i ), FlashArgNumber( 100 ) );
		}
	}
}
