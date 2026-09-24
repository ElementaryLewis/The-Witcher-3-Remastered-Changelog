/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Acid extends W3DamageOverTimeEffect
{
	default effectType = EET_Acid;
	default isPositive = false;
	default powerStatType = CPS_Undefined;
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		target.SoundEvent( 'ep2_mutations_04_poison_blood_spray_enemy' );
	}
}