/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EExplorationStateType
{
	EST_None		,
	EST_Idle		,
	EST_OnAir		,
	EST_Swim		,
	EST_Skate		,
	EST_Critical	,
	EST_Locked		,
	EST_Unchanged	,
}

enum EBehGraphConfirmationState
{
	BGCS_None			,
	BGCS_Waiting		,
	BGCS_Confirmed		,
	BGCS_NotConfirmed	,
}





function LogExploration( _TextS : string )
{
	LogChannel( 'ExplorationState', _TextS );
}




function LogExplorationError( _TextS : string )
{
	var text	: string	= "!!!!!!!!!!!!!!ERROR: " + _TextS;
	
	LogChannel( 'ExplorationState'			, text );
	LogChannel( 'ExplorationStateErrors'	, text );
}




function LogExplorationWarning( _TextS : string )
{
	var text	: string	= "!!!!!Warning: " + _TextS;
	
	LogChannel( 'ExplorationState'			, text );
	LogChannel( 'ExplorationStateWarnings'	, text );
}



function LogExplorationToken( text : string )
{
	LogChannel( 'Exploration Token', text );
}




function InitExplorationLogs()
{
	var text	: string	= "	Initialized Log channel: ";
	
	LogExploration( text + "ExplorationState" );
	LogExplorationWarning( text + "ExplorationStateWarnings" );
	LogExplorationError( text + "ExplorationStateErrors" );
	LogExplorationToken( text + "Exploration Token" );
}




class CExplorationStateManager extends CSelfUpdatingComponent
{
	
	public						var		m_OwnerE					: CGameplayEntity;
	public						var		m_OwnerMAC					: CMovingPhysicalAgentComponent;
	
	
	public	editable inlined	var		m_InputO					: CExplorationInput;
	public	editable inlined	var		m_MoverO					: CExplorationMover;
	public	editable inlined	var		m_SharedDataO				: CExplorationSharedData;
	public	editable inlined	var		m_CollisionManagerO			: CExplorationCollisionManager;
	public	editable inlined	var		m_MovementCorrectorO		: CExplorationMovementCorrector;
	
	
	private						var		m_SuperStateLastN			: name; 
	
	
	private 					var 	m_StatesSArr				: array< CExplorationStateAbstract >;
	private 					var 	m_StatesUpdatedInactiveSArr	: array< CExplorationStateAbstract >;
	private 					var 	m_StateNamesSArr			: array< name >;
	private						var		m_StateTransitionsSArr		: array< CExplorationStateTransitionAbstract >;
	private 					var		m_StateLastN				: name;
	private 					var		m_StateLastI				: int;
	private 					var		m_StateCurN					: name;
	private 					var		m_StateCurI					: int;
	private 					var		m_StateTimeCurF				: float;
	private 					var		m_StateTimeLastF			: float;
	private						var		m_StateGlobalQueuedN		: name;
	private						var		m_StateDefaultN				: name;					default	m_StateDefaultN				= 'Idle';
	private	const				var		c_InvalidStateN				: name;					default	c_InvalidStateN				= 'Invalid';
	private	const				var		c_InvalidStateI				: int;					default	c_InvalidStateI				= 0;
	private						var		m_StateChanged				: bool;
	
	
	private						var		m_StateExitedFromBehN		: name;
	private						var		m_StateEnteredFromBehN		: name;
	private						var		m_BehaviorConfirmStateE		: EBehGraphConfirmationState;
	private						var		m_StateBehCurReportedN		: name;
	
	
	public	editable inlined 	var		m_DefaultCameraSetS			: CCameraParametersSet; 
	
	
	private						var		m_IsOnGroundB				: bool;
	
	
	
	private			 			var		m_TeleportedFallHackTime		: float; 
	private	editable 			var		m_TeleportedFallHackTimeTotalF	: float; 			default	m_TeleportedFallHackTimeTotalF	= 0.1f;
	
	
	private						var		m_storedInteractionPri 		: EInteractionPriority; default	m_storedInteractionPri 		= IP_NotSet;
	
	
	private						var		m_NoSaveLock				: int;					default	m_NoSaveLock				= -1;
	private						var		m_NoSaveLockStringS 		: String;				default	m_NoSaveLockStringS			= 'exploration_state';
	
	
	private						var		m_ActiveB					: bool;
	private						var		m_InitializedB				: bool;					default	m_InitializedB				= false;	
	public						var		m_IsDebugModeB				: bool;					default	m_IsDebugModeB				= false;
	public						var		m_DebugPointV				: Vector;
	public						var		m_SmoothedVelocityV			: Vector;
	
	
	
	
	
	
	
