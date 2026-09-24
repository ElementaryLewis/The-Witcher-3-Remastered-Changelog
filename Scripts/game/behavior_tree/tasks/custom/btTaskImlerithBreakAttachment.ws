/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskImlerithBreakAttachment extends IBehTreeTask
{
	var rigidMeshComp : CRigidMeshComponent;
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if( animEventName == 'BreakAttachmentShield' )
		{
			GetNPC().shieldDebris.BreakAttachment();
			rigidMeshComp = (CRigidMeshComponent)GetNPC().shieldDebris.GetComponentByClassName( 'CRigidMeshComponent' );
			rigidMeshComp.SetEnabled( true );
			
			
			return true;
		}
		
		return false;
	}
};

class CBTTaskImlerithBreakAttachmentDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskImlerithBreakAttachment';
};