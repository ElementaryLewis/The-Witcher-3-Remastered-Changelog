/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EIllusionDiscoveredOneliner
{
	EIDO_PlayOnFirstDiscoveryInThisSession,				
	EIDO_PlayOnFirstDiscovery,							
	EIDO_PlayAlways,									
	EIDO_DontPlay										
}

statemachine class W3IllusionaryObstacle extends CGameplayEntity
{	

	
	
	
	private editable var focusAreaIntensity										: float;
	default focusAreaIntensity	= 0.75f;
	
	default autoState = 'Default';
	
	
	
	
	
	editable saved			var		isEnabled							: bool; default isEnabled = true;
	
	protected 	editable 	var		m_disappearanceEffectDuration		: float; default m_disappearanceEffectDuration = 5;
				editable 	var		m_addFactOnDispel					: string;
				editable 	var		m_addFactOnDiscovery				: string;
				editable	var 	discoveryOnelinerTag				: string;		
	private 	saved	 	var		m_discoveryOneliner					: EIllusionDiscoveredOneliner;
			
	private 	saved	 	var 	m_illusionDiscoveredEver			: bool;			
	private 		 		var 	m_illusionDiscoveredThisSession		: bool;			
	private 				var 	interactionComponent				: CInteractionComponent;
	private 				var 	meshComponent						: CMeshComponent;
	private 				var		m_effectRange						: float; default m_effectRange = 8;
	private    saved        var		m_wasDestroyed						: bool;
	
	private		 			var		m_illusionSpawner					: W3IllusionSpawner;
	private     saved       var     isFocusAreaActive					: bool;
	
				editable	var 	focusModeHighlight					: EFocusModeVisibility;
							default focusModeHighlight 					= FMV_Interactive;
							
							var	i										: int;
							var l_entitiesAround 						: array<CGameplayEntity>;
							var l_illusion								: W3IllusionaryObstacle;
							
							var saveLockID								: int;
	default saveLockID = -1;
	
	
	hint discoveryOnelinerTag = "if discovered all obstacles with this tag will not fire oneliner";
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		if ( m_wasDestroyed )
		{
			AddTimer( 'DestroyDelayed', 0.000001f, false );
		}
		else
		{
			if(!spawnData.restored)
				m_illusionDiscoveredEver = false;
				
			m_illusionDiscoveredThisSession = false;
			
			
			
			SetFocusModeVisibility( focusModeHighlight );
			GotoStateAuto();
		}
	}
	
	timer function DestroyDelayed( dt : float, id : int )
	{
		Destroy();
	}

	
	
	public function SetOneLinerHandling(h : EIllusionDiscoveredOneliner)
	{
		m_discoveryOneliner = h;
	}
	
	
	public function Dispel()
	{
		meshComponent = (CMeshComponent)GetComponentByClassName( 'CMeshComponent' );
		
		PlayEffect('dissapear');
		AddTimer('DeactivateFocusArea', m_disappearanceEffectDuration, false, , , true);
		interactionComponent.SetEnabled( false );
		
		if( m_addFactOnDispel != "")
		{
			FactsAdd( m_addFactOnDispel, 1 );
		}
	}
	
	
	private timer function DeactivateFocusArea( _delta:float , id : int)
	{
		isFocusAreaActive = false;
		theGame.GetFocusModeController().SetFocusAreaIntensity( 0.0f );
	}
	
	
	public function OverrideIllusionObstacleFactOnSpawn( overrideFactName : string )
	{
		m_addFactOnDispel = overrideFactName;
	}
	
	
	public function OverrideIllusionObstacleFactOnDiscovery( overrideFactName : string )
	{
		m_addFactOnDiscovery = overrideFactName;
	}
	
	public function SetDestroyed()
	{
		m_wasDestroyed = true;
		if ( m_illusionSpawner )
		{
			m_illusionSpawner.SetDestroyed();
		}
	}
	
	public function SetIllusionSpawner ( _illusionSpawner : W3IllusionSpawner )
	{
		m_illusionSpawner = _illusionSpawner;
	}
	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		if( interactionComponentName != "dispel" || activator != thePlayer || !isEnabled || thePlayer.GetPlayerAction() != PEA_None )
			return false;
			
		if ( !interactionComponent)
		{
			interactionComponent = (CInteractionComponent)GetComponent( 'dispel' );
		}
		return PlayerHasMedallion();
	}
	
	public function DestroyObstacle( optional destroyAfter : float )
	{
		if( destroyAfter == 0.0f )
		{
			destroyAfter = m_disappearanceEffectDuration;
		}
		
		AddTimer('DestroyTimer', destroyAfter, false, , , true);
		SetDestroyed();
	}
	
	public function SetIllusionEnabled( enabled : bool )
	{
		isEnabled = enabled;
	}
	
	function PlayerHasMedallion() : bool
	{
		var playerInventory : CInventoryComponent;
		playerInventory = thePlayer.GetInventory();
		if( playerInventory.HasItem( 'Illusion Medallion' ) )
		{
			return true;
		}
		return false;
	}
	
	public final function SetDiscoveryOnelinerTag(t : string)
	{
		discoveryOnelinerTag = t;
	}
	
	function DispelAllIlussions ()
	{
		FindGameplayEntitiesInSphere( l_entitiesAround , thePlayer.GetWorldPosition(), m_effectRange, 999 );
		
		for( i = 0 ; i < l_entitiesAround.Size() ; i += 1 )
		{
			l_illusion = (W3IllusionaryObstacle) l_entitiesAround[i];
			
			if( l_illusion )
			{
				l_illusion.Dispel();
				if( l_illusion != this )
					l_illusion.DestroyObstacle( m_disappearanceEffectDuration );
			}
		}
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if( activator != thePlayer || !thePlayer.CanPerformPlayerAction())
			return false;
		
		interactionComponent.SetEnabled( false );
		GotoState( 'Interacting' );
	}
	
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var play, groupDiscovered : bool;
		var i : int;
		var tags : array<name>;
		
		if ( activator.GetEntity() != thePlayer || m_wasDestroyed || !isEnabled || !PlayerHasMedallion() )
		{
			return false;
		}
		
				
		
		if(activator.GetEntity() == thePlayer && FactsQuerySum("blocked_illusion_oneliner") == 0 && thePlayer.IsAlive() && thePlayer.inv.GetItemQuantityByTag(theGame.params.TAG_ILLUSION_MEDALLION) > 0)
		{
			play = false;
			groupDiscovered = false;
			
			
			tags = GetTags();
			for(i=0; i<tags.Size(); i+=1)
			{
				if(FactsQuerySum("io_disc_" + NameToString(tags[i])) )
				{
					
					play = false;
					groupDiscovered = true;
					break;
				}
			}
			
			if(!groupDiscovered)
			{			
				if(m_discoveryOneliner == EIDO_PlayAlways)
				{
					play = true;
				}
				else if(m_discoveryOneliner == EIDO_PlayOnFirstDiscovery)
				{
					if(!m_illusionDiscoveredEver)
					{
						m_illusionDiscoveredEver = true;
						play = true;
					}
				}
				else if(m_discoveryOneliner == EIDO_PlayOnFirstDiscoveryInThisSession)
				{
					if(!m_illusionDiscoveredThisSession)
					{
						m_illusionDiscoveredThisSession = true;
						play = true;
					}
				}
			}
			
			if(play)
			{
				thePlayer.PlayVoiceset(90, "OnUsingEye");
				FactsAdd("blocked_illusion_oneliner", 1, CeilF(thePlayer.delayBetweenIllusionOneliners) );
				
				isFocusAreaActive = true;
				theGame.GetFocusModeController().SetFocusAreaIntensity( focusAreaIntensity );
				
				
				if(activator.GetEntity() == thePlayer && m_addFactOnDiscovery != "" && thePlayer.inv.GetItemQuantityByTag(theGame.params.TAG_ILLUSION_MEDALLION) > 0 )
				{
					if( !FactsDoesExist(m_addFactOnDiscovery) )
					{
						FactsAdd( m_addFactOnDiscovery, 1 );
					}
					
				}				
			}
			
			
			if(discoveryOnelinerTag != "")
				FactsAdd("io_disc_" + discoveryOnelinerTag);
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		
		if ( activator.GetEntity() != thePlayer  )
		{
			return false;
		}
		
		isFocusAreaActive = false;
		theGame.GetFocusModeController().SetFocusAreaIntensity( 0.0f );
		
	}
	
}

