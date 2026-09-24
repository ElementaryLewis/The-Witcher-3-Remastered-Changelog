/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SDefaultStateTransition
{
	var	m_StateNameN 			: name;
	var m_TimeToStartCheckingF	: float	;
}
	
enum EGameplayContextInput
{
	EGCI_Ignore			,
	EGCI_Exploration	,
	EGCI_JumpClimb		,
	EGCI_Combat			,
	EGCI_Swimming		,
}




class CExplorationStateAbstract extends CScriptedComponent
{
	
	protected editable			var	m_StateNameN				: name;
	protected 					var	m_StateTypeE				: EExplorationStateType;
	public						var	m_UpdatesWhileInactiveB		: bool;						default	m_UpdatesWhileInactiveB		= false;
	
	
	protected					var	m_ExplorationO				: CExplorationStateManager;
	
	
	private						var	m_LockedB					: bool;						default	m_LockedB					= false;
	private						var	m_ActiveB					: bool;

	private						var	m_StateNextN				: name;
	
	protected					var m_DefaultStateChangesArr	: array<SDefaultStateTransition>;
	
	
	protected editable			var	m_BehaviorNeedsConfirmB		: bool;						default	m_BehaviorNeedsConfirmB		= false;
	protected editable			var	m_BehaviorEventB			: bool;						default	m_BehaviorEventB			= true;
	protected editable			var	m_BehaviorEventEachFrameB	: bool;						default	m_BehaviorEventEachFrameB	= false;
	protected editable			var	m_BehaviorEventN			: name;					
	protected editable			var	m_StateDefaultExitToN		: name;						
	
	
	protected editable			var	m_CanReactToCriticalStateB	: bool;						default	m_CanReactToCriticalStateB	= true;
	
	
	public editable 			var	m_ChangeCamerasB			: bool;						default	m_ChangeCamerasB			= true;
	protected editable 			var	m_CameraKeepOldB			: bool;						
	protected editable inlined	var	m_CameraSetS				: CCameraParametersSet;				
	
	
	public editable				var m_InputContextE				: EGameplayContextInput;	default	m_InputContextE				= EGCI_Exploration;
	
	
	protected editable			var m_TurnAdjustTimeF			: float;					default	m_TurnAdjustTimeF			= 0.0f;
	
	
	protected					var	m_ActionsToBlockEArr		: array<EInputActionBlock>;
	protected					var	m_ActionsToBlockCountI		: int;
	
	
	protected					var	m_HolsterIsFastB			: bool;						default	m_HolsterIsFastB			= false;
	
	
	private						var	m_CanSaveB					: bool;						default	m_CanSaveB					= true;
	
	
	
	
	final function Initialize( _Exploration : CExplorationStateManager )
	{
		m_ExplorationO = _Exploration;
		
		InitializeSpecific( _Exploration );
		
		AddAnimEventCallbacks();
		
		
		if( m_BehaviorEventB && !IsNameValid( m_BehaviorEventN ) )
		{
			m_BehaviorEventN	= m_StateNameN;
		}
		
		
		if( !IsNameValid( m_StateDefaultExitToN ) )
		{
			m_StateDefaultExitToN	= m_ExplorationO.GetDefaultStateName() ;
		}
		
		
		if( m_CameraSetS )
		{
			if( !IsNameValid( m_CameraSetS.pivotPositionControllerName ) )
			{
				m_CameraSetS.pivotPositionControllerName	= m_ExplorationO.m_DefaultCameraSetS.pivotPositionControllerName;
			}
			if( !IsNameValid( m_CameraSetS.pivotRotationController ) )
			{
				m_CameraSetS.pivotRotationController	= m_ExplorationO.m_DefaultCameraSetS.pivotRotationController;
			}
			if( !IsNameValid( m_CameraSetS.pivotDistanceController ) )
			{
				m_CameraSetS.pivotDistanceController	= m_ExplorationO.m_DefaultCameraSetS.pivotDistanceController;
			}
		}
		
		
		m_ActionsToBlockEArr.Clear();
		AddActionsToBlock();
		
		
		if( m_BehaviorNeedsConfirmB && m_BehaviorEventEachFrameB )
		{
			LogExplorationError( "You can't Require confirmation if you are sending the event each frame: m_BehaviorNeedsConfirmB && m_BehaviorEventEachFrameB" );
		}
		
		LogExploration( "Initialized : " + GetStateName( ) );
	}
	
	
	
	protected function InitializeSpecific( _Exploration : CExplorationStateManager )
	{
		LogExplorationError( GetStateName( ) + ": Missing function InitializeSpecific" );
	}
	
	
	
