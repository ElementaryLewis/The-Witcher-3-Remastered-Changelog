/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Replacer extends CR4Player 
{
	var level : int;
	
	public function GetLevel() : int
	{
		return level;
	}
	
	public function SetLevel( lev : int )
	{
		level = lev;
	}
}


function GetReplacerPlayer() : W3Replacer
{
	return (W3Replacer)thePlayer;
}