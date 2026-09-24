/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3PostFXOnGroundComponent extends CSelfUpdatingComponent
{
	
	
	
	private editable var fadeInTime 			: float; 
	private editable var activeTime 			: float;
	private editable var fadeOutTime 			: float;
	private editable var range 					: float;
	private editable var type 					: int;
	private editable var updateDelay			: float;
	private editable var stopAtDeath			: bool;
	
	private var m_Actor							: CActor;
	private var m_DelaySinceLastUpdate 			: float;
	private var m_DefaultFadeInTime 			: float; 
	private var m_DefaultActiveTime 			: float;
	private var m_DefaultFadeOutTime 			: float;
	private var m_DefaultRange 					: float;
	
	hint type 			= "0 - frost, 1 - burn";
	hint type 			= "0 - frost, 1 - burn";
	hint stopAtDeath  	= "If the entity is an actor, stop the fx at death";
	
	default fadeInTime	= 0.5f;
	default activeTime	= 2.0f;
	default fadeOutTime	= 0.5f;
	default range		= 2.0f;
	default updateDelay = 0.1f;
	default stopAtDeath = true;
	
	
	
	public function GetRange() 					: float  			{ 	return range; 	}
	
	
	event OnComponentAttached()
	{
		m_DefaultFadeInTime 	= fadeInTime;
		m_DefaultActiveTime 	= activeTime;
		m_DefaultFadeOutTime 	= fadeOutTime;
		m_DefaultRange			= range;
		m_Actor					= (CActor) GetEntity();
	}
	
	
	event OnComponentTick ( _Dt : float )
	{
		if( stopAtDeath && m_Actor && !m_Actor.IsAlive()  )
		{
			StopTicking();
			return false;
		}
		
		Update( _Dt );
		
		if( updateDelay < 0 )
		{
			StopTicking();
		}
	}	
	
	
	public function OverrideValues( _FadeInTime : float, _ActiveTime : float, _FadeOutTime : float, _Range : float )
	{
		fadeInTime	= _FadeInTime;
		activeTime	= _ActiveTime;
		fadeOutTime	= _FadeOutTime;
		range		= _Range; 	
	}
	
	
	public function RestoreValues()
	{
		fadeInTime	= m_DefaultFadeInTime;
		activeTime	= m_DefaultActiveTime;
		fadeOutTime	= m_DefaultFadeOutTime;
		range		= m_DefaultRange; 
	}
	
	
	private function Update( _Dt : float )
	{
		var l_pos,  l_normal	: Vector;
		var l_gameplayFX 		: CGameplayFXSurfacePost = theGame.GetSurfacePostFX();
		
		m_DelaySinceLastUpdate += _Dt;		
		if( m_DelaySinceLastUpdate < updateDelay ) return;
		
		l_pos = GetEntity().GetWorldPosition();
		theGame.GetWorld().StaticTrace( l_pos + Vector(0,0,5), l_pos - Vector(0,0,5), l_pos, l_normal );
		
		l_gameplayFX.AddSurfacePostFXGroup( l_pos, fadeInTime, activeTime, fadeOutTime, range, type );
	}
	
}