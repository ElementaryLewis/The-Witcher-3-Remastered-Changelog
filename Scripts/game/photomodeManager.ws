/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
function GetPhotomodeContextName() : name
{
	return 'Photomode';
}

function GetPhotomodeMenuName() : name
{
	return 'PhotomodeMenu';
}

class PhotomodeManager
{
	private var m_photomodeEnabled : bool; default m_photomodeEnabled = false;
	private var m_photomodeEnabledStep1 : bool; default m_photomodeEnabledStep1 = false;
	private var m_photomodeEnabledStep2 : bool; default m_photomodeEnabledStep2 = false;
	
	private var m_lastActiveCam : CCustomCamera;
	private var m_lastActiveContext : name;
	
	public function Initialize()
	{		
		theInput.RegisterListener( this, 'OnPhotomodeEnable', 'EnablePhotoMode' );
		theInput.RegisterListener( this, 'OnPhotomodeEnableStep', 'EnablePhotoMode_Step1' );
		theInput.RegisterListener( this, 'OnPhotomodeEnableStep', 'EnablePhotoMode_Step2' );
		
	}
	
	event OnPhotomodeEnableStep( action : SInputAction )
	{
		if( IsPressed( action ) && action.aName == 'EnablePhotoMode_Step1' )
		{
			m_photomodeEnabledStep1 = true;
		}
		else if( IsPressed( action ) && action.aName == 'EnablePhotoMode_Step2' )
		{
			m_photomodeEnabledStep2 = true;
		}
		if( IsReleased( action ) && action.aName == 'EnablePhotoMode_Step1' )
		{
			m_photomodeEnabledStep1 = false;
		}
		else if( IsReleased( action ) && action.aName == 'EnablePhotoMode_Step2' )
		{
			m_photomodeEnabledStep2 = false;
		}
		
		if( m_photomodeEnabledStep1 && m_photomodeEnabledStep2 )
		{
			m_photomodeEnabledStep1 = false;
			m_photomodeEnabledStep2 = false;
			EnablePhotomode();
		}
	}
	
	event OnPhotomodeEnable( action : SInputAction )
	{		
		if(!IsPressed(action))
			return false;
			
		EnablePhotomode();
	}
	
	event OnPhotomodeDisable( action : SInputAction)
	{
		if(!IsPressed(action))
			return false;
			
		DisablePhotomode();
	}
		
	private function EnablePhotomode()
	{
		var gameCameraPosition : Vector;
		var gameCameraRotation : EulerAngles;

		if( 
		   m_photomodeEnabled 
		|| theGame.IsDialogOrCutscenePlaying() 
		|| !thePlayer.IsAlive()
		|| thePlayer.IsInCutsceneIntro()
		|| theGame.IsBlackscreenOrFading() 
		|| theGame.HasBlackscreenRequested()
		|| theGame.IsCurrentlyPlayingNonGameplayScene()
		|| theGame.GetGuiManager().IsAnyMenu()
		|| theGame.GetTutorialSystem().HasActiveTutorial()
		)
			return;

		theGame.SetPhotomodeEnabled( true );

		m_lastActiveCam = theGame.GetWorld().GetCameraDirector().GetTopmostCamera();
		m_lastActiveContext = theInput.GetContext();
		gameCameraPosition = m_lastActiveCam.GetCameraWorldPosition() + m_lastActiveCam.GetCameraWorldOffset();
		gameCameraRotation = m_lastActiveCam.GetCameraWorldRotation();

		theSound.SoundEvent( "system_pause" );
		
		theInput.SuppressPropagatingEventAfterAction( 'EnablePhotoMode' );
		theInput.SuppressPropagatingEventAfterAction( 'EnablePhotoMode_Step1' );
		theInput.SuppressPropagatingEventAfterAction( 'EnablePhotoMode_Step2' );
		theInput.SetContext( GetPhotomodeContextName() );
		
		theGame.GetPhotomodeCamera().Activate();
		theGame.GetPhotomodeCamera().SetCameraWorldPosition(gameCameraPosition);
		theGame.GetPhotomodeCamera().SetCameraWorldRotation(gameCameraRotation);
		theGame.GetPhotomodeCamera().UpdateWithoutInput( true );

		PauseFx();
		theGame.RequestMenu( GetPhotomodeMenuName() );
		
		m_photomodeEnabled = true;
		thePlayer.ApplyCastSettings();
		thePlayer.SetPhotoModeHorseKick(true);
		
		
		theGame.SetPhotomodeCameraCanMove(false);

		
		DoFakeTick();
	}
	
	public function DisablePhotomode()
	{
		if( !m_photomodeEnabled )
			return;
		theGame.SetPhotomodeEnabled( false );
		theGame.GetPhotomodeEffects().RestoreWeather();

		theSound.SoundEvent( "system_resume" );
		theGame.CloseMenu( GetPhotomodeMenuName() );
		UnpauseFx();
		m_lastActiveCam.Activate( 0.0f, false );	
		theInput.SetContext( m_lastActiveContext );	
			
		m_photomodeEnabled = false;
		thePlayer.ApplyCastSettings();
		
		
		theGame.GetCityLightManager().SetUpdateEnabled( true );
		theGame.GetCityLightManager().ForceUpdate();
	}

	public function DoFakeTick() : void
	{
		
		
		theGame.GetPhotomodeEffects().SetPhotomodeTickTime(0.00001);
	}
	
	private function PauseFx()
	{
		theGame.PauseGameplayFx( true );
		theGame.GetWorld().ForceUpdateWaterOnPause( true );
	}
	
	private function UnpauseFx()
	{	
		theGame.PauseGameplayFx( false );
		theGame.GetWorld().ForceUpdateWaterOnPause( false );
	}
}