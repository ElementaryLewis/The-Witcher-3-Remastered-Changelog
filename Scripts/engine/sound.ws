/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ESoundGameState
{
	ESGS_Default,
	ESGS_Exploration,
	ESGS_ExplorationNight,
	ESGS_Focus,
	ESGS_FocusNight,
	ESGS_FocusUnderwater,
	ESGS_Combat,
	ESGS_CombatMonsterHunt,
	ESGS_Dialog,
	ESGS_DialogNight,
	ESGS_Cutscene,
	ESGS_Minigame,
	ESGS_Death,
	ESGS_Movie,
	ESGS_Boat,
	ESGS_MusicOnly,
	ESGS_Underwater,
	ESGS_UnderwaterCombat,
	ESGS_Paused,
	ESGS_Gwent,
	ESGS_FocusUnderwaterCombat,
}

enum ESoundEventSaveBehavior
{
	SESB_Save,
	SESB_DontSave,
	SESB_ClearSaved
}

import function GetMeshSoundTypeIdentification( component : CComponent ) : name;
import function GetMeshSoundSizeIdentification( component : CComponent ) : name;

import class CScriptSoundSystem extends CObject
{
	private var currentGameState : ESoundGameState;
	private var defaultGameState : ESoundGameState;
	private var defaultStates : array< ESoundGameState >;
	public var stateChangeTimestamp : float;
	public var stateCheckCooldown : float;
	private var isGameStopped : bool;
	private var currentThreatRating : float;
	private var desiredThreatRating : float;
	private var lastThreatUpdateTime : float;
	private var lastThreatDampTime : float;
	private var threatUpdateCooldown : float;
	private var threatDampCooldown : float;
	private var threatDamper : SpringDamper;   
	private var monsterHunt : bool;
	private var monster : bool;
	private var isBlackscreen : bool;
	private var soundSystemSettings : C2dArray; 
	var threatWeight	: int;
	var levelWeight 	: int;
	var tweakWeight		: float;
	
	default threatWeight 	= 10;
	default levelWeight 	= 60;
	default tweakWeight		= 0.02;
	default stateCheckCooldown = 0.15;
	default currentThreatRating = 0.0;
	default desiredThreatRating = 0.0;
	default lastThreatUpdateTime = 0.0;
	default lastThreatDampTime = 0.0;
	default threatUpdateCooldown = 2.0;
	default threatDampCooldown = 0.1;
	default monsterHunt = false;
	default monster = false;
	default isBlackscreen = false;
	
	import private function SoundState( stateGroupName : string, optional stateName : string  );
	import function SoundSwitch( swichGroupName : string, optional stateName : string  );
	import function SoundEvent( eventName : string );
	import function SoundParameter( parameterName : string, value : float, optional duration : float );
	import function SoundGlobalParameter( parameterName : string, value : float, optional duration : float );
	import function SoundSequence( sequenceName : string, sequence : array< string > );
	import function SoundEventAddToSave( eventName : string );
	import function SoundEventClearSaved( );
	import function SoundMusicEvent( eventName : string );
	import function SoundEnableMusicEvents( how : bool );
	import function SoundLoadBank( bankName : string, async : bool );
	import function SoundUnloadBank( bankName : string );
	import function SoundIsBankLoaded( bankName : string ) : bool;
	import function EnableMusicDebug( enable : bool);
	import function TimedSoundEvent(duration : float, optional startEvent : string, optional stopEvent : string, optional shouldUpdateTimeParameter : bool);
	import function MuteSpeechUnderwater(mute : bool);
	
	event OnBlackscreenStart()
	{
		if( !isBlackscreen )
		{
			isBlackscreen = true;
			if( !IsValidBlackscreenState( currentGameState ) )
			{
				SoundState( "game_state",  GameStateToString( ESGS_MusicOnly ) );
			}
		}
	}
	
	event OnBlackscreenEnd()
	{
		if( isBlackscreen )
		{
			isBlackscreen = false;
			SoundState( "game_state",  GameStateToString( currentGameState ) );
		}
	}
	
	private function IsValidBlackscreenState( gameState : ESoundGameState ) : bool
	{
		return  gameState == ESGS_MusicOnly || gameState == ESGS_Movie;
	}
	
	public function Initialize()
	{
		threatDamper = new SpringDamper in this;
		threatDamper.Init( 0.f, 0.f );
		threatDamper.SetSmoothTime( 3.5f );
		
		FillDefaultStatesArray();
		UpdateSoundSettings();
		defaultGameState = ESGS_Exploration;
		EnterDefaultState(); 
	}
	
	public function IsInDefaultState() : bool
	{
		if( defaultStates.Contains( currentGameState ) )
		{
			return true;
		}
		return false;
	}
	
	private function IsThisStateDefault( gameState : ESoundGameState ) : bool
	{
		if( defaultStates.Contains( gameState ) )
		{
			return true;
		}
		return false;
	}
	
	private function EnterDefaultState()
	{
		SoundGameStateChange( defaultGameState );
	}
	
	private function SoundGameStateChange( gameState : ESoundGameState )
	{
		var isCombatMusicEnabled : bool;
	
		if(thePlayer)
			isCombatMusicEnabled = thePlayer.IsCombatMusicEnabled();
		else
			isCombatMusicEnabled = false;
		
		currentGameState = gameState;
		stateChangeTimestamp = theGame.GetEngineTimeAsSeconds();

		if ( isCombatMusicEnabled )
		{
			if ( !thePlayer.IsSoundStateCombatMusic( gameState ) )
			{
				LogChannel( 'OnCombatFinished', "SoundGameStateChange: Combat music stopped" ); 
				thePlayer.OnCombatFinished();
			}
		}	
		else if ( thePlayer.IsSoundStateCombatMusic( gameState ) )
		{
			LogChannel( 'OnCombatFinished', "SoundGameStateChange: Combat music started" ); 
			thePlayer.OnCombatStart();
		}	
		
		
		
		if( !isBlackscreen ||
			( isBlackscreen && IsValidBlackscreenState( gameState ) ) )
		{
			SoundState( "game_state",  GameStateToString( gameState ) );
			LogChannel( 'Sound', "new game_state = " + GameStateToString( gameState ) );
		}
	}

	function ChangeSoundState( stateGroupName : string, optional stateName : string  ) : bool
	{
		if( stateGroupName == "game_state" )
		{
			LogChannel( 'Sound', "ERROR!!! You can't change game_state using ChangeSoundState function!!!" );
			return false;
		}
		
		SoundState( stateGroupName, stateName );
		
		return true;
	}
	
	function EnterGameState( gameState : ESoundGameState ) : bool
	{
		if( currentGameState != gameState )
		{
			if( IsThisStateDefault( gameState ) )
			{
				LogChannel('Sound', "ERROR!!! State: " + gameState + " is default gameState!!!");
				return false;
			}
			
			SoundGameStateChange( gameState );
			
			return true;
		}
		return false;
	}
	
	function LeaveGameState( gameState : ESoundGameState ) : bool
	{
		if( currentGameState != gameState )
		{
			LogChannel('Sound', "ERROR!!! You cannot leave " + gameState + " when you're not in it!!!");
			return false;
		}
		
		EnterDefaultState();
		
		return true;
	}
	
	function GetCurrentGameState() : ESoundGameState
	{
		return currentGameState;
	}
	
	function SetDefaultGameState( gameState : ESoundGameState )
	{
		if( IsThisStateDefault( gameState ) )
		{
			if( gameState != defaultGameState )
			{
				defaultGameState = gameState;
				if( defaultGameState != ESGS_CombatMonsterHunt )
				{
					monsterHunt = false;
					monster = false;
				}
				if( currentGameState != defaultGameState )
				{
					EnterDefaultState();
				}
			}
		}
		else
		{
			LogChannel('Sound', "ERROR!!! State: " + gameState + " is not a default gameState!!!");
		}
	}
	
	function GetDefaultGameState() : ESoundGameState
	{
		return defaultGameState;
	}
	
	function GetMonster() : bool
	{
		return monster;
	}
	
	function GetMonsterHunt() : bool
	{
		return monsterHunt;
	}
	
	function InitializeAreaMusic( worldArea : CName )
	{
		SoundMusicEvent( "stop_music" );
		
		switch( worldArea )
		{
			case 'AN_NMLandNovigrad':
				SoundMusicEvent( "play_music_nomansgrad" );
				break;
				
			case 'AN_Skellige_ArdSkellig':
				SoundMusicEvent( "play_music_skellige" );
				break;
			
			case 'AN_Kaer_Morhen':
				SoundMusicEvent( "play_music_kaer_morhen" );
				break;
			
			case 'AN_Prologue_Village':
			case 'AN_Prologue_Village_Winter':
				SoundMusicEvent( "play_music_prologue" );
				break;
				
			case 'AN_Wyzima':
				SoundMusicEvent( "play_music_wyzima_castle" );
				break;
			
			case 'AN_Island_of_Myst':
				SoundMusicEvent( "play_music_misty_island" );
				break;
				
			case 'AN_Spiral':
				SoundMusicEvent( "play_music_spiral" );
				break;
			
			case 'AN_Dlc_Bob':
				SoundMusicEvent( "play_music_toussaint" );
				break;
			case 'AN_Bob':
				SoundMusicEvent( "play_music_toussaint" );
				break;

			default:
				LogAssert( false, "theSound.InitializeAreaMusic: unsupported area type <<" + worldArea + ">> passed! Music not set!" );
				break;
		}
	}
	
	private function GameStateToString( enumName : ESoundGameState ) : string
	{
		switch ( enumName )
		{
			case ESGS_Default:
				return "";
			case ESGS_Exploration:
				return "exploration";
			case ESGS_ExplorationNight:
				return "exploration_night";
			case ESGS_Focus:
				return "focus_exploration";
			case ESGS_FocusNight:
				return "focus_exploration_night";
			case ESGS_Combat:
				return "combat";
			case ESGS_CombatMonsterHunt:
				return "combat_monster_hunt";
			case ESGS_Dialog:
				return "dialog_scene";
			case ESGS_DialogNight:
				return "dialog_scene_night";
			case ESGS_Cutscene:
				return "cutscene";
			case ESGS_Minigame:
				return "minigames";
			case ESGS_Death:
				return "death";
			case ESGS_Movie:
				return "movie";
			case ESGS_Boat:
				return "boat";
			case ESGS_MusicOnly:
				return "music_only";
			case ESGS_Underwater:
				return "underwater";
			case ESGS_UnderwaterCombat:
				return "underwater_combat";
			case ESGS_FocusUnderwater:
				return "underwater_focus";
			case ESGS_FocusUnderwaterCombat:
				return "underwater_combat_focus";
			case ESGS_Paused:
				return "pause";
			case ESGS_Gwent:
				return "gwent";
			default:
				return "";
		}
	}
	
	function Finalize()
	{
		SoundGameStateChange( ESGS_Default );
		SoundEvent( "fx_underwater_off" );
		SoundEvent( "stop_music" );
	}
	
	private function FillDefaultStatesArray()
	{
		defaultStates.PushBack( ESGS_Exploration );
		defaultStates.PushBack( ESGS_ExplorationNight );
		defaultStates.PushBack( ESGS_Underwater );
		defaultStates.PushBack( ESGS_Combat );
		defaultStates.PushBack( ESGS_CombatMonsterHunt );
		defaultStates.PushBack( ESGS_UnderwaterCombat );
		defaultStates.PushBack( ESGS_Paused );	
	}
	
	public function SetIsGameStopped( val : bool )		{ isGameStopped = val; }
	public function GetIsGameStopped() : bool			{ return isGameStopped; }
	
	public function StopMusic( )
	{
		SoundEvent( "stop_music" );
	}
	



	
	function SendThreatRating()
	{	
		if( lastThreatUpdateTime + threatUpdateCooldown < theGame.GetEngineTimeAsSeconds() )
		{
			CalculateThreat();
		}
		
		if( ( currentThreatRating < 0.99 * desiredThreatRating || currentThreatRating > 1.01 * desiredThreatRating ) && ( lastThreatDampTime + threatDampCooldown < theGame.GetEngineTimeAsSeconds() ) )
		{
			UpdateThreatDamp();
		}
	}
	
	function CalculateThreat()
	{
		var actors : array< CActor >;
		var actorsSize : int;
		var i,v : int;
		var totalWeight : float;
		var tempThreat : float;
		var tempSum : float;
		var tempSumElements : float;
		var tempMaxElement : float;
		var l_tempthreat :float;
		var l_levelget : float;
		var finalSoundValue : int ;
		
		var monsterCategory : EMonsterCategory;
		var soundName : name;
		var isTeleporting : bool;
		var canBeTargeted : bool;
		var canBeHitByFists : bool;
		
		
		monsterHunt = false;
		monster = false;
		totalWeight = 0.0;
		
		actors = thePlayer.GetNPCsAndPlayersInRange( 70, 10, '', FLAG_Attitude_Hostile+FLAG_OnlyAliveActors );
		actorsSize = actors.Size();
		
		for( i = 0; i < actorsSize; i += 1 )
		{
			theGame.GetMonsterParamsForActor( actors[i], monsterCategory, soundName, isTeleporting, canBeTargeted, canBeHitByFists );
			tempThreat = ((CNewNPC)actors[i]).GetThreatLevel();
			
			if( ((CNewNPC)actors[i]).useSoundValue == true )
			{
				finalSoundValue += ((CNewNPC)actors[i]).GetSoundValue();
				LogSound( "finalSoundValue is  "+ finalSoundValue); 
			}
			
			if( tempThreat > 2 ) 
			{
				totalWeight += tempThreat;
			}
			else 
			{
				tempSum += tempThreat;
				tempSumElements += 1;
				
				if( tempThreat > tempMaxElement ) 
					tempMaxElement = tempThreat;
			}
			
			if( MonsterCategoryIsMonster( monsterCategory ) )
				monster = true;
				
			
			
		}
		
		if( tempSum ) 
		{
			totalWeight += tempMaxElement; 
			if( tempSumElements > 1 )
				totalWeight += ( tempSum / tempSumElements ) * 0.5 + 0.3 * tempSumElements; 
		}
		if( FactsQuerySum("NewGamePlus") > 0 )
		{
			levelWeight += theGame.params.GetNewGamePlusLevel();
		}
		tempThreat = totalWeight *threatWeight; 
		l_levelget = thePlayer.GetLevel();
		l_levelget = l_levelget/levelWeight; 
		l_levelget = 1-l_levelget; 
		tempThreat = tempThreat*l_levelget;
		tempThreat = tempThreat*tweakWeight; 
		
		l_tempthreat = tempThreat;
		desiredThreatRating = ClampF( tempThreat * 100, 0.0, 100.0 ); 
		desiredThreatRating += finalSoundValue;
		
		lastThreatUpdateTime = theGame.GetEngineTimeAsSeconds();
		LogSound( "Threat rating recalculated - current desired value = " + desiredThreatRating );
	}
	
	function UpdateThreatDamp()
	{
		var dt : float;
		var prev : float;
		
		dt = ClampF( theGame.GetEngineTimeAsSeconds() - lastThreatDampTime, 0.0, threatDampCooldown );
		
		prev = currentThreatRating;
		currentThreatRating = threatDamper.UpdateAndGet( dt, desiredThreatRating );
		
		if ( prev < currentThreatRating )
		{
			threatDamper.SetSmoothTime(0.5f);
		}
		else
		{
			threatDamper.SetSmoothTime(2.0f);
		}
		
		SoundParameter( 'threat_rating', currentThreatRating );
		
		LogSound( "Threat rating updated - current value = " + currentThreatRating );
		lastThreatDampTime = theGame.GetEngineTimeAsSeconds();
		
		
		if(!thePlayer.IsCiri() && !thePlayer.IsHoldingItemInLHand() && currentThreatRating >= 95.0)
			thePlayer.SetBehaviorVariable('playerDoubleHandSword',1.0f);
		else
			thePlayer.SetBehaviorVariable('playerDoubleHandSword',0.0f);
		
	}

	function IsMonsterFromMonsterHunt( monster : CActor ) : bool
	{
		return monster.HasAbility( 'MonsterHunt' );
	}
	public function UpdateSoundSettings()
	{
		soundSystemSettings = LoadCSV("gameplay\globals\sound_threat_settings.csv");
		threatWeight		=	StringToInt(soundSystemSettings.GetValueAt(1,0));
		levelWeight 		=	StringToInt(soundSystemSettings.GetValueAt(1,1));
		tweakWeight			=	StringToFloat(soundSystemSettings.GetValueAt(1,2));
		LogSound( "threatWeight = " + threatWeight );
		LogSound( "levelWeight = " + levelWeight);
		LogSound( "tweakWeight = " + tweakWeight);
	}
}





