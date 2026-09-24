/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskNPCNotInFrontOfPLayer extends IBehTreeTask
{
	var coneAngle		: float;
	var angleOffset		: float;
	var coneRange		: float;
	
	var playerHeading : float;
	var npc : CNewNPC;
	var distance : float;
	var testedAngle : float;
	
	function IsAvailable() : bool
	{
		
		playerHeading = thePlayer.GetHeading() + angleOffset;
		
		
		
		
		
		
		npc = GetNPC();
		distance = VecDistance2D( npc.GetWorldPosition(), thePlayer.GetWorldPosition() );
		testedAngle = NodeToNodeAngleDistance( npc, thePlayer );
		
		if ( distance < coneRange )
		{
			return false;
		}
		
		if ( testedAngle < ( coneAngle/2 ) )
		{
			return false;
		}

		return true;
	}
}


class CBTTaskNPCNotInFrontOfPLayerDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTTaskNPCNotInFrontOfPLayer';

	editable var coneAngle		: float;
	editable var angleOffset	: float;
	editable var coneRange		: float;
	
	default coneAngle = 90;
	default angleOffset = 0;
	default coneRange = 5;
}
