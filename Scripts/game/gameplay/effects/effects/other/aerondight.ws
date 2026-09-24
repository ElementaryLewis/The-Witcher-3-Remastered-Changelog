/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Aerondight extends CBaseGameplayEffect
{
	private var m_maxCount					: int;
	private saved var m_currCount			: int;
	private saved var m_wasDischarged		: bool;
	private saved var m_aerondightTime		: float;
	private var m_attribute					: SAbilityAttributeValue;
	private var m_stacksPerLevel			: SAbilityAttributeValue;
	private saved var m_currChargingEffect	: name;	
	private var m_aerondightDelay			: float;
	private saved var timeOfPause			: GameTime;
	
		default effectType 				= EET_Aerondight;
		default isPositive 				= true;
	
	event OnUpdate( deltaTime : float )
	{
		m_aerondightTime -= deltaTime;
		
		if( m_aerondightTime <=0 && m_currCount > 0 )
		{
			m_currCount -= 1;
			UpdateAerondightFX();
			ResetAerondightTime();
		}
		
		super.OnUpdate( deltaTime );
	}
	
	public function OnTimeUpdated(dt : float)
	{
		super.OnTimeUpdated( dt );
	}
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		ResetAerondightTime();
		
		super.OnEffectAdded( customParams );
	}
	
	event OnEffectAddedPost()
	{
		LoadParams();		
	
		super.OnEffectAddedPost();
	}
	
	private function LoadParams()
	{
		var val : SAbilityAttributeValue;
		
		m_attribute = target.GetAbilityAttributeValue( 'AerondightEffect', 'perm_dmg_boost' );
		m_stacksPerLevel = target.GetAbilityAttributeValue( 'AerondightEffect', 'stacks_per_level' );
		
		val = target.GetAbilityAttributeValue( 'AerondightEffect', 'maxStacks' );
		m_maxCount = (int) val.valueAdditive;
		val = target.GetAbilityAttributeValue( 'AerondightEffect', 'stackDrainDelay' );
		m_aerondightDelay = val.valueAdditive;
	}
	
	public function OnLoad( t : CActor, eff : W3EffectManager )
	{
		super.OnLoad( t, eff );
		
		LoadParams();
		ResetAerondightTime();
	}
	
	event OnEffectRemoved()
	{
		StopAerondightEffects();
		
		super.OnEffectRemoved();
	}
		
	public function IncreaseAerondightCharges( attackName : name )
	{
		ResetAerondightTime();
		
		if( m_wasDischarged )
		{
			m_wasDischarged = false;
			return;
		}
		
		if( m_currCount < m_maxCount && !m_wasDischarged )
		{
			if( target.IsLightAttack( attackName ) || thePlayer.GetCombatAction() == EBAT_SpecialAttack_Light )
			{
				m_currCount += 1;
			}
			else 
			{
				m_currCount = Min( m_maxCount, ( m_currCount + 2 ) );
			}
			
			UpdateAerondightFX();
		}
	}
	
	private function UpdateAerondightFX()
	{
		var l_aerondightEnt			: CItemEntity;
		var l_effectComponent		: W3AerondightFXComponent;
		var l_newChargingEffect		: name;
		
		target.GetInventory().GetCurrentlyHeldSwordEntity( l_aerondightEnt );
		
		l_effectComponent = (W3AerondightFXComponent)l_aerondightEnt.GetComponentByClassName( 'W3AerondightFXComponent' );
		
		l_aerondightEnt.StopEffect( m_currChargingEffect );
		
		l_newChargingEffect = l_effectComponent.m_visualEffects[ m_currCount - 1 ];
		
		l_aerondightEnt.PlayEffect( l_newChargingEffect );
		
		m_currChargingEffect = l_newChargingEffect;
	}
	
	public function DischargeAerondight() : bool
	{	
		var l_inv					: CInventoryComponent;
		var l_sword					: SItemUniqueId;
		var l_currPermDmgBoost		: float;
		var l_newPermDmgBoost		: float;
		var l_levelDiff				: int;
	
		l_inv = target.GetInventory();
		l_sword = l_inv.GetCurrentlyHeldSword();
		
		l_levelDiff = ( target.GetLevel() - l_inv.GetItemLevel( l_sword ) ) + 1;
		l_currPermDmgBoost = l_inv.GetItemModifierFloat( l_sword, 'PermDamageBoost' );
		
		
		if( l_currPermDmgBoost < 0 )
		{
			l_currPermDmgBoost = 0;
		}
		
		
		if( l_levelDiff * m_stacksPerLevel.valueAdditive * m_attribute.valueAdditive <= l_currPermDmgBoost )
		{
			return false;
		}
		
		m_wasDischarged = true;
		
		target.PlayEffect( 'lasting_shield_discharge' );
		l_newPermDmgBoost = l_currPermDmgBoost + m_attribute.valueAdditive;
		
		
		l_inv.SetItemModifierFloat( l_sword, 'PermDamageBoost', l_newPermDmgBoost );

		ResetCurrentCount();

		StopAerondightEffects();
		
		m_currChargingEffect = '';
		
		return true;
	}
	
	protected function OnPaused()
	{
		super.OnPaused();
		
		SetShowOnHUD( false );
		StopAerondightEffects();
		timeOfPause = theGame.GetGameTime();
	}
	
	protected function OnResumed()
	{
		var l_aerondightEnt	: CItemEntity;
		var secsInPause : float;
		var stacksLost : int;
		var timeInPause : GameTime;
		
		super.OnResumed();
		
		
		timeInPause = theGame.GetGameTime() - timeOfPause;
		secsInPause = ConvertGameSecondsToRealTimeSeconds( GameTimeToSeconds( timeInPause ) );
		stacksLost = FloorF( secsInPause / m_aerondightDelay );
		m_currCount = Max( 0, m_currCount - stacksLost );
		OnUpdate( secsInPause - stacksLost * m_aerondightDelay );	
		
		if( target.GetInventory().ItemHasTag( target.GetInventory().GetCurrentlyHeldSword(), 'Aerondight' ) )
		{
			UpdateAerondightFX();
			
			SetShowOnHUD( true );
			if( m_currChargingEffect != '' )
			{
				target.GetInventory().GetCurrentlyHeldSwordEntity( l_aerondightEnt );
				l_aerondightEnt.PlayEffect( m_currChargingEffect );
			}
		}
	}
	
	public function StopAerondightEffects()
	{
		var l_aerondightEnt			: CItemEntity;
		
		target.GetInventory().GetCurrentlyHeldSwordEntity( l_aerondightEnt );
		
		
		l_aerondightEnt.StopEffect( m_currChargingEffect );
	}
	
	protected function StopTargetFX()
	{
		super.StopTargetFX();
		
		StopAerondightEffects();
	}
	
	public function IsFullyCharged() : bool
	{
		return m_currCount == m_maxCount;
	}
	
	
	
	public function GetCurrentCount() : int
	{
		return m_currCount;
	}
	
	public function GetMaxCount() : int
	{
		return m_maxCount;
	}
	
	
	
	public function ResetAerondightTime()
	{
		m_aerondightTime = m_aerondightDelay;
	}
	
	public function ReduceAerondightStacks()
	{
		m_currCount /= 2;
		
		StopAerondightEffects();
	}
	
	public function ResetCurrentCount()
	{
		m_currCount = 0;
	}
	
}

class W3AerondightFXComponent extends CScriptedComponent
{
	editable var m_visualEffects	: array<name>;
}