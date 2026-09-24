/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import abstract class IAIParameters extends IScriptable 
{
	import function LoadSteeringGraph( fileName : string ) : CMoveSteeringBehavior;
	import function OnManualRuntimeCreation();
	
	function OnCreated() { Init(); }
	function Init(){}
};
import abstract  class CAIParameters 	extends IAIParameters	{};
import abstract class CAIDefaults 	extends IAIParameters 	{};

import abstract class IAITree extends IAIParameters 
{
	import protected var aiTreeName : string;

	import final function OnCreated();
	
	function Init(){}

	
	
};
import abstract class CAITree extends IAITree {};
import abstract class CAIBaseTree extends IAITree {};


import abstract class ICustomValAIParameters extends CAIRedefinitionParameters
{
	function SetCNameValue( value : name ){} 
}

class CHorseTagAIParameters extends ICustomValAIParameters
{
	editable var preferedHorseTag : name;
	function SetCNameValue( value : name )
	{ 
		preferedHorseTag = value; 
	} 
}