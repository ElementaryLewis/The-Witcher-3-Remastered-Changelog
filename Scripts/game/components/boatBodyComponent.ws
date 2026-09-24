/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import statemachine class CBoatBodyComponent extends CRigidMeshComponent
{
	default autoState = 'Idle';

	
    
    
    
    
    event OnComponentAttached()
	{
		GotoStateAuto();
	}
	
	
	event OnCutsceneStarted(){}
	event OnCutsceneEnded(){}
	
	
	import function TriggerCutsceneStart();
	import function TriggerCutsceneEnd();
}