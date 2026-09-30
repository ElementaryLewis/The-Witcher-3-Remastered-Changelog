/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SE_ManageToxicCloud extends W3SwitchEvent
{
	editable var entityTag	: name;
	editable var operations	: array< EToxicCloudOperation >;
	
	hint entityTag	= "Tag of the switch";
	hint operations	= "Operations to perform on switch";
	
	public function Perform( parnt : CEntity )
	{
		var toxicCloudEntity : W3ToxicCloud;
		var entities : array <CEntity>;
		var i : int;
		var j : int;
		
		theGame.GetEntitiesByTag( entityTag, entities );
			
		if ( entities.Size() == 0 )
		{
			LogAssert( false, "No entities found with tag <" + entityTag + ">" );
			return;
		}
		for ( i = 0; i < entities.Size(); i += 1 )
		{
			toxicCloudEntity = (W3ToxicCloud)entities[ i ];
			
			if ( !toxicCloudEntity )
			{
				LogChannel( 'Switch', "W3SE_ManageSwitch::Activate - cannot find switch with tag <" + entityTag + ">");
				return;
			}
			toxicCloudEntity.OnManageToxicCloud(operations);
		}
	}
}