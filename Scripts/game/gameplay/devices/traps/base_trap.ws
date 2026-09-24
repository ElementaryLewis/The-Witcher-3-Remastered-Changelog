/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ETrapOperation
{
	TO_Activate,
	TO_Deactivate,
}

class W3Trap extends W3MonsterClue
{
	
	
	
	const var 		ARM_INTERACTION_COMPONENT_NAME		: string;
	default ARM_INTERACTION_COMPONENT_NAME 				= "Arm";
	
	const var 		DISARM_INTERACTION_COMPONENT_NAME	: string;
	default DISARM_INTERACTION_COMPONENT_NAME 			= "Disarm";
	
	
	
	protected saved var 	m_IsActive					: bool;		default m_IsActive = false;
	protected var 			m_Targets					: array<CNode>;
	protected saved var		m_isArmed					: bool;    	default m_isArmed = true;
	protected saved var   	m_wasSprung					: bool;		default m_wasSprung = false;
	protected saved var 		m_isPlayingAnimation		: bool;
		
	
	private editable var activeByDefault				: bool;
	
	
	private editable var factOnArm						: SFactParameters;
	private editable var factOnDisarm					: SFactParameters;
	private editable var factOnActivation				: SFactParameters;
	private editable var factOnDeactivation				: SFactParameters;
	
	private editable var deactivateAfterTime			: float;
	
	private editable var appearanceActivated			: string;
	private editable var appearanceDeactived			: string;
	private editable var appearanceArmed				: string;
	private editable var appearanceDisarmed				: string;
	
	private editable var canBeArmed						: bool;
	private editable var interactibleAfterSprung		: bool;
	private editable var willActivateWhenHit			: bool;
	private editable var soundOnArm						: name;
	private editable var soundOnDisarm					: name;
	
	default interactionAnim					= PEA_None;
	default interactionAnimTime				= 4.0f;
	default willActivateWhenHit				= false;
	
	default deactivateAfterTime 		= -1;
	
	default canBeArmed = false;
	default interactibleAfterSprung = false;
	default soundOnArm = 'qu_item_disarm_trap';
	default soundOnDisarm = 'qu_item_disarm_trap';
	
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		m_IsActive = false;
		
		if( activeByDefault )
		{
			Activate();
		}
		
