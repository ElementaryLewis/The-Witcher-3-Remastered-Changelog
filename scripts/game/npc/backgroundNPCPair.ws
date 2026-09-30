/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EBackgroundNPCWork_Paired
{
	EBNWP_None,
	EBNWP_DrinkingOpposite,
	EBNWP_Saw,
	EBNWP_Q106KilledbyMorowa
}


enum EBgNPCType
{
	EBNPCT_None,
	EBNPCT_Master,
	EBNPCT_Slave
}


struct SBackgroundPairSpawnedEntity
{
	editable var entityTemplate : CEntityTemplate;
	editable var slotName : name;					
	editable var referenceName : name;				
};


struct SMountEvent
{
	editable var animEventName : name;					
	editable var entityReferenceName : name;			
	editable var newSlotName : name;					
	editable var entityContainingSlot : EBgNPCType;
};


statemachine class W3NPCBackgroundPair extends CGameplayEntity
{
	public editable var work : EBackgroundNPCWork_Paired;						
	public editable var entitiesToSpawn : array<SBackgroundPairSpawnedEntity>;	
	private var spawnedEntities : array<CEntity>;								
	private var currentAttachments : array<CEntity>;							
	public var slave, master : W3NPCBackground;									
	public editable var mountEvents : array<SMountEvent>;						
	public var masterAC, slaveAC : CAnimatedComponent;							
	
	
	event OnSpawned(spawnData : SEntitySpawnData)
	{
		var i : int;	
		var tmp : Vector;
		var newMaster, newSlave : W3NPCBackground;
		
		if(work == EBNWP_None)
		{
			LogAssert(false,"W3NPCBackgroundPair.OnSpawned : <<" + this + ">> has no work type chosen, aborting!");
			return false;
		}
		
		super.OnSpawned(spawnData);
				
		spawnedEntities.Grow(entitiesToSpawn.Size());
		currentAttachments.Grow(entitiesToSpawn.Size());
			
		for(i=0; i<entitiesToSpawn.Size(); i+=1)
		{									
			
			spawnedEntities[i] = theGame.CreateEntity(entitiesToSpawn[i].entityTemplate, tmp);	
			spawnedEntities[i].CreateAttachment(this, entitiesToSpawn[i].slotName);
			currentAttachments[i] = this;
			
			if(!spawnedEntities[i])
			{
				LogAssert(false, "W3NPCBackgroundPair.OnSpawned: pair <<" + this + ">> cannot find slot <<" + entitiesToSpawn[i].slotName + ">>, skipping!");
				continue;
			}
			
			LogBgNPC("Initial spawn : pair <<" + this + ">> spawned <<" + spawnedEntities[i] + ">> on slot <<" + entitiesToSpawn[i].slotName + ">>");
			
			
			if(entitiesToSpawn[i].referenceName == 'master')
			{
				newMaster = (W3NPCBackground)spawnedEntities[i];
				
				if(!newMaster)
				{
					LogAssert(false, "W3NPCBackgroundPair.OnSpawned: pair <<" + this + ">> master entity must be of class W3NPCBackground - aborting!");
					return false;
				}
				
				
				if(master)
				{
					LogAssert(false, "W3NPCBackgroundPair.OnSpawned: pair <<" + this + ">> master entity is defined more than once - aborting!");
					return false;
				}
				
				master = newMaster;
				master.SetParentPairedBackgroundNPCEntity(this);					
				masterAC = (CAnimatedComponent)master.GetComponent( 'man_base' );
				
				if(!masterAC)
				{
					LogAssert(false, "W3NPCBackgroundPair.OnSpawned: pair <<" + this + ">> master's root animated component not found! Make sure it's named 'man_base' - aborting!");
					return false;
				}
			}
			else if(entitiesToSpawn[i].referenceName == 'slave')
			{
				newSlave = (W3NPCBackground)spawnedEntities[i];
				
				if(!newSlave)
				{
					LogAssert(false, "W3NPCBackgroundPair.OnSpawned: pair <<" + this + ">> slave entity must be of class W3NPCBackground - aborting!");
					return false;
				}
				
				
				if(slave)
				{
					LogAssert(false, "W3NPCBackgroundPair.OnSpawned: pair <<" + this + ">> slave entity is defined more than once - aborting!");
					return false;
				}
			
				slave = newSlave;
				slave.SetParentPairedBackgroundNPCEntity(this);
				slaveAC = (CAnimatedComponent)slave.GetComponent( 'man_base' );
				
				if(!slaveAC)
				{
					LogAssert(false, "W3NPCBackgroundPair.OnSpawned: pair <<" + this + ">> slave's root animated component not found! Make sure it's named 'man_base' - aborting!");
					return false;
				}
			}
		}
		
		LogAssert(master, "W3NPCBackgroundPair.OnSpawned: cannot find master entity in <<" + this + ">> - aborting!!!");
		LogAssert(slave, "W3NPCBackgroundPair.OnSpawned: cannot find slave entity in <<" + this + ">> - aborting!!!");
		
		if(!master || !slave)
			return false;
				
		
		masterAC.SetBehaviorVariable( 'isMaster', 1.f );
		slaveAC.SetBehaviorVariable( 'isMaster', 0.f );
		
		
		masterAC.SetBehaviorVariable( 'WorkTypeEnum_Paired', (int)work );
		slaveAC.SetBehaviorVariable( 'WorkTypeEnum_Paired', (int)work );
		
		
		PushState('DoWork');
	}
		
	
	
	public function AttachEntityToSlotRegardlessOfSlotType(i : int, slotName : name, entityContainingSlot : EBgNPCType) : bool
	{
		var slotEntity : CEntity;
		var ret : bool;
	
		
		switch(entityContainingSlot)
		{
			case EBNPCT_None : 
				slotEntity = this;
				break;
			case EBNPCT_Master : 
				slotEntity = master;
				break;
			case EBNPCT_Slave : 
				slotEntity = slave;
				break;
		}
		
		
		
		
		if(currentAttachments[i] != slotEntity)
			spawnedEntities[i].BreakAttachment();
			
		ret = spawnedEntities[i].CreateAttachment(slotEntity, slotName);
		if(ret)
			currentAttachments[i] = slotEntity;
		else
			LogAssert(false, "W3NPCBackgroundPair.OnAnimEvent: bg entity <<" + this + ">> :: entity <<" + spawnedEntities[i] + ">> did not get attached to slot <<" + slotName + ">> of <<" + slotEntity + ">> !!!");
		return ret;
	}	
	
	
	public function IncomingAnimEvent(eventName : name)
	{
		var i,j : int;
		var knownEvent, knownEntity : bool;
	
		knownEvent = false;
		for(j=0; j<mountEvents.Size(); j+=1)
		{
			
			if(eventName == mountEvents[j].animEventName)
			{
				knownEvent = true;
				knownEntity = false;
				for(i=0; i<entitiesToSpawn.Size(); i+=1)
				{
					
					if(mountEvents[j].entityReferenceName == entitiesToSpawn[i].referenceName)
					{
						knownEntity = true;
						AttachEntityToSlotRegardlessOfSlotType(i, mountEvents[j].newSlotName, mountEvents[j].entityContainingSlot);
						
						LogBgNPC("Event mount - pair <<" + this + ">> got event <<" + eventName + ">> : mounting <<" + spawnedEntities[i] + ">> to slot <<" + mountEvents[j].newSlotName + ">> of <<" + mountEvents[j].entityContainingSlot + ">>");
						break;
					}
				}		

				if(!knownEntity)
					LogAssert(false, "W3NPCBackgroundPair.OnAnimEvent: <<" + this + ">> unknown entity with reference name = <<" + mountEvents[j].entityReferenceName + ">> - nothing done!");		
			}
		}
		
		if(!knownEvent)
			LogAssert(false, "W3NPCBackgroundPair.OnAnimEvent: <<" + this + ">> unknown anim event called <<" + eventName + ">> - nothing done!");		
	}
}

state DoWork in W3NPCBackgroundPair
{
	event OnEnterState( prevStateName : name )
	{		
		DoWork();
	}
		
	entry function DoWork()
	{	
		var ass : SAnimatedComponentSyncSettings;
		
		ResetAnimatedComponentSyncSettings( ass );
		
		
		while( true )
		{
			SleepOneFrame();
			parent.slaveAC.SyncTo( parent.masterAC, ass );
		}
	}
}