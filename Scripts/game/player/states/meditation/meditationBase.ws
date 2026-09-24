/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract state MeditationBase in W3PlayerWitcher extends ExtendedMovable
{
	event OnGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{
		
		if(!parent.GetExplCamera())
			DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( -1.5, 0.f, 0.f ), 0.5f, dt );

		return true;
	}
	
	
	public function StopRequested(optional closeUI : bool);
	
	event OnReactToBeingHit( damageAction : W3DamageAction )
	{
		var ret : bool;
		var tox : W3Effect_Toxicity;
		
		ret = virtual_parent.OnReactToBeingHit(damageAction);
		
		
		tox = (W3Effect_Toxicity)damageAction.causer;
		if(!tox)		
			StopRequested(true);
			
		return ret;
	}
}