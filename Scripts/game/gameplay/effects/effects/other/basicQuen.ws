/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_BasicQuen extends CBaseGameplayEffect
{
	private var quenEntity : W3QuenEntity;
	
	default effectType = EET_BasicQuen;
	default isPositive = true;
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		CacheQuen();		
	}
	
	private final function CacheQuen()
	{
		quenEntity = ( W3QuenEntity )GetWitcherPlayer().GetSignEntity( ST_Quen );
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		
		CacheQuen();
	}
	
	
	public final function GetStacks() : int
	{
		if( !quenEntity )
		{
			
			CacheQuen();
		}
		
		return CeilF( 100.f * quenEntity.GetShieldHealth() / quenEntity.GetInitialShieldHealth() );
	}
	
	public final function GetMaxStacks() : int
	{
		return 100;
	}
}