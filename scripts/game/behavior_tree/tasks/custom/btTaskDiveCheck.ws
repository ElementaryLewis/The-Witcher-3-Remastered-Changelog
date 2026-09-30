/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskDiveCheck extends IBehTreeTask
{	
	
	
	
	public var frontOffset 		: float;
	public var minWaterDepth	: float;
	public var maxWaterDistance	: float;	
	
	
	function IsAvailable() : bool
	{
		return CheckWater();
	}
	
	
	function CheckWater() : bool
	{
		var l_pos, l_checkPos 	: Vector;
		var l_world 			: CWorld;
		var l_waterLevel 		: float;
		var l_waterDepth 		: float;
		var l_npc				: CNewNPC;
		var l_npcRadius			: float;
		var l_distToWater		: float;
		var l_temp1				: Vector;
		
		l_world 		= theGame.GetWorld();		
		l_pos 			= GetNPC().GetWorldPosition();		
		l_checkPos 		= l_pos + GetNPC().GetHeadingVector() * frontOffset;		
		l_waterLevel 	= l_world.GetWaterLevel(l_checkPos);
		
		l_distToWater	= l_pos.Z - l_waterLevel;
		
		if ( l_distToWater > maxWaterDistance )
			return false;
		
		l_waterDepth = theGame.GetWorld().GetWaterDepth( l_checkPos );
		
		if( l_waterDepth > 1000 ) l_waterDepth = 0;
		
		if ( l_waterDepth < minWaterDepth )
			return false;
		
		l_npc			= GetNPC();
		l_npcRadius	 	= l_npc.GetRadius();
		
		
		if ( theGame.GetWorld().SweepTest( l_checkPos , l_checkPos - Vector(0, 0, l_distToWater), l_npcRadius, l_temp1, l_temp1 ) )
		{
			return false;
		}
		
		
		return true;
	}
};


class CBTTaskDiveCheckDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDiveCheck';
	
	
	editable var frontOffset 			: float;
	editable var minWaterDepth			: float;
	editable var maxWaterDistance		: float;
	
	default minWaterDepth 		= 3;
	default maxWaterDistance 	= 5;
	default frontOffset 		= 0.f;
}