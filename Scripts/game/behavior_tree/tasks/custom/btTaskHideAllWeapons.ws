/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskHideAllWeapons extends IBehTreeTask
{
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC;
		
		npc.SetRequiredItems( 'None', 'None' );
		npc.ProcessRequiredItems( true );
		return BTNS_Active;
	}
}
class CBTTaskHideAllWeaponsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskHideAllWeapons';
}