/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3IllusionaryAppearance extends W3IllusionaryObstacle
{
	
	
	private editable var realAppearance			: string;
	
	default realAppearance = "true_form";
	default focusAreaIntensity	= 0.25f;
	
	
	public function Dispel()
	{
		PlayEffect('dissapear');
		AddTimer('DeactivateFocusArea', m_disappearanceEffectDuration, false, , , true);
		AddTimer('RemoveIllusion', m_disappearanceEffectDuration, false, , , true);
		FactsAdd( m_addFactOnDispel, 1 );
	}
	
	
	private timer function RemoveIllusion( _delta:float , id : int)
	{
		ApplyAppearance( realAppearance );
	}
}