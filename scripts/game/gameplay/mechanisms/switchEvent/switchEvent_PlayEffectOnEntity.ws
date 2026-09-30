/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SE_PlayEffectOnEntity extends W3SwitchEvent
{
	editable var entityTag	: name;
	editable var effectName : name;
	editable var play		: bool;				default play = true;
	
	hint entityTag	= "Entity tag on which we perform";
	hint effectName = "Effect name (defined in entity), use 'all' and play=no to stop all effects";
	hint play 		= "If set to true then plays effect, else stops it";
	
	public function Perform( parnt : CEntity )
	{
		var entity : CEntity;
						
		entity = theGame.GetEntityByTag( entityTag );
		if ( !entity )
		{
			return;
		}
		
		if ( play )
		{
			entity.PlayEffect( effectName );
		}
		else
		{
			if ( effectName == 'all' )
			{
				entity.StopAllEffects();
			}
			else
			{
				entity.StopEffect( effectName );
			}
		}
	}
}