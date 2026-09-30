/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_BookshelfBuff extends CBaseGameplayEffect
{
	default effectType = EET_BookshelfBuff;
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "message_common_bookshelf_buff_applied" ),, true );
		super.OnEffectAdded( customParams );
	}
	
	protected function CumulateWith( effect : CBaseGameplayEffect )
	{
		theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "message_common_bookshelf_buff_applied" ),, true );
		super.CumulateWith( effect );
	}
}