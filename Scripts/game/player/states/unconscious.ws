/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Unconscious in CR4Player extends ExtendedMovable
{
	private const var duration : float;
	default duration = 4.0;
	
	private var isUnconscious : bool;
	private var killedByGuard : bool;
	private var killedByElevator : bool;
	private var wasInFFMiniGame	: bool;
	
	private	var	m_storedInteractionPri 		: EInteractionPriority; default	m_storedInteractionPri 		= IP_NotSet;
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		parent.BlockAllActions( 'PlayerUnconscious', true );
		
		wasInFFMiniGame = parent.IsFistFightMinigameEnabled();
		
		SetIsUnconscious( true );
		
		CacheSwordInHand();
		
		ChangeInteractionPriority();
		
		ProcessUncounscious();
	}

	event OnLeaveState( nextStateName : name )
	{
		super.OnLeaveState( nextStateName );
		
		theGame.FadeInAsync();
		parent.BlockAllActions( 'PlayerUnconscious', false );
		SetIsUnconscious( false );
		parent.SetBehaviorVariable( 'unconsciousEnd', 0 );
		killedByGuard = false;
		killedByElevator = false;
		wasInFFMiniGame = false;
		
		ResetInteractionPriority();
		
		parent.Revive();
	}
	
	event OnPlayerTickTimer( deltaTime : float )
	{
	
	}
	
	event OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
	{
		if ( killedByGuard )
		{
			
			if(parent.GetExplCamera())
			{
				moveData.pivotPositionController.SetDesiredPosition( parent.GetWorldPosition() , 15.f );
				moveData.pivotDistanceController.SetDesiredDistance( 1.5f );			
				moveData.pivotPositionController.offsetZ = 1.15f;
				
				DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( 6.0f, -3.1f, 1.2f ), 2.0f, dt );
			}
			else
			{
			
				moveData.pivotRotationController.SetDesiredHeading(parent.GetHeading()*-1);
				moveData.pivotRotationController.SetDesiredPitch(-45);
			}
		}
	}
	
	entry function ProcessUncounscious()
	{
		parent.RaiseForceEvent( 'Unconscious' );
		
		if ( killedByGuard )
		{
			Sleep( 1.0 );
			theGame.FadeOutAsync( 1.5 );
			Sleep( 1.5 );
			HideWeapon();
			
			TakeMoneyFromPlayer();
			
			TimeFlow();
			RestoreSword();
			theGame.FadeIn( 1.5 );
			Sleep( 1.5 );
			DisplayMessage();
		}
		else if ( killedByElevator )
		{
			Sleep( 1.0 );
			theGame.FadeOutAsync( 1.5 );
			Sleep( 1.5 );
			HideWeapon();
			TeleportAwayFromElevator();
			TimeFlow();
			RestoreSword();
			theGame.FadeIn( 1.5 );
			Sleep( 1.5 );
		}
		else if ( wasInFFMiniGame )
		{
            Sleep( 1.0 );
			theGame.FadeOut( 1.5 );
			HideWeapon();
			parent.RaiseForceEvent('ForceIdle');
			Sleep( 1.5 );
			parent.GotoStateAuto();
		}
		else
		{
			Sleep( 0.5 );
			theGame.FadeOut( 1.5 );
			HideWeapon();
			theGame.FadeInAsync( 1.5 );
		}
		
		parent.SetBehaviorVariable( 'unconsciousEnd', 1 );
		Sleep( 9.0 );
		parent.GotoStateAuto();
	}
	
	latent function HideWeapon()
	{
		thePlayer.SetRequiredItems('Any', 'None');
		thePlayer.ProcessRequiredItems(true);
		parent.OnForcedHolsterWeapon();
	}
	
	latent function TimeFlow()
	{
		var storedHoursPerMinute : float = theGame.GetHoursPerMinute();
		var fastForward : CGameFastForwardSystem;
		
		fastForward = theGame.GetFastForwardSystem();
		fastForward.BeginFastForward();
		
		theGame.SetHoursPerMinute(10*duration);
		Sleep( duration );
		
		fastForward.AllowFastForwardSelfCompletion();
		
		theGame.SetHoursPerMinute(storedHoursPerMinute);
	}
	
	function ChangeInteractionPriority()
	{
		if ( parent.GetInteractionPriority() != IP_Max_Unpushable )
		{
			m_storedInteractionPri = parent.GetInteractionPriority();
			parent.SetInteractionPriority( IP_Max_Unpushable );
		}
	}
	
	function ResetInteractionPriority()
	{
		if ( m_storedInteractionPri != IP_NotSet )
		{
			parent.SetInteractionPriority( m_storedInteractionPri );
		}
		m_storedInteractionPri = IP_NotSet;
	}
	
	function TakeMoneyFromPlayer()
	{
		var amount : float = thePlayer.GetMoney();
		var finalAmount  : float;
		
		switch ( theGame.GetDifficultyLevel() )
		{
			case EDM_Easy:		finalAmount = MinF( amount * 0.25, 750);	break;	
			case EDM_Medium:	finalAmount = MinF( amount * 0.40, 1250);	break;	
			case EDM_Hard:		finalAmount = MinF( amount * 0.65, 1750);	break;	
			case EDM_Hardcore:	finalAmount = MinF( amount * 0.85, 2250);	break;	
			default : 			finalAmount *= 0; 							break;
		}
		
		thePlayer.RemoveMoney((int)finalAmount);
	}

	function RemoveArmor()
	{
		var inv : CInventoryComponent;
		var ids 		: array<SItemUniqueId>;
		var id			: SItemUniqueId;
		var i			: int;
		
		inv = thePlayer.GetInventory();
		
		if ( inv.GetItemEquippedOnSlot( EES_SilverSword, id ) )
			ids.PushBack(id);
		if ( inv.GetItemEquippedOnSlot( EES_SteelSword, id ) )
			ids.PushBack(id);
		if ( inv.GetItemEquippedOnSlot( EES_Armor, id ) )
			ids.PushBack(id);
		if ( inv.GetItemEquippedOnSlot( EES_Boots, id ) )
			ids.PushBack(id);
		if ( inv.GetItemEquippedOnSlot( EES_Pants, id ) )
			ids.PushBack(id);
		if ( inv.GetItemEquippedOnSlot( EES_Gloves, id ) )
			ids.PushBack(id);
		if ( inv.GetItemEquippedOnSlot( EES_RangedWeapon, id ) )
			ids.PushBack(id);
		
		for ( i=0 ; i < ids.Size() ; i+=1 )
			GetWitcherPlayer().UnequipItem(ids[i]);
	}
	
	function TeleportPlayerToNewPosition()
	{
		var nodes : array<CNode>;
		var currentPos : Vector;
		var minDist : float;
		var dist : float;
		var selectedNode : int;
		var i : int;
		
		
		theGame.GetNodesByTag('player_guard_respawn',nodes);
		
		if ( nodes.Size() > 0 )
		{
			currentPos = thePlayer.GetWorldPosition();
			for ( i=0 ; i < nodes.Size() ; i+=1 )
			{
				dist = VecDistanceSquared( currentPos, nodes[i].GetWorldPosition() );
				if ( i == 0 || minDist > dist )
				{
					minDist = dist;
					selectedNode = i;
				}
			}
			
			if ( selectedNode != -1 )
				thePlayer.TeleportToNode(nodes[selectedNode],true);
		}
	}
	
	function TeleportAwayFromElevator()
	{
		var node : CNode;
		var selectedNode : int;
		
		theGame.GetNodeByTag( 'player_elevator_respawn' );
		if ( node )
			thePlayer.TeleportToNode( node, true );
	}
	
	private var cachedID : SItemUniqueId;
	private var itemEnt1 : CEntity;
	private var itemEnt2 : CEntity;
	
	function CacheSwordInHand()
	{
		var inv : CInventoryComponent;
		var idLWeapon	: SItemUniqueId;
		
		inv = thePlayer.GetInventory();
		
		cachedID = inv.GetItemFromSlot('r_weapon');
		itemEnt1 = parent.inv.GetItemEntityUnsafe( cachedID );
		
		idLWeapon = inv.GetItemFromSlot('l_weapon');
		if ( parent.inv.IsIdValid( idLWeapon ) && !parent.inv.IsItemCrossbow( idLWeapon ) )
			itemEnt2 = parent.inv.GetItemEntityUnsafe( idLWeapon );
	}
	
	function RestoreSword()
	{
		var inv : CInventoryComponent;
		var category : name;
		var id : SItemUniqueId;
		
		inv = thePlayer.GetInventory();
		
		itemEnt1.Destroy();
		itemEnt2.Destroy();
		
		if ( inv.IsIdValid(cachedID) && GetWitcherPlayer() )
		{
			category = inv.GetItemCategory(cachedID);
			
			if ( category == 'steelsword' )
			{
				if ( !inv.GetItemEquippedOnSlot( EES_SteelSword, id ) )
				{
					GetWitcherPlayer().EquipItemInGivenSlot(cachedID,EES_SteelSword,false,false);
				}
				else
				{
					GetWitcherPlayer().UnequipItem(cachedID);
					GetWitcherPlayer().EquipItemInGivenSlot(cachedID,EES_SteelSword,false,false);
				}
			}
			else if ( category == 'silversword' )
			{
				if ( !inv.GetItemEquippedOnSlot( EES_SilverSword, id ) )
				{
					GetWitcherPlayer().EquipItemInGivenSlot(cachedID,EES_SilverSword,false,false);
				}
				else
				{
					GetWitcherPlayer().UnequipItem(cachedID);
					GetWitcherPlayer().EquipItemInGivenSlot(cachedID,EES_SilverSword,false,false);
				}
			}
		}
	}
	
	function DisplayMessage()
	{
		GetWitcherPlayer().DisplayHudMessage( GetLocStringByKeyExt("panel_hud_message_guards_took_money") );
	}
	
	function SetIsUnconscious( flag : bool )
	{
		isUnconscious = flag;
		if ( isUnconscious )
			theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'PlayerUnconsciousAction', -1.f, 60.0f, -1, -1, true ); 
	}
	
	event OnCheckUnconscious()
	{
		return isUnconscious;
	}
	
	event OnKilledByGuard()
	{
		killedByGuard = true;
	}
	
	event OnKilledByElevator()
	{
		killedByElevator = true;
	}
}
