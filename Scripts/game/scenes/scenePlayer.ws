/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EStorySceneOutputAction
{
	SSOA_None,
	SSOA_ReturnToPreviousState,
	SSOA_MountVehicle,
	SSOA_MountVehicleFast,
	SSOA_EnterCombatSteel,
	SSOA_EnterCombatSilver,
	SSOA_EnterCombatFists
}

import class CStorySceneOutput extends CStorySceneControlPart
{
	editable var action : EStorySceneOutputAction;
}

import statemachine class CStoryScenePlayer extends CEntity
{
	private var m_isFinalboard : bool;

	default m_isFinalboard = false;
	default autoState = 'Gameplay';
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		GotoStateAuto();
	}
	
	function SetFinalboardQuest( isFinalboard: bool )
	{
		m_isFinalboard = isFinalboard;
	}
	
	function ShouldRestoreItemsForPlayer( output : CStorySceneOutput ) : bool
	{
		return output.action == SSOA_None || output.action == SSOA_ReturnToPreviousState;
	}
	
	event OnBlockingSceneStarted( scene: CStoryScene )
	{
		var box : Box;
		var ents : array<CGameplayEntity>;
		var i : int;
		var actor : CActor;
		var hud : CR4ScriptedHud;

		if ( !theGame.IsActive() )
		{
			return true;
		}
		
		theGame.SetIsDialogOrCutscenePlaying(true);
		
		
		box.Min = Vector(-30,-30,-30);
		box.Max = Vector(30, 30, 30);
		
		FindGameplayEntitiesInBox(ents, GetSceneWorldPos(), box, 100000, '', FLAG_ExcludePlayer + FLAG_OnlyActors);
		for(i=0; i<ents.Size(); i+=1)
		{
			actor = (CActor)ents[i];
			if(actor && actor.IsInAgony())
				actor.SignalGameplayEvent('ForceEndAgony');
				
			ents[i].StopCutsceneForbiddenFXs();
		}
		
		
		thePlayer.RemoveAllBuffsOfType(EET_Blizzard);
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			hud.OnCutsceneStarted();
		}
	}
	
	import final function DbFactAdded( factName : string );
	
	import final function DbFactRemoved( factName : string );
	
	
	event OnBlockingSceneEnded( output : CStorySceneOutput )
	{
		var hud : CR4ScriptedHud;

		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			hud.OnCutsceneEnded();
		}
		
		if ( !theGame.IsActive() )
		{
			return true;
		}

		theGame.SetIsDialogOrCutscenePlaying(false);
	}
	
	event OnCameraBlendToGameplay()
	{
		var hud : CR4ScriptedHud;

		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			hud.OnCutsceneEnded();
		}
	}
	
	event OnCustceneStarted()
	{
		theGame.SetIsCutscenePlaying(true);
	}	
	
	event OnCutsceneEnded()
	{	
		theGame.SetIsCutscenePlaying(false);
	}
	
	event OnMovieStarted()
	{
		FactsSet("nge_pause_menu_disabled",1,-1); 
		
		if( m_isFinalboard )
		{
			theSound.EnterGameState( ESGS_MusicOnly );
		}
		else
		{
			theSound.EnterGameState( ESGS_Movie );
		}
	}
	
	event OnMovieEnded()
	{
		FactsRemove("nge_pause_menu_disabled"); 
		if ( theSound.GetCurrentGameState() != ESGS_MusicOnly )
		{
			if( theGame.envMgr.IsNight() )
			{
				theSound.EnterGameState( ESGS_DialogNight );
			}
			else
			{
				theSound.EnterGameState( ESGS_Dialog );
			}
		}
	}
	
	import function RestartScene();
	import function RestartSection();
	
	import function GetSceneWorldPos() : Vector;
}

