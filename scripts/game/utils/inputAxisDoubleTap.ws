/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CInputAxisDoubleTap
{	
	
	public	editable	var m_ActionN				: name;
	public	editable	var	m_ThresholdUnpressF		: float;			default m_ThresholdUnpressF		= 0.1f;
	public	editable	var	m_ThresholdPressF		: float;			default m_ThresholdPressF		= 0.9f;
	public	editable	var	m_TimeThresholdF		: float;			default	m_TimeThresholdF		= 0.1f;
	
	
	private				var	m_IsActivatedB			: bool;
	
	private				var	m_PressedNowB			: bool;
	private				var	m_UnpressedNowB			: bool;
	private				var	m_TimeF					: float;
	
	private				var	m_LastTimesUnpressFArr	: array< float >;
	private				var	m_LastTimesPressFArr	: array< float >;
	
	
	
	function Initialize( _ActionN : name, _PressF, _UnpressF, _TimeF : float )
	{
		m_ActionN			= _ActionN;
		m_ThresholdUnpressF	= _PressF;
		m_ThresholdPressF	= _UnpressF;
		m_TimeThresholdF	= _TimeF;
		
		ResetValues();
		
		m_TimeF	= 0.0f;
	}
	
	
	private function ResetValues()
	{
		m_LastTimesUnpressFArr.Clear();
		m_LastTimesUnpressFArr.PushBack( 2.0f );
		m_LastTimesUnpressFArr.PushBack( 2.0f );
		
		m_LastTimesPressFArr.Clear();
		m_LastTimesPressFArr.PushBack( 1.0f );
		m_LastTimesPressFArr.PushBack( 1.0f );
		
		m_PressedNowB	= false;
		m_UnpressedNowB	= false;
		
		m_IsActivatedB	= false;
	}
	
	
	function Update()
	{
		var l_ValueF	: float;
		
		m_TimeF		= theGame.GetEngineTimeAsSeconds();
		
		l_ValueF	= theInput.GetActionValue( m_ActionN );
		
		
		if( CheckPressB( l_ValueF ) )
		{
			if( !m_PressedNowB )
			{
				m_LastTimesPressFArr[0]	= m_LastTimesPressFArr[1];
			}
			m_LastTimesPressFArr[1]	= m_TimeF;
			
			m_PressedNowB	= true;
		}
		
		else
		{
			
			if( CheckUnPressB( l_ValueF ) )
			{
				if( !m_UnpressedNowB )
				{
					m_LastTimesUnpressFArr[0]	= m_LastTimesUnpressFArr[1];
				}
				m_LastTimesUnpressFArr[1]	= m_TimeF;
				
				m_UnpressedNowB	= true;
			}
			
			else
			{
				m_UnpressedNowB	= false;
			}
			
			m_PressedNowB	= false;
		}
		
		m_IsActivatedB	= CheckActivation();
	}	
	
	
	private function CheckPressB( _ValueF : float ) : bool
	{
		if( m_ThresholdPressF > 0.0f )
		{
			return _ValueF >= m_ThresholdPressF;
		}
		else
		{
			return _ValueF <= m_ThresholdPressF;
		}
	}	
	
	
	private function CheckUnPressB( _ValueF : float ) : bool
	{
		if( m_ThresholdPressF >= 0.0f )
		{
			return _ValueF <= m_ThresholdUnpressF;
		}
		else 
		{
			return _ValueF >= m_ThresholdUnpressF;
		}
	}
	
	
	private function CheckActivation() : bool
	{
		
		
		
		
		if( m_LastTimesUnpressFArr[1] > m_LastTimesPressFArr[1] )
		{
			return false;
		}
		
		
		if( m_LastTimesPressFArr[1] > m_TimeF + m_TimeThresholdF )
		{
			return false;
		}
		
		
		if( m_LastTimesUnpressFArr[1] > m_LastTimesPressFArr[1] + m_TimeThresholdF )
		{
			return false;
		}
		
		
		if( m_LastTimesPressFArr[0] > m_LastTimesUnpressFArr[1] + m_TimeThresholdF )
		{
			return false;
		}
		
		
		if( m_LastTimesUnpressFArr[1] > m_LastTimesPressFArr[0] + m_TimeThresholdF )
		{
			return false;
		}
		
		return true;
	}
	
	
	function IsActiveB() : bool
	{
		return m_IsActivatedB;
	}
	
	
	function ConsumeIfActivated()
	{
		if( m_IsActivatedB )
		{
			ResetValues();
		}
	}	
}