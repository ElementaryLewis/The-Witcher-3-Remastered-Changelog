/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CSpawnTreeEntrySubDefinition extends CObject
{
	import var creatureDefinition 	: name;
	import var partyMemberId 		: name;
}
import class CPartySpawnOrganizer extends IScriptable
{
}
import class CInstantMountPartySpawnOrganizer extends CPartySpawnOrganizer
{
}
import class CCreaturePartyEntry extends CBaseCreatureEntry
{
	import var partySpawnOrganizer : CPartySpawnOrganizer;
	
	import function AddPartyMember( inEditor : bool ) : CSpawnTreeEntrySubDefinition;

	function GetContextMenuSpecialOptions( out names : array< string > )
	{
		names.PushBack( "Add rider + horse in party" );
	}
	
	function RunSpecialOption( option : int )
	{
		var horseMember : CSpawnTreeEntrySubDefinition;
		var riderMember : CSpawnTreeEntrySubDefinition;
		
		horseMember = AddPartyMember( true );
		riderMember = AddPartyMember( true );
		
		
		horseMember.creatureDefinition 	= 'horse_def';
		riderMember.creatureDefinition 	= 'rider_def';
		horseMember.partyMemberId 		= 'horse';
		riderMember.partyMemberId 		= 'rider';
		
		partySpawnOrganizer = new CInstantMountPartySpawnOrganizer in this;
	}
}
