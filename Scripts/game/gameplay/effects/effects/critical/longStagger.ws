/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_LongStagger extends W3Effect_Stagger
{
	default criticalStateType 		= ECST_LongStagger;
	default effectType 				= EET_LongStagger;
	
	private var owner : CEntity;
	
	public function OnTimeUpdated(dt : float)
	{
		if( !owner )
		{
			owner = EntityHandleGet( creatorHandle );
		}
		
		if( owner && owner.HasTag( 'fairytale_witch' ) )
		{
			timeToEnableDodge = 1.f;
		}
		
		super.OnTimeUpdated(dt);
	}
}