exec function CollectSoundStates()
{
	var player : CR4Player = thePlayer;

	if( theSound.stateChangeTimestamp + theSound.stateCheckCooldown > theGame.GetEngineTimeAsSeconds() )
		return;	
	else if( theGame.IsStopped() && !theSound.GetIsGameStopped() )
	{
		theSound.SoundEvent( "system_alt_tab" );
		theSound.SetIsGameStopped( true );
		return;
	}
	else if( !theGame.IsStopped() && theSound.GetIsGameStopped() )
	{
		if( theGame.GetGuiManager().GetCommonMenu() )
		{
			theSound.SoundEvent("system_resume_music_only");
		}
		else
		{
			theSound.SoundEvent("system_resume");
		}
		theSound.SetIsGameStopped( false );
	}
	else if( !theGame.IsActive() ) 
		return;
	else if(theGame.IsPausedForReason("Constrained"))
	{
		theSound.SetDefaultGameState(ESGS_Paused);
	}
	else if( !theSound.IsInDefaultState() )
		return;		
	
	if( thePlayer.OnIsCameraUnderwater() )
	{
		if( thePlayer.ShouldEnableCombatMusic() )
		{
			theSound.SetDefaultGameState( ESGS_UnderwaterCombat );
		}
		else if ( !thePlayer.IsThreatened() )
		{
			theSound.SetDefaultGameState( ESGS_Underwater );
		}
	}
	else if( thePlayer.ShouldEnableCombatMusic() )
	{
		theSound.SendThreatRating();
		if ( theSound.GetMonster() )
		{
			theSound.SetDefaultGameState( ESGS_CombatMonsterHunt );
		}
		else
		{
			theSound.SetDefaultGameState( ESGS_Combat );
		}
	}
	else if ( !thePlayer.IsThreatened() )
	{	
		if( theGame.envMgr.IsNight() )
		{
			theSound.SetDefaultGameState( ESGS_ExplorationNight );
		}
		else
		{
			theSound.SetDefaultGameState( ESGS_Exploration );
		}
	}
}

