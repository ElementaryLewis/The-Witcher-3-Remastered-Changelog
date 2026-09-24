/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskSetMorph extends IBehTreeTask
{
	
	
	
	public var morphOnAnimEvent		: bool;
	public var time 				: float;
	public var ratio				: float;	
	
	public var morphOnActivate		: bool;
	public var ratioOnActivate		: float;
	public var timeOnActivate		: float;
	
	public var morphOnDeactivate	: bool;
	public var ratioOnDeactivate	: float;
	public var timeOnDeactivate		: float;	
	
	private var m_morphIsLaunched	: bool;
	
	
	
	function OnActivate() : EBTNodeStatus
	{	
		if( morphOnActivate ) StartMorph( ratioOnActivate, timeOnActivate );
		return BTNS_Active;
	}
	
	
	private final function OnDeactivate()
	{
		if( morphOnDeactivate ) StartMorph( ratioOnDeactivate, timeOnDeactivate );
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{	
		if ( morphOnAnimEvent && animEventName == 'morph' )
		{
			StartMorph(ratio, time);
		}
		
		return true;
	}
	
	
	private final function StartMorph( _Ratio : float, _Time : float)
	{
		var components	: array<CComponent>;
		var i 			: int;
		
		if ( m_morphIsLaunched ) 
			return;
		
		components = GetNPC().GetComponentsByClassName( 'CMorphedMeshManagerComponent' );
		if ( components.Size() > 0 )
		{
			for ( i = 0 ; i < components.Size() ; i += 1 )
			{
				if( ( ( CMorphedMeshManagerComponent ) components[i] ).GetMorphBlend() != _Ratio )
				{
					( ( CMorphedMeshManagerComponent ) components[i] ).SetMorphBlend( _Ratio, _Time );
				}	
			}
		}
	}

}


class BTTaskSetMorphDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSetMorph';
	
	
	editable var morphOnAnimEvent			: bool;
	editable var time 						: float;
	editable var ratio						: float;	
	
	editable var morphOnActivate			: bool;
	editable var ratioOnActivate			: float;
	editable var timeOnActivate				: float;
	
	editable var morphOnDeactivate			: bool;
	editable var ratioOnDeactivate			: float;
	editable var timeOnDeactivate			: float;
	
	hint componentName 		= "Optional: Name of the morph component to modify";
	hint time 				= "Time to reach the ratio";
	hint ratio				= "ratio to morph to";
	hint morphOnAnimEvent	= "If task is used as decorator, start morph when event 'morph' is caught";
}
