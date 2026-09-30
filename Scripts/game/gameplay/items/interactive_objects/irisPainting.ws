/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3IrisPainting extends CGameplayEntity
{
	
	
	
	private editable var portalHP 		: int; 		default portalHP = 3;
	
	private var m_PortalCurrentHP 		: int;
	private var m_IsOpen				: bool;
	private var m_IsReady				: bool;
	private var m_ChargingTotalDuration	: float;	default m_ChargingTotalDuration = 8.0f;
	private var m_ChargingStepDuration	: float;
	
	private var m_LocktagsOn			: bool;
	
	
	
	public function IsOpen()			:bool 	{		return m_IsOpen;	}
	public function IsReady()			:bool	{		return m_IsReady;	}
	
	
	
	event OnWeaponHit (act : W3DamageAction)
	{
		if( !m_IsOpen )
			return false;
			
		if( (W3NightWraithIris ) act.attacker )
			return false;
			
		
		ReducePortalHealth( 3 );
	}
	
	
	event OnBoltHit()
	{
		ReducePortalHealth( 3 );	
	}
	
	
	event OnFireHit(entity : CGameplayEntity)
	{
		if( !m_IsOpen )
			return false;
			
		ReducePortalHealth( 3 );
	}
	
	
	event OnAardHit( sign : W3AardProjectile )
	{	
		if( !m_IsOpen )
			return false;
			
		
		ReducePortalHealth( 3 );
	}	
	
	
	event OnIgniHit( sign : W3IgniProjectile )
	{
		if( !m_IsOpen )
			return false;
			
		
		ReducePortalHealth( 3 );
	}
	
	
	private function IncreasePortalHealth( _Amount : int )
	{		
		m_PortalCurrentHP += _Amount;
		
		
		
		
	}
	
	
	private function ReducePortalHealth( _Amount : int )
	{		
		m_PortalCurrentHP -= _Amount;
		m_PortalCurrentHP = Clamp( m_PortalCurrentHP, 0, portalHP );
		
		
		
		RemoveTimer( 'ReadyPortal' );
		
		if( m_PortalCurrentHP <= 0 )
		{
			DestroyPortal();
		}
		else
		{
			
		}
	}
	
	
	private function PlayProperHealthFX()	
	{
		StopEffect('force_lv1');
		StopEffect('force_lv2');
		StopEffect('force_lv3');
		
		if( m_PortalCurrentHP <= portalHP * 0.34 )
		{
			PlayEffect('force_lv1');
		}
		else if( m_PortalCurrentHP <= portalHP * 0.67 )
		{
			PlayEffect('force_lv2');
		}
		else
		{
			PlayEffect('force_lv3');
		}		
	}
	
	
	public function OpenPortal()
	{
		m_ChargingStepDuration = m_ChargingTotalDuration / ( portalHP + 1 );
		
		m_PortalCurrentHP 		= 0;
		m_IsOpen 				= true;
		
		AddLockTags();
		
		AddTimer( 'ChargePortal', m_ChargingStepDuration , true  );
		
		
		
		PlayEffect( 'connection' );
		PlayEffect('force_level_up');
	}
	
	
	private timer function ChargePortal( delta : float , id : int )
	{			
		if( m_PortalCurrentHP == portalHP )
		{
			AddTimer( 'ReadyPortal', m_ChargingStepDuration );
		}
		else
		{
			IncreasePortalHealth( 1 );
		}
	}	
	
	
	private timer function UpdatePortalTags( delta : float , id : int )
	{
		if( !m_LocktagsOn && VecDistance( GetWorldPosition(), thePlayer.GetWorldPosition() ) < 5 )
		{
			AddLockTags();
		}
		else if( m_LocktagsOn ) 
		{
			RemoveLockTags();
		}
	}
	
	
	private timer function ReadyPortal( delta : float , id : int )
	{	
		m_IsReady = true;
	}
	
	
	private function AddLockTags()
	{
		this.AddTag('softLock');
		this.AddTag('softLock_Bomb');
		this.AddTag('softLock_Bolt');
		this.AddTag('softLock_Aard');
		this.AddTag('softLock_Igni');
		this.AddTag('softLock_Weapon');	
		
		m_LocktagsOn = true;
	}
	
	
	private function RemoveLockTags()
	{
		this.RemoveTag('softLock');
		this.RemoveTag('softLock_Bomb');
		this.RemoveTag('softLock_Bolt');
		this.RemoveTag('softLock_Aard');
		this.RemoveTag('softLock_Igni');
		this.RemoveTag('softLock_Weapon');
		
		m_LocktagsOn = false;
	}
	
	
	public function DestroyPortal()
	{
		PlayEffect( 'breaking_connection' );		
		Close();		
	}
	
	
	public function Close()
	{
		
		StopEffect( 'connection' );		
		StopEffect('force_lv1');
		StopEffect('force_lv2');
		StopEffect('force_lv3');
		
		RemoveTimer( 'ReadyPortal' );
		RemoveTimer( 'ChargePortal' );
		RemoveTimer( 'UpdatePortalTags' );
		
		RemoveLockTags();
		
		m_IsOpen 	= false;
		m_IsReady 	= false;
		
		theGame.GetBehTreeReactionManager().CreateReactionEvent( this, 'IrisPortalClosed', 1, 100, -1, -1, true );
	}

}