	public function PostInitialize()
	{
		AddDefaultStateChangesSpecific();
	}
	
	
	
	private function AddDefaultStateChangesSpecific()
	{
		LogExplorationError( GetStateName( ) + ": Missing function AddDefaultStateChangesSpecific" );
	}
	
	
	
	protected function AddStateToTheDefaultChangeList( stateName : name, optional timeToStartChecking : float )
	{
		var automaticTransition	: SDefaultStateTransition;
		
		if( !m_ExplorationO.StateExistsB( stateName ) )
		{
			LogExplorationError( GetStateName( ) + ": State change : " + stateName + " Does not exist" );
			return;
		}
		
		automaticTransition.m_StateNameN			= stateName;
		automaticTransition.m_TimeToStartCheckingF	= timeToStartChecking;
		m_DefaultStateChangesArr.PushBack( automaticTransition );
	}
	
	
	
	protected function AddActionsToBlock()
	{
		m_ActionsToBlockEArr.Clear();
		
	}
	
	
	
	protected function AddActionToBlock( action : EInputActionBlock )
	{
		m_ActionsToBlockEArr.PushBack( action );
	}
	
	
	
	protected function BlockActions()
	{
		var i 			: int;
		
		m_ActionsToBlockCountI	= m_ActionsToBlockEArr.Size();
		
		if( thePlayer )
		{
			for( i = 0; i < m_ActionsToBlockCountI; i += 1 )
			{
				thePlayer.BlockAction( m_ActionsToBlockEArr[i], m_StateNameN );
			}
		}
	}
	
	
	
	private function UnlockallActions()
	{	
		var i : int;
		
		if( thePlayer )
		{			
			for( i = 0; i < m_ActionsToBlockCountI; i += 1 )
			{
				thePlayer.UnblockAction( m_ActionsToBlockEArr[i], m_StateNameN );
			}
			
		}
	}
	
	
	
	final function Restart()
	{
		m_ActiveB	= false;
	}
	
	
	
	function StateWantsToEnter() : bool
	{
		LogExplorationError( GetStateName( ) + ": Missing function StateWantsToEnter" );
		
		return false;
	}
	
	
	
	function StateCanEnter( curStateName : name ) : bool
	{	
		LogExplorationError( GetStateName( ) + ": Missing function StateCanEnter" );
		DebugBreak();
		
		return false;
	}
	
	
	
	final function StateEnter( prevStateName : name )
	{
		m_StateNextN	= GetStateName();
		
		m_ActiveB	= true;
		
		LogExploration( "-----------------------------------------------------------------------------" );
		LogExploration(  GetStateName( ) + ": StateEnter" );
		
		
		StateEnterSpecific( prevStateName );
		
	}
	
	
	
	protected function StateEnterSpecific( prevStateName : name )
	{
		LogExplorationError( GetStateName( ) + ": Missing function StateEnterSpecific" );
	}
	
	
	
	protected function AddAnimEventCallbacks(){}
	
	
	
	public function StateEnterConfirmed()
	{
		if( m_BehaviorNeedsConfirmB )
		{
			StateEnterConfirmedSpecific();
		}
	}
	
	
	
	public function StateEnterConfirmedSpecific(){}
	
	
	