		UpdateVisibility();
		StructFactsHack();
		UpdateInteraction();
		super.OnSpawned( spawnData );
	}
	 
	 
	 event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		if ( interactionComponentName == "Arm" )
		{
			if( m_isPlayingAnimation )
			{
				return false;
			}
		}
		if ( interactionComponentName == "Disarm" )
		{
			if( m_isPlayingAnimation )
			{
				return false;
			}
		}
		
		return true;
	}
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if(activator != thePlayer && !thePlayer.IsActionAllowed( EIAB_InteractionAction ))
		{
			return false;	
		}
		if ( actionName == "Arm" )
		{
			m_isArmed = true;
			m_isPlayingAnimation = true;
			AddTimer ('ArmTrapTimer', interactionAnimTime, false);
		}
		if ( actionName == "Disarm" )
		{
			m_isPlayingAnimation = true;
			AddTimer ('DisarmTrapTimer', interactionAnimTime, false);
		}
		PlayInteractionAnimation();
		super.OnInteraction(actionName,activator);
	}
	
	event OnClueDetected()
	{
		
		super.OnClueDetected();
		UpdateInteraction();
	}
	
	event OnWeaponHit(act : W3DamageAction)
	{
		if (willActivateWhenHit) Activate();
	}
	
	
	
	public function Activate( optional _Target: CNode ):void
	{
		if( !m_IsActive )
		{
			m_IsActive = true;
			m_wasSprung = true;
			
			AddTimer( 'Update', 0, true, , , true );
			
			if( factOnActivation.ID != "" )
			{
				if( FactsDoesExist ( factOnActivation.ID ) )
				{
					FactsSet( factOnActivation.ID, factOnActivation.value, factOnActivation.validFor );
				}
				else
				{
					FactsAdd( factOnActivation.ID, factOnActivation.value, factOnActivation.validFor );
				}
			}
			
			ApplyAppearance( appearanceActivated );
			
			if( deactivateAfterTime > 0 )
			{
				AddTimer( 'Deactivate', deactivateAfterTime, , , , true );
			}
		}
		
		if ( _Target )
		{
			m_Targets.PushBack( _Target );
		}
		
		DisableAllInteractions();
	}
	
	
	public timer function Deactivate( optional _Delta : float, optional id : int):void
	{
		if( m_IsActive )
		{
			m_IsActive = false;			
			RemoveTimer( 'Update' );
			
			if( factOnDeactivation.ID != "" )
			{
				if( FactsDoesExist ( factOnDeactivation.ID ) )
				{
					FactsSet( factOnDeactivation.ID, factOnDeactivation.value, factOnDeactivation.validFor );
				}
				else
				{
					FactsAdd( factOnDeactivation.ID, factOnDeactivation.value, factOnDeactivation.validFor );
				}
			}
			
			ApplyAppearance( appearanceDeactived );
		}
		
		RemoveTimer( 'Deactivate' );
		
		UpdateInteraction();
	}
	
	
	public final function RemoveTarget( _Target : CNode )
	{
		m_Targets.Remove( _Target );
	}
	
	private timer function ArmTrapTimer ( optional _Delta : float, optional id : int )
	{
		GetWitcherPlayer().DisplayHudMessage("panel_hud_message_trap_armed");
		if( IsNameValid( soundOnArm ) ) this.SoundEvent( soundOnArm );
		Arm(true);
		m_isPlayingAnimation = false;
	}
	
	private timer function DisarmTrapTimer ( optional _Delta : float, optional id : int )
	{
		GetWitcherPlayer().DisplayHudMessage("panel_hud_message_trap_disarmed");
		if( IsNameValid( soundOnDisarm ) ) this.SoundEvent( soundOnDisarm );
		Arm(false);
		m_isPlayingAnimation = false;
	}
	
	public function Arm(shouldArm : bool)
	{
		if (shouldArm)
		{
			m_isArmed = true;
			ApplyAppearance( appearanceArmed );
			UpdateInteraction();
			
			
			if( GetFocusModeVisibility() != FMV_None )
			{
				SetFocusModeVisibility( FMV_Clue );
			}
		}
		else
		{
			m_isArmed = false;
			ApplyAppearance( appearanceDisarmed );
			Deactivate();
			
			
			if( GetFocusModeVisibility() != FMV_None )
			{
				SetFocusModeVisibility( FMV_Interactive );
			}			
		}
		SetFacts();
	}
	
	function UpdateInteraction( optional comp : CComponent )
	{
		var armComp : CComponent;
		var disarmComp : CComponent;
		
		armComp = GetComponent( ARM_INTERACTION_COMPONENT_NAME );
		disarmComp = GetComponent( DISARM_INTERACTION_COMPONENT_NAME );
		
		if ( this.GetWasDetected() && armComp && disarmComp )
		{
			if ( m_isArmed )
			{
				armComp.SetEnabled( false );	
				disarmComp.SetEnabled( true );
				
			}
			else
			{
				if (canBeArmed) 
				{
					if (m_wasSprung)
					{
						if (interactibleAfterSprung)
						{
							armComp.SetEnabled( true );
						}
					}
					else
					{ 
						armComp.SetEnabled( true );
					}
				}
				disarmComp.SetEnabled( false );
				
			}
					
		}
		else
		{
			LogAssert( false, "Trap <<" + this + ">> doesn't have both Arm and Disarm Interactive components" );
		}
		super.UpdateInteraction( comp );
	}
	
	function DisableAllInteractions ()
	{
		var armComp : CComponent;
		var disarmComp : CComponent;
		
		armComp = GetComponent( ARM_INTERACTION_COMPONENT_NAME );
		disarmComp = GetComponent( DISARM_INTERACTION_COMPONENT_NAME );
		
		if ( armComp && disarmComp )
		{
			armComp.SetEnabled( false );	
			disarmComp.SetEnabled( false );				
		}
	}
	
	private function SetFacts (  )
	{
		if ( !m_isArmed )
		{
			if ( factOnDisarm.ID != "" )
			{
				if ( !FactsDoesExist ( factOnDisarm.ID ) )
				{
					FactsAdd ( factOnDisarm.ID, factOnDisarm.value, factOnDisarm.validFor );
				}
			}
			if ( factOnArm.ID != "" )
			{
				if ( FactsDoesExist ( factOnArm.ID ) )
				{
					FactsRemove ( factOnArm.ID );
				}
			}
		}
		else
		{
			if ( factOnDisarm.ID != "" )
			{
				if ( FactsDoesExist ( factOnDisarm.ID ) )
				{
					FactsRemove ( factOnDisarm.ID );
				}
			}
			if ( factOnArm.ID != "" )
			{
				if ( !FactsDoesExist ( factOnArm.ID ) )
				{
					FactsAdd ( factOnArm.ID, factOnArm.value, factOnArm.validFor );
				}
			}
		}
	}
	
	private function StructFactsHack()
	{
		
		if ( factOnArm.ID != "" )
		{
			if (factOnArm.value == 0) factOnArm.value = 1;
			if (factOnArm.validFor == 0) factOnArm.validFor = -1;
		}
		if ( factOnDisarm.ID != "" )
		{
			if (factOnDisarm.value == 0) factOnDisarm.value = 1;
			if (factOnDisarm.validFor == 0) factOnDisarm.validFor = -1;
		}
		if ( factOnActivation.ID != "" )
		{
			if (factOnActivation.value == 0) factOnActivation.value = 1;
			if (factOnActivation.validFor == 0) factOnActivation.validFor = -1;
		}
		if ( factOnDeactivation.ID != "" )
		{
			if (factOnDeactivation.value == 0) factOnDeactivation.value = 1;
			if (factOnDeactivation.validFor == 0) factOnDeactivation.validFor = -1;
		}
	}
	
	event OnManageTrap( operations : array< ETrapOperation >, activator : CActor )
	{
		var i, size : int;
		
		
		if ( m_isArmed )
		{
			size = operations.Size();
			for ( i = 0; i < size; i += 1 )
			{
				switch ( operations[ i ] )
				{
				case TO_Activate:
					Activate(activator);
					break;
				case TO_Deactivate:
					Deactivate();
					break;
				}
			}
		}
	}
}