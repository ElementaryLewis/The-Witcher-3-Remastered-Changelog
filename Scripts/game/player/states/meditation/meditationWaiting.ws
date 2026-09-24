/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state MeditationWaiting in W3PlayerWitcher extends MeditationBase
{
	private const var TARGET_HOURS_PER_MINUTE : float;		
	private const var BLEND_TIME_SECONDS_REAL : float;		
	
	private var storedHoursPerMinute : float;				
	private var waitStartTime : GameTime;					
	private var requestedTargetTime : GameTime;				
	private var abortRequested : bool;						
	
		default TARGET_HOURS_PER_MINUTE = 320.0;
		default BLEND_TIME_SECONDS_REAL = 2;

	event OnEnterState( prevStateName : name )
	{
		var requestedTargetHour : int;
		var fastForward : CGameFastForwardSystem;
		
		fastForward = theGame.GetFastForwardSystem();
		fastForward.BeginFastForward();
	
		virtual_parent.LockEntryFunction( true );
		
		storedHoursPerMinute = theGame.GetHoursPerMinute();
		waitStartTime = theGame.GetGameTime();
		requestedTargetHour = virtual_parent.GetWaitTargetHour();
		
		if(requestedTargetHour > GameTimeHours(waitStartTime))
			requestedTargetTime = GameTimeCreate(GameTimeDays(waitStartTime), requestedTargetHour, 0, 0);
		else
			requestedTargetTime = GameTimeCreate(GameTimeDays(waitStartTime) + 1, requestedTargetHour, 0, 0);
				
		
		FactsSet('MeditationWaitStartDay', GameTimeDays(waitStartTime));		
		FactsSet('MeditationWaitStartHour', GameTimeHours(waitStartTime));
		FactsSet('MeditationStarted', 1);
		
		virtual_parent.LockEntryFunction( false );
		
		MeditationWaiting_Loop();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		var fastForward : CGameFastForwardSystem;
		
		fastForward = theGame.GetFastForwardSystem();
		fastForward.AllowFastForwardSelfCompletion();
		
		FactsSet('MeditationStarted', 0);
		theGame.SetHoursPerMinute(storedHoursPerMinute);
		
		if(abortRequested)
		{
			LatentHackMeditationWaitingAbort();
		}
		
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
		var blendInTime : float;
	
		blendInTime = BlendIn();
		
		if(!abortRequested)
			KeepWaiting(theGame.GetGameTime() - waitStartTime);
		
		BlendOut(2 * BLEND_TIME_SECONDS_REAL - blendInTime);
		
		
		
		
		theGame.SetHoursPerMinute(storedHoursPerMinute);
		
		
		
		if(!abortRequested)
			theGame.SetGameTime(requestedTargetTime, false);
		
		
		GetWitcherPlayer().MeditationRestoring( FinalHack_GetSimulateBuffTime() );				
		
		
		abortRequested = false;
		virtual_parent.PopState();
		virtual_parent.PushState('Meditation');	
	}
	
	
	private latent function BlendIn() : float
	{
		var blendStartTime, currentEngineTime : EngineTime;
		var totalBlendTimeSecsReal, blendedHPM : float;
		var halfMeditationTime  : GameTime;
	
		blendStartTime = theGame.GetEngineTime();
		
		
		halfMeditationTime = waitStartTime + GameTimeCreateFromGameSeconds( (GameTimeToSeconds(requestedTargetTime) - GameTimeToSeconds(waitStartTime)) / 2);
		
		while(true)
		{
			currentEngineTime = theGame.GetEngineTime();
			totalBlendTimeSecsReal = EngineTimeToFloat(currentEngineTime - blendStartTime);
							
			
			if(totalBlendTimeSecsReal >= BLEND_TIME_SECONDS_REAL || theGame.GetGameTime() >= halfMeditationTime || abortRequested)
				break;
			
			blendedHPM = storedHoursPerMinute + (TARGET_HOURS_PER_MINUTE - storedHoursPerMinute) * totalBlendTimeSecsReal / BLEND_TIME_SECONDS_REAL;
			blendedHPM = MinF(TARGET_HOURS_PER_MINUTE, blendedHPM);
			
			theGame.SetHoursPerMinute(blendedHPM);
			
			SleepOneFrame();
		}
		
		return totalBlendTimeSecsReal;
	}
	
	
	private latent function BlendOut(estimatedBlendTimeReal : float)
	{
		var blendStartTime, currentEngineTime : EngineTime;
		var totalBlendTimeSecsReal, blendedHPM : float;
		var currentGameTime : GameTime;
	
		blendStartTime = theGame.GetEngineTime();
		
		while(true)
		{
			currentGameTime = theGame.GetGameTime();
			currentEngineTime = theGame.GetEngineTime();
			totalBlendTimeSecsReal = EngineTimeToFloat(currentEngineTime - blendStartTime);
				
			
			if(currentGameTime >= requestedTargetTime)
				break;
			
			
			if(abortRequested)
				blendedHPM = TARGET_HOURS_PER_MINUTE - 4 * (TARGET_HOURS_PER_MINUTE - storedHoursPerMinute) * totalBlendTimeSecsReal / estimatedBlendTimeReal;
			else
				blendedHPM = TARGET_HOURS_PER_MINUTE - (TARGET_HOURS_PER_MINUTE - storedHoursPerMinute) * totalBlendTimeSecsReal / estimatedBlendTimeReal;
			
			blendedHPM = MaxF(storedHoursPerMinute, blendedHPM);
			
			
			if(blendedHPM == storedHoursPerMinute)
				break;
			
			theGame.SetHoursPerMinute(blendedHPM);
			
			SleepOneFrame();
		}
	}
	
	
	private latent function KeepWaiting(blendTime : GameTime)
	{
		var currentTime : GameTime;
		var commonMenuRef : CR4CommonMenu;
	
		while(true)
		{
			currentTime = theGame.GetGameTime();
			
			
			if((currentTime + blendTime > requestedTargetTime) || abortRequested)
				break;
				
			if ( thePlayer.IsThreatened() )
			{
				commonMenuRef = theGame.GetGuiManager().GetCommonMenu();
				if (commonMenuRef)
				{
					commonMenuRef.CloseMenu();
				}
			}
				
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
}