	event OnComponentAttached()
	{
		var l_EntityE	: CGameplayEntity;
		var l_ActorE	: CActor;
		var	l_MAC		: CMovingPhysicalAgentComponent;
		
		
		InitExplorationLogs();
		
		if( !theGame.IsActive())
		{
			return true;
		}
		
		
		l_EntityE	= ( CGameplayEntity ) GetEntity();
		l_ActorE	= (CActor) l_EntityE;
		if( l_ActorE )
		{
			l_MAC	= (CMovingPhysicalAgentComponent) l_ActorE.GetMovingAgentComponent();
			if( !l_MAC )
			{				
				LogExplorationError( "Owner is has no CMovingPhysicalAgentComponent" );
			}
		}
		else
		{
			LogExplorationError( "Owner is not an actor" );
		}
		
		Initialize( (CGameplayEntity) l_EntityE, l_MAC );
		
		return true;
	}
	
	
	public function Initialize( _OwnerEntityE : CGameplayEntity, _OwnerEntityMAC : CMovingPhysicalAgentComponent )
	{	
		var test	: bool;
		
		
		if( theGame.IsFinalBuild() )
		{
			m_IsDebugModeB = false;
		}
		
		
		m_OwnerE	= _OwnerEntityE;
		m_OwnerMAC	= _OwnerEntityMAC;
		
		
		if( !m_InputO )
		{
			m_InputO	= new CExplorationInput in this;
		}
		m_InputO.Initialize( this );
		
		
		if( !m_MoverO )
		{
			m_MoverO	= new CExplorationMover in this;
		}
		m_MoverO.Initialize( this );
		
		
		if( !m_CollisionManagerO )
		{
			m_CollisionManagerO	= new CExplorationCollisionManager in this;
		}
		m_CollisionManagerO.Initialize( this );
		
		if( !m_MovementCorrectorO )
		{
			m_MovementCorrectorO	= new CExplorationMovementCorrector in this;
		}
		m_MovementCorrectorO.Initialize( this );
		
		
		
		if( m_SharedDataO )
		{
			test	= true;
		}
		else
		{
			m_SharedDataO	= new CExplorationSharedData in this;
		}
		m_SharedDataO.Initialize( this );
		
		
		m_OwnerMAC.RegisterEventListener( this );
		
		
		
		
		
		
		if( !m_DefaultCameraSetS )
		{
			LogExplorationWarning( "There is no default camera parameters set, camera won't be set to defautl after each state change" );
		}
		RessetCameraOffset();
		
		
		GrabStateComponents();		
		
		
		
		Restart();
		
		
		m_InitializedB	= true;
		
		LogExploration( "Finished initialization" );
		LogExploration( "-----------------------------------------------------------------------------" );
		LogExploration( "-----------------------------------------------------------------------------" );
	}
	
	
	private function GrabStateComponents()
	{	
		var i							: int;
		var	l_StatesCountI				: int;
		var	l_ComponentsStateCArr		: array<CComponent>;
		var	l_ComponentsTransitionCArr	: array<CComponent>;
		var	l_TransitionO				: CExplorationStateTransitionAbstract;
		
		
		l_ComponentsStateCArr	= m_OwnerE.GetComponentsByClassName('CExplorationStateAbstract');		
		LogExploration( "Found " + l_ComponentsStateCArr.Size() + " Exploration states" );
		
		
		l_StatesCountI	= l_ComponentsStateCArr.Size() + 1;
		m_StatesSArr.Resize( l_StatesCountI );
		m_StateNamesSArr.Resize( l_StatesCountI );
		m_StatesUpdatedInactiveSArr.Clear();
		m_StatesSArr[c_InvalidStateI] = new CExplorationStateInvalid in this;
		m_StatesSArr[c_InvalidStateI].Initialize( this );
		
		
		for( i = 1; i < m_StatesSArr.Size(); i += 1 )
		{
			m_StatesSArr[i]	= ( CExplorationStateAbstract ) l_ComponentsStateCArr[i - 1];
			if( m_StatesSArr[i] )
			{
				m_StatesSArr[i].Initialize( this );
				
				m_StateNamesSArr[i] = m_StatesSArr[i].GetStateName();
				
				
				if( m_StatesSArr[i].m_UpdatesWhileInactiveB )
				{
					m_StatesUpdatedInactiveSArr.PushBack( m_StatesSArr[i] );
				}
			}
			else
			{
				LogExploration( "Wrong state: " + l_ComponentsStateCArr[i].GetName() );
			}
		}
		
		
		
		for( i = 0; i < m_StatesSArr.Size(); i += 1 )
		{
			m_StatesSArr[i].PostInitialize();
		}
		
		
		FindAndReportProblemsWithStates();
		
		
		for( i = 0; i < l_ComponentsStateCArr.Size(); i += 1 )
		{
			l_TransitionO	= ( CExplorationStateTransitionAbstract ) l_ComponentsStateCArr[i];
			
			if( l_TransitionO )
			{
				m_StateTransitionsSArr.PushBack( l_TransitionO );
			}
		}
		LogExploration( "Found : " + m_StateTransitionsSArr.Size() + " Transition states" );
	}
	
	
	private function FindAndReportProblemsWithStates()
	{
		var i : int;
		if( FindState( c_InvalidStateN ) != c_InvalidStateI )
		{
			LogExplorationError( "Invalid state should not be placed on the entity template" );
		}
		if( FindState( m_StateDefaultN ) == c_InvalidStateI )
		{
			LogExplorationError( "Missing default state" );
		}
		
		for( i = 1; i < m_StatesSArr.Size(); i += 1 )
		{
			if( m_StatesSArr[i].GetStateType() == EST_None )
			{
				LogExplorationError( m_StatesSArr[i].GetStateName() + ": Missing state type. Add it on the script of the state" );
			}
		}
	}
	
	
	private function FindState( stateName : name ) : int
	{
		var i : int;
		
		if( !IsNameValid( stateName ) )
		{
			return c_InvalidStateI;
		}
		
		for( i = 0; i < m_StatesSArr.Size(); i += 1 )
		{
			if( m_StatesSArr[i].GetStateName() == stateName )
			{
				return i;
			}
		}
		
		return c_InvalidStateI;
	}	
	
	
	public function Restart( )
	{	
		var i	: int;
		
		
		for( i = 0; i < m_StatesSArr.Size(); i += 1 )
		{
			m_StatesSArr[i].Restart();
		}
		
		m_StateBehCurReportedN	= 'None';
		
		m_StateGlobalQueuedN	= c_InvalidStateN;
		
		m_StateCurN				= c_InvalidStateN;
		m_StateCurI				= c_InvalidStateI;
		m_StateTimeCurF			= 0.0f;
		m_StateTimeLastF		= 0.0f;
		StateTryToChangeTo( m_StateDefaultN );
		
		
		m_SharedDataO.Reset();
		
		
		m_MoverO.Reset();
		
		
		m_SuperStateLastN	= '';
		
		
		theGame.ReleaseNoSaveLockByName( m_NoSaveLockStringS );
		LogChannel( 'ExplorationSave', "Unlock, resseted" );
		
		
		m_ActiveB	= true;
		
		LogExploration( "RESTARTED" );
	}
	
	
	
	
	
	
	event OnComponentTick ( _Dt : float )
	{
		Update( _Dt );
	}
	
	
	public function Update( _Dt : float )
	{
		var l_NewStateN	: name;
		
		
		
		UpdateSuperStateChange();		
		
		
		if( m_IsDebugModeB )
		{
			UpdateDebugInfo();
		}
		
		
		if( !m_ActiveB || !theGame.IsActive() || theGame.IsPaused() || theGame.GetPhotomodeEnabled() )
		{
			return;
		}		
		
		
		PreUpdate( _Dt );
		
		
		StateChangeUpdate();
		
		
		UpdateStates( _Dt );
		
		
		PostUpdate( _Dt );	
	}
	
	
	private function UpdateDebugInfo()
	{
		var auxString		: string;
		var auxName			: name;
		var weaponName		: string;
		var auxVector		: Vector;
		var auxFloat		: float;
		var textColor		: Color		= Color( 255,255,0 );
		var width			: int		= 200;
		var height			: int		= 10;
		var heightCur		: int;
		var heightInit		: int		= 400;
		var heightInactive	: int		= 300;
		var heightOffset	: int		= 15;
		var heightOffsetBig	: int		= 25;
		var left			: int		= 250;
		var right			: int		= 700;
		var leftFar			: int		= 200;
		var titleOffset		: int		= -30;
		var i				: int;
		
		
		
		heightCur	= heightInit;
		
		
		thePlayer.GetVisualDebug().AddBar( 'labelStates', right + titleOffset, heightCur, width, height, 0.0f, textColor, "States", 0.0f );
		
		heightCur	+= heightOffset;
		auxString	= "PlayerState: " + m_StateCurN;
		auxString	+= " " + m_StatesSArr[m_StateCurI].GetDebugText();
		if( !m_ActiveB )
		{
			auxString	+= " ( Inactive )";
		}
		thePlayer.GetVisualDebug().AddBar( 'PlayerState', right, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );
		
		heightCur	+= heightOffset;
		auxString	= "Last State: " + m_StateLastN	+ " time: " + m_StateTimeLastF;
		thePlayer.GetVisualDebug().AddBar( 'LastState', right, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );
		
		heightCur	+= heightOffset;
		thePlayer.GetVisualDebug().AddBar( 'SuperState', right, heightCur, width, height, 0.0f, textColor, "Super State: " + m_SuperStateLastN, 0.0f );
		
		heightCur	+= heightOffset;
		auxString	= m_OwnerMAC.GetPhysicalState();
		thePlayer.GetVisualDebug().AddBar( 'PhysicalState', right, heightCur, width, height, 0.0f, textColor, "Physical State: " + auxString, 0.0f );
		
		heightCur	+= heightOffset;
		thePlayer.GetVisualDebug().AddBar( 'IsInAir', right, heightCur, width, height, 0.0f, textColor, "IsInAir: " + thePlayer.IsInAir(), 0.0f );
		
		heightCur	+= heightOffset;
		thePlayer.GetVisualDebug().AddBar( 'HasGround', right, heightCur, width, height, 0.0f, textColor, "HasGround: " + m_IsOnGroundB, 0.0f );
		
		
		heightCur	+= heightOffset;
		auxString	= "Position: " + VecToStringPrec( m_OwnerE.GetWorldPosition(), 2 ) + "...Forward: " + VecToStringPrec( m_OwnerE.GetWorldForward(), 1 ) + "...Heading: " + m_OwnerE.GetHeading();
		thePlayer.GetVisualDebug().AddBar( 'PlayerPosAndForward', right, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );
		heightCur	+= heightOffset;
		thePlayer.GetVisualDebug().AddBar( 'VelocityLogic', right, heightCur, width, height, 0.0f, textColor, "Velocity Logic: " + m_MoverO.GetMovementSpeedF(), 0.0f );
		heightCur	+= heightOffset;
		thePlayer.GetVisualDebug().AddBar( 'VelocityMAC', right, heightCur, width, height, 0.0f, textColor, "Velocity MAC: " + VecLength( m_OwnerMAC.GetVelocity() ), 0.0f );
		heightCur	+= heightOffset;
		m_SmoothedVelocityV	= m_SmoothedVelocityV * 0.9 + m_OwnerMAC.GetVelocity() * 0.1f;
		thePlayer.GetVisualDebug().AddBar( 'Velocity2DMAC', right, heightCur, width, height, 0.0f, textColor, "Velocity2DMAC: " + VecLength2D( m_SmoothedVelocityV ), 0.0f );
		
		
		
		heightCur	+= heightOffsetBig;		
		thePlayer.GetVisualDebug().AddBar( 'labelCamera', right + titleOffset, heightCur, width, height, 0.0f, textColor, "Camera", 0.0f );
		
		heightCur	+= heightOffset;
		auxName		= theGame.GetGameCamera().GetActivePivotPositionController().controllerName;
		thePlayer.GetVisualDebug().AddBar( 'CamPivot', right, heightCur, width, height, 0.0f, textColor, "Camera Position controller: " + auxName, 0.0f );
		heightCur	+= heightOffset;
		auxName		= theGame.GetGameCamera().GetActivePivotRotationController().controllerName;
		thePlayer.GetVisualDebug().AddBar( 'CamRot', right, heightCur, width, height, 0.0f, textColor, "Camera Rotation controller: " + auxName, 0.0f );
		heightCur	+= heightOffset;
		auxName		= theGame.GetGameCamera().GetActivePivotDistanceController().controllerName;
		thePlayer.GetVisualDebug().AddBar( 'CamDist', right, heightCur, width, height, 0.0f, textColor, "Camera Distance controller: " + auxName, 0.0f );
		
		
		
		
		
		heightCur	+= heightOffsetBig;
		thePlayer.GetVisualDebug().AddBar( 'SavingEnabled', right + titleOffset, heightCur, width, height, 0.0f, textColor, "Save allowed: " + !theGame.AreSavesLocked(), 0.0f );
		
		
		heightCur	+= heightOffsetBig;
		thePlayer.GetVisualDebug().AddBar( 'Turn Adjustment', right + titleOffset, heightCur, width, height, 0.0f, textColor, "Turn adjusting: " + m_MovementCorrectorO.IsTurnAdjusted(), 0.0f );
		heightCur	+= heightOffset;
		thePlayer.GetVisualDebug().AddBar( 'Turn any Adjustment', right + titleOffset, heightCur, width, height, 0.0f, textColor, "Movement adjusting: " + m_OwnerMAC.GetMovementAdjustor().HasAnyActiveRequest(), 0.0f );
		
		
		
		heightCur	+= heightOffsetBig;
		thePlayer.GetVisualDebug().AddBar( 'labelIK', right + titleOffset, heightCur, width, height, 0.0f, textColor, "IK", 0.0f );
		
		heightCur	+= heightOffset;
		thePlayer.GetVisualDebug().AddBar( 'IK feet', right, heightCur, width, height, 0.0f, textColor, "IK Feet: " + m_OwnerMAC.GetEnabledFeetIK(), 0.0f );
		heightCur	+= heightOffset;
		thePlayer.GetVisualDebug().AddBar( 'IK Slide', right, heightCur, width, height, 0.0f, textColor, "IK slope: " + m_OwnerMAC.GetEnabledSlidingOnSlopeIK(), 0.0f );
		
		
		heightCur	+= heightOffsetBig;
		thePlayer.GetVisualDebug().AddBar( 'Label Correction', right + titleOffset, heightCur, width, height, 0.0f, textColor, "Correction", 0.0f );
		heightCur	+= heightOffset;
		auxString	=	"Corrected " +  m_MovementCorrectorO.GetDebugText();
		thePlayer.GetVisualDebug().AddBar( 'Correction', right, heightCur, width, height, 0.0f, textColor, auxString, 0.0f );
		
		
		
		heightCur	= heightInit;
		
		
		thePlayer.GetVisualDebug().AddBar( 'labelInput', left + titleOffset, heightCur, width, height, 0.0f, textColor, "Input", 0.0f );
		
		heightCur	+= heightOffset;
		thePlayer.GetVisualDebug().AddBar( 'InputContext', left, heightCur, width, height, 0.0f, textColor, "Input context: " + theInput.GetContext(), 0.0f );
		
		
		heightCur	+= heightOffset;
		thePlayer.GetVisualDebug().AddBar( 'labelWeapons', left + titleOffset, heightCur, width, height, 0.0f, textColor, "Weapons", 0.0f );
		
		if( thePlayer.IsWeaponHeld('fist') )
		{
			weaponName	= "fist";
		}
		else if( thePlayer.IsWeaponHeld('silversword') )
		{
			weaponName	= "silversword";
		}
		else if( thePlayer.IsWeaponHeld('steelsword') )
		{
			weaponName	= "steelsword";
		}
		else
		{
			weaponName	= "None";
		}
		heightCur	+= heightOffset;
		thePlayer.GetVisualDebug().AddBar( 'LeftHandI', left, heightCur, width, height, 0.0f, textColor, "Item Weapon: " + weaponName, 0.0f );
		heightCur	+= heightOffset;
		thePlayer.GetVisualDebug().AddBar( 'LeftHandL', left, heightCur, width, height, 0.0f, textColor, "Logic Weapon: " + thePlayer.GetCurrentMeleeWeaponName(), 0.0f );
		
		
		
		heightCur	+= heightOffsetBig;
		thePlayer.GetVisualDebug().AddBar( 'labelSlide', left + titleOffset, heightCur, width, height, 0.0f, textColor, "Slide", 0.0f );
		
		
		heightCur	+= heightOffset;
		thePlayer.GetVisualDebug().AddBar( 'TerrainMaterial', left, heightCur, width, height, 0.0f, Color(255,255,0), "Material: " + m_OwnerMAC.GetMaterialName(), 0.0f );
		heightCur	+= heightOffset;
		auxString	= "Preset: " + m_SharedDataO.terrainSlidePresetName;
		auxString	+= " : SlideMin " + m_MoverO.ConvertCoefToAngleDegree( m_MoverO.GetSlidingLimitMinCur() ) ;
		auxString	+= ", SlideMax " + m_MoverO.ConvertCoefToAngleDegree( m_MoverO.GetSlidingLimitMax() );
		thePlayer.GetVisualDebug().AddBar( 'TerrainPreset', left, heightCur, width, height, 0.0f, Color(255,255,0), auxString, 0.0f );
		
		
		heightCur	+= heightOffset;
		auxFloat	= m_MoverO.GetRealSlideAngle( );
		thePlayer.GetVisualDebug().AddBar( 'RawSlideAngle', left, heightCur, width, height, 0.0f, Color(255,255,0), "Real raw terrain angle: " + auxFloat, 0.0f );
		heightCur	+= heightOffset;
		auxFloat	= m_MoverO.GetRealWideSlideAngle();
		auxFloat	= m_MoverO.ConvertCoefToAngleDegree( auxFloat );
		thePlayer.GetVisualDebug().AddBar( 'RawWideSlideAngle', left, heightCur, width, height, 0.0f, Color(255,255,0), "Real raw wide terrain angle: " + auxFloat, 0.0f );
		
		
		heightCur	+= heightOffsetBig;
		auxFloat	= m_OwnerMAC.GetSlideCoef();
		thePlayer.GetVisualDebug().AddBar( 'SlideCoefDamp', left, heightCur, width, height, 0.0f, textColor, "Slide coef damped: " + auxFloat, 0.0f );
		heightCur	+= heightOffset;
		auxFloat	= m_MoverO.GetSlideCoefFromTerrain();
		thePlayer.GetVisualDebug().AddBar( 'SlideCoefInst', left, heightCur, width, height, 0.0f, textColor, "Slide coef instant: " + auxFloat, 0.0f );
		
		
		heightCur	+= heightOffset;
		auxFloat	= m_MoverO.GetSlideWideCoefFromTerrain( true );
		auxVector	= m_MoverO.m_WideNormalAverageV;
		thePlayer.GetVisualDebug().AddBar( 'NormalWideAVG', left, heightCur, width, height, 0.0f, Color(255,255,0), "Normal coef Wide AVG: " + auxFloat + " " + VecToString( auxVector ), 0.0f );
		heightCur	+= heightOffset;
		auxFloat	= m_MoverO.GetSlideWideCoefFromTerrain( false );
		auxVector	= m_MoverO.m_WideNormalGlobalV;
		thePlayer.GetVisualDebug().AddBar( 'NormalWideGlbl', left, heightCur, width, height, 0.0f, Color(255,255,0), "Normal coef Wide Global: " + auxFloat + " " + VecToString( auxVector ), 0.0f );
		
		
		heightCur	+= heightOffset;
		auxVector	= m_OwnerMAC.GetTerrainNormal( true );
		thePlayer.GetVisualDebug().AddBar( 'NormalDamped', left, heightCur, width, height, 0.0f, textColor, "Normal coef damped: " + auxVector.Z, 0.0f );
		heightCur	+= heightOffset;
		auxVector	= VecNormalize( m_OwnerMAC.GetTerrainNormal( false ) );
		thePlayer.GetVisualDebug().AddBar( 'NormalInstant', left, heightCur, width, height, 0.0f, textColor, "Normal coef Instant: " + auxVector.Z, 0.0f );
		
		
		heightCur	= heightInactive;
		heightCur	= m_SharedDataO.DrawDebugText( leftFar, heightCur, heightOffset, width, height, textColor );
		
		
		for( i = 0; i < m_StatesSArr.Size(); i += 1 )
		{
			auxString	= m_StatesSArr[i].GetDebugTextInactive();
			
			if( auxString != "" )
			{ 
				heightCur	+= heightOffset;
				auxName	= m_StatesSArr[i].GetStateName();
				thePlayer.GetVisualDebug().AddBar( auxName, leftFar, heightCur, width, height, 0.0f, textColor, auxName + auxString, 0.0f );
			}
		}
		
		
		DebugDisplayActionLocks();
		
		
		m_CollisionManagerO.UpdateDebugInfo();
	}
	
	
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags )
	{
		var i	: int;
		
		for( i = 0; i < m_StatesSArr.Size(); i += 1 )
		{
			m_StatesSArr[i].OnVisualDebug( frame, flag, i == m_StateCurI );
		}
		
		m_MovementCorrectorO.OnVisualDebug( frame, flag );
		m_CollisionManagerO.OnVisualDebug( frame, flag );
		
		frame.DrawSphere( m_DebugPointV, 0.2f, Color( 100, 100, 100 ) );
		
		return true;
	}
	
	
	public function SetDebugPoint( point : Vector )
	{
		m_DebugPointV	= point;
	}
	
	
	private function DebugDisplayActionLocks()
	{
		var actionLocks	: array< array< SInputActionLock > >;
		var numLocks	: int;
		var	i, j		: int;
		
		var	heightCur	: int		= 215;
		var textColor	: Color;
		var auxString	: string;
		var	auxName		: name;
		
		
		actionLocks	= thePlayer.GetAllActionLocks();
		
		thePlayer.GetVisualDebug().AddBar( 'CurrentInputLocks', 5, 200, 300, 15, 0.0f, textColor, "======Current Input Locks======", 0.0f );
		
		for( i = 0; i < actionLocks.Size(); i += 1 )
		{
			
			auxString	= ( string ) ( ( EInputActionBlock ) i );
			auxString	= auxString + ":        ";
			auxName		= GetAuxNameForInt( i );
			for( j = 0; j < actionLocks[i].Size(); j += 1 )
			{
				auxString	+= actionLocks[i][j].sourceName + ", ";
				thePlayer.GetVisualDebug().AddBar( auxName, 5, heightCur, 300, 15, 0.0f, textColor, auxString, 0.0f );
				heightCur	+= 15;
			}
			if (actionLocks[i].Size() < 1)
			{
				thePlayer.GetVisualDebug().RemoveBar( auxName );
			}
		}
	}
	
	
	private function GetAuxNameForInt( i : int ) : name
	{
		switch( i )
		{
			case 0: return 'IntName 0';
			case 1: return 'IntName 1';
			case 2: return 'IntName 2';
			case 3: return 'IntName 3';
			case 4: return 'IntName 4';
			case 5: return 'IntName 5';
			case 6: return 'IntName 6';
			case 7: return 'IntName 7';
			case 8: return 'IntName 8';
			case 9: return 'IntName 9';
			case 10: return 'IntName 10';
			case 11: return 'IntName 11';
			case 12: return 'IntName 12';
			case 13: return 'IntName 13';
			case 14: return 'IntName 14';
			case 15: return 'IntName 15';
			case 16: return 'IntName 16';
			case 17: return 'IntName 17';
			case 18: return 'IntName 18';
			case 19: return 'IntName 19';
			case 20: return 'IntName 20';
			case 21: return 'IntName 21';
			case 22: return 'IntName 22';
			case 23: return 'IntName 23';
			case 24: return 'IntName 24';
			case 25: return 'IntName 25';
			case 26: return 'IntName 26';
			case 27: return 'IntName 27';
			case 28: return 'IntName 28';
			case 29: return 'IntName 29';
			case 30: return 'IntName 30';
			case 31: return 'IntName 31';
			case 32: return 'IntName 32';
			case 33: return 'IntName 33';
			case 34: return 'IntName 34';
			case 35: return 'IntName 35';
			case 36: return 'IntName 36';
			case 37: return 'IntName 37';
			case 38: return 'IntName 38';
			case 39: return 'IntName 39';
			case 40: return 'IntName 40';
			case 41: return 'IntName 41';
			case 42: return 'IntName 42';
			case 43: return 'IntName 43';
			case 44: return 'IntName 44';
			case 45: return 'IntName 45';
			case 46: return 'IntName 46';
			case 46: return 'IntName 47';
			case 46: return 'IntName 48';
			case 46: return 'IntName 49';
			case 46: return 'IntName 50';
			case 46: return 'IntName 51';
			case 46: return 'IntName 52';
			case 46: return 'IntName 53';
		}
	}
	
	
	private function UpdateSuperStateChange()
	{
		var l_CurrentSuperStateN	: name;
		
		
		l_CurrentSuperStateN	= thePlayer.GetCurrentStateName();
		
		if( m_SuperStateLastN != l_CurrentSuperStateN )
		{
			SuperStateChanged( m_SuperStateLastN, l_CurrentSuperStateN );
			
			m_SuperStateLastN	= l_CurrentSuperStateN;
		}
	}
	
	
	
	private function SuperStateChanged( stateExiting, stateEntering : name )
	{
		var l_WasActiveB	: bool;
		
		l_WasActiveB	= m_ActiveB;
		m_ActiveB		= true;
		
		LogExploration( "Changed SuperState from : " + stateExiting + " to " + stateEntering );
		
		
		
		if( stateExiting == 'TraverseExploration' )
		{
			if( m_CollisionManagerO.CheckLandBelow( 0.3f ) )
			{
				m_TeleportedFallHackTime	= m_TeleportedFallHackTimeTotalF;
			}
		}
		
		
		
		if( stateEntering == 'TraverseExploration' )
		{
			StateTryToChangeTo( 'Interaction' );
		}
		
		else if( IsThisACombatSuperState( stateEntering ) )
		{
			StateTryToChangeOrFallToDefault( 'CombatExploration' );
		}
		
		else if( stateEntering == 'Skating' )
		{
			StateTryToChangeOrFallToDefault( 'SkateIdle' );
		}
		
		else if( stateEntering == 'Exploration' )
		{
			
			if( !l_WasActiveB )
			{
				StateTryToChangeTo( m_StateDefaultN );
			}
			
			
			
			if( stateExiting == 'PlayerDialogScene' )
			{
				m_TeleportedFallHackTime	= m_TeleportedFallHackTimeTotalF;
			}
			
			
			else if( IsThisACombatSuperState( stateExiting ) )
			{	
				if( m_StateCurN != 'Jump' && m_StateCurN != 'Slide' )
				{
					StateTryToChangeTo( m_StateDefaultN );	
					
				}
			}
			
			else if( stateExiting == 'Swimming' && GetStateCur() == 'Climb' )
			{
				
			}
			
			else if( stateExiting == 'TraverseExploration' && m_SharedDataO.HasToFallFromLadder() )
			{
				StateTryToChangeOrFallToDefault( 'Jump' );
			}
			
			else if( stateExiting != 'AimThrow' )
			{
				StateTryToChangeTo( m_StateDefaultN );
			}
		}
		else if( stateEntering == 'Swimming' )
		{
			StateTryToChangeOrFallToDefault( 'Swim' );
		}
		else if( !thePlayer.OnStateCanUpdateExplorationSubstates() )
		{
			m_ActiveB	= false;
		}
	}
	
	
	public function IsThisACombatSuperState( stateName : name ) : bool
	{
		return thePlayer.IsThisACombatSuperState( stateName );
	}
	
	
	private function PreUpdate( _Dt : float )
	{
		
		m_InputO.Update( _Dt );
		
		
		m_MoverO.PreUpdate( _Dt );
		m_SharedDataO.PreUpdate( _Dt );
		m_MovementCorrectorO.PreUpdate( _Dt );
		
		
		UpdateExternalData( _Dt );
	}
	
	
	private function UpdateExternalData( _Dt : float )
	{
		var isOnGroundNow	: bool;
		
		
		
		if( m_TeleportedFallHackTime > 0.0f )
		{
			return;
		}
		
		
		m_CollisionManagerO.Update( _Dt );
		
		
		isOnGroundNow	= m_OwnerMAC.IsOnGround();
		
		
		if( isOnGroundNow != m_IsOnGroundB )
		{
			if( m_IsDebugModeB )
			{			
				if( isOnGroundNow )
				{
					LogExploration( "StateManager : HitGround at pos" + VecToStringPrec( m_OwnerE.GetWorldPosition(), 3 ) );
				}
				else
				{
					LogExploration( "StateManager : LostGround at pos" + VecToStringPrec( m_OwnerE.GetWorldPosition(), 3 ) );
				}
			}
			m_IsOnGroundB	= isOnGroundNow;
		}
		
		
		if( !isOnGroundNow )
		{
			if( m_StatesSArr[m_StateCurI].ReactToLoseGround() )
			{
				return;
			}
			
			QueueState( 'StartFalling' );
		}	
		else
		{
			if( m_StatesSArr[m_StateCurI].ReactToHitGround() )
			{
				return;
			}
		}
	}
	
	
	public function ReactOnHitCeiling()
	{
		m_StatesSArr[m_StateCurI].ReactToHitCeiling();
	}
	
	
	public function ReactToChanceToFallAndSlide() : bool
	{
		return m_StatesSArr[m_StateCurI].ReactToChanceToFallAndSlide();
	}
	
	
	private function StateChangeUpdate( )
	{
		var l_NewStateN			: name;
		var stateChanged		: bool	= false;
		
		
		
		if(  m_TeleportedFallHackTime > 0.0f )
		{
			return;
		}
		
		
		UpdateStateChangesFromBehavior();		
		
		
		UpdateStateChangesConfirmation();
		
		
		UpdateStateChangesQueued();
		
		
		UpdateStateChangesInProperState();
	}
	
	
	private function UpdateStateChangesFromBehavior() : bool
	{
		var stateName		: name;
		var stateChanged	: bool	= false;
		
		
		if( m_StateEnteredFromBehN != c_InvalidStateN && IsNameValid( m_StateEnteredFromBehN ) )
		{
			stateChanged	= StateTryToChangeOrFallToDefault( m_StateEnteredFromBehN );
			LogExploration("State changed from the Behavior graph");
		}
		
		
		else if( !stateChanged && m_StateExitedFromBehN != c_InvalidStateN &&  IsNameValid( m_StateExitedFromBehN ) )
		{
			stateName		= m_StatesSArr[m_StateCurI].GetStateToExitToAfterFailing();
			stateChanged	= StateTryToChangeOrFallToDefault( stateName );
			LogExploration("State changed by: exiting the Behavior graph node");
		}
		
		
		m_StateEnteredFromBehN	= c_InvalidStateN;
		m_StateExitedFromBehN	= c_InvalidStateN;
		
		
		return stateChanged;
	}

	
	private function UpdateStateChangesConfirmation() : bool
	{
		var stateChanged	: bool	= false;
		
		switch( m_BehaviorConfirmStateE )
		{
			case BGCS_None:
				break;
			case BGCS_Waiting:
				m_BehaviorConfirmStateE	= BGCS_NotConfirmed;
				break;
			case BGCS_Confirmed:
				m_StatesSArr[m_StateCurI].StateEnterConfirmed();
				m_BehaviorConfirmStateE	= BGCS_None;
				break;
			case BGCS_NotConfirmed:
				stateChanged			=  BehaviorConfirmationFailedChange();
				m_BehaviorConfirmStateE	= BGCS_None;
				break;
		}
		
		return stateChanged;
	}
	
	
	private function BehaviorConfirmationFailedChange() : bool
	{
		var stateName		: name;
		var stateChanged	: bool	= false;
		
		if( m_StatesSArr[m_StateCurI].NeedsBehaviorConfirmation() )
		{
			LogExplorationError( m_StatesSArr[m_StateCurI].GetStateName() + ": FAILED CONFIRMATION: behavior graph node was not entered. "
								+ "this CExplorationState needs a node of type ScriptState in the behavior graph (So it is marked on the state variables), "
								+ " and it has to have the same name than the CExplorationState and the notification on enter and exit called 'Enter' and 'Exit'." );
			
			stateName		= m_StatesSArr[m_StateCurI].GetStateToExitToAfterFailing();
			stateChanged	= StateTryToChangeOrFallToDefault( stateName );	
			
			if( stateChanged )
			{
				LogExploration("State changed by: Missing behaviour node confirmation");		
			}
		}
		else
		{		
			LogExploration( m_StateCurN + ": CONFIRMATION NOT NEEDED, so it is set on the property" );
		}
		
		return stateChanged;
	}
	
	
	private function UpdateStateChangesQueued() : bool
	{
		var stateChanged	: bool	= false;
		
		
		if( m_StateGlobalQueuedN != c_InvalidStateN )
		{
			if( !StateTryToChangeTo( m_StateGlobalQueuedN ) )
			{
				LogExplorationError( "Queued state change fail: " + m_StateGlobalQueuedN );
			}
			else
			{			
				LogExploration( "State changed by: State queued " );
				stateChanged	= true;
			}
			
			m_StateGlobalQueuedN	= c_InvalidStateN;
		}
		
		return stateChanged;
	}
	
	
	private function UpdateStateChangesInProperState() : bool
	{
		var l_NewStateN		: name;
		var stateChanged	: bool	= false;
		
		
		l_NewStateN	= m_StatesSArr[m_StateCurI].StateChangePrecheck();
		
		
		while ( l_NewStateN != m_StateCurN )
		{
			
			
			if( !StateTryToChangeTo( l_NewStateN ) )
			{
				if( m_IsDebugModeB )
				{
					LogExplorationError( "State could not be changed: " + m_StateCurN + " -> " + l_NewStateN 
										+ ", this should be checked inside the state itself on the StateChangePrecheck ");
				}
				break;
			}
			
			
			
			l_NewStateN		= m_StatesSArr[m_StateCurI].StateChangePrecheck();
			
			stateChanged	= true;
			LogExploration("State changed by: The state change precheck");
		}
		
		return stateChanged;
	}
	
	
	private function UpdateStates( _Dt : float )
	{		
		
		m_StatesSArr[m_StateCurI].StateUpdate( _Dt );	
		
		
		UpdateInactiveStates( _Dt );
	}
	
	
	private function PostUpdate( _Dt : float )
	{	
		
		if( m_StateChanged )
		{		
			PostStateChange();
		}
		
		
		m_MoverO.ApplyMovement( _Dt );
		
		
		if( m_StatesSArr[ m_StateCurI ].IsRaisingBehaviorEventEachFrame() )
		{
			TryToSetTheProperBehaviorState();
		}
		
		m_InputO.PostUpdate( _Dt );
		m_MoverO.PostUpdate( _Dt );
		m_SharedDataO.PostUpdate( _Dt );
		m_MovementCorrectorO.PostUpdate( _Dt );
		
		
		m_TeleportedFallHackTime	-= _Dt;
		
		
		m_StateTimeCurF	+= _Dt;
	}	
	
	
	private function StateTryToChangeOrFallToDefault( newState :name ) : bool
	{
		
		if( newState == m_StateCurN )
		{
			return true;
		}
		
		
		if( StateTryToChangeTo( newState ) )
		{
			return true;
		}
		
		LogExploration( "StateTryToChangeOrFallToDefault: Could not enter to " + newState + "Trying to go to default" );
		
		
		if( StateTryToChangeTo( m_StateDefaultN ) )
		{
			return true;
		}
		else if( m_StateDefaultN != m_StateCurN )
		{
			LogExplorationError( "Can't enter to defautl state, THIS IS BAD" );
		}
		
		
		return false;
	}
	
	
	private function StateTryToChangeTo( _NewStateN : name ) : bool
	{		
		
		if( !CanChangeBetwenStates( m_StateCurN, _NewStateN ) )
		{
			return false;
		}
		
		
		ChangeToStateWithTransition( _NewStateN );
		
		
		return true;
	}
	
	
	private function ChangeToStateWithTransition( _NewStateN : name )
	{
		var l_NewStateID		: int;
		var l_NewTransitionID	: int;
		var l_NewTransitionN	: name;
		
		
		if( FindTransitionThatCanPlay( m_StateCurN, _NewStateN, l_NewTransitionID, l_NewTransitionN ) )
		{
			_NewStateN		= l_NewTransitionN;
		}
		
		
		ChangeStateTo( _NewStateN );
	}
	
	
	public function CanChangeToState( _ToN : name ) : bool
	{	
		return CanChangeBetwenStates( m_StateCurN, _ToN );
	}
	
	
	public function CanChangeBetwenStates( _FromN, _ToN : name ) : bool
	{
		var l_FromID	: int;
		var l_ToID		: int;
		
		
		
		if( _ToN	!= m_StateDefaultN )
		{
			if( thePlayer.IsInNonGameplayCutscene() )
			{
				return false;
			}
		}
		
		
		l_FromID	= GetStateID( _FromN );
		l_ToID		= GetStateID( _ToN );
		
		
		
		if( _ToN == _FromN )
		{
			LogExploration( "Trying to go to the same state: " + _ToN );
			return false;
		}
		
		
		if( l_ToID == c_InvalidStateI )
		{ 
			LogExploration( "Trying to go to the unexistent state: " + _ToN );
			
			
			return false;
			
		}
		
		
		if( !m_StatesSArr[l_ToID].StateCanEnter( _FromN ) )
		{
			
			
			return false;
		}
		
		
		return true;
	}
	
	
	public function StateWantsAndCanEnter( desiredState : name ) : bool
	{
		var stateID : int;
		
		if( CanChangeBetwenStates( m_StateCurN, desiredState ) )
		{
			stateID	= GetStateID( desiredState );
			if( m_StatesSArr[stateID].StateWantsToEnter() )
			{
				return true;
			}
		}
		
		return false;
	}
	
	
	private function FindTransitionThatCanPlay( _FromN, _ToN : name, out _TransitionI : int, out _TransitionNameN : name ) : bool
	{	
		
		if( !FindTransition( _FromN, _ToN, _TransitionI, _TransitionNameN ) )
		{ 
			return false;
		}
		
		
		
		return true;
	}
	
	
	private function FindTransition( _FromN, _ToN : name, out _TransitionI : int, out _TransitionNameN : name ) : bool
	{
		var i 		: int;
		var l_SizeI	: int;
		
		
		l_SizeI	= m_StateTransitionsSArr.Size();
		
		for( i = 0; i < l_SizeI; i += 1 )
		{
			if( m_StateTransitionsSArr[i].IsMachForThisStates( _FromN, _ToN ) )
			{
				_TransitionI		= i;
				_TransitionNameN	= m_StateTransitionsSArr[i].GetStateName();
				
				if( IsNameValid( _TransitionNameN ) )
				{
					if( CanWePlayTransition( _FromN, _ToN , _TransitionNameN ) )
					{
						return true;
					}
				}
			}
		}
		
		return false;
	}

	
	private function CanWePlayTransition( _FromN, _ToN , _TransitionNameN : name) : bool
	{
		LogExploration( "Found Transition: " + _TransitionNameN + ": " + _FromN + " --> " + _ToN );
		
		
		if( CanChangeBetwenStates( _FromN, _TransitionNameN ) )
		{		
			LogExploration( "Transition will be played'" );	
			
			return true;
		}
		
		return false;
	}
	
	
	private function ChangeStateTo( _NewStateN : name )
	{		
		var l_NewStateID		: int;
		
		
		l_NewStateID		= GetStateID( _NewStateN );
		
		
		m_StatesSArr[m_StateCurI].StateExit( _NewStateN );
		
		m_StatesSArr[l_NewStateID].StateEnter( m_StateCurN );
		
		
		m_StateLastI		= m_StateCurI;
		m_StateLastN		= m_StateCurN;
		
		m_StateCurI			= l_NewStateID;
		m_StateCurN			= _NewStateN;
		
		m_StateTimeLastF	= m_StateTimeCurF;
		m_StateTimeCurF		= 0.0f;
		
		
		m_StateChanged	= true;		
	}
	
	
	public function StateExited()
	{
		RessetCameraOffset();
	}
	
	
	private function PostStateChange()
	{		
		var l_StateTypeE : EExplorationStateType;
		
		
		TryToSetTheProperBehaviorState();
		
		
		
		m_BehaviorConfirmStateE	= BGCS_Waiting;
		
		
		
		SetCamera();
		
		
		
		switch( m_StatesSArr[ m_StateCurI ].m_InputContextE )
		{
			case EGCI_Ignore:
				break;
			case EGCI_Exploration:
				theInput.SetContext( thePlayer.GetExplorationInputContext() ); 
				break;
			case EGCI_JumpClimb:
				theInput.SetContext( 'JumpClimb' );
				break;	
			case EGCI_Combat:
				theInput.SetContext( thePlayer.GetCombatInputContext() ); 
				break;
			case EGCI_Swimming:
				theInput.SetContext( 'Swimming' );
				break;		
		}
		
		
		
		if( !m_StatesSArr[ m_StateCurI ].GetCanSave() ) 
		{		
			theGame.CreateNoSaveLock( m_NoSaveLockStringS, m_NoSaveLock, true ); 
			LogChannel( 'ExplorationSave', "Lock, state " + m_StateCurN );
		}
		else 
		{
			theGame.ReleaseNoSaveLockByName( m_NoSaveLockStringS );
			LogChannel( 'ExplorationSave', "Unlock, state  " + m_StateCurN );
		}
		
		
		
		SetBehaviorParamBool( 'holsterFastForced', m_StatesSArr[ m_StateCurI ].IsHolsterFast(), true );
		
		
		
		l_StateTypeE = m_StatesSArr[ m_StateCurI ].GetStateType();
		
		if ( l_StateTypeE != EST_Unchanged )
		{
			thePlayer.SetIsInAir( l_StateTypeE == EST_OnAir );
		}
		
		
		
		m_StateChanged	= false;
	}
	
	
	private function SetCamera()
	{
		var cameraSet		: CCameraParametersSet;
		var cameraSetLast	: CCameraParametersSet; 
		
		
		if( m_StatesSArr[m_StateCurI].m_ChangeCamerasB )
		{
			
			if( m_StatesSArr[m_StateCurI].GetIfCameraIsKept() )
			{
				return;
			}
			
			
			if( m_StatesSArr[m_StateLastI].GetCameraSet( cameraSetLast ) )
			{			
				cameraSetLast.StopOnMainCamera();
			}
			
			
			if( m_StatesSArr[m_StateCurI].GetCameraSet( cameraSet ) )
			{
				if( cameraSetLast )
				{
					cameraSet.SetToMainCamera( cameraSetLast.pivotPosForcedBlendOnNext );
				}
				else
				{
					cameraSet.SetToMainCamera( 0.0f );
				}				
			}
			
			
			else if( m_DefaultCameraSetS )
			{
				if( cameraSetLast ) 
				{
					m_DefaultCameraSetS.SetToMainCamera( cameraSetLast.pivotPosForcedBlendOnNext );
				}
				else
				{
					m_DefaultCameraSetS.SetToMainCamera( 0.0f );
				}
			}
		}
	}
	
	
	
	private function TryToSetTheProperBehaviorState()
	{
		var l_BehaviorEventN	: name;
		var l_EventIsForcedB	: bool;
		var l_eventResult		: bool;
		
		
		
		
		
		if( m_StatesSArr[m_StateCurI].IsRaisingBehaviorEvent() )
		{
			l_BehaviorEventN	= m_StatesSArr[m_StateCurI].GetBehaviorEventName();
			l_EventIsForcedB	= m_StatesSArr[m_StateCurI].GetBehaviorIsEventForced( m_StateLastN );
			l_eventResult = SendAnimEvent( l_BehaviorEventN, l_EventIsForcedB );
		}
	}
	
	
	private function UpdateInactiveStates( _Dt : float )
	{
		var i	: int;
		
		for( i = 0; i < m_StatesUpdatedInactiveSArr.Size(); i +=1 )
		{
			if( m_StatesUpdatedInactiveSArr[i].GetStateName() != m_StateCurN )
			{
				m_StatesUpdatedInactiveSArr[i].StateUpdateInactive( _Dt );
			}
		}
	}

	
	private function QueueState( newState : name )
	{
		m_StateGlobalQueuedN	= newState;
		LogExploration( "Queued state : " + newState );
	}

	
	public function QueueStateExternal( newState : name )
	{
		m_StateGlobalQueuedN	= newState;
		LogExplorationWarning( "Externaly Queued state : " + newState );
	}
	
	
	
	
	
	
	event OnRagdollStart()
	{
		var actor : CActor;
		var currentPri : EInteractionPriority;

		
		actor = (CActor)m_OwnerE;
		currentPri = actor.GetInteractionPriority();
		if ( actor.IsAlive() && currentPri != IP_Max_Unpushable )
		{
			m_storedInteractionPri = currentPri;
			actor.SetInteractionPriority( IP_Max_Unpushable );
		}
	}
	
	
	event OnNoLongerInRagdoll()
	{
		var actor : CActor;
		
		
		actor = (CActor)m_OwnerE;
		if ( actor.IsAlive() && m_storedInteractionPri != IP_NotSet )
		{
			actor.SetInteractionPriority( m_storedInteractionPri );
			m_storedInteractionPri = IP_NotSet;
		}
	}
	
	
	event OnRagdollTouch( entity : CEntity )
	{
		var actor : CActor;
		
		actor = (CActor)entity;
		if ( actor )
		{
			LogExploration( "on ragdoll touch - " + actor.IsAlive() );
			m_OwnerMAC.SetRagdollPushingMul( actor.IsAlive() ? 0.0f : 0.01f );
		}
	}
	
	
	event OnPrediction( pos : Vector, normal : Vector, disp : Vector, penetration : Float, actorHeight : Float, diffZ : Float, fromVirtualController : bool )
	{
		
	}
	
	
	
	
	
	
	public function SendAnimEvent( eventName : name, optional forced : bool ) : bool
	{
		var res : bool;

		
		if( forced )
		{
			return m_OwnerE.RaiseForceEvent( eventName );
		}
		else
		{
			return m_OwnerE.RaiseEvent( eventName );		
		}
	}
	
	
	public function SetBehaviorParamBool( paramName : name, value : bool, optional onAllInstances : bool )
	{
		if( value )
		{
			m_OwnerE.SetBehaviorVariable( paramName, 1.0f, onAllInstances );
		}
		else
		{
			m_OwnerE.SetBehaviorVariable( paramName, 0.0f, onAllInstances );
		}
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{		
		
		m_StatesSArr[m_StateCurI].OnAnimEvent( animEventName, animEventType, animInfo );
		
		
		m_SharedDataO.OnAnimEvent( animEventName, animEventType, animInfo );
		m_MovementCorrectorO.OnAnimEvent( animEventName, animEventType, animInfo );
	}
	
	
	event OnBehaviorGraphNotification( notificationName : name, stateName : name )
	{
		var	i : int;
		
		
		if( notificationName == 'StartTurnAdjustment' )
		{
			m_MovementCorrectorO.StartTurnAdjustment();
		}
		else if(  notificationName == 'CancelTurnAdjustment' )
		{
			m_MovementCorrectorO.CancelTurnAdjustment();
		}
		
		
		else if( !m_StatesSArr[m_StateCurI].IsRaisingBehaviorEventEachFrame() )
		{
			if( notificationName == 'Exit' ) 
			{		
				
				m_StatesSArr[m_StateCurI].OnBehGraphNodeExited();
				
				
				if( !m_StatesSArr[m_StateCurI].IsRaisingBehaviorEvent() || !m_StatesSArr[m_StateCurI].NeedsBehaviorConfirmation() )
				{
					return true;
				}
				
				
				if( stateName	== m_StateCurN ) 
				{
					m_StateExitedFromBehN	= m_StateCurN;
					
					LogExplorationWarning( m_StateCurN + ": FORCING EXIT, The behavior graph node of this state left by its own" );
				}
				
				
				if( stateName	== m_StateCurN && m_BehaviorConfirmStateE == BGCS_Confirmed )
				{
					LogExplorationWarning( m_StateCurN + ": DECONFIRMED, exited by the Behavior graph node");
					m_BehaviorConfirmStateE	= BGCS_NotConfirmed;
				}	
				
				
				if( stateName == m_StateEnteredFromBehN )
				{
					LogExplorationWarning( stateName + ": FORCED ENTER CANCELLED, the state was reentered on the same frame" );
					
					m_StateExitedFromBehN	= c_InvalidStateN;
					m_StateEnteredFromBehN	= c_InvalidStateN;
				}
				if( m_StateBehCurReportedN == stateName )
				{
					m_StateBehCurReportedN	= 'None';
				}
			}
			
			else if( notificationName == 'Enter' )
			{
				
				m_StatesSArr[m_StateCurI].OnBehGraphNodeEntered();
				
				
				if( !m_StatesSArr[GetStateID(stateName)].IsRaisingBehaviorEvent() || !m_StatesSArr[GetStateID(stateName)].NeedsBehaviorConfirmation() )
				{
					return true;
				}
				
				
				if( stateName == m_StateExitedFromBehN )
				{
					LogExplorationWarning( stateName + ": FORCED EXIT CANCELLED, the state was reentered on the same frame" );
					
					m_StateExitedFromBehN	= c_InvalidStateN;
					m_StateEnteredFromBehN	= c_InvalidStateN;
				}
				
				
				if( stateName	== m_StateCurN )
				{
					LogExploration( m_StateCurN + ": CONFIRMED, enter by the Behavior graph node" );
					m_BehaviorConfirmStateE	= BGCS_Confirmed;
				}		
				
				
				else 
				{
					for( i = 0; i < m_StatesSArr.Size(); i += 1 )
					{
						if( m_StateCurI != i && stateName	== m_StatesSArr[i].GetStateName() )
						{
							m_StateEnteredFromBehN	= stateName;
							LogExplorationWarning( m_StatesSArr[i].GetStateName() + ": FORCING ENTER, The Behavior graph node of this state entered by itself" );
						}
					}
				}
				m_StateBehCurReportedN	= stateName;
			} 
		}
	}
	
	
	
	function OnTeleported()
	{
		
		
		m_SharedDataO.OnTeleported();
		m_MoverO.OnTeleported();
		
		
		
		m_TeleportedFallHackTime	= m_TeleportedFallHackTimeTotalF;
		
	}
	
	
	function ReactOnBeingHit( optional damageAction : W3DamageAction ) : bool
	{
		if( m_ActiveB )
		{			
			
			if( m_StatesSArr[ m_StateCurI ].ReactToBeingHit( damageAction ) )
			{
				return true;
			}
		}
		
		
		return false;
	}
	
	
	function ReactOnCriticalState( enabled : bool )
	{
		if( m_ActiveB )
		{
			
			if( m_StatesSArr[ m_StateCurI ].ReactToCriticalState( enabled ) )
			{
				return;
			}
		}
		
		if( enabled )
		{
			StateTryToChangeTo( 'Ragdoll' );
		}
	}
	
	
	
	
	
	
	function UpdateCameraIfNeeded( out moveData : SCameraMovementData, dt : float ) : bool
	{
		
		return m_StatesSArr[m_StateCurI].UpdateCameraIfNeeded( moveData, dt);
	}
	
	
	
	event OnGameCameraExplorationRotCtrlChange()
	{
		
		if( m_StatesSArr[m_StateCurI].m_ChangeCamerasB )
		{			
			if( m_StatesSArr[m_StateCurI].CameraChangesRotationController() )
			{		
				return true;
			}
		}
		
		return false;
	}
	
	
	public function RessetCameraOffset()
	{
		var camera	: CCustomCamera;
		
		camera	= theGame.GetGameCamera();
		if(camera)
			camera.ResetCollisionOffset();
	}
	
	
	
	
	
	
	private function GetStateID( _StateNameN : name ) : int
	{
		var id	: int;
		
		id	= m_StateNamesSArr.FindFirst( _StateNameN );
		
		if( id < 0 )
		{
			id	= c_InvalidStateI;
		}
		
		return id;
	}
	
	
	public function GetStateCur() : name
	{
		return m_StateCurN;
	}
	
	
	public function GetStateTypeCur() : EExplorationStateType
	{
		return m_StatesSArr[ m_StateCurI ].GetStateType();
	}
	
	
	public function GetStateType( stateName : name ) : EExplorationStateType
	{
		var stateId : int;
		
		stateId	= GetStateID( stateName );
		
		if( stateId == c_InvalidStateI )
		{
			LogExplorationError( "checking for the type of an unexisting state: " + stateName );
		}
		
		return m_StatesSArr[ stateId ].GetStateType();
	}
	
	
	public function GetStateTimeF( ) : float
	{		
		return m_StateTimeCurF;
	}	
	
	
	public function GetDefaultStateName()	: name
	{
		return m_StateDefaultN;
	}
	
	
	public function GetSuperStateName()	: name
	{
		return m_SuperStateLastN;
	}
	
	
	public function StateExistsB( stateName : name ) : bool
	{
		if( FindState( stateName ) != c_InvalidStateI )
		{
			return true;
		}
		
		return false;
	}
	
	
	public function IsOnGround() : bool
	{
		return m_IsOnGroundB;
	}
	
	
	public function CanInteract() : bool
	{
		return m_StatesSArr[m_StateCurI].CanInteract();
	}
	
	
	public function GetTurnAdjustmentTime() : float
	{
		return m_StatesSArr[m_StateCurI].GetTurnAdjustmentTime();
	}
	
	
	public function CanReactToHardCriticalState() : bool
	{
		return m_StatesSArr[m_StateCurI].CanReactToHardCriticalState();
	}

	
	public function GetStateByName( stateName : name ) : CExplorationStateAbstract
	{
		var stateIndex : int;

		stateIndex = FindState( stateName );

		return m_StatesSArr[stateIndex];
	}
}