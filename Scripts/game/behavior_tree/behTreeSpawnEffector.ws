/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import abstract class IBehTreeOnSpawnEffector extends IBehTreeObjectDefinition
{
	function Run()
	{
	}
	import final function GetActor() : CActor;
	import final function GetObjectFromAIStorage( varName : name ) : IScriptable;
};

class SpawnOnHorseEffector extends IBehTreeOnSpawnEffector
{
	editable var mountOnSpawned : CBehTreeValBool;
	
	function Run()
	{
		var horseData	: CAIStorageHorseData;
		var horseEntity : CNewNPC;
		var horseComponent : W3HorseComponent;
		var owner : CActor = GetActor();
		
		if ( !GetValBool(mountOnSpawned) )
		{
			return;
		}
		
		horseEntity = (CNewNPC)GetObjectByVar('mountEntity');
		
		if ( !horseEntity )
		{
			
			return;
		}
		
		horseComponent = horseEntity.GetHorseComponent();
		
		if ( !horseComponent )
		{
			
			return;
		}
		
		horseData = (CAIStorageHorseData)GetObjectFromAIStorage( 'HorseData' );
		horseData.horseEntity = horseEntity;
		horseData.horseComponent = horseComponent;
		horseComponent.riderSharedParams.rider = owner;
	}
}

class SetNPCTypeEffector extends IBehTreeOnSpawnEffector
{
	editable var groupType : CBehTreeValInt;
	
	function Run()
	{
		var npcType	: ENPCGroupType;
		var npc : CNewNPC;
		var owner : CActor = GetActor();
		
		npcType = GetValInt( groupType );
	
		npc = (CNewNPC)owner;
		npc.SetNPCType( npcType );
	}
}