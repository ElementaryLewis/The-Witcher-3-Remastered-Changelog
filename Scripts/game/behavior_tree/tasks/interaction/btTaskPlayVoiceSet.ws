/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskPlayVoiceSet extends IBehTreeTask
{		
	public var voiceSet 					: string;
	public var priority 					: int;
	public var waitUntilSpeechIsFinished 	: bool;
	public var randomizeSpeechStart 		: bool;
	public var dontActivateWhileSpeaking 	: bool;
	public var speachStartDelay				: float;
	public var playOnDeactivate				: bool;	
	public var playAfterXtimes				: int;
	public var breakCurrentSpeach			: bool;
	
	private var iterator : int;
	
	function IsAvailable() : bool
	{
		
		if ( dontActivateWhileSpeaking )
			return !GetActor().IsSpeaking();
			
		return true;
	}
	
	latent function Main() : EBTNodeStatus
	{		
		var owner : CActor = GetActor();
		
		if ( playOnDeactivate )
			return BTNS_Active;
		
		if ( speachStartDelay > 0 )
		{
			Sleep(speachStartDelay);
		}
		
		if( randomizeSpeechStart )
		{
			Sleep( RandRangeF( 5.0, 0.0 ) );
		}
		
		if ( !owner.PlayVoiceset( priority, voiceSet, breakCurrentSpeach ) )
		{
			return BTNS_Failed;
		}
		
		if( waitUntilSpeechIsFinished )
		{
			Sleep( 0.2f );
			
			while( owner.IsSpeaking() )
			{
				SleepOneFrame();
			}
		}
		
		return BTNS_Completed;
	}
	
	function OnDeactivate()
	{
		if ( playOnDeactivate )
		{
			iterator += 1;
			
			if ( iterator >= playAfterXtimes )
			{
				GetActor().PlayVoiceset( priority, voiceSet, breakCurrentSpeach );
				iterator = 0;
			}
		}
	}
	
}

class CBTTaskPlayVoiceSetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskPlayVoiceSet';

	editable var voiceSet 					: CBehTreeValString;
	editable var priority 					: CBehTreeValInt;
	editable var waitUntilSpeechIsFinished 	: bool;
	editable var randomizeSpeechStart 		: bool;
	editable var dontActivateWhileSpeaking 	: bool;
	editable var speachStartDelay			: float;
	editable var playOnDeactivate			: bool;
	editable var playAfterXtimes			: int;
	editable var breakCurrentSpeach			: bool;
	
	default waitUntilSpeechIsFinished 		= true;
	default randomizeSpeechStart 			= false;
	default dontActivateWhileSpeaking 		= false;
	default speachStartDelay 				= -1.f;
	default playAfterXtimes 				= 0;
	default breakCurrentSpeach 				= false;
	
	hint priority = "Clamped between 0 - 75 ";
	hint playAfterXtimes = "Only works with playOnDeactivate";

}