state Gameplay in CStoryScenePlayer
{
	event OnBlockingSceneStarted( scene: CStoryScene )
	{
		parent.OnBlockingSceneStarted(scene);
		parent.PushState( 'Blocking' );
	}
	
	event OnEnterState( prevStateName : name )
	{
		if ( prevStateName == 'Blocking' )
		{
			
			theSound.LeaveGameState( theSound.GetCurrentGameState() );
		}
		else if ( prevStateName == 'Cutscene' )
		{
			theSound.LeaveGameState( ESGS_Cutscene );
		}
		else if ( prevStateName == 'Movie' )
		{
			theSound.LeaveGameState( ESGS_Movie );
		}
	}
}

state Blocking in CStoryScenePlayer
{
	event OnCutsceneStarted()
	{
		parent.PushState( 'Cutscene' );
	}
	
	event OnBlockingSceneEnded( output : CStorySceneOutput )
	{
		parent.OnBlockingSceneEnded(output);
		parent.PopState( false );
	}

	event OnEnterState( prevStateName : name )
	{
		if( theGame.envMgr.IsNight() )
		{
			theSound.EnterGameState( ESGS_DialogNight );
		}
		else
		{
			theSound.EnterGameState( ESGS_Dialog );
		}
		
		if( theGame.GetGameplayConfigBoolValue('enableSceneRewind') )
		{
			theInput.RegisterListener( this, 'OnDbgRestartSection', 'SCN_DBG_RestartSection' );
			theInput.RegisterListener( this, 'OnDbgRestartScene', 'SCN_DBG_RestartScene' );		
		}
	}
	
	event OnDbgRestartSection( action : SInputAction )
	{
		if( IsReleased(action) && theInput.GetLastActivationTime( action.aName ) < 0.3 )
		{
			parent.RestartSection();
		}		
	}
	
	event OnDbgRestartScene( action : SInputAction )
	{
		if( IsPressed(action) )
		{
			parent.RestartScene();
		}			
	}
}

state Cutscene in CStoryScenePlayer
{
	event OnEnterState( prevStateName : name )
	{
		theSound.EnterGameState( ESGS_Cutscene );
	}

	event OnCutsceneEnded()
	{
		parent.PopState( false );
	}
}


state Movie in CStoryScenePlayer
{
	event OnEnterSate( prevStateName : name )
	{
		theSound.EnterGameState( ESGS_Movie );
	}
	
	event OnMovieEnded()
	{
		parent.PopState( false );
	}
}




import class CStoryScene extends CResource
{
	import final function GetRequiredPositionTags() : array< name >;
}

import class CStorySceneSystem extends IGameSystem
{
	import final function IsSkippingLineAllowed() : Bool;
	import final function PlayScene( scene : CStoryScene, input : string );
	import final function SendSignal( signal : EStorySceneSignalType, value : Int32 );
}

import class CStorySceneSpawner extends CGameplayEntity
{
	import private var storyScene : CStoryScene;
	import private var inputName : string;
	editable var useSpawnerLocation : bool;
	
	default useSpawnerLocation = true;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var tags : array< name >;
		if ( useSpawnerLocation == true )
		{
			tags = GetTags();
			ArrayOfNamesAppend( tags, storyScene.GetRequiredPositionTags() );
			SetTags( tags );
		}
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{		
		if ( actionName == "Talk" )
		{
			theGame.GetStorySceneSystem().PlayScene( storyScene, inputName );
		}
	}
}



enum EStorySceneGameplayAction
{
	SSGA_None,
	SSGA_Walk_2m,
	SSGA_Walk_5m,
	SSGA_Walk_8m,
	SSGA_Walk_2m_GoTo_Combat,
	SSGA_Walk_5m_GoTo_Combat,
	SSGA_Walk_8m_GoTo_Combat,
	SSGA_Walk_2m_GoTo_Combat_Silver,
	SSGA_Walk_5m_GoTo_Combat_Silver,
	SSGA_Walk_8m_GoTo_Combat_Silver,
	SSGA_GoTo_Combat_Pose,
	SSGA_GoTo_Combat_Pose_Silver,
	SSGA_GoTo_Combat_Pose_Fists,
	SSGA_EndInWork,
	SSGA_DelayWork,
}

