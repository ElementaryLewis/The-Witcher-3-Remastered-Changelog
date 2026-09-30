/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state MeditationWaiting in W3PlayerWitcher extends MeditationBase
{
	private  var BLEND_TIME_SECONDS_REAL : float;		
	private  var BLEND_STEP_COUNT : int;
	private  var MAX_TIMESCALE : float;
	private  var MAX_FOLIAGE_TIMESCALE : float;
	private  var MAX_CLOUDS_TIMESCALE : float;
	private  var WAIT_DURATION_WITHOUT_BLEND : float;	
	private  var WAIT_DURATION_ADD_PER_HOUR : float;	
	private  var BLEND_OUT_HPM_TARGET: float;
	private const var BLEND_OUT_TIME_COEF : float;				
	private const var WEATHER_BLEND_COEF : float;				
	
	private var storedHoursPerMinute : float;				
	private var waitStartTime : GameTime;					
	private var requestedTargetTime : GameTime;				
	private var abortRequested : bool;						
	private var abortRequestedInstant : bool;				
	private var timeToSkipRealSeconds : float;

	private var storedWeatherQuestPause : bool;

	private var targetHoursPerMinute : float;

	private var storedInteractionPriority : EInteractionPriority;
	
		default BLEND_TIME_SECONDS_REAL = 2;
		default BLEND_STEP_COUNT = 10;
		default MAX_TIMESCALE = 5;
		default MAX_FOLIAGE_TIMESCALE = 2;
		default MAX_CLOUDS_TIMESCALE = 20;
		default WAIT_DURATION_WITHOUT_BLEND = 3;
		default WAIT_DURATION_ADD_PER_HOUR = 0.2f;
		default BLEND_OUT_HPM_TARGET = 5;
		default BLEND_OUT_TIME_COEF = 0.1f;
		default WEATHER_BLEND_COEF = 0.9f;

	event OnEnterState( prevStateName : name )
	{
		var requestedTargetHour : int;
		var fastForward : CGameFastForwardSystem;
		var timeUntilWeatherChange : float;

		
		var config : CInGameConfigWrapper;
		config = theGame.GetInGameConfigWrapper();

		BLEND_TIME_SECONDS_REAL = StringToFloat( config.GetVarValue( 'RemasterCombat', 'MeditationBlendTime' ) );
		BLEND_STEP_COUNT = StringToInt( config.GetVarValue( 'RemasterCombat', 'MeditationBlendStepCount' ) );
		WAIT_DURATION_WITHOUT_BLEND = StringToFloat( config.GetVarValue( 'RemasterCombat', 'MeditationWaitTime' ) );
		WAIT_DURATION_ADD_PER_HOUR = StringToFloat( config.GetVarValue( 'RemasterCombat', 'MeditationWaitTimeAddPerHour' ) );
		MAX_TIMESCALE = StringToFloat( config.GetVarValue( 'RemasterCombat', 'MeditationMaxTimescale' ) );
		MAX_FOLIAGE_TIMESCALE = StringToFloat( config.GetVarValue( 'RemasterCombat', 'MeditationMaxFoliageTimescale' ) );
		MAX_CLOUDS_TIMESCALE = StringToFloat( config.GetVarValue( 'RemasterCombat', 'MeditationMaxCloudsTimescale' ) );
		BLEND_OUT_HPM_TARGET = StringToFloat( config.GetVarValue( 'RemasterCombat', 'MeditationBlendOutHpmTarget' ) );
		

		super.OnEnterState( prevStateName );

		abortRequested = false;
		abortRequestedInstant = false;
		fastForward = theGame.GetFastForwardSystem();
		fastForward.BeginFastForward( false, false, false );
	
		virtual_parent.LockEntryFunction( true );
		
		storedHoursPerMinute = theGame.GetHoursPerMinute();
		storedWeatherQuestPause = IsWeatherPauseRequested();
		waitStartTime = theGame.GetGameTime();
		requestedTargetHour = virtual_parent.GetWaitTargetHour();
		
		if(requestedTargetHour > GameTimeHours(waitStartTime))
			requestedTargetTime = GameTimeCreate(GameTimeDays(waitStartTime), requestedTargetHour, 0, 0);
		else
			requestedTargetTime = GameTimeCreate(GameTimeDays(waitStartTime) + 1, requestedTargetHour, 0, 0);
				
		theSound.SoundEvent("gui_meditation_timelapse_start");
		
		
		FactsSet('MeditationWaitStartDay', GameTimeDays(waitStartTime));		
		FactsSet('MeditationWaitStartHour', GameTimeHours(waitStartTime));
		FactsSet('MeditationStarted', 1);
		
		virtual_parent.LockEntryFunction( false );

		timeToSkipRealSeconds = ConvertGameSecondsToRealTimeSeconds( GameTimeToSeconds(requestedTargetTime) - GameTimeToSeconds(waitStartTime) );
		GetPredictedTimeUntilWeatherChange( timeUntilWeatherChange );

		targetHoursPerMinute = (timeToSkipRealSeconds / CalcWaitDuration( timeToSkipRealSeconds )) * storedHoursPerMinute;

		if ( timeToSkipRealSeconds >= timeUntilWeatherChange )
		{
			RequestRandomWeatherChange( timeToSkipRealSeconds * WEATHER_BLEND_COEF, true );
		}

		storedInteractionPriority = virtual_parent.GetInteractionPriority();
		virtual_parent.SetInteractionPriority( IP_Max_Unpushable );	
		
		MeditationWaiting_Loop();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		var fastForward : CGameFastForwardSystem;

		
		FactsSet('MeditationStarted', 0);
		theGame.SetHoursPerMinute(storedHoursPerMinute);
		fastForward = theGame.GetFastForwardSystem();
		fastForward.AllowFastForwardSelfCompletion();
		
		if(abortRequested)
		{
			LatentHackMeditationWaitingAbort();
		}

		ResetTimeScale();
		RequestWeatherPause( storedWeatherQuestPause );
		theSound.SoundEvent("gui_meditation_timelapse_end");


		virtual_parent.SetInteractionPriority( storedInteractionPriority );
		
		super.OnLeaveState(nextStateName);
	}
	
	entry function LatentHackMeditationWaitingAbort()
	{
		var medd : W3PlayerWitcherStateMeditation;
		
		medd = (W3PlayerWitcherStateMeditation)thePlayer.GetState('Meditation');
		medd.StopMeditation();
	}
	
	private entry function MeditationWaiting_Loop()
	{
		var fastForward : CGameFastForwardSystem;

		BlendIn();
		
		WaitAndBlendOut( theGame.GetGameTime() - waitStartTime );
		
		
		
		
		theGame.SetHoursPerMinute(storedHoursPerMinute);
		
		
		
		if(!abortRequested)
			theGame.SetGameTime(requestedTargetTime, false);
		
		
		GetWitcherPlayer().MeditationRestoring( FinalHack_GetSimulateBuffTime() );

		fastForward = theGame.GetFastForwardSystem();
		fastForward.AllowFastForwardSelfCompletion();

		SleepIgnoreTimeScale( 0.5f );	
		
		
		abortRequested = false;
		abortRequestedInstant = false;
		CloseUI();
		virtual_parent.PopState();
		virtual_parent.PushState('Meditation');	
	}
	
	private latent function BlendIn()
	{
		var blendStartTime, currentEngineTime : EngineTime;
		var totalBlendTimeSecsReal, blendedHPM : float;
		var timeScale : float;

		var timeScaleStep, hpmStep : float;
		var stepCounter : int;
		var currentTargetHpm : float;

		timeScale = theGame.GetTimeScale();
		blendStartTime = theGame.GetEngineTime();

		hpmStep = (targetHoursPerMinute - storedHoursPerMinute) / BLEND_STEP_COUNT;
		timeScaleStep = (MAX_TIMESCALE - timeScale) / BLEND_STEP_COUNT;
		
		while(true)
		{
			currentEngineTime = theGame.GetEngineTime();
			
			stepCounter += 1;
			timeScale += timeScaleStep;
			
			currentTargetHpm = stepCounter * hpmStep;
			blendedHPM = currentTargetHpm / timeScale;

			SetTimeScales( timeScale, blendedHPM );

			if ( stepCounter >= BLEND_STEP_COUNT )
				break;
			else
				SleepIgnoreTimeScale(BLEND_TIME_SECONDS_REAL / BLEND_STEP_COUNT);
		}
	}

	private latent function WaitAndBlendOut( blendTime : GameTime )
	{
		var blendedHPM : float;
		var currentGameTime : GameTime;
		var timeUntilFinish : float;
		var timeScale : float;
		var timeScaleStart : float;
		var blendStartHPM : float;

		var progress : float;
		var totalTimeScaleChange : float;
		var totalHpmChange : float;

		var abortChangedTargetTime : bool;
		var abortNewTargetTime : GameTime;

		blendStartHPM = theGame.GetHoursPerMinute();
		timeScaleStart = theGame.GetTimeScale();
		totalTimeScaleChange = 1 - timeScaleStart;
		totalHpmChange = BLEND_OUT_HPM_TARGET - blendStartHPM;

		blendTime = blendTime * BLEND_OUT_TIME_COEF;

		while(true)
		{
			currentGameTime = theGame.GetGameTime();

			
			if(currentGameTime >= requestedTargetTime || abortRequestedInstant)
				break;
			
			if ( abortRequested && !abortChangedTargetTime )
			{
				abortChangedTargetTime = true;
				abortNewTargetTime = currentGameTime + blendTime / 2;

				if ( abortNewTargetTime < requestedTargetTime )
					requestedTargetTime = abortNewTargetTime;
			}

			timeUntilFinish = GameTimeToSeconds( requestedTargetTime - currentGameTime );

			if ( timeUntilFinish > GameTimeToSeconds( blendTime ) )
			{
				SleepOneFrame();
				continue;
			}
			

			
			progress = 1 - timeUntilFinish / GameTimeToSeconds( blendTime );
			progress = PowF( progress, 0.5 );		

			timeScale = timeScaleStart + (totalTimeScaleChange * progress);

			blendedHPM = blendStartHPM + (totalHpmChange * progress);

			blendedHPM = MaxF(storedHoursPerMinute, blendedHPM);

			SetTimeScales( timeScale, blendedHPM );

			
			if( blendedHPM <= BLEND_OUT_HPM_TARGET )
				break;
					
			SleepOneFrame();
		}

	}
	
	
	public function RequestWaitStop()
	{	
		abortRequested = true;
	}
	
	
	public function StopRequested(optional closeUI : bool)
	{
		var medd : W3PlayerWitcherStateMeditation;
	
		
		RequestWaitStop();
		
		
		medd = (W3PlayerWitcherStateMeditation)(thePlayer.GetState('Meditation'));
		medd.StopRequested(closeUI);
	}

	public function CancelWaiting( optional closeUI : bool )
	{
		abortRequestedInstant = true;
		ResetTimeScale();
		StopRequested( closeUI );
	}
	
	
	private final function FinalHack_GetSimulateBuffTime() : float
	{
		var passedSecondsInGameTime, passedSecondsInRealTime : float;
		var currTime : GameTime;
		
		
		currTime = theGame.GetGameTime();
		if( waitStartTime > currTime )
		{
			return 0.f;
		}
		
		passedSecondsInGameTime = GameTimeToSeconds(currTime - waitStartTime);
		passedSecondsInRealTime = ConvertGameSecondsToRealTimeSeconds(passedSecondsInGameTime);
		
		return passedSecondsInRealTime;
	}

	private function CalcWaitDuration( timeToSkipRealSeconds : float ) : float
	{
		var oneHour : float = 60.f / storedHoursPerMinute;
		var durationAdd : float = RoundF(timeToSkipRealSeconds / oneHour) * WAIT_DURATION_ADD_PER_HOUR;

		return WAIT_DURATION_WITHOUT_BLEND + durationAdd;
	}

	private function SetTimeScales( timeScale : float, hpm : float )
	{
		virtual_parent.SetMeditationAnimSpeedCauserId( virtual_parent.SetAnimationSpeedMultiplier( 1 / timeScale, virtual_parent.GetMeditationAnimSpeedCauserId() ) );
		SetWindSpeedTreeTimeScale( ( 1 / timeScale ) * MAX_FOLIAGE_TIMESCALE );
		SetWindCloudsTimeScale( 1 / ( timeScale * ( hpm / storedHoursPerMinute ) ) * MAX_CLOUDS_TIMESCALE );	

		theGame.SetTimeScale( timeScale, theGame.GetTimescaleSource( ETS_Meditation ), theGame.GetTimescalePriority( ETS_Meditation ), false, true );
		theGame.SetHoursPerMinute( hpm );
	}

	private function ResetTimeScale()
	{
		virtual_parent.ResetMeditationAnimSpeed();
		SetWindSpeedTreeTimeScale( 1.f );
		SetWindCloudsTimeScale( 1.f );
		theGame.RemoveTimeScale( theGame.GetTimescaleSource( ETS_Meditation ) );
		theGame.SetHoursPerMinute( storedHoursPerMinute );
	}

	event OnPlayerTickTimer( deltaTime : float )
	{
		super.OnPlayerTickTimer( deltaTime );

		if ( theGame.IsGameTimePaused() )
		{
			CancelWaiting( true );
		}
	}
}