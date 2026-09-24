/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskOlgierdPhantomAttack extends IBehTreeTask
{	
	private var phantomTemplate : CEntityTemplate;
	private var phantom : W3CiriPhantom;

	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if( animEventName == 'PhantomR' )
		{
			
			return true;
		}
		else if( animEventName == 'PhantomL' )
		{
			
			return true;
		}
		
		return false;
	}
	
	private function SpawnPhantomWithAnim( position : Vector, rotation : EulerAngles, rightSide : bool  )
	{
		
		var res : bool;

		phantom = (W3CiriPhantom)theGame.CreateEntity( phantomTemplate, position, rotation );
		
		if( phantom )
		{	
			if( rightSide )
			{
				phantom.RaiseEvent( 'PhantomR' );
			}
			else
			{
				phantom.RaiseEvent( 'PhantomL' );
			}
			
			
			
			
				
			
			
		}
	}
	
	function OnDeactivate()
	{
		phantom.Destroy();
	}
	
	function Initialize()
	{
		phantomTemplate = (CEntityTemplate)LoadResource( 'olgierd_phantom' );
	}
}

class CBTTaskOlgierdPhantomAttackDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskOlgierdPhantomAttack';
}