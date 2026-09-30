/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state PlayerDialogScene in CPlayer extends Base
{
	private var cachedPrevStateName : name;
	
	event OnEnterState( prevStateName : name )
	{
		
		var player : W3PlayerWitcher;
		var sign : W3SignEntity;
		var horse : CNewNPC;
		var scabbardsComp : CAnimatedComponent;
		
		player = (W3PlayerWitcher)parent;
		
		theInput.SetContext( 'Scene' );
		
		parent.EnableHardLock( false );
		
		thePlayer.OnPlayerActionEnd();
		
		if(player)
		{
			sign = (W3SignEntity)player.GetCurrentSignEntity();
			if (sign)
			{
				sign.OnSignAborted();
			}
			
			player.BombThrowAbort();			
		}
		scabbardsComp = (CAnimatedComponent)( thePlayer.GetComponent( "scabbards_skeleton" ) );
		if ( scabbardsComp )
			scabbardsComp.SetBehaviorVariable( 'inScene', 1.f );

		
		
		player.GetMovingAgentComponent().ResetMoveRequests();
		
		theTelemetry.LogWithName(TE_STATE_DIALOG);
		
		parent.SetBehaviorMimicVariable( 'gameplayMimicsMode', (float)(int)PGMM_None );
		
		cachedPrevStateName = prevStateName;
	}
	
	event OnLeaveState( nextStateName : name )
	{
		var scabbardsComp : CAnimatedComponent;
		scabbardsComp = (CAnimatedComponent)( thePlayer.GetComponent( "scabbards_skeleton" ) );
		if ( scabbardsComp )
			scabbardsComp.SetBehaviorVariable( 'inScene', 0.f );
		
		parent.rawPlayerHeading = parent.GetHeading();
		
		parent.SetBehaviorMimicVariable( 'gameplayMimicsMode', (float)(int)PGMM_Default );
	}
	
	
	event OnBlockingSceneEnded( optional output : CStorySceneOutput)
	{
		var ciri : W3ReplacerCiri;
			
		parent.OnBlockingSceneEnded( output );
		parent.RegisterCollisionEventsListener();
		if ( output )
		{
			if ( output.action == SSOA_ReturnToPreviousState )
			{
				if ( cachedPrevStateName == 'CombatSteel' || cachedPrevStateName == 'CombatSilver' )
					parent.PopState( false );
			}
			else if ( output.action == SSOA_MountVehicle )
			{
				parent.FindAndMountVehicle( VMT_ApproachAndMount, 100.0f );	
				return true;
			}
			else if ( output.action == SSOA_MountVehicleFast )
			{
				parent.FindAndMountVehicle( VMT_ImmediateUse, 100.0f );	
				return true;
			}
			else if ( output.action == SSOA_EnterCombatSilver )
			{
				ciri = (W3ReplacerCiri)thePlayer;
				if ( ciri )
				{
					parent.GotoState( 'CombatSteel', false );
					return true;
				}
				else if ( GetWitcherPlayer().IsItemEquippedByCategoryName( 'silversword' ) )
				{
					parent.GotoState( 'CombatSilver', false );
					return true;
				}
				
			} 
			else if ( output.action == SSOA_EnterCombatSteel )
			{
				if ( GetWitcherPlayer().IsItemEquippedByCategoryName( 'steelsword' ) )
				{
					parent.GotoState( 'CombatSteel', false );
					return true;
				}
			}
			else if ( output.action == SSOA_EnterCombatFists )
			{
				parent.GotoState( 'CombatFists', false );
				return true;
			}
			
		}
		parent.PopState( true );
	}
}
