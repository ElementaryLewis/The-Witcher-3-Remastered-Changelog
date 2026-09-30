/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_CatsFeast extends W3Potion_Cat
{
	default effectType = EET_CatPerk29;
	
    default brightness = 100.f;
    default desaturation = 0.1f;

    event OnPerk29Unequipped()
    {
        SetTimeLeft( 3.f );
    }
}