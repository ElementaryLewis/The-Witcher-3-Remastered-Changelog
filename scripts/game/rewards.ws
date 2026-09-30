/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SItemReward
{
	import var item		: name;
	import var amount	: int;
};

import struct SReward
{
	import var experience	: int;
	import var gold			: int;
	import var items		: array< SItemReward >;
	import var achievement	: int;
	import var level		: int;
};