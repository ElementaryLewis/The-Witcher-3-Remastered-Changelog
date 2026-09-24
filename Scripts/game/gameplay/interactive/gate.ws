/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class CGateEntity extends W3LockableEntity
{
	private saved var currState : name;
	private var speedModifier : float;
	
	private editable var initiallyOpened : bool;
	private editable var startSound : name;
	private editable var stopSound : name;
	private var runTime : float;
	
	default currState = 'Closed';
	default startSound = 'global_doors_portcullis_wooded_loop_start';
	default stopSound = 'global_doors_portcullis_wooded_loop_stop';
	default runTime = 6.0;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		if(	spawnData.restored )
		{
			if( currState == 'Closed' )
			{
				CloseGate( 0.01 );
			}
			else
			{
				OpenGate( 0.01 );
			}
		}
		else 
		{
			HandleInitialState();
		}
	}
	
	event OnStreamIn()
	{
		if (!theGame.IsActive())
			return false;
		
		if( currState == 'Closed' )
			{
				
				EnableDeniedArea( true );
			}
			else
			{
				PlayPropertyAnimation( 'raise', 1, 0.01, PCM_Forward );
				EnableDeniedArea( false );
			}

		super.OnStreamIn();
	}
	
	private function HandleInitialState()
	{
		if( initiallyOpened )
		{
			OpenGate( 0.01 );
		}
		else
		{
			CloseGate( 0.01 );
		}
	}
	
	public function CloseGate( passedSpeedModifier : float )
	{
		SetSpeedModifier( passedSpeedModifier );
		PlayGateSounds();
		GotoState( 'Closed' );
	}
	
	public function OpenGate( passedSpeedModifier : float )
	{
		SetSpeedModifier( passedSpeedModifier );
		PlayGateSounds();
		GotoState( 'Opened' );
	}
	
	public function EnableDeniedArea( toggle : bool )
	{
		var deniedArea : CDeniedAreaComponent;
		
		deniedArea = (CDeniedAreaComponent)GetComponent( "deniedArea" );
		if( deniedArea )
			deniedArea.SetEnabled( toggle );
	}
	
	public function PlayGateSounds()
	{
		if( runTime * speedModifier >= 2.0 ) 
		{
			SoundEvent( startSound );
			AddTimer( 'StopGateSounds', runTime * speedModifier - 1.0, false );
		}
	}

	timer function StopGateSounds( td : float, id : int )
	{
		SoundEvent( stopSound );
	}
	
	public function GetCurrState() : name				{ return currState; }
	public function SetCurrState( stateName : name ) 	{ currState = stateName; }
	public function GetSpeedModifier() : float			{ return speedModifier; }
	public function SetSpeedModifier( passedSpeedModifier : float )		
	{ 
		if( passedSpeedModifier < 0.01 ) 
		{
			speedModifier = 0.01;
		}
		else
		{
			speedModifier = passedSpeedModifier;
		}
	}	
}

state Closed in CGateEntity
{
	event OnEnterState( prevStateName : name )
	{
		Close();
		parent.SetCurrState( 'Closed' );
	}

	private function Close()
	{
		parent.PlayPropertyAnimation( 'raise', 1, parent.GetSpeedModifier(), PCM_Backward );
		parent.EnableDeniedArea( true );
	}
}

state Opened in CGateEntity
{
	event OnEnterState( prevStateName : name )
	{
		Open();
		parent.SetCurrState( 'Opened' );
	}

	private function Open()
	{
		parent.PlayPropertyAnimation( 'raise', 1, parent.GetSpeedModifier(), PCM_Forward );
		parent.EnableDeniedArea( false );
	}
}