import struct SStorySceneGameplayActionCallbackInfo
{
	import var outChangeItems : bool;
	import var outDontUseSceneTeleport : bool;

	import var inActorPosition : Vector;
	import var inActorHeading : Vector;
	import var inGameplayAction : int; 
	import var inActor : CActor;
}

function DoStorySceneGameplayAction( out callbackInfo : SStorySceneGameplayActionCallbackInfo )
{
	var l_aiTreeDecorator	: CAIPlayerActionDecorator;
	var l_aiTree			: CAIMoveToPoint;
	var distance			: float;
	var walkAction			: bool;
	var combatActionSteel	: bool;
	var combatActionSilver	: bool;
	var combatActionFists	: bool;
	var action				: int;
	var correctedZ			: float;
	var npc					: CNewNPC;
	var currentGraphName	: name;
	
	action = callbackInfo.inGameplayAction;
	
	
	callbackInfo.outChangeItems = action == SSGA_Walk_2m_GoTo_Combat || action == SSGA_Walk_5m_GoTo_Combat || action == SSGA_Walk_8m_GoTo_Combat
		|| action == SSGA_Walk_2m_GoTo_Combat_Silver || action == SSGA_Walk_5m_GoTo_Combat_Silver || action == SSGA_Walk_8m_GoTo_Combat_Silver;
	
	
	combatActionSteel = action == SSGA_Walk_2m_GoTo_Combat || action == SSGA_Walk_5m_GoTo_Combat || action == SSGA_Walk_8m_GoTo_Combat || action == SSGA_GoTo_Combat_Pose;
	combatActionSteel = combatActionSteel && callbackInfo.inActor == thePlayer;
	combatActionSilver = action == SSGA_Walk_2m_GoTo_Combat_Silver || action == SSGA_Walk_5m_GoTo_Combat_Silver || action == SSGA_Walk_8m_GoTo_Combat_Silver || action == SSGA_GoTo_Combat_Pose_Silver;
	combatActionSilver = combatActionSilver && callbackInfo.inActor == thePlayer;
	combatActionFists = action == SSGA_GoTo_Combat_Pose_Fists;
	combatActionFists = combatActionFists && callbackInfo.inActor == thePlayer;
	if ( combatActionSteel )
	{
		if ( thePlayer.IsCiri() )
			thePlayer.GotoState( 'CombatSteel', false );
		else if ( GetWitcherPlayer().IsItemEquippedByCategoryName( 'steelsword' ) )
			thePlayer.GotoState( 'CombatSteel', false );
	}
	else if ( combatActionSilver )
	{
		if ( thePlayer.IsCiri() )
			thePlayer.GotoState( 'CombatSteel', false );
		else if ( GetWitcherPlayer().IsItemEquippedByCategoryName( 'silversword' ) ) 
			thePlayer.GotoState( 'CombatSilver', false );
	}
	else if ( combatActionFists )
	{
		if ( thePlayer.IsCiri() )
			thePlayer.GotoState( 'CombatSteel', false );
		else
			thePlayer.GotoState( 'CombatFists', false );
	}
	
	
	walkAction = action == SSGA_Walk_2m || action == SSGA_Walk_5m || action == SSGA_Walk_8m
			  || action == SSGA_Walk_2m_GoTo_Combat || action == SSGA_Walk_5m_GoTo_Combat || action == SSGA_Walk_8m_GoTo_Combat
			  || action == SSGA_Walk_2m_GoTo_Combat_Silver || action == SSGA_Walk_5m_GoTo_Combat_Silver || action == SSGA_Walk_8m_GoTo_Combat_Silver;
	if ( walkAction )
	{
		if ( action == SSGA_Walk_2m || action == SSGA_Walk_2m_GoTo_Combat || action == SSGA_Walk_2m_GoTo_Combat_Silver )
		{
			distance = 2.f;
		}
		else if ( action == SSGA_Walk_5m || action == SSGA_Walk_5m_GoTo_Combat || action == SSGA_Walk_5m_GoTo_Combat_Silver )
		{
			distance = 5.f;
		}
		else 
		{
			distance = 8.f;
		}
		
		l_aiTree = new CAIMoveToPoint in callbackInfo.inActor;
		l_aiTree.OnCreated();
		
		l_aiTree.enterExplorationOnStart 		= false;
		l_aiTree.params.destinationHeading 		= VecHeading( callbackInfo.inActorHeading );
		l_aiTree.params.destinationPosition 	= callbackInfo.inActorPosition + distance * callbackInfo.inActorHeading;
		
		if ( theGame.GetWorld().NavigationComputeZ( l_aiTree.params.destinationPosition, l_aiTree.params.destinationPosition.Z - 5, l_aiTree.params.destinationPosition.Z + 5, correctedZ ) )
			l_aiTree.params.destinationPosition.Z = correctedZ;
		
		if ( callbackInfo.inActor == thePlayer )
		{
			thePlayer.GetMovingAgentComponent().SetGameplayMoveDirection(l_aiTree.params.destinationHeading );
			
			l_aiTree.params.maxIterationsNumber = 1;
			l_aiTree.params.moveType = MT_Walk;
			
			thePlayer.GetVisualDebug().AddSphere( 'MoveToPoint', 1, l_aiTree.params.destinationPosition, true, Color(0,0,255) );
			
			l_aiTreeDecorator = new CAIPlayerActionDecorator in callbackInfo.inActor;
			l_aiTreeDecorator.OnCreated();
			l_aiTreeDecorator.interruptOnInput = true;
			l_aiTreeDecorator.scriptedAction = l_aiTree;
			
			if ( l_aiTreeDecorator )
			{
				callbackInfo.inActor.ForceAIBehavior( l_aiTreeDecorator, BTAP_Emergency );
			}
			else
			{
				callbackInfo.inActor.ForceAIBehavior( l_aiTree, BTAP_Emergency );
			}
		}
		else
		{
			l_aiTree.params.moveType = MT_Walk;
			l_aiTree.params.maxIterationsNumber 	= 2;
			l_aiTree.params.useTimeout				= true;
			l_aiTree.params.timeoutValue 			= 3.f;
			
			callbackInfo.inActor.ForceAIBehavior( l_aiTree, BTAP_Emergency );
		}
	}
	else if ( callbackInfo.inActor == thePlayer && ( action == SSGA_GoTo_Combat_Pose || action == SSGA_GoTo_Combat_Pose_Silver || action == SSGA_GoTo_Combat_Pose_Fists ) )
	{
		thePlayer.SetCombatIdleStance( 1.f );
		thePlayer.SetPlayerCombatStance( PCS_AlertNear, true );
	}
	else if ( action == SSGA_EndInWork )
	{
		
		callbackInfo.inActor.SignalGameplayEvent( 'AI_ForceLastWork' );
		callbackInfo.inActor.ForceAIUpdate();
		
		callbackInfo.outDontUseSceneTeleport = true; 
	}
	else if ( action == SSGA_DelayWork )
	{
		callbackInfo.inActor.SignalGameplayEventParamFloat( 'AI_DelayWork', 2.5 + ( RandF() * 5.0 ) );
	}
	else
	{
		npc = (CNewNPC)callbackInfo.inActor;
		if ( npc && npc.IsHuman() )
		{
			currentGraphName = npc.GetBehaviorGraphInstanceName();
			if (action == SSGA_GoTo_Combat_Pose || ( currentGraphName != 'Exploration' && currentGraphName != 'StoryScene' ) )
				npc.SignalGameplayEvent('WaitAfterScene');
		}
	}
}


