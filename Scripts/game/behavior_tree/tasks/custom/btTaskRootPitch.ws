/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskRootPitch extends IBehTreeTask
{
	private var mac : CMovingPhysicalAgentComponent;
	
	function OnActivate() : EBTNodeStatus
	{
		if ( !mac )
		{
			mac = (CMovingPhysicalAgentComponent)GetActor().GetRootAnimatedComponent();
		}
		return BTNS_Active;
	}

	latent function Main() : EBTNodeStatus
	{
		while( true )
		{
			SleepOneFrame();
		}
		return BTNS_Active;
	}
	
}

class CBTTaskRootPitchDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskRootPitch';
}