	function StateChangePrecheck( )	: name
	{		
		var i 		: int;
		var max		: int;
		var time	: float;
		
		
		time	= m_ExplorationO.GetStateTimeF();
		max = m_DefaultStateChangesArr.Size();		
		for( i = 0; i < max; i += 1 )
		{
			if( time > m_DefaultStateChangesArr[i].m_TimeToStartCheckingF )
			{
				if( m_ExplorationO.StateWantsAndCanEnter( m_DefaultStateChangesArr[i].m_StateNameN ) )
				{
					return m_DefaultStateChangesArr[i].m_StateNameN;
				}
			}
		}
		
		
		if( m_StateNextN != GetStateName()  && m_ExplorationO.CanChangeBetwenStates( GetStateName(), m_StateNextN ) )
		{
			return m_StateNextN;
		}
		
		
		return GetStateName();
	}
	
	
	
	
	function SetReadyToChangeTo( _NewStateN : name )
	{
		m_StateNextN	= _NewStateN;
	}
	
	
	
	
	function HasQueuedState() : bool
	{
		return m_StateNextN	!= GetStateName();
	}
	
	
	function IsThisStatequeued( _StateN : name ) : bool
	{
		return m_StateNextN	== _StateN;
	}
	
	
	function GetQueuedState( ) : name
	{
		return m_StateNextN;
	}
	
	
	function StateUpdate( _Dt : float )
	{
		var l_BehaviorEventN	: name;
		
		
		
		StateUpdateSpecific( _Dt );
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{
		LogExplorationError( GetStateName( ) + ": Missing function StateUpdate" );
		DebugBreak();
	}
	
	
	function StateUpdateInactive( _Dt : float ){}
	
	
	final function StateExit( nextStateName : name )
	{		
		LogExploration(  GetStateName( ) + ": StateExit. Took " + m_ExplorationO.GetStateTimeF() + " seconds." );
		
		
		
		
		
		UnlockallActions();
		
		StateExitSpecific( nextStateName );
		
		
		m_ExplorationO.StateExited();
		
		m_ActiveB	= false;
	}
	
	
	protected function StateExitSpecific( nextStateName : name )
	{
		LogExplorationError( GetStateName( ) + ": Missing function StateExit" );
	}
	
	
	
	protected function RemoveAnimEventCallbacks(){}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) { }
	
	
	function ReactToHitGround() : bool
	{
		return false;
	}
	
	
	function ReactToLoseGround() : bool
	{
		return false;
	}
	
	
	function ReactToHitCeiling() : bool
	{
		return false;
	}
	
	
	function ReactToSlide() : bool
	{
		return false;
	}
	
	
	function ReactToBeingHit( optional damageAction : W3DamageAction ) : bool
	{
		return false;
	}
	
	
	function ReactToChanceToFallAndSlide() : bool
	{
		return false;
	}

	
	function ReactToCriticalState( enabled : bool ) : bool
	{
		return false;
	}
	
	
	
	function OnBehGraphNodeEntered()
	{
	}
	
	
	function OnBehGraphNodeExited()
	{
	}
	
	
	
	
	
	
	final function GetStateName( ) : name
	{
		return m_StateNameN;
	}
	
	
	final function GetStateType() : EExplorationStateType
	{
		return m_StateTypeE;
	}
	
	
	function NeedsBehaviorConfirmation() : bool
	{
		return m_BehaviorNeedsConfirmB;
	}
	
	
	final function IsRaisingBehaviorEvent( ) : bool
	{
		return m_BehaviorEventB;
	}
	
	
	final function IsRaisingBehaviorEventEachFrame() : bool
	{
		return m_BehaviorEventEachFrameB;
	}
	
	
	function GetBehaviorEventName() : name
	{
		return m_BehaviorEventN;
	}

	
	function GetBehaviorIsEventForced( fromState : name ) : bool
	{
		return false;
	}
	
	
	public function IsHolsterFast() : bool
	{
		return m_HolsterIsFastB;
	}
	
	
	function GetStateToExitToAfterFailing() : name
	{
		return m_StateDefaultExitToN;
	}
	
	
	public function GetDebugText() : string
	{
		return "";
	}
	
	
	public function GetDebugTextInactive() : string
	{
		return "";
	}
	
	
	public function GetCameraSet( out cameraSet : CCameraParametersSet) : bool
	{
		if( m_CameraSetS )
		{
			cameraSet	= m_CameraSetS;
			return true;
		}
		return false;
	}
	
	
	public function CameraChangesRotationController() : bool
	{
		if( IsNameValid( m_CameraSetS.pivotRotationController ) )
		{
			if( m_CameraSetS.pivotRotationController != m_ExplorationO.m_DefaultCameraSetS.pivotRotationController )
			{
				return true;
			}
		}
		
		return false;
	}
	
	
	public function GetIfCameraIsKept() : bool
	{
		return m_CameraKeepOldB;
	}
	
	
	function UpdateCameraIfNeeded( out moveData : SCameraMovementData, dt : float ) : bool
	{
		return false;
	}
	
	
	final function IsActiveState() : bool
	{
		return m_ActiveB;
	}
	
	
	public function CanInteract() : bool
	{
		LogExplorationError( GetStateName( ) + ": Missing function CanInteract" );
		DebugBreak();
		
		return false;
	}
	
	
	public function GetTurnAdjustmentTime() : float
	{
		return m_TurnAdjustTimeF;
	}
	
	
	protected function SetCanSave( canSave : bool )
	{
		m_CanSaveB	= canSave;
	}
	
	
	public function GetCanSave() : bool
	{
		return m_CanSaveB;
	}
	
	
	public function CanReactToHardCriticalState() : bool
	{
		return m_CanReactToCriticalStateB;
	}
	
	
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags, active : bool )
	{
		return true;
	}
}