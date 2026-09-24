/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3WindEffectOnGroundComponent extends CSelfUpdatingComponent
{
	
	
	
	editable var maxDistanceFromGround	: float;
	editable var activeAtStart			: bool;
	editable var playOnAnimEvent		: bool;
	editable var activateOnAnimEvent	: bool;
	editable var animEvent				: name;
	editable var deactivateAnimEvent 	: name;
	editable var delayBetweenEffects	: float;	
	editable var effectTemplate			: CEntityTemplate;
	
	
	private var m_isActive				: bool;
	private var m_effectEntity			: CEntity;
	private var m_collisionGroupNames 	: array<name>;
	private var m_delayUntilNextEffect	: float;
	
	default activeAtStart 			= true;
	default m_isActive 				= false;
	default playOnAnimEvent 		= false;
	default activateOnAnimEvent 	= false;
	default animEvent 				= 'WindEffect';
	default deactivateAnimEvent 	= 'WindEffectStop';
	default maxDistanceFromGround 	= 5;
	default delayBetweenEffects 	= 0.1f;
	
	hint maxDistanceFromGround = "How far from the ground can the entity be until the effect is not displayed anymore";
	
	
	event OnComponentAttached()
	{
		var l_actor : CActor;
		
		m_collisionGroupNames.PushBack('Terrain');
		m_collisionGroupNames.PushBack('Foliage');
		m_collisionGroupNames.PushBack('Boat');
		m_collisionGroupNames.PushBack('Platfmors');
		m_collisionGroupNames.PushBack('Static');
		
		l_actor = (CActor) GetEntity();
		
		if( l_actor  && ( playOnAnimEvent || activateOnAnimEvent ) )
		{
			l_actor.AddAnimEventChildCallback(this,animEvent,			'OnAnimEvent_Custom');
			l_actor.AddAnimEventChildCallback(this,deactivateAnimEvent,	'OnAnimEvent_Custom');
		}
		
		StartTicking();
		m_isActive = false;
		if( activeAtStart )
		{
			Activate();
		}
	}
	
	
	event OnAnimEvent_Custom( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{	
		if ( animEventName == animEvent )
		{			
			PlayEffect();
			
			if( activateOnAnimEvent )
			{
				Activate();
			}			
		}
		else if ( animEventName == deactivateAnimEvent )
		{
			Deactivate();
		}
	}
	
	
	event OnComponentTick ( _Dt : float )
	{
		m_delayUntilNextEffect -= _Dt;
		if( m_isActive )
		{
			PlayEffect();
		}
	}
	
	
	public function Activate()
	{
		m_isActive = true;
		StartTicking();
	}	
	
	
	public function Deactivate()
	{
		m_isActive = false;
		
		m_effectEntity.StopAllEffects();
		m_delayUntilNextEffect = 0;
	}
	
	
	private function PlayEffect( )
	{
		var l_pos, l_contact,  l_normal		: Vector;
		var l_waterLevel					: float;
		var l_distanceFromWater				: float;
		var l_distanceFromGround			: float;
		var l_actor							: CActor;
		
		if( m_delayUntilNextEffect > 0 )
		{
			return;
		}
		
		l_actor = (CActor) GetEntity();
		
		l_pos 					= l_actor.GetWorldPosition();
		l_waterLevel 			= theGame.GetWorld().GetWaterLevel( l_pos );
		l_distanceFromWater		= l_pos.Z - l_waterLevel;
		l_distanceFromGround 	= l_actor.GetDistanceFromGround( maxDistanceFromGround );
		
		if( l_distanceFromGround >= maxDistanceFromGround && l_distanceFromWater >= maxDistanceFromGround )
		{
			return;
		}
		
		if( !m_effectEntity )
		{
			m_effectEntity = theGame.CreateEntity( effectTemplate, Vector(0,0,0), GetEntity().GetWorldRotation() );
		}
		
		l_contact  = l_pos;
		
		if( l_distanceFromWater < l_distanceFromGround )
		{
			l_contact.Z -= l_distanceFromWater;
			m_effectEntity.Teleport( l_contact );
			m_effectEntity.PlayEffect('water');
		}
		else
		{
			l_contact.Z -= l_distanceFromGround;
			m_effectEntity.Teleport( l_contact );
			m_effectEntity.PlayEffect('ground');
		}
		
		
		
		
		m_delayUntilNextEffect = delayBetweenEffects;
		
	}
	
}