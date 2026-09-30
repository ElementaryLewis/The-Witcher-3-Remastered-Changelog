/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskPlayScreamSound extends IBehTreeTask
{
	public var minFrequency : float;
	public var maxFrequency : float;
	
	private var actor : CActor;
	
	function IsAvailable() : bool
	{
		return true;
	}
	
	latent function Main() : EBTNodeStatus
	{	
		var npcType : ENPCType;
		var oneTimeOnly : bool;
		
		actor = GetActor();
		npcType = GetNPCType();
		
		if ( minFrequency < 0.f || maxFrequency <= 0 )
		{
			PlaySoundEvent(npcType);
			return BTNS_Active;	
		}
		
		while ( true )
		{
			PlaySoundEvent(npcType);
			Sleep(RandRangeF(maxFrequency, minFrequency));
		}
		
		return BTNS_Active;	
	}
	
	function PlaySoundEvent( _npcType : ENPCType )
	{
		switch ( _npcType )
		{
			case ENT_AdultMale:
				actor.SoundEvent("grunt_vo_test_scream_AdultMale", 'head');
				break;
			
			case ENT_AdultFemale:
				actor.SoundEvent("grunt_vo_test_scream_AdultFemale", 'head');
				break;
			
			case ENT_ChildMale:
				actor.SoundEvent("grunt_vo_test_scream_ChildMale", 'head');
				break;
			
			case ENT_ChildFemale:
				actor.SoundEvent("grunt_vo_test_scream_ChildFemale", 'head');
				break;
			
			default:
				break;			
		}
	}
	
	function GetNPCType() : ENPCType
	{
		var voiceTagName 	: name;
		var voiceTagStr		: string;
		
		voiceTagName =  actor.GetVoicetag();
		voiceTagStr = NameToString( voiceTagName );
		
		if ( StrFindFirst(voiceTagStr, "BOY") >= 0 )
			return ENT_ChildMale;
		
		else if ( StrFindFirst(voiceTagStr, "GIRL") >= 0 )
			return ENT_ChildFemale;
			
		else if ( 	StrFindFirst(voiceTagStr, "WOMAN") >= 0 		||
					StrFindFirst(voiceTagStr, "FEMALE") >= 0  		||
					StrFindFirst(voiceTagStr, "NOBLEWOMAN") >= 0  	||
					StrFindFirst(voiceTagStr, "PROSTITUTE") >= 0 )
			return ENT_AdultFemale;
	
		else
			return ENT_AdultMale;
	}
}

class CBTTaskPlayScreamSoundDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskPlayScreamSound';
	
	editable var minFrequency : float;
	editable var maxFrequency : float;
	
	default minFrequency = -1;
	default maxFrequency = -1;
}