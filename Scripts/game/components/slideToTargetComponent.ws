/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SlideToTargetComponent extends CSelfUpdatingComponent
{
	
	
	
	private editable var	speed 							: float;
	private editable var	stopDistance					: float;
	private editable var 	targetOffset					: Vector;
	private editable var 	fallBackSpeed					: float;
	private editable var	snapToGround					: bool;
	private editable var	normalSpeed						: float;
	private editable var	verticalSpeed					: float;
	
	private editable var	speedOscilation					: SRangeF;
	private editable var	normalSpeedOscilation			: SRangeF;
	private editable var	verticalOscilation				: SRangeF;
	
	private editable var	speedOscilationSpeed			: float;
	private editable var	normalSpeedOscilationSpeed		: float;
	private editable var	verticalOscilationSpeed			: float;
	
	private editable var	gameplayEventAtDestination 		: name;
	private editable var	triggerGPEventOnTarget			: bool;
	private editable var 	destroyDelayAtDestination		: float;
	private editable var	stopEffectAtDest				: name;
	private editable var	playEffectAtDest				: name;
	private editable var 	stayAboveNavigableSpace			: bool;
	private editable var	considerSuccesAfterDelay		: float;
	
	private var m_NodeTarget			: CNode;
	private var m_VectorTarget			: Vector;
	private var m_IsFallingBack			: bool;	
		
	private var m_Entity				: CEntity;
		
	private var m_CanSendEvent			: bool;
		
	private var m_TimeBeforeSuccess 	: float;
	
	private var m_speedTarget			: float;
	private var m_normalSpeedTarget		: float;
	private var m_verticalOffsetTarget	: float;
	
	private var m_currentSpeedOsc		: float;
	private var m_currentNormalSpeedOsc	: float;
	private var m_currentVertOffest		: float;
	
	default speed = 1;
	default destroyDelayAtDestination 	= -1;
	default considerSuccesAfterDelay 	= -1;
	
	hint speed 						= "in m.s-1";
	hint fallBackSpeed 				= "move back at this speed if closer than the stop distance";
	hint normalSpeed 				= "Add a spiral movement toward target by adding a movement along the normal of trajectory to target";
	hint triggerGPEventOnTarget		= "Should the gameplay event be called on this or on the target entity?";
	hint destroyDelayAtDestination 	= "When reaching the destination, destroy after this delay";
	hint considerSuccesAfterDelay 	= "will be considered as having reached the position after this delay. -1 means infinite";
	
	
	
	
	public function SetStopDistance			( _Distance : float ) 	{ stopDistance = _Distance; 			}
	public function SetSpeed				( _Speed 	: float ) 	{ speed = _Speed; 						}
	public function SetOffset				( _Offset 	: Vector )	{ targetOffset = _Offset; 				}
	public function SetFallBackSpeed		( _Speed 	: float ) 	{ fallBackSpeed = _Speed; 				}
	public function SetNormalSpeed			( _Speed 	: float ) 	{ normalSpeed = _Speed; 				}
	public function SetVerticalSpeed		( _Speed 	: float ) 	{ verticalSpeed = _Speed; 				}
	public function SetGameplayEvent		( _Event 	: name 	) 	{ gameplayEventAtDestination = _Event; 	}
	public function SetTriggerOnTarget		( _OnTarget : bool 	) 	{ triggerGPEventOnTarget 	= _OnTarget;}
	public function SetDestroyDelayAtDest	( _Delay 	: float ) 	{ destroyDelayAtDestination = _Delay; 	}
	public function SetSuccessDelay			( _Delay 	: float ) 	{ considerSuccesAfterDelay = _Delay; 	}
	public function SetStopEffect			( _Name 	: name )  	{ stopEffectAtDest = _Name; 			}
	public function SetStayAboveNav			( _Stay 	: bool )  	{ stayAboveNavigableSpace = _Stay; 		}
	
	
	public function SetSpeedOscillation( _Min : float, _Max: float, _OscSpeed: float)
	{
		speedOscilation.min 	= _Min;
		speedOscilation.max 	= _Max;
		speedOscilationSpeed 	= _OscSpeed;
	}
	
	
	public function SetNormalSpeedOscillation( _Min : float, _Max: float, _OscSpeed: float)
	{
		normalSpeedOscilation.min 	= _Min;
		normalSpeedOscilation.max 	= _Max;
		normalSpeedOscilationSpeed 	= _OscSpeed;
	}
	
	
	public function SetVerticalOscillation( _Min : float, _Max: float, _OscSpeed: float)
	{
		verticalOscilation.min 	= _Min;
		verticalOscilation.max 	= _Max;
		verticalOscilationSpeed 	= _OscSpeed;
	}
	
	
	event OnComponentAttached()
	{
		if( !theGame.IsActive())
		{
			return true;
		}
	
		m_Entity 		= GetEntity();
		m_CanSendEvent 	= true;		
		
		m_TimeBeforeSuccess = considerSuccesAfterDelay;
		
		if( speedOscilation.min != speedOscilation.max )
		{
			if( RandF() > 0.5f)	m_speedTarget = speedOscilation.max;
			else m_speedTarget = speedOscilation.min;
		}		
		if( normalSpeedOscilation.min != normalSpeedOscilation.max )
		{
			if( RandF() > 0.5f)	m_normalSpeedTarget = normalSpeedOscilation.max;
			else m_normalSpeedTarget = normalSpeedOscilation.min;
		}		
		if( verticalOscilation.min != verticalOscilation.max )
		{
			if( RandF() > 0.5f)	m_verticalOffsetTarget = verticalOscilation.max;
			else m_verticalOffsetTarget = verticalOscilation.min;
		}
		
		StartTicking();
	}
	
	
	private function Oscilliate( _Dt : float )
	{
		var l_epsilon : float;
		
		l_epsilon = 0.1f;
		
		
		if( speedOscilation.min != speedOscilation.max )
		{
			
			if( ( m_currentSpeedOsc / m_speedTarget ) > 0 && AbsF( AbsF( m_currentSpeedOsc ) - AbsF( m_speedTarget ) ) < l_epsilon )			
			{
				if( m_speedTarget == speedOscilation.min )
					m_speedTarget = speedOscilation.max;
				else
					m_speedTarget = speedOscilation.min;
			}
			
			m_currentSpeedOsc = InterpConstTo_F( m_currentSpeedOsc, m_speedTarget, _Dt, speedOscilationSpeed );
		}
		
		
		if( normalSpeedOscilation.min != normalSpeedOscilation.max )
		{
			
			if( ( m_currentNormalSpeedOsc / m_normalSpeedTarget ) > 0 && AbsF( AbsF( m_currentNormalSpeedOsc ) - AbsF( m_normalSpeedTarget ) ) < l_epsilon )
			{
				if( m_normalSpeedTarget == normalSpeedOscilation.min )
					m_normalSpeedTarget = normalSpeedOscilation.max;
				else
					m_normalSpeedTarget = normalSpeedOscilation.min;
			}
			
			m_currentNormalSpeedOsc = InterpConstTo_F(  m_currentNormalSpeedOsc, m_normalSpeedTarget, _Dt, normalSpeedOscilationSpeed );
		}
		
		
		if( verticalOscilation.min != verticalOscilation.max )
		{
			
			if( ( m_currentVertOffest / m_verticalOffsetTarget ) > 0 && AbsF( AbsF( m_currentVertOffest ) - AbsF( m_verticalOffsetTarget ) ) < l_epsilon )
			{
				if( m_verticalOffsetTarget == verticalOscilation.min )
					m_verticalOffsetTarget = verticalOscilation.max;
				else
					m_verticalOffsetTarget = verticalOscilation.min;
			}
			
			m_currentVertOffest = InterpConstTo_F( m_currentVertOffest, m_verticalOffsetTarget, _Dt, verticalOscilationSpeed );
		}
	}
	
	
	event OnComponentTick ( _Dt : float )
	{
		var l_pos, l_normal, l_normalToTarget, l_toTarget	: Vector;
		var l_groundZ 	: float;
		var l_direction	: float;
		var l_targetPos	: Vector;
		
		if( !m_NodeTarget && m_VectorTarget == Vector( 0,0,0 ) )
			return true;
		
		Oscilliate( _Dt);
		
		if( speed != 0 || normalSpeed != 0 || m_currentNormalSpeedOsc != 0 || m_currentSpeedOsc != 0 || m_currentVertOffest != 0) 
		{	
			l_pos = m_Entity.GetWorldPosition();
			
			l_targetPos = GetTargetPosition();
			
			if( speed != 0 || m_currentSpeedOsc != 0)
			{
				
				if( m_IsFallingBack )
				{
					l_pos = InterpTo_V( l_pos, l_targetPos, _Dt, fallBackSpeed );
				}
				else if ( GetDistanceToTarget() > stopDistance )
				{					
					l_pos = InterpTo_V( l_pos, l_targetPos, _Dt, speed  + m_currentSpeedOsc );
				}
			}
			
			if( verticalSpeed != 0 )
			{
				l_pos = InterpTo_V( l_pos, Vector( l_pos.X, l_pos.Y, l_targetPos.Z + m_currentVertOffest ), _Dt, verticalSpeed );
			}
			
			if( normalSpeed != 0 || m_currentNormalSpeedOsc != 0 )
			{
				l_toTarget 			= GetTargetPosition() - m_Entity.GetWorldPosition();
				l_normalToTarget 	= VecCross( l_toTarget, Vector( 0,0,1 ) );
				l_normalToTarget	= VecNormalize( l_normalToTarget );
				l_direction			= 1;
				if( m_currentNormalSpeedOsc != 0 ) 
					l_direction			=	m_currentNormalSpeedOsc / AbsF( m_currentNormalSpeedOsc );
				l_pos = InterpTo_V( l_pos, l_pos + l_normalToTarget *  l_direction, _Dt, AbsF( normalSpeed + m_currentNormalSpeedOsc  ) );
			}
			if( stayAboveNavigableSpace )
			{
				if( snapToGround )
				{
					theGame.GetWorld().NavigationComputeZ( l_pos, l_pos.Z - 5, l_pos.Z + 5, l_groundZ );
					l_pos.Z = l_groundZ;
				}				
				
				if( !theGame.GetWorld().NavigationCircleTest( l_pos, 0.5 ) )
				{
					l_pos = m_Entity.GetWorldPosition();
				}
			}
			
			else if( snapToGround )
			{
				if( theGame.GetWorld().NavigationComputeZ( l_pos, l_pos.Z - 5, l_pos.Z + 5, l_groundZ ) )
				{
					l_pos.Z = l_groundZ;
				}
				else
				{
					theGame.GetWorld().StaticTrace( l_pos + Vector(0,0,3), l_pos - Vector(0,0,3), l_pos, l_normal );
				}
			}
			m_Entity.Teleport( l_pos );
		}
		
		if ( IsAtDestination() )		
		{
			
			if( destroyDelayAtDestination >= 0 )
			{
				m_Entity.DestroyAfter( destroyDelayAtDestination );
				destroyDelayAtDestination = -1;
			}
			
			
			if ( IsNameValid ( stopEffectAtDest ) )
			{
				m_Entity.StopEffect( stopEffectAtDest );
			}
			if ( IsNameValid ( playEffectAtDest ) )
			{
				if ( !m_Entity.IsEffectActive( playEffectAtDest ) )
				{
					m_Entity.PlayEffect( playEffectAtDest );
				}
			}
			
			if( m_CanSendEvent && IsNameValid( gameplayEventAtDestination ) )
			{
				if( triggerGPEventOnTarget && m_NodeTarget && ( CActor ) m_NodeTarget )
				{
					(( CActor ) m_NodeTarget).SignalGameplayEvent( gameplayEventAtDestination );
				}
				else if( ( CActor ) m_Entity )
				{
					( ( CActor ) m_Entity ).SignalGameplayEvent( gameplayEventAtDestination );
				}	
			}
			m_CanSendEvent = false;
		}
		else
		{
			m_CanSendEvent = true;
		}
		
		m_TimeBeforeSuccess -= _Dt;
	}
	
	
	public function SetTargetNode( _Target : CNode ) 
	{
		m_NodeTarget = _Target;
	}	
	
	
	public function SetTargetVector( _Vector : Vector ) 
	{
		m_VectorTarget 	= _Vector;
		m_NodeTarget 	= NULL;
	}
	
	
	public function IsAtDestination() : bool
	{		
		if( !m_NodeTarget && m_VectorTarget == Vector( 0,0,0 ) ) 
			return false;
		
		if( m_TimeBeforeSuccess <= 0 && considerSuccesAfterDelay > 0 )
		{
			return true;
		}
		
		return GetDistanceToTarget() - stopDistance <= 0;
	}
	
	
	public function GetTargetPosition() : Vector
	{
		var l_targetPos 	: Vector;
		var l_overDistance	: float;
		var l_fromTarget	: Vector;
		var l_zValue		: float;
		
		if( m_NodeTarget ) 
		{
			l_targetPos = m_NodeTarget.GetWorldPosition() + targetOffset;
		}
		else
		{
			l_targetPos = m_VectorTarget;
		}
		m_IsFallingBack = false;
		if( fallBackSpeed > 0 )
		{
			l_overDistance = stopDistance - VecDistance ( GetEntity().GetWorldPosition(), l_targetPos );
			if( l_overDistance > 0 )
			{
				l_zValue 		= l_targetPos.Z;
				l_fromTarget 	= GetEntity().GetWorldPosition() - l_targetPos;
				l_fromTarget	= VecNormalize( l_fromTarget );
				l_targetPos 	= l_targetPos + l_fromTarget * l_overDistance;
				l_targetPos.Z 	= l_zValue;
				m_IsFallingBack = true;
			}		
		}
		
		return l_targetPos;
	}	
	
	
	public function GetTimeLeftToDestination() : float
	{
		var l_timeLeft : float;		
		if( speed <= 0 ) return -1;		
		l_timeLeft = MaxF( 0, GetDistanceToTarget() - stopDistance ) / speed;
		return l_timeLeft;
	}	
	
	
	public function GetDistanceToTarget() : float
	{
		var l_distance : float;
		l_distance = VecDistance( GetTargetPosition(), m_Entity.GetWorldPosition() );
		return l_distance;
	}
}