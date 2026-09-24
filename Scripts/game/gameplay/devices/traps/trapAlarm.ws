/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3TrapAlarm extends W3Trap
{
	
	
	
	private editable var alarmSoundString		: string;
	
	
	public function Activate( optional _Target: CNode ):void
	{
		SoundEvent( alarmSoundString );
		super.Activate( _Target );
	}
	
}