exec function SoundEvent( soundName : string )
{
	theSound.SoundEvent( soundName );
}

exec function SetSoundState( stateGroupName : string, stateName : string  )
{
	theSound.ChangeSoundState( stateGroupName, stateName );
}

exec function soundSequenceOne( sequenceName : string, sequenceElementOne : string )
{
	var sequence : array < string >;
	sequence.PushBack( sequenceElementOne );
	theSound.SoundSequence( sequenceName, sequence );
}

exec function soundSequenceTwo( sequenceName : string, sequenceElementOne : string, sequenceElementTwo : string )
{
	var sequence : array < string >;
	sequence.PushBack( sequenceElementOne );
	sequence.PushBack( sequenceElementTwo );
	theSound.SoundSequence( sequenceName, sequence );
}

exec function soundSequenceThree( sequenceName : string, sequenceElementOne : string, sequenceElementTwo : string, sequenceElementThree : string )
{
	var sequence : array < string >;
	sequence.PushBack( sequenceElementOne );
	sequence.PushBack( sequenceElementTwo );
	sequence.PushBack( sequenceElementThree );
	theSound.SoundSequence( sequenceName, sequence );
}

exec function soundSequenceFour( sequenceName : string, sequenceElementOne : string, sequenceElementTwo : string, sequenceElementThree : string, sequenceElementFour : string )
{
	var sequence : array < string >;
	sequence.PushBack( sequenceElementOne );
	sequence.PushBack( sequenceElementTwo );
	sequence.PushBack( sequenceElementThree );
	sequence.PushBack( sequenceElementFour );
	theSound.SoundSequence( sequenceName, sequence );
}

exec function soundSequenceFive( sequenceName : string, sequenceElementOne : string, sequenceElementTwo : string, sequenceElementThree : string, sequenceElementFour : string, sequenceElementFive : string )
{
	var sequence : array < string >;
	sequence.PushBack( sequenceElementOne );
	sequence.PushBack( sequenceElementTwo );
	sequence.PushBack( sequenceElementThree );
	sequence.PushBack( sequenceElementFour );
	sequence.PushBack( sequenceElementFive );
	theSound.SoundSequence( sequenceName, sequence );
}

exec function enableMusicDebug()
{
	theSound.EnableMusicDebug(true);
}

exec function disableMusicDebug()
{
	theSound.EnableMusicDebug(false);
}