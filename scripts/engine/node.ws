/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CNode extends CObject
{
	
	import final function GetName() : string;
	
	
	import final function GetLocalPosition() : Vector;
	
	
	import final function GetLocalRotation() : EulerAngles;
	
	
	import final function GetLocalScale() : Vector;
	
	
	import final function GetLocalToWorld() : Matrix;
	
	
	import final function GetWorldPosition() : Vector;
	
	
	import final function GetWorldRotation() : EulerAngles;
	
	
	import final function GetWorldForward() : Vector;
	
	
	import final function GetWorldRight() : Vector;
	
	
	import final function GetWorldUp() : Vector;
	
	
	import final function GetHeading() : float;
	
	
	import final function GetHeadingVector() : Vector;
	
	
	import final function HasTag( tag : name ) : bool;
	
	
	import final function GetTags() : array< name >;
	
	
	import final function SetTags( tags : array< name > );
	
	
	import final function GetTagsString() : string;
			
	public function AddTag(tag : name)
	{
		var tags : array<name>;
	
		tags = GetTags();
		ArrayOfNamesPushBackUnique(tags, tag);
		SetTags(tags);		
	}
}


import function FindClosestNode( position : Vector, nodes : array< CNode > ) : CNode;


import function SortNodesByDistance( position : Vector, out nodes : array< CNode > );