state Default in W3IllusionaryObstacle
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
	}
}

state Interacting in W3IllusionaryObstacle
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		theGame.CreateNoSaveLock( 'illusionaryObstacle', parent.saveLockID );
		
		Interacting ();
	}
	
	entry function Interacting ()
	{
		var restoreUsableItem : bool;
		
		
		thePlayer.BlockAction(EIAB_Interactions, 'IllusionObstacle' );
		thePlayer.BlockAction(EIAB_FastTravel, 'IllusionObstacle' );
		thePlayer.BlockAllActions( 'input_handler', true );
		
	
		if ( thePlayer.IsHoldingItemInLHand() )
		{
			restoreUsableItem = true;
			
			
			
			thePlayer.HideUsableItem(true);
			
			
			
		}
		
		thePlayer.PlayerStartAction( PEA_DispelIllusion );
		parent.DispelAllIlussions ();
		
		thePlayer.WaitForAnimationEvent ('HideMedallion', 5.0f );
	
		if ( restoreUsableItem )
		{
			thePlayer.OnUseSelectedItem();
		}
		parent.GotoState ( 'Destroying' );
	}
	
	latent function WaitForUseItemAction ()
	{
		while ( true )
		{
			if ( !thePlayer.IsUsableItemLBlocked() )
			{
				break;
			}
			Sleep ( 0.1f );
		}
	}
}

state Destroying in W3IllusionaryObstacle
{
	var items 		: array<SItemUniqueId>;
	var  medallion  : SItemUniqueId;
	var i 			: int;
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		thePlayer.UnblockAction(EIAB_Interactions, 'IllusionObstacle' );
		thePlayer.UnblockAction(EIAB_FastTravel, 'IllusionObstacle' );
		thePlayer.BlockAllActions( 'input_handler', false );
		
		theGame.ReleaseNoSaveLock( parent.saveLockID );
		
		items = thePlayer.inv.GetItemsByName( 'Illusion Medallion');
		
		for ( i=0; i<items.Size(); i+=1 )
		{
			medallion = items[i];
				
			if ( thePlayer.inv.IsIdValid( medallion ) && (thePlayer.inv.IsItemMounted( medallion ) || thePlayer.inv.IsItemHeld(medallion)) )
			{
				thePlayer.inv.UnmountItem(medallion, true);
			}
		}
		
		parent.DestroyObstacle( 0.01f );
	}
}