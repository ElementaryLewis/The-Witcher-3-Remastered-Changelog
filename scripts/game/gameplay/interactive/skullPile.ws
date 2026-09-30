/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CSkullPileEntity extends CGameplayEntity
{	
	public editable	var factName 			: string;	default factName			= "CollidedAlert";
	public editable	var tagToCollideWith	: name;		default tagToCollideWith	= 'PLAYER';
	var intact : bool;
	var destructionComp : CDestructionSystemComponent;
	
	default intact = true;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var  ent : CEntity = activator.GetEntity();
		
		if( !intact )
		{
			return false;
		}
		
		if ( ent.HasTag( tagToCollideWith ) )
		{
			if( !FactsDoesExist( factName ) )
			{
				FactsAdd( factName );
			}
		}
		
		if( activator.GetEntity() == thePlayer )
		{
			destructionComp = (CDestructionSystemComponent)GetComponentByClassName( 'CDestructionSystemComponent' );
			destructionComp.ApplyFracture();
			
			intact = false;
			
			return true;
		}
		
		return false;
	}
}