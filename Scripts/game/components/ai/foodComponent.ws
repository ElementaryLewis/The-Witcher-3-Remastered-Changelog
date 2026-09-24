/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3FoodComponent extends W3ScentComponent
{
	
	
	
	private editable 	var 	maxEater					: int;
	private editable	var		distanceToEat				: float;
	private editable	var 	startAngleToEat				: float;
	private editable	var 	arcWidthToEat				: float;
	
	default	maxEater 					= 1;
	default	distanceToEat 				= 1;
	default	startAngleToEat 			= 0;
	default	arcWidthToEat 				= 360;
	
	hint maxEater					= "number of npc that can eat at this source simultaneously";
	hint startAngleToEat			= "Angle to add to this entity forward. Indicates starting valid position for eating";
	hint arcWidthToEat				= "From startAngleToEat to where around the food is a suitable position to eat it (>= 360 means all around is good)";
	
	
	private 			var 	m_Eaters			: array<CActor>;
	private 			var		m_LockDistance		: float;
	private 			var		m_EatSlots			: array<Vector>;
	
	private 			var		m_LastTimeEaten		: float;
	
	default	m_LockDistance	= 10;
	
	
	
	public function GetFoodGroup() 		: EFoodGroup				{		return foodGroup;			}
	public function GetLockDistance() 	: float						{		return m_LockDistance;		}
	
	
	event OnComponentAttached()
	{
		var i					: int;
		var angle				: float;
		var angleDistance		: float;
		var heading				: Vector;
		var toPositionVec		: Vector;
		var toPositionEuler		: EulerAngles;
		var finalPosition		: Vector;
		
		m_EatSlots.Clear();
		
		if(  maxEater <= 1 )
		{
			angle = startAngleToEat;
			
			heading 				= GetEntity().GetHeadingVector();
			toPositionEuler 		= VecToRotation( heading );		
			toPositionEuler.Yaw 	+= angle;
			toPositionVec 			= VecFromHeading( toPositionEuler.Yaw );
			
			toPositionVec = VecNormalize( toPositionVec ) * distanceToEat;
			finalPosition = GetEntity().GetWorldPosition() + toPositionVec;
			
			m_EatSlots.PushBack( finalPosition );
		}
		
		angleDistance 	= arcWidthToEat / maxEater - 1;	
		for ( i = 0; i < maxEater; i += 1 )
		{
			angle = startAngleToEat + angleDistance * i;
			
			heading 				= GetEntity().GetHeadingVector();
			toPositionEuler 		= VecToRotation( heading );		
			toPositionEuler.Yaw 	+= angle;
			toPositionVec 			= VecFromHeading( toPositionEuler.Yaw );
			
			toPositionVec = VecNormalize( toPositionVec ) * distanceToEat;
			finalPosition = GetEntity().GetWorldPosition() + toPositionVec;
			
			m_EatSlots.PushBack( finalPosition );		
		}
	}
	
	
	
	event OnFireHit()
	{
		
		attractionRange			= -1;
		deadAttractionRange 	= -1;
		bleedingAttractionRange = -1;
	}
	
	
	
	public function IsAvailable( _ForWhom : CActor ) : bool
	{
		var l_distance : float;
		
		if( GetAttractionRange() <= 0 )
		{
			return false;
		}
		
		
		l_distance = VecDistance( _ForWhom.GetWorldPosition(), GetWorldPosition() );
		if( l_distance < m_LockDistance * 2 )
		{		
			UpdateEaters();			
			if( m_Eaters.Size() >= maxEater && !m_Eaters.Contains( _ForWhom ) )
			{
				return false;
			}
		}
		
		return true;
	}
	
	
	public function GetEatingPosition( _ForWhom : CActor ) : Vector
	{		
		var i					: int;
		var finalPosition		: Vector;		
		var ToNPC				: Vector;
		
		if( arcWidthToEat >= 360 )
		{
			ToNPC = _ForWhom.GetWorldPosition() - GetWorldPosition() ;		
			ToNPC = VecNormalize( ToNPC ) * distanceToEat;
			
			return GetWorldPosition() + ToNPC;
		}
		
		finalPosition = m_EatSlots[0];
		
		for ( i = 0; i < m_Eaters.Size(); i += 1 )
		{
			if( m_Eaters[i] != _ForWhom ) continue;			
			
			finalPosition = m_EatSlots[i];
			_ForWhom.GetVisualDebug().AddSphere( 'eat position', 0.5f, finalPosition, true );			
		}
		
		return finalPosition;
	}
	
	
	public function AddEater( _Eater : CActor ) : bool
	{
		if( m_Eaters.Size() >= maxEater ) return false;
		if( m_Eaters.Contains( _Eater ) ) return false;
		m_Eaters.PushBack( _Eater );
		
		return true;
	}	
	
	
	public function RemoveEater( _Eater : CActor )
	{
		m_Eaters.Remove( _Eater );
		
		if( m_Eaters.Size() == 0 )
		{
			m_LastTimeEaten = theGame.GetEngineTimeAsSeconds();
		}
	}
	
	
	public function UpdateEaters()
	{
		var 	i 					: int;
		var 	l_pos, l_eaterPos	: Vector;
		
		l_pos = GetEntity().GetWorldPosition();
		
		for ( i = m_Eaters.Size() - 1; i >= 0; i -= 1 )
		{
			l_eaterPos = m_Eaters[i].GetWorldPosition();
			
			if( VecDistance( l_pos, l_eaterPos ) > m_LockDistance || maxEater == 0 )
			{
				m_Eaters.Erase( i );
				continue;
			}
		}
	}
}