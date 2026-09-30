/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3FireAura extends W3Effect_Aura
{
	default effectType = EET_FireAura;	
	
	protected function ApplySpawnsOn( entityGE : CGameplayEntity)
	{
		
		if( (CActor)entityGE )
			super.ApplySpawnsOn( entityGE );
		else
			entityGE.OnFireHit( GetCreator() );
	}
}