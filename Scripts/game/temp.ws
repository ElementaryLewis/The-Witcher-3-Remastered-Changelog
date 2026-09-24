/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
exec function PlayMovieScene()
{
	var storyScene : CStoryScene;
	
	storyScene = (CStoryScene)LoadResource("movies\cutscenes\movie_player.w2scene", true);
	theGame.GetStorySceneSystem().PlayScene( storyScene, "Input" );
	
	
	
}

exec function m11cam( n : name )
{
	thePlayer.SetLoopingCameraShakeAnimName( n );
	GetWitcherPlayer().Mutation11StartAnimation();
}

exec function mut11cooldown()
{
	if( FactsQuerySum( "debug_mut11_no_cooldown" ) > 0 )
	{
		FactsRemove( "debug_mut11_no_cooldown" );
	}
	else
	{
		FactsAdd( "debug_mut11_no_cooldown" );
	}
}

exec function radialslotsstatus ()
{
	var i 				 : int;
	var j				 : int;
	var radialSlots		 : array < SRadialSlotDef >;
	
	radialSlots = thePlayer.GetBlockedSlots();
	
	for ( i = 0; i < radialSlots.Size(); i+=1 )
	{
		LogChannel('RadialSlotsBLocked', radialSlots[i].slotName + " is blocked by: "  );
		
		for ( j = 0; j < radialSlots[i].disabledBySources.Size(); j+=1 )
		{
			LogChannel('RadialSlotsBLocked', radialSlots[i].disabledBySources[j] );
		}
	}
}

exec function horsemode( mode : EHorseMode )
{
	GetWitcherPlayer().GetHorseManager().SetHorseMode( mode );
}

exec function reduceitems()
{
		var allItems : array<SItemUniqueId>;
		var i : int;
		
		thePlayer.GetInventory().GetAllItems(allItems);
		for(i=allItems.Size()-1; i >= 0; i-=1)
		{
			if ( thePlayer.GetInventory().GetItemQuantity(allItems[i]) > 10 )
			{
			thePlayer.GetInventory().RemoveItem(allItems[i], thePlayer.GetInventory().GetItemQuantity(allItems[i]) - 10 );
			}
		}
}

exec function enablemusicevents( enable : bool)
{
	theSound.SoundEnableMusicEvents(enable);
}


exec function fillChest( optional tag : name )
{
	var container : W3Container;
	
	if ( tag == '' )
	{
		container = (W3Container)theGame.GetEntityByTag( 'chest1' );
	}
	else
	{
		container = (W3Container)theGame.GetEntityByTag( tag );
	}

	if ( container )
	{
		container.GetInventory().AddAnItem('Recipe for Vermilion');
		container.GetInventory().AddAnItem('Recipe for Vitriol');
		container.GetInventory().AddAnItem('Scoiatael sword 2 schematic');
		container.GetInventory().AddAnItem('Scoiatael sword 3 schematic');

	
	}
}

exec function fillShop( optional tag : name )
{
	var npc : CNewNPC;
	
	if ( tag == '' )
	{
		npc = (CNewNPC)theGame.GetEntityByTag('ShopkeeperEntity');
	}
	else
	{
		npc = (CNewNPC)theGame.GetEntityByTag( tag );
	}
		
	
	if ( npc )
	{
		npc.GetInventory().AddAnItem('Recipe for Rubedo');
		npc.GetInventory().AddAnItem('Recipe for Rebis');
		npc.GetInventory().AddAnItem('Novigraadan sword 1 schematic');
		npc.GetInventory().AddAnItem('Novigraadan sword 4 schematic');
	}
}

exec function ListHair()
{
	var inv : CInventoryComponent;
	var witcher : W3PlayerWitcher;
	var ids : array<SItemUniqueId>;
	var size : int;
	var i : int;

	witcher = GetWitcherPlayer();
	inv = witcher.GetInventory();

	ids = inv.GetItemsByCategory( 'hair' );
	size = ids.Size();
	
	if( size > 0 )
	{
		
		for( i = 0; i < size; i+=1 )
		{
			if(inv.IsItemMounted( ids[i] ) )
				GetWitcherPlayer().DisplayHudMessage( i+": "+inv.GetItemName(ids[i]) +" (Mounted)" );
			else
				GetWitcherPlayer().DisplayHudMessage( i+": "+inv.GetItemName(ids[i]) );
		}
		
	}

}

exec function OpenDoor ( doorTag : name )
{
	var nodes : array<CNode>;
	var entity : CEntity;
	var door : W3Door;
	var doorComponent : CDoorComponent;
	var lockableEntity : W3LockableEntity;
	var i : int;
	
	for(i=0; i<nodes.Size(); i+=1)
	{
		
		
		door = (W3Door)nodes[i];
		if(door)
		{

			door.Enable(true);
			door.Unlock();
			door.Open();
			
		}
		else
		{
			
			entity = (CEntity)nodes[i];
			if( !entity )
			{
				continue;
			}
			
			doorComponent = (CDoorComponent)entity.GetComponentByClassName( 'CDoorComponent' );			
			lockableEntity = (W3LockableEntity)entity; 
			
	
			if( lockableEntity )
			{
				lockableEntity.Enable( true );
			}
			else if( doorComponent )
			{
				doorComponent.SetEnabled( true );
			}
			if( lockableEntity )
			{
				lockableEntity.Unlock();							
				
			}
			if( doorComponent )
			{					
				doorComponent.Open( true, false );					
			}
				
		}
	}
	
}
exec function FixNoticeboard( boardTag : name ) 
{
	var board : W3NoticeBoard;
	var i : int;
	
	board = ( W3NoticeBoard )theGame.GetEntityByTag( boardTag );
	
	if(board)
	{
		board.FixErrands();
	}
}

exec function IsInInterior( tag : name )
{
	var actor : CActor;
	var npc   : CNewNPC;
	var player : CR4Player;

	actor = theGame.GetActorByTag( tag );

	npc = (CNewNPC)actor;
	if ( npc )
		LogChannel('SD', "" + npc.IsInInterior() );
	else
	{
		player = (CR4Player)actor;	
		
		if ( player )
			LogChannel('SD', "" + player.IsInInterior() );		
	}
}

exec function SetHostile( ownerName : name )
{
	var owner : CActor;
	owner = theGame.GetActorByTag( ownerName ); 

	owner.SetAttitude( thePlayer, AIA_Hostile );	
}

exec function GetAtt( actor1Name : name )
{
	var actor1 : CActor;
	var attitude : EAIAttitude;

	actor1 = theGame.GetActorByTag( actor1Name ); 
	attitude = thePlayer.GetAttitude( actor1 );
		
	LogChannel( 'SD', "Att: " + attitude );
}

exec function GetActorAtt( actor1Name : name, actor2Name : name )
{
	var actor1 : CActor;
	var actor2 : CActor;
	var attitude : EAIAttitude;

	actor1 = theGame.GetActorByTag( actor1Name ); 
	actor2 = theGame.GetActorByTag( actor1Name ); 

	attitude = actor1.GetAttitude( actor2 );
		
	LogChannel( 'SD', "Att: " + attitude );
}

exec function GetActorAttGroup( actor1Name : name )
{
	var actor1 : CActor;
	var attitude : name;

	actor1 = theGame.GetActorByTag( actor1Name ); 

	attitude = actor1.GetAttitudeGroup();
		
	LogChannel( 'SD', "Att group: " + attitude );
}


exec function ForceGraphicalLOD( lodLevel : int )
{
	var w : CWorld;
	w = theGame.GetWorld();
	w.ForceGraphicalLOD( lodLevel );
}


exec function proxy()
{
	if(FactsQuerySum('debug_petards_proximity') <= 0)
		FactsAdd('debug_petards_proximity');
	else
		FactsRemove('debug_petards_proximity');
}

exec function addrepairkits()
{
	thePlayer.inv.AddAnItem('weapon_repair_kit_1',2);
	thePlayer.inv.AddAnItem('weapon_repair_kit_2',2);
	thePlayer.inv.AddAnItem('weapon_repair_kit_3',2);
	thePlayer.inv.AddAnItem('armor_repair_kit_1',2);
	thePlayer.inv.AddAnItem('armor_repair_kit_2',2);
	thePlayer.inv.AddAnItem('armor_repair_kit_3',2);
}
exec function invdebug()
{
	thePlayer.inv.AddAnItem('Short Steel Sword',1);
	thePlayer.inv.AddAnItem('Spear 2',1);
	thePlayer.inv.AddAnItem('Science',1);
	thePlayer.inv.AddAnItem('Apple',3);
	thePlayer.inv.AddAnItem('Kaedwenian Stout',3);
	thePlayer.inv.AddAnItem('Raspberries',3);
	thePlayer.inv.AddAnItem('mh301_gryphon_trophy',1);
	thePlayer.inv.AddAnItem('q103_tamara_shrine_key',3);
	thePlayer.inv.AddAnItem('Emerald',3);
	thePlayer.inv.AddAnItem('Perfume',3);
	thePlayer.inv.AddAnItem('Wraith essence',3);
	thePlayer.inv.AddAnItem('Balisse fruit',3);
	thePlayer.inv.AddAnItem('Recipe for Nigredo',3);
	thePlayer.inv.AddAnItem('Recipe for Maribor Forest 3',3);
	thePlayer.inv.AddAnItem('Hanged Man Venom 3',3);
	thePlayer.inv.AddAnItem('White Honey 1',1);
	thePlayer.inv.AddAnItem('White Gull 1',1);
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}

exec function tuten(optional e : bool)
{
	TutorialMessagesEnable(e);
}

exec function testtut( optional scriptTag : name, optional x : float, optional y : float, optional dur : float, optional dontEnableMessages : bool, optional fullscreen : bool, optional noHorResize : bool, optional addToJournal : bool )
{
	var tut : STutorialMessage;
	
	
	if(!dontEnableMessages)
		TutorialMessagesEnable(true);
		
	
	theGame.GetTutorialSystem().TutorialStart(false);
	
	
	theGame.GetTutorialSystem().HideTutorialHint('', true);
		
	
	if(fullscreen)
		tut.type = ETMT_Message;
	else
		tut.type = ETMT_Hint;
	
	if(scriptTag == '')
		tut.tutorialScriptTag = 'TutorialLadderMove';
	else
		tut.tutorialScriptTag = scriptTag;
		
	tut.disableHorizontalResize = noHorResize;
	tut.hintPosX = x;
	tut.hintPosY = y;
	
	if(x != 0 || y != 0)
		tut.hintPositionType = ETHPT_Custom;
	
	if(dur == 0)
		tut.hintDuration = -1;
	else
		tut.hintDuration = dur;		
		
	tut.hintDurationType = ETHDT_Custom;
	tut.canBeShownInMenus = true;
	tut.canBeShownInDialogs = true;
	tut.glossaryLink = true;
	tut.forceToQueueFront = true;
	tut.force = true;
	
	if( addToJournal )
		tut.journalEntryName = scriptTag;
	
	
	theGame.GetTutorialSystem().DisplayTutorial(tut);
}

exec function testtutanim()
{
	if (theGame.GetTutorialSystem())
	{
		theGame.GetTutorialSystem().DEBUG_TestTutFeedback(true);	
	}
}

exec function dicoverMappin(pinTag:name)
{
	theGame.GetCommonMapManager().SetEntityMapPinDiscoveredScript(true, pinTag, true);
}

exec function closeUI()
{
	var commonMenuRef : CR4CommonMenu;
	commonMenuRef = theGame.GetGuiManager().GetCommonMenu();
	if (commonMenuRef)
	{
		commonMenuRef.CloseMenu();
	}
}

exec function itemquality()
{
	thePlayer.inv.AddAnItem('Hjalmar_Short_Steel_Sword',1);
	thePlayer.inv.AddAnItem('Rusty No Mans Land sword',1);
	thePlayer.inv.AddAnItem('Lynx School steel sword',1);
	thePlayer.inv.AddAnItem('Inquisitor sword 2',3);
	thePlayer.inv.AddAnItem('Gnomish sword 2',3);
}

exec function addFTmaps()
{
	thePlayer.inv.AddAnItem('an_skellige_map',1);
	thePlayer.inv.AddAnItem('ard_skellige_map',1);
	thePlayer.inv.AddAnItem('faroe_map',1);
	thePlayer.inv.AddAnItem('hindarsfjal_map',1);
	thePlayer.inv.AddAnItem('undvik_map',1);
	thePlayer.inv.AddAnItem('spikeroog_map',1);

}
exec function mutagentest()
{
	thePlayer.inv.AddAnItem('Dwarven spirit',5);
	thePlayer.inv.AddAnItem('Katakan mutagen',20);
	thePlayer.inv.AddAnItem('Verbena',20);
	thePlayer.inv.AddAnItem('Arenaria',20);
	thePlayer.inv.AddAnItem('Balisse fruit',20);
	thePlayer.inv.AddAnItem('Longrube',20);
	thePlayer.inv.AddAnItem('Arachas mutagen',20);
	thePlayer.inv.AddAnItem('White myrtle',20);
	thePlayer.inv.AddAnItem('Han',20);
	thePlayer.inv.AddAnItem('Nostrix',20);
	thePlayer.inv.AddAnItem('Cockatrice mutagen',20);
	thePlayer.inv.AddAnItem('Crows eye',20);
	thePlayer.inv.AddAnItem('Pringrape',20);
	thePlayer.inv.AddAnItem('Cortinarius',20);
	thePlayer.inv.AddAnItem('Volcanic Gryphon mutagen',20);
	thePlayer.inv.AddAnItem('Ribleaf',20);
	thePlayer.inv.AddAnItem('Blowbill',20);
	thePlayer.inv.AddAnItem('Ergot seeds',20);
	thePlayer.inv.AddAnItem('Celandine',20);
	thePlayer.inv.AddAnItem('Water Hag mutagen',20);
	thePlayer.inv.AddAnItem('Berbercane fruit',20);
	thePlayer.inv.AddAnItem('Bloodmoss',20);
	thePlayer.inv.AddAnItem('Green mold',20);
	
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 4');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 5');
}

exec function readabook(bookName : name)
{
	var item : SItemUniqueId;
	var items : array<SItemUniqueId>;
	
	items = thePlayer.inv.AddAnItem(bookName,1);
	item = items[0];
	thePlayer.inv.ReadBook(item);
}

exec function changeweather(weatherName : name)
{
	RequestWeatherChangeTo( weatherName , 1, false );
}

exec function showhudmess(message : string)
{
	GetWitcherPlayer().DisplayHudMessage(message);
}

exec function testreward()
{
	var i : int;
    var res : CResource;
    var jres : CJournalResource;
    var jbase : CJournalBase;
    var jquest : CJournalQuest;
    var rewards : array< name >;
    var rewrd : SReward;

    res = LoadResource( "pawelmtest");
    jres = (CJournalResource)res;
    jbase = jres.GetEntry();
    jquest = (CJournalQuest)jbase;

	LogChannel( 'QuestReward', "--------------------" );
    rewards = theGame.GetJournalManager().GetQuestRewards( jquest );
    for ( i = 0; i < rewards.Size(); i += 1 )
    {
		LogChannel( 'QuestReward', i + " " + rewards[ i ] );
		if ( theGame.GetReward( rewards[ i ], rewrd ) )
		{
			LogChannel( 'QuestReward', "    " + rewrd.gold + " " + rewrd.experience + " " + rewrd.items.Size() );	
		}
	}
}

exec function untut() 
{
	theGame.Unpause( "TutorialPopup" );
}

exec function eqbomb(itemName : name, optional slotID : int ) 
{
	var items 	: array<SItemUniqueId>;
	var inv : CInventoryComponent;
	
	
	inv = GetWitcherPlayer().GetInventory();
	
	inv.AddAnItem(itemName,5);
	items = inv.GetItemsIds(itemName);
	
	if( slotID > 0 )
	{
		slotID += EES_Quickslot1 - 1;
	}
	
	GetWitcherPlayer().EquipItem( items[0], slotID);	
}

exec function FD( n : float, f : float, dt : float, ds : float)
{
	
	
	theGame.GetFocusModeController().SetFadeParameters( n, f, dt, ds );
}

exec function dismember()
{
	var actor 				: CActor;	
	var dismembermentComp 	: CDismembermentComponent;
	var wounds				: array< name >;
	var usedWound			: name;
	
	actor = thePlayer.GetTarget();
	if(!actor) return;
	dismembermentComp = (CDismembermentComponent)(actor.GetComponentByClassName( 'CDismembermentComponent' ));
	if(!dismembermentComp) return;
	
	dismembermentComp.GetWoundsNames( wounds, WTF_Explosion );
	
	if ( wounds.Size() > 0 )
					usedWound = wounds[ RandRange( wounds.Size() ) ];
					
	actor.SetDismembermentInfo( usedWound, actor.GetWorldPosition() - actor.GetWorldPosition(), true );
	actor.AddTimer( 'DelayedDismemberTimer', 0.05f );
}

exec function pb_test()
{
	var actor : CActor;
	var entities : array< CGameplayEntity >;

	FindGameplayEntitiesInRange( entities, thePlayer, 20.0f, 100, '', FLAG_ExcludePlayer );
}

exec function boat_destr( idxParts : int, index : int )
{
	var i : int;
	var entity : CEntity;
	var entities : array< CGameplayEntity >;
	var drop : CDropPhysicsComponent;
	var dropCompName : string;
	var rigidMeshComp : CRigidMeshComponent;
	var boatDestruction : CBoatDestructionComponent;

	FindGameplayEntitiesInRange( entities, thePlayer, 20.0f, 100, '', FLAG_ExcludePlayer );
	for ( i = 0; i < entities.Size(); i+=1 )
	{
		entity = entities[ i ];
		boatDestruction = (CBoatDestructionComponent)entity.GetComponentByClassName( 'CBoatDestructionComponent' );
		drop = (CDropPhysicsComponent)entity.GetComponentByClassName( 'CDropPhysicsComponent' );
		if ( boatDestruction && drop )
		{
			dropCompName = boatDestruction.partsConfig[ idxParts ].parts[ index ].componentName;	
			rigidMeshComp = (CRigidMeshComponent)entity.GetComponent( dropCompName );
			if ( rigidMeshComp )
			{
				rigidMeshComp.EnableBuoyancy( false );			
				drop.DropMeshByName( dropCompName, VecFromHeading( entity.GetHeading() ), boatDestruction.PartNameToCurveName( dropCompName ) );
			}
			
		}
	}
}

exec function test_wound( wound : name )
{
	var actor : CActor;
	var direction : Vector;
	actor = thePlayer.GetTarget();	
	if ( actor )
	{
		direction = VecNormalize( actor.GetWorldPosition() - thePlayer.GetWorldPosition() );
		actor.SetWound( wound, true, true, false, true, direction );
	}
}

exec function test_scent( actionType : EFocusEffectActivationAction, effectName : name, entityTag : name, duration : float )
{
	FocusEffect( actionType, effectName, entityTag, duration );
}

exec function r4quest()
{
	theGame.RequestMenu( 'JournalQuestMenu' );
}
exec function r4ryanalchemy()
{
	theGame.RequestMenu( 'RyanAlchemyMenu' );
}
exec function r4inventory()
{
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}

exec function FDON()
{
	theGame.GetFocusModeController().SetDimming( true );
}

exec function FDOFF()
{
	theGame.GetFocusModeController().SetDimming( false );
}

exec function FON()
{
	theGame.GetFocusModeController().EnableExtendedVisuals( true, 1.0 );
}

exec function FOFF()
{
	theGame.GetFocusModeController().EnableExtendedVisuals( false, 1.0 );
}

exec function FMON()
{
	theGame.GetFocusModeController().EnableVisuals( true, 0.0f, 0.15f );
}

exec function FMOFF()
{
	theGame.GetFocusModeController().EnableVisuals( false );
}

exec function fhint()
{
	thePlayer.PlayEffect('focus_hint');
}

exec function med(val : bool)
{
	GetWitcherPlayer().GetMedallion().Activate( val, 5.0f );
	if ( !val )
	{
		GetWitcherPlayer().GetMedallion().SetInstantIntensity( 0.0f );
	}
}

exec function addSkillPoints(amount : int)
{
	GetWitcherPlayer().AddPoints(ESkillPoint, amount, true);
}

exec function medthr(val : float)
{
	GetWitcherPlayer().GetMedallion().SetInstantIntensity( val );
}

exec function staticcam()
{
	var ent : CEntity = theGame.GetEntityByTag('static_camera');
	((CStaticCamera)ent).Run();
}

exec function gamecam( blend : float )
{
	theGame.GetGameCamera().Activate( blend );
}

exec function Ciri()
{
	theGame.ChangePlayer( "Ciri" );
	thePlayer.Debug_ReleaseCriticalStateSaveLocks();
}

exec function Geralt()
{
	theGame.ChangePlayer( "Geralt" );
	thePlayer.Debug_ReleaseCriticalStateSaveLocks();
}

exec function replaceplayer( who : string )
{
	theGame.ChangePlayer( who );
}

class CTestTrigger extends CGameplayEntity
{
	private				var entryTime	: float;
	private				var timerInterval	: float;
	
	default timerInterval = 0.0100f;
	default entryTime = 0.0f;
	
	timer function entryTimer( time : float, id : int)
	{
		
		
		
		
		
		
			
		
		
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var actor : CActor;
		var params : SCustomEffectParams;
		
		entryTime = 0;		
		if ( activator.GetEntity() )
		{
			actor = (CActor)activator.GetEntity();
			if ( actor )
			{
				params.effectType = EET_Ragdoll;
				params.creator = this;
				params.duration = 5;
				actor.AddEffectCustom(params);
			}
		}
		
		
		
		
	}	
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		
		
	}
};	

exec function TM( hoursPerMinute : float )
{
	theGame.SetHoursPerMinute( hoursPerMinute );
	
	Log("Time : " + GameTimeToString( theGame.GetGameTime() ) );
}

exec function TON()
{
	theSound.SoundEvent("gui_timelapse_loop");
	theGame.SetHoursPerMinute( 90 );
}

exec function TOFF()
{
	theSound.SoundEvent("gui_timelapse_loop_end");
	theGame.SetHoursPerMinute( 4 );
}

exec function SetMove( flag : bool )
{
	thePlayer.SetManualControl( flag, false );
}

class W3KillTestTrigger extends CGameplayEntity
{
	private				var entered : Bool;
	private				var actors : array< CActor >;
	
	editable var entityTemplate : CEntityTemplate;
	
	timer function acttimer( dt : float , id : int)
	{
		var i : int;
		for( i = 0; i < actors.Size(); i+=1 )
		{
			actors[i].Kill( 'Debug' );
			actors[i].SetBehaviorVariable( 'Ragdoll_Weight',1.0);
			actors[i].RaiseForceEvent( 'Ragdoll' );
		}
		actors.Clear();
	}
	
	function DoStuff()
	{
		var act : CActor;
		var position : Vector;
		var rotation : EulerAngles; 
		position = thePlayer.GetWorldPosition();
		rotation = thePlayer.GetWorldRotation();
		
		position += ( VecFromHeading( rotation.Yaw ) * 5.f );
		rotation.Yaw = -rotation.Yaw;
		
		act = (CActor)theGame.CreateEntity( entityTemplate, position, rotation );
		
		actors.PushBack( act );
		
		AddTimer( 'acttimer', 3.f, false );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{		
		if ( false == entered )
		{
			entered = true;
			DoStuff();
		}
	}	
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		entered = false;
	}
};

exec function autoloot()
{
	var boool : bool;
	boool = GetWitcherPlayer().HAXE3GetAutoLoot();
	GetWitcherPlayer().HAXE3SetAutoLoot(!boool);
}

exec function SM()
{
	var player : CR4Player;
	player = (CR4Player)thePlayer;
	
	if( player )
	{
		player.SetBehaviorVariable( 'simpleRot', 1.0);
	}
	
}

exec function GT()
{
	var dayTime : GameTime;
	var hours : int;
	dayTime = theGame.GetGameTime();
	
	hours = GameTimeHours( dayTime );
	
	LogChannel('hour', "Hours: " + GameTimeToString( dayTime ));
}
exec function FM()
{
	var nodes : array<CNode>;
	var i, size : int;
	var monsterClue : W3MonsterClue;
	theGame.GetNodesByTag( 'fm_object', nodes );
	
	size = nodes.Size();
	
	for( i = 0; i < size; i += 1 )
	{
		monsterClue = (W3MonsterClue)nodes[i];
		
		if( monsterClue )
		{
			monsterClue.SetAvailable( !monsterClue.GetIsAvailable() );
		}
	}
}

exec function testtutorial(msgName : name, optional isNotHint : bool, optional duration : float)
{
	var tut : STutorialMessage;
	
	if(isNotHint)
		tut.type = ETMT_Message;
	else
		tut.type = ETMT_Hint;
	
	tut.tutorialScriptTag = msgName;
	if(duration != 0)
	{
		tut.hintDurationType = ETHDT_Custom;
		tut.hintDuration = duration;
	}
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	theGame.GetTutorialSystem().DisplayTutorial(tut);
}


exec function printability(tag : name)
{
	var abilities, tmp : array<name>;
	var i, size, j : int;
	var actor : CActor;
	var counts : array<int>;
	
	if(tag == 'PLAYER')
		actor = thePlayer;
	else
		actor = theGame.GetActorByTag(tag);
		
	if(actor)
	{
		actor.GetCharacterStats().GetAbilities(abilities,true);
		size = abilities.Size();
		LogChannel('Ability', "");
		LogChannel('Ability', "Logging abilities (" + size + ") of <<" + actor + ">>");
		for(i = 0; i < size; i += 1)
		{
			
			j = tmp.FindFirst(abilities[i]);
			if(j >= 0)
			{
				counts[j] = counts[j] + 1;
				continue;
			}
			else
			{
				tmp.PushBack(abilities[i]);
				counts.PushBack(1);
			}
		}
		
		for(i = 0; i < tmp.Size(); i += 1)
		{
			LogChannel('Ability', tmp[i] + " x " + counts[i]);
		}
	}
}

exec function DebugActivateJournal() 
{
	var manager : CWitcherJournalManager;
	var entries : array< CJournalBase >;
	var tempContainer  : CJournalContainer;
	var tempContainer2 : CJournalContainer;
	var tempContainer3 : CJournalContainer;
	var tempContainer4 : CJournalContainer;
	var entryJour : CJournalBase;
	var tags : array <name>;
	var i,j,k,l,m : int;
	
	manager = theGame.GetJournalManager();
	
	

	tags.PushBack('DebugCharacter');
	tags.PushBack('DebugGlossary');
	tags.PushBack('DebugTuturialEntry');
	tags.PushBack('MonsterType1');	
	tags.PushBack('MonsterType2');	
	tags.PushBack('MonsterType5');	
	tags.PushBack('MonsterType6');	
	tags.PushBack('MonsterType7');	
	tags.PushBack('MonsterType8');	
	tags.PushBack('MonsterType9');	
	tags.PushBack('MonsterType11');	
	tags.PushBack('MonsterType12');	
	tags.PushBack('MonsterType10');	
	tags.PushBack('MonsterTypeHumans');
	tags.PushBack('bestiary_elemental');
	tags.PushBack('bestiary_golem');
	tags.PushBack('bestiary_gargoyle');
	tags.PushBack('bestiary_drowner_dead');
	tags.PushBack('bestiary_drowner');
	tags.PushBack('bestiary_hanged_man');
	tags.PushBack('bestiary_eendriag');
	tags.PushBack('bestiary_alghoul');
	tags.PushBack('bestiary_ghoul');
	tags.PushBack('bestiary_nekker');
	tags.PushBack('bestiary_nekker_warrior');
	tags.PushBack('bestiary_greater_rotfiend');
	tags.PushBack('bestiary_rotfiend');
	tags.PushBack('bestiary_basilisk');
	tags.PushBack('bestiary_forktail');
	tags.PushBack('bestiary_grave_hag');
	tags.PushBack('bestiary_water_hag');
	tags.PushBack('bestiary_fogling');
	tags.PushBack('bestiary_noonwright');
	tags.PushBack('bestiary_wight');
	tags.PushBack('bestiary_moon_wright');
	tags.PushBack('bestiary_nereid');
	tags.PushBack('bestiary_succubus');
	tags.PushBack('mestiary_manticore');
	tags.PushBack('bestiary_griffon');
	tags.PushBack('bestiary_katakan');
	tags.PushBack('Human');
	
	
	for( i = 0; i < tags.Size(); i += 1 )
	{
		entryJour = manager.GetEntryByTag(tags[i]);
		
		tempContainer = (CJournalContainer)entryJour;
		manager.ActivateEntry(entryJour,JS_Active);
		
		LogChannel('DJOUR',"");
		LogChannel('DJOUR'," entries "+i+" tag: "+tags[i]+" size "+tempContainer.GetNumChildren()+" tempContainer "+tempContainer.baseName+" bzium " + (bool)((CJournalContainer)entryJour) );
		
		for( j = 0; j < tempContainer.GetNumChildren(); j += 1 )
		{
			manager.ActivateEntry(tempContainer.GetChild(j),JS_Active);
			tempContainer2 = (CJournalContainer)tempContainer.GetChild(j);
			
			if( tempContainer2 )
			{
				LogChannel('DJOUR',"");
				LogChannel('DJOUR'," 	 entries2 "+j+" name: "+tempContainer2.baseName+" size "+tempContainer2.GetNumChildren());
			
				for( k = 0; k < tempContainer2.GetNumChildren(); k += 1 )
				{	
					tempContainer3 = (CJournalContainer)tempContainer2.GetChild(k);
					manager.ActivateEntry(tempContainer2.GetChild(k),JS_Active);
					if( tempContainer3 )
					{
						LogChannel('DJOUR',"");
						LogChannel('DJOUR'," 		 entries3 "+k+" name: "+tempContainer3.baseName+" size "+tempContainer3.GetNumChildren());

						for( l = 0; l < tempContainer3.GetNumChildren(); l += 1 )
						{
							tempContainer4 = (CJournalContainer)tempContainer3.GetChild(l);
							manager.ActivateEntry(tempContainer3.GetChild(l),JS_Active);
							if( tempContainer4 )
							{
								LogChannel('DJOUR',"");
								LogChannel('DJOUR'," 			 entries "+l+" name: "+tempContainer4.baseName+" size "+tempContainer4.GetNumChildren());

								for( m = 0; m < tempContainer4.GetNumChildren(); m += 1 )
								{
									manager.ActivateEntry(tempContainer4.GetChild(m),JS_Active);
									
								}
							}
						}
					}
					else
					{
						LogChannel('DJOUR'," entries3 is not a container: "+tempContainer2.GetChild(k).baseName);
						manager.ActivateEntry(tempContainer2.GetChild(k),JS_Active);
					}
				}
			}
			else
			{
				LogChannel('DJOUR'," \t NOT FOUND entries "+j+" name: "+tempContainer.GetChild(j).baseName+" size "+ (bool)((CJournalContainer) (tempContainer.GetChild(j)))   );
			}
		}
	}
}

class W2BalanceCalc
{
	var abilities : array<name>;
	var petards : array<SItemUniqueId>;
	var cost : float;
	var statVitality,
		statCurrentVitality,
		statEssence,
		statCurrentEssence,
		statStamina,
		statCurrentStamina,
		statFocus,
		statToxicity,
		statMorale,
		statSickness,
		statParryChance,
		statDodgeChance,
		statVitalityRegen,
		statEssenceRegen,
		statStaminaRegen,
		statFocusRegen,
		statToxicityRegen,
		statMoraleRegen,
		statSicknessRegen,
		statAttackPower,
		statSpellPower,
		statEffectDuration,
		statVitalityDmg,
		statEssenceDmg,
		statSpellDmg,
		statRange,
		statRadius,
		statPhysicalRes,
		statFireRes,
		statFrostRes,
		statShockRes,
		statPoisonRes,
		statBleedingRes,
		statIncinerationRes : float;
	
	var costVitality,
		costEssence,
		costStamina,
		costFocus,
		costToxicity,
		costMorale,
		costDrunkenness,
		costSickness,
		costParryChance,
		costDodgeChance,
		costVitalityRegen,
		costEssenceRegen,
		costStaminaRegen,
		costFocusRegen,
		costToxicityRegen,
		costMoraleRegen,
		costDrunkennessRegen,
		costSicknessRegen,
		costAttackPower,
		costSpellPower,
		costEffectDuration,
		costVitalityDmg,
		costEssenceDmg,
		costSpellDmg,
		costRange,
		costRadius,
		costPhysicalRes,
		costFireRes,
		costFrostRes,
		costShockRes,
		costPoisonRes,
		costBleedingRes,
		costIncinerationRes : float;
	var costconstVitality,
		costconstEssence,
		costconstStamina,
		costconstFocus,
		costconstToxicity,
		costconstMorale,
		costconstDrunkenness,
		costconstSickness,
		costconstParryChance,
		costconstDodgeChance,
		costconstVitalityRegen,
		costconstEssenceRegen,
		costconstStaminaRegen,
		costconstFocusRegen,
		costconstToxicityRegen,
		costconstMoraleRegen,
		costconstDrunkennessRegen,
		costconstSicknessRegen,
		costconstAttackPower,
		costconstSpellPower,
		costconstEffectDuration,
		costconstVitalityDmg,
		costconstEssenceDmg,
		costconstSpellDmg,
		costconstRange,
		costconstRadius,
		costconstPhysicalRes,
		costconstFireRes,
		costconstFrostRes,
		costconstShockRes,
		costconstPoisonRes,
		costconstBleedingRes,
		costconstIncinerationRes : float;
	function SetActorStats(actor : CActor)
	{
		var npc : CNewNPC;
		npc = (CNewNPC)actor;
		actor.GetCharacterStats().GetAbilities(abilities, true);
		
		statVitality = npc.GetStatMax(BCS_Vitality);
		statEssence = npc.GetStatMax(BCS_Essence);
		statStamina = npc.GetStatMax(BCS_Stamina);
		statFocus = npc.GetStatMax(BCS_Focus);
		statToxicity = npc.GetStatMax(BCS_Toxicity);
		statMorale = npc.GetStatMax(BCS_Morale);
		
		statCurrentVitality = npc.GetStat( BCS_Vitality );
		statCurrentEssence = npc.GetStat( BCS_Essence );
		statCurrentStamina = npc.GetStat( BCS_Stamina, true );
		statFocus = npc.GetStat(BCS_Focus);
		statToxicity = npc.GetStat(BCS_Toxicity);
		statMorale = npc.GetStat(BCS_Morale);
		
		
	}
	function PrintActorStats(actor : CActor)
	{
		var i, size : int;
		SetCosts();
		SetActorStats(actor);
		CalculateActorCost();
		Log("------------ Actor: "+actor.GetDisplayName()+" stats START -------------");
		Log(actor);
		Log("Vitality " + statVitality);
		Log("Current Vitality " + statCurrentVitality);
		Log("Essence " + statEssence);
		Log("Current Essence " + statCurrentEssence);
		Log("Stamina " + statStamina);
		Log("Current Stamina " + statCurrentStamina);
		Log("Focus " + statFocus);
		Log("Toxicity " + statToxicity);
		Log("Morale " + statMorale);
		Log("Sickness " + statSickness);
		Log("Parry Chance " + statParryChance);
		Log("Dodge Chance " + statDodgeChance);
		Log("Vitality Regen " + statVitalityRegen);
		Log("Essence Regen " + statEssenceRegen);
		Log("Stamina Regen " + statStaminaRegen);
		Log("Focus Regen " + statFocusRegen);
		Log("Toxicity Regen " + statToxicityRegen);
		Log("Morale Regen " + statMoraleRegen);
		Log("Sickness Regen " + statSicknessRegen);
		Log("Attack Power " + statAttackPower);
		Log("Spell Power " + statSpellPower);
		Log("Effect Duration " + statEffectDuration);
		Log("Vitality Damage " + statVitalityDmg);
		Log("Essence Damage " + statEssenceDmg);
		Log("Spell Damage " + statSpellDmg);
		Log("Range " + statRange);
		Log("Radius " + statRadius);
		Log("Physical Resistance " + statPhysicalRes);
		Log("Fire Resistance " + statFireRes);
		Log("Frost Resistance " + statFrostRes);
		Log("Shock Resistance " + statShockRes);
		Log("Poison Resistance " + statPoisonRes);
		Log("Bleeding Resistance " + statBleedingRes);
		Log("Incineration Resistance " + statIncinerationRes);
		Log("Abilities: ");
		for(i=0; i<abilities.Size(); i += 1)
		{
			Log(abilities[i]);
		}
		Log("------------ Actor: "+actor.GetDisplayName()+" stats END ---------------");
	}
	function CalculateActorCost()
	{
		
	}
	function SetPlayerStats()
	{
		
		statVitality = thePlayer.GetStatMax(BCS_Vitality);
		statEssence = thePlayer.GetStatMax(BCS_Essence);
		statStamina = thePlayer.GetStatMax(BCS_Stamina);
		statFocus = thePlayer.GetStatMax(BCS_Focus);
		statToxicity = thePlayer.GetStatMax(BCS_Toxicity);
		statMorale = thePlayer.GetStatMax(BCS_Morale);
		
		

	}
	function SetCosts()
	{
		
	}
	function CalculateCostsForPlayer()
	{
		
	}
	function PrintPlayerStats()
	{
		SetPlayerStats();
		
		CalculateCostsForPlayer();
		Log("---------- Geralt stats START ------------");
		Log("Vitality " + statVitality);
		Log("Essence " + statEssence);
		Log("Stamina " + statStamina);
		Log("Focus " + statFocus);
		Log("Toxicity " + statToxicity);
		Log("Morale " + statMorale);
		Log("Sickness " + statSickness);
		Log("Parry Chance " + statParryChance);
		Log("Dodge Chance " + statDodgeChance);
		Log("Vitality Regen " + statVitalityRegen);
		Log("Essence Regen " + statEssenceRegen);
		Log("Stamina Regen " + statStaminaRegen);
		Log("Focus Regen " + statFocusRegen);
		Log("Toxicity Regen " + statToxicityRegen);
		Log("Morale Regen " + statMoraleRegen);
		Log("Sickness Regen " + statSicknessRegen);
		Log("Attack Power " + statAttackPower);
		Log("Spell Power " + statSpellPower);
		Log("Effect Duration " + statEffectDuration);
		Log("Vitality Damage " + statVitalityDmg);
		Log("Essence Damage " + statEssenceDmg);
		Log("Spell Damage " + statSpellDmg);
		Log("Range " + statRange);
		Log("Radius " + statRadius);
		Log("Physical Resistance " + statPhysicalRes);
		Log("Fire Resistance " + statFireRes);
		Log("Frost Resistance " + statFrostRes);
		Log("Shock Resistance " + statShockRes);
		Log("Poison Resistance " + statPoisonRes);
		Log("Bleeding Resistance " + statBleedingRes);
		Log("Incineration Resistance " + statIncinerationRes);
		
		Log("Used Items:");
		
		
		
		Log("---------- Geralt stats END --------------");
	}
}
exec function CostPlayer()
{
	var balanceCalculator : W2BalanceCalc;
	balanceCalculator = new W2BalanceCalc in theGame;
	balanceCalculator.PrintPlayerStats();
}
exec function CostActor(tag : name)
{
	var actor : CActor;
	var balanceCalculator : W2BalanceCalc;
	actor = theGame.GetActorByTag(tag);
	if(actor)
	{
		balanceCalculator = new W2BalanceCalc in theGame;
		balanceCalculator.PrintActorStats(actor);
	}
}
exec function CostCombat(optional combatName : string, optional range : float)
{
	var actors : array<CActor>;
	var balanceCalculator : W2BalanceCalc;
	var combatRange : float;
	var i : int;
	if(range > 0.0f)
	{
		combatRange = range;
	}
	else
	{
		combatRange = 30.0f;
	}
	actors = GetActorsInRange(thePlayer, combatRange, 1000000, '');
		Log("==============" +combatName+" Combat balance START ===============");
		balanceCalculator = new W2BalanceCalc in theGame;
		for(i = 0; i < actors.Size(); i += 1)
		{
			if(actors[i] != thePlayer)
				balanceCalculator.PrintActorStats(actors[i]);
		}
		balanceCalculator.PrintPlayerStats();
		Log("==============" +combatName+" Combat balance END ===============");
}

exec function TestAb()
{
	var actors : array<CActor>;
	var actor : CActor;
	var i, size, sizeAb : int;
	var actorName : string;
	
	actors = GetActorsInRange(thePlayer, 20.0);
	size = actors.Size();
	if(size > 0)
	{
		for (i = 0; i < size; i += 1)
		{
			actor = actors[i];
			if(actor != thePlayer)
			{
				actorName = (string)actor.GetName();
				if(actor.HasAbility('axii_debuf2'))
				{
					Log(actorName + " has ability: axii_debuf2");
				}
				else if(actor.HasAbility('axii_debuf1'))
				{
					Log(actorName + " has ability: axii_debuf1");
				}
				else
				{
					Log(actorName + " has no axii debufs");
				}
			}
		}
	}
}
exec function addabl(ablName : name)
{
	thePlayer.AddAbility(ablName);
}

exec function targetaddabl(ablName : name, tag : name)
{
	var ent : CEntity; 
	var gplEnt : CGameplayEntity; 
	
	ent = theGame.GetEntityByTag( tag );
	
	gplEnt = (CGameplayEntity)ent;
	if( gplEnt )
		gplEnt.AddAbility(ablName);
}

exec function rmvabl(ablName : name)
{
	thePlayer.RemoveAbility(ablName);
}

exec function DispSkeleton( entTag : name )
{
	var ent : CEntity; 
	var acs : array< CComponent >;
	var i, size : int;
	
	ent = theGame.GetEntityByTag( entTag );
	if ( ent )
	{
		acs = ent.GetComponentsByClassName( 'CAnimatedComponent' );
		size = acs.Size();
		
		for ( i=0; i<size; i+= 1 )
		{
			((CAnimatedComponent)acs[ i ]).DisplaySkeleton( true );
		}
	}
}

exec function DispSkeletonAll( entTag : name )
{
	var ent : CEntity; 
	var acs : array< CComponent >;
	var i, size : int;
	
	ent = theGame.GetEntityByTag( entTag );
	if ( ent )
	{
		acs = ent.GetComponentsByClassName( 'CAnimatedComponent' );
		size = acs.Size();
		
		for ( i=0; i<size; i+= 1 )
		{
			((CAnimatedComponent)acs[ i ]).DisplaySkeleton( true, true );
		}
	}
}

exec function DispSkeletonAxis( entTag : name )
{
	var ent : CEntity; 
	var acs : array< CComponent >;
	var i, size : int;
	
	ent = theGame.GetEntityByTag( entTag );
	if ( ent )
	{
		acs = ent.GetComponentsByClassName( 'CAnimatedComponent' );
		size = acs.Size();
		
		for ( i=0; i<size; i+= 1 )
		{
			((CAnimatedComponent)acs[ i ]).DisplaySkeleton( false, true );
		}
	}
}

class W3ProjectileShooterTest extends CActor
{
	public editable var projectileTemplate : CEntityTemplate;
	hint projectileTemplate = "CProjectileTrajectory entity template to be spawned.";

	public editable var targetTag : name;
	hint targetTag = "Shooting target.";
	default targetTag = 'target';

	public editable var frequency : float;
	hint frequency = "Projectile spawn frequency in Hz.";
	default frequency = 1.f;

	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		if ( projectileTemplate && IsNameValid( targetTag ) && frequency > 0.f )
		{
			AddTimer( 'Shoot', 1.f / frequency, true );
		}	
	}
	
	timer function Shoot( t : float , id : int)
	{
		var projectile : CProjectileTrajectory;
		var node : CNode;
		
		projectile = (CProjectileTrajectory) theGame.CreateEntity( projectileTemplate, GetWorldPosition() );
		node = theGame.GetNodeByTag( targetTag );

		projectile.Init( this );
		projectile.ShootProjectileAtNode( 45.f, 20.f,  node, 1000.f );
	}
	
};

exec function Hour()
{
	var time : GameTime;
	time =  GameTimeCreate( 3, 7, 0 );
	theGame.SetGameTime(time, true);
}

exec function addIngr()
{
	thePlayer.inv.AddAnItem('Flowers', 1);
	thePlayer.inv.AddAnItem('Dwarven spirit', 1);
	thePlayer.inv.AddAnItem('Vial', 1);
}

exec function ParryStart( flag : bool )
{
	if ( flag )
	{
		thePlayer.SetBehaviorVariable( 'parryType', 1.0 );
		thePlayer.RaiseForceEvent( 'ParryStart' );
	}
	else
	{
		thePlayer.SetBehaviorVariable( 'parryType', 7.0 );
		thePlayer.RaiseForceEvent( 'ParryStart' );	
	}
}

exec function PerformParry( flag : bool )
{
	if ( flag )
	{
		thePlayer.SetBehaviorVariable( 'parryType', RandRange(9) );
		thePlayer.RaiseForceEvent( 'PerformParry' );
	}
	else
	{
		thePlayer.SetBehaviorVariable( 'parryType', 7.0 );
		thePlayer.RaiseForceEvent( 'PerformParry' );
	}
}

exec function PerformCounter( flag : bool )
{
	if ( flag )
	{
		thePlayer.RaiseForceEvent( 'PerformCounter' );
	}
	else
	{
		thePlayer.RaiseForceEvent( 'PerformCounter' );
	}
}

exec function addFocus()
{
	thePlayer.GainStat(BCS_Focus, thePlayer.GetStatMax(BCS_Focus));
}

exec function FixMovement()
{
	((W3PlayerWitcher)thePlayer).SetBIsCombatActionAllowed( true );
	thePlayer.SetBIsInputAllowed( true, 'execFunc_FixMovement' );
}

exec function trad()
{
	var arr : array<SItemUniqueId>;
	
	arr = thePlayer.inv.AddAnItem('White Frost 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	thePlayer.EquipItem(arr[0], EES_Petard1);
	
	arr = thePlayer.inv.AddAnItem('Silver Dust Bomb 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	
	arr = thePlayer.inv.AddAnItem('Devils Puffball 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	
	arr = thePlayer.inv.AddAnItem('Samum 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dancing Star 3');
	thePlayer.EquipItem(arr[0], EES_Petard2);
	
	thePlayer.inv.AddAnItem('Tracking Bolt',9);
	thePlayer.inv.AddAnItem('Bait Bolt',9);
	thePlayer.inv.AddAnItem('Blunt Bolt',9);
	thePlayer.inv.AddAnItem('Broadhead Bolt',9);
	thePlayer.inv.AddAnItem('Target Point Bolt',9);
	thePlayer.inv.AddAnItem('Split Bolt',9);
	thePlayer.inv.AddAnItem('Explosive Bolt',9);
	
	thePlayer.inv.AddAnItem('Blunt Bolt Legendary',9);
	thePlayer.inv.AddAnItem('Broadhead Bolt Legendary',9);
	thePlayer.inv.AddAnItem('Target Point Bolt Legendary',9);
	thePlayer.inv.AddAnItem('Split Bolt Legendary',9);
	thePlayer.inv.AddAnItem('Explosive Bolt Legendary',9);
	
	thePlayer.inv.AddAnItem('Torch');
	thePlayer.inv.AddAnItem('q103_bell');
}

exec function addbombs(optional notInfinite : bool)
{	
	var arr : array<SItemUniqueId>;

	if(!notInfinite)
	{
		FactsAdd("debug_fact_inf_bombs");
	}
	
	arr = thePlayer.inv.AddAnItem('Samum 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Samum 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Samum 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dwimeritium Bomb 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dwimeritium Bomb 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dwimeritium Bomb 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dancing Star 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dancing Star 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dancing Star 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Devils Puffball 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Devils Puffball 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Devils Puffball 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dragons Dream 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dragons Dream 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Dragons Dream 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Silver Dust Bomb 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Silver Dust Bomb 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Silver Dust Bomb 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('White Frost 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('White Frost 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('White Frost 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
		
	arr = thePlayer.inv.AddAnItem('Grapeshot 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Grapeshot 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = thePlayer.inv.AddAnItem('Grapeshot 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	
	thePlayer.EquipItem(arr[0], EES_Petard1);
	GetWitcherPlayer().SelectQuickslotItem( EES_Petard1 );
}

exec function freezetodeath()
{
	var arr : array<SItemUniqueId>;
	
	arr = thePlayer.inv.AddAnItem('Freeze to death', 20);	
	thePlayer.EquipItem(arr[0], EES_Quickslot1);
	GetWitcherPlayer().SelectQuickslotItem( EES_Quickslot1 );
}

exec function addbolts(optional infinite : bool)
{	
	var arr : array<SItemUniqueId>;

	if(infinite)
	{
		FactsAdd("debug_fact_inf_bolts");
	}



	
	thePlayer.inv.AddAnItem('Tracking Bolt',9);
	thePlayer.inv.AddAnItem('Bait Bolt',9);
	thePlayer.inv.AddAnItem('Blunt Bolt',9);
	thePlayer.inv.AddAnItem('Broadhead Bolt',9);
	thePlayer.inv.AddAnItem('Target Point Bolt',9);
	thePlayer.inv.AddAnItem('Split Bolt',9);
	thePlayer.inv.AddAnItem('Explosive Bolt',9);
	
	thePlayer.inv.AddAnItem('Blunt Bolt Legendary',9);
	thePlayer.inv.AddAnItem('Broadhead Bolt Legendary',9);
	thePlayer.inv.AddAnItem('Target Point Bolt Legendary',9);
	thePlayer.inv.AddAnItem('Split Bolt Legendary',9);
	thePlayer.inv.AddAnItem('Explosive Bolt Legendary',9);
}


exec function addcraft()
{
	thePlayer.inv.AddAnItem('Hardened leather', 10);
	thePlayer.inv.AddAnItem('Linen', 10);
	thePlayer.inv.AddAnItem('Thread', 10);
	thePlayer.inv.AddAnItem('Twine', 10);
	thePlayer.inv.AddAnItem('Steel plate', 10);
	thePlayer.inv.AddAnItem('Cotton', 10);
	thePlayer.inv.AddAnItem('Oil', 10);
	thePlayer.inv.AddAnItem('Infused shard', 10);
	
	GetWitcherPlayer().AddCraftingSchematic('Heavy Boots 2 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Heavy Boots 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Pants 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Heavy Pants 2 schematic');
	
	thePlayer.AddMoney(50000);
}


exec function addsteelswords()
{
	thePlayer.inv.AddAnItem('Long Steel Sword',1);
	thePlayer.inv.AddAnItem('Viper School steel sword',1);
	thePlayer.inv.AddAnItem('Short Steel Sword',1);
	thePlayer.inv.AddAnItem('Hjalmar_Short_Steel_Sword',1);
	thePlayer.inv.AddAnItem('Short sword 1',1);
	thePlayer.inv.AddAnItem('Short sword 2',1);
	thePlayer.inv.AddAnItem('Dwarven sword 1',1);
	thePlayer.inv.AddAnItem('Dwarven sword 2',1);
	thePlayer.inv.AddAnItem('Gnomish sword 1',1);
	thePlayer.inv.AddAnItem('Gnomish sword 2',1);
	thePlayer.inv.AddAnItem('Inquisitor sword 1',1);
	thePlayer.inv.AddAnItem('Inquisitor sword 2',1);
	thePlayer.inv.AddAnItem('No Mans Land sword 1',1);
	thePlayer.inv.AddAnItem('No Mans Land sword 1 q2',1);
	thePlayer.inv.AddAnItem('No Mans Land sword 2',1);
	thePlayer.inv.AddAnItem('No Mans Land sword 3',1);
	thePlayer.inv.AddAnItem('No Mans Land sword 4',1);
	thePlayer.inv.AddAnItem('Rusty Nilfgaardian sword',1);
	thePlayer.inv.AddAnItem('Nilfgaardian sword 1',1);
	thePlayer.inv.AddAnItem('Nilfgaardian sword 2',1);
	thePlayer.inv.AddAnItem('Nilfgaardian sword 3',1);
	thePlayer.inv.AddAnItem('Nilfgaardian sword 4',1);
	thePlayer.inv.AddAnItem('Rusty Novigraadan sword',1);
	thePlayer.inv.AddAnItem('Novigraadan sword 1',1);
	thePlayer.inv.AddAnItem('Novigraadan sword 2',1);
	thePlayer.inv.AddAnItem('Novigraadan sword 3',1);
	thePlayer.inv.AddAnItem('Novigraadan sword 4',1);
	thePlayer.inv.AddAnItem('Scoiatael sword 1',1);
	thePlayer.inv.AddAnItem('Scoiatael sword 2',1);
	thePlayer.inv.AddAnItem('Scoiatael sword 3',1);
	thePlayer.inv.AddAnItem('Rusty Skellige sword',1);
	thePlayer.inv.AddAnItem('Skellige sword 1',1);
	thePlayer.inv.AddAnItem('Skellige sword 2',1);
	thePlayer.inv.AddAnItem('Skellige sword 3',1);
	thePlayer.inv.AddAnItem('Skellige sword 4',1);
	thePlayer.inv.AddAnItem('Wild Hunt sword 1',1);
	thePlayer.inv.AddAnItem('Wild Hunt sword 2',1);
	thePlayer.inv.AddAnItem('Wild Hunt sword 3',1);
	thePlayer.inv.AddAnItem('Wild Hunt sword 4',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addsteelswords2()
{
	thePlayer.inv.AddAnItem('Bear School steel sword',1);
	thePlayer.inv.AddAnItem('Bear School steel sword 1',1);
	thePlayer.inv.AddAnItem('Bear School steel sword 2',1);
	thePlayer.inv.AddAnItem('Bear School steel sword 3',1);
	thePlayer.inv.AddAnItem('Gryphon School steel sword',1);
	thePlayer.inv.AddAnItem('Gryphon School steel sword 1',1);
	thePlayer.inv.AddAnItem('Gryphon School steel sword 2',1);
	thePlayer.inv.AddAnItem('Gryphon School steel sword 3',1);
	thePlayer.inv.AddAnItem('Lynx School steel sword',1);
	thePlayer.inv.AddAnItem('Lynx School steel sword 1',1);
	thePlayer.inv.AddAnItem('Lynx School steel sword 2',1);
	thePlayer.inv.AddAnItem('Lynx School steel sword 3',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addwolfdlc(optional dontOpenInv : bool)
{
	thePlayer.inv.AddAnItem('Wolf Armor', 1);
	thePlayer.inv.AddAnItem('Wolf Armor 1', 1);
	thePlayer.inv.AddAnItem('Wolf Armor 2', 1);
	thePlayer.inv.AddAnItem('Wolf Armor 3', 1);

	thePlayer.inv.AddAnItem('Wolf Gloves 1', 1);
	thePlayer.inv.AddAnItem('Wolf Gloves 2', 1);

	thePlayer.inv.AddAnItem('Wolf Pants 1', 1);
	thePlayer.inv.AddAnItem('Wolf Pants 2', 1);

	thePlayer.inv.AddAnItem('Wolf Boots 1', 1);
	thePlayer.inv.AddAnItem('Wolf Boots 2', 1);

	thePlayer.inv.AddAnItem('Wolf School steel sword', 1);
	thePlayer.inv.AddAnItem('Wolf School steel sword 1', 1);
	thePlayer.inv.AddAnItem('Wolf School steel sword 2', 1);
	thePlayer.inv.AddAnItem('Wolf School steel sword 3', 1);

	thePlayer.inv.AddAnItem('Wolf School silver sword', 1);
	thePlayer.inv.AddAnItem('Wolf School silver sword 1', 1);
	thePlayer.inv.AddAnItem('Wolf School silver sword 2', 1);
	thePlayer.inv.AddAnItem('Wolf School silver sword 3', 1);
	
	if(!dontOpenInv)
	{
		theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
	}
}


exec function addsilverswords(optional dontOpenInv : bool)
{
	thePlayer.inv.AddAnItem('Witcher Silver Sword',1);
	thePlayer.inv.AddAnItem('Silver sword 1',1);
	thePlayer.inv.AddAnItem('Silver sword 2',1);
	thePlayer.inv.AddAnItem('Silver sword 3',1);
	thePlayer.inv.AddAnItem('Silver sword 4',1);
	thePlayer.inv.AddAnItem('Silver sword 5',1);
	thePlayer.inv.AddAnItem('Silver sword 6',1);
	thePlayer.inv.AddAnItem('Silver sword 7',1);
	thePlayer.inv.AddAnItem('Silver sword 8',1);
	thePlayer.inv.AddAnItem('Dwarven silver sword 1',1);
	thePlayer.inv.AddAnItem('Dwarven silver sword 2',1);
	thePlayer.inv.AddAnItem('Elven silver sword 1',1);
	thePlayer.inv.AddAnItem('Elven silver sword 2',1);
	thePlayer.inv.AddAnItem('Gnomish silver sword 1',1);
	thePlayer.inv.AddAnItem('Gnomish silver sword 2',1);
	thePlayer.inv.AddAnItem('Bear School silver sword',1);
	thePlayer.inv.AddAnItem('Bear School silver sword 1',1);
	thePlayer.inv.AddAnItem('Bear School silver sword 2',1);
	thePlayer.inv.AddAnItem('Bear School silver sword 3',1);
	thePlayer.inv.AddAnItem('Lynx School silver sword',1);
	thePlayer.inv.AddAnItem('Lynx School silver sword 1',1);
	thePlayer.inv.AddAnItem('Lynx School silver sword 2',1);
	thePlayer.inv.AddAnItem('Lynx School silver sword 3',1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword',1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword 1',1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword 2',1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword 3',1);
	thePlayer.inv.AddAnItem('Viper School silver sword',1);
	thePlayer.inv.AddAnItem('Wolf School silver sword',1);
	thePlayer.inv.AddAnItem('Wolf School silver sword 1',1);
	thePlayer.inv.AddAnItem('Wolf School silver sword 2',1);
	thePlayer.inv.AddAnItem('Wolf School silver sword 3',1);
	
	if(!dontOpenInv)
		theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addsilverswords2()
{
	thePlayer.inv.AddAnItem('Bear School silver sword',1);
	thePlayer.inv.AddAnItem('Bear School silver sword 1',1);
	thePlayer.inv.AddAnItem('Bear School silver sword 2',1);
	thePlayer.inv.AddAnItem('Bear School silver sword 3',1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword',1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword 1',1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword 2',1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword 3',1);
	thePlayer.inv.AddAnItem('Lynx School silver sword',1);
	thePlayer.inv.AddAnItem('Lynx School silver sword 1',1);
	thePlayer.inv.AddAnItem('Lynx School silver sword 2',1);
	thePlayer.inv.AddAnItem('Lynx School silver sword 3',1);
	thePlayer.inv.AddAnItem('Wolf School silver sword',1);
	thePlayer.inv.AddAnItem('Wolf School silver sword 1',1);
	thePlayer.inv.AddAnItem('Wolf School silver sword 2',1);
	thePlayer.inv.AddAnItem('Wolf School silver sword 3',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addcrossbows()
{
	thePlayer.inv.AddAnItem('Crossbow 1',1);
	thePlayer.inv.AddAnItem('Crossbow q206',1);
	thePlayer.inv.AddAnItem('Crossbow 2',1);
	thePlayer.inv.AddAnItem('Crossbow 3',1);
	thePlayer.inv.AddAnItem('Crossbow 4',1);
	thePlayer.inv.AddAnItem('Crossbow 5',1);
	thePlayer.inv.AddAnItem('Crossbow 6',1);
	thePlayer.inv.AddAnItem('Crossbow 7',1);
	thePlayer.inv.AddAnItem('Lynx School Crossbow',1);
	thePlayer.inv.AddAnItem('Bear School Crossbow',1);
	thePlayer.inv.AddAnItem('Nilfgaardian crossbow',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addarmor()
{
	thePlayer.inv.AddAnItem('Heavy armor 01',1);
	thePlayer.inv.AddAnItem('Heavy armor 02',1);
	thePlayer.inv.AddAnItem('Heavy armor 03',1);
	thePlayer.inv.AddAnItem('Heavy armor 04',1);
	thePlayer.inv.AddAnItem('Heavy armor 05',1);
	thePlayer.inv.AddAnItem('Light armor 01',1);
	thePlayer.inv.AddAnItem('Light armor 02',1);
	thePlayer.inv.AddAnItem('Light armor 03',1);
	thePlayer.inv.AddAnItem('Light armor 04',1);

	thePlayer.inv.AddAnItem('Light armor 06',1);
	thePlayer.inv.AddAnItem('Light armor 07',1);
	thePlayer.inv.AddAnItem('Light armor 08',1);
	thePlayer.inv.AddAnItem('Light armor 09',1);
	thePlayer.inv.AddAnItem('Medium armor 01',1);
	thePlayer.inv.AddAnItem('Medium armor 02',1);
	thePlayer.inv.AddAnItem('Medium armor 03',1);
	thePlayer.inv.AddAnItem('Medium armor 04',1);
	thePlayer.inv.AddAnItem('Medium armor 05',1);

	thePlayer.inv.AddAnItem('Medium armor 07',1);


	thePlayer.inv.AddAnItem('Medium armor 10',1);
	thePlayer.inv.AddAnItem('Medium armor 11',1);

	thePlayer.inv.AddAnItem('Nilfgaardian Casual Suit 01',1);
	thePlayer.inv.AddAnItem('Nilfgaardian Casual Suit 02',1);
	thePlayer.inv.AddAnItem('Nilfgaardian Casual Suit 03',1);
	thePlayer.inv.AddAnItem('Skellige Casual Suit 01',1);
	thePlayer.inv.AddAnItem('Skellige Casual Suit 02',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addarmor2()
{
	thePlayer.inv.AddAnItem('Starting Armor',1);
	thePlayer.inv.AddAnItem('Bear Armor',1);
	thePlayer.inv.AddAnItem('Bear Armor 1',1);
	thePlayer.inv.AddAnItem('Bear Armor 2',1);
	thePlayer.inv.AddAnItem('Bear Armor 3',1);
	thePlayer.inv.AddAnItem('Gryphon Armor',1);
	thePlayer.inv.AddAnItem('Gryphon Armor 1',1);
	thePlayer.inv.AddAnItem('Gryphon Armor 2',1);
	thePlayer.inv.AddAnItem('Gryphon Armor 3',1);
	thePlayer.inv.AddAnItem('Lynx Armor',1);
	thePlayer.inv.AddAnItem('Lynx Armor 1',1);
	thePlayer.inv.AddAnItem('Lynx Armor 2',1);
	thePlayer.inv.AddAnItem('Lynx Armor 3',1);
	thePlayer.inv.AddAnItem('Wolf Armor',1);
	thePlayer.inv.AddAnItem('Wolf Armor 1',1);
	thePlayer.inv.AddAnItem('Wolf Armor 2',1);
	thePlayer.inv.AddAnItem('Wolf Armor 3',1);
	thePlayer.inv.AddAnItem('Geralt Shirt',1);
	thePlayer.inv.AddAnItem('Geralt Shirt No Knife',1);
	thePlayer.inv.AddAnItem('Nilfgaardian Casual Suit 01',1);
	thePlayer.inv.AddAnItem('Nilfgaardian Casual Suit 02',1);
	thePlayer.inv.AddAnItem('Nilfgaardian Casual Suit 03',1);
	thePlayer.inv.AddAnItem('Skellige Casual Suit 01',1);
	thePlayer.inv.AddAnItem('Skellige Casual Suit 02',1);
	thePlayer.inv.AddAnItem('sq108_heavy_armor',1);
	
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addpants()
{
	thePlayer.inv.AddAnItem('Starting Pants',1);
	thePlayer.inv.AddAnItem('Wolf Pants 1',1);
	thePlayer.inv.AddAnItem('Wolf Pants 2',1);
	thePlayer.inv.AddAnItem('Lynx Pants 1',1);
	thePlayer.inv.AddAnItem('Lynx Pants 2',1);
	thePlayer.inv.AddAnItem('Gryphon Pants 1',1);
	thePlayer.inv.AddAnItem('Gryphon Pants 2',1);
	thePlayer.inv.AddAnItem('Bear Pants 1',1);
	thePlayer.inv.AddAnItem('Bear Pants 2',1);
	thePlayer.inv.AddAnItem('Pants 01',1);
	thePlayer.inv.AddAnItem('Pants 01 q2',1);
	thePlayer.inv.AddAnItem('Pants 02',1);
	thePlayer.inv.AddAnItem('Pants 03',1);
	thePlayer.inv.AddAnItem('Pants 04',1);
	thePlayer.inv.AddAnItem('Heavy pants 01',1);
	thePlayer.inv.AddAnItem('Heavy pants 02',1);
	thePlayer.inv.AddAnItem('Heavy pants 03',1);
	thePlayer.inv.AddAnItem('Heavy pants 04',1);
	thePlayer.inv.AddAnItem('Nilfgaardian Casual Pants',1);
	thePlayer.inv.AddAnItem('Skellige Casual Pants 01',1);
	thePlayer.inv.AddAnItem('Skellige Casual Pants 02',1);
	thePlayer.inv.AddAnItem('Bath Towel Pants 01',1);
	thePlayer.inv.AddAnItem('Ciri pants 01',1);
	thePlayer.inv.AddAnItem('Wild Hunt pants 01',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addboots()
{
	thePlayer.inv.AddAnItem('Starting Boots',1);
	thePlayer.inv.AddAnItem('Wolf Boots 1',1);
	thePlayer.inv.AddAnItem('Wolf Boots 2',1);
	thePlayer.inv.AddAnItem('Lynx Boots 1',1);
	thePlayer.inv.AddAnItem('Lynx Boots 2',1);
	thePlayer.inv.AddAnItem('Gryphon Boots 1',1);
	thePlayer.inv.AddAnItem('Gryphon Boots 2',1);
	thePlayer.inv.AddAnItem('Bear Boots 1',1);
	thePlayer.inv.AddAnItem('Bear Boots 2',1);
	thePlayer.inv.AddAnItem('Boots 01',1);
	thePlayer.inv.AddAnItem('Boots 01 q2',1);
	thePlayer.inv.AddAnItem('Boots 02',1);
	thePlayer.inv.AddAnItem('Boots 03',1);
	thePlayer.inv.AddAnItem('Boots 04',1);
	thePlayer.inv.AddAnItem('Boots 01',1);
	thePlayer.inv.AddAnItem('Heavy boots 01',1);
	thePlayer.inv.AddAnItem('Heavy boots 02',1);
	thePlayer.inv.AddAnItem('Heavy boots 03',1);
	thePlayer.inv.AddAnItem('Heavy boots 04',1);
	thePlayer.inv.AddAnItem('Nilfgaardian casual shoes',1);
	thePlayer.inv.AddAnItem('Skellige casual shoes',1);
	thePlayer.inv.AddAnItem('Radovid boots 01',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addgloves()
{
	thePlayer.inv.AddAnItem('Starting Gloves',1);
	thePlayer.inv.AddAnItem('Wolf Gloves 1',1);
	thePlayer.inv.AddAnItem('Wolf Gloves 2',1);
	thePlayer.inv.AddAnItem('Lynx Gloves 1',1);
	thePlayer.inv.AddAnItem('Lynx Gloves 2',1);
	thePlayer.inv.AddAnItem('Gryphon Gloves 1',1);
	thePlayer.inv.AddAnItem('Gryphon Gloves 2',1);
	thePlayer.inv.AddAnItem('Bear Gloves 1',1);
	thePlayer.inv.AddAnItem('Bear Gloves 2',1);
	thePlayer.inv.AddAnItem('Gloves 01',1);
	thePlayer.inv.AddAnItem('Gloves 01 q2',1);
	thePlayer.inv.AddAnItem('Gloves 02',1);
	thePlayer.inv.AddAnItem('Gloves 03',1);
	thePlayer.inv.AddAnItem('Gloves 04',1);
	thePlayer.inv.AddAnItem('Gloves 05',1);
	thePlayer.inv.AddAnItem('Heavy gloves 01',1);
	thePlayer.inv.AddAnItem('Heavy gloves 02',1);
	thePlayer.inv.AddAnItem('Heavy gloves 03',1);
	thePlayer.inv.AddAnItem('Heavy gloves 04',1);
	thePlayer.inv.AddAnItem('Wild Hunt gloves 01',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addsets()
{
	thePlayer.inv.AddAnItem('Wolf Boots 1',1);
	thePlayer.inv.AddAnItem('Lynx Boots 1',1);
	thePlayer.inv.AddAnItem('Gryphon Boots 1',1);
	thePlayer.inv.AddAnItem('Bear Boots 1',1);
	
	thePlayer.inv.AddAnItem('Wolf Pants 1',1);
	thePlayer.inv.AddAnItem('Lynx Pants 1',1);
	thePlayer.inv.AddAnItem('Gryphon Pants 1',1);
	thePlayer.inv.AddAnItem('Bear Pants 1',1);
	
	thePlayer.inv.AddAnItem('Bear Armor',1);
	thePlayer.inv.AddAnItem('Gryphon Armor',1);
	thePlayer.inv.AddAnItem('Lynx Armor',1);
	thePlayer.inv.AddAnItem('Wolf Armor',1);
	
	thePlayer.inv.AddAnItem('Wolf Gloves 1',1);
	thePlayer.inv.AddAnItem('Lynx Gloves 1',1);
	thePlayer.inv.AddAnItem('Gryphon Gloves 1',1);
	thePlayer.inv.AddAnItem('Bear Gloves 1',1);
	
	thePlayer.inv.AddAnItem('Bear School steel sword',1);
	thePlayer.inv.AddAnItem('Gryphon School steel sword',1);
	thePlayer.inv.AddAnItem('Lynx School steel sword',1);
	thePlayer.inv.AddAnItem('Wolf School steel sword',1);
	
	thePlayer.inv.AddAnItem('Bear School silver sword',1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword',1);
	thePlayer.inv.AddAnItem('Lynx School silver sword',1);
	thePlayer.inv.AddAnItem('Wolf School silver sword',1);
}


exec function addbooks()
{
	addbooks_();
}

function addbooks_()
{
	thePlayer.inv.AddAnItem('Beasts vol 1',1);
	thePlayer.inv.AddAnItem('Beasts vol 2',1);
	thePlayer.inv.AddAnItem('Cursed Monsters vol 1',1);
	thePlayer.inv.AddAnItem('Cursed Monsters vol 2',1);
	thePlayer.inv.AddAnItem('Draconides vol 1',1);
	thePlayer.inv.AddAnItem('Draconides vol 2',1);
	thePlayer.inv.AddAnItem('Hybrid Monsters vol 1',1);
	thePlayer.inv.AddAnItem('Hybrid Monsters vol 2',1);
	thePlayer.inv.AddAnItem('Insectoids vol 1',1);
	thePlayer.inv.AddAnItem('Insectoids vol 2',1);
	thePlayer.inv.AddAnItem('Magical Monsters vol 1',1);
	thePlayer.inv.AddAnItem('Magical Monsters vol 2',1);
	thePlayer.inv.AddAnItem('Necrophage vol 1',1);
	thePlayer.inv.AddAnItem('Necrophage vol 2',1);
	thePlayer.inv.AddAnItem('Relict Monsters vol 1',1);
	thePlayer.inv.AddAnItem('Relict Monsters vol 2',1);
	thePlayer.inv.AddAnItem('Specters vol 1',1);
	thePlayer.inv.AddAnItem('Specters vol 2',1);
	thePlayer.inv.AddAnItem('Ogres vol 1',1);
	thePlayer.inv.AddAnItem('Ogres vol 2',1);
	thePlayer.inv.AddAnItem('Vampires vol 1',1);
	thePlayer.inv.AddAnItem('Vampires vol 2',1);
	thePlayer.inv.AddAnItem('Wild Hunt',1);
	thePlayer.inv.AddAnItem('Horse vol 1',1);
	thePlayer.inv.AddAnItem('Horse vol 2',1);
	thePlayer.inv.AddAnItem('Boat vol 1',1);
	thePlayer.inv.AddAnItem('Boat vol 2',1);
	thePlayer.inv.AddAnItem('Gear improvement',1);
	thePlayer.inv.AddAnItem('Weapon maintenance',1);
	thePlayer.inv.AddAnItem('Armor maintenancet',1);
	thePlayer.inv.AddAnItem('Nilfgard arms and tactics',1);
	thePlayer.inv.AddAnItem('Norther Kingdoms arms and tactics',1);
	thePlayer.inv.AddAnItem('Skelige arms and tactics',1);
	thePlayer.inv.AddAnItem('Theatre Glossary vol 1',1);
	thePlayer.inv.AddAnItem('Theatre Glossary vol 2',1);
	thePlayer.inv.AddAnItem('Jacob of Varazze Chronicles',1);
	thePlayer.inv.AddAnItem('Poems of Gonzal de Verceo',1);
	thePlayer.inv.AddAnItem('Book of Arachases',1);
	thePlayer.inv.AddAnItem('Glossary Temerian Dynasty',1);
	thePlayer.inv.AddAnItem('Orders from Shilard',1);
	thePlayer.inv.AddAnItem('Journey into the mind',1);
	thePlayer.inv.AddAnItem('Necronomicon',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addlore()
{
	thePlayer.inv.AddAnItem('lore_imperial_edict_i',1);
	thePlayer.inv.AddAnItem('lore_imperial_edict_ii',1);
	thePlayer.inv.AddAnItem('lore_nilfgaardian_royal_dynasty',1);
	thePlayer.inv.AddAnItem('lore_nilfgaardian_history_book',1);
	thePlayer.inv.AddAnItem('lore_nilfgaardian_empire',1);
	thePlayer.inv.AddAnItem('lore_lodge_of_sorceresses',1);
	thePlayer.inv.AddAnItem('lore_third_war_with_nilfgaard',1);
	thePlayer.inv.AddAnItem('lore_wars_with_nilfgaard',1);
	thePlayer.inv.AddAnItem('lore_novigrad',1);
	thePlayer.inv.AddAnItem('lore_skellige_island',1);
	thePlayer.inv.AddAnItem('lore_skellige_heroes_sove',1);
	thePlayer.inv.AddAnItem('lore_skellige_heroes_tyr',1);
	thePlayer.inv.AddAnItem('lore_skellige_heroes_otkell',1);
	thePlayer.inv.AddAnItem('lore_skellige_heroes_modolf',1);
	thePlayer.inv.AddAnItem('lore_skellige_heroes_broddr',1);
	thePlayer.inv.AddAnItem('lore_skellige_heroes_grymmdjarr',1);
	thePlayer.inv.AddAnItem('lore_oxenfurt',1);
	thePlayer.inv.AddAnItem('lore_velen',1);
	thePlayer.inv.AddAnItem('lore_fate_of_temeria',1);
	thePlayer.inv.AddAnItem('lore_fall_of_wyzima',1);
	thePlayer.inv.AddAnItem('lore_summit_of_loc_muinne',1);
	thePlayer.inv.AddAnItem('lore_redania',1);
	thePlayer.inv.AddAnItem('lore_radovids_rise_to_power',1);
	thePlayer.inv.AddAnItem('lore_redanian_secret_service',1);
	thePlayer.inv.AddAnItem('lore_kovir',1);
	thePlayer.inv.AddAnItem('lore_kovir',1);
	thePlayer.inv.AddAnItem('lore_basics_of_magic',1);
	thePlayer.inv.AddAnItem('lore_principles_of_eternal_fire',1);
	thePlayer.inv.AddAnItem('lore_cult_of_freyia',1);
	thePlayer.inv.AddAnItem('lore_cult_of_hemdall',1);
	thePlayer.inv.AddAnItem('lore_druids',1);
	thePlayer.inv.AddAnItem('lore_witchers',1);
	thePlayer.inv.AddAnItem('lore_monstrum',1);
	thePlayer.inv.AddAnItem('lore_radovid_propaganda_pamphlet',1);
	thePlayer.inv.AddAnItem('lore_the_great_four',1);
	thePlayer.inv.AddAnItem('lore_wild_hunt',1);
	thePlayer.inv.AddAnItem('lore_non_humans',1);
	thePlayer.inv.AddAnItem('lore_prophecy_of_ithlinne',1);
	thePlayer.inv.AddAnItem('lore_conjunction_of_spheres',1);
	thePlayer.inv.AddAnItem('lore_theory_of_spheres',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addlore2()
{
	thePlayer.inv.AddAnItem('lore_elder_blood',1);
	thePlayer.inv.AddAnItem('lore_an_seidhe_and_aen_elle',1);
	thePlayer.inv.AddAnItem('lore_cirilla_of_cintra',1);
	thePlayer.inv.AddAnItem('lore_elven_sages',1);
	thePlayer.inv.AddAnItem('lore_elven_ruins',1);
	thePlayer.inv.AddAnItem('lore_elven_legends',1);
	thePlayer.inv.AddAnItem('lore_witch_hunters',1);
	thePlayer.inv.AddAnItem('lore_goetia',1);
	thePlayer.inv.AddAnItem('lore_oneiromancy',1);
	thePlayer.inv.AddAnItem('lore_hydromancy',1);
	thePlayer.inv.AddAnItem('lore_necromancy',1);
	thePlayer.inv.AddAnItem('lore_tyromancy',1);
	thePlayer.inv.AddAnItem('lore_polymorphism',1);
	thePlayer.inv.AddAnItem('lore_war_between_astrals',1);
	thePlayer.inv.AddAnItem('lore_witcher_signs',1);
	thePlayer.inv.AddAnItem('lore_last_wish',1);
	thePlayer.inv.AddAnItem('lore_bells_of_beauclair',1);
	thePlayer.inv.AddAnItem('lore_sands_of_zerrikania',1);
	thePlayer.inv.AddAnItem('lore_naglfar_demonic_drakkar',1);
	thePlayer.inv.AddAnItem('lore_ragnarok',1);
	thePlayer.inv.AddAnItem('lore_study_on_white_cold',1);
	thePlayer.inv.AddAnItem('lore_journals_from_urskar_1',1);
	thePlayer.inv.AddAnItem('lore_journals_from_urskar_2',1);
	thePlayer.inv.AddAnItem('lore_journals_from_urskar_3',1);
	thePlayer.inv.AddAnItem('lore_journals_from_urskar_4',1);
	thePlayer.inv.AddAnItem('lore_journals_from_urskar_5',1);
	thePlayer.inv.AddAnItem('lore_journals_from_urskar_6',1);
	thePlayer.inv.AddAnItem('lore_journals_from_urskar_7',1);
	thePlayer.inv.AddAnItem('lore_nilfgaardian_transport_orders',1);
	thePlayer.inv.AddAnItem('lore_yennefer_journals',1);
	thePlayer.inv.AddAnItem('lore_inteligence_report_about_ciri',1);
	thePlayer.inv.AddAnItem('lore_unfinished_war_annals',1);
	thePlayer.inv.AddAnItem('lore_aleksanders_notes',1);
	thePlayer.inv.AddAnItem('lore_popiels_journal',1);
	thePlayer.inv.AddAnItem('lore_about_the_fourth_witch',1);
	thePlayer.inv.AddAnItem('lore_brother_adalbert_bestiary',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addfood()
{
	thePlayer.inv.AddAnItem( 'Beauclair White', 1 );
	thePlayer.inv.AddAnItem( 'Cherry Cordial', 1 );
	thePlayer.inv.AddAnItem( 'Dijkstra Dry', 1 );
	thePlayer.inv.AddAnItem( 'Erveluce', 1 );
	thePlayer.inv.AddAnItem( 'Est Est', 1 );
	thePlayer.inv.AddAnItem( 'Kaedwenian Stout', 1 );
	thePlayer.inv.AddAnItem( 'Mahakam Spirit', 1 );
	thePlayer.inv.AddAnItem( 'Mandrake cordial', 1 );
	thePlayer.inv.AddAnItem( 'Mettina Rose', 1 );
	thePlayer.inv.AddAnItem( 'Nilfgaardian Lemon', 1 );
	thePlayer.inv.AddAnItem( 'Local pepper vodka', 1 );
	thePlayer.inv.AddAnItem( 'Redanian Herbal', 1 );
	thePlayer.inv.AddAnItem( 'Redanian Lager', 1 );
	thePlayer.inv.AddAnItem( 'Rivian Kriek', 1 );
	thePlayer.inv.AddAnItem( 'Temerian Rye', 1 );
	thePlayer.inv.AddAnItem( 'Viziman Champion', 1 );
	thePlayer.inv.AddAnItem( 'Apple', 1 );
	thePlayer.inv.AddAnItem( 'Baked apple', 1 );
	thePlayer.inv.AddAnItem( 'Banana', 1 );
	thePlayer.inv.AddAnItem( 'Bell pepper', 1 );
	thePlayer.inv.AddAnItem( 'Blueberries', 1 );
	thePlayer.inv.AddAnItem( 'Bread', 1 );
	thePlayer.inv.AddAnItem( 'Burned bread', 1 );
	thePlayer.inv.AddAnItem( 'Bun', 1 );
	thePlayer.inv.AddAnItem( 'Burned bun', 1 );
	thePlayer.inv.AddAnItem( 'Candy', 1 );
	thePlayer.inv.AddAnItem( 'Cheese', 1 );
	thePlayer.inv.AddAnItem( 'Chicken', 1 );
	thePlayer.inv.AddAnItem( 'Chicken leg', 1 );
	thePlayer.inv.AddAnItem( 'Roasted chicken leg', 1 );
	thePlayer.inv.AddAnItem( 'Roasted chicken', 1 );
	thePlayer.inv.AddAnItem( 'Chicken sandwich', 1 );
	thePlayer.inv.AddAnItem( 'Grilled chicken sandwich', 1 );
	thePlayer.inv.AddAnItem( 'Cucumber', 1 );
	thePlayer.inv.AddAnItem( 'Dried fruit', 1 );
	thePlayer.inv.AddAnItem( 'Dried fruit and nuts', 1 );
	thePlayer.inv.AddAnItem( 'Egg', 1 );
	thePlayer.inv.AddAnItem( 'Fish', 1 );
	thePlayer.inv.AddAnItem( 'Fried fish', 1 );
	thePlayer.inv.AddAnItem( 'Gutted fish', 1 );
	thePlayer.inv.AddAnItem( 'Fondue', 1 );
	thePlayer.inv.AddAnItem( 'Grapes', 1 );
	thePlayer.inv.AddAnItem( 'Ham sandwich', 1 );
	thePlayer.inv.AddAnItem( 'Very good honey', 1 );
	thePlayer.inv.AddAnItem( 'Honeycomb', 1 );
	thePlayer.inv.AddAnItem( 'Fried meat', 1 );
	thePlayer.inv.AddAnItem( 'Raw meat', 1 );
	thePlayer.inv.AddAnItem( 'Cows milk', 1 );
	thePlayer.inv.AddAnItem( 'Goats milk', 1 );
	thePlayer.inv.AddAnItem( 'Mushroom', 1 );
	thePlayer.inv.AddAnItem( 'Mutton curry', 1 );
	thePlayer.inv.AddAnItem( 'Mutton leg', 1 );
	thePlayer.inv.AddAnItem( 'Olive', 1 );
	thePlayer.inv.AddAnItem( 'Onion', 1 );
	thePlayer.inv.AddAnItem( 'Pear', 1 );
	thePlayer.inv.AddAnItem( 'Pepper', 1 );
	thePlayer.inv.AddAnItem( 'Plum', 1 );
	thePlayer.inv.AddAnItem( 'Pork', 1 );
	thePlayer.inv.AddAnItem( 'Grilled pork', 1 );
	thePlayer.inv.AddAnItem( 'Potatoes', 1 );
	thePlayer.inv.AddAnItem( 'Baked potato', 1 );
	thePlayer.inv.AddAnItem( 'Chips', 1 );
	thePlayer.inv.AddAnItem( 'Raspberries', 1 );
	thePlayer.inv.AddAnItem( 'Raspberry juice', 1 );
	thePlayer.inv.AddAnItem( 'Strawberries', 1 );
	thePlayer.inv.AddAnItem( 'Toffee', 1 );
	thePlayer.inv.AddAnItem( 'Vinegar', 1 );
	thePlayer.inv.AddAnItem( 'Butter Bandalura', 1 );
	thePlayer.inv.AddAnItem( 'Apple juice', 1 );
	thePlayer.inv.AddAnItem( 'Bottled water', 1 );

	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function adddrinks(optional cnt : int, optional noMenu : bool)
{
	if(cnt == 0)
		cnt = 1;
		
	thePlayer.inv.AddAnItem('Apple juice',cnt);
	thePlayer.inv.AddAnItem('Bottled water',cnt);
	thePlayer.inv.AddAnItem('Cows milk',cnt);
	thePlayer.inv.AddAnItem('Goats milk',cnt);
	thePlayer.inv.AddAnItem('Raspberry juice',cnt);
	thePlayer.inv.AddAnItem('Mandrake cordial',cnt);
	thePlayer.inv.AddAnItem('Cherry Cordial',cnt);
	thePlayer.inv.AddAnItem('Mahakam Spirit',cnt);
	thePlayer.inv.AddAnItem('Local pepper vodka',cnt);
	thePlayer.inv.AddAnItem('Nilfgaardian Lemon',cnt);
	thePlayer.inv.AddAnItem('Redanian Herbal',cnt);
	thePlayer.inv.AddAnItem('Temerian Rye',cnt);
	thePlayer.inv.AddAnItem('Beauclair White',cnt);
	thePlayer.inv.AddAnItem('Mettina Rose',cnt);
	thePlayer.inv.AddAnItem('Est Est',cnt);
	thePlayer.inv.AddAnItem('Erveluce',cnt);
	thePlayer.inv.AddAnItem('Dijkstra Dry',cnt);
	thePlayer.inv.AddAnItem('Viziman Champion',cnt);
	thePlayer.inv.AddAnItem('Redanian Lager',cnt);
	thePlayer.inv.AddAnItem('Rivian Kriek',cnt);
	thePlayer.inv.AddAnItem('Kaedwenian Stout',cnt);
	thePlayer.inv.AddAnItem('Dwarven spirit',cnt);
	
	if(!noMenu)
		theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addtrophies()
{
	thePlayer.inv.AddAnItem('Nekkers Trophy',1);
	thePlayer.inv.AddAnItem('Werewolf Trophy',1);
	thePlayer.inv.AddAnItem('q002_griffin_trophy',1);
	thePlayer.inv.AddAnItem('Drowned Dead Trophy',1);
	thePlayer.inv.AddAnItem('mh101_cockatrice_trophy',1);
	thePlayer.inv.AddAnItem('mh102_arachas_trophy',1);
	thePlayer.inv.AddAnItem('mh103_nightwraith_trophy',1);
	thePlayer.inv.AddAnItem('mh104_ekimma_trophy',1);
	thePlayer.inv.AddAnItem('mh105_wyvern_trophy',1);
	thePlayer.inv.AddAnItem('mh106_gravehag_trophy',1);
	thePlayer.inv.AddAnItem('mh107_czart_trophy',1);
	thePlayer.inv.AddAnItem('mh108_fogling_trophy',1);
	thePlayer.inv.AddAnItem('mh201_cave_troll_trophy',1);
	thePlayer.inv.AddAnItem('mh202_nekker_warrior_trophy',1);
	thePlayer.inv.AddAnItem('mh203_drowned_dead_trophy',1);
	thePlayer.inv.AddAnItem('mh204_leshy_trophy',1);
	thePlayer.inv.AddAnItem('mh205_leshy_trophy',1);
	thePlayer.inv.AddAnItem('mh206_fiend_trophy',1);
	thePlayer.inv.AddAnItem('mh207_wraith_trophy',1);
	thePlayer.inv.AddAnItem('mh208_forktail_trophy',1);
	thePlayer.inv.AddAnItem('mh209_fogling_trophy',1);
	thePlayer.inv.AddAnItem('mh210_lamia_trophy',1);
	thePlayer.inv.AddAnItem('mh211_bies_trophy',1);
	thePlayer.inv.AddAnItem('mh212_erynie_trophy',1);
	thePlayer.inv.AddAnItem('mq1024_water_hag_trophy',1);
	thePlayer.inv.AddAnItem('mq1051_wyvern_trophy',1);
	thePlayer.inv.AddAnItem('q202_ice_giant_trophy',1);
	thePlayer.inv.AddAnItem('mh301_gryphon_trophy',1);
	thePlayer.inv.AddAnItem('mh302_leshy_trophy',1);
	thePlayer.inv.AddAnItem('mh303_succubus_trophy',1);
	thePlayer.inv.AddAnItem('mh304_katakan_trophy',1);
	thePlayer.inv.AddAnItem('mh305_doppler_trophy',1);
	thePlayer.inv.AddAnItem('mh306_dao_trophy',1);
	thePlayer.inv.AddAnItem('mh308_noonwraith_trophy',1);
	thePlayer.inv.AddAnItem('sq108_griffin_trophy',1);
	thePlayer.inv.AddAnItem('mq0003_noonwraith_trophy',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function adddye()
{
	thePlayer.inv.AddAnItem('Dye Default',10);
	thePlayer.inv.AddAnItem('Dye Black',10);
	thePlayer.inv.AddAnItem('Dye Blue',10);
	thePlayer.inv.AddAnItem('Dye Brown',10);
	thePlayer.inv.AddAnItem('Dye Gray',10);
	thePlayer.inv.AddAnItem('Dye Green',10);
	thePlayer.inv.AddAnItem('Dye Orange',10);
	thePlayer.inv.AddAnItem('Dye Pink',10);
	thePlayer.inv.AddAnItem('Dye Purple',10);
	thePlayer.inv.AddAnItem('Dye Red',10);
	thePlayer.inv.AddAnItem('Dye Turquoise',10);
	thePlayer.inv.AddAnItem('Dye White',10);
	thePlayer.inv.AddAnItem('Dye Yellow',10);

	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addmisc()
{
	thePlayer.inv.AddAnItem('Horn_of_Hornwales',1);
	thePlayer.inv.AddAnItem('Painting_of_hemmelfart',1);
	
	
	thePlayer.inv.AddAnItem('Weapon repair kit 1',1);
	thePlayer.inv.AddAnItem('Weapon repair kit 2',1);
	thePlayer.inv.AddAnItem('Weapon repair kit 3',1);
	thePlayer.inv.AddAnItem('Armor repair kit 1',1);
	thePlayer.inv.AddAnItem('Armor repair kit 2',1);
	thePlayer.inv.AddAnItem('Armor repair kit 3',1);
	thePlayer.inv.AddAnItem('Dismantle Kit',1);
	thePlayer.inv.AddAnItem('Torch',1);
	thePlayer.inv.AddAnItem('q106_magic_oillamp',1);
	thePlayer.inv.AddAnItem('Oil Lamp',1);
	thePlayer.inv.AddAnItem('Illusion Medallion',1);
	
	thePlayer.inv.AddAnItem('q103_bell',1);
	thePlayer.inv.AddAnItem('202_hornval_horn',1);
	thePlayer.inv.AddAnItem('q203_eyeofloki',1);
	
	
	thePlayer.inv.AddAnItem('ciris_phylactery',1);
	thePlayer.inv.AddAnItem('q403_ciri_meteor',1);
	thePlayer.inv.AddAnItem('mh107_czart_lure',1);
	
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addhorseitems()
{
	thePlayer.inv.AddAnItem('Horse Bag 1',1);
	thePlayer.inv.AddAnItem('Horse Bag 2',1);
	thePlayer.inv.AddAnItem('Horse Bag 3',1);
	thePlayer.inv.AddAnItem('Horse Blinder 1',1);
	thePlayer.inv.AddAnItem('Horse Blinder 2',1);
	thePlayer.inv.AddAnItem('Horse Blinder 3',1);
	thePlayer.inv.AddAnItem('Horse Saddle 1',1);
	thePlayer.inv.AddAnItem('Horse Saddle 1v2',1);
	thePlayer.inv.AddAnItem('Horse Saddle 1v3',1);
	thePlayer.inv.AddAnItem('Horse Saddle 1v4',1);
	thePlayer.inv.AddAnItem('Horse Saddle 2',1);
	thePlayer.inv.AddAnItem('Horse Saddle 2v2',1);
	thePlayer.inv.AddAnItem('Horse Saddle 2v3',1);
	thePlayer.inv.AddAnItem('Horse Saddle 2v4',1);
	thePlayer.inv.AddAnItem('Horse Saddle 3',1);
	thePlayer.inv.AddAnItem('Horse Saddle 3v2',1);
	thePlayer.inv.AddAnItem('Horse Saddle 3v3',1);
	thePlayer.inv.AddAnItem('Horse Saddle 3v4',1);
	thePlayer.inv.AddAnItem('Horse Saddle 4',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}

exec function WitcherHairstyle( number : int )
{
	var inv : CInventoryComponent;
	var witcher : W3PlayerWitcher;
	var ids : array<SItemUniqueId>;

	var size : int;
	var i : int;

	witcher = GetWitcherPlayer();
	inv = witcher.GetInventory();

	ids = inv.GetItemsByCategory( 'hair' );
	size = ids.Size();
	
	if( size > 0 )
	{
		
		for( i = 0; i < size; i+=1 )
		{
			inv.RemoveItem(ids[i], 1);	
		}
		
	}
	
	ids.Clear();
	
	if(number == 0)
	{
		ids = inv.AddAnItem('Half With Tail Hairstyle');
	}
	else if(number == 1)
	{
		ids = inv.AddAnItem('Shaved With Tail Hairstyle');
	}
	else if(number == 2)
	{
		ids = inv.AddAnItem('Long Loose Hairstyle');
	}
	else if( number == 3 )
	{
		ids = inv.AddAnItem('Preview Hair');
	}
	
	inv.MountItem(ids[0]);
}


exec function addupgrades(optional count : int, optional dontOpenUI : bool)
{
	if(count == 0)
		count = 1;
	
	thePlayer.inv.AddAnItem('Rune stribog lesser', count);
	thePlayer.inv.AddAnItem('Rune stribog', count);
	thePlayer.inv.AddAnItem('Rune stribog greater', count);
	thePlayer.inv.AddAnItem('Rune dazhbog lesser', count);
	thePlayer.inv.AddAnItem('Rune dazhbog', count);
	thePlayer.inv.AddAnItem('Rune dazhbog greater', count);
	thePlayer.inv.AddAnItem('Rune devana lesser', count);
	thePlayer.inv.AddAnItem('Rune devana', count);
	thePlayer.inv.AddAnItem('Rune devana greater', count);
	thePlayer.inv.AddAnItem('Rune zoria lesser', count);
	thePlayer.inv.AddAnItem('Rune zoria', count);
	thePlayer.inv.AddAnItem('Rune zoria greater', count);
	thePlayer.inv.AddAnItem('Rune morana lesser', count);
	thePlayer.inv.AddAnItem('Rune morana', count);
	thePlayer.inv.AddAnItem('Rune morana greater', count);
	thePlayer.inv.AddAnItem('Rune triglav lesser', count);
	thePlayer.inv.AddAnItem('Rune triglav', count);
	thePlayer.inv.AddAnItem('Rune triglav greater', count);
	thePlayer.inv.AddAnItem('Rune svarog lesser', count);
	thePlayer.inv.AddAnItem('Rune svarog', count);
	thePlayer.inv.AddAnItem('Rune svarog greater', count);
	thePlayer.inv.AddAnItem('Rune veles lesser', count);
	thePlayer.inv.AddAnItem('Rune veles', count);
	thePlayer.inv.AddAnItem('Rune veles greater', count);
	thePlayer.inv.AddAnItem('Rune perun lesser', count);
	thePlayer.inv.AddAnItem('Rune perun', count);
	thePlayer.inv.AddAnItem('Rune perun greater', count);
	thePlayer.inv.AddAnItem('Rune elemental lesser', count);
	thePlayer.inv.AddAnItem('Rune elemental', count);
	thePlayer.inv.AddAnItem('Rune elemental greater', count);
	thePlayer.inv.AddAnItem('Rune tvarog', count);
	thePlayer.inv.AddAnItem('Rune pierog', count);
	
	thePlayer.inv.AddAnItem('Glyph aard lesser', count);
	thePlayer.inv.AddAnItem('Glyph aard', count);
	thePlayer.inv.AddAnItem('Glyph aard greater', count);
	thePlayer.inv.AddAnItem('Glyph axii lesser', count);
	thePlayer.inv.AddAnItem('Glyph axii', count);
	thePlayer.inv.AddAnItem('Glyph axii greater', count);
	thePlayer.inv.AddAnItem('Glyph igni lesser', count);
	thePlayer.inv.AddAnItem('Glyph igni', count);
	thePlayer.inv.AddAnItem('Glyph igni greater', count);
	thePlayer.inv.AddAnItem('Glyph quen lesser', count);
	thePlayer.inv.AddAnItem('Glyph quen', count);
	thePlayer.inv.AddAnItem('Glyph quen greater', count);
	thePlayer.inv.AddAnItem('Glyph yrden lesser', count);
	thePlayer.inv.AddAnItem('Glyph yrden', count);
	thePlayer.inv.AddAnItem('Glyph yrden greater', count);
	thePlayer.inv.AddAnItem('Glyph warding lesser', count);
	thePlayer.inv.AddAnItem('Glyph warding', count);
	thePlayer.inv.AddAnItem('Glyph warding greater', count);
	thePlayer.inv.AddAnItem('Glyph binding lesser', count);
	thePlayer.inv.AddAnItem('Glyph binding', count);
	thePlayer.inv.AddAnItem('Glyph binding greater', count);
	thePlayer.inv.AddAnItem('Glyph mending lesser', count);
	thePlayer.inv.AddAnItem('Glyph mending', count);
	thePlayer.inv.AddAnItem('Glyph mending greater', count);
	thePlayer.inv.AddAnItem('Glyph binding lesser', count);
	thePlayer.inv.AddAnItem('Glyph binding', count);
	thePlayer.inv.AddAnItem('Glyph binding greater', count);
	thePlayer.inv.AddAnItem('Glyph reinforcement lesser', count);
	thePlayer.inv.AddAnItem('Glyph reinforcement', count);
	thePlayer.inv.AddAnItem('Glyph reinforcement greater', count);

	if(!dontOpenUI)
		theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}

exec function addcraftingingre(optional quantity : int)
{
	if(quantity == 0)
		quantity = 20;
	
	thePlayer.inv.AddAnItem('Alghoul bone marrow',quantity);
	thePlayer.inv.AddAnItem('Amethyst dust',quantity);
	thePlayer.inv.AddAnItem('Arachas eyes',quantity);
	thePlayer.inv.AddAnItem('Arachas venom',quantity);
	thePlayer.inv.AddAnItem('Basilisk hide',quantity);
	thePlayer.inv.AddAnItem('Basilisk venom',quantity);
	thePlayer.inv.AddAnItem('Bear pelt',quantity);
	thePlayer.inv.AddAnItem('Berserker pelt',quantity);
	thePlayer.inv.AddAnItem('Coal',quantity);
	thePlayer.inv.AddAnItem('Cockatrice egg',quantity);
	thePlayer.inv.AddAnItem('Cotton',quantity);
	thePlayer.inv.AddAnItem('Crystalized essence',quantity);
	thePlayer.inv.AddAnItem('Cyclops eye',quantity);
	thePlayer.inv.AddAnItem('Czart hide',quantity);
	thePlayer.inv.AddAnItem('Dark iron ingot',quantity);
	thePlayer.inv.AddAnItem('Dark iron ore',quantity);
	thePlayer.inv.AddAnItem('Deer hide',quantity);
	thePlayer.inv.AddAnItem('Diamond dust',quantity);
	thePlayer.inv.AddAnItem('Draconide leather',quantity);
	thePlayer.inv.AddAnItem('Dragon scales',quantity);
	thePlayer.inv.AddAnItem('Drowned dead tongue',quantity);
	thePlayer.inv.AddAnItem('Drowner brain',quantity);
	thePlayer.inv.AddAnItem('Dwimeryte ingot',quantity);
	thePlayer.inv.AddAnItem('Dwimeryte ore',quantity);
	thePlayer.inv.AddAnItem('Elemental essence',quantity);
	thePlayer.inv.AddAnItem('Elemental rune',quantity);
	thePlayer.inv.AddAnItem('Emerald dust',quantity);
	thePlayer.inv.AddAnItem('Endriag chitin plates',quantity);
	thePlayer.inv.AddAnItem('Endriag embryo',quantity);
	thePlayer.inv.AddAnItem('Fiend eye',quantity);
	thePlayer.inv.AddAnItem('Forgotten soul',quantity);
	thePlayer.inv.AddAnItem('Forktail hide',quantity);
	thePlayer.inv.AddAnItem('Gargoyle Dust',quantity);
	thePlayer.inv.AddAnItem('Gargoyle Heart',quantity);
	thePlayer.inv.AddAnItem('Ghoul blood',quantity);
	thePlayer.inv.AddAnItem('Glowing ore',quantity);
	thePlayer.inv.AddAnItem('Goat hide',quantity);
	thePlayer.inv.AddAnItem('Golem heart',quantity);
	thePlayer.inv.AddAnItem('Gryphon egg',quantity);
	thePlayer.inv.AddAnItem('Gryphon feathers',quantity);
	thePlayer.inv.AddAnItem('Hag teeth',quantity);
	thePlayer.inv.AddAnItem('Hardened leather',quantity);
	thePlayer.inv.AddAnItem('Hardened timber',quantity);
	thePlayer.inv.AddAnItem('Harpy feathers',quantity);
	thePlayer.inv.AddAnItem('Horse hide',quantity);
	thePlayer.inv.AddAnItem('Iron ore',quantity);
	thePlayer.inv.AddAnItem('Lamia lock of hair',quantity);
	thePlayer.inv.AddAnItem('Leather straps',quantity);
	thePlayer.inv.AddAnItem('Leather',quantity);
	thePlayer.inv.AddAnItem('Leshy resin',quantity);
	thePlayer.inv.AddAnItem('Linen',quantity);
	thePlayer.inv.AddAnItem('Meteorite ingot',quantity);
	thePlayer.inv.AddAnItem('Meteorite ore',quantity);
	thePlayer.inv.AddAnItem('Necrophage skin',quantity);
	thePlayer.inv.AddAnItem('Nekker blood',quantity);
	thePlayer.inv.AddAnItem('Nekker heart',quantity);
	thePlayer.inv.AddAnItem('Nightwraith dark essence',quantity);
	thePlayer.inv.AddAnItem('Noonwraith light essence',quantity);
	thePlayer.inv.AddAnItem('Oil',quantity);
	thePlayer.inv.AddAnItem('Phosphorescent crystal',quantity);
	thePlayer.inv.AddAnItem('Pig hide',quantity);
	thePlayer.inv.AddAnItem('Pure silver',quantity);
	thePlayer.inv.AddAnItem('Rabbit pelt',quantity);
	thePlayer.inv.AddAnItem('Rotfiend blood',quantity);
	thePlayer.inv.AddAnItem('Sapphire dust',quantity);
	thePlayer.inv.AddAnItem('Shattered core',quantity);
	thePlayer.inv.AddAnItem('Silk',quantity);
	thePlayer.inv.AddAnItem('Silver ingot',quantity);
	thePlayer.inv.AddAnItem('Silver mineral',quantity);
	thePlayer.inv.AddAnItem('Silver ore',quantity);
	thePlayer.inv.AddAnItem('Siren vocal cords',quantity);
	thePlayer.inv.AddAnItem('Specter dust',quantity);
	thePlayer.inv.AddAnItem('Steel ingot',quantity);
	thePlayer.inv.AddAnItem('Steel plate',quantity);
	thePlayer.inv.AddAnItem('String',quantity);
	thePlayer.inv.AddAnItem('Thread',quantity);
	thePlayer.inv.AddAnItem('Timber',quantity);
	thePlayer.inv.AddAnItem('Troll skin',quantity);
	thePlayer.inv.AddAnItem('Twine',quantity);
	thePlayer.inv.AddAnItem('Vampire fang',quantity);
	thePlayer.inv.AddAnItem('Vampire saliva',quantity);
	thePlayer.inv.AddAnItem('Venom extract',quantity);
	thePlayer.inv.AddAnItem('Water essence',quantity);
	thePlayer.inv.AddAnItem('Werewolf pelt',quantity);
	thePlayer.inv.AddAnItem('Werewolf saliva',quantity);
	thePlayer.inv.AddAnItem('White bear pelt',quantity);
	thePlayer.inv.AddAnItem('White wolf pelt',quantity);
	thePlayer.inv.AddAnItem('Wolf liver',quantity);
	thePlayer.inv.AddAnItem('Wolf pelt',quantity);
	thePlayer.inv.AddAnItem('Wyvern egg',quantity);
	thePlayer.inv.AddAnItem('Wyvern plate',quantity);
}

exec function addCraftingItem( item : int)
{
	var quantity : int;
	quantity = 20;

	switch ( item )
	{
		case 2:
			thePlayer.inv.AddAnItem('Alghoul bone marrow',quantity);
			break;
		
		case 3:
			thePlayer.inv.AddAnItem('Amethyst dust',quantity);
			break;
		
		case 4:
			thePlayer.inv.AddAnItem('Arachas eyes',quantity);
			break;
		
		case 5:
			thePlayer.inv.AddAnItem('Arachas venom',quantity);
			break;
		
		case 6:
			thePlayer.inv.AddAnItem('Basilisk hide',quantity);
			break;
		
		case 7:
			thePlayer.inv.AddAnItem('Basilisk venom',quantity);
			break;
		
		case 8:
			thePlayer.inv.AddAnItem('Bear pelt',quantity);
			break;
		
		case 9:
			thePlayer.inv.AddAnItem('Berserker pelt',quantity);
			break;
		
		case 10:
			thePlayer.inv.AddAnItem('Coal',quantity);

		case 11:
			thePlayer.inv.AddAnItem('Cockatrice egg',quantity);
			break;
		case 12:
			thePlayer.inv.AddAnItem('Cotton',quantity);
			break;
		case 13:
			thePlayer.inv.AddAnItem('Crystalized essence',quantity);
			break;
		case 14:
			thePlayer.inv.AddAnItem('Cyclops eye',quantity);
			break;
		case 15:
			thePlayer.inv.AddAnItem('Czart hide',quantity);
			break;
		case 16:
			thePlayer.inv.AddAnItem('Dark iron ingot',quantity);
			break;
		case 17:
			thePlayer.inv.AddAnItem('Dark iron ore',quantity);
			break;
		case 18:
			thePlayer.inv.AddAnItem('Deer hide',quantity);
			break;
		case 19:
			thePlayer.inv.AddAnItem('Diamond dust',quantity);
			break;
		case 20:
			thePlayer.inv.AddAnItem('Draconide leather',quantity);
			break;
		case 21:
			thePlayer.inv.AddAnItem('Dragon scales',quantity);
			break;
		case 22:
			thePlayer.inv.AddAnItem('Drowned dead tongue',quantity);
			break;
		case 23:
			thePlayer.inv.AddAnItem('Drowner brain',quantity);
			break;
		case 24:
			thePlayer.inv.AddAnItem('Dwimeryte ingot',quantity);
			break;
		case 25:
			thePlayer.inv.AddAnItem('Dwimeryte ore',quantity);
			break;
		case 26:
			thePlayer.inv.AddAnItem('Elemental essence',quantity);
			break;
		case 27:
			thePlayer.inv.AddAnItem('Elemental rune',quantity);
			break;
		case 28:
			thePlayer.inv.AddAnItem('Emerald dust',quantity);
			break;
		case 29:
			thePlayer.inv.AddAnItem('Endriag chitin plates',quantity);
			break;
		case 30:
			thePlayer.inv.AddAnItem('Endriag embryo',quantity);
			break;
		case 31:
			thePlayer.inv.AddAnItem('Fiend eye',quantity);
			break;
		case 32:
			thePlayer.inv.AddAnItem('Forgotten soul',quantity);
			break;
		case 33:
			thePlayer.inv.AddAnItem('Forktail hide',quantity);
			break;
		case 34:
			thePlayer.inv.AddAnItem('Gargoyle Dust',quantity);
			break;
		case 35:
			thePlayer.inv.AddAnItem('Gargoyle Heart',quantity);
			break;
		case 36:
			thePlayer.inv.AddAnItem('Ghoul blood',quantity);
			break;
		case 37:
			thePlayer.inv.AddAnItem('Glowing ore',quantity);
			break;
		case 38:
			thePlayer.inv.AddAnItem('Goat hide',quantity);
			break;
		case 39:
			thePlayer.inv.AddAnItem('Golem heart',quantity);
			break;
		case 40:
			thePlayer.inv.AddAnItem('Gryphon egg',quantity);
			break;
		case 41:
			thePlayer.inv.AddAnItem('Gryphon feathers',quantity);
			break;
		case 42:
			thePlayer.inv.AddAnItem('Hag teeth',quantity);
			break;
		case 43:
			thePlayer.inv.AddAnItem('Hardened leather',quantity);
			break;
		case 44:
			thePlayer.inv.AddAnItem('Hardened timber',quantity);
			break;
		case 45:
			thePlayer.inv.AddAnItem('Harpy feathers',quantity);
			break;
		case 46:
			thePlayer.inv.AddAnItem('Horse hide',quantity);
			break;
		case 47:
			thePlayer.inv.AddAnItem('Iron ore',quantity);
			break;
		case 48:
			thePlayer.inv.AddAnItem('Lamia lock of hair',quantity);
			break;
		case 49:
			thePlayer.inv.AddAnItem('Leather straps',quantity);
			break;
		case 50:
			thePlayer.inv.AddAnItem('Leather',quantity);
			break;
		case 51:
			thePlayer.inv.AddAnItem('Leshy resin',quantity);
			break;
		case 52:
			thePlayer.inv.AddAnItem('Linen',quantity);
			break;
		case 53:
			thePlayer.inv.AddAnItem('Meteorite ingot',quantity);
			break;
		case 54:
			thePlayer.inv.AddAnItem('Meteorite ore',quantity);
			break;
		case 55:
			thePlayer.inv.AddAnItem('Necrophage skin',quantity);
			break;
		case 56:
			thePlayer.inv.AddAnItem('Nekker blood',quantity);
			break;
		case 57:
			thePlayer.inv.AddAnItem('Nekker heart',quantity);
			break;
		case 58:
			thePlayer.inv.AddAnItem('Nightwraith dark essence',quantity);
			break;
		case 59:
			thePlayer.inv.AddAnItem('Noonwraith light essence',quantity);
			break;
		case 60:
			thePlayer.inv.AddAnItem('Oil',quantity);
			break;
		case 61:
			thePlayer.inv.AddAnItem('Phosphorescent crystal',quantity);
			break;
		case 62:
			thePlayer.inv.AddAnItem('Pig hide',quantity);
			break;
		case 63:
			thePlayer.inv.AddAnItem('Pure silver',quantity);
			break;
		case 64:
			thePlayer.inv.AddAnItem('Rabbit pelt',quantity);
			break;
		case 65:
			thePlayer.inv.AddAnItem('Rotfiend blood',quantity);
			break;
		case 66:
			thePlayer.inv.AddAnItem('Sapphire dust',quantity);
			break;
		case 67:
			thePlayer.inv.AddAnItem('Shattered core',quantity);
			break;
		case 68:
			thePlayer.inv.AddAnItem('Silk',quantity);
			break;
		case 69:
			thePlayer.inv.AddAnItem('Silver ingot',quantity);
			break;
		case 70:
			thePlayer.inv.AddAnItem('Silver mineral',quantity);
			break;
		case 71:
			thePlayer.inv.AddAnItem('Silver ore',quantity);
			break;
		case 72:
			thePlayer.inv.AddAnItem('Siren vocal cords',quantity);
			break;
		case 73:
			thePlayer.inv.AddAnItem('Specter dust',quantity);
			break;
		case 74:
			thePlayer.inv.AddAnItem('Steel ingot',quantity);
			break;
		case 75:
			thePlayer.inv.AddAnItem('Steel plate',quantity);
			break;
		case 76:
			thePlayer.inv.AddAnItem('String',quantity);
			break;
		case 77:
			thePlayer.inv.AddAnItem('Thread',quantity);
			break;
		case 78:
			thePlayer.inv.AddAnItem('Timber',quantity);
			break;
		case 79:
			thePlayer.inv.AddAnItem('Troll skin',quantity);
			break;
		case 80:
			thePlayer.inv.AddAnItem('Twine',quantity);
			break;
		case 81:
			thePlayer.inv.AddAnItem('Vampire fang',quantity);
			break;
		case 82:
			thePlayer.inv.AddAnItem('Vampire saliva',quantity);
			break;
		case 83:
			thePlayer.inv.AddAnItem('Venom extract',quantity);
			break;
		case 84:
			thePlayer.inv.AddAnItem('Water essence',quantity);
			break;
		case 85:
			thePlayer.inv.AddAnItem('Werewolf pelt',quantity);
			break;
		case 86:
			thePlayer.inv.AddAnItem('Werewolf saliva',quantity);
			break;
		case 87:
			thePlayer.inv.AddAnItem('White bear pelt',quantity);
			break;
		case 88:
			thePlayer.inv.AddAnItem('White wolf pelt',quantity);
			break;
		case 89:
			thePlayer.inv.AddAnItem('Wolf liver',quantity);
			break;
		case 90:
			thePlayer.inv.AddAnItem('Wolf pelt',quantity);
			break;
		case 91:
			thePlayer.inv.AddAnItem('Wyvern egg',quantity);
			break;
		case 92:
			thePlayer.inv.AddAnItem('Wyvern plate',quantity);
			break;
	}
}
exec function learnallschematics()
{
	GetWitcherPlayer().AddCraftingSchematic('Short sword 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Short sword 2 schematic');
	GetWitcherPlayer().AddCraftingSchematic('No Mans Land sword 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('No Mans Land sword 2 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Skellige sword 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Lynx School steel sword schematic');
	GetWitcherPlayer().AddCraftingSchematic('Bear School Crossbow schematic');
	GetWitcherPlayer().AddCraftingSchematic('Lynx School Crossbow schematicfting_');
	GetWitcherPlayer().AddCraftingSchematic('Nilfgaardian sword 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Novigraadan sword 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('No Mans Land sword 3 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Light Armor 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Skellige sword 2 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Gryphon School steel sword schematic');
	GetWitcherPlayer().AddCraftingSchematic('Viper Steel sword schematic');
	GetWitcherPlayer().AddCraftingSchematic('No Mans Land sword 4 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Scoiatael sword 2 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Novigraadan sword 4 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Nilfgaardian sword 4 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Scoiatael sword 3 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Inquisitor sword 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Bear School steel sword schematic');
	GetWitcherPlayer().AddCraftingSchematic('Wolf School steel sword schematic');
	GetWitcherPlayer().AddCraftingSchematic('Inquisitor sword 2 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Silver sword 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Silver sword 2 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Viper Silver sword schematic');
	GetWitcherPlayer().AddCraftingSchematic('Lynx School silver sword schematic');
	
	GetWitcherPlayer().AddCraftingSchematic('Boots 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Dwarven sword 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Boots 2 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Dwarven sword 2 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Boots 3 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Gnomish sword 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Boots 4 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Gnomish sword 2 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Heavy Boots 1 schematic');
	
	GetWitcherPlayer().AddCraftingSchematic('Pants 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Silver sword 3 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Pants 2 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Gryphon School silver sword schematic');
	GetWitcherPlayer().AddCraftingSchematic('Pants 3 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Silver sword 4 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Pants 4 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Silver sword 6 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Heavy Pants 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Silver sword 7 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Heavy Pants 2 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Elven silver sword 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Heavy Pants 3 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Bear School silver sword schematic');
	GetWitcherPlayer().AddCraftingSchematic('Heavy Pants 4 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Elven silver sword 2 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Wolf School silver sword schematic');
	
	GetWitcherPlayer().AddCraftingSchematic('Gloves 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Dwarven silver sword 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Gloves 2 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Dwarven silver sword 2 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Gloves 3 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Gnomish silver sword 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Gloves 4 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Gnomish silver sword 2 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Heavy Gloves 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Heavy Gloves 2 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Heavy Gloves 3 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Heavy Gloves 4 schematic');
	
	GetWitcherPlayer().AddCraftingSchematic('Lynx Armor schematic');
	GetWitcherPlayer().AddCraftingSchematic('Lynx Boots 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Lynx Gloves 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Lynx Pants 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Gryphon Armor schematic');
	GetWitcherPlayer().AddCraftingSchematic('Gryphon Boots 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Gryphon Gloves 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Gryphon Pants 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Bear Armor schematic');
	GetWitcherPlayer().AddCraftingSchematic('Bear Boots 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Bear Gloves 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Bear Pants 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Wolf Armor schematic');
	GetWitcherPlayer().AddCraftingSchematic('Wolf Boots 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Wolf Gloves 1 schematic');
	GetWitcherPlayer().AddCraftingSchematic('Wolf Pants 1 schematic');
	
	GetWitcherPlayer().AddCraftingSchematic('Witcher Bear Jacket Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Bear Jacket Upgrade schematic 2');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Bear Jacket Upgrade schematic 3');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Bear Boots Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Bear Pants Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Bear Gloves Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Bear School steel sword Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Bear School steel sword Upgrade schematic 2');
	GetWitcherPlayer().AddCraftingSchematic('Bear School steel sword Upgrade schematic 3');
	GetWitcherPlayer().AddCraftingSchematic('Bear School silver sword Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Bear School silver sword Upgrade schematic 2');
	GetWitcherPlayer().AddCraftingSchematic('Bear School silver sword Upgrade schematic 3');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Gryphon Jacket Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Gryphon Jacket Upgrade schematic 2');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Gryphon Jacket Upgrade schematic 3');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Gryphon Boots Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Gryphon Pants Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Gryphon Gloves Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Gryphon School steel sword Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Gryphon School steel sword Upgrade schematic 2');
	GetWitcherPlayer().AddCraftingSchematic('Gryphon School steel sword Upgrade schematic 3');
	GetWitcherPlayer().AddCraftingSchematic('Gryphon School silver sword Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Gryphon School silver sword Upgrade schematic 2');
	GetWitcherPlayer().AddCraftingSchematic('Gryphon School silver sword Upgrade schematic 3');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Wolf Jacket Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Wolf Jacket Upgrade schematic 2');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Wolf Jacket Upgrade schematic 3');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Wolf Boots Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Wolf Pants Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Wolf Gloves Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Wolf School steel sword Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Wolf School steel sword Upgrade schematic 2');
	GetWitcherPlayer().AddCraftingSchematic('Wolf School steel sword Upgrade schematic 3');
	GetWitcherPlayer().AddCraftingSchematic('Wolf School silver sword Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Wolf School silver sword Upgrade schematic 2');
	GetWitcherPlayer().AddCraftingSchematic('Wolf School silver sword Upgrade schematic 3');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Lynx Jacket Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Lynx Jacket Upgrade schematic 2');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Lynx Jacket Upgrade schematic 3');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Lynx Boots Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Lynx Pants Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Witcher Lynx Gloves Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Lynx School steel sword Upgrade schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Lynx School steel sword Upgrade schematic 2');
	GetWitcherPlayer().AddCraftingSchematic('Lynx School steel sword Upgrade schematic 3');
	GetWitcherPlayer().AddCraftingSchematic('Lynx School silver sword Upgrade schematic ');
	GetWitcherPlayer().AddCraftingSchematic('Lynx School silver sword Upgrade schematic 2');
	GetWitcherPlayer().AddCraftingSchematic('Lynx School silver sword Upgrade schematic 3'); 
	
	GetWitcherPlayer().AddCraftingSchematic('Steel ingot schematic');
	GetWitcherPlayer().AddCraftingSchematic('Dark iron ingot schematic');
	GetWitcherPlayer().AddCraftingSchematic('Meteorite ingot schematic');
	GetWitcherPlayer().AddCraftingSchematic('Dwimeryte ingot schematic');
	GetWitcherPlayer().AddCraftingSchematic('Silver ingot schematic 1a');
	GetWitcherPlayer().AddCraftingSchematic('Silver ingot schematic 2a');
	GetWitcherPlayer().AddCraftingSchematic('Silver ingot schematic 3a');
	GetWitcherPlayer().AddCraftingSchematic('Hardened leather schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Hardened leather schematic 2');
	GetWitcherPlayer().AddCraftingSchematic('Hardened leather schematic 3');
	GetWitcherPlayer().AddCraftingSchematic('Hardened leather schematic 4');
	GetWitcherPlayer().AddCraftingSchematic('Hardened timber schematic 1h');
	GetWitcherPlayer().AddCraftingSchematic('Draconide leather schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Draconide leather schematic 2');
	GetWitcherPlayer().AddCraftingSchematic('Draconide leather schematic 3');
	GetWitcherPlayer().AddCraftingSchematic('Draconide leather schematic ');
	GetWitcherPlayer().AddCraftingSchematic('Leather schematic 1');
	GetWitcherPlayer().AddCraftingSchematic('Leather schematic 2');
	GetWitcherPlayer().AddCraftingSchematic('Leather schematic 3');
	GetWitcherPlayer().AddCraftingSchematic('Leather schematic 4');
	GetWitcherPlayer().AddCraftingSchematic('Leather schematic 5');
	GetWitcherPlayer().AddCraftingSchematic('Leather schematic 6');
	GetWitcherPlayer().AddCraftingSchematic('Leather schematic 7');
	GetWitcherPlayer().AddCraftingSchematic('Leather schematic 8');
	GetWitcherPlayer().AddCraftingSchematic('Leather straps schematic');
	GetWitcherPlayer().AddCraftingSchematic('Steel plate schematic');
	
	GetWitcherPlayer().AddCraftingSchematic('Rune stribog lesser schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune stribog schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune stribog greater schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune dazhbog lesser schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune dazhbog schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune dazhbog greater schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune devana lesser schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune devana schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune devana greater schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune zoria lesser schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune zoria schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune zoria greater schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune morana lesser schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune morana schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune morana greater schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune triglav lesser schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune triglav schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune triglav greater schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune svarog lesser schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune svarog schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune svarog greater schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune veles lesser schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune veles schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune veles greater schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune perun lesser schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune perun schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune perun greater schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune elemental lesser schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune elemental schematic');
	GetWitcherPlayer().AddCraftingSchematic('Rune elemental greater schematic');
}

exec function addcraftedsteel()
{
	thePlayer.inv.AddAnItem('Short sword 1_crafted',1);
	thePlayer.inv.AddAnItem('Short sword 2_crafted',1);
	thePlayer.inv.AddAnItem('No Mans Land sword 1_crafted',1);
	thePlayer.inv.AddAnItem('No Mans Land sword 2_crafted',1);
	thePlayer.inv.AddAnItem('Skellige sword 1_crafted',1);
	thePlayer.inv.AddAnItem('Lynx School steel sword',1);
	thePlayer.inv.AddAnItem('Nilfgaardian sword 1_crafted',1);
	thePlayer.inv.AddAnItem('Novigraadan sword 1_crafted',1);
	thePlayer.inv.AddAnItem('No Mans Land sword 3_crafted',1);
	thePlayer.inv.AddAnItem('Skellige sword 2_crafted',1);
	thePlayer.inv.AddAnItem('Gryphon School steel sword',1);
	thePlayer.inv.AddAnItem('Viper School steel sword',1);
	thePlayer.inv.AddAnItem('No Mans Land sword 4_crafted',1);
	thePlayer.inv.AddAnItem('Scoiatael sword 2_crafted',1);
	thePlayer.inv.AddAnItem('Novigraadan sword 4_crafted',1);
	thePlayer.inv.AddAnItem('Nilfgaardian sword 4_crafted',1);
	thePlayer.inv.AddAnItem('Scoiatael sword 3_crafted',1);
	thePlayer.inv.AddAnItem('Inquisitor sword 1_crafted',1);
	thePlayer.inv.AddAnItem('Bear School steel sword',1);
	thePlayer.inv.AddAnItem('Wolf School steel sword',1);
	thePlayer.inv.AddAnItem('Inquisitor sword 2_crafted',1);
	thePlayer.inv.AddAnItem('Dwarven sword 1_crafted',1);
	thePlayer.inv.AddAnItem('Dwarven sword 2_crafted',1);
	thePlayer.inv.AddAnItem('Gnomish sword 1_crafted',1);
	thePlayer.inv.AddAnItem('Gnomish sword 2_crafted',1);

	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}

exec function testrune()
{
	thePlayer.inv.AddAnItem('Bear School steel sword 2');
	thePlayer.inv.AddAnItem('Zoria rune');
}

exec function addcraftedsilver()
{
	thePlayer.inv.AddAnItem('Silver sword 1_crafted',1);
	thePlayer.inv.AddAnItem('Silver sword 2_crafted',1);
	thePlayer.inv.AddAnItem('Viper School Silver sword',1);
	thePlayer.inv.AddAnItem('Lynx School silver sword',1);
	thePlayer.inv.AddAnItem('Silver sword 3_crafted',1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword',1);
	thePlayer.inv.AddAnItem('Silver sword 4_crafted',1);
	thePlayer.inv.AddAnItem('Silver sword 6_crafted',1);
	thePlayer.inv.AddAnItem('Silver sword 7_crafted',1);
	thePlayer.inv.AddAnItem('Elven silver sword 1_crafted',1);
	thePlayer.inv.AddAnItem('Bear School silver sword',1);
	thePlayer.inv.AddAnItem('Elven silver sword 2_crafted',1);
	thePlayer.inv.AddAnItem('Wolf School silver sword',1);
	thePlayer.inv.AddAnItem('Dwarven silver sword 1_crafted',1);
	thePlayer.inv.AddAnItem('Dwarven silver sword 2_crafted',1);
	thePlayer.inv.AddAnItem('Gnomish silver sword 1_crafted',1);
	thePlayer.inv.AddAnItem('Gnomish silver sword 2_crafted',1);

	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}

exec function addcraftedsteelrelic()
{
	thePlayer.inv.AddAnItem('Arbitrator_crafted',1);
	thePlayer.inv.AddAnItem('Beannshie_crafted',1);
	thePlayer.inv.AddAnItem('Blackunicorn_crafted',1);
	thePlayer.inv.AddAnItem('Longclaw_crafted',1);

	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}

exec function addcraftedsilverrelic()
{
	thePlayer.inv.AddAnItem('Harpy_crafted',1);
	thePlayer.inv.AddAnItem('Negotiator_crafted',1);
	thePlayer.inv.AddAnItem('Weeper_crafted',1);

	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}

exec function addcraftedranged()
{
	thePlayer.inv.AddAnItem('Bear School Crossbow', 1);
	thePlayer.inv.AddAnItem('Lynx School Crossbow', 1);

	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}

exec function addcraftedboots()
{
	thePlayer.inv.AddAnItem('Boots 01_crafted' );
	thePlayer.inv.AddAnItem('Boots 02_crafted' );
	thePlayer.inv.AddAnItem('Boots 03_crafted' );
	thePlayer.inv.AddAnItem('Boots 04_crafted' );

	thePlayer.inv.AddAnItem('Heavy boots 01_crafted' );
	thePlayer.inv.AddAnItem('Heavy boots 02_crafted' );
	thePlayer.inv.AddAnItem('Heavy boots 03_crafted' );
	thePlayer.inv.AddAnItem('Heavy boots 04_crafted' );

	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addschematicsboots()
{
	thePlayer.inv.AddAnItem('Boots 1 schematic',1);
	thePlayer.inv.AddAnItem('Boots 2 schematic',1);
	thePlayer.inv.AddAnItem('Boots 3 schematic',1);
	thePlayer.inv.AddAnItem('Boots 4 schematic',1);
	thePlayer.inv.AddAnItem('Heavy Boots 1 schematic',1);
	thePlayer.inv.AddAnItem('Heavy Boots 2 schematic',1);
	thePlayer.inv.AddAnItem('Heavy Boots 3 schematic',1);
	thePlayer.inv.AddAnItem('Heavy Boots 4 schematic',1);

	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addschematicspants()
{
	thePlayer.inv.AddAnItem('Pants 1 schematic',1);
	thePlayer.inv.AddAnItem('Pants 2 schematic',1);
	thePlayer.inv.AddAnItem('Pants 3 schematic',1);
	thePlayer.inv.AddAnItem('Pants 4 schematic',1);
	thePlayer.inv.AddAnItem('Heavy Pants 1 schematic',1);
	thePlayer.inv.AddAnItem('Heavy Pants 2 schematic',1);
	thePlayer.inv.AddAnItem('Heavy Pants 3 schematic',1);
	thePlayer.inv.AddAnItem('Heavy Pants 4 schematic',1);

	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}
	

exec function addschematicsgloves()
{
	thePlayer.inv.AddAnItem('Gloves 1 schematic',1);
	thePlayer.inv.AddAnItem('Gloves 2 schematic',1);
	thePlayer.inv.AddAnItem('Gloves 3 schematic',1);
	thePlayer.inv.AddAnItem('Gloves 4 schematic',1);

	thePlayer.inv.AddAnItem('Heavy Gloves 1 schematic',1);
	thePlayer.inv.AddAnItem('Heavy Gloves 2 schematic',1);
	thePlayer.inv.AddAnItem('Heavy Gloves 3 schematic',1);
	thePlayer.inv.AddAnItem('Heavy Gloves 4 schematic',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addschematicsarmor()
{
	thePlayer.inv.AddAnItem('Lynx Armor schematic',1);
	thePlayer.inv.AddAnItem('Lynx Boots schematic',1);
	thePlayer.inv.AddAnItem('Lynx Gloves schematic',1);
	thePlayer.inv.AddAnItem('Lynx Pants schematic',1);
	thePlayer.inv.AddAnItem('Gryphon Armor schematic',1);
	thePlayer.inv.AddAnItem('Gryphon Boots schematic',1);
	thePlayer.inv.AddAnItem('Gryphon Gloves schematic',1);
	thePlayer.inv.AddAnItem('Gryphon Pants schematic',1);
	thePlayer.inv.AddAnItem('Bear Armor schematic',1);
	thePlayer.inv.AddAnItem('Bear Boots schematic',1);
	thePlayer.inv.AddAnItem('Bear Gloves schematic',1);
	thePlayer.inv.AddAnItem('Bear Pants schematic',1);
	thePlayer.inv.AddAnItem('Wolf Armor schematic',1);
	thePlayer.inv.AddAnItem('Wolf Boots schematic',1);
	thePlayer.inv.AddAnItem('Wolf Gloves schematic',1);
	thePlayer.inv.AddAnItem('Wolf Pants schematic',1);
	thePlayer.inv.AddAnItem('Light Armor 1 schematic',1);
	thePlayer.inv.AddAnItem('Light Armor 1 schematic',1);
	thePlayer.inv.AddAnItem('Light Armor 2 schematic',1);
	thePlayer.inv.AddAnItem('Light Armor 3 schematic',1);
	thePlayer.inv.AddAnItem('Light Armor 4 schematic',1);
	thePlayer.inv.AddAnItem('Light Armor 5 schematic',1);
	thePlayer.inv.AddAnItem('Light Armor 6 schematic',1);
	thePlayer.inv.AddAnItem('Light Armor 7 schematic',1);
	thePlayer.inv.AddAnItem('Light Armor 8 schematic',1);
	thePlayer.inv.AddAnItem('Medium Armor 1 schematic',1);
	thePlayer.inv.AddAnItem('Medium Armor 2 schematic',1);
	thePlayer.inv.AddAnItem('Medium Armor 3 schematic',1);
	thePlayer.inv.AddAnItem('Medium Armor 4 schematic',1);
	thePlayer.inv.AddAnItem('Medium Armor 5 schematic',1);
	thePlayer.inv.AddAnItem('Medium Armor 6 schematic',1);
	thePlayer.inv.AddAnItem('Medium Armor 7 schematic',1);
	thePlayer.inv.AddAnItem('Medium Armor 8 schematic',1);
	thePlayer.inv.AddAnItem('Medium Armor 9 schematic',1);
	thePlayer.inv.AddAnItem('Medium Armor 10 schematic',1);
	thePlayer.inv.AddAnItem('Heavy Armor 1 schematic',1);
	thePlayer.inv.AddAnItem('Heavy Armor 2 schematic',1);
	thePlayer.inv.AddAnItem('Heavy Armor 3 schematic',1);
	thePlayer.inv.AddAnItem('Heavy Armor 4 schematic',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addschematicscomponents()
{
	thePlayer.inv.AddAnItem('Steel ingot schematic',1);
	thePlayer.inv.AddAnItem('Dark iron ingot schematic',1);
	thePlayer.inv.AddAnItem('Meteorite ingot schematic',1);
	thePlayer.inv.AddAnItem('Dwimeryte ingot schematic',1);
	thePlayer.inv.AddAnItem('Silver ingot schematic 1a',1);
	thePlayer.inv.AddAnItem('Silver ingot schematic 2a',1);
	thePlayer.inv.AddAnItem('Silver ingot schematic 3a',1);
	thePlayer.inv.AddAnItem('Hardened leather schematic 1',1);
	thePlayer.inv.AddAnItem('Hardened leather schematic 2',1);
	thePlayer.inv.AddAnItem('Hardened leather schematic 3',1);
	thePlayer.inv.AddAnItem('Hardened leather schematic 4',1);
	thePlayer.inv.AddAnItem('Hardened timber schematic 1h',1);
	thePlayer.inv.AddAnItem('Draconide leather schematic 1',1);
	thePlayer.inv.AddAnItem('Draconide leather schematic 2',1);
	thePlayer.inv.AddAnItem('Draconide leather schematic 3',1);
	thePlayer.inv.AddAnItem('Draconide leather schematic ',1);
	thePlayer.inv.AddAnItem('Leather schematic 1',1);
	thePlayer.inv.AddAnItem('Leather schematic 2',1);
	thePlayer.inv.AddAnItem('Leather schematic 3',1);
	thePlayer.inv.AddAnItem('Leather schematic 4',1);
	thePlayer.inv.AddAnItem('Leather schematic 5',1);
	thePlayer.inv.AddAnItem('Leather schematic 6',1);
	thePlayer.inv.AddAnItem('Leather schematic 7',1);
	thePlayer.inv.AddAnItem('Leather schematic 8',1);
	thePlayer.inv.AddAnItem('Leather straps schematic',1);
	thePlayer.inv.AddAnItem('Steel plate schematic',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}

exec function addsecondary()
{
	thePlayer.inv.AddAnItem('W_Axe01',1);
	thePlayer.inv.AddAnItem('W_Axe02',1);
	thePlayer.inv.AddAnItem('W_Axe03',1);
	thePlayer.inv.AddAnItem('W_Axe04',1);
	thePlayer.inv.AddAnItem('W_Axe05',1);
	thePlayer.inv.AddAnItem('W_Axe06',1);
	thePlayer.inv.AddAnItem('W_Club',1);
	thePlayer.inv.AddAnItem('W_Mace01',1);
	thePlayer.inv.AddAnItem('W_Mace02',1);
	thePlayer.inv.AddAnItem('W_Pickaxe',1);
	thePlayer.inv.AddAnItem('W_Poker',1);

	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addschematicsupgrades()
{
	thePlayer.inv.AddAnItem('Witcher Bear Jacket Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Witcher Bear Jacket Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Witcher Bear Jacket Upgrade schematic 3',1);
	thePlayer.inv.AddAnItem('Witcher Bear Boots Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Witcher Bear Pants Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Witcher Bear Gloves Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Bear School steel sword Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Bear School steel sword Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Bear School steel sword Upgrade schematic 3',1);
	thePlayer.inv.AddAnItem('Bear School silver sword Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Bear School silver sword Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Bear School silver sword Upgrade schematic 3',1);
	thePlayer.inv.AddAnItem('Witcher Gryphon Jacket Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Witcher Gryphon Jacket Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Witcher Gryphon Jacket Upgrade schematic 3',1);
	thePlayer.inv.AddAnItem('Witcher Gryphon Boots Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Witcher Gryphon Pants Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Witcher Gryphon Gloves Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Gryphon School steel sword Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Gryphon School steel sword Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Gryphon School steel sword Upgrade schematic 3',1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword Upgrade schematic 3',1);
	thePlayer.inv.AddAnItem('Witcher Wolf Jacket Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Witcher Wolf Jacket Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Witcher Wolf Jacket Upgrade schematic 3',1);
	thePlayer.inv.AddAnItem('Witcher Wolf Boots Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Witcher Wolf Pants Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Witcher Wolf Gloves Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Wolf School steel sword Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Wolf School steel sword Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Wolf School steel sword Upgrade schematic 3',1);
	thePlayer.inv.AddAnItem('Wolf School silver sword Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Wolf School silver sword Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Wolf School silver sword Upgrade schematic 3',1);
	thePlayer.inv.AddAnItem('Witcher Lynx Jacket Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Witcher Lynx Jacket Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Witcher Lynx Jacket Upgrade schematic 3',1);
	thePlayer.inv.AddAnItem('Witcher Lynx Boots Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Witcher Lynx Pants Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Witcher Lynx Gloves Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Lynx School steel sword Upgrade schematic 1',1);
	thePlayer.inv.AddAnItem('Lynx School steel sword Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Lynx School steel sword Upgrade schematic 3',1);
	thePlayer.inv.AddAnItem('Lynx School silver sword Upgrade schematic ',1);
	thePlayer.inv.AddAnItem('Lynx School silver sword Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Lynx School silver sword Upgrade schematic 3',1); 
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addschematicsbolts()
{
	thePlayer.inv.AddAnItem('Bodkin Bolt schematic',1);
	thePlayer.inv.AddAnItem('Tracking Bolt schematic',1);
	thePlayer.inv.AddAnItem('Bait Bolt schematic',1);
	thePlayer.inv.AddAnItem('Blunt Bolt schematic',1);
	thePlayer.inv.AddAnItem('Broadhead Bolt schematic',1);
	thePlayer.inv.AddAnItem('Target Point Bolt schematic',1);
	thePlayer.inv.AddAnItem('Split Bolt schematic',1);
	thePlayer.inv.AddAnItem('Explosive Bolt schematic',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addmutagens()
{
	thePlayer.inv.AddAnItem('Mutagen Sword',1);
	thePlayer.inv.AddAnItem('Mutagen Magic',1);
	thePlayer.inv.AddAnItem('Mutagen Alchemy',1);
	thePlayer.inv.AddAnItem('Mutagen Ulti',1);
	thePlayer.inv.AddAnItem('Mutagen 1',1);
	thePlayer.inv.AddAnItem('Mutagen 2',1);
	thePlayer.inv.AddAnItem('Mutagen 3',1);
	thePlayer.inv.AddAnItem('Mutagen 4',1);
	thePlayer.inv.AddAnItem('Mutagen 5',1);
	thePlayer.inv.AddAnItem('Mutagen 6',1);
	thePlayer.inv.AddAnItem('Mutagen 7',1);
	thePlayer.inv.AddAnItem('Mutagen 8',1);
	thePlayer.inv.AddAnItem('Mutagen 9',1);
	thePlayer.inv.AddAnItem('Mutagen 10',1);
	thePlayer.inv.AddAnItem('Mutagen 11',1);
	thePlayer.inv.AddAnItem('Mutagen 12',1);
	thePlayer.inv.AddAnItem('Mutagen 13',1);
	thePlayer.inv.AddAnItem('Mutagen 14',1);
	thePlayer.inv.AddAnItem('Mutagen 15',1);
	thePlayer.inv.AddAnItem('Mutagen 16',1);
	thePlayer.inv.AddAnItem('Mutagen 17',1);
	thePlayer.inv.AddAnItem('Mutagen 18',1);
	thePlayer.inv.AddAnItem('Mutagen 19',1);
	thePlayer.inv.AddAnItem('Mutagen 20',1);
	thePlayer.inv.AddAnItem('Mutagen 21',1);
	thePlayer.inv.AddAnItem('Mutagen 22',1);
	thePlayer.inv.AddAnItem('Mutagen 23',1);
	thePlayer.inv.AddAnItem('Mutagen 24',1);
	thePlayer.inv.AddAnItem('Mutagen 25',1);
	thePlayer.inv.AddAnItem('Mutagen 26',1);
	thePlayer.inv.AddAnItem('Mutagen 27',1);
	thePlayer.inv.AddAnItem('Mutagen 28',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}

exec function addmutageningredients()
{
	thePlayer.inv.AddAnItem('Lesser mutagen red',1);
	thePlayer.inv.AddAnItem('Lesser mutagen green',1);
	thePlayer.inv.AddAnItem('Lesser mutagen blue',1);
	thePlayer.inv.AddAnItem('Katakan mutagen',1);
	thePlayer.inv.AddAnItem('Arachas mutagen',1);
	thePlayer.inv.AddAnItem('Cockatrice mutagen',1);
	thePlayer.inv.AddAnItem('Volcanic Gryphon mutagen',1);
	thePlayer.inv.AddAnItem('Gryphon mutagen',1);
	thePlayer.inv.AddAnItem('Water Hag mutagen',1);
	thePlayer.inv.AddAnItem('Nightwraith mutagen',1);
	thePlayer.inv.AddAnItem('Ekimma mutagen',1);
	thePlayer.inv.AddAnItem('Czart mutagen',1);
	thePlayer.inv.AddAnItem('Fogling 1 mutagen',1);
	thePlayer.inv.AddAnItem('Wyvern mutagen',1);
	thePlayer.inv.AddAnItem('Doppler mutagen',1);
	thePlayer.inv.AddAnItem('Troll mutagen',1);
	thePlayer.inv.AddAnItem('Noonwraith mutagen',1);
	thePlayer.inv.AddAnItem('Succubus mutagen',1);
	thePlayer.inv.AddAnItem('Fogling 2 mutagen',1);
	thePlayer.inv.AddAnItem('Fiend mutagen',1);
	thePlayer.inv.AddAnItem('Forktail mutagen',1);
	thePlayer.inv.AddAnItem('Grave Hag mutagen',1);
	thePlayer.inv.AddAnItem('Wraith mutagen',1);
	thePlayer.inv.AddAnItem('Dao mutagen',1);
	thePlayer.inv.AddAnItem('Lamia mutagen',1);
	thePlayer.inv.AddAnItem('Ancient Leshy mutagen',1);
	thePlayer.inv.AddAnItem('Basilisk mutagen',1);
	thePlayer.inv.AddAnItem('Werewolf mutagen',1);
	thePlayer.inv.AddAnItem('Nekker Warrior mutagen',1);
	thePlayer.inv.AddAnItem('Leshy mutagen',1);
}

exec function addmutagenrecipes()
{
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 4');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 5');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 6');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 7');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 8');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 9');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 10');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 11');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 12');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 13');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 14');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 15');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 16');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 17');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 18');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 19');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 20');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 21');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 22');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 23');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 24');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 25');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 26');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 27');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Mutagen 28');
	
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Lesser Mutagen Red to Blue');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Lesser Mutagen Red to Green');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Lesser Mutagen Blue to Red');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Lesser Mutagen Blue to Green');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Lesser Mutagen Green to Red');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Lesser Mutagen Green to Blue');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Mutagen Red to Blue');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Mutagen Red to Green');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Mutagen Blue to Red');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Mutagen Blue to Green');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Mutagen Green to Red');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Mutagen Green to Blue');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Greater Mutagen Red to Blue');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Greater Mutagen Red to Green');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Greater Mutagen Blue to Red');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Greater Mutagen Blue to Green');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Greater Mutagen Green to Red');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe Greater Mutagen Green to Blue');
}


exec function addrecipesoils()
{
	thePlayer.inv.AddAnItem('Recipe for Beast Oil 1',1);
	thePlayer.inv.AddAnItem('Recipe for Beast Oil 2',1);
	thePlayer.inv.AddAnItem('Recipe for Beast Oil 3',1);
	thePlayer.inv.AddAnItem('Recipe for Cursed Oil 1',1);
	thePlayer.inv.AddAnItem('Recipe for Cursed Oil 2',1);
	thePlayer.inv.AddAnItem('Recipe for Cursed Oil 3',1);
	thePlayer.inv.AddAnItem('Recipe for Hanged Man Venom 1',1);
	thePlayer.inv.AddAnItem('Recipe for Hanged Man Venom 2',1);
	thePlayer.inv.AddAnItem('Recipe for Hanged Man Venom 3',1);
	thePlayer.inv.AddAnItem('Recipe for Hybrid Oil 1',1);
	thePlayer.inv.AddAnItem('Recipe for Hybrid Oil 2',1);
	thePlayer.inv.AddAnItem('Recipe for Hybrid Oil 3',1);
	thePlayer.inv.AddAnItem('Recipe for Insectoid Oil 1',1);
	thePlayer.inv.AddAnItem('Recipe for Insectoid Oil 2',1);
	thePlayer.inv.AddAnItem('Recipe for Insectoid Oil 3',1);
	thePlayer.inv.AddAnItem('Recipe for Magicals Oil 1',1);
	thePlayer.inv.AddAnItem('Recipe for Magicals Oil 2',1);
	thePlayer.inv.AddAnItem('Recipe for Magicals Oil 3',1);
	thePlayer.inv.AddAnItem('Recipe for Necrophage Oil 1',1);
	thePlayer.inv.AddAnItem('Recipe for Necrophage Oil 2',1);
	thePlayer.inv.AddAnItem('Recipe for Necrophage Oil 3',1);
	thePlayer.inv.AddAnItem('Recipe for Specter Oil 1',1);
	thePlayer.inv.AddAnItem('Recipe for Specter Oil 2',1);
	thePlayer.inv.AddAnItem('Recipe for Specter Oil 3',1);
	thePlayer.inv.AddAnItem('Recipe for Vampire Oil 1',1);
	thePlayer.inv.AddAnItem('Recipe for Vampire Oil 2',1);
	thePlayer.inv.AddAnItem('Recipe for Vampire Oil 3',1);
	thePlayer.inv.AddAnItem('Recipe for Ogre Oil 1',1);
	thePlayer.inv.AddAnItem('Recipe for Ogre Oil 2',1);
	thePlayer.inv.AddAnItem('Recipe for Ogre Oil 3',1);
	thePlayer.inv.AddAnItem('Recipe for Relic Oil 1',1);
	thePlayer.inv.AddAnItem('Recipe for Relic Oil 2',1);
	thePlayer.inv.AddAnItem('Recipe for Relic Oil 3',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addrecipesbombs()
{
	thePlayer.inv.AddAnItem('Recipe for Dancing Star 1',1);
	thePlayer.inv.AddAnItem('Recipe for Dancing Star 2',1);
	thePlayer.inv.AddAnItem('Recipe for Dancing Star 3',1);
	thePlayer.inv.AddAnItem('Recipe for Devils Puffball 1',1);
	thePlayer.inv.AddAnItem('Recipe for Devils Puffball 2',1);
	thePlayer.inv.AddAnItem('Recipe for Devils Puffball 3',1);
	thePlayer.inv.AddAnItem('Recipe for Dimeritum Bomb 1',1);
	thePlayer.inv.AddAnItem('Recipe for Dimeritum Bomb 2',1);
	thePlayer.inv.AddAnItem('Recipe for Dimeritum Bomb 3',1);
	thePlayer.inv.AddAnItem('Recipe for Dragons Dream 1',1);
	thePlayer.inv.AddAnItem('Recipe for Dragons Dream 2',1);
	thePlayer.inv.AddAnItem('Recipe for Dragons Dream 3',1);
	thePlayer.inv.AddAnItem('Recipe for Grapeshot 1',1);
	thePlayer.inv.AddAnItem('Recipe for Grapeshot 2',1);
	thePlayer.inv.AddAnItem('Recipe for Grapeshot 3',1);
	thePlayer.inv.AddAnItem('Recipe for Samum 1',1);
	thePlayer.inv.AddAnItem('Recipe for Samum 2',1);
	thePlayer.inv.AddAnItem('Recipe for Samum 3',1);
	thePlayer.inv.AddAnItem('Recipe for Silver Dust Bomb 1',1);
	thePlayer.inv.AddAnItem('Recipe for Silver Dust Bomb 2',1);
	thePlayer.inv.AddAnItem('Recipe for Silver Dust Bomb 3',1);
	thePlayer.inv.AddAnItem('Recipe for White Frost 1',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addrecipespotions()
{
	thePlayer.inv.AddAnItem('Recipe for Black Blood 1',1);
	thePlayer.inv.AddAnItem('Recipe for Black Blood 2',1);
	thePlayer.inv.AddAnItem('Recipe for Black Blood 3',1);
	thePlayer.inv.AddAnItem('Recipe for Blizzard 1',1);
	thePlayer.inv.AddAnItem('Recipe for Blizzard 2',1);
	thePlayer.inv.AddAnItem('Recipe for Blizzard 3',1);
	thePlayer.inv.AddAnItem('Recipe for Cat 1',1);
	thePlayer.inv.AddAnItem('Recipe for Cat 2',1);
	thePlayer.inv.AddAnItem('Recipe for Cat 3',1);
	thePlayer.inv.AddAnItem('Recipe for Czart Lure',1);
	thePlayer.inv.AddAnItem('Recipe for Bear Pheromone Potion 1',1);
	thePlayer.inv.AddAnItem('Recipe for Drowner Pheromone Potion 1',1);
	thePlayer.inv.AddAnItem('Recipe for Nekker Pheromone Potion 1',1);
	thePlayer.inv.AddAnItem('Recipe for Full Moon 1',1);
	thePlayer.inv.AddAnItem('Recipe for Full Moon 2',1);
	thePlayer.inv.AddAnItem('Recipe for Full Moon 3',1);
	thePlayer.inv.AddAnItem('Recipe for Golden Oriole 1',1);
	thePlayer.inv.AddAnItem('Recipe for Golden Oriole 2',1);
	thePlayer.inv.AddAnItem('Recipe for Golden Oriole 3',1);
	thePlayer.inv.AddAnItem('Recipe for Killer Whale 1',1);
	thePlayer.inv.AddAnItem('Recipe for Maribor Forest 1',1);
	thePlayer.inv.AddAnItem('Recipe for Maribor Forest 2',1);
	thePlayer.inv.AddAnItem('Recipe for Maribor Forest 3',1);
	thePlayer.inv.AddAnItem('Recipe for Petris Philtre 1',1);
	thePlayer.inv.AddAnItem('Recipe for Petris Philtre 2',1);
	thePlayer.inv.AddAnItem('Recipe for Petris Philtre 3',1);
	thePlayer.inv.AddAnItem('Recipe for Pops Antidote',1);
	thePlayer.inv.AddAnItem('Recipe for Swallow 1',1);
	thePlayer.inv.AddAnItem('Recipe for Swallow 2',1);
	thePlayer.inv.AddAnItem('Recipe for Swallow 3',1);
	thePlayer.inv.AddAnItem('Recipe for Tawny Owl 1',1);
	thePlayer.inv.AddAnItem('Recipe for Tawny Owl 2',1);
	thePlayer.inv.AddAnItem('Recipe for Tawny Owl 3',1);
	thePlayer.inv.AddAnItem('Recipe for Thunderbolt 1',1);
	thePlayer.inv.AddAnItem('Recipe for Thunderbolt 2',1);
	thePlayer.inv.AddAnItem('Recipe for Thunderbolt 3',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addrecipespotions2()
{
	thePlayer.inv.AddAnItem('Recipe for Trial Potion 1',1);
	thePlayer.inv.AddAnItem('Recipe for Trial Potion 2',1);
	thePlayer.inv.AddAnItem('Recipe for Trial Potion 3',1);
	thePlayer.inv.AddAnItem('Recipe for White Gull 1',1);
	thePlayer.inv.AddAnItem('Recipe for White Honey 1',1);
	thePlayer.inv.AddAnItem('Recipe for White Honey 2',1);
	thePlayer.inv.AddAnItem('Recipe for White Honey 3',1);
	thePlayer.inv.AddAnItem('Recipe for White Raffard Decoction 1',1);
	thePlayer.inv.AddAnItem('Recipe for White Raffard Decoction 2',1);
	thePlayer.inv.AddAnItem('Recipe for White Raffard Decoction 3',1);
	thePlayer.inv.AddAnItem('Recipe for Dwarven spirit 1',1);
	thePlayer.inv.AddAnItem('Recipe for Alcohest 1',1);
	thePlayer.inv.AddAnItem('Recipe for White gull 1',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addherbs(optional cnt : int, optional noMenu : bool)
{
	if(cnt == 0)
		cnt = 1;
		
	thePlayer.inv.AddAnItem('Allspice root',cnt);
	thePlayer.inv.AddAnItem('Arenaria',cnt);
	thePlayer.inv.AddAnItem('Balisse fruit',cnt);
	thePlayer.inv.AddAnItem('Beggartick blossoms',cnt);
	thePlayer.inv.AddAnItem('Berbercane fruit',cnt);
	thePlayer.inv.AddAnItem('Bison Grass',cnt);
	thePlayer.inv.AddAnItem('Bloodmoss',cnt);
	thePlayer.inv.AddAnItem('Blowbill',cnt);
	thePlayer.inv.AddAnItem('Bryonia',cnt);
	thePlayer.inv.AddAnItem('Buckthorn',cnt);
	thePlayer.inv.AddAnItem('Celandine',cnt);
	thePlayer.inv.AddAnItem('Cortinarius',cnt);
	thePlayer.inv.AddAnItem('Crows eye',cnt);
	thePlayer.inv.AddAnItem('Ergot seeds',cnt);
	thePlayer.inv.AddAnItem('Fools parsley leaves',cnt);
	thePlayer.inv.AddAnItem('Ginatia petals',cnt);
	thePlayer.inv.AddAnItem('Green mold',cnt);
	thePlayer.inv.AddAnItem('Han',cnt);
	thePlayer.inv.AddAnItem('Hellebore petals',cnt);
	thePlayer.inv.AddAnItem('Honeysuckle',cnt);
	thePlayer.inv.AddAnItem('Hop umbels',cnt);
	thePlayer.inv.AddAnItem('Hornwort',cnt);
	thePlayer.inv.AddAnItem('Longrube',cnt);
	thePlayer.inv.AddAnItem('Mandrake root',cnt);
	thePlayer.inv.AddAnItem('Mistletoe',cnt);
	thePlayer.inv.AddAnItem('Moleyarrow',cnt);
	thePlayer.inv.AddAnItem('Nostrix',cnt);
	thePlayer.inv.AddAnItem('Pigskin puffball',cnt);
	thePlayer.inv.AddAnItem('Pringrape',cnt);
	thePlayer.inv.AddAnItem('Ranogrin',cnt);
	thePlayer.inv.AddAnItem('Ribleaf',cnt);
	thePlayer.inv.AddAnItem('Sewant mushrooms',cnt);
	thePlayer.inv.AddAnItem('Verbena',cnt);
	thePlayer.inv.AddAnItem('White myrtle',cnt);
	thePlayer.inv.AddAnItem('Wolfsbane',cnt);

	if(!noMenu)
		theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addkeys()
{
	thePlayer.inv.AddAnItem('q103_tamara_shrine_key',1);
	thePlayer.inv.AddAnItem('q104_keira_mine_key',1);
	thePlayer.inv.AddAnItem('q107_guslar_cell_key',1);
	thePlayer.inv.AddAnItem('q201_yen_chamber_key',1);
	thePlayer.inv.AddAnItem('q202_hjalmar_cell_key',1);
	thePlayer.inv.AddAnItem('q205_key_to_burrow',1);
	thePlayer.inv.AddAnItem('q206_arnvalds_key',1);
	thePlayer.inv.AddAnItem('q206_arnvalds_chest_key',1);
	thePlayer.inv.AddAnItem('q208_yen_room_key',1);
	thePlayer.inv.AddAnItem('q301_crematory_key',1);
	thePlayer.inv.AddAnItem('q303_menges_skeleton_key',1);
	thePlayer.inv.AddAnItem('q303_vault_key',1);
	thePlayer.inv.AddAnItem('q305_key_midgets_house',1);
	thePlayer.inv.AddAnItem('q401_trial_ingredients_key',1);
	thePlayer.inv.AddAnItem('q503_lockbox_key',1);
	thePlayer.inv.AddAnItem('sq102_barn_door_side_key',1);
	thePlayer.inv.AddAnItem('sq102_lockbox_key',1);
	thePlayer.inv.AddAnItem('sq210_underwater_chest_key',1);
	thePlayer.inv.AddAnItem('sq210_underwater_gate2_key',1);
	thePlayer.inv.AddAnItem('sq210_underwater_gate1_key',1);
	thePlayer.inv.AddAnItem('sq302_philippa_key',1);
	thePlayer.inv.AddAnItem('sq303_pollys_key',1);
	thePlayer.inv.AddAnItem('sq304_warehouse_key',1);
	thePlayer.inv.AddAnItem('sq304_wrhs_indoor_key',1);
	thePlayer.inv.AddAnItem('sq310_zed_door_key',1);
	thePlayer.inv.AddAnItem('sq310_attic_key',1);
	thePlayer.inv.AddAnItem('sq310_triangle_key',1);
	thePlayer.inv.AddAnItem('sq314_prison_key',1);
	thePlayer.inv.AddAnItem('sq314_sigil_key',1);
	thePlayer.inv.AddAnItem('mq2003_treasure_chamber_key',1);
	thePlayer.inv.AddAnItem('mq3002_chest_key',1);
	thePlayer.inv.AddAnItem('mq2020_slave_cells_key',1);
	thePlayer.inv.AddAnItem('mh207_lighthouse_door_key',1);
	thePlayer.inv.AddAnItem('mh104_ekimma_house_key',1);
	thePlayer.inv.AddAnItem('mq2020_pirate_lord_house_door',1);
	thePlayer.inv.AddAnItem('mh303_succubus_house_key',1);
	thePlayer.inv.AddAnItem('mh304_morge_door_key',1);
	thePlayer.inv.AddAnItem('mh304_katakan_hideout_door_key',1);
	thePlayer.inv.AddAnItem('mh306_dao_manor_door_key',1);
	thePlayer.inv.AddAnItem('gp_prologue_key01',1);
	thePlayer.inv.AddAnItem('lw_prologue_royal_key01',1);
	thePlayer.inv.AddAnItem('lw_cb17_key',1);
	thePlayer.inv.AddAnItem('lw_cp_glinsk_cage_key_1',1);
	thePlayer.inv.AddAnItem('lw_tm12_refugee_camp_key',1);
	thePlayer.inv.AddAnItem('lw_gr13_slavers_key',1);
	thePlayer.inv.AddAnItem('lw_de6_scavenger_key',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addvaluables()
{
	thePlayer.inv.AddAnItem('Amber',1);
	thePlayer.inv.AddAnItem('Amethyst',1);
	thePlayer.inv.AddAnItem('Diamond ',1);
	thePlayer.inv.AddAnItem('Emerald',1);
	thePlayer.inv.AddAnItem('Pearl',1);
	thePlayer.inv.AddAnItem('Ruby',1);
	thePlayer.inv.AddAnItem('Sapphire',1);
	thePlayer.inv.AddAnItem('Black pearl',1);
	thePlayer.inv.AddAnItem('Candelabra',1);
	thePlayer.inv.AddAnItem('Casket',1);
	thePlayer.inv.AddAnItem('Golden casket',1);
	thePlayer.inv.AddAnItem('Gold candelabra',1);
	thePlayer.inv.AddAnItem('Gold diamond ring',1);
	thePlayer.inv.AddAnItem('Gold sapphire ring',1);
	thePlayer.inv.AddAnItem('Gold ring',1);
	thePlayer.inv.AddAnItem('Gold ruby ring',1);
	thePlayer.inv.AddAnItem('Silver amber necklace',1);
	thePlayer.inv.AddAnItem('Silver ruby necklace',1);
	thePlayer.inv.AddAnItem('Silver emerald necklace',1);
	thePlayer.inv.AddAnItem('Gold diamond necklace',1);
	thePlayer.inv.AddAnItem('Gold pearl necklace',1);
	thePlayer.inv.AddAnItem('Gold sapphire necklace',1);
	thePlayer.inv.AddAnItem('Silver amber ring',1);
	thePlayer.inv.AddAnItem('Silver candelabra',1);
	thePlayer.inv.AddAnItem('Silver casket',1);
	thePlayer.inv.AddAnItem('Silver emerald ring',1);
	thePlayer.inv.AddAnItem('Silver sapphire ring',1);

	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}

function additemfood()
{
	thePlayer.inv.AddAnItem( 'Beauclair White', 1 );
	thePlayer.inv.AddAnItem( 'Cherry Cordial', 1 );
	thePlayer.inv.AddAnItem( 'Dijkstra Dry', 1 );
	thePlayer.inv.AddAnItem( 'Erveluce', 1 );
	thePlayer.inv.AddAnItem( 'Est Est', 1 );
	thePlayer.inv.AddAnItem( 'Kaedwenian Stout', 1 );
	thePlayer.inv.AddAnItem( 'Mahakam Spirit', 1 );
	thePlayer.inv.AddAnItem( 'Mandrake cordial', 1 );
	thePlayer.inv.AddAnItem( 'Mettina Rose', 1 );
	thePlayer.inv.AddAnItem( 'Nilfgaardian Lemon', 1 );
	thePlayer.inv.AddAnItem( 'Local pepper vodka', 1 );
	thePlayer.inv.AddAnItem( 'Redanian Herbal', 1 );
	thePlayer.inv.AddAnItem( 'Redanian Lager', 1 );
	thePlayer.inv.AddAnItem( 'Rivian Kriek', 1 );
	thePlayer.inv.AddAnItem( 'Temerian Rye', 1 );
	thePlayer.inv.AddAnItem( 'Viziman Champion', 1 );
	thePlayer.inv.AddAnItem( 'Apple', 1 );
	thePlayer.inv.AddAnItem( 'Baked apple', 1 );
	thePlayer.inv.AddAnItem( 'Banana', 1 );
	thePlayer.inv.AddAnItem( 'Bell pepper', 1 );
	thePlayer.inv.AddAnItem( 'Blueberries', 1 );
	thePlayer.inv.AddAnItem( 'Bread', 1 );
	thePlayer.inv.AddAnItem( 'Burned bread', 1 );
	thePlayer.inv.AddAnItem( 'Bun', 1 );
	thePlayer.inv.AddAnItem( 'Burned bun', 1 );
	thePlayer.inv.AddAnItem( 'Candy', 1 );
	thePlayer.inv.AddAnItem( 'Cheese', 1 );
	thePlayer.inv.AddAnItem( 'Chicken', 1 );
	thePlayer.inv.AddAnItem( 'Chicken leg', 1 );
	thePlayer.inv.AddAnItem( 'Roasted chicken leg', 1 );
	thePlayer.inv.AddAnItem( 'Roasted chicken', 1 );
	thePlayer.inv.AddAnItem( 'Chicken sandwich', 1 );
	thePlayer.inv.AddAnItem( 'Grilled chicken sandwich', 1 );
	thePlayer.inv.AddAnItem( 'Cucumber', 1 );
	thePlayer.inv.AddAnItem( 'Dried fruit', 1 );
	thePlayer.inv.AddAnItem( 'Dried fruit and nuts', 1 );
	thePlayer.inv.AddAnItem( 'Egg', 1 );
	thePlayer.inv.AddAnItem( 'Fish', 1 );
	thePlayer.inv.AddAnItem( 'Fried fish', 1 );
	thePlayer.inv.AddAnItem( 'Gutted fish', 1 );
	thePlayer.inv.AddAnItem( 'Fondue', 1 );
	thePlayer.inv.AddAnItem( 'Grapes', 1 );
	thePlayer.inv.AddAnItem( 'Ham sandwich', 1 );
	thePlayer.inv.AddAnItem( 'Very good honey', 1 );
	thePlayer.inv.AddAnItem( 'Honeycomb', 1 );
	thePlayer.inv.AddAnItem( 'Fried meat', 1 );
	thePlayer.inv.AddAnItem( 'Raw meat', 1 );
	thePlayer.inv.AddAnItem( 'Cows milk', 1 );
	thePlayer.inv.AddAnItem( 'Goats milk', 1 );
	thePlayer.inv.AddAnItem( 'Mushroom', 1 );
	thePlayer.inv.AddAnItem( 'Mutton curry', 1 );
	thePlayer.inv.AddAnItem( 'Mutton leg', 1 );
	thePlayer.inv.AddAnItem( 'Olive', 1 );
	thePlayer.inv.AddAnItem( 'Onion', 1 );
	thePlayer.inv.AddAnItem( 'Pear', 1 );
	thePlayer.inv.AddAnItem( 'Pepper', 1 );
	thePlayer.inv.AddAnItem( 'Plum', 1 );
	thePlayer.inv.AddAnItem( 'Pork', 1 );
	thePlayer.inv.AddAnItem( 'Grilled pork', 1 );
	thePlayer.inv.AddAnItem( 'Potatoes', 1 );
	thePlayer.inv.AddAnItem( 'Baked potato', 1 );
	thePlayer.inv.AddAnItem( 'Chips', 1 );
	thePlayer.inv.AddAnItem( 'Raspberries', 1 );
	thePlayer.inv.AddAnItem( 'Raspberry juice', 1 );
	thePlayer.inv.AddAnItem( 'Strawberries', 1 );
	thePlayer.inv.AddAnItem( 'Toffee', 1 );
	thePlayer.inv.AddAnItem( 'Vinegar', 1 );
	thePlayer.inv.AddAnItem( 'Butter Bandalura', 1 );
	thePlayer.inv.AddAnItem( 'Apple juice', 1 );
	thePlayer.inv.AddAnItem( 'Bottled water', 1 );
}

function additemalchemy()
{
	
}


function additemcrafting()
{
	thePlayer.inv.AddAnItem('Cotton',1);
	thePlayer.inv.AddAnItem('Thread',1);
	thePlayer.inv.AddAnItem('String',1);
	thePlayer.inv.AddAnItem('Linen',1);
	thePlayer.inv.AddAnItem('Child doll',1);
	thePlayer.inv.AddAnItem('Bag of grain',1);
	thePlayer.inv.AddAnItem('Silk',1);
	thePlayer.inv.AddAnItem('Patchwork vest',1);
	thePlayer.inv.AddAnItem('Fiber',1);
	thePlayer.inv.AddAnItem('Note',1);
	thePlayer.inv.AddAnItem('Flowers',1);
	thePlayer.inv.AddAnItem('Voodoo doll',1);
	thePlayer.inv.AddAnItem('Twine',1);
	thePlayer.inv.AddAnItem('Jumping rope',1);
	thePlayer.inv.AddAnItem('Rope',1);
	thePlayer.inv.AddAnItem('Fishing net',1);
	thePlayer.inv.AddAnItem('Dye',1);
	thePlayer.inv.AddAnItem('Sap',1);
	thePlayer.inv.AddAnItem('Resin',1);
	
	thePlayer.inv.AddAnItem('Flute_junk',1);
	thePlayer.inv.AddAnItem('Mug',1);
	thePlayer.inv.AddAnItem('Ladle',1);
	thePlayer.inv.AddAnItem('Smoking pipe',1);
	thePlayer.inv.AddAnItem('Platter',1);
	thePlayer.inv.AddAnItem('Fishing rod',1);
	thePlayer.inv.AddAnItem('Casket',1);
	thePlayer.inv.AddAnItem('Drum',1);
	thePlayer.inv.AddAnItem('Haft',1);
	thePlayer.inv.AddAnItem('Broken paddle',1);
	thePlayer.inv.AddAnItem('Broken rakes',1);
	thePlayer.inv.AddAnItem('Wooden rung rope ladder',1);
	thePlayer.inv.AddAnItem('Hardened timber',1);
	thePlayer.inv.AddAnItem('Ashes',1);
	thePlayer.inv.AddAnItem('Valuable fossil',1);
	thePlayer.inv.AddAnItem('Feather',1);
	thePlayer.inv.AddAnItem('Fur square',1);
	thePlayer.inv.AddAnItem('Oil',1);
	thePlayer.inv.AddAnItem('Rotten meat',1);
	thePlayer.inv.AddAnItem('Wolf liver',1);

	thePlayer.inv.AddAnItem('Wax',1);
	thePlayer.inv.AddAnItem('Candle',1);
	thePlayer.inv.AddAnItem('Coal',1);
	thePlayer.inv.AddAnItem('Empty vial',1);
	thePlayer.inv.AddAnItem('Vial',1);
	thePlayer.inv.AddAnItem('Inkwell',1);
	thePlayer.inv.AddAnItem('Perfume',1);
	thePlayer.inv.AddAnItem('Jar',1);
	thePlayer.inv.AddAnItem('Flask',1);
	thePlayer.inv.AddAnItem('Bottle',1);
	thePlayer.inv.AddAnItem('Jug',1);
	thePlayer.inv.AddAnItem('Fisstech',1);
	thePlayer.inv.AddAnItem('Glamarye',1);
	thePlayer.inv.AddAnItem('Shell',1);
	thePlayer.inv.AddAnItem('Seashell',1);
}

function additemleather()
{
	thePlayer.inv.AddAnItem('Leather straps',1);
	thePlayer.inv.AddAnItem('Worn leather pelt',1);
	thePlayer.inv.AddAnItem('Scoiatael trophies',1);
	thePlayer.inv.AddAnItem('Rabbit pelt',1);
	thePlayer.inv.AddAnItem('Fox pelt',1);
	thePlayer.inv.AddAnItem('Leather squares',1);
	thePlayer.inv.AddAnItem('Nilfgaardian special forces insignia',1);
	thePlayer.inv.AddAnItem('Temerian special forces insignia',1);
	thePlayer.inv.AddAnItem('Redanian special forces insignia',1);
	thePlayer.inv.AddAnItem('Old goat skin',1);
	thePlayer.inv.AddAnItem('Old sheep skin',1);
	thePlayer.inv.AddAnItem('Parchment',1);
	thePlayer.inv.AddAnItem('Book',1);
	thePlayer.inv.AddAnItem('Leather',1);
	thePlayer.inv.AddAnItem('Pig hide',1);
	thePlayer.inv.AddAnItem('Goat hide',1);
	thePlayer.inv.AddAnItem('Deer hide',1);
	thePlayer.inv.AddAnItem('Wolf pelt',1);
	thePlayer.inv.AddAnItem('Old bear skin',1);
	thePlayer.inv.AddAnItem('Cow hide',1);
	thePlayer.inv.AddAnItem('White wolf pelt',1);
	thePlayer.inv.AddAnItem('Horse hide',1);
	thePlayer.inv.AddAnItem('Hardened leather',1);
	thePlayer.inv.AddAnItem('Bear pelt',1);
	thePlayer.inv.AddAnItem('White bear pelt',1);
	thePlayer.inv.AddAnItem('Chitin scale',1);
	thePlayer.inv.AddAnItem('Endriag chitin plates',1);
	thePlayer.inv.AddAnItem('Dragon scales',1);
	thePlayer.inv.AddAnItem('Draconide leather',1);
}

function additemmetals()
{
	thePlayer.inv.AddAnItem('Lead ore',1);
	thePlayer.inv.AddAnItem('Melitele figurine',1);
	thePlayer.inv.AddAnItem('Iron ore',1);
	thePlayer.inv.AddAnItem('Bandalur butter knife',1);
	thePlayer.inv.AddAnItem('Goblet',1);
	thePlayer.inv.AddAnItem('Nails',1);
	thePlayer.inv.AddAnItem('Old rusty breadknife',1);
	thePlayer.inv.AddAnItem('Salt pepper shaker',1);
	thePlayer.inv.AddAnItem('Razor',1);
	thePlayer.inv.AddAnItem('Wire',1);
	thePlayer.inv.AddAnItem('Wire rope',1);
	thePlayer.inv.AddAnItem('Iron ingot',1);
	thePlayer.inv.AddAnItem('Candelabra',1);
	thePlayer.inv.AddAnItem('Lute',1);
	thePlayer.inv.AddAnItem('Steel ingot',1);
	thePlayer.inv.AddAnItem('Axe head',1);
	thePlayer.inv.AddAnItem('Pickaxe head',1);
	thePlayer.inv.AddAnItem('Rusty hammer head',1);
	thePlayer.inv.AddAnItem('Blunt axe',1);
	thePlayer.inv.AddAnItem('Blunt pickaxe',1);
	thePlayer.inv.AddAnItem('Chain',1);
	thePlayer.inv.AddAnItem('Steel plate',1);
	thePlayer.inv.AddAnItem('Dark iron ore',1);
	thePlayer.inv.AddAnItem('Dark iron ingot',1);
	thePlayer.inv.AddAnItem('Dark steel ingot',1);
	thePlayer.inv.AddAnItem('Dark steel plate',1);
	thePlayer.inv.AddAnItem('Meteorite ore',1);
	thePlayer.inv.AddAnItem('Meteorite ingot',1);
	
	thePlayer.inv.AddAnItem('Meteorite silver ingot',1);
	thePlayer.inv.AddAnItem('Meteorite silver plate',1);
	thePlayer.inv.AddAnItem('Glowing ore',1);
	thePlayer.inv.AddAnItem('Dwimeritium shackles',1);
	thePlayer.inv.AddAnItem('Glowing ingot',1);
	thePlayer.inv.AddAnItem('Dwimeritium chains',1);
	thePlayer.inv.AddAnItem('Dwimeryte ore',1);
	thePlayer.inv.AddAnItem('Dwimeryte ingot',1);
	thePlayer.inv.AddAnItem('Dwimeryte plate',1);
}

function additemrunesupgrades()
{
	
	
	
	
	thePlayer.inv.AddAnItem('Rune stribog lesser',1);
	thePlayer.inv.AddAnItem('Rune stribog',1);
	thePlayer.inv.AddAnItem('Rune stribog greater',1);
	thePlayer.inv.AddAnItem('Rune dazhbog lesser',1);
	thePlayer.inv.AddAnItem('Rune dazhbog',1);
	thePlayer.inv.AddAnItem('Rune dazhbog greater',1);
	thePlayer.inv.AddAnItem('Rune devana lesser',1);
	thePlayer.inv.AddAnItem('Rune devana',1);
	thePlayer.inv.AddAnItem('Rune devana greater',1);
	thePlayer.inv.AddAnItem('Rune zoria lesser',1);
	thePlayer.inv.AddAnItem('Rune zoria',1);
	thePlayer.inv.AddAnItem('Rune zoria greater',1);
	thePlayer.inv.AddAnItem('Rune morana lesser',1);
	thePlayer.inv.AddAnItem('Rune morana',1);
	thePlayer.inv.AddAnItem('Rune morana greater',1);
	thePlayer.inv.AddAnItem('Rune triglav lesser',1);
	thePlayer.inv.AddAnItem('Rune triglav',1);
	thePlayer.inv.AddAnItem('Rune triglav greater',1);
	thePlayer.inv.AddAnItem('Rune svarog lesser',1);
	thePlayer.inv.AddAnItem('Rune svarog',1);
	thePlayer.inv.AddAnItem('Rune svarog greater',1);
	thePlayer.inv.AddAnItem('Rune veles lesser',1);
	thePlayer.inv.AddAnItem('Rune veles',1);
	thePlayer.inv.AddAnItem('Rune veles greater',1);
	thePlayer.inv.AddAnItem('Rune perun lesser',1);
	thePlayer.inv.AddAnItem('Rune perun',1);
	thePlayer.inv.AddAnItem('Rune perun greater',1);
	thePlayer.inv.AddAnItem('Rune elemental lesser',1);
	thePlayer.inv.AddAnItem('Rune elemental',1);
	thePlayer.inv.AddAnItem('Rune elemental greater',1);
	
}

function additemmonstrous()
{
	thePlayer.inv.AddAnItem('Monstrous hair',1);
	thePlayer.inv.AddAnItem('Lamia lock of hair',1);
	thePlayer.inv.AddAnItem('Monstrous brain',1);
	thePlayer.inv.AddAnItem('Drowner brain',1);
	thePlayer.inv.AddAnItem('Monstrous blood',1);
	thePlayer.inv.AddAnItem('Ghoul blood',1);
	thePlayer.inv.AddAnItem('Nekker blood',1);
	thePlayer.inv.AddAnItem('Rotfiend blood',1);
	thePlayer.inv.AddAnItem('Leshy resin',1);
	thePlayer.inv.AddAnItem('Monstrous bone',1);
	thePlayer.inv.AddAnItem('Alghoul bone marrow',1);
	thePlayer.inv.AddAnItem('Monstrous claw',1);
	thePlayer.inv.AddAnItem('Alghoul claw',1);
	thePlayer.inv.AddAnItem('Harpy talon',1);
	thePlayer.inv.AddAnItem('Monstrous dust',1);
	thePlayer.inv.AddAnItem('Specter dust',1);
	thePlayer.inv.AddAnItem('Gargoyle Dust',1);
	thePlayer.inv.AddAnItem('Monstrous heart',1);
	thePlayer.inv.AddAnItem('Nekker heart',1);
	thePlayer.inv.AddAnItem('Gargoyle heart',1);
	thePlayer.inv.AddAnItem('Golem heart',1);
	thePlayer.inv.AddAnItem('Monstrous feather',1);
	thePlayer.inv.AddAnItem('Harpy feathers',1);
	thePlayer.inv.AddAnItem('Gryphon feathers',1);
	thePlayer.inv.AddAnItem('Monstrous egg',1);
	thePlayer.inv.AddAnItem('Cockatrice egg',1);
	thePlayer.inv.AddAnItem('Endriag embryo',1);
	thePlayer.inv.AddAnItem('Gryphon egg',1);
	thePlayer.inv.AddAnItem('Wyvern egg',1);
	thePlayer.inv.AddAnItem('Monstrous essence',1);
	thePlayer.inv.AddAnItem('Noonwraith light essence',1);
	thePlayer.inv.AddAnItem('Nightwraith dark essence',1);
	thePlayer.inv.AddAnItem('Water essence',1);
	thePlayer.inv.AddAnItem('Crystalized essence',1);
	thePlayer.inv.AddAnItem('Elemental essence',1);
	thePlayer.inv.AddAnItem('Monstrous eye',1);
	thePlayer.inv.AddAnItem('Arachas eyes',1);
	thePlayer.inv.AddAnItem('Cyclops eye',1);
	thePlayer.inv.AddAnItem('Fiend eye',1);
	thePlayer.inv.AddAnItem('Monstrous liver',1);
	thePlayer.inv.AddAnItem('Monstrous hide',1);
	thePlayer.inv.AddAnItem('Berserker pelt',1);
	thePlayer.inv.AddAnItem('Necrophage skin',1);
	thePlayer.inv.AddAnItem('Troll skin',1);
	thePlayer.inv.AddAnItem('Werewolf pelt',1);
	thePlayer.inv.AddAnItem('Czart hide',1);
	thePlayer.inv.AddAnItem('Werewolf saliva',1);
	thePlayer.inv.AddAnItem('Vampire saliva',1);
	thePlayer.inv.AddAnItem('Monstrous plate',1);
	thePlayer.inv.AddAnItem('Basilisk hide',1);
	thePlayer.inv.AddAnItem('Wyvern plate',1);
	thePlayer.inv.AddAnItem('Forktail hide',1);
	thePlayer.inv.AddAnItem('Monstrous saliva',1);
	thePlayer.inv.AddAnItem('Monstrous tooth',1);
	thePlayer.inv.AddAnItem('Hag teeth',1);
	thePlayer.inv.AddAnItem('Vampire fang',1);
	thePlayer.inv.AddAnItem('Monstrous tongue',1);
	thePlayer.inv.AddAnItem('Drowned dead tongue',1);
	thePlayer.inv.AddAnItem('Venom extract',1);
	thePlayer.inv.AddAnItem('Arachas venom',1);
	thePlayer.inv.AddAnItem('Basilisk venom',1);
	thePlayer.inv.AddAnItem('Siren vocal cords',1);
}

function additemsprecious()
{
	thePlayer.inv.AddAnItem('Amber dust',1);
	thePlayer.inv.AddAnItem('Amber',1);
	thePlayer.inv.AddAnItem('Amber fossil',1);
	thePlayer.inv.AddAnItem('Amber flawless',1);
	thePlayer.inv.AddAnItem('Amethyst dust',1);
	thePlayer.inv.AddAnItem('Amethyst',1);
	thePlayer.inv.AddAnItem('Amethyst flawless',1);
	thePlayer.inv.AddAnItem('Black pearl dust',1);
	thePlayer.inv.AddAnItem('Black pearl',1);
	thePlayer.inv.AddAnItem('Powdered pearl',1);
	thePlayer.inv.AddAnItem('Pearl',1);
	thePlayer.inv.AddAnItem('Diamond dust',1);
	thePlayer.inv.AddAnItem('Diamond',1);
	thePlayer.inv.AddAnItem('Diamond flawless',1);
	thePlayer.inv.AddAnItem('Emerald dust',1);
	thePlayer.inv.AddAnItem('Emerald',1);
	thePlayer.inv.AddAnItem('Emerald flawless',1);
	thePlayer.inv.AddAnItem('Ruby dust',1);
	thePlayer.inv.AddAnItem('Ruby',1);
	thePlayer.inv.AddAnItem('Ruby flawless',1);
	thePlayer.inv.AddAnItem('Sapphire dust',1);
	thePlayer.inv.AddAnItem('Sapphire',1);
	thePlayer.inv.AddAnItem('Sapphire flawless',1);
	thePlayer.inv.AddAnItem('Gold mineral',1);
	thePlayer.inv.AddAnItem('Gold ring',1);
	thePlayer.inv.AddAnItem('Gold ruby ring',1);
	thePlayer.inv.AddAnItem('Gold pearl necklace',1);
	thePlayer.inv.AddAnItem('Gold sapphire ring',1);
	thePlayer.inv.AddAnItem('Gold sapphire necklace',1);
	thePlayer.inv.AddAnItem('Gold diamond ring',1);
	thePlayer.inv.AddAnItem('Gold diamond necklace',1);
	thePlayer.inv.AddAnItem('Gold ore',1);
	thePlayer.inv.AddAnItem('Gold candelabra',1);
	thePlayer.inv.AddAnItem('Golden mug',1);
	thePlayer.inv.AddAnItem('Golden platter',1);
	thePlayer.inv.AddAnItem('Golden casket',1);
	thePlayer.inv.AddAnItem('Silver mineral',1);
	thePlayer.inv.AddAnItem('Silver pantaloons',1);
	thePlayer.inv.AddAnItem('Silver amber ring',1);
	thePlayer.inv.AddAnItem('Silver sapphire ring',1);
	thePlayer.inv.AddAnItem('Silver emerald ring',1);
	thePlayer.inv.AddAnItem('Silver emerald necklace',1);
	thePlayer.inv.AddAnItem('Silver amber necklace',1);
	thePlayer.inv.AddAnItem('Silver ruby necklace',1);
	thePlayer.inv.AddAnItem('Silver ore',1);
	thePlayer.inv.AddAnItem('Silverware',1);
	thePlayer.inv.AddAnItem('Silver teapot',1);
	thePlayer.inv.AddAnItem('Silver mug',1);
	thePlayer.inv.AddAnItem('Silver platter',1);
	thePlayer.inv.AddAnItem('Silver casket',1);
	thePlayer.inv.AddAnItem('Silver ingot',1);
	thePlayer.inv.AddAnItem('Pure silver',1);
	thePlayer.inv.AddAnItem('Silver candelabra',1);
	thePlayer.inv.AddAnItem('Ornate silver sword replica',1);
	thePlayer.inv.AddAnItem('Silver plate',1);
	thePlayer.inv.AddAnItem('Ornate silver shield replica',1);
}


exec function addjunk()
{
	thePlayer.inv.AddAnItem('Ashes',1);
	
	thePlayer.inv.AddAnItem('Axe head',1);
	thePlayer.inv.AddAnItem('Bag of grain',1);
	thePlayer.inv.AddAnItem('Bandalur butter knife',1);
	thePlayer.inv.AddAnItem('Blunt axe',1);
	thePlayer.inv.AddAnItem('Blunt pickaxe',1);
	thePlayer.inv.AddAnItem('Broken paddle',1);
	thePlayer.inv.AddAnItem('Broken rakes',1);
	thePlayer.inv.AddAnItem('Candle',1);
	thePlayer.inv.AddAnItem('Chain',1);
	thePlayer.inv.AddAnItem('Child doll',1);
	thePlayer.inv.AddAnItem('Drum',1);
	thePlayer.inv.AddAnItem('Empty bottle',1);
	thePlayer.inv.AddAnItem('Empty vial',1);
	thePlayer.inv.AddAnItem('Fishing net',1);
	thePlayer.inv.AddAnItem('Fishing rod',1);
	thePlayer.inv.AddAnItem('Fisstech',1);
	thePlayer.inv.AddAnItem('Flowers',1);
	thePlayer.inv.AddAnItem('Flute',1);
	thePlayer.inv.AddAnItem('Glamarye',1);
	thePlayer.inv.AddAnItem('Goblet',1);
	thePlayer.inv.AddAnItem('Golden mug',1);
	thePlayer.inv.AddAnItem('Golden platter',1);
	thePlayer.inv.AddAnItem('Inkwell',1);
	thePlayer.inv.AddAnItem('Jumping rope',1);
	thePlayer.inv.AddAnItem('Ladle',1);
	thePlayer.inv.AddAnItem('Lead',1);
	thePlayer.inv.AddAnItem('Lute',1);
	thePlayer.inv.AddAnItem('Melitele figurine',1);
	thePlayer.inv.AddAnItem('Mug',1);
	thePlayer.inv.AddAnItem('Nails',1);
	thePlayer.inv.AddAnItem('Nilfgaardian special forces insignia',1);
	thePlayer.inv.AddAnItem('Old bear skin',1);
	thePlayer.inv.AddAnItem('Old goat skin',1);
	thePlayer.inv.AddAnItem('Old rusty breadknife',1);
	thePlayer.inv.AddAnItem('Old sheep skin',1);
	thePlayer.inv.AddAnItem('Ornate silver shield replica',1);
	thePlayer.inv.AddAnItem('Ornate silver sword replica',1);
	thePlayer.inv.AddAnItem('Parchment',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addjunk2()
{
	thePlayer.inv.AddAnItem('Patchwork vest',1);
	thePlayer.inv.AddAnItem('Perfume',1);
	thePlayer.inv.AddAnItem('Philosophers stone',1);
	thePlayer.inv.AddAnItem('Pickaxe head',1);
	thePlayer.inv.AddAnItem('Razor',1);
	thePlayer.inv.AddAnItem('Rope',1);
	thePlayer.inv.AddAnItem('Rusty hammer head',1);
	thePlayer.inv.AddAnItem('Seashell',1);
	thePlayer.inv.AddAnItem('Scoiatael trophies',1);
	thePlayer.inv.AddAnItem('Shell',1);
	thePlayer.inv.AddAnItem('Silver mug',1);
	thePlayer.inv.AddAnItem('Silver pantaloons',1);
	thePlayer.inv.AddAnItem('Silver plate',1);
	thePlayer.inv.AddAnItem('Silver teapot',1);
	thePlayer.inv.AddAnItem('Silverware',1);
	thePlayer.inv.AddAnItem('Skull',1);
	thePlayer.inv.AddAnItem('Smoking pipe',1);
	thePlayer.inv.AddAnItem('Temerian special forces insignia',1);
	thePlayer.inv.AddAnItem('Valuable fossil',1);
	
	thePlayer.inv.AddAnItem('Vial',1);
	thePlayer.inv.AddAnItem('Voodoo doll',1);
	thePlayer.inv.AddAnItem('Wire',1);
	thePlayer.inv.AddAnItem('Wire rope',1);
	thePlayer.inv.AddAnItem('Wooden rung rope ladder',1);
	thePlayer.inv.AddAnItem('Worn leather pelt',1);
	thePlayer.inv.AddAnItem('lw_001_monstrous_remains',1);
	thePlayer.inv.AddAnItem('q305_painting_of_hemmelfart',1);
	thePlayer.inv.AddAnItem('mq3016_bards_belongings',1);
	thePlayer.inv.AddAnItem('sq202_tableware',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}




exec function addquestitems1()
{
	thePlayer.inv.AddAnItem('q001_crystal_skull',1);
	thePlayer.inv.AddAnItem('q101_hendrik_trapdoor_key',1);
	thePlayer.inv.AddAnItem('q202_navigator_horn',1);
	thePlayer.inv.AddAnItem('q103_medallion',1);
	thePlayer.inv.AddAnItem('q103_botch_blood',1);
	thePlayer.inv.AddAnItem('q103_wooden_doll',1);
	thePlayer.inv.AddAnItem('q103_talisman',1);
	thePlayer.inv.AddAnItem('q103_spinning_topc',1);
	thePlayer.inv.AddAnItem('q103_incense',1);
	thePlayer.inv.AddAnItem('q104_oillamp',1);
	thePlayer.inv.AddAnItem('q105_johnnys_dollc',1);
	thePlayer.inv.AddAnItem('q105_ravens_feather',1);
	thePlayer.inv.AddAnItem('q105_ritual_dagger',1);
	thePlayer.inv.AddAnItem('q105_soltis_ear',1);
	thePlayer.inv.AddAnItem('q105_witch_bones',1);
	thePlayer.inv.AddAnItem('q106_magic_communicator',1);
	thePlayer.inv.AddAnItem('q106_anabelle_remains',1);
	thePlayer.inv.AddAnItem('q106_anabelle_vial',1);	
	thePlayer.inv.AddAnItem('q107_doll1',1);
	thePlayer.inv.AddAnItem('q107_doll2',1);
	thePlayer.inv.AddAnItem('q107_doll3',1);
	thePlayer.inv.AddAnItem('q107_doll_anna',1);
	thePlayer.inv.AddAnItem('q107_doll5',1);
	thePlayer.inv.AddAnItem('q107_doll6',1);
	thePlayer.inv.AddAnItem('q108_necklet',1);
	thePlayer.inv.AddAnItem('q111_ergot_beer',1);
	thePlayer.inv.AddAnItem('q111_fugas_top_key',1);
	thePlayer.inv.AddAnItem('q111_falkas_coin',1);
	thePlayer.inv.AddAnItem('q111_imlerith_acorn',1);
	thePlayer.inv.AddAnItem('q201_mead',1);
	thePlayer.inv.AddAnItem('q201_pine_cone',1);
	thePlayer.inv.AddAnItem('q201_skull',1);
	thePlayer.inv.AddAnItem('q202_shackles',1);
	thePlayer.inv.AddAnItem('q202_sail',1);
	thePlayer.inv.AddAnItem('q202_nails',1);
	thePlayer.inv.AddAnItem('q203_broken_eyeofloki',1);
	thePlayer.inv.AddAnItem('q203_chest_key',1);
	thePlayer.inv.AddAnItem('q203_broksvard',1);
	thePlayer.inv.AddAnItem('q205_mirt_green',1);
	thePlayer.inv.AddAnItem('q205_mirt_yellow',1);
	thePlayer.inv.AddAnItem('q205_hvitr_universal_key',1);
	thePlayer.inv.AddAnItem('q205_gaelnos_rootc',1);
	thePlayer.inv.AddAnItem('q205_swallow_green',1);
	thePlayer.inv.AddAnItem('q205_swallow_yellow',1);
	thePlayer.inv.AddAnItem('q206_wine_sample',1);
	thePlayer.inv.AddAnItem('q206_herb_mixture',1);
	thePlayer.inv.AddAnItem('q208_heroesmead',1);
	thePlayer.inv.AddAnItem('q210_avallach_notes_01',1);
	thePlayer.inv.AddAnItem('q210_avallach_notes_02',1);
	thePlayer.inv.AddAnItem('q210_avallach_lover_notes',1);
	thePlayer.inv.AddAnItem('q210_solarstein',1);
	thePlayer.inv.AddAnItem('q301_rose_remembrance',1);
	thePlayer.inv.AddAnItem('q301_triss_parcel',1);
	thePlayer.inv.AddAnItem('q301_magic_rat_incense',1);
	thePlayer.inv.AddAnItem('q301_haunted_doll',1);
	thePlayer.inv.AddAnItem('q301_burdock',1);
	thePlayer.inv.AddAnItem('q302_estate_key',1);
	thePlayer.inv.AddAnItem('q302_ring_door_key',1);
	thePlayer.inv.AddAnItem('q303_bomb_fragment',1);
	thePlayer.inv.AddAnItem('q303_bomb_cap',1);
	thePlayer.inv.AddAnItem('q303_wine_bottle',1);
	thePlayer.inv.AddAnItem('q305_dandelion_signet',1);
	thePlayer.inv.AddAnItem('q309_key_piece1',1);
	thePlayer.inv.AddAnItem('q309_key_piece2',1);
	thePlayer.inv.AddAnItem('q309_key_piece3',1);
	thePlayer.inv.AddAnItem('q309_three_keys_combined r',1);
	thePlayer.inv.AddAnItem('q310_wine',1);
	thePlayer.inv.AddAnItem('q310_lever',1);
	thePlayer.inv.AddAnItem('q310_sewer_door_key',1);
	thePlayer.inv.AddAnItem('q310_cell_key',1);
	thePlayer.inv.AddAnItem('q310_backdoor_keyc',1);
	thePlayer.inv.AddAnItem('q401_forktail_brain',1);
	thePlayer.inv.AddAnItem('q401_triss_earring',1);
	thePlayer.inv.AddAnItem('q401_sausages',1);
	thePlayer.inv.AddAnItem('q401_trial_key_ingredient_a',1);
	thePlayer.inv.AddAnItem('q401_trial_key_ingredient_b',1);
	thePlayer.inv.AddAnItem('q401_trial_key_ingredient_c',1);
	thePlayer.inv.AddAnItem('q401_bucket_and_rag',1);
	thePlayer.inv.AddAnItem('yennefers_omelette',1);
	thePlayer.inv.AddAnItem('yennefers_omelette_fantasie',1);
	thePlayer.inv.AddAnItem('scrambled_eggs',1);
	thePlayer.inv.AddAnItem('q401_disgusting_meal',1);
	thePlayer.inv.AddAnItem('q504_fish',1);
	thePlayer.inv.AddAnItem('q505_gems',1);
	thePlayer.inv.AddAnItem('sq101_safe_goods',1);
	thePlayer.inv.AddAnItem('sq104_key',1);
	thePlayer.inv.AddAnItem('sq107_vault_key',1);
	thePlayer.inv.AddAnItem('sq108_smith_toolsc',1);
	thePlayer.inv.AddAnItem('sq108_acid_gland',1);
	thePlayer.inv.AddAnItem('sq201_werewolf_meat',1);
	thePlayer.inv.AddAnItem('sq201_rotten_meatc',1);
	thePlayer.inv.AddAnItem('sq201_cursed_jewel',1);
	thePlayer.inv.AddAnItem('sq201_padlock_keyc',1);
	thePlayer.inv.AddAnItem('sq201_chamber_keyc',1);
	thePlayer.inv.AddAnItem('sq202_half_seal',1);
	thePlayer.inv.AddAnItem('sq204_wolf_heart',1);
	thePlayer.inv.AddAnItem('sq204_leshy_talisman',1);
	thePlayer.inv.AddAnItem('sq205_fernflower_petal',1);
	thePlayer.inv.AddAnItem('sq205_preserved_mash',1);
	thePlayer.inv.AddAnItem('sq205_moonshine_spirit',1);
	thePlayer.inv.AddAnItem('sq206_sleipnir_formula',1);
	thePlayer.inv.AddAnItem('sq206_sleipnir_ingredient',1);
	thePlayer.inv.AddAnItem('sq206_sleipnir_potion',1);
	thePlayer.inv.AddAnItem('sq207_portal_stone_red',1);
	thePlayer.inv.AddAnItem('sq207_portal_stone_green',1);
	thePlayer.inv.AddAnItem('sq207_portal_stone_blue',1);
	thePlayer.inv.AddAnItem('sq208_portait_otkell',1);
	thePlayer.inv.AddAnItem('sq208_portait_tyrc',1);
	thePlayer.inv.AddAnItem('sq208_portait_brodrr',1);
	thePlayer.inv.AddAnItem('sq208_portait_saemingr',1);
	thePlayer.inv.AddAnItem('sq208_herbs',1);
	thePlayer.inv.AddAnItem('sq208_raghnaroog',1);
	thePlayer.inv.AddAnItem('sq210_conch',1);
	thePlayer.inv.AddAnItem('sq210_golems_heart',1);
	thePlayer.inv.AddAnItem('sq210_golems_charged_heartg',1);
	thePlayer.inv.AddAnItem('sq210_burnt_heartc',1);
	thePlayer.inv.AddAnItem('sq210_gold_token',1);
	thePlayer.inv.AddAnItem('sq301_triss_mask_for_shop',1);
	thePlayer.inv.AddAnItem('sq302_crystal',1);
	thePlayer.inv.AddAnItem('sq302_generator_2',1);
	thePlayer.inv.AddAnItem('sq302_generator_3',1);
	thePlayer.inv.AddAnItem('sq303_lesser_white_honey',1);
	thePlayer.inv.AddAnItem('sq304_smithing_mtrls',1);
	thePlayer.inv.AddAnItem('sq304_chemicals',1);
	thePlayer.inv.AddAnItem('sq304_monster_trophy',1);
	thePlayer.inv.AddAnItem('sq304_aluminium',1);
	thePlayer.inv.AddAnItem('sq304_ferrum_cadmiae',1);
	thePlayer.inv.AddAnItem('sq304_thermite',1);
	thePlayer.inv.AddAnItem('sq402_ingredient',1);
	thePlayer.inv.AddAnItem('sq402_florence_flask_with_water',1);
	thePlayer.inv.AddAnItem('sq402_florence_flask',1);
	thePlayer.inv.AddAnItem('sq302_eyes',1);
	thePlayer.inv.AddAnItem('sq302_agates',1);
	thePlayer.inv.AddAnItem('sq303_blunt_sword',1);
	thePlayer.inv.AddAnItem('sq305_conduct',1);
	thePlayer.inv.AddAnItem('sq307_cattrap',1);
	thePlayer.inv.AddAnItem('sq307_cat_accessories',1);
	thePlayer.inv.AddAnItem('sq307_flower',1);
	thePlayer.inv.AddAnItem('sq401_old_sword',1);
	thePlayer.inv.AddAnItem('sq308_martin_maskask',1);
	thePlayer.inv.AddAnItem('sq310_card_1',1);
	thePlayer.inv.AddAnItem('sq310_card_2',1);
	thePlayer.inv.AddAnItem('sq310_card_3',1);
	thePlayer.inv.AddAnItem('sq309_iorweth_arrow',1);
	thePlayer.inv.AddAnItem('sq314_cure',1);
	thePlayer.inv.AddAnItem('sq314_cure_recipe',1);
	thePlayer.inv.AddAnItem('sq314_var_rechte_journal',1);
	thePlayer.inv.AddAnItem('mq0002_box',1);
	thePlayer.inv.AddAnItem('mq0003_ornate_bracelet',1);
	thePlayer.inv.AddAnItem('mq0004_thalers_monocle',1);
	thePlayer.inv.AddAnItem('mq0004_frying_pan',1);
	thePlayer.inv.AddAnItem('mq1001_dog_collar',1);
	thePlayer.inv.AddAnItem('mq1001_locker_key',1);
	thePlayer.inv.AddAnItem('mq1002_artifact_1',1);
	thePlayer.inv.AddAnItem('mq1002_artifact_2',1);
	thePlayer.inv.AddAnItem('mq1002_artifact_3',1);
	thePlayer.inv.AddAnItem('mq1006_elf_head',1);
	thePlayer.inv.AddAnItem('mq1022_paint',1);
	thePlayer.inv.AddAnItem('mq1010_ring',1);
	thePlayer.inv.AddAnItem('mq1028_muggs_papers',1);
	thePlayer.inv.AddAnItem('mq1050_dragon_root',1);
	thePlayer.inv.AddAnItem('mq1053_skull',1);
	thePlayer.inv.AddAnItem('mq1056_chain_cutter',1);
	thePlayer.inv.AddAnItem('mq2001_kuilu',1);
	thePlayer.inv.AddAnItem('mq2001_horn',1);
	thePlayer.inv.AddAnItem('mq2002_sword',1);
	thePlayer.inv.AddAnItem('mq2006_key_1',1);
	thePlayer.inv.AddAnItem('mq2006_key_2',1);
	thePlayer.inv.AddAnItem('mq2030_shawl',1);
	thePlayer.inv.AddAnItem('mq2033_tp_stone',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}

exec function fff(x : float)
{
	theGame.GetFocusModeController().SetFocusAreaIntensity(x);
}




exec function addquestitems2()
{
	thePlayer.inv.AddAnItem('mq2037_drakkar_chest_key',1);
	thePlayer.inv.AddAnItem('mq2038_headsman_sword',1);
	thePlayer.inv.AddAnItem('mq2048_stone_medalion',1);
	thePlayer.inv.AddAnItem('mq2048_ships_logbook',1);
	thePlayer.inv.AddAnItem('mq1019_oil',1);
	thePlayer.inv.AddAnItem('mq3012_noble_statuette',1);
	thePlayer.inv.AddAnItem('mq3012_soldier_statuette',1);
	thePlayer.inv.AddAnItem('mq3031_mother_of_pearl',1);
	thePlayer.inv.AddAnItem('mq3032_basilisk_leather',1);
	thePlayer.inv.AddAnItem('mq3035_philppa_ring',1);
	thePlayer.inv.AddAnItem('mq3039_loot_chest_key',1);
	thePlayer.inv.AddAnItem('mq1051_spyglass',1);
	thePlayer.inv.AddAnItem('mq1052_monster_trophy',1);
	thePlayer.inv.AddAnItem('mq3032_leather_boots',1);
	thePlayer.inv.AddAnItem('mq1052_bandit_key',1);
	thePlayer.inv.AddAnItem('sq312_medicine',1);
	thePlayer.inv.AddAnItem('mq2041_dexterity_token',1);
	thePlayer.inv.AddAnItem('mq2043_conviction_token',1);
	thePlayer.inv.AddAnItem('mq4003_siren_ring',1);
	thePlayer.inv.AddAnItem('mq4003_husband_ring',1);
	thePlayer.inv.AddAnItem('mq4004_boy_remains',1);
	thePlayer.inv.AddAnItem('mh103_killers_knife',1);
	thePlayer.inv.AddAnItem('mh106_hags_skulls',1);
	thePlayer.inv.AddAnItem('mh107_fiend_dung',1);
	thePlayer.inv.AddAnItem('mh203_water_hag_trophy',1);
	thePlayer.inv.AddAnItem('mh307_minion_trophy',1);
	thePlayer.inv.AddAnItem('mh307_minion_lair_key',1);
	thePlayer.inv.AddAnItem('mh308_dagger',1);
	thePlayer.inv.AddAnItem('troll_bane_gloves',1);
	thePlayer.inv.AddAnItem('q001_letter_from_yenn',1);
	thePlayer.inv.AddAnItem('q001_academic_book',1);
	thePlayer.inv.AddAnItem('q002_yenn_notes_about_ciri',1);
	thePlayer.inv.AddAnItem('q101_hendrik_notes',1);
	thePlayer.inv.AddAnItem('q101_candle_instruction',1);
	thePlayer.inv.AddAnItem('q103_tamara_prayer',1);
	thePlayer.inv.AddAnItem('q103_letter_from_graden_1',1);
	thePlayer.inv.AddAnItem('q103_letter_from_graden_2',1);
	thePlayer.inv.AddAnItem('q103_nilfgaardian_demand',1);
	thePlayer.inv.AddAnItem('q103_about_eve',1);
	thePlayer.inv.AddAnItem('q103_love_letter',1);
	thePlayer.inv.AddAnItem('q103_curse_book',1);
	thePlayer.inv.AddAnItem('q103_safe_conduct',1);
	thePlayer.inv.AddAnItem('q103_baron_dagger',1);
	thePlayer.inv.AddAnItem('q104_cure_recipe',1);
	thePlayer.inv.AddAnItem('q104_eye_ink_recipe',1);
	thePlayer.inv.AddAnItem('q104_aleksander_letter',1);
	thePlayer.inv.AddAnItem('q104_avallach_notes',1);
	thePlayer.inv.AddAnItem('q104_avallach_poetry',1);
	thePlayer.inv.AddAnItem('q105_book_about_witches',1);
	thePlayer.inv.AddAnItem('q106_note_from_keira',1);
	thePlayer.inv.AddAnItem('q106_alexander_notes_01',1);
	thePlayer.inv.AddAnItem('q106_alexander_notes_02',1);
	thePlayer.inv.AddAnItem('q201_yen_journal_1',1);
	thePlayer.inv.AddAnItem('q201_poisoned_source',1);
	thePlayer.inv.AddAnItem('q201_wild_hunt_book',1);
	thePlayer.inv.AddAnItem('q201_mousesack_letter',1);
	thePlayer.inv.AddAnItem('q201_criminal',1);
	thePlayer.inv.AddAnItem('q205_avallach_book',1);
	thePlayer.inv.AddAnItem('q206_arits_letterble',1);
	thePlayer.inv.AddAnItem('q206_arnvalds_letter',1);
	thePlayer.inv.AddAnItem('q210_letter_for_emhyr',1);
	thePlayer.inv.AddAnItem('q301_drawing_crib',1);
	thePlayer.inv.AddAnItem('q302_zdenek_contractble',1);
	thePlayer.inv.AddAnItem('q302_igor_note',1);
	thePlayer.inv.AddAnItem('q302_roche_letterble',1);
	thePlayer.inv.AddAnItem('q302_dijkstras_notes',1);
	thePlayer.inv.AddAnItem('q302_rico_thugs_notes',1);
	thePlayer.inv.AddAnItem('q302_casino_registerble',1);
	thePlayer.inv.AddAnItem('q302_roche_report',1);
	thePlayer.inv.AddAnItem('q302_crafter_notes',1);
	thePlayer.inv.AddAnItem('q302_whoreson_letter_to_radowid',1);
	thePlayer.inv.AddAnItem('q303_note_for_ciri',1);
	thePlayer.inv.AddAnItem('q303_dudus_briefing',1);
	thePlayer.inv.AddAnItem('q303_contact_note',1);
	thePlayer.inv.AddAnItem('q303_marked_bible',1);
	thePlayer.inv.AddAnItem('q304_dandelion_diary',1);
	thePlayer.inv.AddAnItem('q304_letter_1',1);
	thePlayer.inv.AddAnItem('q304_letter_2',1);
	thePlayer.inv.AddAnItem('q304_letter_3',1);
	thePlayer.inv.AddAnItem('q304_dandelion_ballad',1);
	thePlayer.inv.AddAnItem('q304_priscilla_letter',1);
	thePlayer.inv.AddAnItem('q304_ambasador_letter',1);
	thePlayer.inv.AddAnItem('q304_rosa_lover_letter',1);
	thePlayer.inv.AddAnItem('q305_script_drama_title1',1);
	thePlayer.inv.AddAnItem('q305_script_drama_title2',1);
	thePlayer.inv.AddAnItem('q305_script_comedy_title1',1);
	thePlayer.inv.AddAnItem('q305_script_comedy_title2',1);
	thePlayer.inv.AddAnItem('q305_script_for_irina',1);
	thePlayer.inv.AddAnItem('q308_coroner_msg',1);
	thePlayer.inv.AddAnItem('q308_sermon_1',1);
	thePlayer.inv.AddAnItem('q308_sermon_2',1);
	thePlayer.inv.AddAnItem('q308_sermon_3',1);
	thePlayer.inv.AddAnItem('q308_sermon_4',1);
	thePlayer.inv.AddAnItem('q308_sermon_5',1);
	thePlayer.inv.AddAnItem('q308_psycho_farewell',1);
	thePlayer.inv.AddAnItem('q308_vegelbud_invite',1);
	thePlayer.inv.AddAnItem('q308_priscilla_invite',1);
	thePlayer.inv.AddAnItem('q308_anneke_invite',1);
	thePlayer.inv.AddAnItem('q308_last_invite',1);
	thePlayer.inv.AddAnItem('q308_nathanel_sermon_1',1);
	thePlayer.inv.AddAnItem('q308_vg_ethanol',1);
	thePlayer.inv.AddAnItem('q308_vg_paraffin',1);
	thePlayer.inv.AddAnItem('q308_vg_guillotine',1);
	thePlayer.inv.AddAnItem('q309_note_from_varese',1);
	thePlayer.inv.AddAnItem('q309_witch_hunters_orders',1);
	thePlayer.inv.AddAnItem('q309_glejt_from_dijkstra',1);
	thePlayer.inv.AddAnItem('q309_mssg_from_triss',1);
	thePlayer.inv.AddAnItem('q309_key_letters',1);
	thePlayer.inv.AddAnItem('q309_key_orders',1);
	thePlayer.inv.AddAnItem('q310_journal_notes_1',1);
	thePlayer.inv.AddAnItem('q310_journal_notes_2',1);
	thePlayer.inv.AddAnItem('q311_lost_diary1',1);
	thePlayer.inv.AddAnItem('q311_lost_diary2',1);
	thePlayer.inv.AddAnItem('q311_lost_diary3',1);
	thePlayer.inv.AddAnItem('q311_lost_diary4',1);
	thePlayer.inv.AddAnItem('q311_aen_elle_notesble',1);
	thePlayer.inv.AddAnItem('q401_yen_journal_2',1);
	thePlayer.inv.AddAnItem('q403_treaty hold',1);
	thePlayer.inv.AddAnItem('q310_yen_trinket',1);
	thePlayer.inv.AddAnItem('q310_explorer_note',1);
	thePlayer.inv.AddAnItem('q505_nilf_diary_lost1',1);
	thePlayer.inv.AddAnItem('q505_nilf_diary_lost2',1);
	thePlayer.inv.AddAnItem('q505_nilf_diary_won1',1);
	thePlayer.inv.AddAnItem('sq101_shipment_list',1);
	thePlayer.inv.AddAnItem('sq101_letter_from_keiray',1);
	thePlayer.inv.AddAnItem('sq102_dolores_diary',1);
	thePlayer.inv.AddAnItem('sq102_huberts_diary',1);
	thePlayer.inv.AddAnItem('sq102_loose_papers',1);
	thePlayer.inv.AddAnItem('sq104_notes',1);
	thePlayer.inv.AddAnItem('sq106_manuscript',1);
	thePlayer.inv.AddAnItem('sq201_ship_manifesto',1);
	thePlayer.inv.AddAnItem('sq202_book_1',1);
	thePlayer.inv.AddAnItem('sq202_book_2',1);
	thePlayer.inv.AddAnItem('sq205_brewing_instructions',1);
	thePlayer.inv.AddAnItem('sq205_brewmasters_log',1);
	thePlayer.inv.AddAnItem('sq208_letter',1);
	thePlayer.inv.AddAnItem('sq208_otkell_journal',1);
	thePlayer.inv.AddAnItem('sq208_ashes',1);
	thePlayer.inv.AddAnItem('sq210_gog_book',1);
	thePlayer.inv.AddAnItem('sq210_gog_brain',1);
	thePlayer.inv.AddAnItem('sq210_blank_brain',1);
	thePlayer.inv.AddAnItem('sq210_drm_brain',1);
	thePlayer.inv.AddAnItem('sq210_gog_recipe',1);
	thePlayer.inv.AddAnItem('sq304_ledger_bookble',1);
	thePlayer.inv.AddAnItem('sq302_philippa_letter',1);
	thePlayer.inv.AddAnItem('sq303_robbery_speechble',1);
	thePlayer.inv.AddAnItem('sq309_girl_notebookble',1);
	thePlayer.inv.AddAnItem('sq311_spy_papers',1);
	thePlayer.inv.AddAnItem('sq309_mage_letter',1);
	thePlayer.inv.AddAnItem('sq310_ledger_book',1);
	thePlayer.inv.AddAnItem('sq310_package',1);
	thePlayer.inv.AddAnItem('sq313_iorveth_letters',1);
	thePlayer.inv.AddAnItem('sq401_orders',1);
	thePlayer.inv.AddAnItem('cg100_barons_notes',1);
	thePlayer.inv.AddAnItem('cg300_roches_list',1);
	thePlayer.inv.AddAnItem('mq0003_girls_diary',1);
	thePlayer.inv.AddAnItem('mq0004_burnt_papers',1);
	thePlayer.inv.AddAnItem('mq1001_locker_diary',1);
	thePlayer.inv.AddAnItem('mq1002_aeramas_journal',1);
	thePlayer.inv.AddAnItem('mq1002_aeramas_journal_2',1);
	thePlayer.inv.AddAnItem('mq1015_hang_man_note',1);
	thePlayer.inv.AddAnItem('mq1014_old_mine_journal',1);
	thePlayer.inv.AddAnItem('mq1017_nilfgaardian_letter',1);
	thePlayer.inv.AddAnItem('mq1023_fake_papers',1);
	thePlayer.inv.AddAnItem('mq1036_refugee_letter',1);
	thePlayer.inv.AddAnItem('mq1033_fight_diary',1);
	thePlayer.inv.AddAnItem('mq1053_letter_to_emhyr',1);
	thePlayer.inv.AddAnItem('mq1053_report',1);
	thePlayer.inv.AddAnItem('mq1053_martins_notes',1);
	thePlayer.inv.AddAnItem('mq1055_letters',1);
	thePlayer.inv.AddAnItem('mq2001_journal_1a',1);
	thePlayer.inv.AddAnItem('mq2001_journal_1b',1);
	thePlayer.inv.AddAnItem('mq2001_journal_1c',1);
	thePlayer.inv.AddAnItem('mq2001_journal_2a',1);
	thePlayer.inv.AddAnItem('mq2001_journal_2b',1);
	thePlayer.inv.AddAnItem('mq2003_bandit_journal',1);
	thePlayer.inv.AddAnItem('mq2006_map_1',1);
	thePlayer.inv.AddAnItem('mq2006_map_2',1);
	thePlayer.inv.AddAnItem('mq2008_journal',1);
	thePlayer.inv.AddAnItem('mq2010_lumbermill_journal_1',1);
	thePlayer.inv.AddAnItem('mq2010_lumbermill_journal_2',1);
	thePlayer.inv.AddAnItem('mq2010_lumbermill_journal_3',1);
	thePlayer.inv.AddAnItem('mq2012_letter',1);
	thePlayer.inv.AddAnItem('mq2015_kurisus_note',1);
	thePlayer.inv.AddAnItem('mq2033_captain_note',1);
	thePlayer.inv.AddAnItem('mq2033_captain_journal',1);
	thePlayer.inv.AddAnItem('mq2037_dimun_directions',1);
	thePlayer.inv.AddAnItem('mq2039_Honeycomb',1);
	thePlayer.inv.AddAnItem('mq2048_guide_notes',1);
	thePlayer.inv.AddAnItem('mq2048_waxed_letters',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}
	


exec function addquestitems3()
{
	thePlayer.inv.AddAnItem('mq2049_book_1',1);
	thePlayer.inv.AddAnItem('mq2049_book_2',1);
	thePlayer.inv.AddAnItem('mq2049_book_3',1);
	thePlayer.inv.AddAnItem('mq2049_book_4',1);
	thePlayer.inv.AddAnItem('mq2049_book_5',1);
	thePlayer.inv.AddAnItem('mq3002_hidden_messages_note_01',1);
	thePlayer.inv.AddAnItem('mq3002_hidden_messages_note_02',1);
	thePlayer.inv.AddAnItem('mq3002_hidden_messages_note_03',1);
	thePlayer.inv.AddAnItem('mq3017_reds_diary',1);
	thePlayer.inv.AddAnItem('mq3026_varese_invitation',1);
	thePlayer.inv.AddAnItem('mq3026_horse_racing_leaflet',1);
	thePlayer.inv.AddAnItem('mq3027_my_manifest',1);
	thePlayer.inv.AddAnItem('mq3027_fluff_book_1',1);
	thePlayer.inv.AddAnItem('mq3027_fluff_book_2',1);
	thePlayer.inv.AddAnItem('mq3027_fluff_book_3',1);
	thePlayer.inv.AddAnItem('mq3027_fluff_book_4',1);
	thePlayer.inv.AddAnItem('mq3027_letter',1);
	thePlayer.inv.AddAnItem('mq3030_trader_documents',1);
	thePlayer.inv.AddAnItem('mq3035_talar_notes',1);
	thePlayer.inv.AddAnItem('mq3036_rosas_letter',1);
	thePlayer.inv.AddAnItem('mq3036_rosas_second_letter',1);
	thePlayer.inv.AddAnItem('mq4001_book',1);
	thePlayer.inv.AddAnItem('mq4002_note',1);
	thePlayer.inv.AddAnItem('mq4003_letter',1);
	thePlayer.inv.AddAnItem('mq4005_note_1',1);
	thePlayer.inv.AddAnItem('mq4006_book',1);
	thePlayer.inv.AddAnItem('mh103_girls_journal',1);
	thePlayer.inv.AddAnItem('mh207_lighthouse_keeper_letter',1);
	thePlayer.inv.AddAnItem('mh301_merc_contract',1);
	thePlayer.inv.AddAnItem('mh305_doppler_letter',1);
	thePlayer.inv.AddAnItem('mh306_mages_journal',1);
	thePlayer.inv.AddAnItem('mh306_tenant_journal',1);
	thePlayer.inv.AddAnItem('lw_temerian_soldiers_journal',1);
	thePlayer.inv.AddAnItem('lw_sb13_note',1);
	thePlayer.inv.AddAnItem('FeromoneBomb',1);
	thePlayer.inv.AddAnItem('q205_gland_formula',1);
	thePlayer.inv.AddAnItem('q205_mushroom_formula',1);
	thePlayer.inv.AddAnItem('Recipe for Lesser White Honey',1);
	thePlayer.inv.AddAnItem('sq402_vitriol',1);
	thePlayer.inv.AddAnItem('sq402_rebis',1);
	thePlayer.inv.AddAnItem('sq402_hydragenum',1);
	thePlayer.inv.AddAnItem('sq402_aether',1);
	thePlayer.inv.AddAnItem('sq402_quebrith',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addtreasurehuntitems()
{
	thePlayer.inv.AddAnItem('th1001_journal_viper_part1',1);
	thePlayer.inv.AddAnItem('th1009_journal_wolf_part1',1);
	thePlayer.inv.AddAnItem('th1009_journal_wolf_part2',1);
	thePlayer.inv.AddAnItem('th003_journal_wolf_part3',1);
	thePlayer.inv.AddAnItem('th004_map_wolf_jacket_upgrade1',1);
	thePlayer.inv.AddAnItem('th005_map_wolf_jacket_upgrade2',1);
	thePlayer.inv.AddAnItem('th006_map_wolf_jacket_upgrade3',1);
	thePlayer.inv.AddAnItem('th007_map_wolf_gloves_upgrade1',1);
	thePlayer.inv.AddAnItem('th008_map_wolf_pants_upgrade1',1);
	thePlayer.inv.AddAnItem('th009_map_wolf_boots_upgrade1',1);
	thePlayer.inv.AddAnItem('th010_map_wolf_silver_sword_upgrade1',1);
	thePlayer.inv.AddAnItem('th011_map_wolf_silver_sword_upgrade2',1);
	thePlayer.inv.AddAnItem('th012_map_wolf_silver_sword_upgrade3',1);
	thePlayer.inv.AddAnItem('th013_map_wolf_steel_sword_upgrade1',1);
	thePlayer.inv.AddAnItem('th014_map_wolf_steel_sword_upgrade2',1);
	thePlayer.inv.AddAnItem('th015_map_wolf_steel_sword_upgrade3',1);
	thePlayer.inv.AddAnItem('th1003_journal_cat_lady',1);
	thePlayer.inv.AddAnItem('th1003_journal_lynx_part1',1);
	thePlayer.inv.AddAnItem('th1003_journal_lynx_part2',1);
	thePlayer.inv.AddAnItem('th1003_journal_lynx_part3',1);
	thePlayer.inv.AddAnItem('th1003_journal_lynx_part4',1);
	thePlayer.inv.AddAnItem('th1003_journal_lynx_part5',1);
	thePlayer.inv.AddAnItem('th1003_journal_lynx_part6',1);
	thePlayer.inv.AddAnItem('th020_map_lynx_jacket_upgrade1',1);
	thePlayer.inv.AddAnItem('th020_map_lynx_jacket_upgrade2',1);
	thePlayer.inv.AddAnItem('th021_map_lynx_jacket_upgrade3',1);
	thePlayer.inv.AddAnItem('th022_map_lynx_gloves_upgrade1',1);
	thePlayer.inv.AddAnItem('th023_map_lynx_pants_upgrade1',1);
	thePlayer.inv.AddAnItem('th024_map_lynx_boots_upgrade1',1);
	thePlayer.inv.AddAnItem('th025_map_lynx_silver_sword_upgrade1',1);
	thePlayer.inv.AddAnItem('th026_map_lynx_silver_sword_upgrade2',1);
	thePlayer.inv.AddAnItem('th027_map_lynx_silver_sword_upgrade3',1);
	thePlayer.inv.AddAnItem('th028_map_lynx_steel_sword_upgrade1',1);
	thePlayer.inv.AddAnItem('th029_map_lynx_steel_sword_upgrade2',1);
	thePlayer.inv.AddAnItem('th030_map_lynx_steel_sword_upgrade3',1);
	thePlayer.inv.AddAnItem('th1005_journal_gryphon_part1',1);
	thePlayer.inv.AddAnItem('th1005_journal_gryphon_part2',1);
	thePlayer.inv.AddAnItem('th1005_journal_gryphon_part3',1);
	thePlayer.inv.AddAnItem('th1005_journal_gryphon_part4',1);
	thePlayer.inv.AddAnItem('th1005_journal_gryphon_part5',1);
	thePlayer.inv.AddAnItem('th034_map_gryphon_jacket_upgrade1',1);
	thePlayer.inv.AddAnItem('th035_map_gryphon_jacket_upgrade2',1);
	thePlayer.inv.AddAnItem('th036_map_gryphon_jacket_upgrade3',1);
	thePlayer.inv.AddAnItem('th037_map_gryphon_gloves_upgrade1',1);
	thePlayer.inv.AddAnItem('th038_map_gryphon_pants_upgrade1',1);
	thePlayer.inv.AddAnItem('th039_map_gryphon_boots_upgrade1',1);
	thePlayer.inv.AddAnItem('th040_map_gryphon_silver_sword_upgrade1',1);
	thePlayer.inv.AddAnItem('th041_map_gryphon_silver_sword_upgrade2',1);
	thePlayer.inv.AddAnItem('th042_map_gryphon_silver_sword_upgrade3',1);
	thePlayer.inv.AddAnItem('th043_map_gryphon_steel_sword_upgrade1',1);
	thePlayer.inv.AddAnItem('th044_map_gryphon_steel_sword_upgrade2',1);
	thePlayer.inv.AddAnItem('th045_map_gryphon_steel_sword_upgrade3',1);
	thePlayer.inv.AddAnItem('th1007_journal_bear_part1',1);
	thePlayer.inv.AddAnItem('th1007_journal_bear_part2',1);
	thePlayer.inv.AddAnItem('th1007_journal_bear_part3',1);
	thePlayer.inv.AddAnItem('th1007_journal_bear_part4',1);
	thePlayer.inv.AddAnItem('th1007_journal_bear_part5',1);
	thePlayer.inv.AddAnItem('th1007_journal_bear_part6',1);
	thePlayer.inv.AddAnItem('th050_map_bear_jacket_upgrade1',1);
	thePlayer.inv.AddAnItem('th051_map_bear_jacket_upgrade2',1);
	thePlayer.inv.AddAnItem('th052_map_bear_jacket_upgrade3',1);
	thePlayer.inv.AddAnItem('th053_map_bear_gloves_upgrade1',1);
	thePlayer.inv.AddAnItem('th054_map_bear_pants_upgrade1',1);
	thePlayer.inv.AddAnItem('th055_map_bear_boots_upgrade1',1);
	thePlayer.inv.AddAnItem('th056_map_bear_silver_sword_upgrade1',1);
	thePlayer.inv.AddAnItem('th057_map_bear_silver_sword_upgrade2',1);
	thePlayer.inv.AddAnItem('th058_map_bear_silver_sword_upgrade3',1);
	thePlayer.inv.AddAnItem('th059_map_bear_steel_sword_upgrade1',1);
	thePlayer.inv.AddAnItem('th060_map_bear_steel_sword_upgrade2',1);
	thePlayer.inv.AddAnItem('th061_map_bear_steel_sword_upgrade3',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function addcharacterdecorations()
{
	thePlayer.inv.AddAnItem('Geralt mask 01',1);
	thePlayer.inv.AddAnItem('Geralt mask 02',1);
	thePlayer.inv.AddAnItem('Geralt mask 03',1);
	thePlayer.inv.AddAnItem('Triss mask',1);
	thePlayer.inv.AddAnItem('Geralt robbery mask',1);
	thePlayer.inv.AddAnItem('Triss Earring',1);
	thePlayer.inv.AddAnItem('mq1013_Pretender pendant',1);
	thePlayer.inv.AddAnItem('Dijkstra mask',1);
	thePlayer.inv.AddAnItem('Voorhis mask',1);
	thePlayer.inv.AddAnItem('Ingrid mask',1);
	thePlayer.inv.AddAnItem('Luiza mask',1);
	thePlayer.inv.AddAnItem('Witch Hunter mask',1);
	thePlayer.inv.AddAnItem('Albert mask',1);
	thePlayer.inv.AddAnItem('False Albert mask 01',1);
	thePlayer.inv.AddAnItem('False Albert mask 02',1);
	thePlayer.inv.AddAnItem('Guest mask man 01',1);
	thePlayer.inv.AddAnItem('Guest mask man 02',1);
	thePlayer.inv.AddAnItem('Guest mask man 03',1);
	thePlayer.inv.AddAnItem('Guest mask man 04',1);
	thePlayer.inv.AddAnItem('Guest mask man 05',1);
	thePlayer.inv.AddAnItem('Guest mask man 06',1);
	thePlayer.inv.AddAnItem('Guest mask man 07',1);
	thePlayer.inv.AddAnItem('Guest mask man 08',1);
	thePlayer.inv.AddAnItem('Guest mask man 09',1);
	thePlayer.inv.AddAnItem('Guest mask man 10',1);
	thePlayer.inv.AddAnItem('Guest mask man 11',1);
	thePlayer.inv.AddAnItem('Guest mask man 12',1);
	thePlayer.inv.AddAnItem('Guest mask man 13',1);
	thePlayer.inv.AddAnItem('Guest mask woman 01',1);
	thePlayer.inv.AddAnItem('Guest mask woman 02',1);
	thePlayer.inv.AddAnItem('Guest mask woman 03',1);
	thePlayer.inv.AddAnItem('Guest mask woman 04',1);
	thePlayer.inv.AddAnItem('Guest mask woman 05',1);
	thePlayer.inv.AddAnItem('Guest mask woman 06',1);
	thePlayer.inv.AddAnItem('Guest mask woman 07',1);
	thePlayer.inv.AddAnItem('Guest mask woman 08',1);
	thePlayer.inv.AddAnItem('Guest mask woman 09',1);
	thePlayer.inv.AddAnItem('Guest mask woman 10',1);
	thePlayer.inv.AddAnItem('Guest mask woman 11',1);
	thePlayer.inv.AddAnItem('Guest mask woman 12',1);
	thePlayer.inv.AddAnItem('Guest mask woman 13',1);
	thePlayer.inv.AddAnItem('Guest mask woman 14',1);
	thePlayer.inv.AddAnItem('Guest mask woman 15',1);
	thePlayer.inv.AddAnItem('Guest mask woman 16',1);
	thePlayer.inv.AddAnItem('Guest mask woman 17',1);
	
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}


exec function recycle()
{
	var id : array<SItemUniqueId>;
	
	id = thePlayer.inv.AddAnItem('Witcher Silver Sword');
	thePlayer.inv.RecycleItem( id[0], ECL_Journeyman );
}


exec function printinv(optional onlyEquipped : bool)
{
	PrintInventory(onlyEquipped);
}
exec function printinv2()
{
	PrintInventory2();
}

exec function printinv2item( index : int )
{
	PrintInventory2Item( index );
}

exec function dressmeup( i : int)
{
	var inv : CInventoryComponent = thePlayer.inv;
	var ids : array<SItemUniqueId>;
	
	switch(i)
	{
		case 0:
			ids = inv.AddAnItem('Plain Shirt');		
			break;
		case 1:
			ids = inv.AddAnItem('Worn Leather Boots');
			break;
		case 2:
			ids = inv.AddAnItem('Worn Pants');
			break;
		case 3:
			ids = inv.AddAnItem('Worn Leather Gloves');
			break;
	}
	
	thePlayer.EquipItem(ids[0]);
}

exec function undressme( i : int )
{
	var inv : CInventoryComponent = thePlayer.inv;
	
	if( i == 0 )
	{
		inv.RemoveItemByName('Plain Shirt', 1 );
	}
	else if( i == 1 )
	{
		inv.RemoveItemByName('Worn Leather Boots', 1 );
	}
	else if( i == 2 )
	{
		inv.RemoveItemByName('Worn Pants', 1 );
	}
	else if( i == 3 )
	{
		inv.RemoveItemByName('Worn Leather Gloves', 1 );
	}
}

exec function healme(optional perc : int)
{
	var max, current : float;

	if(perc <= 0)
		perc = 100;
		
	max = thePlayer.GetStatMax(BCS_Vitality);
	current = thePlayer.GetStat(BCS_Vitality);
	thePlayer.ForceSetStat(BCS_Vitality, MinF(max, current + max * perc / 100));
}

exec function playstation(e : bool)
{
	if(e)
	{
		FactsAdd("dbg_force_ps_pad");
	}
	else
	{
		FactsRemove("dbg_force_ps_pad");
	}
}


exec function hitme(d : int, optional playHitAnim : bool)
{
	var action : W3DamageAction;

	action = new W3DamageAction in theGame.damageMgr;
	action.Initialize(NULL, thePlayer, NULL, 'console', EHRT_Light, CPS_Undefined, false, false, false, false);
	action.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, (thePlayer.GetStatMax( BCS_Vitality )*d)/100);
	
	action.SetSuppressHitSounds(true);
	
	if ( playHitAnim )
	{
		action.SetHitAnimationPlayType(EAHA_ForceYes);
	}
	else
	{
		action.SetHitAnimationPlayType(EAHA_ForceNo);
	}
	
	theGame.damageMgr.ProcessAction(action);
	delete action;
}

exec function hittarget(d : int, optional playHitAnim : bool)
{
	var action : W3DamageAction;

	action = new W3DamageAction in theGame.damageMgr;
	action.Initialize(NULL, thePlayer.GetTarget(), NULL, 'console', EHRT_Light, CPS_Undefined, false, false, false, false);
	action.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, (thePlayer.GetTarget().GetMaxHealth() * d /100) );
	
	action.SetSuppressHitSounds(true);
	
	if ( playHitAnim )
	{
		action.SetHitAnimationPlayType(EAHA_ForceYes);
	}
	else
	{
		action.SetHitAnimationPlayType(EAHA_ForceNo);
	}
	
	theGame.damageMgr.ProcessAction(action);
	delete action;
}


exec function hitstamina(d : int)
{
	thePlayer.DrainStamina(ESAT_FixedValue, RoundMath((thePlayer.GetStatMax( BCS_Stamina )*d)/100), 1 );
}



exec function drinkpots( index : int)
{	
	var witcher : W3PlayerWitcher;
	
	witcher = GetWitcherPlayer();
	switch( index )
	{
		case 1 : 
		{
			witcher.inv.AddAnItem('White Honey 1',10);	
			break;
		}	
		case 2 : 
		{
			witcher.inv.AddAnItem('Full Moon 1',10);	
			break;
		}
		case 3 : 
		
		case 4 : 
		
		case 5 :
		{
			witcher.inv.AddAnItem('White Honey 1',10);	
			witcher.inv.AddAnItem('Cat 1',10);	
			
			break;
		}
	}	
}

exec function drinkpot(potionName : name, slot : int)
{
	var ids : array<SItemUniqueId>;
	var ammo : int;
	var min, max : SAbilityAttributeValue;

	theGame.GetDefinitionsManager().GetItemAttributeValueNoRandom(potionName, true, 'ammo', min, max);
	ammo = (int)CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
	ids = thePlayer.inv.AddAnItem(potionName, ammo);	
	
	switch(slot)
	{
		case 1 : slot = EES_Potion1; break;
		case 2 : slot = EES_Potion2; break;
		case 3 : slot = EES_Potion3; break;
		case 4 : slot = EES_Potion4; break;
	}
	
	GetWitcherPlayer().EquipItemInGivenSlot(ids[0], slot, false);
}

exec function expots(optional isDoubleTap : bool)
{
	var witcher : W3PlayerWitcher;
	var ids : array<SItemUniqueId>;
	
	witcher = GetWitcherPlayer();
	
	ids = witcher.inv.AddAnItem('Apple',100);
	witcher.EquipItemInGivenSlot(ids[0], EES_Potion1, false);
	
	ids.Clear();
	ids = witcher.inv.AddAnItem('Tawny Owl 3');
	witcher.EquipItemInGivenSlot(ids[0], EES_Potion3, false);
	
	ids.Clear();
	ids = witcher.inv.AddAnItem('Swallow 3');
	witcher.EquipItemInGivenSlot(ids[0], EES_Potion2, false);
	
	ids.Clear();
	ids = witcher.inv.AddAnItem('Thunderbolt 3');
	witcher.EquipItemInGivenSlot(ids[0], EES_Potion4, false);
	
	witcher.inv.AddAnItem('Dwarven spirit',100);
	
	thePlayer.GetInputHandler().SetPotionSelectionMode(!isDoubleTap);
}

exec function potmode(isDoubleTap : bool)
{
	thePlayer.GetInputHandler().SetPotionSelectionMode(!isDoubleTap);
}

exec function addalchrec(nam : name)
{
	GetWitcherPlayer().AddAlchemyRecipe(nam);
}

exec function addalch2()
{
	LogChannel('AlchemyTimers', "addalch2 >>>>>>>>");

	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Black Blood 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Blizzard 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Cat 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Full Moon 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Golden Oriole 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Maribor Forest 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Petris Philtre 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Swallow 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Tawny Owl 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Thunderbolt 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for White Honey 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for White Raffards Decoction 2');	
	
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Anthropomorph Oil 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Cursed Oil 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Hanged Man Venom 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Hybrid Oil 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Insectoid Oil 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Magicals Oil 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Necrophage Oil 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Specter Oil 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Vampire Oil 2');
	
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Dancing Star 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Devils Puffball 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Dwimeritum Bomb 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Dragons Dream 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Grapeshot 2');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Samum 2');
	
	LogChannel('AlchemyTimers', "addalch2 <<<<<<<<");
}
exec function addalch3()
{
	LogChannel('AlchemyTimers', "addalch3 >>>>>>>>");
	
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Black Blood 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Blizzard 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Cat 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Full Moon 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Golden Oriole 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Maribor Forest 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Petris Philtre 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Swallow 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Tawny Owl 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Thunderbolt 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for White Honey 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for White Raffards Decoction 3');	
	
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Anthropomorph Oil 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Cursed Oil 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Hanged Man Venom 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Hybrid Oil 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Insectoid Oil 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Magicals Oil 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Necrophage Oil 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Specter Oil 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Vampire Oil 3');
	
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Dancing Star 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Devils Puffball 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Dwimeritum Bomb 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Dragons Dream 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Grapeshot 3');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Samum 3');
	
	LogChannel('AlchemyTimers', "addalch3 <<<<<<<<");
}




exec function addalch(optional quantity : int )
{
	var dm : CDefinitionsManagerAccessor;
	var main, ingredients : SCustomNode;
	var i, k : int;
	var ing : array<name>;
	var tmpName : name;

	LogChannel('AlchemyTimers', "addalch >>>>>>>>");

	if(quantity == 0)
		quantity = 50;
	
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Black Blood 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Blizzard 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Cat 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Full Moon 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Golden Oriole 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Maribor Forest 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Petris Philtre 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Swallow 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Tawny Owl 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Thunderbolt 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for White Gull 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for White Honey 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for White Raffards Decoction 1');	
	
	
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Beast Oil 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Cursed Oil 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Hanged Man Venom 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Hybrid Oil 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Insectoid Oil 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Magicals Oil 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Necrophage Oil 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Specter Oil 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Vampire Oil 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Draconide Oil 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Ogre Oil 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Relic Oil 1');
	
	
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Dancing Star 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Devils Puffball 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Dwimeritum Bomb 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Dragons Dream 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Grapeshot 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Samum 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for Silver Dust Bomb 1');
	GetWitcherPlayer().AddAlchemyRecipe('Recipe for White Frost 1');
	
	GetWitcherPlayer().AddAlchemyRecipe('q305_antidote_for_venom_formula');
	
	LogChannel('AlchemyTimers', "addalch ||||||||1");

	
	dm = theGame.GetDefinitionsManager();
	main = dm.GetCustomDefinition('alchemy_recipes');

	LogChannel('AlchemyTimers', "addalch ||||||||2");
	
	
	for(i=0; i<main.subNodes.Size(); i+=1)
	{
		ingredients = dm.GetCustomDefinitionSubNode(main.subNodes[i],'ingredients');					
		for(k=0; k<ingredients.subNodes.Size(); k+=1)
		{		
			if(dm.GetCustomNodeAttributeValueName(ingredients.subNodes[k], 'item_name', tmpName))
			{
				if(!ing.Contains(tmpName))
					ing.PushBack(tmpName);
			}
		}
	}
	
	LogChannel('AlchemyTimers', "addalch ||||||||3");
	
	for(i=0; i<ing.Size(); i+=1)
	{
		if (dm.ItemHasTag(ing[i], 'MutagenIngredient'))
		{
			thePlayer.inv.AddAnItem(ing[i],1); 
		}
		else
		{
			thePlayer.inv.AddAnItem(ing[i],quantity);
		}
	}
		
	LogChannel('AlchemyTimers', "addalch <<<<<<<<");
}


function PrintInventory(optional onlyEquipped : bool)
{
	var items : array<SItemUniqueId>;
	var i, quantity : int;
	var printables : array<name>;
	var itemName : name;
	var dm : CDefinitionsManagerAccessor;
	var witcher : W3PlayerWitcher;
	
	Log("==== Showing inventory ====");	
	dm = theGame.GetDefinitionsManager();
	thePlayer.inv.GetAllItems(items);
	witcher = GetWitcherPlayer();
	
	for(i=0; i<items.Size(); i+=1)
	{	
		if(onlyEquipped && !witcher.IsItemEquipped(items[i]))
			continue;
			
		itemName = thePlayer.inv.GetItemName(items[i]);
			
		if(onlyEquipped)
		{
			Log(witcher.inv.GetItemQuantity(items[i]) + " x " + itemName + ", " + witcher.GetItemSlot(items[i]));
		}
		else if(!printables.Contains(itemName))
		{
			printables.PushBack(itemName);
		}
	}
	
	if(!onlyEquipped)
	{
		for(i=0; i<printables.Size(); i+=1)
		{
			quantity = thePlayer.inv.GetItemQuantityByName(printables[i]);
			Log(quantity + " x " + printables[i]);
		}
	}
	
	Log("");
}

function PrintInventory2()
{
	var inv				: CInventoryComponent;
	var items			: array< SItemUniqueId >;
	var i, j			: int;
	var itemName		: name;
	var itemQuantity	: int;
	var itemCategory	: name;
	var itemTagsArr		: array< name >;
	var itemTags		: string;
	
	var listName		: array< string >;
	var listQuantity	: array< string >;
	var listCategory	: array< string >;
	var listTags		: array< string >;

	var listNameLen		: int;
	var listQuantityLen	: int;
	var listCategoryLen	: int;
	var listTagsLen		: int;
	
	var line			: string;

	LogItems("==== Showing inventory ==========================================================");
	
	inv = thePlayer.inv;
	inv.GetAllItems( items );
	for( i = 0; i < items.Size(); i += 1 )
	{	
		itemName     = inv.GetItemName( items[ i ] );
		itemQuantity = inv.GetItemQuantity( items[ i ] );
		itemCategory = inv.GetItemCategory( items[ i ] );
		inv.GetItemTags( items[ i ], itemTagsArr );
		itemTags = "";
		for ( j = 0; j < itemTagsArr.Size(); j += 1 )
		{
			itemTags += itemTagsArr[ j ];
			if ( j < itemTagsArr.Size() - 1 )
			{
				itemTags += ", ";
			}
		}
		listName.PushBack    ( "[" + itemName + "] " );
		listQuantity.PushBack( "[" + itemQuantity + "] " );
		listCategory.PushBack( "[" + itemCategory + "] " );
		listTags.PushBack(     "[" + itemTags + "] " );
	}
	
	for ( i = 0; i < listName.Size(); i += 1 )
	{
		if ( listNameLen < StrLen( listName[ i ] ) )
		{
			listNameLen = StrLen( listName[ i ] );
		}
		if ( listQuantityLen < StrLen( listQuantity[ i ] ) )
		{
			listQuantityLen = StrLen( listQuantity[ i ] );
		}
		if ( listCategoryLen < StrLen( listCategory[ i ] ) )
		{
			listCategoryLen = StrLen( listCategory[ i ] );
		}
		if ( listTagsLen < StrLen( listTags[ i ] ) )
		{
			listTagsLen = StrLen( listTags[ i ] );
		}
	}

	for ( i = 0; i < listName.Size(); i += 1 )
	{
		line  = "[";
		line += i;
		if ( i < 10)
			line += " ";
		line += "] ";

		line += listQuantity[ i ];
		for ( j = StrLen( listQuantity[ i ] ); j < listQuantityLen; j += 1 )
		{
			line += " ";
		}

		line += listName[ i ];
		for ( j = StrLen( listName[ i ] ); j < listNameLen; j += 1 )
		{
			line += " ";
		}

		line += listCategory[ i ];
		for ( j = StrLen( listCategory[ i ] ); j < listCategoryLen; j += 1 )
		{
			line += " ";
		}

		line += listTags[ i ];
		for ( j = StrLen( listTags[ i ] ); j < listTagsLen; j += 1 )
		{
			line += " ";
		}

		LogItems(line );
	}
	LogItems("=================================================================================");
}

function PrintInventory2Item( index : int )
{
	var inv				: CInventoryComponent;
	var items			: array< SItemUniqueId >;
	var itemName		: name;
	var itemQuantity	: int;
	var itemCategory	: name;
	var itemDurability  : float;
	
	LogItems("==== Showing inventory item =====================================================");
	
	inv = thePlayer.inv;
	inv.GetAllItems( items );
	if ( index >= 0 && index < items.Size() )
	{
		itemName       = inv.GetItemName( items[ index ] );
		itemQuantity   = inv.GetItemQuantity( items[ index ] );
		itemCategory   = inv.GetItemCategory( items[ index ] );
		itemDurability = inv.GetItemDurability( items[ index ] );

		LogItems("[" + itemName + "] [" + itemQuantity + "] [" + itemCategory + "] [dur " + itemDurability + "]");
	}
	else
	{
		LogItems("Incorrect index " + index + " <0, " + (items.Size() - 1) + ">");
	}
	LogItems("=================================================================================");

}


exec function craft(schemName : name, level : int, type : int)
{
	var cftman : W3CraftingManager;
	var master : W3CraftsmanComponent;
	var craftedItemId : SItemUniqueId;
	var craftsmanDef : SCraftsman;
	var error : ECraftingException;
	
	LogCrafting("--==  Starting craft test  ==--");
	
	GetWitcherPlayer().AddCraftingSchematic(schemName);
	
	
	master = new W3CraftsmanComponent in theGame;
	craftsmanDef.level = level;
	craftsmanDef.type = type;
	master.craftsmanData.PushBack(craftsmanDef);
	
	cftman = new W3CraftingManager in theGame;
	cftman.Init(master);
	error = cftman.Craft(schemName, craftedItemId);
	
	LogCrafting("Craft test: result is <<" + error + ">>");
	LogCrafting("");
		
	delete master;
	delete cftman;
}

exec function testuroboros()
{
	var maskIds : array<SItemUniqueId>;
	var maskId : SItemUniqueId;
	
	maskIds = thePlayer.inv.AddAnItem('q203_eyeofloki');
	maskId = maskIds[0];
	FactsAdd("q203_eyeofloki_active");
	thePlayer.EquipItem(maskId, EES_InvalidSlot, true);
}

exec function unequipitem(n : name)
{
	var ids : array<SItemUniqueId>;
	var id : SItemUniqueId;
	
	ids = thePlayer.inv.GetItemsIds(n);
	id = ids[0];
	thePlayer.UnequipItem(id);
}

exec function hideitem()
{
	thePlayer.OnUseSelectedItem();
}

exec function removeitem(n : name)
{
	thePlayer.inv.RemoveItemByName( n, 1 );
}

exec function equipitem(n : name)
{
	var ids : array<SItemUniqueId>;
	var id : SItemUniqueId;
	
	ids = thePlayer.inv.GetItemsIds(n);
	id = ids[0];
	thePlayer.EquipItem(id);
}

exec function useoil(n : name, optional type : int)
{
	var ids : array<SItemUniqueId>;
	var swordId : SItemUniqueId;
	var slot : EEquipmentSlots;
	
	if(type == 0)
		slot = EES_SteelSword;
	if(type == 1)
		slot = EES_SilverSword;

	ids = thePlayer.inv.AddAnItem(n);
	
	if(GetWitcherPlayer())
	{
		GetWitcherPlayer().GetItemEquippedOnSlot(slot, swordId);
	}
	else	
	{
		swordId = ((W3ReplacerCiri)thePlayer).GetEquippedSword(!type);
	}
	
	if(swordId != GetInvalidUniqueId())
		thePlayer.ApplyOil(ids[0], swordId);
}

exec function oilstats()
{
	oilstats_internal( true );
	oilstats_internal( false );
}

function oilstats_internal( steel : bool )
{
	var id : SItemUniqueId;
	var slot : EEquipmentSlots;
	var oils : array< W3Effect_Oil >;
	var str : string;
	var i : int;
	
	if( steel )
	{
		slot = EES_SteelSword;
		str = "Steel";
	}
	else
	{
		slot = EES_SilverSword;
		str = "Silver";
	}
	
	if(GetWitcherPlayer().GetItemEquippedOnSlot(slot, id))
	{
		oils = GetWitcherPlayer().inv.GetOilsAppliedOnItem( id );
		for(i=0; i<oils.Size(); i+=1)
		{
			LogStats( "=============== oil stats ==============================" );
			LogStats( str + " sword has <<" + oils[ i ].GetOilItemName() + ">> oil, with " + oils[ i ].GetAmmoCurrentCount() + "/" + oils[ i ].GetAmmoMaxCount() + " charges left");
		}
	}	
}

exec function addSlot()
{
	var swordId : SItemUniqueId;
	GetWitcherPlayer().GetItemEquippedOnSlot( EES_SteelSword, swordId );
	thePlayer.inv.AddSlot( swordId );
}

exec function enchantItem()
{
	var swordId : SItemUniqueId;
	GetWitcherPlayer().GetItemEquippedOnSlot( EES_SteelSword, swordId );
	thePlayer.inv.EnchantItem( swordId, 'Runeword 6', 'Runeword 6 _stats' );
}

exec function unenchantItem()
{
	var swordId : SItemUniqueId;
	GetWitcherPlayer().GetItemEquippedOnSlot( EES_SteelSword, swordId );
	thePlayer.inv.UnenchantItem( swordId );
}

exec function playerkill(optional ignoreImmortalityMode : bool)
{
	thePlayer.Kill( 'Debug', ignoreImmortalityMode );
}

exec function PlayerKinematic()
{
	thePlayer.SetBehaviorVariable( 'Ragdoll_Weight',0.0);
	thePlayer.RaiseForceEvent('RecoverFromRagdoll');
}

exec function PlayerDynamic(optional weight : float)
{
	if ( weight > 0 )
		thePlayer.SetBehaviorVariable( 'Ragdoll_Weight',weight);
	else
		thePlayer.SetBehaviorVariable( 'Ragdoll_Weight',1.0);
	thePlayer.RaiseForceEvent('Ragdoll');
}

function PlayerDynamicGlobal()
{
	thePlayer.SetBehaviorVariable( 'Ragdoll_Weight',1.0);
	thePlayer.RaiseForceEvent( 'Ragdoll' );
}

function PlayerKinematicGlobal()
{
	thePlayer.SetBehaviorVariable( 'Ragdoll_Weight',0.0);
	thePlayer.RaiseForceEvent( 'RecoverFromRagdoll' );
}

exec function itemattributes(itemName : name)
{
	var inv : CInventoryComponent;
	var ids : array<SItemUniqueId>;
	var atts : array<name>;
	var i : int;

	inv = thePlayer.inv;
	ids = inv.GetItemsIds(itemName);
	inv.GetItemAttributes(ids[0], atts);
	
	LogItems("Logging attributes of item <<" + itemName + ">>");
	for(i=0; i<atts.Size(); i+=1)
		LogItems(atts[i]);
	LogItems("");
}

exec function additem(itemName : name, optional count : int, optional equip : bool)
{
	var ids : array<SItemUniqueId>;
	var i : int;

	if(IsNameValid(itemName))
	{
		ids = thePlayer.inv.AddAnItem(itemName, count);
		if(thePlayer.inv.IsItemSingletonItem(ids[0]))
		{
			for(i=0; i<ids.Size(); i+=1)
				thePlayer.inv.SingletonItemSetAmmo(ids[i], thePlayer.inv.SingletonItemGetMaxAmmo(ids[i]));
		}
		
		if(ids.Size() == 0)
		{
			LogItems("exec function additem: failed to add item <<" + itemName + ">>, most likely wrong item name");
			return;
		}
		
		if(equip)
			thePlayer.EquipItem(ids[0]);
	}
	else
	{
		LogItems("exec function additem: Invalid item name <<"+itemName+">>, cannot add");
	}
}

exec function printfact(id : string)
{
    if ( FactsDoesExist( id ) )
		Log("Fact <<"+id+">> has val of "+FactsQuerySum(id));
	else
		Log("Fact <<"+id+">> doesn't exists");
}

exec function addfact(factID : string, optional value : int, optional expires : int)
{
	var val : int;
	var exp : int;
	
	if(value == 0)
		val = 1;
	else
		val = value;

	if ( expires == 0)
	    exp = -1;
	else
		exp = expires;
	
	FactsAdd(factID, val, exp);
}

exec function removefact(factID : string)
{
	FactsRemove(factID);
}

exec function klapaucius()
{
	thePlayer.AddMoney(100);
}
exec function addmoney(val : int)
{
	thePlayer.AddMoney(val);
}

exec function removemoney(val : int)
{
	thePlayer.RemoveMoney(val);
}

exec function fadein()
{
	theGame.ResetFadeLock( "exe_func_fadein" );
	theGame.FadeInAsync( 0.f );
}

exec function pc_snaptonavdata(val: bool)
{
	thePlayer.GetMovingAgentComponent().SnapToNavigableSpace( val );
}


exec function god()
{
	god_internal();
}

function god_internal()
{
	if( !thePlayer.IsInvulnerable() )
	{
		thePlayer.SetImmortalityMode( AIM_Invulnerable, AIC_Default, true );
		thePlayer.SetCanPlayHitAnim(false);
		thePlayer.AddBuffImmunity_AllNegative('god', true);
		StaminaBoyInternal(true);
		LogCheats( "God is now ON" );
	}
	else
	{
		thePlayer.SetImmortalityMode( AIM_None, AIC_Default, true );	
		thePlayer.SetCanPlayHitAnim(true);
		thePlayer.RemoveBuffImmunity_AllNegative('god');
		StaminaBoyInternal(false);
		LogCheats( "God is now OFF" );
	}
}


exec function god2()
{
	god2_internal();
}

function god2_internal()
{
	var isImmortal : bool;
	
	isImmortal = thePlayer.IsImmortal();
	thePlayer.CheatGod2( !isImmortal );
	
	if( isImmortal )
	{
		LogCheats( "God is now OFF" );
	}
	else
	{
		LogCheats( "God is now ON" );
	}
}


exec function god3()
{	
	thePlayer.SetImmortalityMode(AIM_Unconscious,AIC_Default);
}


exec function eatapple()
{		
	var ids : array<SItemUniqueId>;
	
	ids = thePlayer.inv.AddAnItem( 'Apple' );
	thePlayer.ConsumeItem(ids[0]);
}

exec function gametestdummy() : bool
{		
	return false;
}

exec function spamplayerspeed(optional enable : bool)
{
	if(enable)
		thePlayer.AddTimer('Debug_SpamSpeed', 0.01, true);
	else
		thePlayer.RemoveTimer('Debug_SpamSpeed');
}

exec function learnskill(skillName : name)
{
	var i : int;
	var skills : array<SSkill>;

	if(skillName == 'all')
	{
		skills = thePlayer.GetPlayerSkills();
		for(i=0; i<skills.Size(); i+=1)
		{
			thePlayer.AddSkill(skills[i].skillType);
		}
	}
	else
	{
		thePlayer.AddSkill(SkillNameToEnum(skillName));
	}
}

exec function stats(tag : name)
{
	var actor : CActor;

	actor = theGame.GetActorByTag(tag);
	if(!actor)
	{
		LogStats("Cannot find actor with tag <<" + tag + ">>");
		return;
	}
	
	Debug_stats(actor);
}

exec function statstarget()
{
	var target : CNewNPC;
	target = (CNewNPC)thePlayer.GetTarget();	
	
	if( target )
		Debug_stats( target );
	else
		LogStats("statstarget: No target!");		
}

exec function statsplayer()
{
	Debug_stats(thePlayer);
}

exec function logstats()
{
	var i, size : int;
	var bullshit : ESkill;
	var inv				: CInventoryComponent;
	var items			: array< SItemUniqueId >;
	var itemsnames		: array< name >;
	var j			: int;
	var itemName		: name;
	var itemQuantity	: int;
	var itemCategory	: name;
	var itemTagsArr		: array< name >;
	var itemTags		: string;
	
	var listName		: array< string >;
	var listQuantity	: array< string >;
	var listCategory	: array< string >;
	var listTags		: array< string >;

	var listNameLen		: int;
	var listQuantityLen	: int;
	var listCategoryLen	: int;
	var listTagsLen		: int;
	var temp			: bool;
	
	var line			: string;	
	
	LogStats("======================================================================================================");
	LogStats("================================= BALANCE STATS LOG - STARTS HERE ====================================");
	LogStats("======================================================================================================");
	LogStats("");
	LogStats("CURRENT DIFFICULTY LEVEL :");	
	LogStats(theGame.GetDifficultyMode() );	
	LogStats("");
	LogStats("EXPERIENCE POINTS MULTIPLIERS :");	
	LogStats("KILLS = BASE_EPERIENCE *" + theGame.expGlobalMod_kills );	
	LogStats("QUESTS = BASE_EXPERIENCE *" + theGame.expGlobalMod_quests );	
	LogStats("");
	LogStats("------------------------------------------------------------------------------------------------------");
	LogStats(" STATISTICS");
	LogStats("------------------------------------------------------------------------------------------------------");
	LogStats("");
	Debug_stats(thePlayer);
	LogStats("");
	LogStats("------------------------------------------------------------------------------------------------------");
	LogStats(" SKILLS");
	LogStats("------------------------------------------------------------------------------------------------------");
	LogStats("");
	LogStats("ALWAYS UNLOCKED :");
	LogStats("");
	size = EnumGetMax('ESkill')+1;
	for(i=0; i<20; i+=1)
	{
		if(thePlayer.HasLearnedSkill(i))
		{
			bullshit = i;
			if ( thePlayer.IsSkillEquipped(i) ) 
			LogStats(GetLocStringByKeyExt(thePlayer.GetSkillLocalisationKeyName( bullshit ) ) + " ("+bullshit+")");
		}
	}
	LogStats("");
	LogStats("");
	LogStats("CURRENT BUILD :");
	LogStats("");
	for(i=20; i<size; i+=1)
	{
		if(thePlayer.HasLearnedSkill(i))
		{
			bullshit = i;
			if ( thePlayer.IsSkillEquipped(i) ) 
			LogStats(GetLocStringByKeyExt(thePlayer.GetSkillLocalisationKeyName( bullshit ) ) + " ("+bullshit+")");
		}
	}
	LogStats("");
	LogStats("");
	LogStats("ALL OTHER UNLOCKED SKILLS:");
	LogStats("");
	for(i=0; i<size; i+=1)
	{
		if(thePlayer.HasLearnedSkill(i))
		{
			bullshit = i;
			if ( !thePlayer.IsSkillEquipped(i) ) 
			LogStats(GetLocStringByKeyExt(thePlayer.GetSkillLocalisationKeyName( bullshit ) ) + " ("+bullshit+") | isEquipped=" + thePlayer.IsSkillEquipped(i) + " | canUse=" + thePlayer.CanUseSkill(i));
		}
	}
	LogStats("");
	LogStats("");
	LogStats("------------------------------------------------------------------------------------------------------");
	LogStats(" INVENTORY");
	LogStats("------------------------------------------------------------------------------------------------------");
	LogStats("");

	inv = thePlayer.inv;
	LogStats("GENERAL STATS:");
	LogStats("CAPACITY - " + RoundF(GetWitcherPlayer().GetEncumbrance()) + "/" + RoundF(GetWitcherPlayer().GetMaxRunEncumbrance(temp)) );	
	LogStats("CROWNS (money) - " + inv.GetMoney() );
	LogStats("");
	LogStats("CUREENTLY EQUIPPED ITEMS:");
	inv.GetAllItems( items );
		for( i = 0; i < items.Size(); i += 1 )
		{
			if ( ( inv.IsItemHeld( items[ i ] ) || inv.IsItemMounted( items[ i ] ) ) && !inv.ItemHasTag( items[i], 'NoShow' ) )
			{
					LogStats( StrUpper(inv.GetItemCategory(items[i]))  + ": " + inv.GetItemName( items[i] ));
			}
		}	
	
	LogStats("");
	LogStats("ALL ITEMS:");
	for( i = 0; i < items.Size(); i += 1 )
	{	
		itemName     = inv.GetItemName( items[ i ] );
		itemQuantity = inv.GetItemQuantity( items[ i ] );
		itemCategory = inv.GetItemCategory( items[ i ] );
		inv.GetItemTags( items[ i ], itemTagsArr );
		itemTags = "";
		for ( j = 0; j < itemTagsArr.Size(); j += 1 )
		{
			itemTags += itemTagsArr[ j ];
			if ( j < itemTagsArr.Size() - 1 )
			{
				itemTags += ", ";
			}
		}
		listName.PushBack    ( "[" + itemName + "] " );
		listQuantity.PushBack( "[" + itemQuantity + "] " );
		listCategory.PushBack( "[" + itemCategory + "] " );
		listTags.PushBack(     "[" + itemTags + "] " );
	}
	
	for ( i = 0; i < listName.Size(); i += 1 )
	{
		if ( listNameLen < StrLen( listName[ i ] ) )
		{
			listNameLen = StrLen( listName[ i ] );
		}
		if ( listQuantityLen < StrLen( listQuantity[ i ] ) )
		{
			listQuantityLen = StrLen( listQuantity[ i ] );
		}
		if ( listCategoryLen < StrLen( listCategory[ i ] ) )
		{
			listCategoryLen = StrLen( listCategory[ i ] );
		}
		if ( listTagsLen < StrLen( listTags[ i ] ) )
		{
			listTagsLen = StrLen( listTags[ i ] );
		}
	}

	for ( i = 0; i < listName.Size(); i += 1 )
	{
		line  = "[";
		line += i;
		if ( i < 10)
			line += " ";
		line += "] ";

		line += listQuantity[ i ];
		for ( j = StrLen( listQuantity[ i ] ); j < listQuantityLen; j += 1 )
		{
			line += " ";
		}

		line += listName[ i ];
		for ( j = StrLen( listName[ i ] ); j < listNameLen; j += 1 )
		{
			line += " ";
		}

		line += listCategory[ i ];
		for ( j = StrLen( listCategory[ i ] ); j < listCategoryLen; j += 1 )
		{
			line += " ";
		}

		line += listTags[ i ];
		for ( j = StrLen( listTags[ i ] ); j < listTagsLen; j += 1 )
		{
			line += " ";
		}

		LogStats(line );
	}
	LogStats("");	
	LogStats("------------------------------------------------------------------------------------------------------");
	LogStats(" ABILITIES LIST");
	LogStats("------------------------------------------------------------------------------------------------------");
	LogStats("");
	thePlayer.LogAllAbilities();
	LogStats("");
	LogStats("======================================================================================================");
	LogStats("================================= BALANCE STATS LOG -- ENDSS HERE ====================================");
	LogStats("======================================================================================================");
}

function Debug_stats(actor : CActor)
{
	var val : SAbilityAttributeValue;
	var tags : array<name>;
	var fVal1, fVal2, toxicityNoLock, lockedToxicity, temp, stamina : float;
	var i, size : int;
	var buffs : array<CBaseGameplayEffect>;
	var npc : CNewNPC;
	var tempString : string;
	var invChannels : array<EActorImmortalityChanel>;
	
	npc = (CNewNPC)actor;
	
	LogStats("");
	LogStats("  ----------------------------== Printing stats for <<" + actor + ">> ==----------------------------");
	
	
	tags = npc.GetTags();
	size = tags.Size();
	tempString = "Tags: ";
	for(i=0; i<size; i+=1)
	{
		tempString += NameToString(tags[i]) + ", ";
	}
	LogStats(tempString);
	
	
	LogStats("isAlive = " + actor.IsAlive());
	LogStats(" ");

	
	if(actor != thePlayer)
	{
		LogStats("Actor uses difficulty mode: " + actor.Debug_GetUsedDifficultyMode());
		LogStats(theGame.params.DIFFICULTY_HP_MULTIPLIER + " = " + NoTrailZeros(CalculateAttributeValue(actor.GetAttributeValue(theGame.params.DIFFICULTY_HP_MULTIPLIER))) );
		LogStats(theGame.params.DIFFICULTY_DMG_MULTIPLIER + " = " + NoTrailZeros(CalculateAttributeValue(actor.GetAttributeValue(theGame.params.DIFFICULTY_DMG_MULTIPLIER))) );
		LogStats(" ");
	}
	
	
	if(actor == GetWitcherPlayer())
	{
		LogStats("Level: " + GetWitcherPlayer().GetLevel());
		LogStats("XP to next level: " + GetWitcherPlayer().GetMissingExpForNextLevel());
		LogStats(" ");
	}
	else if(actor == GetReplacerPlayer())
	{
		LogStats("Level: " + GetReplacerPlayer().GetLevel());
	}
	else
	{
		LogStats("Level: " + (int)CalculateAttributeValue(actor.GetAttributeValue('level',,true)));
		LogStats("True Level: " + ((CNewNPC)actor).GetLevelFromLocalVar());
	}
	
	
	if(npc)
	{
		LogStats("XP for killing: " + npc.CalculateExperiencePoints(true));
		LogStats("");
	}
	
	
	LogStats( SpaceFill(BCS_Vitality,12) + " = " +  SpaceFill( NoTrailZeros(actor.GetStat(BCS_Vitality)), 7, ESFM_JustifyRight) + " / " + SpaceFill( NoTrailZeros(actor.GetStatMax(BCS_Vitality)), 7, ESFM_JustifyRight) );
	LogStats( SpaceFill(BCS_Essence,12) + " = " + SpaceFill( NoTrailZeros(actor.GetStat(BCS_Essence)), 7, ESFM_JustifyRight) + " / " + SpaceFill( NoTrailZeros(actor.GetStatMax(BCS_Essence)), 7, ESFM_JustifyRight) );
	
	stamina = actor.GetStat(BCS_Stamina);
	LogStats( SpaceFill(BCS_Stamina,12) + " = " + SpaceFill( NoTrailZeros(stamina), 7, ESFM_JustifyRight) + " / " + SpaceFill( NoTrailZeros(actor.GetStatMax(BCS_Stamina)), 7, ESFM_JustifyRight) );
	
	if(actor == GetWitcherPlayer())
	{
		toxicityNoLock = actor.GetStat(BCS_Toxicity, true);
		lockedToxicity = actor.GetStat(BCS_Toxicity) - toxicityNoLock;
		LogStats( SpaceFill(BCS_Toxicity,12) + " = " + SpaceFill( NoTrailZeros(toxicityNoLock), 7, ESFM_JustifyRight) + " / " + SpaceFill( NoTrailZeros(actor.GetStatMax(BCS_Toxicity)), 7, ESFM_JustifyRight) + ", lockedToxicity = " + NoTrailZeros(lockedToxicity) );
	}	
	
	LogStats( SpaceFill(BCS_Focus,12) + " = " + SpaceFill( NoTrailZeros(actor.GetStat(BCS_Focus)), 7, ESFM_JustifyRight) + " / " + SpaceFill( NoTrailZeros(actor.GetStatMax(BCS_Focus)), 7, ESFM_JustifyRight) );
	LogStats( SpaceFill(BCS_Morale,12) + " = " + SpaceFill( NoTrailZeros(actor.GetStat(BCS_Morale)), 7, ESFM_JustifyRight) + " / " + SpaceFill( NoTrailZeros(actor.GetStatMax(BCS_Morale)), 7, ESFM_JustifyRight) );
	LogStats( SpaceFill(BCS_Air,12) + " = " + SpaceFill( NoTrailZeros(actor.GetStat(BCS_Air)), 7, ESFM_JustifyRight) + " / " + SpaceFill( NoTrailZeros(actor.GetStatMax(BCS_Air)), 7, ESFM_JustifyRight) );	
	LogStats(" ");
	
	
	val = actor.GetPowerStatValue(CPS_AttackPower);
	LogStats("attack power: Base = " + SpaceFill(NoTrailZeros(val.valueBase), 4, ESFM_JustifyRight) + ", Mult = " + SpaceFill(NoTrailZeros(val.valueMultiplicative), 4, ESFM_JustifyRight) + ", Add = " + SpaceFill(NoTrailZeros(val.valueAdditive), 4, ESFM_JustifyRight) );
	val = actor.GetPowerStatValue(CPS_SpellPower);
	LogStats("spell power : Base = " + SpaceFill(NoTrailZeros(val.valueBase), 4, ESFM_JustifyRight) + ", Mult = " + SpaceFill(NoTrailZeros(val.valueMultiplicative), 4, ESFM_JustifyRight) + ", Add = " + SpaceFill(NoTrailZeros(val.valueAdditive), 4, ESFM_JustifyRight) );
	LogStats(" ");
	
	
	if(actor != thePlayer)
	{
		temp = CalculateAttributeValue(actor.GetAttributeValue(theGame.params.CRITICAL_HIT_CHANCE));
		LogStats("critical hit chance: " + NoTrailZeros(temp*100) + "%");
	}
	else
	{
		temp = thePlayer.GetCriticalHitChance( true, false, NULL, MC_NotSet, false );
		LogStats( "Fast Attack critical hit chance: " + NoTrailZeros( temp*100 ) + "%" );
		
		temp = thePlayer.GetCriticalHitChance( false, true, NULL, MC_NotSet, false );
		LogStats( "Heavy Attack critical hit chance: " + NoTrailZeros( temp*100 ) + "%" );
	}	
	
	if(actor != thePlayer)
	{
		val = actor.GetAttributeValue(theGame.params.CRITICAL_HIT_DAMAGE_BONUS);
	}
	else
	{
		val = thePlayer.GetCriticalHitDamageBonus(GetInvalidUniqueId(), MC_NotSet, false);
	}
	LogStats("critical hit damage bonus: +" + NoTrailZeros(CalculateAttributeValue(val) * 100) + "%");
	LogStats(" ");
	
	
	val = actor.GetAttributeValue(RegenStatEnumToName(CRS_Vitality));
	LogStats("Vitality Regen        :   Base = " + SpaceFill(NoTrailZeros(val.valueBase), 4, ESFM_JustifyRight)  + ",   Mult = " + SpaceFill(NoTrailZeros(val.valueMultiplicative), 4, ESFM_JustifyRight)  + ",   Add = " + SpaceFill(NoTrailZeros(val.valueAdditive), 4, ESFM_JustifyRight) );
	
	if(actor == thePlayer)
	{
		val = actor.GetAttributeValue('vitalityCombatRegen');
		LogStats("Combat Vitality Regen :   Base = " + SpaceFill(NoTrailZeros(val.valueBase), 4, ESFM_JustifyRight)  + ",   Mult = " + SpaceFill(NoTrailZeros(val.valueMultiplicative), 4, ESFM_JustifyRight)  + ",   Add = " + SpaceFill(NoTrailZeros(val.valueAdditive), 4, ESFM_JustifyRight) );
	}
	
	val = actor.GetAttributeValue(RegenStatEnumToName(CRS_Essence));
	LogStats("Essence Regen         :   Base = " + SpaceFill(NoTrailZeros(val.valueBase), 4, ESFM_JustifyRight)  + ",   Mult = " + SpaceFill(NoTrailZeros(val.valueMultiplicative), 4, ESFM_JustifyRight)  + ",   Add = " + SpaceFill(NoTrailZeros(val.valueAdditive), 4, ESFM_JustifyRight) );
	val = actor.GetAttributeValue(RegenStatEnumToName(CRS_Morale));
	LogStats("Morale Regen          :   Base = " + SpaceFill(NoTrailZeros(val.valueBase), 4, ESFM_JustifyRight)  + ",   Mult = " + SpaceFill(NoTrailZeros(val.valueMultiplicative), 4, ESFM_JustifyRight)  + ",   Add = " + SpaceFill(NoTrailZeros(val.valueAdditive), 4, ESFM_JustifyRight) );
	val = actor.GetAttributeValue(RegenStatEnumToName(CRS_Stamina));
	LogStats("Stamina Regen         :   Base = " + SpaceFill(NoTrailZeros(val.valueBase), 4, ESFM_JustifyRight)  + ",   Mult = " + SpaceFill(NoTrailZeros(val.valueMultiplicative), 4, ESFM_JustifyRight)  + ",   Add = " + SpaceFill(NoTrailZeros(val.valueAdditive), 4, ESFM_JustifyRight) );
	LogStats(" ");
	
	
	val = actor.GetTotalArmor();
	LogStats("Armor:   Base = " + NoTrailZeros(val.valueBase) + ",   Mult = " + NoTrailZeros(val.valueMultiplicative) + ",   Add = " + NoTrailZeros(val.valueAdditive));
	LogStats(" ");
	
	
	actor.GetResistValue(CDS_SlashingRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_SlashingRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	actor.GetResistValue(CDS_PiercingRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_PiercingRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	actor.GetResistValue(CDS_BludgeoningRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_BludgeoningRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	actor.GetResistValue(CDS_RendingRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_RendingRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	actor.GetResistValue(CDS_ElementalRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_ElementalRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	actor.GetResistValue(CDS_PhysicalRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_PhysicalRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	actor.GetResistValue(CDS_BleedingRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_BleedingRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	actor.GetResistValue(CDS_PoisonRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_PoisonRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	actor.GetResistValue(CDS_FireRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_FireRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	actor.GetResistValue(CDS_FrostRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_FrostRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	actor.GetResistValue(CDS_ShockRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_ShockRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	actor.GetResistValue(CDS_ForceRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_ForceRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	actor.GetResistValue(CDS_FreezeRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_FreezeRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	actor.GetResistValue(CDS_WillRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_WillRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	actor.GetResistValue(CDS_BurningRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_BurningRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	actor.GetResistValue(CDS_DoTBurningDamageRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_DoTBurningDamageRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	actor.GetResistValue(CDS_DoTPoisonDamageRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_DoTPoisonDamageRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	actor.GetResistValue(CDS_DoTBleedingDamageRes, fVal1, fVal2);
	LogStats( SpaceFill(CDS_DoTBleedingDamageRes, 31) + "Points = " + SpaceFill(NoTrailZeros(fVal1), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	
	
	LogStats("");
	val = actor.GetAttributeValue('critical_hit_damage_reduction');
	fVal2 = val.valueMultiplicative;
	LogStats( SpaceFill("critical_hit_damage_reduction", 31) + "Points = " + SpaceFill(NoTrailZeros(0.f), 7, ESFM_JustifyRight) + ", Percents = " + NoTrailZeros(fVal2*100));
	
	LogStats("Hit severity reduction = " + NoTrailZeros(CalculateAttributeValue(actor.GetAttributeValue('hit_severity'))) );
		
	
	LogStats("");
	LogStats("Buff immunitites:");
	size = (int)EET_EffectTypesSize ;
	for(i=0; i<size; i+=1)
	{
		if(actor.IsImmuneToBuff(i))
		{
			LogStats("* " + ((EEffectType)i));
		}
	}
	LogStats("");
	
	
	LogStats("Is invulnerable = " + actor.IsInvulnerable() );
	if(actor.IsInvulnerable())
	{
		invChannels = actor.GetImmortalityModeChannels(AIM_Invulnerable);
		tempString = "     Channels: ";
		for(i=0; i<invChannels.Size(); i+=1)
		{
			tempString += invChannels[i] + ", ";
		}
		LogStats(tempString);
	}
	LogStats("Is immortal = " + actor.IsImmortal() );
	if(actor.IsImmortal())
	{
		invChannels = actor.GetImmortalityModeChannels(AIM_Immortal);
		tempString = "     Channels: ";
		for(i=0; i<invChannels.Size(); i+=1)
		{
			tempString += invChannels[i] + ", ";
		}
		LogStats(tempString);
	}	
	
	
	LogStats("Hit severity reduction = " + NoTrailZeros(CalculateAttributeValue(actor.GetAttributeValue('hit_severity'))) );
	
	
	
	LogStats("");
	LogStats("Current buffs:");
	buffs = actor.GetBuffs();
	for(i=0; i<buffs.Size(); i+=1)
	{
		LogStats( SpaceFill( buffs[i].GetEffectType(), 25 ) + " isPaused= " + SpaceFill( buffs[i].IsPaused(),5,ESFM_JustifyRight ) + ", duration= " + SpaceFill( NoTrailZeros( buffs[i].GetDurationLeft() ), 9, ESFM_JustifyRight ) + " / " + SpaceFill( NoTrailZeros( buffs[i].GetInitialDurationAfterResists() ), 9, ESFM_JustifyRight ) );
	}
	
	LogStats(" ");
	LogStats("                    --== End of stats for <<" + actor + ">> ==--");
	LogStats(" ");
}

function Debug_Attributes(n : CActor)
{
	var dm : CDefinitionsManagerAccessor;
	var abs, atts : array<name>;
	var i : int;
	var val : SAbilityAttributeValue;
	var valF : float;

	if(!n)
		return;
		
	n.GetCharacterStats().GetAbilities(abs, true);
	dm = theGame.GetDefinitionsManager();
	atts = dm.GetAbilitiesAttributes(abs);
	
	LogStats("Printing non-forbidden attributes of <<" + n + ">>");
	LogStats("");
	for(i=0; i<atts.Size(); i+=1)
	{
		if(!theGame.params.IsForbiddenAttribute(atts[i]))
		{
			val = n.GetAttributeValue(atts[i]);
			valF = CalculateAttributeValue(val);
			LogStats(atts[i] + " = " + NoTrailZeros(valF));
		}
	}
}

exec function BlockRageOnTarget(lock : bool, optional time : float)
{
	var target : CActor;
	target = thePlayer.GetTarget();	
	
	if ( target )
	{
		target.BlockAbility('Rage',lock,time);
	}
}

exec function blockabilityontarget( abilityName : name )
{
	var target : CActor;
	target = thePlayer.GetTarget();	
	
	if ( target )
	{
		target.BlockAbility(abilityName,true);
	}
}

exec function testpause()
{
	theGame.Pause( "testpause" );
}

exec function testunpause()
{
	theGame.Unpause( "testpause" );
}

exec function testlosscontroller()
{
	theGame.GetGuiManager().SetIgnoreControllerDisconnectionEvents( false );
	theGame.GetGuiManager().OnControllerDisconnected();
}

exec function testregainedcontroller()
{
	theGame.GetGuiManager().OnControllerReconnected();
}

exec function testdlcinstalled()
{
	theGame.GetGuiManager().DisplayNewDlcInstalled( "Hoho! New DLC installed" );
}
	
exec function dodge()
{
	var target : CActor;
	target = thePlayer.GetTarget();	
	if ( target )
	{
		target.SignalGameplayEventParamInt('Time2Dodge', (int)EDT_Projectile );	
	}
}

exec function dcc()
{
	thePlayer.AddTimer('Debug_DelayedConsoleCommand', 3);
}


exec function spawnRaw( nam : name, optional quantity : int, optional distance : float, optional isHostile : bool ) 
{
	var ent : CEntity;
	var horse : CEntity;
	var pos, cameraDir, player, normal : Vector;
	var rot : EulerAngles;
	var i : int;
	var template : CEntityTemplate;
	var horseTemplate : CEntityTemplate;
	var horseTag : array<name>;
	var l_aiTree		: CAIHorseDoNothingAction;
	
	quantity = Max(quantity, 1);
	
	rot = thePlayer.GetWorldRotation();	
	if(nam != 'boat')
	{
		rot.Yaw += 180;		
	}
	
	
	cameraDir = theCamera.GetCameraDirection();
	
	if( distance == 0 ) distance = 3; 
	cameraDir.X *= distance;	
	cameraDir.Y *= distance;
	
	
	player = thePlayer.GetWorldPosition();
	
	
	pos 	= cameraDir + player;	
	pos.Z = player.Z;
	
	
	template = (CEntityTemplate)LoadResource(nam);
	
	if ( nam == 'rider' ) 
		horseTemplate = (CEntityTemplate)LoadResource('horse');
		
	for(i=0; i<quantity; i+=1)
	{		
		ent = theGame.CreateEntity(template, pos, rot);
		
		if ( horseTemplate )
		{
			horseTag.PushBack('enemy_horse');
			horse = theGame.CreateEntity(horseTemplate, pos, rot,true,false,false,PM_DontPersist,horseTag);
			l_aiTree = new CAIHorseDoNothingAction in ent;
			l_aiTree.OnCreated();
			((CActor)ent).ForceAIBehavior( l_aiTree, BTAP_AboveEmergency2, 'AI_Rider_Load_Forced' );
			((CActor)ent).SignalGameplayEventParamInt( 'RidingManagerMountHorse', MT_instant | MT_fromScript );
			
		}
			
		if( isHostile )
		{
			((CActor)ent).SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
		}
	}
}

exec function spawnBoat000()
{
	var nam : name;
	var ent : CEntity;
	var pos : Vector;
	var rot : EulerAngles;
	var template : CEntityTemplate;
	
	nam = 'boat';
	rot = EulerAngles( 0.0f, 0.0f, 0.0f );
	pos = Vector( 0.0f, 0.0f, 0.0f, 1.0f );
	
	template = (CEntityTemplate)LoadResource(nam);
	ent = theGame.CreateEntity(template, pos, rot, true, false, false, PM_Persist );
}

exec function spawnPath(path : name, optional isHostile : bool)
{
	var ent : CEntity;
	var pos : Vector;
	var rot : EulerAngles;
	var template : CEntityTemplate;
	
	rot = thePlayer.GetWorldRotation();	
	rot.Yaw += 180;
	pos = thePlayer.GetWorldPosition();
	pos += VecConeRand(thePlayer.GetHeading(), 0, 3, 3);
	
	template = (CEntityTemplate)LoadResource(path,true);
	ent = theGame.CreateEntity(template, pos, rot);
	
	if( isHostile )
	{
		((CActor)ent).SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
	}
	else
	{
		((CActor)ent).SetTemporaryAttitudeGroup( 'friendly_to_player', AGP_Default );
	}
}

exec function spawn(nam : name, optional quantity : int, optional distance : float, optional isHostile : bool, optional level : int )
{
	var ent : CEntity;
	var horse : CEntity;
	var pos, cameraDir, player, posFin, normal, posTemp : Vector;
	var rot : EulerAngles;
	var i, sign : int;
	var s,r,x,y : float;
	var template : CEntityTemplate;
	var horseTemplate : CEntityTemplate;
	var horseTag : array<name>;
	var resourcePath	: string;
	var l_aiTree		: CAIHorseDoNothingAction;
	var templateCSV : C2dArray;
	quantity = Max(quantity, 1);
	
	rot = thePlayer.GetWorldRotation();	
	if(nam != 'boat')
	{
		rot.Yaw += 180;		
	}
	
	
	cameraDir = theCamera.GetCameraDirection();
	
	if( distance == 0 ) distance = 3; 
	cameraDir.X *= distance;	
	cameraDir.Y *= distance;
	
	
	player = thePlayer.GetWorldPosition();
	
	
	pos = cameraDir + player;	
	pos.Z = player.Z;
	
	
	posFin.Z = pos.Z;			
	s = quantity / 0.2;			
	r = SqrtF(s/Pi());
	
	
	template = (CEntityTemplate)LoadResource(nam);
	
	if ( nam == 'rider' ) 
		horseTemplate = (CEntityTemplate)LoadResource('horse');
		
	if(!template)
	{
		resourcePath = "characters\npc_entities\monsters";
		resourcePath = resourcePath + NameToString(nam);
		resourcePath = resourcePath + ".w2ent";
		template = (CEntityTemplate)LoadResource( resourcePath, true );
	}
	
	if( nam == 'def' )
	{
		templateCSV = LoadCSV("gameplay\globals\temp_spawner.csv");
		
		resourcePath = templateCSV.GetValueAt(0,0);
		template = (CEntityTemplate)LoadResource( resourcePath, true );
	}

	for(i=0; i<quantity; i+=1)
	{		
		x = RandF() * r;			
		y = RandF() * (r - x);		
		
		if(RandRange(2))					
			sign = 1;
		else
			sign = -1;
			
		posFin.X = pos.X + sign * x;	
		
		if(RandRange(2))					
			sign = 1;
		else
			sign = -1;
			
		posFin.Y = pos.Y + sign * y;	
		
		if(nam == 'boat')
		{
			posFin.Z = 0.0f;
		}
		else
		{
			if(theGame.GetWorld().StaticTrace( posFin + Vector(0,0,5), posFin - Vector(0,0,5), posTemp, normal ))
			{
				posFin = posTemp;
			}
		}
		
		if( nam == 'boat' )
		{
			ent = theGame.CreateEntity(template, posFin, rot, true, false, false, PM_Persist );
		}
		else
		{
			ent = theGame.CreateEntity(template, posFin, rot);
		}
		
		if ( horseTemplate )
		{
			horseTag.PushBack('enemy_horse');
			horse = theGame.CreateEntity(horseTemplate, posFin, rot,true,false,false,PM_DontPersist,horseTag);
			
			
			
			
			l_aiTree = new CAIHorseDoNothingAction in ent;
			l_aiTree.OnCreated();
			((CActor)ent).ForceAIBehavior( l_aiTree, BTAP_AboveEmergency2, 'AI_Rider_Load_Forced' );
			
			((CActor)ent).SignalGameplayEventParamInt( 'RidingManagerMountHorse', MT_instant | MT_fromScript );
		}
			
		if( isHostile )
		{
			((CActor)ent).SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
		}
			
		if ( level != 0 )
		{
			((CNewNPC)ent).SetLevel( level );
		}
	}
}
exec function likeaboss()
{
	if(FactsQuerySum('player_is_the_boss') > 0)
	{
		FactsRemove('player_is_the_boss');
		LogCheats( "Like a Boss is now OFF" );
	}
	else
	{
		FactsAdd('player_is_the_boss');
		LogCheats( "Like a Boss is now ON" );
	}
}

exec function dismounttest()
{
	var target : CActor;
	target = thePlayer.GetTarget();	
	
	if( target )
	{
		target.SignalGameplayEvent('DismountTheHorse');
	}
}

exec function sfmh()
{
	
	var results : array< CGameplayEntity >;
	var size : int;
	var i : int;
	
	FindGameplayEntitiesInRange( results, thePlayer, 20, 100 );
	size = results.Size();
	
	for( i = 0; i <= size; i += 1 )
	{
		
		
		((CNewNPC)results[i]).RaiseForceEvent( 'FocusHit' );
		((CNewNPC)results[i]).SetBehaviorVariable( 'FlySpeed', 0 );
		((CNewNPC)results[i]).SetBehaviorVariable( 'npcStance', 4 );
		((CMovingPhysicalAgentComponent)((CNewNPC)results[i]).GetMovingAgentComponent()).SetAnimatedMovement( false );
	}
}


exec function panic()
{
	
	var results : array< CGameplayEntity >;
	var size : int;
	var i : int;
	
	FindGameplayEntitiesInRange( results, thePlayer, 30, 100 );
	size = results.Size();
	
	for( i = 0; i <= size; i += 1 )
	{
		((CNewNPC)results[i]).DrainMorale(100);
	}
}

exec function freeze(optional off : int, optional range : float, optional tag : name)
{
	var i : int;
	var npcs : array<CActor>;

	if(range <= 0)
		range = 10;
	npcs = thePlayer.GetNPCsAndPlayersInRange(range,1000000,tag);
	for(i=0; i<npcs.Size(); i+=1)
	{
		if((CPlayer)npcs[i])
			continue;		
		if(off)
			npcs[i].AddEffectDefault(EET_Stagger, NULL, 'console');
		else
			npcs[i].SignalGameplayEvent('CombatFocusMode');			
	}
}


exec function twt()
{
	var target : CNewNPC; 

	target = theGame.GetNPCByTag( 'tgt' );
	thePlayer.SetUnpushableTarget( target ); 
}

exec function twr()
{
	var target : CNewNPC; 

	thePlayer.SetUnpushableTarget( target ); 
}


exec function ut()
{
	var target : CActor;
	target = thePlayer.GetTarget();

	if( target )
	{
		thePlayer.SetUnpushableTarget( target ); 
	}
}

exec function setpri( tag : name, value : int )
{
	var target : CNewNPC; 

	target = theGame.GetNPCByTag( tag );
	target.SetInteractionPriority( value );
}

exec function setcol( value : bool )
{
	thePlayer.EnableCharacterCollisions( value );
}

exec function addpotions()
{
	var inv : CInventoryComponent;
	var arr : array<SItemUniqueId>;
	
	inv = thePlayer.inv;
	arr = inv.AddAnItem('Black Blood 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Black Blood 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Black Blood 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Blizzard 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Blizzard 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Blizzard 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cat 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cat 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cat 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Full Moon 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Full Moon 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Full Moon 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Golden Oriole 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Golden Oriole 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Golden Oriole 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Killer Whale 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Maribor Forest 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Maribor Forest 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Maribor Forest 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Petri Philtre 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Petri Philtre 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Petri Philtre 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Swallow 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Swallow 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Swallow 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Tawny Owl 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Tawny Owl 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Tawny Owl 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Thunderbolt 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Thunderbolt 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Thunderbolt 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Honey 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Honey 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Honey 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Raffards Decoction 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Raffards Decoction 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('White Raffards Decoction 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
}

exec function addoils()
{
	var inv : CInventoryComponent;
	var arr : array<SItemUniqueId>;
	
	inv = thePlayer.inv;
	
	arr = inv.AddAnItem('Beast Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Beast Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Beast Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cursed Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cursed Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Cursed Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hanged Man Venom 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hanged Man Venom 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hanged Man Venom 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hybrid Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hybrid Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Hybrid Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Insectoid Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Insectoid Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Insectoid Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Magicals Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Magicals Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Magicals Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Necrophage Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Necrophage Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Necrophage Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Specter Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Specter Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Specter Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Vampire Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Vampire Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Vampire Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Draconide Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Draconide Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Draconide Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Ogre Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Ogre Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Ogre Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Relic Oil 1');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Relic Oil 2');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
	arr = inv.AddAnItem('Relic Oil 3');
	thePlayer.inv.SingletonItemSetAmmo(arr[0], thePlayer.inv.SingletonItemGetMaxAmmo(arr[0]));
}

exec function logskills()
{
	var i, size : int;
	var bullshit : ESkill;

	size = EnumGetMax('ESkill')+1;
	LogSkills("");
	LogSkills("Printing player acquired skills, perks and bookperks:");
	for(i=0; i<size; i+=1)
	{
		if(thePlayer.HasLearnedSkill(i))
		{
			bullshit = i;
			LogSkills(bullshit + ", isEquipped=" + thePlayer.IsSkillEquipped(i) + ", canUse=" + thePlayer.CanUseSkill(i));
		}
	}
	LogSkills("");
}

exec function obstacle()
{
	var target : CActor;

	target = thePlayer.GetTarget();
	if( target )
	{
		target.SignalGameplayEvent('CollisionWithObstacle');
	}
}

exec function addstat(stat : EBaseCharacterStats, val : float)
{
	if(stat == BCS_Vitality)
	{
		thePlayer.ForceSetStat(stat, val + thePlayer.GetStat(stat));
	}
	else
	{
		thePlayer.GainStat(stat, val);
	}
}

exec function drainstat(stat : EBaseCharacterStats, val : float)
{
	switch(stat)
	{
		case BCS_Stamina :
			thePlayer.DrainStamina(ESAT_FixedValue, val, 1);
			break;
		case BCS_Toxicity : 
			thePlayer.DrainToxicity(val);
			break;
		case BCS_Focus : 
			thePlayer.DrainFocus(val);
			break;
		case BCS_Morale : 
			thePlayer.DrainMorale(val);
			break;
		case BCS_Air : 
			thePlayer.DrainAir(val);
			break;
	}
}

exec function printbuffs()
{
	var buffs : array<CBaseGameplayEffect>;
	var i : int;
	
	buffs = thePlayer.GetBuffs();
	LogEffects("--------- Printing player buffs:");
	
	for(i=0; i<buffs.Size(); i+=1)
		LogEffects(buffs[i] + "         time left = " + NoTrailZeros(buffs[i].GetDurationLeft()) );
	
	LogEffects("--------- Done");
}

exec function spawnenemy()
{
	var template : CEntityTemplate;
	var pos : Vector;
	var rot : EulerAngles;
	
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	rot = VecToRotation(thePlayer.GetWorldPosition() - pos);
	
	template = (CEntityTemplate)LoadResource("1hand");
	theGame.CreateEntity(template, pos, rot );
}

exec function ApproachAttack( i : int)
{
	var player : CR4Player;
	
	player = thePlayer;
	player.approachAttack = i;
}

exec function TReset()
{
	var gameTime : GameTime;
	
	gameTime = GameTimeCreate( 1, 14, 2 );
	
	theGame.SetGameTime(gameTime, false);
	
	theGame.SetHoursPerMinute( 1 );
	
	
}

exec function HPM(hpm : int)
{
	theGame.SetHoursPerMinute(hpm);
}

exec function weak()
{
	if(FactsDoesExist("debug_fact_weak"))
	{
		FactsRemove("debug_fact_weak");
		LogCheats( "Weak is now OFF" );
	}
	else
	{
		FactsAdd("debug_fact_weak");	
		LogCheats( "Weak is now ON" );
	}
}

exec function instantMount( vehicleTag : name )
{
	var entities : array<CGameplayEntity>;
	var entity : CGameplayEntity;
	var vehicle : CVehicleComponent;
	
	FindGameplayEntitiesInRange(entities,thePlayer,1000,1,vehicleTag);
	entity = entities[0];
	
	if ( entity )
	{
		vehicle = (CVehicleComponent)(entity.GetComponentByClassName('CVehicleComponent'));
		if ( vehicle )
		{
			vehicle.Mount( thePlayer, VMT_ImmediateUse, EVS_driver_slot );
		}
	}
}

exec function mute()
{
	theSound.EnterGameState(ESGS_Movie);
}
exec function unmute()
{
	theSound.EnterGameState(ESGS_Default);
}

class ARDebugCameraRot extends ICustomCameraScriptedPivotRotationController
{
	protected function ControllerUpdate( out currentRotation : EulerAngles, out currentVelocity : EulerAngles, timeDelta : float )
	{
		currentRotation.Pitch = -89;
		currentRotation.Yaw = 0;
		currentRotation.Roll = 0;
	}
	protected function ControllerUpdateInput( out movedHorizontal : bool, out movedVertical : bool )
	{
		movedHorizontal = true;
		movedVertical = false;
	}
}

class ARDebugCameraDist extends ICustomCameraScriptedPivotDistanceController
{
	protected function ControllerUpdate( out currDistance : float, out currVelocity : float, timeDelta : float )
	{
		currDistance = 8;
	}
}



exec function arcam()
{ 
	
	theGame.GetGameCamera().ChangePivotRotationController('Debug_AR_Test_Cam_Rot');
	theGame.GetGameCamera().ChangePivotDistanceController('Debug_AR_Test_Cam_Dist');
}

exec function imback()
{
	thePlayer.CheatResurrect();
}

exec function idoeverything()
{
	
	thePlayer.Dbg_UnlockAllActions();
	thePlayer.SetIsMovable( true );
}

exec function resurrect()
{
	thePlayer.CheatResurrect();
	theInput.RestoreContext( 'Exploration', true );
	theGame.ReleaseNoSaveLock(theGame.deathSaveLockId);
}

exec function cleardevelop()
{
	GetWitcherPlayer().Debug_ClearCharacterDevelopment();
}

exec function appearance( app : name )
{
	var npc : CActor;
	npc = thePlayer.GetTarget();
	
	if( npc )
	{
		npc.SetAppearance( app );
	}
}

exec function InputLogging( val : bool )
{
	theInput.EnableLog(val);
}

exec function testdur()
{
	var inv				: CInventoryComponent;
	var items1			: array< SItemUniqueId >;
	var items2			: array< SItemUniqueId >;
	var allItems		: array< SItemUniqueId >;
	var	i				: int;

	inv = thePlayer.inv;

	items1 = inv.GetItemsByCategory( 'steelsword' );
	items2 = inv.GetItemsByCategory( 'silversword' );
	
	ArrayOfIdsAppend( allItems, items1 );
	ArrayOfIdsAppend( allItems, items2 );

	for ( i = 0; i < allItems.Size(); i += 1 )
	{
		LogChannel( 'Durability', "---------------------------------------");
		LogChannel( 'Durability', "Item '" + inv.GetItemName( allItems[ i ] ) + "', has durability? " + inv.HasItemDurability( allItems[ i ] ));

		LogChannel( 'Durability', "   Current durability " + inv.GetItemDurability( allItems[ i ] ) );
		LogChannel( 'Durability', "   Initial durability " + inv.GetItemInitialDurability( allItems[ i ] ) );
		LogChannel( 'Durability', "   Max durability     " + inv.GetItemMaxDurability( allItems[ i ] ) );
		if ( inv.HasItemDurability( allItems[ i ] ) )
		{
			LogChannel( 'Durability', "   Setting current durability to max..." );
			inv.SetItemDurabilityScript( allItems[ i ], inv.GetItemMaxDurability( allItems[ i ] ) );
			LogChannel( 'Durability', "   Current durability " + inv.GetItemDurability( allItems[ i ] ) );
		}
		else
		{
			LogChannel( 'Durability', "   Setting current durability to max... that doesn't make sense, but we can try" );
			inv.SetItemDurabilityScript( allItems[ i ], inv.GetItemMaxDurability( allItems[ i ] ) );
			LogChannel( 'Durability', "   Current durability " + inv.GetItemDurability( allItems[ i ] ) );
		}
	}
}


exec function incdur( item : name, val : int )
{
	var inv				: CInventoryComponent;
	var items			: array< SItemUniqueId >;
	
	inv = thePlayer.inv;

	items = inv.AddAnItem( item );
	
	inv.SetItemDurabilityScript(items[0], val);
}


exec function decdur( val : int )
{
	var inv				: CInventoryComponent;
	var items1			: array< SItemUniqueId >;
	var items2			: array< SItemUniqueId >;
	var items3			: array< SItemUniqueId >;
	var allItems		: array< SItemUniqueId >;
	var	i,j				: int;

	inv = thePlayer.inv;

	items1 = inv.GetItemsByCategory( 'steelsword' );
	items2 = inv.GetItemsByCategory( 'silversword' );
	items3 = inv.GetItemsByCategory( 'armor' );

	ArrayOfIdsAppend( allItems, items1 );
	ArrayOfIdsAppend( allItems, items2 );
	ArrayOfIdsAppend( allItems, items3 );

	for ( j = 0; j < val; j+=1 )
	{
		for ( i = 0; i < allItems.Size(); i += 1 )
		{
			if ( inv.HasItemDurability( allItems[ i ] ) )
			{
				inv.ReduceItemDurability( allItems[ i ] );
			}
		}
	}
}



exec function buffme( type : EEffectType, optional duration : float, optional src : name )
{
	var params : SCustomEffectParams;

	if(duration > 0)
	{
		params.effectType = type;
		params.sourceName = src;
		params.duration = duration;
		thePlayer.AddEffectCustom(params);
	}
	else
	{
		thePlayer.AddEffectDefault(type, NULL, src);
	}
}

exec function addtorch()
{
	thePlayer.inv.AddAnItem('Torch');
	thePlayer.inv.AddAnItem('q103_bell');
}

exec function spawnpukespot()
{
	var ent : CEntity;
	var tags : array< name >;
	var template : CEntityTemplate;
	
	tags = ent.GetTags();
	tags.PushBack( 'dudes' );
	
	template = (CEntityTemplate)LoadResource("stand_puke");
	ent = theGame.CreateEntity(template, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation(), true, false, false, PM_DontPersist,  tags );
}

exec function durr()
{
	var ids : array<SItemUniqueId>;
	var sword : SItemUniqueId;
		
	GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, sword);
	
	damageitem_g(EES_SteelSword, 0.5);
	LogItems("durr: before = " + thePlayer.inv.GetItemDurability(sword));
	ids = thePlayer.inv.AddAnItem('Weapon repair kit 1');
	thePlayer.RepairItemUsingConsumable(sword, ids[0]);
	LogItems("durr: after = " + thePlayer.inv.GetItemDurability(sword));
}	

exec function spawnbarrel()
{
	var ent : CEntity;
	var template : CEntityTemplate;
	
	template = (CEntityTemplate)LoadResource("barrel");
	ent = theGame.CreateEntity(template, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
}

exec function spawnbarrels()
{
	var ent : CEntity;
	var pos : Vector;
	var template : CEntityTemplate;
	
	pos = thePlayer.GetWorldPosition();
	pos.Z += 3;
	template = (CEntityTemplate)LoadResource( "barrel");
	
	pos.X += 4;
	pos.Y += 4;
	ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
	
	pos.X -= 4;
	pos.Y += 4;
	ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
	
	pos.X += 4;
	pos.Y -= 4;
	ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
	
	pos.X -= 4;
	pos.Y -= 4;
	ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
	
	pos.X += 6;
	pos.Y += 6;
	ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
	
	pos.X -= 6;
	pos.Y += 6;
	ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
	
	pos.X += 6;
	pos.Y -= 6;
	ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
	
	pos.X -= 6;
	pos.Y -= 6;
	ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
}

exec function spawnbees()
{
	var ent : CEntity;
	var pos : Vector;
	var template : CEntityTemplate;
	
	pos = thePlayer.GetWorldPosition();
	pos.Z += 4;
	template = (CEntityTemplate)LoadResource( "beehive");
	
	ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
	
	pos.X += 8;
	ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
	
	pos.Y += 8;
	ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
	
	pos.X -= 8;
	ent = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation() );
}

exec function damageboat(dmg : float, index : int)
{
	((CBoatDestructionComponent)thePlayer.GetUsedVehicle().GetComponentByClassName('CBoatDestructionComponent')).DealDamage(dmg, index);
}

exec function iu()
{
	var um : W3ItemUpgradeManager;
	var ids : array<SItemUniqueId>;
	
	um = new W3ItemUpgradeManager in theGame;
	um.Init();
	
	thePlayer.AddMoney(10000);
	thePlayer.inv.AddAnItem('Iron ore', 100);
	thePlayer.inv.AddAnItem('Silver mineral', 100);
	
	ids = thePlayer.inv.GetItemsIds('Witcher Silver Sword');
	
	um.PurchaseUpgrade(ids[0], 'Damage 2');
}

exec function RainStrength()
{
	var rainStrength : float = 1;
	rainStrength = GetRainStrength();
	Log( "Rain strength: " + rainStrength );
}


exec function MegaBomb()
{	
	var angle : float;
	var velocity : float;
	var range : float;
	var i : int;
	
	var projectile : CProjectileTrajectory;
	var collisionGroups : array<name>;
	var target: Vector;
	var rot : EulerAngles;
	var step : float;
	var template : CEntityTemplate;
	
	angle = 90.0f;
	velocity = 20.0f;
	range = 100.0f;
	step = 5.0f;
	
	collisionGroups.PushBack('Terrain');
	collisionGroups.PushBack('Static');
	
	rot = thePlayer.GetWorldRotation();
	
	for( i=0; i<180; i+=(int)step )
	{	
		target = VecNormalize( Vector( CosF(rot.Yaw), SinF(rot.Yaw), 0.0f ) );
		target *= range*0.25f;
		target += thePlayer.GetWorldPosition();
		
		template = (CEntityTemplate)LoadResource("grapeshot");
		projectile = (CProjectileTrajectory) theGame.CreateEntity(template, thePlayer.GetWorldPosition() + Vector(0,0,30), thePlayer.GetWorldRotation() );

		projectile.Init( thePlayer );
		projectile.ShootProjectileAtPosition( angle, velocity, target, range, collisionGroups );
		
		angle -= step;
		if( angle < -90.0f )
			angle = 90.0f;
		
	}
}

exec function LogInputContext()
{	
	LogInput(theInput.GetContext() );
}

exec function ResetInput()
{
	thePlayer.Debug_ResetInput();
}

exec function spawnwh()
{
	var template : CEntityTemplate;

	template = (CEntityTemplate)LoadResource("wh");
	theGame.CreateEntity(template, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
}

exec function AddAttackMult()
{
	thePlayer.AddAbility('GeraltMult');
}

function AddAndEquipSkill(skill : ESkill) : bool
{
	var slot : int;

	GetWitcherPlayer().AddSkill(skill);  
	slot = GetWitcherPlayer().GetFreeSkillSlot();
	if(slot > -1)
	{
		GetWitcherPlayer().EquipSkill(skill, slot);
		return true;
	}
	
	return false;
}

exec function FB( level : int )
{	
	if ( level <= 1 )
	{
		thePlayer.AddAbility('Lvl10');
		
		
		
	}
	if ( level == 2 )
	{
		thePlayer.AddAbility('Lvl20');
		
		
		
	}
	if ( level == 3 )
	{
		thePlayer.AddAbility('Lvl30');
		
		
		
	}
	if ( level >= 4 )
	{
		thePlayer.AddAbility('Lvl40');
		
		
		
	}
}

exec function ActivateTeleport( teleportTag : name )
{
	var teleportEntity : CTeleportEntity;
	teleportEntity = ( CTeleportEntity )( theGame.GetEntityByTag( teleportTag ) );
	
	if( !teleportEntity )
			LogChannel( 'Error', "Teleport not set properly in ManageTeleport quest function." );

	teleportEntity.ActivateTeleport( 0.5 );
}

exec function RunGossip()
{
	theGame.GetBehTreeReactionManager().InitReactionScene( thePlayer, 'Gossip', 5.0, 30.0f, 1000.0f, 2 );			
}

exec function debugtp()
{
	thePlayer.TeleportWithRotation( thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
}

exec function OpenRift( tag : name )
{
	var rift : CRiftEntity;
	
	rift = (CRiftEntity)( theGame.GetNodeByTag( tag ) );
	rift.ActivateRift();
}

exec function CloseRift( tag : name )
{
	var rift : CRiftEntity;
	
	rift = (CRiftEntity)( theGame.GetNodeByTag( tag ) );
	rift.DeactivateRift();
}

exec function Ragdoll( tag : name )
{
	var dude : CActor;
	var target : CActor;
	
	target = thePlayer.GetTarget();	
	
	dude = (CActor)( theGame.GetNodeByTag( tag ) );
	if( dude )
	{
		dude.AddEffectDefault(EET_Ragdoll, NULL);
	}
	else if ( target )
	{
		target.AddEffectDefault(EET_Ragdoll, NULL);
	}
}

exec function omnom(optional level : int)
{
	var ids : array<SItemUniqueId>;

	if(level < 2)
		ids = thePlayer.inv.AddAnItem('Raw meat');
	else if(level == 2)
		ids = thePlayer.inv.AddAnItem('Very good honey');
	else 
		ids = thePlayer.inv.AddAnItem('Toffee');
		
	thePlayer.ConsumeItem(ids[0]);
}

exec function stagger( tag : name )
{
	var dude : CActor;
	
	dude = (CActor)( theGame.GetNodeByTag( tag ) );
	if( dude )
		dude.AddEffectDefault(EET_Stagger, NULL);
}

exec function printstate()
{
	LogStates("--== Current player state is <<" + thePlayer.GetCurrentStateName() + ">> ==--");
}

exec function SetEasy()
{
	temp_difflevel(EDM_Easy);
}
exec function SetMedium()
{
	temp_difflevel(EDM_Medium);
}
exec function SetHard()
{
	temp_difflevel(EDM_Hard);
}
exec function SetHardcore()
{
	temp_difflevel(EDM_Hardcore);
}

exec function difflevel(i : EDifficultyMode)
{
	temp_difflevel(i);
}


function temp_difflevel(i : EDifficultyMode)
{
	theGame.SetDifficultyLevel(i);
	theGame.OnDifficultyChanged(i);
}

exec function printdiff()
{
	LogStats("Current difficulty mode is: " + theGame.GetDifficultyMode() );
}

exec function BlockAb( actorTag : name, abilityName : name )
{
	var actor : CActor;
	
	actor = ( CActor )( theGame.GetEntityByTag( actorTag ) );
	if( !actor )
		LogChannel( 'Error', "Actor not found in BlockAb exec function." );
	
	actor.BlockAbility( abilityName, true);
}

exec function criticalboy()
{
	if( FactsQuerySum( 'debug_fact_critical_boy' ) > 0 )
	{
		FactsRemove( 'debug_fact_critical_boy' );
		LogCheats( "Critical Boy is now OFF" );
	}
	else
	{
		FactsAdd( 'debug_fact_critical_boy' );
		LogCheats( "Critical Boy is now ON" );
	}
}


exec function ProfilerInit( bufforSize : int )
{
	PROFILER_Init(bufforSize);	
}

exec function ProfilerInitEx( bufforSize : int, bufforSignalsSize : int )
{
	PROFILER_InitEx(bufforSize,bufforSignalsSize);	
}

exec function ProfilerInitMB( bufforSize : int )
{
	PROFILER_Init(bufforSize*1024*1024);	
}

exec function ProfilerInitExMB( bufforSize : int, bufforSignalsSize : int )
{
	PROFILER_InitEx(bufforSize*1024*1024,bufforSignalsSize*1024*1024);	
}

exec function ProfilerScriptEnable()
{
	PROFILER_ScriptEnable();	
}

exec function ProfilerScriptDisable()
{
	PROFILER_ScriptDisable();	
}

exec function ProfilerStart()
{
	PROFILER_Start();	
}

exec function ProfilerStop()
{
	PROFILER_Stop();	
}

exec function ProfilerStore( profileName : string )
{
	PROFILER_Store( profileName );	
}

exec function ProfilerStoreDef()
{
	PROFILER_StoreDef();	
}

exec function ProfilerStoreInstrFuncList()
{
	PROFILER_StoreInstrFuncList();	
}

exec function ProfilerStartCatchBr()
{
	PROFILER_StartCatchBreakpoint();	
}

exec function ProfilerStopCatchBr()
{
	PROFILER_StopCatchBreakpoint();	
}

exec function ProfilerSetTimeBr( instrFuncName : string, time : float, stopOnce : bool )
{
	PROFILER_SetTimeBreakpoint( instrFuncName, time, stopOnce );	
}

exec function ProfilerSetHitCountBr( instrFuncName : string, counter : int )
{
	PROFILER_SetHitCountBreakpoint( instrFuncName, counter );	
}

exec function ProfilerDisableTimeBr( instrFuncName : string )
{
	PROFILER_DisableTimeBreakpoint( instrFuncName );	
}

exec function ProfilerDisableHitCountBr( instrFuncName : string )
{
	PROFILER_DisableHitCountBreakpoint( instrFuncName );	
}

exec function MoveToPlayer( speed:float, optional actorTag:name )
{
	var i :int;
	var l_actor 		: CActor;
	var l_actors		: array<CActor>;
	var l_aiTree		: CAIMoveToAction;
	
	l_actors = GetActorsInRange( thePlayer, 1000, 99, actorTag );
	
	l_aiTree = new CAIMoveToAction in l_actor;
	l_aiTree.OnCreated();
	
	l_aiTree.params.targetTag = 'PLAYER';
	l_aiTree.params.moveSpeed = speed;
	l_aiTree.params.rotateAfterwards = false;
	
	if( speed > 1 )
	{
		l_aiTree.params.moveType = MT_Run;
	}
	
	for	( i = 0; i < l_actors.Size(); i+= 1 )
	{
		l_actor = (CActor) l_actors[i];
		l_actor.ForceAIBehavior( l_aiTree, BTAP_Emergency);
	}
}

exec function MoveToPoint( speed:float, waypointTag:name, optional actorTag:name )
{
	var i :int;
	var l_actor 		: CActor;
	var l_actors		: array<CActor>;
	var l_aiTree		: CAIMoveToAction;
	
	l_actors = GetActorsInRange( thePlayer, 1000, 99, actorTag );
	
	l_aiTree = new CAIMoveToAction in l_actor;
	l_aiTree.OnCreated();
	
	l_aiTree.params.targetTag = waypointTag;
	l_aiTree.params.moveSpeed = speed;
	l_aiTree.params.rotateAfterwards = false;
	
	if( speed > 1 )
	{
		l_aiTree.params.moveType = MT_Run;
	}
	
	for	( i = 0; i < l_actors.Size(); i+= 1 )
	{
		l_actor = (CActor) l_actors[i];
		l_actor.ForceAIBehavior( l_aiTree, BTAP_Emergency);
	}
}

exec function MoveAlongPath( speed : float, pathTag : name, optional actorTag : name )
{
	var i :int;
	var l_actor 		: CActor;
	var l_actors		: array<CActor>;
	var l_aiTree		: CAIMoveAlongPathAction;
	
	l_actors = GetActorsInRange( thePlayer, 1000, 99, actorTag );
	
	l_aiTree = new CAIMoveAlongPathAction in l_actor;
	l_aiTree.OnCreated();
	
	l_aiTree.params.pathTag = pathTag;
	
	if( speed > 1 )
	{
		l_aiTree.params.moveType = MT_Run;
	}
	else
	{
		l_aiTree.params.moveType = MT_Walk;
	}
	
	for	( i = 0; i < l_actors.Size(); i+= 1 )
	{
		l_actor = (CActor) l_actors[i];
		l_actor.ForceAIBehavior( l_aiTree, BTAP_Emergency);
	}
}


exec function nopolice()
{
	FactsRemove( "guards_alerted" );
}

exec function testdrownerswimming( optional actorTag : name )
{
	var i :int;
	var l_actor 		: CActor;
	var l_actors		: array<CActor>;
	
	l_actors = GetActorsInRange( thePlayer, 50, 99, actorTag );
	for	( i = 0; i < l_actors.Size(); i+= 1 )
	{
		l_actors[i].SignalGameplayEvent('TestDrownerSwimming');
	}
}

exec function dismantle()
{
	var sw, dk : array<SItemUniqueId>;

	sw = thePlayer.inv.AddAnItem('Witcher Silver Sword');
	dk = thePlayer.inv.AddAnItem('Dismantle Kit');
	GetWitcherPlayer().DismantleItem(sw[0], dk[0]);
}

exec function Skate()
{	
	thePlayer.GotoState('Skating');
}

exec function AltCombatCamera( b : bool )
{	
	var  player : CR4Player = thePlayer;
	player.scriptedCombatCamera = b;
}

exec function tuthack()
{
	thePlayer.AddAbility('GeraltSkills_Testing');
	thePlayer.Debug_ResetInput();
}

exec function togglemenus()
{
	theGame.ToggleMenus();
}

exec function toggleinput()
{
	theGame.ToggleInput();
}

exec function interiorcam( b : bool )
{
	
}

exec function slow(factor : float)
{
	
	theGame.SetTimeScale(factor, theGame.GetTimescaleSource(ETS_CFM_On), theGame.GetTimescalePriority(ETS_CFM_On), true );
}

exec function shakeoffgeralt()
{
	var vehicleComp : W3HorseComponent;
	
	vehicleComp = (W3HorseComponent)thePlayer.GetUsedVehicle().GetComponentByClassName('CVehicleComponent');
	vehicleComp.ShakeOffRider( DT_ragdoll );
}

exec function immunity( effectName : name, optional actorTag:name  )
{	
	var i 			: int;
	var l_actor 	: CActor;
	var l_actors	: array<CActor>;
	var effect 		: EEffectType;
	var abilityName : name;
	
	EffectNameToType ( effectName, effect, abilityName ); 
	
	if (actorTag == 'PLAYER') 
	{
		thePlayer.AddBuffImmunity( effect, 'console', true );
		return;
	}
	
	l_actors = GetActorsInRange( thePlayer, 10000, 99, actorTag );
	for	( i = 0; i < l_actors.Size(); i+= 1 )
	{
		l_actor = (CActor) l_actors[i];
		l_actor.AddBuffImmunity( effect, 'console', true );
	}

}

exec function SuppressReactions( toggle : bool, areaTag : name )
{
	theGame.GetBehTreeReactionManager().SuppressReactions( toggle, areaTag );
}


exec function CryStart()
{
	var baron		: CEntity;
	var baronActor	: CActor;
	
	baron		= theGame.GetEntityByTag('Baron');
	if( baron )
	{
		baronActor	= ( CActor ) baron;
		if( baronActor )
		{
			baronActor.SignalGameplayEvent( 'StartCrying' );
		}
	}
}

exec function ultrafix()
{
	
	thePlayer.Debug_ReleaseCriticalStateSaveLocks();
	
	
	thePlayer.Debug_ResetInput();
	
	
	thePlayer.GetBuff(EET_AutoStaminaRegen).Debug_HAX_FIX(thePlayer);
	thePlayer.GetBuff(EET_AutoStaminaRegen).Debug_HAX_FIX(thePlayer);
	
	
	thePlayer.CheatResurrect();
	
	
	theGame.ResetFadeLock( "exe_func_ultrafix" );
	theGame.FadeInAsync( 0.f );
}


exec function CryStop()
{
	var baron		: CEntity;
	var baronActor	: CActor;
	
	baron	= theGame.GetEntityByTag('Baron');
	if( baron )
	{
		baronActor	= ( CActor ) baron;
		if( baronActor )
		{
			baronActor.SignalGameplayEvent( 'StopCrying' );
		}
	}
}

exec function skillblock(skill : ESkill, block : bool, optional cooldown : float)
{
	thePlayer.BlockSkill(skill, block, cooldown);
}

exec function skilleq(skill : ESkill, optional id : int, optional level : int)
{
	skilleq_internal(skill, id, level);
}

function skilleq_internal(skill : ESkill, optional id : int, optional level : int)
{
	var witcher : W3PlayerWitcher;
	var i, size : int;
	
	witcher = GetWitcherPlayer();

	if(level == 0)
		level = 1;
		
	for(i=0; i<level; i+=1)
	{
		witcher.AddSkill(skill);
	}	
	
	if(id <= 0)
		id = witcher.GetFreeSkillSlot();
	
	if(id < 0)
	{
		
		size = witcher.GetSkillSlotsCount();
		for(i=0; i<size; i+=1)
		{
			if(witcher.Debug_HAX_UnlockSkillSlot(i))
			{
				id = witcher.GetSkillSlotIDFromIndex(i);
				break;
			}
		}			
	}
	
	if(id >= 0)
		witcher.EquipSkill(skill, id);
}

exec function skilluneq(id : int)
{
	GetWitcherPlayer().UnequipSkill(id);
}

exec function skilleqtest()
{
	thePlayer.AddSkill(S_Magic_s08);
	thePlayer.AddSkill(S_Magic_s10);
	thePlayer.AddSkill(S_Magic_s11);
	
	GetWitcherPlayer().EquipSkill(S_Magic_s08, 8);	
	GetWitcherPlayer().UnequipSkill(8);	
	GetWitcherPlayer().EquipSkill(S_Magic_s08, 8);	
	
	GetWitcherPlayer().EquipSkill(S_Magic_s10, 10);	
	
	GetWitcherPlayer().EquipSkill(S_Magic_s11, 11);	
	GetWitcherPlayer().UnequipSkill(11);	
}

exec function printeqskills()	
{
	var i : int;
	var skill : ESkill;
	var unlocked : bool;

	LogSkills("");
	LogSkills("*** Logging equipped skills:");
	for(i=1; i<=20; i+=1)
	{
		unlocked = GetWitcherPlayer().GetSkillOnSlot(i, skill);
		
		if(!unlocked)
			LogSkills(i+". SLOT LOCKED");
		else if(skill == S_SUndefined)
			LogSkills(i+".");
		else		
			LogSkills(i+". " + skill + ", level = " + GetWitcherPlayer().GetSkillLevel(skill));
	}
}

exec function actionBlock( action : EInputActionBlock, block : bool )
{
	if( block )
	{
		thePlayer.BlockAction( action, 'consoleCommand' );
	}
	else
	{
		thePlayer.UnblockAction( action, 'consoleCommand' );
	}
}

exec function bft()
{
	thePlayer.BlockAction( EIAB_FastTravel, 'consoleCommand' );
}

exec function uft()
{
	thePlayer.UnblockAction( EIAB_FastTravel, 'consoleCommand' );
}

exec function eqmut()
{
	var ids : array<SItemUniqueId>;

	ids = thePlayer.inv.AddAnItem('Dao mutagen');
	GetWitcherPlayer().EquipItemInGivenSlot(ids[0], EES_SkillMutagen1, false);
	
	ids = thePlayer.inv.AddAnItem('Lamia mutagen');
	GetWitcherPlayer().EquipItemInGivenSlot(ids[0], EES_SkillMutagen1, false);
}

exec function uneqmut(slot : EEquipmentSlots)
{	
	GetWitcherPlayer().UnequipItemFromSlot(slot);
}

exec function medit()
{
	GetWitcherPlayer().Meditate();
}

exec function AddMeteorItem()
{
	thePlayer.inv.AddAnItem('q403_ciri_meteor',1);
}

exec function ToggleCloseCombat()
{
	if ( thePlayer.HasAbility('NoCloseCombatCheat') )
		thePlayer.RemoveAbility('NoCloseCombatCheat');
	else
		thePlayer.AddAbility('NoCloseCombatCheat');
}

exec function Panther( enable : bool )
{
	var r4Player	: CR4Player;
	
	r4Player	= ( CR4Player ) thePlayer;
	if( r4Player )
	{
		r4Player.substateManager.m_SharedDataO.m_UsePantherJumpB	= enable;
	}
}

exec function SecondaryItemTest()
{
	thePlayer.inv.AddAnItem('guisarme_test');
	thePlayer.inv.AddAnItem('axe_test');
	thePlayer.inv.AddAnItem('mace_test');
	thePlayer.inv.AddAnItem('dwarven_hammer_test');
}

exec function horseLowAtt( val : bool )
{
	if( val )
		thePlayer.SetBehaviorVariable( 'aimVertical', 1.0 );
	else
		thePlayer.SetBehaviorVariable( 'aimVertical', 0.0 );
}

exec function horseLocalSpace( toggle : bool )
{
	var horseComp : W3HorseComponent;
	horseComp = (W3HorseComponent)thePlayer.GetUsedVehicle().GetComponentByClassName( 'W3HorseComponent' );
	
	if ( horseComp )
		horseComp.ToggleLocalSpaceControlls( toggle );
	else
	{
		horseComp = (W3HorseComponent)thePlayer.GetHorseCurrentlyMounted().GetComponentByClassName( 'W3HorseComponent' );
		horseComp.ToggleLocalSpaceControlls( toggle );
	}
}

exec function horseSimpleStamina( toggle : bool )
{
	var horseComp : W3HorseComponent;
	
	horseComp = (W3HorseComponent)thePlayer.GetUsedVehicle().GetComponentByClassName( 'W3HorseComponent' );
	
	if ( horseComp )
		horseComp.ToggleSimpleStaminaManagement( toggle );
	else
	{
		horseComp = (W3HorseComponent)thePlayer.GetHorseCurrentlyMounted().GetComponentByClassName( 'W3HorseComponent' );
		horseComp.ToggleSimpleStaminaManagement( toggle );
	}
}

exec function showAttRange( attRangeName : name, optional actorTag:name )
{
	var i 				:int;
	var l_actor 		: CActor;
	var l_actors		: array<CActor>;
	
	l_actors = GetActorsInRange( thePlayer, 1000, 99, actorTag );
	
	for	( i = 0; i < l_actors.Size(); i+= 1 )
	{
		l_actor = (CActor) l_actors[i];
		l_actor.SetDebugAttackRange( attRangeName );
	}
	
}

exec function TestAdjustMove( val : bool ) 
{
	thePlayer.SetTestAdjustRequestedMovementDirection( val );
}

exec function fadeout()
{
	theGame.ResetFadeLock( "exe_func_fadeout" );
	theGame.FadeOutAsync();
}

exec function eredins()
{
	var ent : CEntity;
	var template : CEntityTemplate;
	
	template = (CEntityTemplate)LoadResource( "eredin_longsword" );
	ent = theGame.CreateEntity( template, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
	template = (CEntityTemplate)LoadResource( "eredin_hammer" );
	ent = theGame.CreateEntity( template, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
	template = (CEntityTemplate)LoadResource( "eredin_witcher" );
	ent = theGame.CreateEntity( template, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
}

exec function attitude( tag : name, flag : bool )
{
	var ent : CEntity;
	var actor : CActor;
	
	ent = theGame.GetEntityByTag( tag );
	actor = (CActor)ent;
	if( flag )
		actor.SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
	else
		actor.SetTemporaryAttitudeGroup( 'friendly_to_player', AGP_Default );
}

exec function settlement()
{
	thePlayer.IsInSettlement();
}

exec function MovePlayerFwd( distance : float, speed : float, optional drawSteel : bool, optional drawSilver : bool)
{
	var l_actor 			: CActor;
	var l_aiTreeDecorator	: CAIPlayerActionDecorator;
	var l_aiTree			: CAIMoveToPoint;
	
	if ( thePlayer.IsUsingHorse() )
		l_actor = (CActor)thePlayer.GetUsedHorseComponent().GetEntity();
	else
		l_actor = thePlayer;
	
	l_aiTree = new CAIMoveToPoint in l_actor;
	l_aiTree.OnCreated();
	
	l_aiTree.enterExplorationOnStart 		= false;
	l_aiTree.params.moveSpeed 				= speed;
	l_aiTree.params.destinationHeading 		= VecHeading(l_actor.GetHeadingVector());
	l_aiTree.params.destinationPosition 	= l_actor.GetWorldPosition() + distance*l_actor.GetHeadingVector();
	l_aiTree.params.maxIterationsNumber 	= 1;
	
	if ( l_actor == thePlayer )
	{
		if ( speed >= 2 )
			l_aiTree.params.moveType = MT_Sprint;
		else if ( speed >= 1 )
			l_aiTree.params.moveType = MT_FastRun;
		else
			l_aiTree.params.moveType = MT_Walk;
	}
	else
		l_aiTree.params.moveType = MT_Walk;
	
	l_aiTreeDecorator = new CAIPlayerActionDecorator in l_actor;
	l_aiTreeDecorator.OnCreated();
	l_aiTreeDecorator.interruptOnInput = true;
	l_aiTreeDecorator.scriptedAction = l_aiTree;	
		
	if ( drawSteel )
	{
		if(!GetWitcherPlayer().IsAnyItemEquippedOnSlot(EES_SteelSword))
		{
			return;
		}
		
		thePlayer.OnEquipMeleeWeapon(PW_Steel, true);
	}
	else if ( drawSilver)
	{
		if(!GetWitcherPlayer().IsAnyItemEquippedOnSlot(EES_SilverSword))
		{
			return;
		}
		
		thePlayer.OnEquipMeleeWeapon(PW_Silver, true);
	}
	
	if ( l_aiTreeDecorator )
		l_actor.ForceAIBehavior( l_aiTreeDecorator, BTAP_Emergency);
	else
		l_actor.ForceAIBehavior( l_aiTree, BTAP_Emergency);
}

exec function followNPC()
{
	var l_actor 			: CActor;
	var l_aiTreeDecorator	: CAIPlayerRiderActionDecorator;
	var l_aiTree			: CAIRiderFollowAction;
	
	if( thePlayer.IsUsingHorse() )
		l_actor = (CActor)thePlayer.GetUsedHorseComponent().GetEntity();
	else
		return;
	
	l_aiTree = new CAIRiderFollowAction in l_actor;
	l_aiTree.OnCreated();
	
	l_aiTree.params.targetTag = 'bob';

	l_aiTreeDecorator = new CAIPlayerRiderActionDecorator in l_actor;
	l_aiTreeDecorator.OnCreated();
	l_aiTreeDecorator.interruptOnInput = true;
	l_aiTreeDecorator.scriptedAction = l_aiTree;	

	if ( l_aiTreeDecorator )
		l_actor.ForceAIBehavior( l_aiTreeDecorator, BTAP_Emergency);
	else
		l_actor.ForceAIBehavior( l_aiTree, BTAP_Emergency);
}





exec function magicBubble( toggle : bool, optional actorTag : name )
{
	var i :int;
	var l_actor 		: CActor;
	var l_actors		: array<CActor>;
	var l_aiTree		: CAISorceressMagicBubbleActionTree;
	
	l_actors = GetActorsInRange( thePlayer, 1000, 99, actorTag );
	
	l_aiTree = new CAISorceressMagicBubbleActionTree in l_actor;
	l_aiTree.OnCreated();
	
	l_aiTree.deactivate = !toggle;
	
	for	( i = 0; i < l_actors.Size(); i+= 1 )
	{
		l_actor = (CActor) l_actors[i];
		if ( l_actor == thePlayer )
			continue;
		l_actor.ForceAIBehavior( l_aiTree, BTAP_Emergency);
	}
}
exec function upperBody(optional actorTag : name)
{
	var i :int;
	var l_actor 		: CActor;
	var l_actors		: array<CActor>;
	var l_aiTree		: CAIPlayAnimationUpperBodySlotAction;
	
	l_actors = GetActorsInRange( thePlayer, 1000, 99, actorTag );
	
	l_aiTree = new CAIPlayAnimationUpperBodySlotAction in l_actor;
	l_aiTree.OnCreated();
	
	l_aiTree.animName = 'woman_sex_loop';
	
	for	( i = 0; i < l_actors.Size(); i+= 1 )
	{
		l_actor = (CActor) l_actors[i];
		if ( l_actor == thePlayer )
			continue;
		l_actor.ForceAIBehavior( l_aiTree, BTAP_Emergency);
	}
}
exec function shootTest( targetTag : name, optional xbow : bool, optional actorTag : name )
{
	var i :int;
	var l_actor 		: CActor;
	var l_actors		: array<CActor>;
	var actionDecorator	: CAICombatModeActionDecorator;
	var l_aiTree		: CAIShootActionTree;
	
	l_actors = GetActorsInRange( thePlayer, 1000, 99, actorTag );
	
	actionDecorator = new CAICombatModeActionDecorator in l_actor;
	actionDecorator.OnCreated();
	actionDecorator.drawWeaponOnStart = true;
	actionDecorator.changeBehaviorGraphOnStart = true;
	
	if ( xbow )
	{
		actionDecorator.RightItemType = 'crossbow';
		actionDecorator.behGraph = EBG_Combat_Crossbow;
	}
	else
	{
		actionDecorator.LeftItemType = 'bow';
		actionDecorator.behGraph = EBG_Combat_Bow;
	}
	
	
	
	
	l_aiTree = new CAIShootActionTree in l_actor;
	l_aiTree.OnCreated();
	l_aiTree.targetTag = targetTag;
	l_aiTree.setProjectileOnFire = true;
	
	actionDecorator.scriptedAction = l_aiTree;
	
	for	( i = 0; i < l_actors.Size(); i+= 1 )
	{
		l_actor = (CActor) l_actors[i];
		if ( l_actor == thePlayer )
			continue;
		l_actor.ForceAIBehavior( actionDecorator, BTAP_AboveCombat);
	}
	
}
exec function stopUncon(optional actorTag : name)
{
	var i :int;
	var l_actor 		: CActor;
	var l_actors		: array<CActor>;
	
	l_actors = GetActorsInRange( thePlayer, 1000, 99, actorTag );
	
	for	( i = 0; i < l_actors.Size(); i+= 1 )
	{
		l_actor = (CActor) l_actors[i];
		if ( l_actor == thePlayer )
			continue;
		l_actor.SignalGameplayEvent('ForceStopUnconscious');
	}
}

exec function PlayerDebug( )
{
	var states : CExplorationStateManager;
	states = thePlayer.substateManager;
	states.m_IsDebugModeB = !states.m_IsDebugModeB;
}

exec function hidetut()
{
	theGame.GetTutorialSystem().HideTutorialHint('', true);
}

exec function itemkey(localizedString : string)
{
	var i : int;
	var items : array<SItemUniqueId>;
	var itemName : name;
	
	thePlayer.inv.GetAllItems(items);
	for(i=0; i<items.Size(); i+=1)
	{
		itemName = thePlayer.inv.GetItemName(items[i]);
		if(GetLocStringByKeyExt(thePlayer.inv.GetItemLocalizedNameByName(itemName)) == localizedString)
		{
			LogLocalization("item key is <<" + itemName + ">>");
			break;
		}
	}
}

exec function HideHorse()
{
	var horseComp : W3HorseComponent;
	horseComp = (W3HorseComponent)thePlayer.GetHorseCurrentlyMounted().GetComponentByClassName( 'W3HorseComponent' );
	horseComp.OnHideHorse();
}

exec function KillHorse()
{
	var horseComp : W3HorseComponent;
	horseComp = (W3HorseComponent)thePlayer.GetHorseCurrentlyMounted().GetComponentByClassName( 'W3HorseComponent' );
	horseComp.OnKillHorse();
}

exec function CamOffsetCorrection( optional enable : bool )
{
	thePlayer.substateManager.m_SharedDataO.EnableCameraOffsetCorrection( enable );
}

exec function playcam( val : name )
{
	var animation : SCameraAnimationDefinition;
	
	animation.priority = CAP_Highest;
	animation.blendIn = 0.1f;
	animation.blendOut = 0.1f;
	animation.weight = 1.f;
	animation.speed	= 1.0f;
	animation.reset = true;
	
	switch( val )
	{
		case 'back':
		{
			animation.animation = 'man_finisher_01_rp_camera_back';
			break;
		}
		case 'front':
		{
			animation.animation = 'man_finisher_01_rp_camera_front';
			break;
		}
		case 'left':
		{
			animation.animation = 'man_finisher_01_rp_camera_left';
			break;
		}
		case 'right':
		{
			animation.animation = 'man_finisher_01_rp_camera_right';
			break;
		}
		case 'exp':
		{
			animation.animation = 'camera_exploration';
			animation.loop = true;
			animation.additive = true;
			break;
		}
		case 'exp1':
		{
			animation.animation = 'camera_exploration';
			animation.loop = true;
			break;
		}
		case 'shake':
		{
			animation.animation = 'camera_shake_hit_lvl3_1';
			animation.priority = CAP_High;
			animation.weight = 0.3f;
			animation.additive = true;
		}
	}

	theGame.GetGameCamera().PlayAnimation( animation );
}

exec function printabs(optional tag : name, optional fromItems : bool, optional attributes : bool)
{
	printabs_f(tag, fromItems, attributes);
}

exec function printabstarget(optional fromItems : bool, optional attributes : bool)
{
	printabs_f(, fromItems, attributes, thePlayer.GetTarget());
}

function printabs_f(optional tag : name, optional fromItems : bool, optional attributes : bool, optional act : CActor)
{
	var i : int;
	var abs, atts : array<name>;
	var logStr : string;
	var actor : CActor;
	var val : SAbilityAttributeValue;
	
	if(!act)
	{
		if(tag == '')
			tag = 'PLAYER';
			
		if(tag == 'PLAYER')
		{
			actor = thePlayer;
		}
		else
		{
			actor = theGame.GetNPCByTag(tag);
		}
	}
	else
	{
		actor = act;
	}
	
	actor.GetCharacterStats().GetAbilities(abs,fromItems);
	
	logStr = "** Printing abilities of <<" + actor + ">> ";
	if(fromItems)
		logStr += "with items:";
	else
		logStr += "without items:";
	
	LogStats(logStr);
	while(abs.Size() > 0)
	{
		LogStats(SpaceFill(ArrayOfNamesCount(abs, abs[0]) + "x '" + abs[0] + "'", 50) + "typo check: '" + StrUpper(NameToString(abs[0])) + "'");
		ArrayOfNamesRemoveAll(abs, abs[0]);
	}
	LogStats("");
	
	if(attributes)
	{
		LogStats("** Attributes:");
		
		atts = actor.GetAllAttributes();
		ArraySortNames(atts);
		for(i=0; i<atts.Size(); i+=1)
		{
			if(theGame.params.IsForbiddenAttribute(atts[i]))
			{
				LogStats(SpaceFill(atts[i],35) + ", this attribute is cached - cannot directly get value using GetAttributeValue() func!");
			}
			else
			{
				val = actor.GetAttributeValue(atts[i], , true);
				LogStats(SpaceFill("'" + atts[i] + "'",35) + ", BASE= " + SpaceFill(NoTrailZeros(val.valueBase),8,ESFM_JustifyRight) + ", MUL= " + SpaceFill(NoTrailZeros(val.valueMultiplicative),8,ESFM_JustifyRight) + ", ADD= " + SpaceFill(NoTrailZeros(val.valueAdditive),8,ESFM_JustifyRight) );
			}
		}
		
		LogStats("");
	}
}

exec function damageitem(slot : EEquipmentSlots, perc : float)
{
	damageitem_g(slot, perc);
}

function damageitem_g(slot : EEquipmentSlots, perc : float)
{
	var max, dur : float;
	var item : SItemUniqueId;
	
	if(GetWitcherPlayer().GetItemEquippedOnSlot(slot, item))
	{
		max = thePlayer.inv.GetItemMaxDurability(item);
		dur = thePlayer.inv.GetItemDurability(item);
		
		dur -= perc * max;
		thePlayer.inv.SetItemDurabilityScript(item, dur);
	}
}

exec function alert()
{
	thePlayer.SetPlayerCombatStance( PCS_AlertNear );
	
}

exec function muttest(optional mutPotName : name, optional slot : EEquipmentSlots)
{
	var ids : array<SItemUniqueId>;
	
	if(mutPotName == '')
		mutPotName = 'Mutagen 1';
		
	if(slot == EES_InvalidSlot)
		slot = EES_PotionMutagen1;
		
	ids = thePlayer.inv.AddAnItem(mutPotName);
	GetWitcherPlayer().EquipItemInGivenSlot(ids[0], slot, false);
}

exec function cage()
{
	var entityTemplate : CEntityTemplate;
	var spawnedEntity : CEntity;
	
	entityTemplate = (CEntityTemplate)LoadResource("witches_cage");
	
	spawnedEntity = theGame.CreateEntity(entityTemplate, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());
	spawnedEntity.ApplyAppearance("roots_on");
}

exec function snowball( optional actorTag : name)
{
	var i :int;
	var l_actor 		: CActor;
	var l_actors		: array<CActor>;
	var l_aiTree		: CAICiriSnowballFightActionTree;
	
	l_actors = GetActorsInRange( thePlayer, 1000, 99, actorTag );
	
	l_aiTree = new CAICiriSnowballFightActionTree in l_actor;
	l_aiTree.OnCreated();
	
	for	( i = 0; i < l_actors.Size(); i+= 1 )
	{
		l_actor = (CActor) l_actors[i];
		if ( l_actor == thePlayer )
			continue;
		l_actor.ForceAIBehavior( l_aiTree, BTAP_AboveCombat);
	}
}	

exec function addtelemetrytag( tag : string )
{
	theTelemetry.AddSessionTag( tag );	
}

exec function remtelemetrytag( tag : string )
{
	theTelemetry.RemoveSessionTag( tag );	
}
exec function giveset ( val : name )
{
	var iID : array<SItemUniqueId>;
	
	switch ( val )
	{
		case 'gryphon' :
		{
			iID = thePlayer.inv.AddAnItem( 'Gryphon School steel sword 3',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Gryphon School silver sword 3',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Gryphon Armor 3',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Gryphon Gloves 4',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Gryphon Pants 4',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Gryphon Boots 4',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			break;
		}
		case 'lynx' :
		{
			iID = thePlayer.inv.AddAnItem( 'Lynx School steel sword 3',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Lynx School silver sword 3',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Lynx Armor 3',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Lynx Gloves 4',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Lynx Pants 4',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Lynx Boots 4',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Lynx School Crossbow',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			break;
		}
		case 'bear' :
		{
			iID = thePlayer.inv.AddAnItem( 'Bear School steel sword 3',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Bear School silver sword 3',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Bear Armor 3',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Bear Gloves 4',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Bear Pants 4',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Bear Boots 4',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Bear School Crossbow',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			break;
		}
		case 'wolf' :
		{
			iID = thePlayer.inv.AddAnItem( 'Wolf School steel sword 3',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Wolf School silver sword 3',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Wolf Armor 3',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Wolf Gloves 4',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Wolf Pants 4',1);
			GetWitcherPlayer().EquipItem(iID[0]);
			iID = thePlayer.inv.AddAnItem( 'Wolf Boots 4',1);
			break;	
		}	
	}
}

exec function addtemerianarmor()
{
	var iID : array<SItemUniqueId>;
	
	iID = thePlayer.inv.AddAnItem( 'DLC1 Temerian Armor', 1);
	
	iID = thePlayer.inv.AddAnItem( 'DLC1 Temerian Boots', 1);
	
	iID = thePlayer.inv.AddAnItem( 'DLC1 Temerian Gloves', 1);

	iID = thePlayer.inv.AddAnItem( 'DLC1 Temerian Pants', 1);
	
	GetWitcherPlayer().EquipItem( iID[0] );
	iID = thePlayer.inv.AddAnItem( 'NGP DLC1 Temerian Armor', 1);
	
	GetWitcherPlayer().EquipItem( iID[0] );
	iID = thePlayer.inv.AddAnItem( 'NGP DLC1 Temerian Boots', 1);
	
	GetWitcherPlayer().EquipItem( iID[0] );
	iID = thePlayer.inv.AddAnItem( 'NGP DLC1 Temerian Gloves', 1);

	GetWitcherPlayer().EquipItem( iID[0] );
	iID = thePlayer.inv.AddAnItem( 'NGP DLC1 Temerian Pants', 1);
}

exec function addnilfgaardianarmor()
{
	var iID : array<SItemUniqueId>;
	
	GetWitcherPlayer().EquipItem( iID[0] );
	iID = thePlayer.inv.AddAnItem( 'NGP DLC5 Nilfgaardian Armor', 1);
	
	GetWitcherPlayer().EquipItem( iID[0] );
	iID = thePlayer.inv.AddAnItem( 'NGP DLC5 Nilfgaardian Boots', 1);
	
	GetWitcherPlayer().EquipItem( iID[0] );
	iID = thePlayer.inv.AddAnItem( 'NGP DLC5 Nilfgaardian Gloves', 1);

	GetWitcherPlayer().EquipItem( iID[0] );
	iID = thePlayer.inv.AddAnItem( 'NGP DLC5 Nilfgaardian Pants', 1);
}
 
exec function shieldApp( tag : name )
{
	var entity : CEntity;
	var gplEnt : CGameplayEntity;
	var shield : CEntity;
	var inv : CInventoryComponent;
	
	entity = theGame.GetEntityByTag( tag );

	if( entity )
	{
		gplEnt = (CGameplayEntity)entity;
		inv = gplEnt.GetInventory();
		shield = inv.GetItemEntityUnsafe( inv.GetItemFromSlot( 'l_weapon' ) );
		shield.ApplyAppearance( 'damaged' );
	}
}

exec function SwitchAttach( attach : bool, parentEntityTag : name, childEntityTag : name, optional attachSlot: name )
{
	var l_parentEntity	: CEntity;
	var l_childEntity	: CEntity;
	
	l_parentEntity 	= theGame.GetEntityByTag( parentEntityTag );
	l_childEntity 	= theGame.GetEntityByTag( childEntityTag );
	
	if( !l_parentEntity || !l_childEntity )
	{
		return;
	}
	
	if( attach )
	{
		l_childEntity.CreateAttachment( l_parentEntity, attachSlot );
	}
	else
	{
		l_childEntity.BreakAttachment();
	}
	
}
exec function slide()
{
	thePlayer.substateManager.m_MoverO.SetSuperSlide( !thePlayer.substateManager.m_MoverO.superSlide );
}

exec function climb()
{
	thePlayer.substateManager.m_SharedDataO.SetUseClimb( !thePlayer.substateManager.m_SharedDataO.m_UseClimbB );
}

exec function climbJump()
{
	thePlayer.substateManager.m_SharedDataO.SwitchUseOnlyJumpClimbs();
}

exec function savefix( lockedNr : int )
{
	var i : int;
	for( i = 0; i < lockedNr; i += 1 )
	{
		theGame.ReleaseNoSaveLock(i);
	}
}

exec function hl(x,y,w,h : float)
{
	theGame.GetTutorialSystem().TutorialStart(false);
	theGame.GetTutorialSystem().DEBUG_TestTutorialHint(x,y,w,h,-1);
}

exec function imlerithSecondStage( tag : name )
{
	var imlerith : CNewNPC;
	
	imlerith = (CNewNPC)theGame.GetNodeByTag( tag );
	imlerith.DropItemFromSlot( 'l_weapon', true );
	imlerith.AddEffectDefault( EET_Frozen, thePlayer, "debug" );
}

exec function changeStyle()
{
	var target : CActor;
	target = thePlayer.GetTarget();
	
	if ( target )
	{
		target.SignalGameplayEvent('LeaveCurrentCombatStyle');
	}
}

exec function addHair1()
{
	var newID : array<SItemUniqueId>;
	
	newID = thePlayer.inv.AddAnItem('Half With Tail Hairstyle', 1);
	thePlayer.EquipItem(newID[0]);
}

exec function addHair2()
{
	var newID : array<SItemUniqueId>;
	
	newID = thePlayer.inv.AddAnItem('Shaved With Tail Hairstyle', 1);
	thePlayer.EquipItem(newID[0]);
}

exec function addHair3()
{
	var newID : array<SItemUniqueId>;
	
	newID = thePlayer.inv.AddAnItem('Long Loose Hairstyle', 1);
	thePlayer.EquipItem(newID[0]);
}

exec function addHairDLC1()
{
	var newID : array<SItemUniqueId>;
	
	newID = thePlayer.inv.AddAnItem('Short Loose Hairstyle', 1);
	thePlayer.EquipItem(newID[0]);
}

exec function addHairDLC2()
{
	var newID : array<SItemUniqueId>;
	
	newID = thePlayer.inv.AddAnItem('Mohawk With Ponytail Hairstyle', 1);
	thePlayer.EquipItem(newID[0]);
}

exec function addHairDLC3()
{
	var newID : array<SItemUniqueId>;
	
	newID = thePlayer.inv.AddAnItem('Nilfgaardian Hairstyle', 1);
	thePlayer.EquipItem(newID[0]);
}

exec function addLightArmors()
{
thePlayer.inv.RemoveAllItems();
thePlayer.inv.AddAnItem('Light armor 01', 1);
thePlayer.inv.AddAnItem('Light armor 02', 1);
thePlayer.inv.AddAnItem('Light armor 03', 1);
thePlayer.inv.AddAnItem('Light armor 04', 1);
thePlayer.inv.AddAnItem('Light armor 06', 1);
thePlayer.inv.AddAnItem('Light armor 07', 1);
thePlayer.inv.AddAnItem('Light armor 08', 1);
thePlayer.inv.AddAnItem('Light armor 09', 1);
thePlayer.inv.AddAnItem('Starting Gloves', 1);
thePlayer.inv.AddAnItem('Starting Pants', 1);
thePlayer.inv.AddAnItem('Starting Boots', 1);

thePlayer.inv.AddAnItem('Starting Gloves', 1);
thePlayer.inv.AddAnItem('Long Steel Sword', 1);
thePlayer.inv.AddAnItem('Witcher Silver Sword', 1);
}

exec function addMediumArmors()
{
thePlayer.inv.RemoveAllItems();
thePlayer.inv.AddAnItem('Medium armor 01', 1);
thePlayer.inv.AddAnItem('Medium armor 02', 1);
thePlayer.inv.AddAnItem('Medium armor 03', 1);
thePlayer.inv.AddAnItem('Medium armor 04', 1);
thePlayer.inv.AddAnItem('Medium armor 05', 1);
thePlayer.inv.AddAnItem('Medium armor 07', 1);
thePlayer.inv.AddAnItem('Medium armor 10', 1);
thePlayer.inv.AddAnItem('Medium armor 11', 1);
thePlayer.inv.AddAnItem('Starting Gloves', 1);
thePlayer.inv.AddAnItem('Starting Pants', 1);
thePlayer.inv.AddAnItem('Starting Boots', 1);

thePlayer.inv.AddAnItem('Starting Gloves', 1);
thePlayer.inv.AddAnItem('Long Steel Sword', 1);
thePlayer.inv.AddAnItem('Witcher Silver Sword', 1);
}

exec function addHeavyArmors()
{
thePlayer.inv.RemoveAllItems();
thePlayer.inv.AddAnItem('Heavy armor 01', 1);
thePlayer.inv.AddAnItem('Heavy armor 02', 1);
thePlayer.inv.AddAnItem('Heavy armor 03', 1);
thePlayer.inv.AddAnItem('Heavy armor 04', 1);
thePlayer.inv.AddAnItem('Heavy armor 05', 1);
thePlayer.inv.AddAnItem('Starting Gloves', 1);
thePlayer.inv.AddAnItem('Starting Pants', 1);
thePlayer.inv.AddAnItem('Starting Boots', 1);

thePlayer.inv.AddAnItem('Starting Gloves', 1);
thePlayer.inv.AddAnItem('Long Steel Sword', 1);
thePlayer.inv.AddAnItem('Witcher Silver Sword', 1);
}

exec function addBearArmors()
{
	var lm : W3PlayerWitcher;
	var exp, prevLvl, currLvl : int;
	
	GetWitcherPlayer().Debug_ClearCharacterDevelopment();
	lm = GetWitcherPlayer();
	prevLvl = lm.GetLevel();
	currLvl = lm.GetLevel();
		
	while(currLvl < 60)
	{
		exp = lm.GetTotalExpForNextLevel() - lm.GetPointsTotal(EExperiencePoint);
		lm.AddPoints(EExperiencePoint, exp, false); 
		currLvl = lm.GetLevel();
		if(prevLvl == currLvl)
			break;
		prevLvl = currLvl;
	}	
	
	thePlayer.inv.RemoveAllItems();
	thePlayer.inv.AddAnItem('Bear Armor', 1);
	thePlayer.inv.AddAnItem('Bear Armor 1', 1);
	thePlayer.inv.AddAnItem('Bear Armor 2', 1);
	thePlayer.inv.AddAnItem('Bear Armor 3', 1);
	thePlayer.inv.AddAnItem('Bear Armor 4', 1);
	thePlayer.inv.AddAnItem('Bear Gloves 1', 1);
	thePlayer.inv.AddAnItem('Bear Gloves 2', 1);
	thePlayer.inv.AddAnItem('Bear Gloves 3', 1);
	thePlayer.inv.AddAnItem('Bear Gloves 4', 1);
	thePlayer.inv.AddAnItem('Bear Gloves 5', 1);
	thePlayer.inv.AddAnItem('Bear Pants 1', 1);
	thePlayer.inv.AddAnItem('Bear Pants 2', 1);
	thePlayer.inv.AddAnItem('Bear Pants 3', 1);
	thePlayer.inv.AddAnItem('Bear Pants 4', 1);
	thePlayer.inv.AddAnItem('Bear Pants 5', 1);
	thePlayer.inv.AddAnItem('Bear Boots 1', 1);
	thePlayer.inv.AddAnItem('Bear Boots 2', 1);
	thePlayer.inv.AddAnItem('Bear Boots 3', 1);
	thePlayer.inv.AddAnItem('Bear Boots 4', 1);
	thePlayer.inv.AddAnItem('Bear Boots 5', 1);
	
	thePlayer.inv.AddAnItem('Bear School steel sword', 1);
	thePlayer.inv.AddAnItem('Bear School steel sword 1', 1);
	thePlayer.inv.AddAnItem('Bear School steel sword 2', 1);
	thePlayer.inv.AddAnItem('Bear School steel sword 3', 1);
	thePlayer.inv.AddAnItem('Bear School silver sword', 1);
	thePlayer.inv.AddAnItem('Bear School silver sword 1', 1);
	thePlayer.inv.AddAnItem('Bear School silver sword 2', 1);
	thePlayer.inv.AddAnItem('Bear School silver sword 3', 1);

	thePlayer.inv.AddAnItem('Dye Default',10);
	thePlayer.inv.AddAnItem('Dye Black',10);
	thePlayer.inv.AddAnItem('Dye Blue',10);
	thePlayer.inv.AddAnItem('Dye Brown',10);
	thePlayer.inv.AddAnItem('Dye Gray',10);
	thePlayer.inv.AddAnItem('Dye Green',10);
	thePlayer.inv.AddAnItem('Dye Orange',10);
	thePlayer.inv.AddAnItem('Dye Pink',10);
	thePlayer.inv.AddAnItem('Dye Purple',10);
	thePlayer.inv.AddAnItem('Dye Red',10);
	thePlayer.inv.AddAnItem('Dye Turquoise',10);
	thePlayer.inv.AddAnItem('Dye White',10);
	thePlayer.inv.AddAnItem('Dye Yellow',10);

	EncumbranceBoy( 0 );
}

exec function addLynxArmors()
{
	var lm : W3PlayerWitcher;
	var exp, prevLvl, currLvl : int;
	
	GetWitcherPlayer().Debug_ClearCharacterDevelopment();
	lm = GetWitcherPlayer();
	prevLvl = lm.GetLevel();
	currLvl = lm.GetLevel();
		
	while(currLvl < 60)
	{
		exp = lm.GetTotalExpForNextLevel() - lm.GetPointsTotal(EExperiencePoint);
		lm.AddPoints(EExperiencePoint, exp, false); 
		currLvl = lm.GetLevel();
		if(prevLvl == currLvl)
			break;
		prevLvl = currLvl;
	}	

	thePlayer.inv.RemoveAllItems();
	thePlayer.inv.AddAnItem('Lynx Armor', 1);
	thePlayer.inv.AddAnItem('Lynx Armor 1', 1);
	thePlayer.inv.AddAnItem('Lynx Armor 2', 1);
	thePlayer.inv.AddAnItem('Lynx Armor 3', 1);
	thePlayer.inv.AddAnItem('Lynx Armor 4', 1);
	thePlayer.inv.AddAnItem('Lynx Gloves 1', 1);
	thePlayer.inv.AddAnItem('Lynx Gloves 2', 1);
	thePlayer.inv.AddAnItem('Lynx Gloves 3', 1);
	thePlayer.inv.AddAnItem('Lynx Gloves 4', 1);
	thePlayer.inv.AddAnItem('Lynx Gloves 5', 1);
	thePlayer.inv.AddAnItem('Lynx Pants 1', 1);
	thePlayer.inv.AddAnItem('Lynx Pants 2', 1);
	thePlayer.inv.AddAnItem('Lynx Pants 3', 1);
	thePlayer.inv.AddAnItem('Lynx Pants 4', 1);
	thePlayer.inv.AddAnItem('Lynx Pants 5', 1);
	thePlayer.inv.AddAnItem('Lynx Boots 1', 1);
	thePlayer.inv.AddAnItem('Lynx Boots 2', 1);
	thePlayer.inv.AddAnItem('Lynx Boots 3', 1);
	thePlayer.inv.AddAnItem('Lynx Boots 4', 1);
	thePlayer.inv.AddAnItem('Lynx Boots 5', 1);

	thePlayer.inv.AddAnItem('Lynx School steel sword', 1);
	thePlayer.inv.AddAnItem('Lynx School steel sword 1', 1);
	thePlayer.inv.AddAnItem('Lynx School steel sword 2', 1);
	thePlayer.inv.AddAnItem('Lynx School steel sword 3', 1);
	thePlayer.inv.AddAnItem('Lynx School silver sword', 1);
	thePlayer.inv.AddAnItem('Lynx School silver sword 1', 1);
	thePlayer.inv.AddAnItem('Lynx School silver sword 2', 1);
	thePlayer.inv.AddAnItem('Lynx School silver sword 3', 1);

	thePlayer.inv.AddAnItem('Dye Default',10);
	thePlayer.inv.AddAnItem('Dye Black',10);
	thePlayer.inv.AddAnItem('Dye Blue',10);
	thePlayer.inv.AddAnItem('Dye Brown',10);
	thePlayer.inv.AddAnItem('Dye Gray',10);
	thePlayer.inv.AddAnItem('Dye Green',10);
	thePlayer.inv.AddAnItem('Dye Orange',10);
	thePlayer.inv.AddAnItem('Dye Pink',10);
	thePlayer.inv.AddAnItem('Dye Purple',10);
	thePlayer.inv.AddAnItem('Dye Red',10);
	thePlayer.inv.AddAnItem('Dye Turquoise',10);
	thePlayer.inv.AddAnItem('Dye White',10);
	thePlayer.inv.AddAnItem('Dye Yellow',10);
	
	EncumbranceBoy( 0 );
}


exec function testappearance()
{
	var ids : array<SItemUniqueId>;

	thePlayer.inv.RemoveAllItems();
	
	thePlayer.inv.AddAnItem( 'Red Wolf Armor 1', 1);
	thePlayer.inv.AddAnItem( 'Red Wolf Armor 2', 1);
	thePlayer.inv.AddAnItem( 'Red Wolf Gloves 1', 1);
	thePlayer.inv.AddAnItem( 'Red Wolf Gloves 2', 1);
	thePlayer.inv.AddAnItem( 'Red Wolf Pants 1', 1);
	thePlayer.inv.AddAnItem( 'Red Wolf Pants 2', 1);
	thePlayer.inv.AddAnItem( 'Red Wolf Boots 1', 1);
    thePlayer.inv.AddAnItem( 'Red Wolf Boots 2', 1);

	ids = thePlayer.inv.AddAnItem('Gryphon Armor 3', 1);
	thePlayer.EquipItem(ids[0]);

	thePlayer.inv.AddAnItem('Dye Default',1);
	thePlayer.inv.AddAnItem('Dye Black',1);
	thePlayer.inv.AddAnItem('Dye Blue',1);
	thePlayer.inv.AddAnItem('Dye Brown',1);
	thePlayer.inv.AddAnItem('Dye Gray',1);
	thePlayer.inv.AddAnItem('Dye Green',1);
	thePlayer.inv.AddAnItem('Dye Orange',1);
	thePlayer.inv.AddAnItem('Dye Pink',1);
	thePlayer.inv.AddAnItem('Dye Purple',1);
	thePlayer.inv.AddAnItem('Dye Red',1);
	thePlayer.inv.AddAnItem('Dye Silver',1);
	thePlayer.inv.AddAnItem('Dye White',1);
	thePlayer.inv.AddAnItem('Dye Yellow',1);

	thePlayer.inv.AddAnItem( 'Dye Solution', 20);
	thePlayer.inv.AddAnItem( 'Recipe Dye Default', 1);
	thePlayer.inv.AddAnItem( 'Recipe Dye Gray', 1);
	thePlayer.inv.AddAnItem( 'Recipe Dye Silver', 1);
	thePlayer.inv.AddAnItem( 'Recipe Dye Brown', 1);
	thePlayer.inv.AddAnItem( 'Recipe Dye Red', 1);
	thePlayer.inv.AddAnItem( 'Recipe Dye Green', 1);
	thePlayer.inv.AddAnItem( 'Recipe Dye Blue', 1);
	thePlayer.inv.AddAnItem( 'Recipe Dye Black', 1);
	thePlayer.inv.AddAnItem( 'Recipe Dye White', 1);
	thePlayer.inv.AddAnItem( 'Recipe Dye Orange', 1);
	thePlayer.inv.AddAnItem( 'Recipe Dye Pink', 1);
	thePlayer.inv.AddAnItem( 'Recipe Dye Yellow', 1);
	thePlayer.inv.AddAnItem( 'Recipe Dye Purple', 1);

	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}

exec function addGryphonArmors()
{

	var lm : W3PlayerWitcher;
	var exp, prevLvl, currLvl : int;
	
	GetWitcherPlayer().Debug_ClearCharacterDevelopment();
	lm = GetWitcherPlayer();
	prevLvl = lm.GetLevel();
	currLvl = lm.GetLevel();
		
	while(currLvl < 60)
	{
		exp = lm.GetTotalExpForNextLevel() - lm.GetPointsTotal(EExperiencePoint);
		lm.AddPoints(EExperiencePoint, exp, false); 
		currLvl = lm.GetLevel();
		if(prevLvl == currLvl)
			break;
		prevLvl = currLvl;
	}	

	thePlayer.inv.RemoveAllItems();
	thePlayer.inv.AddAnItem('Gryphon Armor', 1);
	thePlayer.inv.AddAnItem('Gryphon Armor 1', 1);
	thePlayer.inv.AddAnItem('Gryphon Armor 2', 1);
	thePlayer.inv.AddAnItem('Gryphon Armor 3', 1);
	thePlayer.inv.AddAnItem('Gryphon Armor 4', 1);
	thePlayer.inv.AddAnItem('Gryphon Gloves 1', 1);
	thePlayer.inv.AddAnItem('Gryphon Gloves 2', 1);
	thePlayer.inv.AddAnItem('Gryphon Gloves 3', 1);
	thePlayer.inv.AddAnItem('Gryphon Gloves 4', 1);
	thePlayer.inv.AddAnItem('Gryphon Gloves 5', 1);
	thePlayer.inv.AddAnItem('Gryphon Pants 1', 1);
	thePlayer.inv.AddAnItem('Gryphon Pants 2', 1);
	thePlayer.inv.AddAnItem('Gryphon Pants 3', 1);
	thePlayer.inv.AddAnItem('Gryphon Pants 4', 1);
	thePlayer.inv.AddAnItem('Gryphon Pants 5', 1);
	thePlayer.inv.AddAnItem('Gryphon Boots 1', 1);
	thePlayer.inv.AddAnItem('Gryphon Boots 2', 1);
	thePlayer.inv.AddAnItem('Gryphon Boots 3', 1);
	thePlayer.inv.AddAnItem('Gryphon Boots 4', 1);
	thePlayer.inv.AddAnItem('Gryphon Boots 5', 1);

	thePlayer.inv.AddAnItem('Gryphon School steel sword', 1);
	thePlayer.inv.AddAnItem('Gryphon School steel sword 1', 1);
	thePlayer.inv.AddAnItem('Gryphon School steel sword 2', 1);
	thePlayer.inv.AddAnItem('Gryphon School steel sword 3', 1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword', 1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword 1', 1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword 2', 1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword 3', 1);


	thePlayer.inv.AddAnItem('Dye Default',10);
	thePlayer.inv.AddAnItem('Dye Black',10);
	thePlayer.inv.AddAnItem('Dye Blue',10);
	thePlayer.inv.AddAnItem('Dye Brown',10);
	thePlayer.inv.AddAnItem('Dye Gray',10);
	thePlayer.inv.AddAnItem('Dye Green',10);
	thePlayer.inv.AddAnItem('Dye Orange',10);
	thePlayer.inv.AddAnItem('Dye Pink',10);
	thePlayer.inv.AddAnItem('Dye Purple',10);
	thePlayer.inv.AddAnItem('Dye Red',10);
	thePlayer.inv.AddAnItem('Dye Turquoise',10);
	thePlayer.inv.AddAnItem('Dye White',10);
	thePlayer.inv.AddAnItem('Dye Yellow',10);

	EncumbranceBoy( 0 );
}

exec function addViperArmors()
{

	var lm : W3PlayerWitcher;
	var exp, prevLvl, currLvl : int;
	
	GetWitcherPlayer().Debug_ClearCharacterDevelopment();
	lm = GetWitcherPlayer();
	prevLvl = lm.GetLevel();
	currLvl = lm.GetLevel();
		
	while(currLvl < 60)
	{
		exp = lm.GetTotalExpForNextLevel() - lm.GetPointsTotal(EExperiencePoint);
		lm.AddPoints(EExperiencePoint, exp, false); 
		currLvl = lm.GetLevel();
		if(prevLvl == currLvl)
			break;
		prevLvl = currLvl;
	}	

thePlayer.inv.RemoveAllItems();
thePlayer.inv.AddAnItem('Starting Armor', 1);
thePlayer.inv.AddAnItem('Starting Gloves', 1);
thePlayer.inv.AddAnItem('Starting Pants', 1);
thePlayer.inv.AddAnItem('Starting Boots', 1);

thePlayer.inv.AddAnItem('Long Steel Sword', 1);
thePlayer.inv.AddAnItem('Witcher Silver Sword', 1);


	thePlayer.inv.AddAnItem('Dye Default',10);
	thePlayer.inv.AddAnItem('Dye Black',10);
	thePlayer.inv.AddAnItem('Dye Blue',10);
	thePlayer.inv.AddAnItem('Dye Brown',10);
	thePlayer.inv.AddAnItem('Dye Gray',10);
	thePlayer.inv.AddAnItem('Dye Green',10);
	thePlayer.inv.AddAnItem('Dye Orange',10);
	thePlayer.inv.AddAnItem('Dye Pink',10);
	thePlayer.inv.AddAnItem('Dye Purple',10);
	thePlayer.inv.AddAnItem('Dye Red',10);
	thePlayer.inv.AddAnItem('Dye Turquoise',10);
	thePlayer.inv.AddAnItem('Dye White',10);
	thePlayer.inv.AddAnItem('Dye Yellow',10);

	EncumbranceBoy( 0 );
}

exec function addRelicArmors()
{
thePlayer.inv.RemoveAllItems();
thePlayer.inv.AddAnItem('Shiadhal armor', 1);
thePlayer.inv.AddAnItem('Thyssen armor', 1);
thePlayer.inv.AddAnItem('Oathbreaker armor', 1);
thePlayer.inv.AddAnItem('Zireael armor', 1);
thePlayer.inv.AddAnItem('Shadaal armor', 1);
thePlayer.inv.AddAnItem('Relic Heavy 3 armor', 1);

thePlayer.inv.AddAnItem('Starting Gloves', 1);
thePlayer.inv.AddAnItem('Long Steel Sword', 1);
thePlayer.inv.AddAnItem('Witcher Silver Sword', 1);
}

exec function addAllArmors()
{
thePlayer.inv.RemoveAllItems();
thePlayer.inv.AddAnItem('Starting Armor', 1);
thePlayer.inv.AddAnItem('Geralt Shirt', 1);
thePlayer.inv.AddAnItem('Body torso 01', 1);
thePlayer.inv.AddAnItem('Wolf Armor', 1);
thePlayer.inv.AddAnItem('Wolf Armor 1', 1);
thePlayer.inv.AddAnItem('Wolf Armor 2', 1);
thePlayer.inv.AddAnItem('Wolf Armor 3', 1);
thePlayer.inv.AddAnItem('Lynx Armor', 1);
thePlayer.inv.AddAnItem('Lynx Armor 1', 1);
thePlayer.inv.AddAnItem('Lynx Armor 2', 1);
thePlayer.inv.AddAnItem('Lynx Armor 3', 1);
thePlayer.inv.AddAnItem('Gryphon Armor', 1);
thePlayer.inv.AddAnItem('Gryphon Armor 1', 1);
thePlayer.inv.AddAnItem('Gryphon Armor 2', 1);
thePlayer.inv.AddAnItem('Gryphon Armor 3', 1);
thePlayer.inv.AddAnItem('Bear Armor', 1);
thePlayer.inv.AddAnItem('Bear Armor 1', 1);
thePlayer.inv.AddAnItem('Bear Armor 2', 1);
thePlayer.inv.AddAnItem('Bear Armor 3', 1);
thePlayer.inv.AddAnItem('Light armor 01', 1);
thePlayer.inv.AddAnItem('Light armor 02', 1);
thePlayer.inv.AddAnItem('Light armor 03', 1);
thePlayer.inv.AddAnItem('Light armor 04', 1);
thePlayer.inv.AddAnItem('Light armor 06', 1);
thePlayer.inv.AddAnItem('Light armor 07', 1);
thePlayer.inv.AddAnItem('Light armor 08', 1);
thePlayer.inv.AddAnItem('Light armor 09', 1);
thePlayer.inv.AddAnItem('Medium armor 01', 1);
thePlayer.inv.AddAnItem('Medium armor 02', 1);
thePlayer.inv.AddAnItem('Medium armor 03', 1);
thePlayer.inv.AddAnItem('Medium armor 04', 1);
thePlayer.inv.AddAnItem('Medium armor 05', 1);
thePlayer.inv.AddAnItem('Medium armor 07', 1);
thePlayer.inv.AddAnItem('Medium armor 10', 1);
thePlayer.inv.AddAnItem('Medium armor 11', 1);
thePlayer.inv.AddAnItem('Heavy armor 01', 1);
thePlayer.inv.AddAnItem('Heavy armor 02', 1);
thePlayer.inv.AddAnItem('Heavy armor 03', 1);
thePlayer.inv.AddAnItem('Heavy armor 04', 1);
thePlayer.inv.AddAnItem('Heavy armor 05', 1);
thePlayer.inv.AddAnItem('Starting Gloves', 1);
thePlayer.inv.AddAnItem('Starting Pants', 1);
thePlayer.inv.AddAnItem('Starting Boots', 1);
thePlayer.inv.AddAnItem('Shiadhal armor', 1);
thePlayer.inv.AddAnItem('Thyssen armor', 1);
thePlayer.inv.AddAnItem('Oathbreaker armor', 1);
thePlayer.inv.AddAnItem('Zireael armor', 1);
thePlayer.inv.AddAnItem('Shadaal armor', 1);
thePlayer.inv.AddAnItem('Relic Heavy 3 armor', 1);

thePlayer.inv.AddAnItem('Starting Gloves', 1);
thePlayer.inv.AddAnItem('Long Steel Sword', 1);
thePlayer.inv.AddAnItem('Witcher Silver Sword', 1);
}

exec function addCasualArmors()
{
thePlayer.inv.RemoveAllItems();
thePlayer.inv.AddAnItem('Nilfgaardian Casual Suit 01', 1);
thePlayer.inv.AddAnItem('Nilfgaardian Casual Suit 02', 1);
thePlayer.inv.AddAnItem('Nilfgaardian Casual Suit 03', 1);
thePlayer.inv.AddAnItem('Skellige Casual Suit 01', 1);
thePlayer.inv.AddAnItem('Skellige Casual Suit 02', 1);
thePlayer.inv.AddAnItem('Geralt Shirt', 1);
thePlayer.inv.AddAnItem('Nilfgaardian Casual Pants', 1);
thePlayer.inv.AddAnItem('Skellige Casual Pants 01', 1);
thePlayer.inv.AddAnItem('Skellige Casual Pants 02', 1);
thePlayer.inv.AddAnItem('Bath Towel Pants 01', 1);
thePlayer.inv.AddAnItem('Skellige casual shoes', 1);
thePlayer.inv.AddAnItem('Nilfgaardian casual shoes', 1);
thePlayer.inv.AddAnItem('Starting Gloves', 1);

thePlayer.inv.AddAnItem('Long Steel Sword', 1);
thePlayer.inv.AddAnItem('Witcher Silver Sword', 1);
}

exec function addAllGloves(){

thePlayer.inv.AddAnItem('Starting Gloves', 1);
thePlayer.inv.AddAnItem('Lynx Gloves 1', 1);
thePlayer.inv.AddAnItem('Lynx Gloves 2', 1);
thePlayer.inv.AddAnItem('Gryphon Gloves 1', 1);
thePlayer.inv.AddAnItem('Gryphon Gloves 2', 1);
thePlayer.inv.AddAnItem('Bear Gloves 1', 1);
thePlayer.inv.AddAnItem('Bear Gloves 2', 1);

thePlayer.inv.AddAnItem('Gloves 01', 1);
thePlayer.inv.AddAnItem('Gloves 02', 1);
thePlayer.inv.AddAnItem('Gloves 03', 1);
thePlayer.inv.AddAnItem('Gloves 04', 1);
thePlayer.inv.AddAnItem('Heavy gloves 01', 1);
thePlayer.inv.AddAnItem('Heavy gloves 02', 1);
thePlayer.inv.AddAnItem('Heavy gloves 03', 1);
thePlayer.inv.AddAnItem('Heavy gloves 04', 1);
}

exec function addAllBoots(){

thePlayer.inv.AddAnItem('Gryphon Boots 1', 1);
thePlayer.inv.AddAnItem('Gryphon Boots 2', 1);
thePlayer.inv.AddAnItem('Lynx Boots 1', 1);
thePlayer.inv.AddAnItem('Lynx Boots 2', 1);
thePlayer.inv.AddAnItem('Bear Boots 1', 1);
thePlayer.inv.AddAnItem('Bear Boots 2', 1);

thePlayer.inv.AddAnItem('Boots 01', 1);
thePlayer.inv.AddAnItem('Boots 02', 1);
thePlayer.inv.AddAnItem('Boots 03', 1);
thePlayer.inv.AddAnItem('Boots 04', 1);
thePlayer.inv.AddAnItem('Boots 01 q2', 1);
thePlayer.inv.AddAnItem('Heavy boots 01', 1);
thePlayer.inv.AddAnItem('Heavy boots 02', 1);
thePlayer.inv.AddAnItem('Heavy boots 03', 1);
thePlayer.inv.AddAnItem('Heavy boots 04', 1);
thePlayer.inv.AddAnItem('Heavy boots 05', 1);
thePlayer.inv.AddAnItem('Heavy boots 06', 1);
thePlayer.inv.AddAnItem('Heavy boots 07', 1);
thePlayer.inv.AddAnItem('Heavy boots 08', 1);

thePlayer.inv.AddAnItem('Nilfgaardian casual shoes', 1);
thePlayer.inv.AddAnItem('Skellige casual shoes', 1);
}

exec function addAllPants(){

thePlayer.inv.AddAnItem('Gryphon Pants 1', 1);
thePlayer.inv.AddAnItem('Gryphon Pants 2', 1);
thePlayer.inv.AddAnItem('Lynx Pants 1', 1);
thePlayer.inv.AddAnItem('Lynx Pants 2', 1);
thePlayer.inv.AddAnItem('Bear Pants 1', 1);
thePlayer.inv.AddAnItem('Bear Pants 2', 1);

thePlayer.inv.AddAnItem('Pants 01', 1);
thePlayer.inv.AddAnItem('Pants 02', 1);
thePlayer.inv.AddAnItem('Pants 03', 1);
thePlayer.inv.AddAnItem('Pants 04', 1);
thePlayer.inv.AddAnItem('Heavy pants 01', 1);
thePlayer.inv.AddAnItem('Heavy pants 02', 1);
thePlayer.inv.AddAnItem('Heavy pants 03', 1);
thePlayer.inv.AddAnItem('Heavy pants 04', 1);
}

exec function addHorseArmors()
{
thePlayer.inv.AddAnItem('i_01_hd__bags_lvl2', 1);
thePlayer.inv.AddAnItem('i_01_hd__bags_lvl3', 1);
thePlayer.inv.AddAnItem('c_01_hd__champron_lvl3', 1);
thePlayer.inv.AddAnItem('c_01_hd__champron_lvl2', 1);
thePlayer.inv.AddAnItem('s_01_hd__saddle_lvl1', 1);
thePlayer.inv.AddAnItem('s_01_hd__saddle_lvl2', 1);
thePlayer.inv.AddAnItem('s_01_hd__saddle_lvl3', 1);
thePlayer.inv.AddAnItem('s_01_hd__saddle_lvl4', 1);
}

exec function AddAllThMaps ()
{
	thePlayer.inv.AddAnItem('th1003_map_lynx_upgrade1a', 1);
	thePlayer.inv.AddAnItem('th1003_map_lynx_upgrade1b', 1);
	thePlayer.inv.AddAnItem('th1003_map_lynx_upgrade2', 1);
	thePlayer.inv.AddAnItem('th1003_map_lynx_upgrade3', 1);
	thePlayer.inv.AddAnItem('th1005_map_gryphon_upgrade1a', 1);
	thePlayer.inv.AddAnItem('th1005_map_gryphon_upgrade1b', 1);
	thePlayer.inv.AddAnItem('th1005_map_gryphon_upgrade2', 1);
	thePlayer.inv.AddAnItem('th1005_map_gryphon_upgrade3', 1);
	thePlayer.inv.AddAnItem('th1007_map_bear_upgrade1a', 1);
	thePlayer.inv.AddAnItem('th1007_map_bear_upgrade1b', 1);
	thePlayer.inv.AddAnItem('th1007_map_bear_upgrade2', 1);
	thePlayer.inv.AddAnItem('th1007_map_bear_upgrade3', 1);
}

exec function addAllSkills(val : int, optional level : int)
{	
	var lm : W3PlayerWitcher;
	var i,exp,k : int;
	
	if(level < 1)
	{
		level = 1;
	}
	
	lm = GetWitcherPlayer();
	for(i=0; i<level; i+=1)
	{
		exp = lm.GetTotalExpForNextLevel() - lm.GetPointsTotal(EExperiencePoint);
		lm.AddPoints(EExperiencePoint, exp, false );
	}
	
	
	for ( k=0 ; k < val; k += 1 )
	{
		thePlayer.AddSkill(S_Sword_1 );
		thePlayer.AddSkill(S_Sword_2 );
		thePlayer.AddSkill(S_Sword_3 );
		thePlayer.AddSkill(S_Sword_4 );
		thePlayer.AddSkill(S_Sword_5 );

		thePlayer.AddSkill(S_Magic_1 );
		thePlayer.AddSkill(S_Magic_2 );
		thePlayer.AddSkill(S_Magic_3 );
		thePlayer.AddSkill(S_Magic_4 );
		thePlayer.AddSkill(S_Magic_5 );

		thePlayer.AddSkill(S_Alchemy_1);
		thePlayer.AddSkill(S_Alchemy_2);
		thePlayer.AddSkill(S_Alchemy_3);
		thePlayer.AddSkill(S_Alchemy_4);
		thePlayer.AddSkill(S_Alchemy_5);
		
		thePlayer.AddSkill(S_Sword_s01 );
		thePlayer.AddSkill(S_Sword_s02 );
		thePlayer.AddSkill(S_Sword_s03 );
		thePlayer.AddSkill(S_Sword_s04 );
		thePlayer.AddSkill(S_Sword_s05 );
		thePlayer.AddSkill(S_Sword_s06 );
		thePlayer.AddSkill(S_Sword_s07 );
		thePlayer.AddSkill(S_Sword_s08 );
		thePlayer.AddSkill(S_Sword_s09 );
		thePlayer.AddSkill(S_Sword_s10);
		thePlayer.AddSkill(S_Sword_s11);
		thePlayer.AddSkill(S_Sword_s12);
		thePlayer.AddSkill(S_Sword_s13);
		thePlayer.AddSkill(S_Sword_s15);
		thePlayer.AddSkill(S_Sword_s16);
		thePlayer.AddSkill(S_Sword_s17);
		thePlayer.AddSkill(S_Sword_s18);
		thePlayer.AddSkill(S_Sword_s19);
		thePlayer.AddSkill(S_Sword_s20);
		thePlayer.AddSkill(S_Sword_s21);
		
		thePlayer.AddSkill(S_Magic_s01 );
		thePlayer.AddSkill(S_Magic_s02 );
		thePlayer.AddSkill(S_Magic_s03 );
		thePlayer.AddSkill(S_Magic_s04 );
		thePlayer.AddSkill(S_Magic_s05 );
		thePlayer.AddSkill(S_Magic_s06 );
		thePlayer.AddSkill(S_Magic_s07 );
		thePlayer.AddSkill(S_Magic_s08 );
		thePlayer.AddSkill(S_Magic_s09 );
		thePlayer.AddSkill(S_Magic_s10);
		thePlayer.AddSkill(S_Magic_s11);
		thePlayer.AddSkill(S_Magic_s12);
		thePlayer.AddSkill(S_Magic_s13);
		thePlayer.AddSkill(S_Magic_s14);
		thePlayer.AddSkill(S_Magic_s15);
		thePlayer.AddSkill(S_Magic_s16);
		thePlayer.AddSkill(S_Magic_s17);
		thePlayer.AddSkill(S_Magic_s18);
		thePlayer.AddSkill(S_Magic_s19);
		thePlayer.AddSkill(S_Magic_s20);
		
		thePlayer.AddSkill(S_Alchemy_s01);
		thePlayer.AddSkill(S_Alchemy_s02 );
		thePlayer.AddSkill(S_Alchemy_s03 );
		thePlayer.AddSkill(S_Alchemy_s04 );
		thePlayer.AddSkill(S_Alchemy_s05 );
		thePlayer.AddSkill(S_Alchemy_s06 );
		thePlayer.AddSkill(S_Alchemy_s07 );
		thePlayer.AddSkill(S_Alchemy_s08 );
		thePlayer.AddSkill(S_Alchemy_s09 );
		thePlayer.AddSkill(S_Alchemy_s10);
		thePlayer.AddSkill(S_Alchemy_s11);
		thePlayer.AddSkill(S_Alchemy_s12);
		thePlayer.AddSkill(S_Alchemy_s13);
		thePlayer.AddSkill(S_Alchemy_s14);
		thePlayer.AddSkill(S_Alchemy_s15);
		thePlayer.AddSkill(S_Alchemy_s16);
		thePlayer.AddSkill(S_Alchemy_s17);
		thePlayer.AddSkill(S_Alchemy_s18);
		thePlayer.AddSkill(S_Alchemy_s19);
		thePlayer.AddSkill(S_Alchemy_s20);
		
		
		thePlayer.AddSkill(S_Perk_01);
		thePlayer.AddSkill(S_Perk_02);
		thePlayer.AddSkill(S_Perk_03);
		thePlayer.AddSkill(S_Perk_04);
		thePlayer.AddSkill(S_Perk_05);
		thePlayer.AddSkill(S_Perk_06);
		thePlayer.AddSkill(S_Perk_07);
		thePlayer.AddSkill(S_Perk_08);
		thePlayer.AddSkill(S_Perk_09);
		thePlayer.AddSkill(S_Perk_10);
		thePlayer.AddSkill(S_Perk_11);
		thePlayer.AddSkill(S_Perk_12);
		thePlayer.AddSkill(S_Perk_13);
		thePlayer.AddSkill(S_Perk_14);
		thePlayer.AddSkill(S_Perk_15);
		thePlayer.AddSkill(S_Perk_16);
		thePlayer.AddSkill(S_Perk_17);
		thePlayer.AddSkill(S_Perk_18);
		thePlayer.AddSkill(S_Perk_19);
		thePlayer.AddSkill(S_Perk_20);
		thePlayer.AddSkill(S_Perk_21);
		thePlayer.AddSkill(S_Perk_22);
	}
}

exec function secretgwint(optional deckIndex : int)
{
	var gwintManager:CR4GwintManager;
	gwintManager = theGame.GetGwintManager();
	gwintManager.setDoubleAIEnabled(false);
	
	if (deckIndex)
	{
		gwintManager.SetEnemyDeckIndex(deckIndex);
	}
	
	gwintManager.testMatch = true;
	
	gwintManager.SetForcedFaction(GwintFaction_Neutral);

	if (gwintManager.GetHasDoneTutorial())
	{
		gwintManager.gameRequested = true;
		theGame.RequestMenu( 'DeckBuilder' );
	}
	else
	{
		theGame.RequestMenu( 'GwintGame' );
	}
}

exec function setAIDeck(deckName : name)
{
	theGame.GetGwintManager().SetEnemyDeckByName(deckName);
}

exec function secretgwintAI()
{
	var gwintManager:CR4GwintManager;
	gwintManager = theGame.GetGwintManager();
	
	gwintManager.testMatch = true;
	gwintManager.setDoubleAIEnabled(true);
	
	theGame.RequestMenu( 'GwintGame' );
}

exec function secretdeckbuilder()
{
	var gwintManager:CR4GwintManager;
	gwintManager = theGame.GetGwintManager();
	
	gwintManager.testMatch = true;
	theGame.RequestMenu( 'DeckBuilder' );
}

exec function resetDecks()
{
	theGame.GetGwintManager().OnGwintSetupNewgame();
}

exec function winGwint( result : bool )
{
	theGame.GetGuiManager().GetRootMenu().CloseMenu();
	if (result)
	{
	thePlayer.SetGwintMinigameState( EMS_End_PlayerWon );
	}
	else
	{
	thePlayer.SetGwintMinigameState( EMS_End_PlayerLost );
	}
}

exec function winGwintPanel( result : int )
{
	var manager : CR4GuiManager;
	var gwintMenu : CR4GwintGameMenu;
	
	manager = (CR4GuiManager)theGame.GetGuiManager();
	if ( manager )
	{
		gwintMenu = (CR4GwintGameMenu)manager.GetRootMenu();
		if ( gwintMenu )
		{
			gwintMenu.EndGwintMatch( result );
		}
	}
}

exec function unlockDeck( val : int)
{
	theGame.GetGwintManager().UnlockDeck(val);
	theGame.GetGwintManager().SetSelectedPlayerDeck(val);
}

exec function addCard( cardID : int )
{
	theGame.GetGwintManager().AddCardToCollection(cardID);
}

exec function addCardByName( cardName : name )
{
	GetWitcherPlayer().AddGwentCard( cardName, 1 );
}

exec function givecards ( val : name )
{
	switch ( val )
	{
		case 'nilfgaard' :
		{
			thePlayer.inv.AddAnItem( 'gwint_card_impera_brigade',3);
			thePlayer.inv.AddAnItem( 'gwint_card_cynthia',1);
			thePlayer.inv.AddAnItem( 'gwint_card_letho',1);
			thePlayer.inv.AddAnItem( 'gwint_card_archer_support',2);
			thePlayer.inv.AddAnItem( 'gwint_card_siege_engineer',1);
			thePlayer.inv.AddAnItem( 'gwint_card_assire',1);
			thePlayer.inv.AddAnItem( 'gwint_card_fringilla',1);
			thePlayer.inv.AddAnItem( 'gwint_card_nauzicaa',1);
			thePlayer.inv.AddAnItem( 'gwint_card_black_archer',1);
			thePlayer.inv.AddAnItem( 'gwint_card_siege_support',1);
			thePlayer.inv.AddAnItem( 'gwint_card_menno',1);
			break;
		}
		case 'monsters' :
		{
			thePlayer.inv.AddAnItem( 'gwint_card_imlerith',1);
			thePlayer.inv.AddAnItem( 'gwint_card_katakan',1);
			thePlayer.inv.AddAnItem( 'gwint_card_bruxa',1);
			thePlayer.inv.AddAnItem( 'gwint_card_garkain',1);
			thePlayer.inv.AddAnItem( 'gwint_card_fleder',1);
			thePlayer.inv.AddAnItem( 'gwint_card_ghoul',2);
			thePlayer.inv.AddAnItem( 'gwint_card_nekker',1);
			thePlayer.inv.AddAnItem( 'gwint_card_grave_hag',1);
			thePlayer.inv.AddAnItem( 'gwint_card_fire_elemental',1);
			thePlayer.inv.AddAnItem( 'gwint_card_fogling',1);
			thePlayer.inv.AddAnItem( 'gwint_card_wyvern',1);
			thePlayer.inv.AddAnItem( 'gwint_card_leshan',1);
			thePlayer.inv.AddAnItem( 'gwint_card_witch_velen',2);
			thePlayer.inv.AddAnItem( 'gwint_card_arachas',3);
			break;			
			
		}
		case 'scoia' :
		{
			thePlayer.inv.AddAnItem( 'gwint_card_saskia',1);
			thePlayer.inv.AddAnItem( 'gwint_card_havekar_support',2);
			thePlayer.inv.AddAnItem( 'gwint_card_mahakam',4);
			thePlayer.inv.AddAnItem( 'gwint_card_isengrim',1);
			thePlayer.inv.AddAnItem( 'gwint_card_havekar_nurse',2);
			thePlayer.inv.AddAnItem( 'gwint_card_barclay',1);
			thePlayer.inv.AddAnItem( 'gwint_card_dennis',1);
			thePlayer.inv.AddAnItem( 'gwint_card_elf_skirmisher',1);
			thePlayer.inv.AddAnItem( 'gwint_card_dol_infantry',1);
			thePlayer.inv.AddAnItem( 'gwint_card_vrihedd_brigade',1);
			break;	
			
		}
		case 'kingdoms' :
		{
			thePlayer.inv.AddAnItem( 'gwint_card_thaler',1);
			thePlayer.inv.AddAnItem( 'gwint_card_blue_stripes',3);
			thePlayer.inv.AddAnItem( 'gwint_card_poor_infantry',1);
			thePlayer.inv.AddAnItem( 'gwint_card_trebuchet',1);
			thePlayer.inv.AddAnItem( 'gwint_card_natalis',1);
			thePlayer.inv.AddAnItem( 'gwint_card_esterad',1);
			thePlayer.inv.AddAnItem( 'gwint_card_siege_tower',2);
			thePlayer.inv.AddAnItem( 'gwint_card_crinfrid',2);
			thePlayer.inv.AddAnItem( 'gwint_card_kaedwen',2);
			thePlayer.inv.AddAnItem( 'gwint_card_witch_hunters',1);
			thePlayer.inv.AddAnItem( 'gwint_card_ballista_officer',1);
			thePlayer.inv.AddAnItem( 'gwint_card_ballista',1);
			thePlayer.inv.AddAnItem( 'gwint_card_stennis',1);
			thePlayer.inv.AddAnItem( 'gwint_card_siegfried',1);
			break;	
			
		}
		case 'skellige' :
		{
			thePlayer.inv.AddAnItem( 'gwint_card_king_bran_bronze', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_hemdal', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_hjalmar', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_cerys', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_ermion', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_draig', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_holger_blackhand', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_madman_lugos', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_donar_an_hindar', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_udalryk', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_birna_bran', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_blueboy_lugos', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_svanrige', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_olaf', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_berserker', 4 );
			thePlayer.inv.AddAnItem( 'gwint_card_young_berserker', 4 );
			thePlayer.inv.AddAnItem( 'gwint_card_clan_an_craite_warrior', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_clan_tordarroch_armorsmith', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_clan_heymaey_skald', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_light_drakkar', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_war_drakkar', 4 );
			thePlayer.inv.AddAnItem( 'gwint_card_clan_brokvar_archer', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_clan_drummond_shieldmaiden', 4 );
			thePlayer.inv.AddAnItem( 'gwint_card_clan_dimun_pirate', 1 );
			thePlayer.inv.AddAnItem( 'gwint_card_cock', 3 );
			thePlayer.inv.AddAnItem( 'gwint_card_mushroom', 3 );
		}
	}
}

exec function specials(optional off : bool, optional force : bool)
{
	GetWitcherPlayer().Debug_EquipTestingSkills(!off, force);
}

exec function remactlocks(optional action : EInputActionBlock, optional all : bool)
{
	thePlayer.Debug_ClearAllActionLocks(action, all);
}

exec function testhorse( level : int)
{
	var id    : SItemUniqueId;
	var newID : SItemUniqueId;
	
	var arg   : array<SItemUniqueId>;
	var eqId  : SItemUniqueId;
	
	switch (level)
	{
	default:
	case 1:
		thePlayer.inv.AddAnItem( 'Horse Bag 1', 1);
		thePlayer.inv.AddAnItem( 'Horse Blinder 1', 1);
		 thePlayer.inv.AddAnItem( 'Horse Saddle 1', 1);
		break;
	case 2:
		thePlayer.inv.AddAnItem( 'Horse Bag 2', 1);
		thePlayer.inv.AddAnItem( 'Horse Blinder 2', 1);
		thePlayer.inv.AddAnItem( 'Horse Saddle 2', 1);
		break;
	case 3:
		thePlayer.inv.AddAnItem( 'Horse Bag 3', 1);
		thePlayer.inv.AddAnItem( 'Horse Blinder 3', 1);
		thePlayer.inv.AddAnItem( 'Horse Saddle 3', 1);
		break;
	case 4:
		thePlayer.inv.AddAnItem( 'Horse Bag 3', 1);
		thePlayer.inv.AddAnItem( 'Horse Blinder 3', 1);
		thePlayer.inv.AddAnItem( 'Horse Saddle 4', 1);
		break;
	}
	
	
}

exec function additemhorse(itemName : name, cnt : int)
{
	var arg   : array<SItemUniqueId>;
	var eqId : SItemUniqueId;
	var i : int;
	
	arg = thePlayer.inv.AddAnItem(itemName, cnt);
	
	for(i=0; i<arg.Size(); i+=1)
	{
		eqId = GetWitcherPlayer().GetHorseManager().MoveItemToHorse(arg[i]);		
		GetWitcherPlayer().GetHorseManager().EquipItem(eqId);
	}
}

exec function printhorse()
{
	var i : int;
	var val : float;
	var inv : CInventoryComponent;
	var items : array<SItemUniqueId>;
	var hm : W3HorseManager;

	hm = GetWitcherPlayer().GetHorseManager();
	inv = GetWitcherPlayer().GetHorseManager().GetInventoryComponent();
	inv.GetAllItems(items);
	for(i=0; i<items.Size(); i+=1)
	{
		LogChannel('HorseMgr', inv.GetItemName(items[i]) + " x" + inv.GetItemQuantity(items[i]));
	}
	
	val = CalculateAttributeValue(GetWitcherPlayer().GetHorseManager().GetHorseAttributeValue('vitality', false));
	LogChannel('HorseMgr', "Vitality: " + val);
	val = CalculateAttributeValue(GetWitcherPlayer().GetHorseManager().GetHorseAttributeValue('stamina', false));
	LogChannel('HorseMgr', "Stamina: " + val);
	val = CalculateAttributeValue(GetWitcherPlayer().GetHorseManager().GetHorseAttributeValue('panic', false));
	LogChannel('Panic', "Panic: " + val);
}

exec function testBeast()
{
	var i, j : int;
	var manager : CWitcherJournalManager;
	var resource : CJournalResource;
	var entryBase : CJournalBase;
	var childGroups : array<CJournalBase>;
	var childEntries : array<CJournalBase>;
	var descriptionGroup : CJournalCreatureDescriptionGroup;
	var descriptionEntry : CJournalCreatureDescriptionEntry;
	
	manager = theGame.GetJournalManager();
	
	resource = (CJournalResource)LoadResource( "BestiaryBasilisk" );
	
	
	if ( resource )
	{
		entryBase = resource.GetEntry();
		if ( entryBase )
		{
			manager.ActivateEntry( entryBase, JS_Active );

			
			manager.GetAllChildren( entryBase, childGroups );
			for ( i = 0; i < childGroups.Size(); i += 1 )
			{
				descriptionGroup = ( CJournalCreatureDescriptionGroup )childGroups[ i ];
				if ( descriptionGroup )
				{
					manager.GetAllChildren( descriptionGroup, childEntries );
					for ( j = 0; j < childEntries.Size(); j += 1 )
					{
						descriptionEntry = ( CJournalCreatureDescriptionEntry )childEntries[ j ];
						if ( descriptionEntry )
						{
							manager.ActivateEntry( descriptionEntry, JS_Active );
						}
					}
					return;
				}
			}
		}
	}
}

exec function scaleBubble( magicBubbleTag : name, desiredScale : float, scaleDuration : float )
{
	var entitesList : array<CEntity>;
	var magicBubble : W3MagicBubbleEntity;
	var i : int;
	
	theGame.GetEntitiesByTag( magicBubbleTag, entitesList );
	
	if ( entitesList.Size() <= 0 )
	{
		LogQuest( "Quest function <<ScaleMagicBubble>>: No entities with tag: '" + magicBubbleTag + "' was found!" );
		return;
	}
	
	for(i=0; i<entitesList.Size(); i+=1)
	{
		magicBubble = (W3MagicBubbleEntity)entitesList[i];
		if ( magicBubble )
		{
			magicBubble.ScaleOverTime( Vector(desiredScale,desiredScale,desiredScale), scaleDuration );
		}
	}
}

exec function eq_silver( sword_id : int, optional dir : name)
{	
	var swords 		: array<name>;
	var ids 		: array<SItemUniqueId>;
	var id			: SItemUniqueId;
	var i 			: int;
	var j 			: int;
	var inv 		: CInventoryComponent = thePlayer.inv;
	var temp_name 	: name;
	
	swords.PushBack( 'Viper School silver sword' );			
	swords.PushBack( 'Viper School silver sword' );			
	swords.PushBack( 'Lynx School silver sword' );			
	swords.PushBack( 'Lynx School silver sword 1' );		
	swords.PushBack( 'Lynx School silver sword 2' );		
	swords.PushBack( 'Lynx School silver sword 3' );		
	swords.PushBack( 'Gryphon School silver sword' );		
	swords.PushBack( 'Gryphon School silver sword 1' );		
	swords.PushBack( 'Gryphon School silver sword 2' );		
	swords.PushBack( 'Gryphon School silver sword 3' );		
	swords.PushBack( 'Bear School silver sword' );			
	swords.PushBack( 'Bear School silver sword 1' );		
	swords.PushBack( 'Bear School silver sword 2' );		
	swords.PushBack( 'Bear School silver sword 3' );		
	swords.PushBack( 'Wolf School silver sword' );			
	swords.PushBack( 'Wolf School silver sword 1' );		
	swords.PushBack( 'Wolf School silver sword 2' );		
	swords.PushBack( 'Wolf School silver sword 3' );		
	swords.PushBack( 'Dwarven silver sword 1' );			
	swords.PushBack( 'Dwarven silver sword 2' );			
	swords.PushBack( 'Gnomish silver sword 1' );			
	swords.PushBack( 'Gnomish silver sword 2' );			
	swords.PushBack( 'Elven silver sword 1' );				
	swords.PushBack( 'Elven silver sword 2' );				
	swords.PushBack( 'Silver sword 1' );					
	swords.PushBack( 'Silver sword 2' );					
	swords.PushBack( 'Silver sword 3' );					
	swords.PushBack( 'Silver sword 4' );					
	swords.PushBack( 'Silver sword 5' );					
	swords.PushBack( 'Silver sword 6' );					
	swords.PushBack( 'Silver sword 7' );					
	swords.PushBack( 'Silver sword 8' );					
	
	if ( dir == 'None' )
	{
		for ( i = 1; i < swords.Size(); i += 1 )
		{
			inv.RemoveItemByName(swords[i],1);
		}
	}
	
	if ( sword_id > 0 )
	{
		ids = inv.AddAnItem(swords[sword_id],1);
		thePlayer.EquipItem(ids[0]);
		Log("=== SELECTED SWORD NR. : " + sword_id + "  SWORD NAME: " + swords[sword_id]);
	}
	
	switch(dir)
	{
		case 'next' :
		{
			inv.GetItemEquippedOnSlot( EES_SilverSword, id );
			temp_name = inv.GetItemName( id );
			
			for ( j = 1; j < swords.Size(); j += 1 )
			{
				if ( swords[j] == temp_name )
				{
					for ( i = 1; i < swords.Size(); i += 1 )
						{
						inv.RemoveItemByName(swords[i],1);
						}
					ids = inv.AddAnItem( swords[j+1], 1 );
					thePlayer.EquipItem( ids[0] );
					Log("=== SELECTED SWORD NR. : " + (j+1) + "  SWORD NAME: " + swords[(j+1)]);
					break;
				}
			}
			break;
		}
		case 'prev' :
		{
			inv.GetItemEquippedOnSlot( EES_SilverSword, id );
			temp_name = inv.GetItemName( id );
			
			for ( j = 1; j < swords.Size(); j += 1 )
			{
				if (swords[j] == temp_name)
				{
					for ( i = 1; i < swords.Size(); i += 1 )
						{
						inv.RemoveItemByName(swords[i],1);
						}
					ids = inv.AddAnItem( swords[j-1], 1 );
					thePlayer.EquipItem( ids[0] );
					Log("=== SELECTED SWORD NR. : " + (j-1) + "  SWORD NAME: " + swords[(j-1)] );
					break;
				}
			}
			break;	
		}
		case 'None':	break;	
	}
	
	swords.Clear();
	ids.Clear();
}

exec function eq_steel( sword_id : int, optional dir : name)
{	
	var swords 		: array<name>;
	var ids 		: array<SItemUniqueId>;
	var id			: SItemUniqueId;
	var i 			: int;
	var j 			: int;
	var inv 		: CInventoryComponent = thePlayer.inv;
	var temp_name 	: name;
	
	swords.PushBack( 'Viper School steel sword' ) ;
	swords.PushBack( 'Viper School steel sword' ) ;
	swords.PushBack( 'Gryphon School steel sword' ) ;
	swords.PushBack( 'Gryphon School steel sword 1' ) ;
	swords.PushBack( 'Gryphon School steel sword 2' ) ;
	swords.PushBack( 'Gryphon School steel sword 3' ) ;
	swords.PushBack( 'Bear School steel sword' ) ;
	swords.PushBack( 'Bear School steel sword 1' ) ;
	swords.PushBack( 'Bear School steel sword 2' ) ;
	swords.PushBack( 'Bear School steel sword 3' ) ;
	swords.PushBack( 'Wolf School steel sword' ) ;
	swords.PushBack( 'Wolf School steel sword 1' ) ;
	swords.PushBack( 'Wolf School steel sword 2' ) ;
	swords.PushBack( 'Wolf School steel sword 3' ) ;
	swords.PushBack( 'Lynx School steel sword' ) ;
	swords.PushBack( 'Lynx School steel sword 1' ) ;
	swords.PushBack( 'Lynx School steel sword 2' ) ;
	swords.PushBack( 'Lynx School steel sword 3' ) ;
	swords.PushBack( 'No Mans Land sword 1' ) ;
	swords.PushBack( 'No Mans Land sword 1 q2' ) ;
	swords.PushBack( 'No Mans Land sword 2' ) ;
	swords.PushBack( 'No Mans Land sword 3' ) ;
	swords.PushBack( 'No Mans Land sword 4' ) ;
	swords.PushBack( 'Rusty Novigraadan sword' ) ;	
	swords.PushBack( 'Novigraadan sword 1' ) ;	
	swords.PushBack( 'Novigraadan sword 2' ) ;	
	swords.PushBack( 'Novigraadan sword 3' ) ;	
	swords.PushBack( 'Novigraadan sword 4' ) ;	
	swords.PushBack( 'Rusty Nilfgaardian sword' ) ;
	swords.PushBack( 'Nilfgaardian sword 1' ) ;
	swords.PushBack( 'Nilfgaardian sword 2' ) ;	
	swords.PushBack( 'Nilfgaardian sword 3' ) ;	
	swords.PushBack( 'Nilfgaardian sword 4' ) ;	
	swords.PushBack( 'Rusty Skellige sword' ) ;	
	swords.PushBack( 'Skellige sword 1' ) ;	
	swords.PushBack( 'Skellige sword 2' ) ;	
	swords.PushBack( 'Skellige sword 3' ) ;
	swords.PushBack( 'Skellige sword 4' ) ;	
	swords.PushBack( 'q402 Skellige sword 3' ) ;	
	swords.PushBack( 'Scoiatael sword 1' ) ;
	swords.PushBack( 'Scoiatael sword 2' ) ;
	swords.PushBack( 'Scoiatael sword 3' ) ;	
	swords.PushBack( 'Inquisitor sword 1' ) ;
	swords.PushBack( 'Inquisitor sword 2' ) ;
	swords.PushBack( 'Dwarven sword 1' ) ;
	swords.PushBack( 'Dwarven sword 2' ) ;
	swords.PushBack( 'Gnomish sword 1' ) ;
	swords.PushBack( 'Gnomish sword 2' ) ;
	swords.PushBack( 'Wild Hunt sword 1' ) ;
	swords.PushBack( 'Wild Hunt sword 2' ) ;
	swords.PushBack( 'Wild Hunt sword 3' ) ;
	swords.PushBack( 'Wild Hunt sword 4' ) ;
	swords.PushBack( 'Long Steel Sword' ) ;
	swords.PushBack( 'Short Steel Sword' ) ;
	swords.PushBack( 'Hjalmar_Short_Steel_Sword' ) ;
	swords.PushBack( 'Wooden sword' ) ;
	swords.PushBack( 'Short sword 1' ) ;
	swords.PushBack( 'Short sword 2' ) ;


	
	if ( dir == 'None' )
	{
		for ( i = 1; i < swords.Size(); i += 1 )
		{
			inv.RemoveItemByName(swords[i],1);
		}
	}
	
	if ( sword_id > 0 )
	{
		ids = inv.AddAnItem(swords[sword_id],1);
		thePlayer.EquipItem(ids[0]);
		Log("=== SELECTED SWORD NR. : " + sword_id + "  SWORD NAME: " + swords[sword_id]);
	}
	
	switch(dir)
	{
		case 'next' :
		{
			inv.GetItemEquippedOnSlot( EES_SteelSword, id );
			temp_name = inv.GetItemName( id );
			
			for ( j = 1; j < swords.Size(); j += 1 )
			{
				if ( swords[j] == temp_name )
				{
					for ( i = 1; i < swords.Size(); i += 1 )
						{
						inv.RemoveItemByName(swords[i],1);
						}
					ids = inv.AddAnItem( swords[j+1], 1 );
					thePlayer.EquipItem( ids[0] );
					Log("=== SELECTED SWORD NR. : " + (j+1) + "  SWORD NAME: " + swords[(j+1)]);
					break;
				}
			}
			break;
		}
		case 'prev' :
		{
			inv.GetItemEquippedOnSlot( EES_SteelSword, id );
			temp_name = inv.GetItemName( id );
			
			for ( j = 1; j < swords.Size(); j += 1 )
			{
				if (swords[j] == temp_name)
				{
					for ( i = 1; i < swords.Size(); i += 1 )
						{
						inv.RemoveItemByName(swords[i],1);
						}
					ids = inv.AddAnItem( swords[j-1], 1 );
					thePlayer.EquipItem( ids[0] );
					Log("=== SELECTED SWORD NR. : " + (j-1) + "  SWORD NAME: " + swords[(j-1)] );
					break;
				}
			}
			break;	
		}
		case 'None':	break;	
	}
	
	swords.Clear();
	ids.Clear();
}

exec function eq_steel_unique( sword_id : int, optional dir : name)
{	
	var swords 		: array<name>;
	var ids 		: array<SItemUniqueId>;
	var id			: SItemUniqueId;
	var i 			: int;
	var j 			: int;
	var inv 		: CInventoryComponent = thePlayer.inv;
	var temp_name 	: name;
	
	swords.PushBack( 'Angivare' ) ;
	swords.PushBack( 'Arbitrator' ) ;
	swords.PushBack( 'Ardaenye' ) ;
	swords.PushBack( 'Barbersurgeon' ) ;
	swords.PushBack( 'Beannshie' ) ;
	swords.PushBack( 'Blackunicorn' ) ;
	swords.PushBack( 'Caerme' ) ;
	swords.PushBack( 'Cheesecutter' );
	swords.PushBack( 'Dyaebl' ) ;
	swords.PushBack( 'Deireadh' ) ;
	swords.PushBack( 'Vynbleidd' ) ;
	swords.PushBack( 'Gwyhyr' ) ;
	swords.PushBack( 'Forgottenvransword' ) ;
	swords.PushBack( 'Harvall' ) ;
	swords.PushBack( 'Karabela' ) ;
	swords.PushBack( 'Princessxenthiasword' ) ;
	swords.PushBack( 'Robustswordofdolblathanna' ) ;
	swords.PushBack( 'Ashrune' ) ;
	swords.PushBack( 'Longclaw' ) ;
	swords.PushBack( 'Daystar' ) ;
	swords.PushBack( 'Devine' ) ;
	swords.PushBack( 'Bloedeaedd' ) ;
	swords.PushBack( 'Inis' ) ;
	swords.PushBack( 'Gwestog' ) ;
	swords.PushBack( 'Abarad' ) ;
	swords.PushBack( 'Wolf' ) ;
	swords.PushBack( 'Cleaver' ) ;
	swords.PushBack( 'Dancer' ) ;
	swords.PushBack( 'Headtaker' ) ;
	swords.PushBack( 'Mourner' ) ;
	swords.PushBack( 'Ultimatum' ) ;
	swords.PushBack( 'Caroline' ) ;
	swords.PushBack( 'Lune' ) ;
	swords.PushBack( 'WithcerSilverWolf' ) ;
	swords.PushBack( 'Gloryofthenorth' ) ;
	swords.PushBack( 'Torlara' ) ;
	
	if ( dir == 'None' )
	{
		for ( i = 1; i < swords.Size(); i += 1 )
		{
			inv.RemoveItemByName(swords[i],1);
		}
	}
	
	if ( sword_id > 0 )
	{
		ids = inv.AddAnItem(swords[sword_id],1);
		thePlayer.EquipItem(ids[0]);
		Log("=== SELECTED SWORD NR. : " + sword_id + "  SWORD NAME: " + swords[sword_id]);
	}
	
	switch(dir)
	{
		case 'next' :
		{
			inv.GetItemEquippedOnSlot( EES_SteelSword, id );
			temp_name = inv.GetItemName( id );
			
			for ( j = 1; j < swords.Size(); j += 1 )
			{
				if ( swords[j] == temp_name )
				{
					for ( i = 1; i < swords.Size(); i += 1 )
						{
						inv.RemoveItemByName(swords[i],1);
						}
					ids = inv.AddAnItem( swords[j+1], 1 );
					thePlayer.EquipItem( ids[0] );
					Log("=== SELECTED SWORD NR. : " + (j+1) + "  SWORD NAME: " + swords[(j+1)]);
					break;
				}
			}
			break;
		}
		case 'prev' :
		{
			inv.GetItemEquippedOnSlot( EES_SteelSword, id );
			temp_name = inv.GetItemName( id );
			
			for ( j = 1; j < swords.Size(); j += 1 )
			{
				if (swords[j] == temp_name)
				{
					for ( i = 1; i < swords.Size(); i += 1 )
						{
						inv.RemoveItemByName(swords[i],1);
						}
					ids = inv.AddAnItem( swords[j-1], 1 );
					thePlayer.EquipItem( ids[0] );
					Log("=== SELECTED SWORD NR. : " + (j-1) + "  SWORD NAME: " + swords[(j-1)] );
					break;
				}
			}
			break;	
		}
		case 'None':	break;	
	}
	
	swords.Clear();
	ids.Clear();
}

exec function eq_silver_unique( sword_id : int, optional dir : name)
{	
	var swords 		: array<name>;
	var ids 		: array<SItemUniqueId>;
	var id			: SItemUniqueId;
	var i 			: int;
	var j 			: int;
	var inv 		: CInventoryComponent = thePlayer.inv;
	var temp_name 	: name;
	
	swords.PushBack( 'Addandeith' ) ;
	swords.PushBack( 'Moonblade' ) ;
	swords.PushBack( 'Aerondight' ) ;
	swords.PushBack( 'Bloodsword' ) ;
	swords.PushBack( 'Deithwen' ) ;
	swords.PushBack( 'Fate' ) ;
	swords.PushBack( 'Gynvaelaedd' ) ;
	swords.PushBack( 'Naevdeseidhe' ) ;
	swords.PushBack( 'Bladeofys' ) ;
	swords.PushBack( 'Zerrikanterment' ) ;
	swords.PushBack( 'Anathema' ) ;
	swords.PushBack( 'Roseofaelirenn' ) ;
	swords.PushBack( 'Reachofthedamned' ) ;
	swords.PushBack( 'Azurewrath' ) ;
	swords.PushBack( 'Deargdeith' ) ;
	swords.PushBack( 'Arainne' ) ;
	swords.PushBack( 'Havcaaren' ) ;
	swords.PushBack( 'Loathen' ) ;
	swords.PushBack( 'Gynvael' ) ;
	swords.PushBack( 'Anth' ) ;
	swords.PushBack( 'Weeper' ) ;
	swords.PushBack( 'Virgin' ) ;
	swords.PushBack( 'Negotiator' ) ;
	swords.PushBack( 'Harpy' ) ;
	swords.PushBack( 'Tlareg' ) ;
	
	swords.PushBack( 'Breathofthenorth' ) ;
	swords.PushBack( 'Torzirael' ) ;

	
	if ( dir == 'None' )
	{
		for ( i = 1; i < swords.Size(); i += 1 )
		{
			inv.RemoveItemByName(swords[i],1);
		}
	}
	
	if ( sword_id > 0 )
	{
		ids = inv.AddAnItem(swords[sword_id],1);
		thePlayer.EquipItem(ids[0]);
		Log("=== SELECTED SWORD NR. : " + sword_id + "  SWORD NAME: " + swords[sword_id]);
	}
	
	switch(dir)
	{
		case 'next' :
		{
			inv.GetItemEquippedOnSlot( EES_SteelSword, id );
			temp_name = inv.GetItemName( id );
			
			for ( j = 1; j < swords.Size(); j += 1 )
			{
				if ( swords[j] == temp_name )
				{
					for ( i = 1; i < swords.Size(); i += 1 )
						{
						inv.RemoveItemByName(swords[i],1);
						}
					ids = inv.AddAnItem( swords[j+1], 1 );
					thePlayer.EquipItem( ids[0] );
					Log("=== SELECTED SWORD NR. : " + (j+1) + "  SWORD NAME: " + swords[(j+1)]);
					break;
				}
			}
			break;
		}
		case 'prev' :
		{
			inv.GetItemEquippedOnSlot( EES_SteelSword, id );
			temp_name = inv.GetItemName( id );
			
			for ( j = 1; j < swords.Size(); j += 1 )
			{
				if (swords[j] == temp_name)
				{
					for ( i = 1; i < swords.Size(); i += 1 )
						{
						inv.RemoveItemByName(swords[i],1);
						}
					ids = inv.AddAnItem( swords[j-1], 1 );
					thePlayer.EquipItem( ids[0] );
					Log("=== SELECTED SWORD NR. : " + (j-1) + "  SWORD NAME: " + swords[(j-1)] );
					break;
				}
			}
			break;	
		}
		case 'None':	break;	
	}
	
	swords.Clear();
	ids.Clear();
}

exec function activateAllGlossaryCharacters()
{
	var manager : CWitcherJournalManager;
	
	manager = theGame.GetJournalManager();
	
	activateJournalCharacterEntryWithAlias("CharactersAnabelle", manager);
	activateJournalCharacterEntryWithAlias("CharactersAnnaStenger", manager);
	activateJournalCharacterEntryWithAlias("CharactersArnvald", manager);
	activateJournalCharacterEntryWithAlias("CharactersAvallach", manager);
	activateJournalCharacterEntryWithAlias("CharactersBabcia", manager);
	activateJournalCharacterEntryWithAlias("CharactersBaron", manager);
	activateJournalCharacterEntryWithAlias("CharactersBirna", manager);
	activateJournalCharacterEntryWithAlias("CharactersBlueBoyLugos", manager);
	activateJournalCharacterEntryWithAlias("CharactersBrewess", manager);
	activateJournalCharacterEntryWithAlias("CharactersCaranthir", manager);
	activateJournalCharacterEntryWithAlias("CharactersCarduin", manager);
	activateJournalCharacterEntryWithAlias("CharactersCerys", manager);
	activateJournalCharacterEntryWithAlias("CharactersChapelle", manager);
	activateJournalCharacterEntryWithAlias("CharactersCirilla", manager);
	activateJournalCharacterEntryWithAlias("CharactersCorinetilly", manager);
	activateJournalCharacterEntryWithAlias("CharactersCrach", manager);
	activateJournalCharacterEntryWithAlias("CharactersDandelion", manager);
	activateJournalCharacterEntryWithAlias("CharactersDijkstra", manager);
	activateJournalCharacterEntryWithAlias("CharactersDonar", manager);
	activateJournalCharacterEntryWithAlias("CharactersDuchDrzewa", manager);
	activateJournalCharacterEntryWithAlias("CharactersDudu", manager);
	activateJournalCharacterEntryWithAlias("CharactersElihal", manager);
	activateJournalCharacterEntryWithAlias("CharactersEmhyrVarEmreis", manager);
	activateJournalCharacterEntryWithAlias("CharactersEredin", manager);
	activateJournalCharacterEntryWithAlias("CharactersEskel", manager);
	activateJournalCharacterEntryWithAlias("CharactersFeliciaCori", manager);
	activateJournalCharacterEntryWithAlias("CharactersFolan", manager);
	activateJournalCharacterEntryWithAlias("CharactersFringilla", manager);
	activateJournalCharacterEntryWithAlias("CharactersFugas", manager);
	activateJournalCharacterEntryWithAlias("CharactersGeels", manager);
	activateJournalCharacterEntryWithAlias("CharactersGeralt", manager);
	activateJournalCharacterEntryWithAlias("CharactersGraden", manager);
	activateJournalCharacterEntryWithAlias("CharactersGraham", manager);
	activateJournalCharacterEntryWithAlias("CharactersGuslarz", manager);
	activateJournalCharacterEntryWithAlias("CharactersHalbjorn", manager);
	activateJournalCharacterEntryWithAlias("CharactersHarald", manager);
	activateJournalCharacterEntryWithAlias("CharactersHendrik", manager);
	activateJournalCharacterEntryWithAlias("CharactersHjalmar", manager);
	activateJournalCharacterEntryWithAlias("CharactersHjort", manager);
	activateJournalCharacterEntryWithAlias("CharactersHolger", manager);
	activateJournalCharacterEntryWithAlias("CharactersHubert", manager);
	activateJournalCharacterEntryWithAlias("CharactersImlerith", manager);
	activateJournalCharacterEntryWithAlias("CharactersIrinaRenarde", manager);
	activateJournalCharacterEntryWithAlias("CharactersJanek", manager);
	activateJournalCharacterEntryWithAlias("CharactersJoachim", manager);
	activateJournalCharacterEntryWithAlias("CharactersKarlVarese", manager);
	activateJournalCharacterEntryWithAlias("CharactersKeira", manager);
	activateJournalCharacterEntryWithAlias("CharactersKrolZebrakow", manager);
	activateJournalCharacterEntryWithAlias("CharactersLambert", manager);
	activateJournalCharacterEntryWithAlias("CharactersLetho", manager);
	activateJournalCharacterEntryWithAlias("CharactersLugosMad", manager);
	activateJournalCharacterEntryWithAlias("CharactersLuizaLaValette", manager);
	activateJournalCharacterEntryWithAlias("CharactersMargarita", manager);
	activateJournalCharacterEntryWithAlias("CharactersMenge", manager);
	activateJournalCharacterEntryWithAlias("CharactersMousesack", manager);
	activateJournalCharacterEntryWithAlias("CharactersMysteriousElf", manager);
	activateJournalCharacterEntryWithAlias("CharactersNataniel", manager);
	activateJournalCharacterEntryWithAlias("CharactersOtrygg", manager);
	activateJournalCharacterEntryWithAlias("CharactersPhilippaEilhart", manager);
	activateJournalCharacterEntryWithAlias("CharactersPriscilla", manager);
	activateJournalCharacterEntryWithAlias("CharactersRadovid", manager);
	activateJournalCharacterEntryWithAlias("CharactersRoche", manager);
	activateJournalCharacterEntryWithAlias("CharactersSheala", manager);
	activateJournalCharacterEntryWithAlias("CharactersSvanrige", manager);
	activateJournalCharacterEntryWithAlias("CharactersTalar", manager);
	activateJournalCharacterEntryWithAlias("CharactersTamara", manager);
	activateJournalCharacterEntryWithAlias("CharactersTavar", manager);
	activateJournalCharacterEntryWithAlias("CharactersTriss", manager);
	activateJournalCharacterEntryWithAlias("CharactersTrollBart", manager);
	activateJournalCharacterEntryWithAlias("CharactersUdalryk", manager);
	activateJournalCharacterEntryWithAlias("CharactersUma", manager);
	activateJournalCharacterEntryWithAlias("CharactersVes", manager);
	activateJournalCharacterEntryWithAlias("CharactersVesemir", manager);
	activateJournalCharacterEntryWithAlias("CharactersVigi", manager);
	activateJournalCharacterEntryWithAlias("CharactersVimme", manager);
	activateJournalCharacterEntryWithAlias("CharactersVoorhis", manager);
	activateJournalCharacterEntryWithAlias("CharactersWeavess", manager);
	activateJournalCharacterEntryWithAlias("CharactersWhisperess", manager);
	activateJournalCharacterEntryWithAlias("CharactersWhoreson", manager);
	activateJournalCharacterEntryWithAlias("CharactersWszerad", manager);
	activateJournalCharacterEntryWithAlias("CharactersYennefer", manager);
	activateJournalCharacterEntryWithAlias("CharactersZoltan", manager);
}




exec function activateAllGlossaryEncyclopedia()
{
	var manager : CWitcherJournalManager;
	
	manager = theGame.GetJournalManager();
	
	activateJournalGlossaryGroupWithAlias("GlossaryDebugGlossary", manager);
	activateJournalGlossaryGroupWithAlias("GlossaryWitchers", manager);
}

exec function activateAllGlossaryStorybook()
{
	var manager : CWitcherJournalManager;
	
	manager = theGame.GetJournalManager();
	
	
	activateJournalStoryBookPageEntryWithAlias("StoryBookPrologueEntry01", manager);
	activateJournalStoryBookPageEntryWithAlias("StoryBookPrologueEntry02", manager);
	
	
	activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry01", manager);
	activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry02", manager);
	activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry03", manager);
	activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry04", manager);
	activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry05", manager);
	activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry06", manager);
	activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry07", manager);
	activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry08", manager);
	activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry09", manager);
	activateJournalStoryBookPageEntryWithAlias("StoryBookChapter1Entry10", manager);

	
	activateJournalStoryBookPageEntryWithAlias("StoryBookChapter2Entry01", manager);
	activateJournalStoryBookPageEntryWithAlias("StoryBookChapter2Entry02", manager);
	activateJournalStoryBookPageEntryWithAlias("StoryBookChapter2Entry03", manager);

	
	activateJournalStoryBookPageEntryWithAlias("StoryBookChapter3Entry01", manager);
	activateJournalStoryBookPageEntryWithAlias("StoryBookChapter3Entry02", manager);
	activateJournalStoryBookPageEntryWithAlias("StoryBookChapter3Entry03", manager);
	activateJournalStoryBookPageEntryWithAlias("StoryBookChapter3Entry04", manager);
}

exec function activateAllGlossaryBeastiary()
{
	var manager : CWitcherJournalManager;
	
	manager = theGame.GetJournalManager();
	
	activateJournalBestiaryEntryWithAlias("BestiaryElemental", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryGolem", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryIceGolem", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryFireElemental", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryWhMinion", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryDzinn", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryGargoyle", manager);

	activateJournalBestiaryEntryWithAlias("BestiaryWerebear", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryMiscreant", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryWerewolf", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryLycanthrope", manager);

	activateJournalBestiaryEntryWithAlias("BestiaryEndriaga", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryCrabSpider", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryArmoredArachas", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryPoisonousArachas", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryEndriagaTruten", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryEndriagaWorker", manager);

	activateJournalBestiaryEntryWithAlias("BestiaryAlghoul", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryGhoul", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryGreaterRotFiend", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryDrowner", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryFogling", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryGraveHag", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryWaterHag", manager);

	activateJournalBestiaryEntryWithAlias("BestiaryBasilisk", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryCockatrice", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryForktail", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryWyvern", manager);

	activateJournalBestiaryEntryWithAlias("BestiaryNoonwright", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryMoonwright", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryPesta", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryHim", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryWraith", manager);

	activateJournalBestiaryEntryWithAlias("BestiaryWolf", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryBear", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryDog", manager);

	activateJournalBestiaryEntryWithAlias("BestiaryKatakan", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryEkkima", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryHigherVampire", manager);

	activateJournalBestiaryEntryWithAlias("BestiaryCyclop", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryIceGiant", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryNekker", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryIceTroll", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryCaveTroll", manager);

	activateJournalBestiaryEntryWithAlias("BestiaryErynia", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryGriffin", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryHarpy", manager);
	activateJournalBestiaryEntryWithAlias("BestiarySiren", manager);
	activateJournalBestiaryEntryWithAlias("BestiarySuccubus", manager);

	activateJournalBestiaryEntryWithAlias("BestiaryLeshy", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryBies", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryCzart", manager);
	activateJournalBestiaryEntryWithAlias("BestiarySilvan", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryWitches", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryGolding", manager);
	
}

exec function testJournal()
{
	activateJournalBestiaryEntryWithAlias(      "BestiaryElemental",        theGame.GetJournalManager() );
	activateJournalStoryBookPageEntryWithAlias( "StoryBookPrologueEntry01", theGame.GetJournalManager() );
	activateJournalCharacterEntryWithAlias(     "CharactersEredin",         theGame.GetJournalManager() );
	activateJournalGlossaryGroupWithAlias(      "GlossaryDebugGlossary",    theGame.GetJournalManager() );
}

exec function openHorseInv()
{
	var initDataObject:W3MenuInitData = new W3MenuInitData in theGame.GetGuiManager();
	initDataObject.setDefaultState('SingleHorseInventory');
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu', initDataObject );
}

exec function dealDamageToBoat( dmg : float, index : int, optional globalHitPos : Vector )
{
	thePlayer.DealDamageToBoat( dmg, index, globalHitPos );
}
exec function EmitReactionEvent( reactionEventName : name, lifetime : float, distance : float, interval : float, recipients : int  )
{
	theGame.GetBehTreeReactionManager().CreateReactionEvent( thePlayer, reactionEventName, lifetime, distance, interval, recipients, false, true );
}

exec function test61257()
{
	var entities		: array< CGameplayEntity >;
	var i 				: int;
	var poster			: W3Poster;
	var component		: CComponent;
		
	FindGameplayEntitiesInRange( entities, thePlayer, 50, 1000 );
	for ( i = 0; i < entities.Size(); i += 1 )
	{
		poster = (W3Poster) entities[ i ];
		if ( poster )
		{
			component = poster.GetComponentByClassName( 'CInteractionComponent' );
			if ( component )
				LogChannel( 'Bug61257', "Poster with CInteractionComponent found [" + poster.GetName() + "]" );
			else
				LogChannel( 'Bug61257', "Poster with NO CInteractionComponent found [" + poster.GetName() + "]" );
		}
	}
}

exec function SetRunType( runType : int )
{
	thePlayer.SetBehaviorVariable( 'runType', (float)runType );
}
exec function XDPPrintUserStats( statisticName : String )
{
	theTelemetry.XDPPrintUserStats( statisticName );
}

exec function XDPPrintUserAchievement( achievementName : String )
{
	theTelemetry.XDPPrintUserAchievement( achievementName );
}

exec function testunlockachievement( achievementName : name )
{
	theGame.UnlockAchievement( achievementName );
}

exec function sysmsg(optional hide : bool)
{
	if (hide)
	{
		theGame.GetGuiManager().HideUserDialog(0);
	}
	else
	{
		theGame.GetGuiManager().ShowUserDialog( 0, "TEST", "error_message_no_controller_x1", UDB_OkCancel);
	}
}

exec function sysmsgtst()
{
	theGame.GetGuiManager().HideUserDialog( 0);
	theGame.GetGuiManager().ShowUserDialog( 0, "TEST", "error_message_no_controller_x1", UDB_OkCancel);
	theGame.GetGuiManager().HideUserDialog( 0);
}

exec function addgwintcards( optional deck : string )
{
	switch (deck)
	{
		case "1":
		case "NK":
		case "Northern":
		case "Northern Kingdoms":
			AddDeckNK();
			break;
		case "2":
		case "Nilf":
		case "Nilfgaard":
			AddDeckNilf();
			break;
		case "3":
		case "Scoia":
		case "Scoia'tael":
			AddDeckScoia();
			break;
		case "4": 
		case "Monst":
		case "Monster":
		case "Monsters":
			AddDeckMonst();
			break;
		case "5":
		case "Ske":
		case "Skellige":
			AddDeckSke();
			break;
		case "6":
		case "Neutral":
			AddDeckNeutral();
			break;
		default:
			AddDeckNeutral();
			AddDeckNK();
			AddDeckNilf();
			AddDeckScoia();
			AddDeckMonst();
			AddDeckSke();
			break;
	}	
}

function AddDeckNK()
{
	
	theGame.GetGwintManager().AddCardToCollection( 1002 ); 
	theGame.GetGwintManager().AddCardToCollection( 1003 ); 
	theGame.GetGwintManager().AddCardToCollection( 1004 ); 
	theGame.GetGwintManager().AddCardToCollection( 1005 ); 
	theGame.GetGwintManager().AddCardToCollection( 100 ); 
	theGame.GetGwintManager().AddCardToCollection( 101 ); 
	theGame.GetGwintManager().AddCardToCollection( 102 ); 
	theGame.GetGwintManager().AddCardToCollection( 103 ); 
	theGame.GetGwintManager().AddCardToCollection( 105 ); 
	theGame.GetGwintManager().AddCardToCollection( 109 ); 
	theGame.GetGwintManager().AddCardToCollection( 126 ); 
	theGame.GetGwintManager().AddCardToCollection( 127 ); 
	theGame.GetGwintManager().AddCardToCollection( 130 ); 
	theGame.GetGwintManager().AddCardToCollection( 130 ); 
	theGame.GetGwintManager().AddCardToCollection( 130 ); 
	theGame.GetGwintManager().AddCardToCollection( 140 ); 
	theGame.GetGwintManager().AddCardToCollection( 140 ); 
	theGame.GetGwintManager().AddCardToCollection( 160 ); 
	theGame.GetGwintManager().AddCardToCollection( 170 ); 
	
}

function AddDeckNilf()
{
	theGame.GetGwintManager().AddCardToCollection( 2002 ); 
	theGame.GetGwintManager().AddCardToCollection( 2003 ); 
	theGame.GetGwintManager().AddCardToCollection( 2004 ); 
	theGame.GetGwintManager().AddCardToCollection( 2005 ); 
	theGame.GetGwintManager().AddCardToCollection( 200 ); 
	theGame.GetGwintManager().AddCardToCollection( 201 ); 
	theGame.GetGwintManager().AddCardToCollection( 202 ); 
	theGame.GetGwintManager().AddCardToCollection( 203 ); 
	theGame.GetGwintManager().AddCardToCollection( 205 ); 
	theGame.GetGwintManager().AddCardToCollection( 206 ); 
	theGame.GetGwintManager().AddCardToCollection( 207 ); 
	theGame.GetGwintManager().AddCardToCollection( 208 ); 
	theGame.GetGwintManager().AddCardToCollection( 209 ); 
	theGame.GetGwintManager().AddCardToCollection( 210 ); 
	theGame.GetGwintManager().AddCardToCollection( 211 ); 
	theGame.GetGwintManager().AddCardToCollection( 212 ); 
	theGame.GetGwintManager().AddCardToCollection( 213 ); 
	theGame.GetGwintManager().AddCardToCollection( 214 ); 
	theGame.GetGwintManager().AddCardToCollection( 215 ); 
	theGame.GetGwintManager().AddCardToCollection( 217 ); 
	theGame.GetGwintManager().AddCardToCollection( 218 ); 
	theGame.GetGwintManager().AddCardToCollection( 219 ); 
	theGame.GetGwintManager().AddCardToCollection( 220 ); 
	theGame.GetGwintManager().AddCardToCollection( 221 ); 
	theGame.GetGwintManager().AddCardToCollection( 230 ); 
	theGame.GetGwintManager().AddCardToCollection( 231 ); 
	theGame.GetGwintManager().AddCardToCollection( 235 ); 
	theGame.GetGwintManager().AddCardToCollection( 236 ); 
	theGame.GetGwintManager().AddCardToCollection( 240 ); 
	theGame.GetGwintManager().AddCardToCollection( 241 ); 
	theGame.GetGwintManager().AddCardToCollection( 245 ); 
	theGame.GetGwintManager().AddCardToCollection( 245 ); 
	theGame.GetGwintManager().AddCardToCollection( 245 ); 
	theGame.GetGwintManager().AddCardToCollection( 245 ); 
	theGame.GetGwintManager().AddCardToCollection( 250 ); 
	theGame.GetGwintManager().AddCardToCollection( 250 ); 
	theGame.GetGwintManager().AddCardToCollection( 250 ); 
	theGame.GetGwintManager().AddCardToCollection( 255 ); 
	theGame.GetGwintManager().AddCardToCollection( 260 ); 
	theGame.GetGwintManager().AddCardToCollection( 261 ); 
	theGame.GetGwintManager().AddCardToCollection( 265 ); 
}

function AddDeckScoia()
{
	theGame.GetGwintManager().AddCardToCollection( 3002 ); 
	theGame.GetGwintManager().AddCardToCollection( 3003 ); 
	theGame.GetGwintManager().AddCardToCollection( 3004 ); 
	theGame.GetGwintManager().AddCardToCollection( 3005 ); 
	theGame.GetGwintManager().AddCardToCollection( 300 ); 
	theGame.GetGwintManager().AddCardToCollection( 301 ); 
	theGame.GetGwintManager().AddCardToCollection( 302 ); 
	theGame.GetGwintManager().AddCardToCollection( 303 ); 
	theGame.GetGwintManager().AddCardToCollection( 305 ); 
	theGame.GetGwintManager().AddCardToCollection( 306 ); 
	theGame.GetGwintManager().AddCardToCollection( 307 ); 
	theGame.GetGwintManager().AddCardToCollection( 308 ); 
	theGame.GetGwintManager().AddCardToCollection( 309 ); 
	theGame.GetGwintManager().AddCardToCollection( 310 ); 
	theGame.GetGwintManager().AddCardToCollection( 311 ); 
	theGame.GetGwintManager().AddCardToCollection( 312 ); 
	theGame.GetGwintManager().AddCardToCollection( 313 ); 
	theGame.GetGwintManager().AddCardToCollection( 320 ); 
	theGame.GetGwintManager().AddCardToCollection( 321 ); 
	theGame.GetGwintManager().AddCardToCollection( 322 ); 
	theGame.GetGwintManager().AddCardToCollection( 325 ); 
	theGame.GetGwintManager().AddCardToCollection( 326 ); 
	theGame.GetGwintManager().AddCardToCollection( 330 ); 
	theGame.GetGwintManager().AddCardToCollection( 331 ); 
	theGame.GetGwintManager().AddCardToCollection( 332 ); 
	theGame.GetGwintManager().AddCardToCollection( 335 ); 
	theGame.GetGwintManager().AddCardToCollection( 336 ); 
	theGame.GetGwintManager().AddCardToCollection( 337 ); 
	theGame.GetGwintManager().AddCardToCollection( 340 ); 
	theGame.GetGwintManager().AddCardToCollection( 341 ); 
	theGame.GetGwintManager().AddCardToCollection( 342 ); 
	theGame.GetGwintManager().AddCardToCollection( 343 ); 
	theGame.GetGwintManager().AddCardToCollection( 344 ); 
	theGame.GetGwintManager().AddCardToCollection( 350 ); 
	theGame.GetGwintManager().AddCardToCollection( 351 ); 
	theGame.GetGwintManager().AddCardToCollection( 352 ); 
	theGame.GetGwintManager().AddCardToCollection( 355 ); 
	theGame.GetGwintManager().AddCardToCollection( 360 ); 
	theGame.GetGwintManager().AddCardToCollection( 365 ); 
	theGame.GetGwintManager().AddCardToCollection( 366 ); 
	theGame.GetGwintManager().AddCardToCollection( 367 ); 
	theGame.GetGwintManager().AddCardToCollection( 368 ); 
}

function AddDeckMonst()
{
	theGame.GetGwintManager().AddCardToCollection( 4002 ); 
	theGame.GetGwintManager().AddCardToCollection( 4003 ); 
	theGame.GetGwintManager().AddCardToCollection( 4004 ); 
	theGame.GetGwintManager().AddCardToCollection( 4005 ); 
	theGame.GetGwintManager().AddCardToCollection( 400 ); 
	theGame.GetGwintManager().AddCardToCollection( 401 ); 
	theGame.GetGwintManager().AddCardToCollection( 402 ); 
	theGame.GetGwintManager().AddCardToCollection( 403 ); 
	theGame.GetGwintManager().AddCardToCollection( 405 ); 
	theGame.GetGwintManager().AddCardToCollection( 407 ); 
	theGame.GetGwintManager().AddCardToCollection( 410 ); 
	theGame.GetGwintManager().AddCardToCollection( 413 ); 
	theGame.GetGwintManager().AddCardToCollection( 415 ); 
	theGame.GetGwintManager().AddCardToCollection( 417 ); 
	theGame.GetGwintManager().AddCardToCollection( 420 ); 
	theGame.GetGwintManager().AddCardToCollection( 423 ); 
	theGame.GetGwintManager().AddCardToCollection( 425 ); 
	theGame.GetGwintManager().AddCardToCollection( 427 ); 
	theGame.GetGwintManager().AddCardToCollection( 430 ); 
	theGame.GetGwintManager().AddCardToCollection( 433 ); 
	theGame.GetGwintManager().AddCardToCollection( 435 ); 
	theGame.GetGwintManager().AddCardToCollection( 437 ); 
	theGame.GetGwintManager().AddCardToCollection( 440 ); 
	theGame.GetGwintManager().AddCardToCollection( 443 ); 
	theGame.GetGwintManager().AddCardToCollection( 445 ); 
	theGame.GetGwintManager().AddCardToCollection( 447 ); 
	theGame.GetGwintManager().AddCardToCollection( 450 ); 
	theGame.GetGwintManager().AddCardToCollection( 451 ); 
	theGame.GetGwintManager().AddCardToCollection( 452 ); 
	theGame.GetGwintManager().AddCardToCollection( 453 ); 
	theGame.GetGwintManager().AddCardToCollection( 455 ); 
	theGame.GetGwintManager().AddCardToCollection( 456 ); 
	theGame.GetGwintManager().AddCardToCollection( 457 ); 
	theGame.GetGwintManager().AddCardToCollection( 460 ); 
	theGame.GetGwintManager().AddCardToCollection( 461 ); 
	theGame.GetGwintManager().AddCardToCollection( 462 ); 
	theGame.GetGwintManager().AddCardToCollection( 463 ); 
	theGame.GetGwintManager().AddCardToCollection( 464 ); 
	theGame.GetGwintManager().AddCardToCollection( 470 ); 
	theGame.GetGwintManager().AddCardToCollection( 471 ); 
	theGame.GetGwintManager().AddCardToCollection( 472 ); 
	theGame.GetGwintManager().AddCardToCollection( 475 ); 
	theGame.GetGwintManager().AddCardToCollection( 476 ); 
	theGame.GetGwintManager().AddCardToCollection( 477 ); 
	theGame.GetGwintManager().AddCardToCollection( 478 ); 
}

function AddDeckSke()
{
	theGame.GetGwintManager().AddCardToCollection( 5001 ); 
	theGame.GetGwintManager().AddCardToCollection( 5002 ); 
	theGame.GetGwintManager().AddCardToCollection( 501 ); 
	theGame.GetGwintManager().AddCardToCollection( 502 ); 
	theGame.GetGwintManager().AddCardToCollection( 503 ); 
	theGame.GetGwintManager().AddCardToCollection( 504 ); 
	theGame.GetGwintManager().AddCardToCollection( 505 ); 
	theGame.GetGwintManager().AddCardToCollection( 506 ); 
	theGame.GetGwintManager().AddCardToCollection( 507 ); 
	theGame.GetGwintManager().AddCardToCollection( 508 ); 
	theGame.GetGwintManager().AddCardToCollection( 509 ); 
	theGame.GetGwintManager().AddCardToCollection( 510 ); 
	theGame.GetGwintManager().AddCardToCollection( 511 ); 
	theGame.GetGwintManager().AddCardToCollection( 512 ); 
	theGame.GetGwintManager().AddCardToCollection( 513 ); 
	theGame.GetGwintManager().AddCardToCollection( 515 ); 
	theGame.GetGwintManager().AddCardToCollection( 515 ); 
	theGame.GetGwintManager().AddCardToCollection( 515 ); 
	theGame.GetGwintManager().AddCardToCollection( 517 ); 
	theGame.GetGwintManager().AddCardToCollection( 517 ); 
	theGame.GetGwintManager().AddCardToCollection( 517 ); 
	theGame.GetGwintManager().AddCardToCollection( 518 ); 
	theGame.GetGwintManager().AddCardToCollection( 519 ); 
	theGame.GetGwintManager().AddCardToCollection( 520 ); 
	theGame.GetGwintManager().AddCardToCollection( 520 ); 
	theGame.GetGwintManager().AddCardToCollection( 520 ); 
	theGame.GetGwintManager().AddCardToCollection( 521 ); 
	theGame.GetGwintManager().AddCardToCollection( 521 ); 
	theGame.GetGwintManager().AddCardToCollection( 521 ); 
	theGame.GetGwintManager().AddCardToCollection( 522 ); 
	theGame.GetGwintManager().AddCardToCollection( 522 ); 
	theGame.GetGwintManager().AddCardToCollection( 522 ); 
	theGame.GetGwintManager().AddCardToCollection( 523 ); 
	theGame.GetGwintManager().AddCardToCollection( 524 ); 
	theGame.GetGwintManager().AddCardToCollection( 525 ); 
	theGame.GetGwintManager().AddCardToCollection( 526 ); 
	theGame.GetGwintManager().AddCardToCollection( 527 ); 
	theGame.GetGwintManager().AddCardToCollection( 22 ); 
	theGame.GetGwintManager().AddCardToCollection( 22 ); 
	theGame.GetGwintManager().AddCardToCollection( 22 ); 
	theGame.GetGwintManager().AddCardToCollection( 23 ); 
	theGame.GetGwintManager().AddCardToCollection( 23 ); 
	theGame.GetGwintManager().AddCardToCollection( 23 ); 
}

function AddDeckNeutral()
{
	
	theGame.GetGwintManager().AddCardToCollection( 0 ); 
	theGame.GetGwintManager().AddCardToCollection( 0 ); 
	theGame.GetGwintManager().AddCardToCollection( 0 ); 
	theGame.GetGwintManager().AddCardToCollection( 1 ); 
	theGame.GetGwintManager().AddCardToCollection( 1 ); 
	theGame.GetGwintManager().AddCardToCollection( 1 ); 
	theGame.GetGwintManager().AddCardToCollection( 2 ); 
	theGame.GetGwintManager().AddCardToCollection( 2 ); 
	theGame.GetGwintManager().AddCardToCollection( 2 ); 
	theGame.GetGwintManager().AddCardToCollection( 3 ); 
	theGame.GetGwintManager().AddCardToCollection( 4 ); 
	theGame.GetGwintManager().AddCardToCollection( 5 ); 
	theGame.GetGwintManager().AddCardToCollection( 6 ); 
	theGame.GetGwintManager().AddCardToCollection( 7 ); 
	theGame.GetGwintManager().AddCardToCollection( 8 ); 
	theGame.GetGwintManager().AddCardToCollection( 9 ); 
	theGame.GetGwintManager().AddCardToCollection( 10 ); 
	theGame.GetGwintManager().AddCardToCollection( 11 ); 
	theGame.GetGwintManager().AddCardToCollection( 12 ); 
	theGame.GetGwintManager().AddCardToCollection( 13 ); 
	theGame.GetGwintManager().AddCardToCollection( 14 ); 
	theGame.GetGwintManager().AddCardToCollection( 15 ); 
	theGame.GetGwintManager().AddCardToCollection( 16 ); 
	theGame.GetGwintManager().AddCardToCollection( 17 ); 
	theGame.GetGwintManager().AddCardToCollection( 18 ); 
	theGame.GetGwintManager().AddCardToCollection( 19 ); 
	theGame.GetGwintManager().AddCardToCollection( 19 ); 
	theGame.GetGwintManager().AddCardToCollection( 19 ); 
	theGame.GetGwintManager().AddCardToCollection( 20 ); 
	
}



exec function testnotify()
{	
	theGame.GetGuiManager().ShowNotification("Some test notification");
}

exec function testsaveind()
{	
	theGame.GetGuiManager().ShowSavingIndicator();
}

exec function questProgress()
{
	var progress : int;
	var manager : CWitcherJournalManager;

	manager = theGame.GetJournalManager();
	progress = manager.GetQuestProgress();
	
	LogChannel( 'Quests', "Progress: " + progress + "%" );
}

exec function ResetManualCamera()
{
	thePlayer.HardLockToTarget( false );
	theGame.GetGameCamera().EnableManualControl( true );
}

exec function activateGate( tag : name )
{
	var gate : CBoatRacingGateEntity;
	
	gate = (CBoatRacingGateEntity)theGame.GetEntityByTag( tag );
	
	if( gate )
	{
		gate.ActivateGate();
	}
}

exec function statstolog()
{
	GetWitcherPlayer().LogAllAbilities();
}

exec function showSafeRect( value : bool ):void
{
	var overlayPopupRef  : CR4OverlayPopup;
	overlayPopupRef = (CR4OverlayPopup) theGame.GetGuiManager().GetPopup('OverlayPopup');
	if (overlayPopupRef)
	{
		overlayPopupRef.ShowSafeRect(value);
	}
}

exec function ClearAndStopCanFindPathEnemiesListUpdate( flag : bool )
{
	var player : CR4Player = thePlayer;

	if ( flag )
		player.canFindPathEnemiesList.Clear();
		
	player.disablecanFindPathEnemiesListUpdate = flag;
}

exec function kinecton()
{
    theGame.GetKinectSpeechRecognizer().SetEnabled( true );
}

exec function kinectoff()
{
    theGame.GetKinectSpeechRecognizer().SetEnabled( false );
}

exec function testgameprogress( perc: float )
{
    theTelemetry.SetGameProgress( perc );
}

exec function makeitrain()
{
	RequestWeatherChangeTo('WT_Rain_Storm', 1.0, false);
}

exec function stoprain()
{
	RequestWeatherChangeTo('WT_Clear', 1.0, false);
}

exec function witchcraft()
{
	theGame.GetDefinitionsManager().TestWitchcraft();
}

exec function vloot( listAllItemDefs : bool )
{
	theGame.GetDefinitionsManager().ValidateLootDefinitions( listAllItemDefs );
}

exec function vrecycling( listAllItemDefs : bool )
{
	theGame.GetDefinitionsManager().ValidateRecyclingParts( listAllItemDefs );
}

exec function vcrafting( listAllItemDefs : bool )
{
	theGame.GetDefinitionsManager().ValidateCraftingDefinitions( listAllItemDefs );
}


exec function gather(optional range : float)
{
	var ents : array<CGameplayEntity>;
	var i, breakpointMe : int;
	var entity : CGameplayEntity;
	var entityState : name;
	
	if(range == 0)
		range = 5;
		
	FindGameplayEntitiesInSphere(ents, thePlayer.GetWorldPosition(), range, 100000);
	
	for(i=0; i<ents.Size(); i+=1)
	{
		entity = ents[i];
		entityState = entity.GetCurrentStateName();
		
		breakpointMe = 0;
	}
	
	breakpointMe = 0;
}

exec function hackknockdown()
{
	thePlayer.substateManager.m_SharedDataO.SetHackKnockBack( !thePlayer.substateManager.m_SharedDataO.hackKnockBackAlways );
}

exec function zzz()
{
	thePlayer.inv.RemoveItemByName('Zireael Sword', -1);
}

exec function ForceCombatMode( flag : bool ) 
{
	if ( flag ) 
		thePlayer.GetPlayerMode().ForceCombatMode( FCMR_QuestFunction );
	else
		thePlayer.GetPlayerMode().ReleaseForceCombatMode( FCMR_QuestFunction );
}

exec function InvertCamera( invert : bool )
{
	theInput.SetInvertCamera( invert );
}


exec function balanceadapt()
{
	if  ( thePlayer.IsAdaptiveBalance() ) 
		thePlayer.SetAdaptiveBalance( false ); 
		else
		thePlayer.SetAdaptiveBalance( true ); 
}
exec function SSPrintJsonObjectsMemoryUsage()
{
	theGame.GetSecondScreenManager().PrintJsonObjectsMemoryUsage();
}

exec function ForceHolster( optional instant : bool )
{
	thePlayer.OnRangedForceHolster( true, instant );
}


exec function StartRumble( lowFreq : float, highFreq : float, time : float )
{
	theGame.VibrateController( lowFreq, highFreq, time );
}

exec function StopRumble()
{
	theGame.StopVibrateController();
}

exec function PrintRumble()
{
	var lowFreq : float;
	var highFreq : float;
	theGame.GetCurrentVibrationFreq( lowFreq, highFreq );
	Log( "Low freq = " + lowFreq );
	Log( "High freq = " + highFreq );
}

exec function StopSpecificRumble( lowFreq : float, highFreq : float )
{
	theGame.RemoveSpecificRumble( lowFreq, highFreq );
}

exec function PrintIsSpecificRumbleActive( lowFreq : float, highFreq : float )
{
	if( theGame.IsSpecificRumbleActive( lowFreq, highFreq ) )
	{
		Log( "Rumble active" );
	}
	else
	{
		Log( "Rumble not active" );
	}
}

exec function AreAchievementsDisabled()
{
	if( theGame.GetAchievementsDisabled() )
	{
		Log( "Achievements Disabled" );
		if( theGame.IsFinalBuild() )
		{
			theGame.RequestMenu( 'DeckBuilder' );
		}
	}
	else
	{
		Log( "Achievements Enabled" );
	}
}

exec function PrintContext()
{
	var c : name;
	
	c = theInput.GetContext();
	Log( c );
}

exec function ToggleCameraAutoRotation()
{
	var camera : CCustomCamera;
		
	camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
	if( camera )
	{
		camera.allowAutoRotation = !camera.allowAutoRotation;
	}
}

exec function inputTreshold( _inputTreshold : float )
{
	thePlayer.SetInputModuleNeededToRun( _inputTreshold );
}

exec function horseCamMode( mode : int )
{
	var horseComp : W3HorseComponent;
	
	horseComp = (W3HorseComponent)thePlayer.GetUsedVehicle().GetComponentByClassName( 'W3HorseComponent' );
	
	if ( horseComp )
		horseComp.cameraMode = mode;
}
exec function gwentTournamentCards( optional val : int )
{
	if( val )
	{
		thePlayer.inv.RemoveItemByName('gwint_card_kayran',1);
		thePlayer.inv.RemoveItemByName('gwint_card_ciri',1);
		thePlayer.inv.RemoveItemByName('gwint_card_geralt',1);
		thePlayer.inv.RemoveItemByName('gwint_card_imlerith',1);
		thePlayer.inv.RemoveItemByName('gwint_card_philippa',1);
		thePlayer.inv.RemoveItemByName('gwint_card_leshen',1);
		thePlayer.inv.RemoveItemByName('gwint_card_draug',1);
		thePlayer.inv.RemoveItemByName('gwint_card_saskia',1);
		thePlayer.inv.RemoveItemByName('gwint_card_eithne',1);
	}
	else 
	{
		thePlayer.inv.AddAnItem('gwint_card_kayran',1);
		thePlayer.inv.AddAnItem('gwint_card_ciri',1);
		thePlayer.inv.AddAnItem('gwint_card_geralt',1);
		thePlayer.inv.AddAnItem('gwint_card_imlerith',1);
		thePlayer.inv.AddAnItem('gwint_card_philippa',1);
		thePlayer.inv.AddAnItem('gwint_card_leshen',1);
		thePlayer.inv.AddAnItem('gwint_card_draug',1);
		thePlayer.inv.AddAnItem('gwint_card_saskia',1);
		thePlayer.inv.AddAnItem('gwint_card_eithne',1);
		thePlayer.inv.AddAnItem('gwint_card_tibor',1);
		thePlayer.inv.AddAnItem('gwint_card_moorvran',1);
		thePlayer.inv.AddAnItem('gwint_card_menno',1);
		thePlayer.inv.AddAnItem('gwint_card_letho',1);
		thePlayer.inv.AddAnItem('gwint_card_esterad',1);
	}
}

exec function EnableSnapToNavMesh( source : name, enable : bool )
{
	thePlayer.EnableSnapToNavMesh( source, enable );
}



exec function RestoreHorseManager() : bool
{
	return GetWitcherPlayer().RestoreHorseManager();
}

exec function horsePanic()
{
	var horseComp : W3HorseComponent;
	var horseActor : CActor;
	
	horseComp = (W3HorseComponent)thePlayer.GetUsedVehicle().GetComponentByClassName( 'W3HorseComponent' );
	
	if ( horseComp )
	{
		horseActor = (CActor)(horseComp.GetEntity());
		horseActor.AddAbility( 'DisableHorsePanic' );
	}	
	else
	{
		horseComp = (W3HorseComponent)thePlayer.GetHorseCurrentlyMounted().GetComponentByClassName( 'W3HorseComponent' );
		horseActor = (CActor)(horseComp.GetEntity());
		horseActor.AddAbility( 'DisableHorsePanic' );
	}
}

exec function pottip(itemName : name)
{
	var ids : array<SItemUniqueId>;
	var null : array<SAttributeTooltip>;
	
	ids = thePlayer.inv.GetItemsByName(itemName);
	if(ids.Size() > 0)
		thePlayer.inv.GetPotionAttributesForTooltip(ids[0], null);
}

exec function showMouse(value:bool)
{
	theGame.GetGuiManager().RequestMouseCursor(value);
}

exec function EnablePCMode( flag : bool )
{
	var player : CR4Player = thePlayer;

	player.EnablePCMode( flag );
}

exec function EnableUberMovement( flag : bool )
{
	var player : CR4Player = thePlayer;

	theGame.EnableUberMovement( flag );
}

exec function primarec()
{
	var dm : CDefinitionsManagerAccessor;
	var main, ingredients : SCustomNode;
	var i, k, ingQuantity : int;
	var recipeName, cookedItemName, ingName : name;
	var logStr : string;
	
	dm = theGame.GetDefinitionsManager();
	main = dm.GetCustomDefinition('alchemy_recipes');
	
	LogChannel('PrimaAlchemyRecipes', "recipe localized name;cooked item localized name;buy price;ingredients list;");
	
	for(i=0; i<main.subNodes.Size(); i+=1)
	{
		dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', recipeName);
		dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'cookedItem_name', cookedItemName);
		
		
		if(dm.ItemHasTag(cookedItemName, 'Quest') || StrContains(NameToString(cookedItemName), " Blizzard"))
			continue;
		
		logStr = GetLocStringByKeyExt(dm.GetItemLocalisationKeyName(recipeName)) + ";" + GetLocStringByKeyExt(dm.GetItemLocalisationKeyName(cookedItemName)) + ";";
		logStr += dm.GetItemPrice(cookedItemName) + ";";
		
		
		ingredients = dm.GetCustomDefinitionSubNode(main.subNodes[i],'ingredients');
		for(k=0; k<ingredients.subNodes.Size(); k+=1)
		{		
			dm.GetCustomNodeAttributeValueName(ingredients.subNodes[k], 'item_name', ingName);
			dm.GetCustomNodeAttributeValueInt(ingredients.subNodes[k], 'quantity', ingQuantity);
			logStr += ingQuantity + ";" + GetLocStringByKeyExt(dm.GetItemLocalisationKeyName(ingName)) + ";";
		}
		
		LogChannel('PrimaAlchemyRecipes', logStr);
	}
}

exec function primabooks()
{
	var bookNames : array<name>;
	var i : int;
	var itemCategory : name;
	var strLocName, contents : string;
	var dm : CDefinitionsManagerAccessor;
		
	dm = theGame.GetDefinitionsManager();
	bookNames = dm.GetItemsWithTag('ReadableItem');
	LogChannel('PrimaBookContents', "book name key;book;contents as HTML text;");
	
	for(i=0; i<bookNames.Size(); i+=1)
	{
		
		itemCategory = dm.GetItemCategory(bookNames[i]);
		if(itemCategory == 'alchemy_recipe' || itemCategory == 'crafting_schematic')
			continue;
			
		
		if(dm.ItemHasTag(bookNames[i], 'ThMap'))
			continue;
	
		strLocName = dm.GetItemLocalisationKeyName(bookNames[i]);
		contents = GetLocStringByKeyExt(strLocName + "_text");
		LogChannel('PrimaBookContents', strLocName + ";" + GetLocStringByKeyExt(strLocName) + ";" + contents + ";");
	}
}

exec function StartNewGamePlus(filename : string)
{
	var saves : array< SSavegameInfo >;
	var i : int;
	
	theGame.ListSavedGames(saves);
	for(i=0; i<saves.Size(); i+=1)
	{
		if(StrLower(saves[i].filename) == StrLower(filename))
		{
			theGame.StartNewGamePlus(saves[i]);
			return;
		}
	}	
}

exec function NewGamePlus( flag : bool )
{
	theGame.EnableNewGamePlus( flag );
}

exec function SimulateDLCsAvailable(value:bool)
{
	theGame.GetDLCManager().SimulateDLCsAvailable(value);
}

exec function testMessage()
{
	theGame.GetGuiManager().ShowProgressDialog( 0, "", "error_message_damaged_save_unavailable_ps4 really really really really long test string of doom really really really really long test string of doom really really really really long test string of doom really really really really long test string of doom really really really really long test string of doom", false, UDB_Ok, 0.5, UMPT_Content, 'content0' );
}
exec function spawnBoatAndMount()
{
	var entities : array<CGameplayEntity>;
	var vehicle : CVehicleComponent;
	var i : int;
	var boat : W3Boat;
	var ent : CEntity;
	var player : Vector;
	var rot : EulerAngles;
	var template : CEntityTemplate;
	
	FindGameplayEntitiesInRange( entities, thePlayer, 10, 10, 'vehicle' );
	
	for( i = 0; i < entities.Size(); i = i + 1 )
	{
		boat = ( W3Boat )entities[ i ];
		if( boat )
		{
			vehicle = ( CVehicleComponent )( boat.GetComponentByClassName( 'CVehicleComponent' ) );
			if ( vehicle )
			{
				vehicle.Mount( thePlayer, VMT_ImmediateUse, EVS_driver_slot );
			}
			
			return;
		}
	}

	rot = thePlayer.GetWorldRotation();	
	player = thePlayer.GetWorldPosition();
	template = (CEntityTemplate)LoadResource( 'boat' );
	player.Z = 0.0f;

	ent = theGame.CreateEntity(template, player, rot, true, false, false, PM_Persist );
	
	if( ent )
	{
		vehicle = ( CVehicleComponent )( ent.GetComponentByClassName( 'CVehicleComponent' ) );
		if ( vehicle )
		{
			vehicle.Mount( thePlayer, VMT_ImmediateUse, EVS_driver_slot );
		}
	}
}

exec function printtags(actorTag : name)
{
	var actor : CActor;
	var tags : array<name>;
	var i : int;
	
	actor = theGame.GetActorByTag(actorTag);
	if(!actor)
		return;
	
	tags = actor.GetTags();
	LogStats("Printing tags of " + actor);
	for(i=0; i<tags.Size(); i+=1)
	{
		LogStats(tags[i]);
	}
	LogStats("");
}

exec function testLoc( key : string )
{
	var result:string;
	result = GetLocStringByKeyExt(key);
	if (result != "")
	{
		LogStates(result);
	}
	else
	{
		LogStates("Key not found");
	}
}

exec function testRescale()
{
	theGame.RequestMenu('RescaleMenu');
}

exec function light()
{
	var ids : array<SItemUniqueId>;
	
	GetWitcherPlayer().UnequipItemFromSlot(EES_Armor);
	GetWitcherPlayer().UnequipItemFromSlot(EES_Pants);
	GetWitcherPlayer().UnequipItemFromSlot(EES_Gloves);
	GetWitcherPlayer().UnequipItemFromSlot(EES_Boots);
	
	ids.Clear();
	ids = GetWitcherPlayer().inv.AddAnItem('Gloves 01');
	GetWitcherPlayer().EquipItem(ids[0]);
	
	ids.Clear();
	ids = GetWitcherPlayer().inv.AddAnItem('Pants 01');
	GetWitcherPlayer().EquipItem(ids[0]);
	
	ids.Clear();
	ids = GetWitcherPlayer().inv.AddAnItem('Light armor 01');
	GetWitcherPlayer().EquipItem(ids[0]);
	
	ids.Clear();
	ids = GetWitcherPlayer().inv.AddAnItem('Boots 01');
	GetWitcherPlayer().EquipItem(ids[0]);
}

exec function simngp(flag : bool)
{
	if(flag)
		FactsAdd("NewGamePlus");
	else
		FactsRemove("NewGamePlus");
	theGame.params.SetNewGamePlusLevel(0);
}

exec function addofir()
{
	thePlayer.inv.AddAnItem('Ofir Armor');
	thePlayer.inv.AddAnItem('Crafted Ofir Armor');
	thePlayer.inv.AddAnItem('Crafted Ofir Boots');
	thePlayer.inv.AddAnItem('Crafted Ofir Gloves');
	thePlayer.inv.AddAnItem('Crafted Ofir Pants');
	thePlayer.inv.AddAnItem('Crafted Ofir Steel Sword');
	thePlayer.inv.AddAnItem('Ofir Sabre 1');
	thePlayer.inv.AddAnItem('Ofir Sabre 2');
	thePlayer.inv.AddAnItem('Horse Saddle 6');
	thePlayer.inv.AddAnItem('Ofir Horse Bag');
	thePlayer.inv.AddAnItem('Ofir Horse Blinders');
}

exec function testGamma()
{
	theGame.RequestMenu('MainGammaMenu');
}

exec function testStash()
{
	theGame.GameplayFactsAdd("stashMode", 1);
	theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
}

exec function spawnEthereals( optional count : int, optional dist : float, optional level : int )
{
	
	var ent : CEntity;
	var pos, posTemp, playerPos : Vector;
	var rot : EulerAngles;
	var i : int;
	var template : CEntityTemplate;

	rot = thePlayer.GetWorldRotation();	
	rot.Yaw += 180;

	template = (CEntityTemplate)LoadResource('ethereal');

	if( count == 0 ) count = 6;
	
	for(i=0; i<count; i+=1)
	{		
		if(i == 1)
			rot.Yaw -= 60;
		else if(i == 2)
			rot.Yaw -= 60;
		else if(i == 3)
			rot = thePlayer.GetWorldRotation();	
		else if(i == 4)
			rot.Yaw -= 60;
		else if(i == 5)
			rot.Yaw -= 60;
		
		if(dist == 0) dist = 5.0;
		
		pos = thePlayer.GetWorldPosition() + VecFromHeading( thePlayer.GetHeading() - i * 60.0 ) * dist;
		
		ent = theGame.CreateEntity(template, pos, rot);
		
		((CActor)ent).SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
		
		if( level )
		{
			if(level == 1)
			{	
				((CNewNPC)ent).AddAbility( 'EtherealSkill_1' );
			}
			else if(level == 2)
			{
				((CNewNPC)ent).AddAbility( 'EtherealSkill_1' );
				((CNewNPC)ent).AddAbility( 'EtherealSkill_2' );
			}
			else if(level == 3)
			{
				((CNewNPC)ent).AddAbility( 'EtherealSkill_1' );
				((CNewNPC)ent).AddAbility( 'EtherealSkill_2' );
				((CNewNPC)ent).AddAbility( 'EtherealSkill_3' );
			}
			else if(level == 4)
			{
				((CNewNPC)ent).AddAbility( 'EtherealSkill_1' );
				((CNewNPC)ent).AddAbility( 'EtherealSkill_2' );
				((CNewNPC)ent).AddAbility( 'EtherealSkill_3' );
				((CNewNPC)ent).AddAbility( 'EtherealSkill_4' );
				((CNewNPC)ent).RaiseGuard();
			}
			else if(level == 5)
			{
				((CNewNPC)ent).AddAbility( 'EtherealSkill_1' );
				((CNewNPC)ent).AddAbility( 'EtherealSkill_2' );
				((CNewNPC)ent).AddAbility( 'EtherealSkill_3' );
				((CNewNPC)ent).AddAbility( 'EtherealSkill_4' );
				((CNewNPC)ent).AddAbility( 'EtherealSkill_5' );
				((CNewNPC)ent).RaiseGuard();
			}
		}
	}
}

exec function Addep1Items()
{	
	thePlayer.inv.AddAnItem('Crafted Ofir Boots');
	thePlayer.inv.AddAnItem('Crafted Ofir Gloves');
	thePlayer.inv.AddAnItem('Crafted Ofir Pants');
	thePlayer.inv.AddAnItem('Crafted Ofir Steel Sword');
	thePlayer.inv.AddAnItem('Ofir Sabre 1');
	thePlayer.inv.AddAnItem('Ofir Sabre 2');
	thePlayer.inv.AddAnItem('Horse Saddle 6');
	thePlayer.inv.AddAnItem('Ofir Horse Bag');
	thePlayer.inv.AddAnItem('Ofir Horse Blinders');

	thePlayer.inv.AddAnItem('Ofir Armor');
	thePlayer.inv.AddAnItem('Crafted Ofir Armor');
	thePlayer.inv.AddAnItem('Olgierd Sabre');
	thePlayer.inv.AddAnItem('Soltis Vodka');
	thePlayer.inv.AddAnItem('Cornucopia');
	thePlayer.inv.AddAnItem('Flaming Rose Armor');
	thePlayer.inv.AddAnItem('Burning Rose Sword');
	thePlayer.inv.AddAnItem('Geralt Kontusz');
	thePlayer.inv.AddAnItem('Geralt Kontusz Boots');
	thePlayer.inv.AddAnItem('EP1 Witcher Silver Sword');
	thePlayer.inv.AddAnItem('EP1 Viper School steel sword');
	thePlayer.inv.AddAnItem('EP1 Viper School silver sword');
}

exec function Addep2Items()
{
	GetWitcherPlayer().AddPoints( EExperiencePoint, 85000, false );

	thePlayer.inv.AddAnItem('Guard Lvl1 Armor 1');
	thePlayer.inv.AddAnItem('Guard Lvl1 Boots 1');
	thePlayer.inv.AddAnItem('Guard Lvl1 Gloves 1');
	thePlayer.inv.AddAnItem('Guard Lvl1 Pants 1');
	
	thePlayer.inv.AddAnItem('Guard Lvl1 Armor 2');
	thePlayer.inv.AddAnItem('Guard Lvl1 Boots 2');
	thePlayer.inv.AddAnItem('Guard Lvl1 Gloves 2');
	thePlayer.inv.AddAnItem('Guard Lvl1 Pants 2');
	
	thePlayer.inv.AddAnItem('Guard Lvl1 Armor 3');
	thePlayer.inv.AddAnItem('Guard Lvl1 Boots 3');
	thePlayer.inv.AddAnItem('Guard Lvl1 Gloves 3');
	thePlayer.inv.AddAnItem('Guard Lvl1 Pants 3');
	
	thePlayer.inv.AddAnItem('Guard Lvl1 A Armor 1');
	thePlayer.inv.AddAnItem('Guard Lvl1 A Boots 1');
	thePlayer.inv.AddAnItem('Guard Lvl1 A Gloves 1');
	thePlayer.inv.AddAnItem('Guard Lvl1 A Pants 1');
	
	thePlayer.inv.AddAnItem('Guard Lvl1 A Armor 2');
	thePlayer.inv.AddAnItem('Guard Lvl1 A Boots 2');
	thePlayer.inv.AddAnItem('Guard Lvl1 A Gloves 2');
	thePlayer.inv.AddAnItem('Guard Lvl1 A Pants 2');
	
	thePlayer.inv.AddAnItem('Guard Lvl1 A Armor 3');
	thePlayer.inv.AddAnItem('Guard Lvl1 A Boots 3');
	thePlayer.inv.AddAnItem('Guard Lvl1 A Gloves 3');
	thePlayer.inv.AddAnItem('Guard Lvl1 A Pants 3');
	
	thePlayer.inv.AddAnItem('Guard Lvl2 Armor 1');
	thePlayer.inv.AddAnItem('Guard Lvl2 Boots 1');
	thePlayer.inv.AddAnItem('Guard Lvl2 Gloves 1');
	thePlayer.inv.AddAnItem('Guard Lvl2 Pants 1');
	
	thePlayer.inv.AddAnItem('Guard Lvl2 Armor 2');
	thePlayer.inv.AddAnItem('Guard Lvl2 Boots 2');
	thePlayer.inv.AddAnItem('Guard Lvl2 Gloves 2');
	thePlayer.inv.AddAnItem('Guard Lvl2 Pants 2');
	
	thePlayer.inv.AddAnItem('Guard Lvl2 Armor 3');
	thePlayer.inv.AddAnItem('Guard Lvl2 Boots 3');
	thePlayer.inv.AddAnItem('Guard Lvl2 Gloves 3');
	thePlayer.inv.AddAnItem('Guard Lvl2 Pants 3');
	
	thePlayer.inv.AddAnItem('Guard Lvl2 A Armor 1');
	thePlayer.inv.AddAnItem('Guard Lvl2 A Boots 1');
	thePlayer.inv.AddAnItem('Guard Lvl2 A Gloves 1');
	thePlayer.inv.AddAnItem('Guard Lvl2 A Pants 1');
	
	thePlayer.inv.AddAnItem('Guard Lvl2 A Armor 2');
	thePlayer.inv.AddAnItem('Guard Lvl2 A Boots 2');
	thePlayer.inv.AddAnItem('Guard Lvl2 A Gloves 2');
	thePlayer.inv.AddAnItem('Guard Lvl2 A Pants 2');
	
	thePlayer.inv.AddAnItem('Guard Lvl2 A Armor 3');
	thePlayer.inv.AddAnItem('Guard Lvl2 A Boots 3');
	thePlayer.inv.AddAnItem('Guard Lvl2 A Gloves 3');
	thePlayer.inv.AddAnItem('Guard Lvl2 A Pants 3');
	
	thePlayer.inv.AddAnItem('Knight Geralt Armor 1');
	thePlayer.inv.AddAnItem('Knight Geralt Boots 1');
	thePlayer.inv.AddAnItem('Knight Geralt Gloves 1');
	thePlayer.inv.AddAnItem('Knight Geralt Pants 1');
	
	thePlayer.inv.AddAnItem('Knight Geralt Armor 2');
	thePlayer.inv.AddAnItem('Knight Geralt Boots 2');
	thePlayer.inv.AddAnItem('Knight Geralt Gloves 2');
	thePlayer.inv.AddAnItem('Knight Geralt Pants 2');
	
	thePlayer.inv.AddAnItem('Knight Geralt Armor 3');
	thePlayer.inv.AddAnItem('Knight Geralt Boots 3');
	thePlayer.inv.AddAnItem('Knight Geralt Gloves 3');
	thePlayer.inv.AddAnItem('Knight Geralt Pants 3');
	
	thePlayer.inv.AddAnItem('Knight Geralt A Armor 1');
	thePlayer.inv.AddAnItem('Knight Geralt A Boots 1');
	thePlayer.inv.AddAnItem('Knight Geralt A Gloves 1');
	thePlayer.inv.AddAnItem('Knight Geralt A Pants 1');
	
	thePlayer.inv.AddAnItem('Knight Geralt A Armor 2');
	thePlayer.inv.AddAnItem('Knight Geralt A Boots 2');
	thePlayer.inv.AddAnItem('Knight Geralt A Gloves 2');
	thePlayer.inv.AddAnItem('Knight Geralt A Pants 2');
	
	thePlayer.inv.AddAnItem('Knight Geralt A Armor 3');
	thePlayer.inv.AddAnItem('Knight Geralt A Boots 3');
	thePlayer.inv.AddAnItem('Knight Geralt A Gloves 3');
	thePlayer.inv.AddAnItem('Knight Geralt A Pants 3');
	
	thePlayer.inv.AddAnItem('Toussaint Armor 2');
	thePlayer.inv.AddAnItem('Toussaint Boots 2');
	thePlayer.inv.AddAnItem('Toussaint Gloves 2');
	thePlayer.inv.AddAnItem('Toussaint Pants 2');
	
	thePlayer.inv.AddAnItem('Toussaint Armor 3');
	thePlayer.inv.AddAnItem('Toussaint Boots 3');
	thePlayer.inv.AddAnItem('Toussaint Gloves 3');
	thePlayer.inv.AddAnItem('Toussaint Pants 3');
	
	thePlayer.inv.AddAnItem('sq701_geralt_armor');
	thePlayer.inv.AddAnItem('sq701_ravix_armor');
	thePlayer.inv.AddAnItem('q705_mandragora_gloves');
}

exec function Addep2HorseItems()
{
	thePlayer.inv.AddAnItem('Toussaint saddle');
	thePlayer.inv.AddAnItem('Toussaint saddle 2');
	thePlayer.inv.AddAnItem('Toussaint saddle 3');
	thePlayer.inv.AddAnItem('Toussaint saddle 4');
	thePlayer.inv.AddAnItem('Toussaint saddle 5');
	thePlayer.inv.AddAnItem('Toussaint saddle 6');
	
	thePlayer.inv.AddAnItem('Tourney Geralt Saddle');
	thePlayer.inv.AddAnItem('Tourney Ravix Saddle');
	
	thePlayer.inv.AddAnItem('Toussaint horsebag');
	
	thePlayer.inv.AddAnItem('Toussaint horse blinders');
	thePlayer.inv.AddAnItem('Toussaint horse blinders 2');
	thePlayer.inv.AddAnItem('Toussaint horse blinders 3');
	thePlayer.inv.AddAnItem('Toussaint horse blinders 4');
	thePlayer.inv.AddAnItem('Toussaint horse blinders 5');
	thePlayer.inv.AddAnItem('Toussaint horse blinders 6');
	
	thePlayer.inv.AddAnItem('Monniers horse blinders');
	
	thePlayer.inv.AddAnItem('q701_cyclops_trophy');
	thePlayer.inv.AddAnItem('q702_wicht_trophy');
	thePlayer.inv.AddAnItem('q704_garkain_trophy');
	thePlayer.inv.AddAnItem('mq7002_spriggan_trophy');
	thePlayer.inv.AddAnItem('mq7009_griffin_trophy');
	thePlayer.inv.AddAnItem('mq7017_zmora_trophy');
	thePlayer.inv.AddAnItem('mq7010_dracolizard_trophy');
	thePlayer.inv.AddAnItem('mq7018_basilisk_trophy');
	thePlayer.inv.AddAnItem('mh701_sharley_matriarch_trophy');
}

exec function issa( dlc : name )
{
	Log( "Result: " + theGame.CanStartStandaloneDLC( dlc ) );
}

exec function ssa( dlc : name )
{
	Log( "Result: " + theGame.InitStandaloneDLCLoading( dlc, 0 ) );
}

exec function standalone_ep1()
{
	GetWitcherPlayer().StandaloneEp1_1();	
}

exec function standalone_ep2()
{
	GetWitcherPlayer().StandaloneEp2_1();	
}

exec function censer( val : float )
{
	thePlayer.SetBehaviorVariable( 'censerSwinging', val, true );
}

exec function rwall()
{
	var witcher : W3PlayerWitcher;
	
	witcher = GetWitcherPlayer();
	
	witcher.UnequipItem( rw_internal("r1") );
	witcher.UnequipItem( rw_internal("r2") );
	witcher.UnequipItem( rw_internal("r4") );
	witcher.UnequipItem( rw_internal("r5") );
	witcher.UnequipItem( rw_internal("r6") );
	witcher.UnequipItem( rw_internal("r8") );
	witcher.UnequipItem( rw_internal("r10") );
	witcher.UnequipItem( rw_internal("r11") );
	witcher.UnequipItem( rw_internal("r12") );
	
	witcher.UnequipItem( rw_internal("r1", false, true) );
	witcher.UnequipItem( rw_internal("r2", false, true) );
	witcher.UnequipItem( rw_internal("r4", false, true) );
	witcher.UnequipItem( rw_internal("r5", false, true) );
	witcher.UnequipItem( rw_internal("r6", false, true) );
	witcher.UnequipItem( rw_internal("r8", false, true) );
	witcher.UnequipItem( rw_internal("r10", false, true) );
	witcher.UnequipItem( rw_internal("r11", false, true) );
	witcher.UnequipItem( rw_internal("r12", false, true) );
	
	witcher.UnequipItem( rw_internal("g1") );
	witcher.UnequipItem( rw_internal("g2") );
	witcher.UnequipItem( rw_internal("g3") );
	witcher.UnequipItem( rw_internal("g4") );
	witcher.UnequipItem( rw_internal("g5") );
	witcher.UnequipItem( rw_internal("g6") );
	witcher.UnequipItem( rw_internal("g7") );
	witcher.UnequipItem( rw_internal("g10") );
	witcher.UnequipItem( rw_internal("g12") );
	witcher.UnequipItem( rw_internal("g14") );
	witcher.UnequipItem( rw_internal("g15") );
	witcher.UnequipItem( rw_internal("g17") );
	witcher.UnequipItem( rw_internal("g18") );
	witcher.UnequipItem( rw_internal("g20") );
}

exec function rw(typ : string, optional removeAllExisting : bool, optional onSilverSword : bool)
{
	rw_internal(typ, removeAllExisting, onSilverSword);
}

function rw_internal(typ : string, optional removeAllExisting : bool, optional onSilverSword : bool) : SItemUniqueId
{
	var type, word : string;
	var witcher : W3PlayerWitcher;
	var i, num : int;
	var ids, items : array<SItemUniqueId>;
	var itemId : SItemUniqueId;
	var wordAsName : name;
	var runewordCheck : array<name>;
	
	
	type = StrLeft(typ, 1);
	num = StringToInt(StrRight(typ, StrLen(typ)-1));
	witcher = GetWitcherPlayer();
	
	if(type == "r" || type == "R")
	{
		type = "Runeword";
	}
	else if(type == "g" || type == "G")
	{
		type = "Glyphword";
	}
	
	word = type + " " + num;	
	
	
	if     (word == "Runeword 1"   || typ == "Napelnienie"   || typ == "Replenishment")	  	{wordAsName = 'Runeword 1'; type = "Runeword";}
	else if(word == "Runeword 2"   || typ == "Przeciecie"    || typ == "Severance") 		{wordAsName = 'Runeword 2'; type = "Runeword";}
	else if(word == "Runeword 4"   || typ == "Wigor"         || typ == "Invigoration") 		{wordAsName = 'Runeword 4'; type = "Runeword";}
	else if(word == "Runeword 5"   || typ == "Utrwalenie"    || typ == "Preservation") 		{wordAsName = 'Runeword 5'; type = "Runeword";}
	else if(word == "Runeword 6"   || typ == "Pierogi"       || typ == "Dumplings")			{wordAsName = 'Runeword 6'; type = "Runeword";}
	else if(word == "Runeword 8"   || typ == "Spokoj"        || typ == "Placation") 		{wordAsName = 'Runeword 8'; type = "Runeword";}
	else if(word == "Runeword 10"  || typ == "Odnowienie"    || typ == "Rejuvenation") 		{wordAsName = 'Runeword 10'; type = "Runeword";}
	else if(word == "Runeword 11"  || typ == "Przedluzenie"  || typ == "Prolongation") 		{wordAsName = 'Runeword 11'; type = "Runeword";}
	else if(word == "Runeword 12"  || typ == "Triumf"        || typ == "Elation") 			{wordAsName = 'Runeword 12'; type = "Runeword";}
	else if(word == "Glyphword 1"  || typ == "Odbicie"       || typ == "Deflection") 		{wordAsName = 'Glyphword 1'; type = "Glyphword";}
	else if(word == "Glyphword 2"  || typ == "Lekkosc"       || typ == "Levity") 			{wordAsName = 'Glyphword 2'; type = "Glyphword";}
	else if(word == "Glyphword 3"  || typ == "Rownowaga"     || typ == "Balance") 			{wordAsName = 'Glyphword 3'; type = "Glyphword";}
	else if(word == "Glyphword 4"  || typ == "Ciezar"        || typ == "Heft") 				{wordAsName = 'Glyphword 4'; type = "Glyphword";}
	else if(word == "Glyphword 5"  || typ == "Ciern"         || typ == "Retribution") 		{wordAsName = 'Glyphword 5'; type = "Glyphword";}
	else if(word == "Glyphword 6"  || typ == "Wycieczenie"   || typ == "Depletion") 		{wordAsName = 'Glyphword 6'; type = "Glyphword";}
	else if(word == "Glyphword 7"  || typ == "Kolo"          || typ == "Rotation") 			{wordAsName = 'Glyphword 7'; type = "Glyphword";}
	else if(word == "Glyphword 10" || typ == "Zawaladniecie" || typ == "Usurpation") 		{wordAsName = 'Glyphword 10'; type = "Glyphword";}
	else if(word == "Glyphword 12" || typ == "Ogien"         || typ == "Ignition") 			{wordAsName = 'Glyphword 12'; type = "Glyphword";}
	else if(word == "Glyphword 14" || typ == "Oczarowanie"   || typ == "Beguilement") 		{wordAsName = 'Glyphword 14'; type = "Glyphword";}
	else if(word == "Glyphword 15" || typ == "Spetanie"      || typ == "Entanglement") 		{wordAsName = 'Glyphword 15'; type = "Glyphword";}
	else if(word == "Glyphword 17" || typ == "Tarcza"        || typ == "Protection") 		{wordAsName = 'Glyphword 17'; type = "Glyphword";}
	else if(word == "Glyphword 18" || typ == "Opetanie"      || typ == "Possession") 		{wordAsName = 'Glyphword 18'; type = "Glyphword";}
	else if(word == "Glyphword 20" || typ == "Eksplozja"     || typ == "Eruption") 			{wordAsName = 'Glyphword 20'; type = "Glyphword";}
	
	runewordCheck = GetAllRunewordSchematics();
	if(!runewordCheck.Contains(wordAsName))
		return GetInvalidUniqueId();
	
	
	if(type == "Runeword")
	{
		if(!onSilverSword)
		{
			if(!witcher.GetItemEquippedOnSlot(EES_SteelSword, itemId))
			{
				ids = witcher.inv.AddAnItem('Gnomish sword 2', 1, true);
				itemId = ids[0];
			}
		}
		else
		{
			if(!witcher.GetItemEquippedOnSlot(EES_SilverSword, itemId))
			{
				ids = witcher.inv.AddAnItem('Azurewrath', 1, true);
				itemId = ids[0];
			}
		}
	}
	else if(type == "Glyphword")
	{
		if(!witcher.GetItemEquippedOnSlot(EES_Armor, itemId))
		{
			ids = witcher.inv.AddAnItem('Medium armor 05r', 1, true);
			itemId = ids[0];
		}
	}
	
	if(!witcher.inv.IsIdValid(itemId))
		return GetInvalidUniqueId();
	
	
	if(removeAllExisting)
	{
		witcher.inv.GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			witcher.inv.UnenchantItem(items[i]);
		}
	}
	else
	{
		witcher.inv.UnenchantItem(itemId);
	}
	
	while(witcher.inv.GetItemEnhancementSlotsCount(itemId) < 3)
	{
		witcher.inv.AddSlot(itemId);
	}
	
	witcher.inv.EnchantItem(itemId, wordAsName, getEnchamtmentStatName(wordAsName));
	witcher.EquipItem(itemId);
	
	return itemId;
}


exec function focusboy ( optional fp : int )
{
	if( !FactsDoesExist("debug_fact_focus_boy") )
	{
		if(fp==0)
		{
			fp = 1;
		}
		FactsAdd("debug_fact_focus_boy", fp);
		Log("The fact value equals " + FactsQuerySum("debug_fact_focus_boy") + " ." );
	}
	else
	{
		FactsRemove("debug_fact_focus_boy");
	}	
}

exec function startContentEP2(contentName : string)			
{
	var teleportPosition 	: Vector;
	var worldName			: String;
	var shouldTeleport 		: Bool;
		
	worldName =  theGame.GetWorld().GetDepotPath();
		
	if(StrFindFirst(worldName, "bob")<0)   
	{
		Log("temp.ws:startContentEP2: Use this command only on bob.w2w level.");
		return;
	}
	
	shouldTeleport = true;
	
	switch(contentName)
	{
	

		case 'poi_bar_a_01' :
		{
			teleportPosition = Vector(835, -575, 60);
			break;
		}

		case 'poi_bar_a_02' :
		{
			teleportPosition = Vector(1035, -1194, 7);
			break;
		}
		
		case 'poi_bar_a_03' :
		{
			teleportPosition = Vector(401, -1169, 3);
			break;
		}

		case 'poi_bar_b_04' :
		{
			teleportPosition = Vector(513, -1217, 5);
			break;
		}
		
		case 'poi_car_a_01' :
		{
			teleportPosition = Vector(636, -1524, 25);
			break;
		}
		
		case 'poi_car_b_04' :
		{
			teleportPosition = Vector(397, -1434, 10);
			break;
		}

		case 'poi_car_c_03' :
		{
			teleportPosition = Vector(-362, -1914, 69);
			break;
		}		
	
		case 'poi_car_a_02' :
		{
			teleportPosition = Vector(482, -1890, 63);
			break;
		}
		
		case 'poi_san_a_01' :
		{
			teleportPosition = Vector(247, -1444, 9);
			break;
		}

		case 'poi_san_b_02' :
		{
			teleportPosition = Vector(62, -1034, 2);
			break;
		}			
	
		case 'poi_gor_a_01' :
		{
			teleportPosition = Vector(-882, -1572, 83);
			break;
		}
		
		case 'poi_gor_b_02' :
		{
			teleportPosition = Vector(-1047, -1201, 158);
			break;
		}

		case 'poi_gor_c_04' :
		{
			teleportPosition = Vector(-1254, -879, 107);
			break;
		}		
		case 'poi_gor_d_05' :
		{
			teleportPosition = Vector(-1126, -29, 49);
			break;
		}
		
		case 'poi_gor_d_06' :
		{
			teleportPosition = Vector(-1053, -138, 10);
			break;
		}

		case 'poi_gor_d_07' :
		{
			teleportPosition = Vector(-1011, 227, 49);
			break;
		}	

		case 'poi_vin_a_01' :
		{
			teleportPosition = Vector(-785, -511, 37);
			break;
		}
		
		case 'poi_vin_a_02' :
		{
			teleportPosition = Vector(-439, -589, 53);
			break;
		}

		case 'poi_vin_b_03' :
		{
			teleportPosition = Vector(-203, -381, 17);
			break;
		}		

		case 'poi_vin_b_04' :
		{
			teleportPosition = Vector(134, -337, 11);
			break;
		}
		
		case 'poi_vin_b_05' :
		{
			teleportPosition = Vector(41, -99, 2);
			break;
		}

		case 'poi_ved_a_01' :
		{
			teleportPosition = Vector(-194, 310, 6);
			break;
		}	

		case 'poi_ved_a_02' :
		{
			teleportPosition = Vector(-476, 666, 4);
			break;
		}
		
		case 'poi_ved_a_03' :
		{
			teleportPosition = Vector(-427, 298, 2);
			break;
		}

		case 'poi_ved_b_04' :
		{
			teleportPosition = Vector(-218, 687, 4);
			break;
		}	

		case 'poi_ved_b_05' :
		{
			teleportPosition = Vector(-17, 510, 13);
			break;
		}
		
		case 'poi_rav_a_01' :
		{
			teleportPosition = Vector(141, -582, 21);
			break;
		}

		case 'poi_rav_a_02' :
		{
			teleportPosition = Vector(-435, -561, 22);
			break;
		}			

		case 'poi_rav_a_04' :
		{
			teleportPosition = Vector(244, -664, 3);
			break;
		}	

		case 'poi_rav_b_03' :
		{
			teleportPosition = Vector(209, -125, 19);
			break;
		}
		
		case 'poi_myr_a_01' :
		{
			teleportPosition = Vector(392, 131, 5);
			break;
		}

		case 'poi_myr_a_02' :
		{
			teleportPosition = Vector(660, 148, 4);
			break;
		}	

		
	
		case 'mq7001' :
		{
			teleportPosition = Vector(-469, -1503, 91);
			break;
		}	

		case 'mq7002' :
		{
			teleportPosition = Vector(-630, -1206, 109);
			break;
		}	
		
		case 'mq7003' :
		{
			teleportPosition = Vector(790, 40, 4);
			break;
		}	
		
		case 'mq7004' :
		{
			teleportPosition = Vector(-1304, -281, 37);
			break;
		}	
		
		case 'mq7006' :
		{
			teleportPosition = Vector(-948, -751, 63);
			break;
		}	
		
		case 'mq7007' :
		{
			teleportPosition = Vector(286, -1670, 44);
			break;
		}	

	
		case 'mq7009' :
		{
			teleportPosition = Vector(-496, -1394, 93);
			break;
		}	
		
		case 'mq7010' :
		{
			teleportPosition = Vector(674, -751, 15);
			break;
		}			
		case 'mq7011' :
		{
			teleportPosition = Vector(-519, -1416, 93);
			break;
		}	
		
		case 'mq7013' :
		{
			teleportPosition = Vector(-576, -1274, 106);
			break;
		}	
		
		case 'mq7015' :
		{
			teleportPosition = Vector(-518, -1326, 95);
			break;
		}	

		case 'mq7017' :
		{
			teleportPosition = Vector(428, -54, 11);
			break;
		}	
		
		case 'mq7018' :
		{
			teleportPosition = Vector(5.7, 230, 10.5);
			break;
		}	

		case 'mq7020' :
		{
			teleportPosition = Vector(-495, -1540, 91);
			break;
		}	
		
		case 'mq7021' :
		{
			teleportPosition = Vector(-1142, -940, 118);
			break;
		}	
		
		case 'mq7022' :
		{
			teleportPosition = Vector(310, -1029, 5);
			break;
		}

	
	
		case 'blacksmith' :
		{
			teleportPosition = Vector(-558, -1370, 91);
			break;
		}
		
	
	
		case 'th700_prison' :
		{
			teleportPosition = Vector(-1167.86, -819.229, 125.85);
			break;
		}

		case 'th700_crypt' :
		{
			teleportPosition = Vector(-414.49, -1489.24, 90.1729);
			break;
		}
		
		case 'th700_vault' :
		{
			teleportPosition = Vector(-656.499, 60.7197, 4.90265);
			break;
		}

		case 'th700_lake' :
		{
			teleportPosition = Vector(772.325, -162.962, 15.2514);
			break;
		}
		
		case 'th700_chapel' :
		{
			teleportPosition = Vector(-875.6, -1580.38, 85.1843);
			break;
		}
		
		default:
		{
			shouldTeleport = false;											
			Log("temp.ws:startContentEP2: This name was not defined.");
		}
	
	}
	
	if(shouldTeleport) 								
	{
		thePlayer.Teleport(teleportPosition);
	}
}

exec function addset( set : EItemSetType, optional equip : bool, optional addExp : bool, optional clearGeralt : bool )
{
	var witcher : W3PlayerWitcher;
	
	witcher = GetWitcherPlayer();
	FactsAdd( "DebugNoLevelUpUpdates" );
	
	if( clearGeralt )
	{
		witcher.Debug_ClearCharacterDevelopment();
	}
	
	if( addExp )
	{
		witcher.AddPoints( EExperiencePoint, 85000, false );
	}
	
	switch( set )
	{
		case EIST_Lynx:
			if(equip)
			{
				witcher.AddAndEquipItem( 'Lynx Armor 4' );
				witcher.AddAndEquipItem( 'Lynx Pants 5' );
				witcher.AddAndEquipItem( 'Lynx Gloves 5' );
				witcher.AddAndEquipItem( 'Lynx Boots 5' );
				witcher.AddAndEquipItem( 'Lynx School steel sword 4' );
				witcher.AddAndEquipItem( 'Lynx School silver sword 4' );
			}
			else
			{
				thePlayer.inv.AddAnItem( 'Lynx Armor 4' );
				thePlayer.inv.AddAnItem( 'Lynx Pants 5' );
				thePlayer.inv.AddAnItem( 'Lynx Gloves 5' );
				thePlayer.inv.AddAnItem( 'Lynx Boots 5' );
				thePlayer.inv.AddAnItem( 'Lynx School steel sword 4' );
				thePlayer.inv.AddAnItem( 'Lynx School silver sword 4' );
			}
			break;
		case EIST_Gryphon:
			if(equip)
			{
				witcher.AddAndEquipItem( 'Gryphon Armor 4' );
				witcher.AddAndEquipItem( 'Gryphon Pants 5' );
				witcher.AddAndEquipItem( 'Gryphon Gloves 5' );
				witcher.AddAndEquipItem( 'Gryphon Boots 5' );
				witcher.AddAndEquipItem( 'Gryphon School steel sword 4' );
				witcher.AddAndEquipItem( 'Gryphon School silver sword 4' );
			}
			else
			{
				thePlayer.inv.AddAnItem( 'Gryphon Armor 4' );
				thePlayer.inv.AddAnItem( 'Gryphon Pants 5' );
				thePlayer.inv.AddAnItem( 'Gryphon Gloves 5' );
				thePlayer.inv.AddAnItem( 'Gryphon Boots 5' );
				thePlayer.inv.AddAnItem( 'Gryphon School steel sword 4' );
				thePlayer.inv.AddAnItem( 'Gryphon School silver sword 4' );
			}
			break;
		case EIST_Bear:
			witcher.Debug_BearSetBonusQuenSkills();
			if(equip)
			{
				witcher.AddAndEquipItem( 'Bear Armor 4' );
				witcher.AddAndEquipItem( 'Bear Pants 5' );
				witcher.AddAndEquipItem( 'Bear Gloves 5' );
				witcher.AddAndEquipItem( 'Bear Boots 5' );
				witcher.AddAndEquipItem( 'Bear School steel sword 4' );
				witcher.AddAndEquipItem( 'Bear School silver sword 4' );
			}
			else
			{
				thePlayer.inv.AddAnItem( 'Bear Armor 4' );
				thePlayer.inv.AddAnItem( 'Bear Pants 5' );
				thePlayer.inv.AddAnItem( 'Bear Gloves 5' );
				thePlayer.inv.AddAnItem( 'Bear Boots 5' );
				thePlayer.inv.AddAnItem( 'Bear School steel sword 4' );
				thePlayer.inv.AddAnItem( 'Bear School silver sword 4' );
			}
			break;
		case EIST_Wolf:
			witcher.inv.AddAnItem( 'Grapeshot 2' );
			witcher.inv.AddAnItem( 'Dancing Star 2' );
			witcher.inv.AddAnItem( 'Hybrid Oil 2' );
			witcher.inv.AddAnItem( 'Cursed Oil 2' );
			witcher.inv.AddAnItem( 'Magical Oil 2' );
			witcher.inv.AddAnItem( 'Specter Oil 2' );
			if(equip)
			{
				witcher.AddAndEquipItem( 'Wolf Armor 4' );
				witcher.AddAndEquipItem( 'Wolf Pants 5' );
				witcher.AddAndEquipItem( 'Wolf Gloves 5' );
				witcher.AddAndEquipItem( 'Wolf Boots 5' );
				witcher.AddAndEquipItem( 'Wolf School steel sword 4' );
				witcher.AddAndEquipItem( 'Wolf School silver sword 4' );
			}
			else
			{
				thePlayer.inv.AddAnItem( 'Wolf Armor 4' );
				thePlayer.inv.AddAnItem( 'Wolf Pants 5' );
				thePlayer.inv.AddAnItem( 'Wolf Gloves 5' );
				thePlayer.inv.AddAnItem( 'Wolf Boots 5' );
				thePlayer.inv.AddAnItem( 'Wolf School steel sword 4' );
				thePlayer.inv.AddAnItem( 'Wolf School silver sword 4' );
			}
			break;
		case EIST_RedWolf:
			witcher.inv.AddAnItem( 'Black Blood 2' );
			witcher.inv.AddAnItem( 'Swallow 2' );
			witcher.inv.AddAnItem( 'Grapeshot 2' );
			if(equip)
			{
				witcher.AddAndEquipItem( 'Red Wolf Armor 1' );
				witcher.AddAndEquipItem( 'Red Wolf Pants 1' );
				witcher.AddAndEquipItem( 'Red Wolf Gloves 1' );
				witcher.AddAndEquipItem( 'Red Wolf Boots 1' );
				witcher.AddAndEquipItem( 'Red Wolf School steel sword 1' );
				witcher.AddAndEquipItem( 'Red Wolf School silver sword 1' );
			}
			else
			{
				thePlayer.inv.AddAnItem( 'Red Wolf Armor 1' );
				thePlayer.inv.AddAnItem( 'Red Wolf Pants 1' );
				thePlayer.inv.AddAnItem( 'Red Wolf Gloves 1' );
				thePlayer.inv.AddAnItem( 'Red Wolf Boots 1' );
				thePlayer.inv.AddAnItem( 'Red Wolf School steel sword 1' );
				thePlayer.inv.AddAnItem( 'Red Wolf School silver sword 1' );
			}
			break;
		case EIST_Vampire:
			if( equip )
			{
				witcher.AddAndEquipItem( 'q702_vampire_boots' );
				witcher.AddAndEquipItem( 'q702_vampire_gloves' );
				witcher.AddAndEquipItem( 'q702_vampire_pants' );
				witcher.AddAndEquipItem( 'q702_vampire_armor' );
				witcher.AddAndEquipItem( 'q702 vampire steel sword' );
				witcher.AddAndEquipItem( 'q702_vampire_mask' );
			}
			else
			{
				witcher.inv.AddAnItem( 'q702_vampire_boots' );
				witcher.inv.AddAnItem( 'q702_vampire_gloves' );
				witcher.inv.AddAnItem( 'q702_vampire_pants' );
				witcher.inv.AddAnItem( 'q702_vampire_armor' );
				witcher.inv.AddAnItem( 'q702_vampire_mask' );
				witcher.inv.AddAnItem( 'q702 vampire steel sword' );
			}
	}
}

exec function muteq( number : int, optional godMode : int )
{
	var mut : EPlayerMutationType;
	
	GetWitcherPlayer().MutationSystemEnable( true );
	mut = number;
	( ( W3PlayerAbilityManager ) GetWitcherPlayer().abilityManager ).DEBUG_DevelopAndEquipMutation( mut );
	
	if( godMode == 1 )
	{
		god_internal();
	}
	else if( godMode == 2 )
	{
		god2_internal();
	}
}

exec function mutall()
{
	mutall_internal();
}

function mutall_internal()
{
	var pam : W3PlayerAbilityManager;
	var i : int;
	
	GetWitcherPlayer().MutationSystemEnable( true );
	pam = ( W3PlayerAbilityManager ) GetWitcherPlayer().abilityManager;
	for( i=12; i>0; i-=1 )
	{
		pam.DEBUG_DevelopAndEquipMutation( i );
	}
}

exec function enablemutations( enable : bool )
{
	GetWitcherPlayer().MutationSystemEnable( enable );
}

exec function tmut( optional itemsCount : int )
{
	var lm : W3PlayerWitcher;
	var i,exp : int;
	
	GetWitcherPlayer().MutationSystemEnable( true );
	
	if (itemsCount == 0)
	{
		itemsCount = 120;
	}
	
	thePlayer.inv.AddAnItem( 'Greater mutagen blue', itemsCount );
	thePlayer.inv.AddAnItem( 'Greater mutagen red', itemsCount );
	thePlayer.inv.AddAnItem( 'Greater mutagen green', itemsCount );
	
	GetWitcherPlayer().AddPoints( ESkillPoint, itemsCount, true );
	
	lm = GetWitcherPlayer();
	for( i=0; i<30; i+=1 )
	{
		exp = lm.GetTotalExpForNextLevel() - lm.GetPointsTotal( EExperiencePoint );
		lm.AddPoints( EExperiencePoint, exp, false );
	}
}

exec function printmut()
{
	var pam : W3PlayerAbilityManager;
	var mutations : array< SMutation >;
	var i, j : int;
	var progress : SMutationProgress;
	var str, tmpString : string;
	var reqMutation : EPlayerMutationType;
	var colorAdded : bool;
	
	pam = (W3PlayerAbilityManager)GetWitcherPlayer().abilityManager;
	mutations = pam.GetMutations();
	LogMutation( "==========================================================================================" );
	LogMutation( "================================= Mutations Status =======================================" );
	LogMutation( "==========================================================================================" );

	for( i=0; i<mutations.Size(); i+=1 )
	{
		
		tmpString = GetWitcherPlayer().GetMutationLocalizedName( mutations[ i ].type );
		if( tmpString == "" )
		{
			tmpString = "missing localization key";
		}
		LogMutation( mutations[ i ].type + " - " + tmpString );
		
		
		tmpString = GetWitcherPlayer().GetMutationLocalizedDescription( mutations[ i ].type );
		if( tmpString == "" )
		{
			tmpString = "missing localization key";
		}
		LogMutation( tmpString );
		
		
		str = "Mutation is ";
		colorAdded = false;
		if( mutations[ i ].colors.Contains( SC_Red ) )
		{
			str += "Red";
			colorAdded = true;
		}
		if( mutations[ i ].colors.Contains( SC_Green ) )
		{
			if( colorAdded )
			{
				str += " + ";
			}
			str += "Green";
			colorAdded = true;
		}		
		if( mutations[ i ].colors.Contains( SC_Blue ) )
		{
			if( colorAdded )
			{
				str += " + ";
			}
			str += "Blue";
		}
		if( mutations[ i ].colors.Size() == 0 )
		{
			str += "of no color";
		}
		LogMutation( str );
		
		
		str = "Required mutations: ";
		for( j=0; j<mutations[ i ].requiredMutations.Size(); j+=1 )
		{
			reqMutation = mutations[ i ].requiredMutations[j];
			tmpString = GetWitcherPlayer().GetMutationLocalizedName( reqMutation );
			if( tmpString == "" )
			{
				tmpString = "missing localization key";
			}
			str += reqMutation + "(" + tmpString + "), ";
		}
		if( mutations[ i ].requiredMutations.Size() == 0 )
		{
			str += "None";
		}
		LogMutation( str );
		
		
		progress = mutations[ i ].progress;
		LogMutation("Progress " + SpaceFill( pam.GetMutationResearchProgress( mutations[ i ].type ), 3, ESFM_JustifyRight) + "%     Red: " + 
				progress.redUsed + "/" + progress.redRequired +	"     Green: " + progress.greenUsed + "/" + progress.greenRequired + 
				"     Blue: " + progress.blueUsed + "/" + progress.blueRequired + "     SkillPoints: " + progress.skillpointsUsed + "/" + progress.skillpointsRequired );
				
		
		if( mutations[ i ].type == EPMT_MutationMaster )
		{
			LogMutation( "Stage: " + pam.GetMasterMutationStage() );
		}
		
		
		LogMutation("");
	}
}

exec function finishTarget()
{
	thePlayer.AddTimer( 'PerformFinisher', 0.0 );
}

enum EncumbranceBoyMode
{
	EBM_Swap,
	EBM_On,
	EBM_Off
}

exec function mule( optional mode : int )
{
	EncumbranceBoy( mode );
}

function EncumbranceBoy( mode : EncumbranceBoyMode )
{
	if( mode == EBM_Off || ( mode == EBM_Swap && FactsQuerySum( "DEBUG_EncumbranceBoy" ) ) )
	{
		FactsRemove( "DEBUG_EncumbranceBoy" );
		GetWitcherPlayer().UpdateEncumbrance();
		LogCheats( "Mule is now OFF" );
	}
	else
	{
		FactsAdd( "DEBUG_EncumbranceBoy" );
		GetWitcherPlayer().RemoveAllBuffsOfType( EET_OverEncumbered );
		LogCheats( "Mule is now ON" );
	}
}

exec function testEP2Perks()
{
	var w		: W3PlayerWitcher;
	var inv		: CInventoryComponent;
	var ids		: array<SItemUniqueId>;
	
	w = GetWitcherPlayer();
	inv = w.GetInventory();
	
	FactsAdd( "DebugNoLevelUpUpdates" );
	w.AddPoints( EExperiencePoint, 25000, false );
	
	ids = inv.AddAnItem( 'Apple', 15, true, false, false );
	w.EquipItem( ids[0] );
	ids = inv.AddAnItem( 'Chicken Sandwich', 15, true, false, false );
	w.EquipItem( ids[0] );
	
	ids = inv.AddAnItem( 'Explosive Bolt', 15, true, false, false);
	w.EquipItem( ids[0] );
	
	ids = thePlayer.inv.AddAnItem('Grapeshot 3');
	thePlayer.inv.SingletonItemSetAmmo(ids[0], thePlayer.inv.SingletonItemGetMaxAmmo(ids[0]));
	ids = thePlayer.inv.AddAnItem('Dwimeritium Bomb 3');
	thePlayer.inv.SingletonItemSetAmmo(ids[0], thePlayer.inv.SingletonItemGetMaxAmmo(ids[0]));
	ids = thePlayer.inv.AddAnItem('Dragons Dream 3');
	thePlayer.inv.SingletonItemSetAmmo(ids[0], thePlayer.inv.SingletonItemGetMaxAmmo(ids[0]));
	ids = thePlayer.inv.AddAnItem('Devils Puffball 3');
	thePlayer.inv.SingletonItemSetAmmo(ids[0], thePlayer.inv.SingletonItemGetMaxAmmo(ids[0]));
	
	theGame.RequestMenuWithBackground( 'CharacterMenu', 'CommonMenu' );
}

exec function mutrev( optional unlockMutations : bool )
{
	
	fb3_internal( 30, 'sign' );
	
	
	GetWitcherPlayer().AddAndEquipItem( 'Gnomish sword 2' );
	
	
	GetWitcherPlayer().AddAndEquipItem( 'Blizzard 3' );
	
	
	GetWitcherPlayer().GainStat( BCS_Focus, 3.f );
	
	
	if( unlockMutations )
	{
		mutall_internal();
	}
	
	
	GetWitcherPlayer().AddAndEquipItem( 'Mutagen 2' );
	
	
	god_internal();
}

exec function addsetrec( n : EItemSetType, optional clearInv : bool )
{
	var w		: W3PlayerWitcher;
	
	w = GetWitcherPlayer();

	if( clearInv )
	{
		w.Debug_ClearCharacterDevelopment();
	}
	
	if( w.GetLevel() < 50 )
	{
		w.AddPoints( EExperiencePoint, 85000, false );
	}
	
	w.inv.AddAnItem('Infused shard', 30);
	w.inv.AddMoney( 10000 );
	
	
	switch( n )
	{
		case EIST_Lynx:
			w.inv.AddAnItem( 'Lynx School steel sword 3' );
			w.inv.AddAnItem( 'Lynx School steel sword Upgrade schematic 4' );
			w.inv.AddAnItem( 'Lynx School silver sword 3' );
			w.inv.AddAnItem( 'Lynx School silver sword Upgrade schematic 4' );
			w.inv.AddAnItem( 'Lynx Armor 3' );
			w.inv.AddAnItem( 'Witcher Lynx Jacket Upgrade schematic 4' );
			w.inv.AddAnItem( 'Lynx Gloves 4' );
			w.inv.AddAnItem( 'Witcher Lynx Gloves Upgrade schematic 5' );
			w.inv.AddAnItem( 'Lynx Boots 4' );
			w.inv.AddAnItem( 'Witcher Lynx Boots Upgrade schematic 5' );
			w.inv.AddAnItem( 'Lynx Pants 4' );
			w.inv.AddAnItem( 'Witcher Lynx Pants Upgrade schematic 5' );
			break;
		case EIST_Gryphon:
			w.inv.AddAnItem( 'Gryphon School steel sword 3' );
			w.inv.AddAnItem( 'Gryphon School steel sword Upgrade schematic 4' );
			w.inv.AddAnItem( 'Gryphon School silver sword 3' );
			w.inv.AddAnItem( 'Gryphon School silver sword Upgrade schematic 4' );
			w.inv.AddAnItem( 'Gryphon Armor 3' );
			w.inv.AddAnItem( 'Witcher Gryphon Jacket Upgrade schematic 4' );
			w.inv.AddAnItem( 'Gryphon Gloves 4' );
			w.inv.AddAnItem( 'Witcher Gryphon Gloves Upgrade schematic 5' );
			w.inv.AddAnItem( 'Gryphon Boots 4' );
			w.inv.AddAnItem( 'Witcher Gryphon Boots Upgrade schematic 5' );
			w.inv.AddAnItem( 'Gryphon Pants 4' );
			w.inv.AddAnItem( 'Witcher Gryphon Pants Upgrade schematic 5' );
			break;
		case EIST_Bear:
			w.inv.AddAnItem( 'Bear School steel sword 3' );
			w.inv.AddAnItem( 'Bear School steel sword Upgrade schematic 4' );
			w.inv.AddAnItem( 'Bear School silver sword 3' );
			w.inv.AddAnItem( 'Bear School silver sword Upgrade schematic 4' );
			w.inv.AddAnItem( 'Bear Armor 3' );
			w.inv.AddAnItem( 'Witcher Bear Jacket Upgrade schematic 4' );
			w.inv.AddAnItem( 'Bear Gloves 4' );
			w.inv.AddAnItem( 'Witcher Bear Gloves Upgrade schematic 5' );
			w.inv.AddAnItem( 'Bear Boots 4' );
			w.inv.AddAnItem( 'Witcher Bear Boots Upgrade schematic 5' );
			w.inv.AddAnItem( 'Bear Pants 4' );
			w.inv.AddAnItem( 'Witcher Bear Pants Upgrade schematic 5' );
			w.Debug_BearSetBonusQuenSkills();
			break;
		case EIST_Wolf:
			w.inv.AddAnItem( 'Wolf School steel sword 3' );
			w.inv.AddAnItem( 'Wolf School steel sword Upgrade schematic 4' );
			w.inv.AddAnItem( 'Wolf School silver sword 3' );
			w.inv.AddAnItem( 'Wolf School silver sword Upgrade schematic 4' );
			w.inv.AddAnItem( 'Wolf Armor 3' );
			w.inv.AddAnItem( 'Witcher Wolf Jacket Upgrade schematic 4' );
			w.inv.AddAnItem( 'Wolf Gloves 4' );
			w.inv.AddAnItem( 'Witcher Wolf Gloves Upgrade schematic 5' );
			w.inv.AddAnItem( 'Wolf Boots 4' );
			w.inv.AddAnItem( 'Witcher Wolf Boots Upgrade schematic 5' );
			w.inv.AddAnItem( 'Wolf Pants 4' );
			w.inv.AddAnItem( 'Witcher Wolf Pants Upgrade schematic 5' );
			w.inv.AddAnItem( 'Grapeshot 2' );
			w.inv.AddAnItem( 'Dancing Star 2' );
			w.inv.AddAnItem( 'Hybrid Oil 2' );
			w.inv.AddAnItem( 'Cursed Oil 2' );
			w.inv.AddAnItem( 'Magical Oil 2' );
			w.inv.AddAnItem( 'Specter Oil 2' );
		case EIST_RedWolf:
			w.inv.AddAnItem( 'Red Wolf School steel sword schematic 1' );
			w.inv.AddAnItem( 'Red Wolf School silver sword schematic 1' );
			w.inv.AddAnItem( 'Witcher Red Wolf Jacket schematic 1' );
			w.inv.AddAnItem( 'Witcher Red Wolf Gloves schematic 1' );
			w.inv.AddAnItem( 'Witcher Red Wolf Boots schematic 1' );
			w.inv.AddAnItem( 'Witcher Red Wolf Pants schematic 1' );
			w.inv.AddAnItem( 'Black Blood 2' );
			w.inv.AddAnItem( 'Swallow 2' );
			w.inv.AddAnItem( 'Grapeshot 2' );
			break;
		default:
			break;	
	}
}

exec function countFT()
{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();
		var arr1 : array< SAvailableFastTravelMapPin >;	
		arr1 = mapManager.GetFastTravelPoints(true, false, false, true, true);
		
		Log( arr1.Size() );
}

exec function Clear()
{
	GetWitcherPlayer().GetInventory().RemoveAllItems();
}

exec function rainAnim()
{
	
	thePlayer.ActionPlaySlotAnimationAsync( 'PLAYER_SLOT', 'geralt_mutation_11', 0.2, 0.2 );
}

exec function activateAllBestiaryEP2()
{
var manager : CWitcherJournalManager;
	
	manager = theGame.GetJournalManager();
	
	activateJournalBestiaryEntryWithAlias("BestiaryPanther", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCBeastOfBeauclaire", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCPigs", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCBigBadWolf", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCEP2Boar", manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiaryDracolizard", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCDracolizardMatriarch", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCSilverBasilisk", manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiarySharley", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCSharleyMatriarch", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCSpriggan", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCSharleyCaptive", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCFTWitch", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCMQ7002Borowy", manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiaryBarghest", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCNightmare", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCDaphne", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCRapunzel", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCBeanshee", manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiaryGarkain", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryBruxa", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryFleder", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryAlp", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCBruxaCB", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCAlphaGarkain", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCDettlaff", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCProtofleder", manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiaryDagonet", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryCloudGiant"	, manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiaryGraveir", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryWicht", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCWightCollector", manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiaryScolopendromorph", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryPaleWidow", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryKikimoraWarrior", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryKikimoraWorker"	, manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiaryArchespore", manager);
	
	
	activateJournalBestiaryEntryWithAlias("BestiaryDarkPixie", manager);
	activateJournalBestiaryEntryWithAlias("BestiaryQCMoreauGolem", manager);
}

exec function addarmorEP2(armorType : string)
{
	if(armorType == "set")
	{
		thePlayer.inv.AddAnItem('Lynx Armor 4',1);
		thePlayer.inv.AddAnItem('Gryphon Armor 4',1);
		thePlayer.inv.AddAnItem('Bear Armor 4',1);
		thePlayer.inv.AddAnItem('Wolf Armor 4',1);
		thePlayer.inv.AddAnItem('Red Wolf Armor 1',1);
		thePlayer.inv.AddAnItem('Red Wolf Armor 2',1);
	}
	else if(armorType == "craft")
	{
		thePlayer.inv.AddAnItem('Guard Lvl2 Armor 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Armor 3',1);
		thePlayer.inv.AddAnItem('Knight Geralt Armor 3',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Armor 3',1);
		thePlayer.inv.AddAnItem('Toussaint Armor 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 Armor 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Armor 3',1);
	}
	else if(armorType == "basic")
	{
		
		thePlayer.inv.AddAnItem('Guard Lvl1 Armor 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 Armor 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Armor 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Armor 2',1);
		
		thePlayer.inv.AddAnItem('Guard Lvl2 Armor 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 Armor 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Armor 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Armor 2',1);
		
		thePlayer.inv.AddAnItem('Knight Geralt Armor 1',1);
		thePlayer.inv.AddAnItem('Knight Geralt Armor 2',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Armor 1',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Armor 2',1);
		thePlayer.inv.AddAnItem('Toussaint Armor 2',1);
		thePlayer.inv.AddAnItem('sq701_geralt_armor',1);
		thePlayer.inv.AddAnItem('sq701_ravix_armor',1);
	}
	else if(armorType == "all")
	{
		thePlayer.inv.AddAnItem('Lynx Armor 4',1);
		thePlayer.inv.AddAnItem('Gryphon Armor 4',1);
		thePlayer.inv.AddAnItem('Bear Armor 4',1);
		thePlayer.inv.AddAnItem('Wolf Armor 4',1);
		thePlayer.inv.AddAnItem('Red Wolf Armor 1',1);
		thePlayer.inv.AddAnItem('Red Wolf Armor 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 Armor 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Armor 3',1);
		thePlayer.inv.AddAnItem('Knight Geralt Armor 3',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Armor 3',1);
		thePlayer.inv.AddAnItem('Toussaint Armor 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 Armor 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Armor 3',1);
			
		thePlayer.inv.AddAnItem('Guard Lvl1 Armor 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 Armor 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Armor 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Armor 2',1);
		
		thePlayer.inv.AddAnItem('Guard Lvl2 Armor 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 Armor 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Armor 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Armor 2',1);
		
		thePlayer.inv.AddAnItem('Knight Geralt Armor 1',1);
		thePlayer.inv.AddAnItem('Knight Geralt Armor 2',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Armor 1',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Armor 2',1);
		thePlayer.inv.AddAnItem('Toussaint Armor 2',1);
		thePlayer.inv.AddAnItem('sq701_geralt_armor',1);
		thePlayer.inv.AddAnItem('sq701_ravix_armor',1);
	}
	else
	{
		Log("temp.ws:addarmorEP2: You did not provide proper armor type, please use set, craft or all to add specific ones or all to add ALL items");
	}
}
exec function addbootsEP2(armorType : string)
{
	if(armorType == "set")
	{
		thePlayer.inv.AddAnItem('Lynx Boots 5',1);
		thePlayer.inv.AddAnItem('Gryphon Boots 5',1);
		thePlayer.inv.AddAnItem('Bear Boots 5',1);
		thePlayer.inv.AddAnItem('Wolf Boots 5',1);
		thePlayer.inv.AddAnItem('Red Wolf Boots 1',1);
		thePlayer.inv.AddAnItem('Red Wolf Boots 2',1);
	}
	else if(armorType == "craft")
	{
		thePlayer.inv.AddAnItem('Guard Lvl1 Boots 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Boots 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 Boots 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Boots 3',1);
		thePlayer.inv.AddAnItem('Knight Geralt Boots 3',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Boots 3',1);
		thePlayer.inv.AddAnItem('Toussaint Boots 3',1);
	}
	else if(armorType == "basic")
	{
		
		thePlayer.inv.AddAnItem('Guard Lvl1 Boots 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 Boots 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Boots 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Boots 2',1);
		
		thePlayer.inv.AddAnItem('Guard Lvl2 Boots 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 Boots 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Boots 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Boots 2',1);
		
		thePlayer.inv.AddAnItem('Knight Geralt Boots 1',1);
		thePlayer.inv.AddAnItem('Knight Geralt Boots 2',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Boots 1',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Boots 2',1);
		thePlayer.inv.AddAnItem('Toussaint Boots 2',1);
	}
	else if(armorType == "all")
	{
		thePlayer.inv.AddAnItem('Lynx Boots 5',1);
		thePlayer.inv.AddAnItem('Gryphon Boots 5',1);
		thePlayer.inv.AddAnItem('Bear Boots 5',1);
		thePlayer.inv.AddAnItem('Wolf Boots 5',1);
		thePlayer.inv.AddAnItem('Red Wolf Boots 1',1);
		thePlayer.inv.AddAnItem('Red Wolf Boots 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 Boots 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Boots 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 Boots 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Boots 3',1);
		thePlayer.inv.AddAnItem('Knight Geralt Boots 3',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Boots 3',1);
		thePlayer.inv.AddAnItem('Toussaint Boots 3',1);
		
		thePlayer.inv.AddAnItem('Guard Lvl1 Boots 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 Boots 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Boots 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Boots 2',1);
		
		thePlayer.inv.AddAnItem('Guard Lvl2 Boots 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 Boots 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Boots 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Boots 2',1);
		
		thePlayer.inv.AddAnItem('Knight Geralt Boots 1',1);
		thePlayer.inv.AddAnItem('Knight Geralt Boots 2',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Boots 1',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Boots 2',1);
		thePlayer.inv.AddAnItem('Toussaint Boots 2',1);
	}
	else
	{
		Log("You did not provide proper armor type, please use set, craft or all to add specific ones or all to add ALL items");
	}
}
exec function addglovesEP2(armorType : string)
{
	if(armorType == "set")
	{
		thePlayer.inv.AddAnItem('Lynx Gloves 5',1);
		thePlayer.inv.AddAnItem('Gryphon Gloves 5',1);
		thePlayer.inv.AddAnItem('Bear Gloves 5',1);
		thePlayer.inv.AddAnItem('Wolf Gloves 5',1);
		thePlayer.inv.AddAnItem('Red Wolf Gloves 1',1);
		thePlayer.inv.AddAnItem('Red Wolf Gloves 2',1);
	}
	else if(armorType == "craft")
	{
		thePlayer.inv.AddAnItem('Guard Lvl1 Gloves 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Gloves 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 Gloves 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Gloves 3',1);
		thePlayer.inv.AddAnItem('Knight Geralt Gloves 3',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Gloves 3',1);
		thePlayer.inv.AddAnItem('Toussaint Gloves 3',1);
	}
	else if(armorType == "basic")
	{
		
		thePlayer.inv.AddAnItem('Guard Lvl1 Gloves 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 Gloves 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Gloves 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Gloves 2',1);
		
		thePlayer.inv.AddAnItem('Guard Lvl2 Gloves 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 Gloves 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Gloves 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Gloves 2',1);
		
		thePlayer.inv.AddAnItem('Knight Geralt Gloves 1',1);
		thePlayer.inv.AddAnItem('Knight Geralt Gloves 2',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Gloves 1',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Gloves 2',1);
		thePlayer.inv.AddAnItem('Toussaint Gloves 2',1);
	}
	else if (armorType == "all")
	{
		thePlayer.inv.AddAnItem('Lynx Gloves 5',1);
		thePlayer.inv.AddAnItem('Gryphon Gloves 5',1);
		thePlayer.inv.AddAnItem('Bear Gloves 5',1);
		thePlayer.inv.AddAnItem('Wolf Gloves 5',1);
		thePlayer.inv.AddAnItem('Red Wolf Gloves 1',1);
		thePlayer.inv.AddAnItem('Red Wolf Gloves 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 Gloves 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Gloves 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 Gloves 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Gloves 3',1);
		thePlayer.inv.AddAnItem('Knight Geralt Gloves 3',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Gloves 3',1);
		thePlayer.inv.AddAnItem('Toussaint Gloves 3',1);
		
		thePlayer.inv.AddAnItem('Guard Lvl1 Gloves 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 Gloves 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Gloves 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Gloves 2',1);
		
		thePlayer.inv.AddAnItem('Guard Lvl2 Gloves 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 Gloves 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Gloves 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Gloves 2',1);
		
		thePlayer.inv.AddAnItem('Knight Geralt Gloves 1',1);
		thePlayer.inv.AddAnItem('Knight Geralt Gloves 2',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Gloves 1',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Gloves 2',1);
		thePlayer.inv.AddAnItem('Toussaint Gloves 2',1);
	}
	else
	{
		Log("You did not provide proper armor type, please use set, craft or all to add specific ones or all to add ALL items");
	}
}
exec function addpantsEP2(armorType : string)
{
	if(armorType == "set")
	{
		thePlayer.inv.AddAnItem('Lynx Pants 5',1);
		thePlayer.inv.AddAnItem('Gryphon Pants 5',1);
		thePlayer.inv.AddAnItem('Bear Pants 5',1);
		thePlayer.inv.AddAnItem('Wolf Pants 5',1);
		thePlayer.inv.AddAnItem('Red Wolf Pants 1',1);
		thePlayer.inv.AddAnItem('Red Wolf Pants 2',1);
	}
	else if(armorType == "craft")
	{
		thePlayer.inv.AddAnItem('Guard Lvl1 Pants 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Pants 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 Pants 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Pants 3',1);
		thePlayer.inv.AddAnItem('Knight Geralt Pants 3',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Pants 3',1);
		thePlayer.inv.AddAnItem('Toussaint Pants 3',1);
	}
	else if(armorType == "basic")
	{
		
		thePlayer.inv.AddAnItem('Guard Lvl1 Pants 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 Pants 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Pants 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Pants 2',1);
		
		thePlayer.inv.AddAnItem('Guard Lvl2 Pants 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 Pants 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Pants 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Pants 2',1);
		
		thePlayer.inv.AddAnItem('Knight Geralt Pants 1',1);
		thePlayer.inv.AddAnItem('Knight Geralt Pants 2',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Pants 1',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Pants 2',1);
		thePlayer.inv.AddAnItem('Toussaint Pants 2',1);
	}
	else if (armorType == "all")
	{
		thePlayer.inv.AddAnItem('Lynx Pants 5',1);
		thePlayer.inv.AddAnItem('Gryphon Pants 5',1);
		thePlayer.inv.AddAnItem('Bear Pants 5',1);
		thePlayer.inv.AddAnItem('Wolf Pants 5',1);
		thePlayer.inv.AddAnItem('Red Wolf Pants 1',1);
		thePlayer.inv.AddAnItem('Red Wolf Pants 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 Pants 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Pants 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 Pants 3',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Pants 3',1);
		thePlayer.inv.AddAnItem('Knight Geralt Pants 3',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Pants 3',1);
		thePlayer.inv.AddAnItem('Toussaint Pants 3',1);
		
		thePlayer.inv.AddAnItem('Guard Lvl1 Pants 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 Pants 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Pants 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl1 A Pants 2',1);
		
		thePlayer.inv.AddAnItem('Guard Lvl2 Pants 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 Pants 2',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Pants 1',1);
		thePlayer.inv.AddAnItem('Guard Lvl2 A Pants 2',1);
		
		thePlayer.inv.AddAnItem('Knight Geralt Pants 1',1);
		thePlayer.inv.AddAnItem('Knight Geralt Pants 2',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Pants 1',1);
		thePlayer.inv.AddAnItem('Knight Geralt A Pants 2',1);
		thePlayer.inv.AddAnItem('Toussaint Pants 2',1);
	}
	else
	{
		Log("You did not provide proper armor type, please use set, craft or all to add specific ones or all to add ALL items");
	}
}

exec function addEP2Set(setType : string)
{
	if (setType == "bear")
	{
		thePlayer.inv.AddAnItem('Bear Armor 4',1);
		thePlayer.inv.AddAnItem('Bear Boots 5',1);
		thePlayer.inv.AddAnItem('Bear Pants 5',1);
		thePlayer.inv.AddAnItem('Bear Gloves 5',1);
		thePlayer.inv.AddAnItem('Bear School steel sword 4',1);
		thePlayer.inv.AddAnItem('Bear School silver sword 4',1);
	
	}
	else if (setType == "lynx")
	{
		thePlayer.inv.AddAnItem('Lynx Armor 4',1);
		thePlayer.inv.AddAnItem('Lynx Boots 5',1);
		thePlayer.inv.AddAnItem('Lynx Pants 5',1);
		thePlayer.inv.AddAnItem('Lynx Gloves 5',1);
		thePlayer.inv.AddAnItem('Lynx School steel sword 4',1);
		thePlayer.inv.AddAnItem('Lynx School silver sword 4',1);
		
	}
	else if (setType == "gryphon")
	{
		thePlayer.inv.AddAnItem('Gryphon Armor 4',1);
		thePlayer.inv.AddAnItem('Gryphon Boots 5',1);
		thePlayer.inv.AddAnItem('Gryphon Pants 5',1);
		thePlayer.inv.AddAnItem('Gryphon Gloves 5',1);
		thePlayer.inv.AddAnItem('Gryphon School steel sword 4',1);
		thePlayer.inv.AddAnItem('Gryphon School silver sword 4',1);
		
	}
	else if (setType == "wolf")
	{
		thePlayer.inv.AddAnItem('Wolf Armor 4',1);
		thePlayer.inv.AddAnItem('Wolf Boots 5',1);
		thePlayer.inv.AddAnItem('Wolf Pants 5',1);
		thePlayer.inv.AddAnItem('Wolf Gloves 5',1);
		thePlayer.inv.AddAnItem('Wolf School steel sword 4',1);
		thePlayer.inv.AddAnItem('Wolf School silver sword 4',1);
		
	}
	else if (setType == "manticore1")
	{
		thePlayer.inv.AddAnItem('Red Wolf Armor 1',1);
		thePlayer.inv.AddAnItem('Red Wolf Boots 1',1);
		thePlayer.inv.AddAnItem('Red Wolf Pants 1',1);
		thePlayer.inv.AddAnItem('Red Wolf Gloves 1',1);
		thePlayer.inv.AddAnItem('Red Wolf School steel sword 1',1);
		thePlayer.inv.AddAnItem('Red Wolf School silver sword 1',1);
	}
	else if (setType == "manticore2")
	{
		thePlayer.inv.AddAnItem('Red Wolf Armor 2',1);
		thePlayer.inv.AddAnItem('Red Wolf Boots 2',1);
		thePlayer.inv.AddAnItem('Red Wolf Pants 2',1);
		thePlayer.inv.AddAnItem('Red Wolf Gloves 2',1);
		thePlayer.inv.AddAnItem('Red Wolf School steel sword 2',1);
		thePlayer.inv.AddAnItem('Red Wolf School silver sword 2',1);
		
	}
	else
	{
		Log("No such set! Please use bear, lynx, gryphon, wolf, manticore 1 or manticore 2");
	}
}
exec function addswordEP2(swordType1 : string, optional swordType2 : string)
{
	if(swordType1 == "steel")
	{
		if(swordType2 == "set")
		{
			thePlayer.inv.AddAnItem('Lynx School steel sword 4',1);
			thePlayer.inv.AddAnItem('Gryphon School steel sword 4',1);
			thePlayer.inv.AddAnItem('Bear School steel sword 4',1);
			thePlayer.inv.AddAnItem('Wolf School steel sword 4',1);
			thePlayer.inv.AddAnItem('Red Wolf School steel sword 1',1);
			thePlayer.inv.AddAnItem('Red Wolf School steel sword 2',1);
		}
		else if(swordType2 == "craft")
		{
			thePlayer.inv.AddAnItem('Guard lvl1 steel sword 3',1);
			thePlayer.inv.AddAnItem('Guard lvl2 steel sword 3',1);
			thePlayer.inv.AddAnItem('Knights steel sword 3',1);
			thePlayer.inv.AddAnItem('Hanza steel sword 3',1);
			thePlayer.inv.AddAnItem('Toussaint steel sword 3',1);
			thePlayer.inv.AddAnItem('Serpent Steel Sword 1',1);
			thePlayer.inv.AddAnItem('Serpent Steel Sword 2',1);
			thePlayer.inv.AddAnItem('Serpent Steel Sword 3',1);
		}
		else if(swordType2 == "basic")
		{
			thePlayer.inv.AddAnItem('Guard Lvl1 steel sword 1',1);
			thePlayer.inv.AddAnItem('Guard Lvl1 steel sword 2',1);
			thePlayer.inv.AddAnItem('Guard Lvl2 steel sword 1',1);
			thePlayer.inv.AddAnItem('Guard Lvl2 steel sword 2',1);
			thePlayer.inv.AddAnItem('Knights steel sword 1',1);
			thePlayer.inv.AddAnItem('Knights steel sword 2',1);
			thePlayer.inv.AddAnItem('Squire steel sword 1',1);
			thePlayer.inv.AddAnItem('Squire steel sword 2',1);
			thePlayer.inv.AddAnItem('Unique steel sword',1);
			thePlayer.inv.AddAnItem('Unique silver sword',1);
			thePlayer.inv.AddAnItem('Gwent steel sword 1',1);
			thePlayer.inv.AddAnItem('sq701 Geralt of Rivia sword',1);
			thePlayer.inv.AddAnItem('sq701 Ravix of Fourhorn sword',1);
			thePlayer.inv.AddAnItem('mq7001 Toussaint steel sword',1);
			thePlayer.inv.AddAnItem('mq7007 Elven Sword',1);
			thePlayer.inv.AddAnItem('mq7011 Cianfanelli steel sword',1);
		}
		else if(swordType2 == "all")
		{
			thePlayer.inv.AddAnItem('Lynx School steel sword 4',1);
			thePlayer.inv.AddAnItem('Gryphon School steel sword 4',1);
			thePlayer.inv.AddAnItem('Bear School steel sword 4',1);
			thePlayer.inv.AddAnItem('Wolf School steel sword 4',1);
			thePlayer.inv.AddAnItem('Red Wolf School steel sword 1',1);
			thePlayer.inv.AddAnItem('Red Wolf School steel sword 2',1);
			thePlayer.inv.AddAnItem('Serpent Steel Sword 1',1);
			thePlayer.inv.AddAnItem('Serpent Steel Sword 2',1);
			thePlayer.inv.AddAnItem('Serpent Steel Sword 3',1);
			thePlayer.inv.AddAnItem('Guard lvl1 steel sword 3',1);
			thePlayer.inv.AddAnItem('Guard lvl2 steel sword 3',1);
			thePlayer.inv.AddAnItem('Knights steel sword 3',1);
			thePlayer.inv.AddAnItem('Hanza steel sword 3',1);
			thePlayer.inv.AddAnItem('Toussaint steel sword 3',1);
			thePlayer.inv.AddAnItem('Guard Lvl1 steel sword 1',1);
			thePlayer.inv.AddAnItem('Guard Lvl1 steel sword 2',1);
			thePlayer.inv.AddAnItem('Guard Lvl2 steel sword 1',1);
			thePlayer.inv.AddAnItem('Guard Lvl2 steel sword 2',1);
			thePlayer.inv.AddAnItem('Knights steel sword 1',1);
			thePlayer.inv.AddAnItem('Knights steel sword 2',1);
			thePlayer.inv.AddAnItem('Squire steel sword 1',1);
			thePlayer.inv.AddAnItem('Squire steel sword 2',1);
			thePlayer.inv.AddAnItem('Unique steel sword',1);
			thePlayer.inv.AddAnItem('Unique silver sword',1);
			thePlayer.inv.AddAnItem('Gwent steel sword 1',1);
			thePlayer.inv.AddAnItem('sq701 Geralt of Rivia sword',1);
			thePlayer.inv.AddAnItem('sq701 Ravix of Fourhorn sword',1);
			thePlayer.inv.AddAnItem('mq7001 Toussaint steel sword',1);
			thePlayer.inv.AddAnItem('mq7007 Elven Sword',1);
			thePlayer.inv.AddAnItem('mq7011 Cianfanelli steel sword',1);
		}
		else
		{
			Log("You didn't provide proper sword type. Please use set, craft, basic or all.");
		}
	}
	else if(swordType1 == "silver")
	{
		if(swordType2 == "set")
		{
			thePlayer.inv.AddAnItem('Lynx School silver sword 4',1);
			thePlayer.inv.AddAnItem('Gryphon School silver sword 4',1);
			thePlayer.inv.AddAnItem('Bear School silver sword 4',1);
			thePlayer.inv.AddAnItem('Wolf School silver sword 4',1);
			thePlayer.inv.AddAnItem('Red Wolf School silver sword 1',1);
			thePlayer.inv.AddAnItem('Red Wolf School silver sword 2',1);
		}
		else if(swordType2 == "craft")
		{
			thePlayer.inv.AddAnItem('Serpent Silver Sword 1',1);
			thePlayer.inv.AddAnItem('Serpent Silver Sword 2',1);
			thePlayer.inv.AddAnItem('Serpent Silver Sword 3',1);
		}
		else if(swordType2 == "basic")
		{
			Log("There are no lootable silver swords in EP2! Use set, craft or all.");
		}
		else if(swordType2 == "all")
		{
			thePlayer.inv.AddAnItem('Lynx School silver sword 4',1);
			thePlayer.inv.AddAnItem('Gryphon School silver sword 4',1);
			thePlayer.inv.AddAnItem('Bear School silver sword 4',1);
			thePlayer.inv.AddAnItem('Wolf School silver sword 4',1);
			thePlayer.inv.AddAnItem('Red Wolf School silver sword 1',1);
			thePlayer.inv.AddAnItem('Red Wolf School silver sword 2',1);
			thePlayer.inv.AddAnItem('Serpent Silver Sword 1',1);
			thePlayer.inv.AddAnItem('Serpent Silver Sword 2',1);
			thePlayer.inv.AddAnItem('Serpent Silver Sword 3',1);
		}
		else
		{
			Log("You didn't provide proper sword type. Please use set, craft or all.");
		}
	}
	else if(swordType1 == "all")
	{
		if(swordType2 == "set")
		{
			thePlayer.inv.AddAnItem('Lynx School silver sword 4',1);
			thePlayer.inv.AddAnItem('Gryphon School silver sword 4',1);
			thePlayer.inv.AddAnItem('Bear School silver sword 4',1);
			thePlayer.inv.AddAnItem('Wolf School silver sword 4',1);
			thePlayer.inv.AddAnItem('Red Wolf School silver sword 1',1);
			thePlayer.inv.AddAnItem('Red Wolf School silver sword 2',1);
			thePlayer.inv.AddAnItem('Serpent Silver Sword 1',1);
			thePlayer.inv.AddAnItem('Serpent Silver Sword 2',1);
			thePlayer.inv.AddAnItem('Serpent Silver Sword 3',1);
			thePlayer.inv.AddAnItem('Lynx School steel sword 4',1);
			thePlayer.inv.AddAnItem('Gryphon School steel sword 4',1);
			thePlayer.inv.AddAnItem('Bear School steel sword 4',1);
			thePlayer.inv.AddAnItem('Wolf School steel sword 4',1);
			thePlayer.inv.AddAnItem('Red Wolf School steel sword 1',1);
			thePlayer.inv.AddAnItem('Red Wolf School steel sword 2',1);
			thePlayer.inv.AddAnItem('Serpent Steel Sword 1',1);
			thePlayer.inv.AddAnItem('Serpent Steel Sword 2',1);
			thePlayer.inv.AddAnItem('Serpent Steel Sword 3',1);
		}
		else if(swordType2 == "craft")
		{
			thePlayer.inv.AddAnItem('Guard lvl1 steel sword 3',1);
			thePlayer.inv.AddAnItem('Guard lvl2 steel sword 3',1);
			thePlayer.inv.AddAnItem('Knights steel sword 3',1);
			thePlayer.inv.AddAnItem('Hanza steel sword 3',1);
			thePlayer.inv.AddAnItem('Toussaint steel sword 3',1);
		}
		else if(swordType2 == "basic")
		{
			thePlayer.inv.AddAnItem('Guard Lvl1 steel sword 1',1);
			thePlayer.inv.AddAnItem('Guard Lvl1 steel sword 2',1);
			thePlayer.inv.AddAnItem('Guard Lvl2 steel sword 1',1);
			thePlayer.inv.AddAnItem('Guard Lvl2 steel sword 2',1);
			thePlayer.inv.AddAnItem('Knights steel sword 1',1);
			thePlayer.inv.AddAnItem('Knights steel sword 2',1);
			thePlayer.inv.AddAnItem('Squire steel sword 1',1);
			thePlayer.inv.AddAnItem('Squire steel sword 2',1);
			thePlayer.inv.AddAnItem('Unique steel sword',1);
			thePlayer.inv.AddAnItem('Unique silver sword',1);
			thePlayer.inv.AddAnItem('Gwent steel sword 1',1);
			thePlayer.inv.AddAnItem('sq701 Geralt of Rivia sword',1);
			thePlayer.inv.AddAnItem('sq701 Ravix of Fourhorn sword',1);
			thePlayer.inv.AddAnItem('mq7001 Toussaint steel sword',1);
			thePlayer.inv.AddAnItem('mq7007 Elven Sword',1);
			thePlayer.inv.AddAnItem('mq7011 Cianfanelli steel sword',1);
		}
		else if(swordType2 == "all")
		{
			thePlayer.inv.AddAnItem('Lynx School silver sword 4',1);
			thePlayer.inv.AddAnItem('Gryphon School silver sword 4',1);
			thePlayer.inv.AddAnItem('Bear School silver sword 4',1);
			thePlayer.inv.AddAnItem('Wolf School silver sword 4',1);
			thePlayer.inv.AddAnItem('Red Wolf School silver sword 1',1);
			thePlayer.inv.AddAnItem('Red Wolf School silver sword 2',1);
			thePlayer.inv.AddAnItem('Serpent Silver Sword 1',1);
			thePlayer.inv.AddAnItem('Serpent Silver Sword 2',1);
			thePlayer.inv.AddAnItem('Serpent Silver Sword 3',1);
			thePlayer.inv.AddAnItem('Lynx School steel sword 4',1);
			thePlayer.inv.AddAnItem('Gryphon School steel sword 4',1);
			thePlayer.inv.AddAnItem('Bear School steel sword 4',1);
			thePlayer.inv.AddAnItem('Wolf School steel sword 4',1);
			thePlayer.inv.AddAnItem('Red Wolf School steel sword 1',1);
			thePlayer.inv.AddAnItem('Red Wolf School steel sword 2',1);
			thePlayer.inv.AddAnItem('Serpent Steel Sword 1',1);
			thePlayer.inv.AddAnItem('Serpent Steel Sword 2',1);
			thePlayer.inv.AddAnItem('Serpent Steel Sword 3',1);
			thePlayer.inv.AddAnItem('Guard lvl1 steel sword 3',1);
			thePlayer.inv.AddAnItem('Guard lvl2 steel sword 3',1);
			thePlayer.inv.AddAnItem('Knights steel sword 3',1);
			thePlayer.inv.AddAnItem('Hanza steel sword 3',1);
			thePlayer.inv.AddAnItem('Toussaint steel sword 3',1);
			thePlayer.inv.AddAnItem('Guard Lvl1 steel sword 1',1);
			thePlayer.inv.AddAnItem('Guard Lvl1 steel sword 2',1);
			thePlayer.inv.AddAnItem('Guard Lvl2 steel sword 1',1);
			thePlayer.inv.AddAnItem('Guard Lvl2 steel sword 2',1);
			thePlayer.inv.AddAnItem('Knights steel sword 1',1);
			thePlayer.inv.AddAnItem('Knights steel sword 2',1);
			thePlayer.inv.AddAnItem('Squire steel sword 1',1);
			thePlayer.inv.AddAnItem('Squire steel sword 2',1);
			thePlayer.inv.AddAnItem('Unique steel sword',1);
			thePlayer.inv.AddAnItem('Unique silver sword',1);
			thePlayer.inv.AddAnItem('Gwent steel sword 1',1);
			thePlayer.inv.AddAnItem('sq701 Geralt of Rivia sword',1);
			thePlayer.inv.AddAnItem('sq701 Ravix of Fourhorn sword',1);
			thePlayer.inv.AddAnItem('mq7001 Toussaint steel sword',1);
			thePlayer.inv.AddAnItem('mq7007 Elven Sword',1);
			thePlayer.inv.AddAnItem('mq7011 Cianfanelli steel sword',1);
		}
		else
		{
			Log("You didn't provide proper sword type. Please use set, craft, basic or all.");
		}
	}
	else if (swordType1 == "other")
	{
		thePlayer.inv.AddAnItem('Laundry stick',1);
		thePlayer.inv.AddAnItem('Laundry pole',1);
	}
	else
	{
		Log("You didn't provide proper sword type. Please use steel, silver, other or all.");
	}
}

exec function addQuestItemsEP2(questNumber : string)
{
	if(questNumber == "Q701" || "q701")
	{
		thePlayer.inv.AddAnItem('q701_duchess_summons',1);
		thePlayer.inv.AddAnItem('q701_beast_picture_01',1);
		thePlayer.inv.AddAnItem('q701_beast_picture_02',1);
		thePlayer.inv.AddAnItem('q701_beast_picture_03',1);
		thePlayer.inv.AddAnItem('q701_corvo_bianco_deed',1);
		thePlayer.inv.AddAnItem('q701_victim_handkarchief',1);
		thePlayer.inv.AddAnItem('q701_coin_pouch',1);
		thePlayer.inv.AddAnItem('q701_swan_item',1);
		thePlayer.inv.AddAnItem('q701_unicorn_item',1);
		thePlayer.inv.AddAnItem('q701_cookie_lure',1);
		thePlayer.inv.AddAnItem('q701_apple_lure',1);
		thePlayer.inv.AddAnItem('q701_carrot_basket',1);
		thePlayer.inv.AddAnItem('q701_grain_cup',1);
		thePlayer.inv.AddAnItem('q701_gardens_lost_ring',1);
		thePlayer.inv.AddAnItem('q701_crayfish_soup',1);
		thePlayer.inv.AddAnItem('q701_pate',1);
	}
	else if (questNumber == "Q702" || "q702")
	{
		thePlayer.inv.AddAnItem('q702_wight_gland',1);
		thePlayer.inv.AddAnItem('q702_wight_brew',1);
		thePlayer.inv.AddAnItem('q702_wicht_key',1);
		thePlayer.inv.AddAnItem('q702_wicht_fork',1);
		thePlayer.inv.AddAnItem('q702_fly',1);
		thePlayer.inv.AddAnItem('q702_leaflet',1);
		thePlayer.inv.AddAnItem('q702_graveir_lure',1);
		thePlayer.inv.AddAnItem('q702_victims_names',1);
		thePlayer.inv.AddAnItem('q702_blackmail_letter',1);
		thePlayer.inv.AddAnItem('q702_bootblack_prices',1);
		thePlayer.inv.AddAnItem('q702_knight_oath',1);
		thePlayer.inv.AddAnItem('q702_love_letter',1);
		thePlayer.inv.AddAnItem('q702_marlena_father_letter',1);
		thePlayer.inv.AddAnItem('q702_marlena_letter',1);
		thePlayer.inv.AddAnItem('q702_mill_order',1);
		thePlayer.inv.AddAnItem('q702_tesham_mutna_cell_letter',1);
		thePlayer.inv.AddAnItem('q702_toy_store_closing_order',1);
		thePlayer.inv.AddAnItem('q702_toy_store_letter',1);
		thePlayer.inv.AddAnItem('q702_regeneration_elixir',1);
		thePlayer.inv.AddAnItem('q702_spoon_key_message',1);
		thePlayer.inv.AddAnItem('q702_wight_diary',1);
		thePlayer.inv.AddAnItem('q702_comissariat',1);
		thePlayer.inv.AddAnItem('q702_regis_biography',1);
		thePlayer.inv.AddAnItem('q702_regis_sentences',1);
		thePlayer.inv.AddAnItem('q702_cage_breeding_humans',1);
		thePlayer.inv.AddAnItem('q702_monster_curses',1);
		thePlayer.inv.AddAnItem('q702_vampire_transcript',1);
		thePlayer.inv.AddAnItem('q702_spoon_key',1);
		thePlayer.inv.AddAnItem('q702_secret_urn',1);
		thePlayer.inv.AddAnItem('q702_marlena_dowry',1);
		thePlayer.inv.AddAnItem('q702_breeding_humans',1);
		thePlayer.inv.AddAnItem('Vampire Vision Potion',1);
	}
	else if (questNumber == "Q703" || "q703")
	{
		thePlayer.inv.AddAnItem('q703_bung',1);
		thePlayer.inv.AddAnItem('q703_geralt_wanted_note',1);
		thePlayer.inv.AddAnItem('q703_heart_of_toussaint',1);
		thePlayer.inv.AddAnItem('q703_mandragora_mask_male',1);
		thePlayer.inv.AddAnItem('q703_mandragora_mask_female',1);
		thePlayer.inv.AddAnItem('q703_paint_bomb_red',1);
		thePlayer.inv.AddAnItem('q703_unique_hunting_knife',1);
		thePlayer.inv.AddAnItem('q703_wooden_hammer',1);
		thePlayer.inv.AddAnItem('Geralt mandragora mask',1);
	}
	else if (questNumber == "Q704" || "q704")
	{
		thePlayer.inv.AddAnItem('q704_orianas_vampire_key',1);
		thePlayer.inv.AddAnItem('q704_caretakers_letter',1);
		thePlayer.inv.AddAnItem('q704_mages_notebook',1);
		thePlayer.inv.AddAnItem('q704_mages_notes_01',1);
		thePlayer.inv.AddAnItem('q704_mages_notes_02',1);
		thePlayer.inv.AddAnItem('q704_vampire_offering',1);
		thePlayer.inv.AddAnItem('q704_ft_bean_01',1);
		thePlayer.inv.AddAnItem('q704_ft_bean_02',1);
		thePlayer.inv.AddAnItem('q704_ft_bean_03',1);
		thePlayer.inv.AddAnItem('q704_ft_riding_hoods_hood',1);
		thePlayer.inv.AddAnItem('q704_ft_pipe',1);
		thePlayer.inv.AddAnItem('q704_ft_golden_egg',1);
		thePlayer.inv.AddAnItem('q704_ft_bottle_caps',1);
		thePlayer.inv.AddAnItem('q704_ft_corkscrew',1);
		thePlayer.inv.AddAnItem('q704_ft_fake_teeth',1);
		thePlayer.inv.AddAnItem('q704_ft_syanna_journal',1);
		thePlayer.inv.AddAnItem('q704_vampire_lure_bolt',1);
		Log("You can also specify which part of Q704 intrests you - Q704A for vampire invasion or Q704B for Fairy Tale");
	}
	else if (questNumber == "Q704A" || "q704a")
	{
		thePlayer.inv.AddAnItem('q704_orianas_vampire_key',1);
		thePlayer.inv.AddAnItem('q704_caretakers_letter',1);
		thePlayer.inv.AddAnItem('q704_mages_notebook',1);
		thePlayer.inv.AddAnItem('q704_mages_notes_01',1);
		thePlayer.inv.AddAnItem('q704_mages_notes_02',1);
		thePlayer.inv.AddAnItem('q704_vampire_offering',1);
		thePlayer.inv.AddAnItem('q704_vampire_lure_bolt',1);
	}
	else if (questNumber == "Q704B" || "q704b")
	{
		thePlayer.inv.AddAnItem('q704_ft_bean_01',1);
		thePlayer.inv.AddAnItem('q704_ft_bean_02',1);
		thePlayer.inv.AddAnItem('q704_ft_bean_03',1);
		thePlayer.inv.AddAnItem('q704_ft_riding_hoods_hood',1);
		thePlayer.inv.AddAnItem('q704_ft_pipe',1);
		thePlayer.inv.AddAnItem('q704_ft_golden_egg',1);
		thePlayer.inv.AddAnItem('q704_ft_bottle_caps',1);
		thePlayer.inv.AddAnItem('q704_ft_corkscrew',1);
		thePlayer.inv.AddAnItem('q704_ft_fake_teeth',1);
		thePlayer.inv.AddAnItem('q704_ft_syanna_journal',1);
	}
	else if (questNumber == "Q705" || "q705")
	{
		thePlayer.inv.AddAnItem('q705_ah_letter',1);
		thePlayer.inv.AddAnItem('q705_dirty_clothes',1);
		thePlayer.inv.AddAnItem('q705_soap',1);
		thePlayer.inv.AddAnItem('q705_medal',1);
		thePlayer.inv.AddAnItem('q705_white_roses',1);
		thePlayer.inv.AddAnItem('q705_mandragora',1);
		thePlayer.inv.AddAnItem('q705_prison_stash_note',1);
		thePlayer.inv.AddAnItem('q705_hammer_chisel',1);
		thePlayer.inv.AddAnItem('q705_pinup_poster',1);
		thePlayer.inv.AddAnItem('q705_geralt_mask',1);
	}
	else if (questNumber == "SQ701" || "sq701")
	{
		thePlayer.inv.AddAnItem('sq701_nest',1);
		thePlayer.inv.AddAnItem('sq701_geralt_shield',1);
		thePlayer.inv.AddAnItem('sq701_ravix_shield',1);
		thePlayer.inv.AddAnItem('sq701_tutorial_shield',1);
		thePlayer.inv.AddAnItem('sq701 Geralt of Rivia sword',1);
		thePlayer.inv.AddAnItem('sq701 Ravix of Fourhorn sword',1);
		thePlayer.inv.AddAnItem('sq701_geralt_armor',1);
		thePlayer.inv.AddAnItem('sq701_ravix_armor',1);
		thePlayer.inv.AddAnItem('sq701_victory_laurels',1);
	}
	else if (questNumber == "SQ703" || "sq703")
	{
		thePlayer.inv.AddAnItem('sq703_peacock_feather',1);
		thePlayer.inv.AddAnItem('sq703_map',1);
		thePlayer.inv.AddAnItem('sq703_map_alternative',1);
		thePlayer.inv.AddAnItem('sq703_safari_picture',1);
		thePlayer.inv.AddAnItem('sq703_hunter_letter',1);
		thePlayer.inv.AddAnItem('sq703_wife_letter',1);
		thePlayer.inv.AddAnItem('sq703_accountance_book',1);
	}
	else if (questNumber == "MH701" || "mh701")
	{
		thePlayer.inv.AddAnItem('mh701_lost_locket',1);
		thePlayer.inv.AddAnItem('mh701_fresh_blood',1);
		thePlayer.inv.AddAnItem('mh701_usable_lur',1);
		thePlayer.inv.AddAnItem('mh701_work_schedule',1);
		thePlayer.inv.AddAnItem('mh701_wine_list',1);
	}
	else if (questNumber == "MQ7001" || "mq7001")
	{
		thePlayer.inv.AddAnItem('mq7001_louis_urn',1);
		thePlayer.inv.AddAnItem('mq7001_margot_urn',1);
		thePlayer.inv.AddAnItem('mq7001_gwent_poems',1);
	}
	else if (questNumber == "MQ7002" || "mq7002")
	{
		thePlayer.inv.AddAnItem('mq7002_love_letter_01',1);
		thePlayer.inv.AddAnItem('mq7002_love_letter_02',1);
	}
	else if (questNumber == "MQ7004" || "mq7004")
	{
		thePlayer.inv.AddAnItem('mq7004_knight_item',1);
		thePlayer.inv.AddAnItem('mq7004_scarf',1);
		thePlayer.inv.AddAnItem('mq7004_storybook',1);
		thePlayer.inv.AddAnItem('mq7004_note_01',1);
		thePlayer.inv.AddAnItem('mq7004_note_02',1);
		thePlayer.inv.AddAnItem('mq7004_note_03',1);
	}
	else if (questNumber == "MQ7006" || "mq7006")
	{
		thePlayer.inv.AddAnItem('mq7006_egg',1);
	}
	else if (questNumber == "MQ7007" || "mq7007")
	{
		thePlayer.inv.AddAnItem('mq7007_tribute_food',1);
		thePlayer.inv.AddAnItem('mq7007_tribute_wine',1);
		thePlayer.inv.AddAnItem('mq7007_elven_shield',1);
		thePlayer.inv.AddAnItem('mq7007 Elven Sword',1);
		thePlayer.inv.AddAnItem('mq7007_elven_mask',1);
	}
	else if (questNumber == "MQ7009" || "mq7009")
	{
		thePlayer.inv.AddAnItem('mq7009_painter_accessories',1);
		thePlayer.inv.AddAnItem('mq7009_painting_pose1',1);
		thePlayer.inv.AddAnItem('mq7009_painting_pose1_grif',1);
		thePlayer.inv.AddAnItem('mq7009_painting_pose2',1);
		thePlayer.inv.AddAnItem('mq7009_painting_pose2_grif',1);
		thePlayer.inv.AddAnItem('mq7009_painting_pose3',1);
		thePlayer.inv.AddAnItem('mq7009_painting_pose3_grif',1);
	}
	else if (questNumber == "MQ7010" || "mq7010")
	{
		thePlayer.inv.AddAnItem('mq7010_still_note',1);
	}
	else if (questNumber == "MQ7011" || "mq7011")
	{
		thePlayer.inv.AddAnItem('mq7011_document',1);
	}
	else if (questNumber == "MQ7015" || "mq7015")
	{
		thePlayer.inv.AddAnItem('mq7015_reginalds_balls',1);
		thePlayer.inv.AddAnItem('mq7015_reginalds_figurine',1);
	}
	else if (questNumber == "MQ7017" || "mq7017")
	{
		thePlayer.inv.AddAnItem('mq7017_mushroom_potion',1);
		thePlayer.inv.AddAnItem('mq7017_pinastri_note',1);
	}
	else if (questNumber == "MQ7018" || "mq7018")
	{
		thePlayer.inv.AddAnItem('mq7018_guild_contract_letter',1);
		thePlayer.inv.AddAnItem('mq7018_workers_letter_basilisk_alive',1);
		thePlayer.inv.AddAnItem('mq7018_workers_letter_basilisk_dead',1);
	}
	else if (questNumber == "MQ7020" || "mq7020")
	{
		Log("No items in that quest or you provided wrong quest number! Please verify you provided the right one, you entered " + questNumber);
	}
	else if (questNumber == "MQ7021" || "mq7021")
	{
		thePlayer.inv.AddAnItem('mq7021_treasure_map',1);
		thePlayer.inv.AddAnItem('mq7021_filter',1);
	}
	else if (questNumber == "MQ7023" || "mq7023")
	{
		thePlayer.inv.AddAnItem('mq7023_letter_yen',1);
		thePlayer.inv.AddAnItem('mq7023_letter_triss',1);
		thePlayer.inv.AddAnItem('mq7023_letter_neutral',1);
		thePlayer.inv.AddAnItem('mq7023_map',1);
		thePlayer.inv.AddAnItem('mq7023_journal_laura',1);
		thePlayer.inv.AddAnItem('mq7023_gargoyle_hand',1);
		thePlayer.inv.AddAnItem('mq7023_portal_key',1);
		thePlayer.inv.AddAnItem('mq7023_megascope_crystal_2',1);
		thePlayer.inv.AddAnItem('mq7023_megascope_crystal',1);
		thePlayer.inv.AddAnItem('mq7023_megascope_crystal_4',1);
		thePlayer.inv.AddAnItem('mq7023_centipede_albumen_mutated',1);
		thePlayer.inv.AddAnItem('mq7023_fluff_book_mutations',1);
		thePlayer.inv.AddAnItem('mq7023_fluff_book_scolopendromorphs',1);
	}
	else if (questNumber == "MQ7024" || "mq7024")
	{
		thePlayer.inv.AddAnItem('mq7024_alchemy_lab_note',1);
	}
	else if (questNumber == "CG700" || "cg700")
	{
		thePlayer.inv.AddAnItem('cg700_base_deck',1);
		thePlayer.inv.AddAnItem('cg700_gwent_statue',1);
		thePlayer.inv.AddAnItem('cg700_letter_monniers_brother',1);
		thePlayer.inv.AddAnItem('cg700_letter_merchants',1);
		thePlayer.inv.AddAnItem('cg700_letter_purist',1);
	}
	else if (questNumber == "FF701" || "ff701")
	{
		thePlayer.inv.AddAnItem('ff701_fist_fight_trophy',1);
	}
	else if (questNumber == "TH700" || "th700")
	{
		thePlayer.inv.AddAnItem('th700_prison_journal',1);
		thePlayer.inv.AddAnItem('th700_crypt_journal',1);
		thePlayer.inv.AddAnItem('th700_vault_journal',1);
		thePlayer.inv.AddAnItem('th700_lake_journal',1);
		thePlayer.inv.AddAnItem('th700_chapel_journal',1);
		thePlayer.inv.AddAnItem('th700_lake_fluff_note1',1);
		thePlayer.inv.AddAnItem('th700_lake_fluff_note2',1);
		thePlayer.inv.AddAnItem('th700_lake_fluff_note3',1);
		thePlayer.inv.AddAnItem('th700_preacher_bones',1);
	}
	else if (questNumber == "TH701" || "th701")
	{
		thePlayer.inv.AddAnItem('th701_wg_initial_note',1);
		thePlayer.inv.AddAnItem('th701_wg_swords_note',1);
		thePlayer.inv.AddAnItem('th701_wg_pants_note',1);
		thePlayer.inv.AddAnItem('th701_bear_contract',1);
		thePlayer.inv.AddAnItem('th701_bear_journal',1);
		thePlayer.inv.AddAnItem('th701_bear_notes',1);
		thePlayer.inv.AddAnItem('th701_cat_journal',1);
		thePlayer.inv.AddAnItem('th701_cat_notes',1);
		thePlayer.inv.AddAnItem('th701_cat_witcher_notes',1);
		thePlayer.inv.AddAnItem('th701_gryphon_moreau_letter',1);
		thePlayer.inv.AddAnItem('th701_gryphon_moreau_journal',1);
		thePlayer.inv.AddAnItem('th701_gryphon_jerome_letter',1);
		thePlayer.inv.AddAnItem('th701_power_core',1);
		thePlayer.inv.AddAnItem('th701_wolf_journal',1);
		thePlayer.inv.AddAnItem('th701_wolf_witcher_note',1);
		thePlayer.inv.AddAnItem('th701_elven_journal',1);
		thePlayer.inv.AddAnItem('th701_portal_crystal',1);
		thePlayer.inv.AddAnItem('th701_coward_journal',1);
	}
	else
	{
		Log("No items in that quest or you provided wrong quest number! Please verify you provided the right one, you entered " + questNumber);
	}
}

exec function addBooksEP2()
{
	thePlayer.inv.AddAnItem('q701_crayfish_soup_recipe',1);
	thePlayer.inv.AddAnItem('q701_pate_recipe',1);
	thePlayer.inv.AddAnItem('q701_godfryd_book',1);
	thePlayer.inv.AddAnItem('q701_rydygier_book',1);
	thePlayer.inv.AddAnItem('q701_1st_victim_files',1);
	thePlayer.inv.AddAnItem('q701_2nd_victim_files',1);
	thePlayer.inv.AddAnItem('q701_3rd_victim_files',1);
	thePlayer.inv.AddAnItem('q701_goliath_book',1);
	thePlayer.inv.AddAnItem('q701_gardens_invitation',1);
	thePlayer.inv.AddAnItem('q701_wine_flier_01',1);
	thePlayer.inv.AddAnItem('q701_wine_flier_02',1);
	thePlayer.inv.AddAnItem('q701_wine_flier_03',1);
	thePlayer.inv.AddAnItem('q701_corvo_bianco_book',1);
	thePlayer.inv.AddAnItem('q701_fisherman_poetry',1);
	thePlayer.inv.AddAnItem('q703_killing_vampires',1);
	thePlayer.inv.AddAnItem('q703_history_of_est_est',1);
	thePlayer.inv.AddAnItem('q703_history_of_pomino',1);
	thePlayer.inv.AddAnItem('q703_one_handed_adalard',1);
	thePlayer.inv.AddAnItem('q703_napkin_love_letter',1);
	thePlayer.inv.AddAnItem('q703_letter_of_refusal',1);
	thePlayer.inv.AddAnItem('q703_piece_of_scenario',1);
	thePlayer.inv.AddAnItem('q704_ft_little_mermaid',1);
	thePlayer.inv.AddAnItem('q704_ft_letter_from_dandelion',1);
	thePlayer.inv.AddAnItem('sq701_registration_note',1);
	thePlayer.inv.AddAnItem('sq701_vivienne_note',1);
	thePlayer.inv.AddAnItem('sq701_rainfarn_note',1);
	thePlayer.inv.AddAnItem('sq701_guillaume_note',1);
	thePlayer.inv.AddAnItem('sq701_palmerin_note',1);
	thePlayer.inv.AddAnItem('sq701_tailles_note',1);
	thePlayer.inv.AddAnItem('sq701_anseis_note',1);
	thePlayer.inv.AddAnItem('sq701_donimir_note',1);
	thePlayer.inv.AddAnItem('sq701_horm_note',1);
	thePlayer.inv.AddAnItem('sq701_horm_emhyr_dead_note',1);
	thePlayer.inv.AddAnItem('sq701_horm_emhyr_victory_note',1);
	thePlayer.inv.AddAnItem('sq701_fan_01_note',1);
	thePlayer.inv.AddAnItem('sq701_fan_02_note',1);
	thePlayer.inv.AddAnItem('sq701_fan_03_note',1);
	thePlayer.inv.AddAnItem('lore_biography_beledals_grandfather',1);
	thePlayer.inv.AddAnItem('mq7011_procedures_book',1);
	thePlayer.inv.AddAnItem('mq7011_bank_book_filler_01',1);
	thePlayer.inv.AddAnItem('mq7011_bank_flier_01',1);
	thePlayer.inv.AddAnItem('mq7011_bank_flier_02',1);
	thePlayer.inv.AddAnItem('mq7020_hairdresser_recipe',1);
	thePlayer.inv.AddAnItem('mq7020_hairdresser_leaflet',1);
	thePlayer.inv.AddAnItem('mq7020_duvall_poem',1);
	thePlayer.inv.AddAnItem('mq7020_map',1);
	thePlayer.inv.AddAnItem('lore_basilisk_hunts',1);
	thePlayer.inv.AddAnItem('lore_toussaint_civil_war',1);
	thePlayer.inv.AddAnItem('lore_toussaint_nobles',1);
	thePlayer.inv.AddAnItem('lore_toussaint_ecology',1);
	thePlayer.inv.AddAnItem('lore_gwent_history',1);
}

exec function activateAllCharactersEP2()
{
	var manager : CWitcherJournalManager;
	
	manager = theGame.GetJournalManager();
	
	activateJournalCharacterEntryWithAlias("CharactersAnnaHenrietta", manager);
	activateJournalCharacterEntryWithAlias("CharactersDamien", manager);
	activateJournalCharacterEntryWithAlias("CharactersDettlaff", manager);
	activateJournalCharacterEntryWithAlias("CharactersGuillaume", manager);
	activateJournalCharacterEntryWithAlias("CharactersMilton", manager);
	activateJournalCharacterEntryWithAlias("CharactersOriana", manager);
	activateJournalCharacterEntryWithAlias("CharactersRegis", manager);
	activateJournalCharacterEntryWithAlias("CharactersPalmerin", manager);
	activateJournalCharacterEntryWithAlias("CharactersSyanna", manager);
	activateJournalCharacterEntryWithAlias("CharactersUkryty", manager);
	activateJournalCharacterEntryWithAlias("CharactersVivienne", manager);
	activateJournalCharacterEntryWithAlias("CharactersHermit", manager);
	activateJournalCharacterEntryWithAlias("CharactersLadyOfTheLake", manager);
	activateJournalCharacterEntryWithAlias("CharactersBarnabe", manager);
	activateJournalCharacterEntryWithAlias("CharactersBootblack", manager);
	activateJournalCharacterEntryWithAlias("CharactersRoach", manager);

}

exec function addfoodEP2()
{
	thePlayer.inv.AddAnItem('Bourgogne chardonnay',1);
	thePlayer.inv.AddAnItem('Chateau mont valjean',1);
	thePlayer.inv.AddAnItem('Bourgogne pinot noir',1);
	thePlayer.inv.AddAnItem('Saint mathieu rouge',1);
	thePlayer.inv.AddAnItem('Duke nicolas chardonnay',1);
	thePlayer.inv.AddAnItem('Uncle toms exquisite blanc',1);
	thePlayer.inv.AddAnItem('Chevalier adam pinot blanc reserve',1);
	thePlayer.inv.AddAnItem('Prince john merlot',1);
	thePlayer.inv.AddAnItem('Count var ochmann shiraz',1);
	thePlayer.inv.AddAnItem('Chateau de konrad cabernet',1);
	thePlayer.inv.AddAnItem('Geralt de rivia',1);
	thePlayer.inv.AddAnItem('White Wolf',1);
	thePlayer.inv.AddAnItem('Butcher of Blaviken',1);
	thePlayer.inv.AddAnItem('Pheasant gutted',1);
	thePlayer.inv.AddAnItem('Tarte tatin',1);
	thePlayer.inv.AddAnItem('Ratatouille',1);
	thePlayer.inv.AddAnItem('Baguette camembert',1);
	thePlayer.inv.AddAnItem('Crossaint honey',1);
	thePlayer.inv.AddAnItem('Herb toasts',1);
	thePlayer.inv.AddAnItem('Brioche',1);
	thePlayer.inv.AddAnItem('Flamiche',1);
	thePlayer.inv.AddAnItem('Camembert',1);
	thePlayer.inv.AddAnItem('Chocolate souffle',1);
	thePlayer.inv.AddAnItem('Pate chicken livers',1);
	thePlayer.inv.AddAnItem('Confit de canard',1);
	thePlayer.inv.AddAnItem('Baguette fish paste',1);
	thePlayer.inv.AddAnItem('Fish tarte',1);
	thePlayer.inv.AddAnItem('Boeuf bourguignon',1);
	thePlayer.inv.AddAnItem('Rillettes porc',1);
	thePlayer.inv.AddAnItem('Onion soup',1);
	thePlayer.inv.AddAnItem('Ham roasted',1);
	thePlayer.inv.AddAnItem('Tomato',1);
	thePlayer.inv.AddAnItem('Cookies',1);
	thePlayer.inv.AddAnItem('Ginger Bread',1);
	thePlayer.inv.AddAnItem('Magic Mushrooms',1);
	thePlayer.inv.AddAnItem('Poison Apple',1);
}

exec function addingredientsEP2(optional junkAdd : string, optional addHerb: string)
{
	thePlayer.inv.AddAnItem('Draconide infused leather',1);
	thePlayer.inv.AddAnItem('Nickel mineral',1);
	thePlayer.inv.AddAnItem('Nickel ore',1);
	thePlayer.inv.AddAnItem('Copper mineral',1);
	
	thePlayer.inv.AddAnItem('Malachite mineral',1);
	thePlayer.inv.AddAnItem('Copper ore',1);
	thePlayer.inv.AddAnItem('Cupronickel ore',1);
	thePlayer.inv.AddAnItem('Copper ingot',1);
	thePlayer.inv.AddAnItem('Copper plate',1);
	thePlayer.inv.AddAnItem('Green gold mineral',1);
	thePlayer.inv.AddAnItem('Green gold ore',1);
	thePlayer.inv.AddAnItem('Green gold ingot',1);
	thePlayer.inv.AddAnItem('Green gold plate',1);
	thePlayer.inv.AddAnItem('Orichalcum mineral',1);
	thePlayer.inv.AddAnItem('Orichalcum ore',1);
	thePlayer.inv.AddAnItem('Orichalcum ingot',1);
	thePlayer.inv.AddAnItem('Orichalcum plate',1);
	thePlayer.inv.AddAnItem('Dwimeryte enriched ore',1);
	thePlayer.inv.AddAnItem('Dwimeryte enriched ingot',1);
	thePlayer.inv.AddAnItem('Dwimeryte enriched plate',1);
	thePlayer.inv.AddAnItem('Acid extract',1);
	thePlayer.inv.AddAnItem('Centipede discharge',1);
	thePlayer.inv.AddAnItem('Archespore juice',1);
	thePlayer.inv.AddAnItem('Kikimore discharge',1);
	thePlayer.inv.AddAnItem('Vampire blood',1);
	thePlayer.inv.AddAnItem('Monstrous carapace',1);
	thePlayer.inv.AddAnItem('Sharley dust',1);
	thePlayer.inv.AddAnItem('Wight ear',1);
	thePlayer.inv.AddAnItem('Barhest essence',1);
	thePlayer.inv.AddAnItem('Wight hair',1);
	thePlayer.inv.AddAnItem('Sharley heart',1);
	thePlayer.inv.AddAnItem('Monstrous pincer',1);
	thePlayer.inv.AddAnItem('Centipede mandible',1);
	thePlayer.inv.AddAnItem('Dracolizard plate',1);
	thePlayer.inv.AddAnItem('Monstrous spore',1);
	thePlayer.inv.AddAnItem('Wight stomach',1);
	thePlayer.inv.AddAnItem('Monstrous vine',1);
	thePlayer.inv.AddAnItem('Archespore tendril',1);
	thePlayer.inv.AddAnItem('Monstrous wing',1);
	if(junkAdd == "junk")
	{
		thePlayer.inv.AddAnItem('Peacock feather',1);
		thePlayer.inv.AddAnItem('Dull meteorite axe',1);
		thePlayer.inv.AddAnItem('Broken meteorite pickaxe',1);
		thePlayer.inv.AddAnItem('Hotel silver breadknife',1);
		thePlayer.inv.AddAnItem('Hotel silver goblet',1);
		thePlayer.inv.AddAnItem('Hotel silver teapot',1);
		thePlayer.inv.AddAnItem('Hotel silver fruitbowl',1);
		thePlayer.inv.AddAnItem('Hotel silver serving tray',1);
		thePlayer.inv.AddAnItem('Hotel silver wine bottle',1);
		thePlayer.inv.AddAnItem('Hotel silver cup',1);
		thePlayer.inv.AddAnItem('Copper salt pepper shaker',1);
		thePlayer.inv.AddAnItem('Copper mug',1);
		thePlayer.inv.AddAnItem('Copper platter',1);
		thePlayer.inv.AddAnItem('Copper casket',1);
		thePlayer.inv.AddAnItem('Copper candelabra',1);
		thePlayer.inv.AddAnItem('Cupronickel axe head',1);
		thePlayer.inv.AddAnItem('Cupronickel pickaxe head',1);
		thePlayer.inv.AddAnItem('Copper chain',1);
		thePlayer.inv.AddAnItem('Green gold ruby ring',1);
		thePlayer.inv.AddAnItem('Green gold sapphire ring',1);
		thePlayer.inv.AddAnItem('Green gold emerald ring',1);
		thePlayer.inv.AddAnItem('Green gold diamond ring',1);
		thePlayer.inv.AddAnItem('Green gold amber necklace',1);
		thePlayer.inv.AddAnItem('Green gold ruby necklace',1);
		thePlayer.inv.AddAnItem('Green gold sapphire necklace',1);
		thePlayer.inv.AddAnItem('Green gold emerald necklace',1);
		thePlayer.inv.AddAnItem('Green gold diamond necklace',1);
		thePlayer.inv.AddAnItem('Touissant knife',1);
		thePlayer.inv.AddAnItem('Bottle caps',1);
		thePlayer.inv.AddAnItem('Fake teeth',1);
		thePlayer.inv.AddAnItem('Corkscrew',1);
		thePlayer.inv.AddAnItem('Gingerbread man',1);
		thePlayer.inv.AddAnItem('Toys rich',1);
		thePlayer.inv.AddAnItem('Teapot teacups',1);
		thePlayer.inv.AddAnItem('Skeletal ashes',1);
		thePlayer.inv.AddAnItem('Magic mirror shard',1);
		thePlayer.inv.AddAnItem('Magic dust',1);
		thePlayer.inv.AddAnItem('Fourleaf clover',1);
		thePlayer.inv.AddAnItem('Magic gold',1);
	}
	if(addHerb == "herb")
	{
		thePlayer.inv.AddAnItem('Winter cherry',1);
		thePlayer.inv.AddAnItem('Holy basil',1);
		thePlayer.inv.AddAnItem('Blue lotus',1);
	}
}

function unlockDyeRecipes()
{
	thePlayer.inv.AddAnItem('Recipe Dye Gray',1);
	thePlayer.inv.AddAnItem('Recipe Dye Turquoise',1);
	thePlayer.inv.AddAnItem('Recipe Dye Brown',1);
	thePlayer.inv.AddAnItem('Recipe Dye Green',1);
	thePlayer.inv.AddAnItem('Recipe Dye Blue',1);
	thePlayer.inv.AddAnItem('Recipe Dye Orange',1);
	thePlayer.inv.AddAnItem('Recipe Dye Pink',1);
	thePlayer.inv.AddAnItem('Recipe Dye Yellow',1);
	thePlayer.inv.AddAnItem('Recipe Dye Black',1);
	thePlayer.inv.AddAnItem('Recipe Dye White',1);
	thePlayer.inv.AddAnItem('Recipe Dye Red',1);
	thePlayer.inv.AddAnItem('Recipe Dye Purple',1);
}

function unlockMutagenRecipes()
{
	thePlayer.inv.AddAnItem('Recipe Lesser Mutagen Red to Blue',1);
	thePlayer.inv.AddAnItem('Recipe Lesser Mutagen Red to Green',1);
	thePlayer.inv.AddAnItem('Recipe Lesser Mutagen Green to Red',1);
	thePlayer.inv.AddAnItem('Recipe Lesser Mutagen Green to Blue',1);
	thePlayer.inv.AddAnItem('Recipe Lesser Mutagen Blue to Red',1);
	thePlayer.inv.AddAnItem('Recipe Lesser Mutagen Blue to Green',1);
	thePlayer.inv.AddAnItem('Recipe Mutagen Red to Blue',1);
	thePlayer.inv.AddAnItem('Recipe Mutagen Red to Green',1);
	thePlayer.inv.AddAnItem('Recipe Mutagen Green to Red',1);
	thePlayer.inv.AddAnItem('Recipe Mutagen Green to Blue',1);
	thePlayer.inv.AddAnItem('Recipe Mutagen Blue to Red',1);
	thePlayer.inv.AddAnItem('Recipe Mutagen Blue to Green',1);
	thePlayer.inv.AddAnItem('Recipe Greater Mutagen Red to Blue',1);
	thePlayer.inv.AddAnItem('Recipe Greater Mutagen Red to Green',1);
	thePlayer.inv.AddAnItem('Recipe Greater Mutagen Green to Red',1);
	thePlayer.inv.AddAnItem('Recipe Greater Mutagen Green to Blue',1);
	thePlayer.inv.AddAnItem('Recipe Greater Mutagen Blue to Red',1);
	thePlayer.inv.AddAnItem('Recipe Greater Mutagen Blue to Green',1);
}

function unlockQuestRecipes()
{
	thePlayer.inv.AddAnItem('Recipe for Sharley Lure',1);
	thePlayer.inv.AddAnItem('Recipe for Mutation Serum',1);
	thePlayer.inv.AddAnItem('q704_antidote_recipe',1);
	thePlayer.inv.AddAnItem('q704_vampire_lure_bolt_recipe',1);
}
function unlockSwordRecipes()
{
	thePlayer.inv.AddAnItem('Lynx School steel sword Upgrade schematic 4',1);
	thePlayer.inv.AddAnItem('Gryphon School steel sword Upgrade schematic 4',1);
	thePlayer.inv.AddAnItem('Bear School steel sword Upgrade schematic 4',1);
	thePlayer.inv.AddAnItem('Wolf School steel sword Upgrade schematic 4',1);
	thePlayer.inv.AddAnItem('Red Wolf School steel sword schematic 1',1);
	thePlayer.inv.AddAnItem('Red Wolf School steel sword Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Serpent Steel Sword schematic 1',1);
	thePlayer.inv.AddAnItem('Serpent Steel Sword schematic 2',1);
	thePlayer.inv.AddAnItem('Serpent Steel Sword schematic 3',1);
	thePlayer.inv.AddAnItem('Guard Lvl1 steel sword 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl1 A steel sword 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl2 steel sword 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl2 A steel sword 3 schematic',1);
	thePlayer.inv.AddAnItem('Knights Geralt steel sword 3 schematic',1);
	thePlayer.inv.AddAnItem('Squire steel sword 3 schematic',1);
	thePlayer.inv.AddAnItem('Hanza steel sword 3 schematic',1);
	thePlayer.inv.AddAnItem('Toussaint steel sword 3 schematic',1);
	thePlayer.inv.AddAnItem('Lynx School silver sword Upgrade schematic 4',1);
	thePlayer.inv.AddAnItem('Gryphon School silver sword Upgrade schematic 4',1);
	thePlayer.inv.AddAnItem('Bear School silver sword Upgrade schematic 4',1);
	thePlayer.inv.AddAnItem('Wolf School silver sword Upgrade schematic 4',1);
	thePlayer.inv.AddAnItem('Red Wolf School silver sword schematic 1',1);
	thePlayer.inv.AddAnItem('Red Wolf School silver sword Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Serpent Silver Sword schematic 1',1);
	thePlayer.inv.AddAnItem('Serpent Silver Sword schematic 2',1);
	thePlayer.inv.AddAnItem('Serpent Silver Sword schematic 3',1);
}
function unlockArmorRecipes()
{
	thePlayer.inv.AddAnItem('Witcher Lynx Jacket Upgrade schematic 4',1);
	thePlayer.inv.AddAnItem('Witcher Lynx Gloves Upgrade schematic 5',1);
	thePlayer.inv.AddAnItem('Witcher Lynx Boots Upgrade schematic 5',1);
	thePlayer.inv.AddAnItem('Witcher Lynx Pants Upgrade schematic 5',1);
	thePlayer.inv.AddAnItem('Witcher Gryphon Jacket Upgrade schematic 4',1);
	thePlayer.inv.AddAnItem('Witcher Gryphon Gloves Upgrade schematic 5',1);
	thePlayer.inv.AddAnItem('Witcher Gryphon Boots Upgrade schematic 5',1);
	thePlayer.inv.AddAnItem('Witcher Gryphon Pants Upgrade schematic 5',1);
	thePlayer.inv.AddAnItem('Witcher Bear Jacket Upgrade schematic 4',1);
	thePlayer.inv.AddAnItem('Witcher Bear Gloves Upgrade schematic 5',1);
	thePlayer.inv.AddAnItem('Witcher Bear Boots Upgrade schematic 5',1);
	thePlayer.inv.AddAnItem('Witcher Bear Pants Upgrade schematic 5',1);
	thePlayer.inv.AddAnItem('Witcher Wolf Jacket Upgrade schematic 4',1);
	thePlayer.inv.AddAnItem('Witcher Wolf Gloves Upgrade schematic 5',1);
	thePlayer.inv.AddAnItem('Witcher Wolf Boots Upgrade schematic 5',1);
	thePlayer.inv.AddAnItem('Witcher Wolf Pants Upgrade schematic 5',1);
	thePlayer.inv.AddAnItem('Witcher Red Wolf Jacket schematic 1',1);
	thePlayer.inv.AddAnItem('Witcher Red Wolf Jacket Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Witcher Red Wolf Gloves schematic 1',1);
	thePlayer.inv.AddAnItem('Witcher Red Wolf Gloves Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Witcher Red Wolf Boots schematic 1',1);
	thePlayer.inv.AddAnItem('Witcher Red Wolf Boots Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Witcher Red Wolf Pants schematic 1',1);
	thePlayer.inv.AddAnItem('Witcher Red Wolf Pants Upgrade schematic 2',1);
	thePlayer.inv.AddAnItem('Guard Lvl1 Armor 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl1 Gloves 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl1 Boots 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl1 Pants 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl1 A Armor 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl1 A Gloves 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl1 A Boots 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl1 A Pants 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl2 Armor 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl2 Gloves 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl2 Boots 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl2 Pants 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl2 A Armor 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl2 A Gloves 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl2 A Boots 3 schematic',1);
	thePlayer.inv.AddAnItem('Guard Lvl2 A Pants 3 schematic',1);
	thePlayer.inv.AddAnItem('Knight Geralt Armor 3 schematic',1);
	thePlayer.inv.AddAnItem('Knight Geralt Gloves 3 schematic',1);
	thePlayer.inv.AddAnItem('Knight Geralt Boots 3 schematic',1);
	thePlayer.inv.AddAnItem('Knight Geralt Pants 3 schematic',1);
	thePlayer.inv.AddAnItem('Knight Geralt A Armor 3 schematic',1);
	thePlayer.inv.AddAnItem('Knight Geralt A Gloves 3 schematic',1);
	thePlayer.inv.AddAnItem('Knight Geralt A Boots 3 schematic',1);
	thePlayer.inv.AddAnItem('Knight Geralt A Pants 3 schematic',1);
}

function unlockMaterialRecipes()
{
	thePlayer.inv.AddAnItem('Draconide infused leather schematic',1);
	thePlayer.inv.AddAnItem('Nickel ore schematic',1);
	thePlayer.inv.AddAnItem('Cupronickel ore schematic',1);
	thePlayer.inv.AddAnItem('Copper ore schematic',1);
	thePlayer.inv.AddAnItem('Copper ingot schematic',1);
	thePlayer.inv.AddAnItem('Copper plate schematic',1);
	thePlayer.inv.AddAnItem('Green gold ore schematic',1);
	thePlayer.inv.AddAnItem('Green gold ore schematic1 ',1);
	thePlayer.inv.AddAnItem('Green gold ingot schematic',1);
	thePlayer.inv.AddAnItem('Green gold plate schematic',1);
	thePlayer.inv.AddAnItem('Orichalcum ore schematic',1);
	thePlayer.inv.AddAnItem('Orichalcum ore schematic 1',1);
	thePlayer.inv.AddAnItem('Orichalcum ingot schematic',1);
	thePlayer.inv.AddAnItem('Orichalcum plate schematic',1);
	thePlayer.inv.AddAnItem('Dwimeryte enriched ore schematic',1);
	thePlayer.inv.AddAnItem('Dwimeryte enriched ingot schematic',1);
	thePlayer.inv.AddAnItem('Dwimeryte enriched plate schematic',1);
}

exec function unlockrecipesEP2(type : string)
{
	if(type == "all")
	{
		unlockDyeRecipes();
		unlockMutagenRecipes();
		unlockQuestRecipes();
		unlockSwordRecipes();
		unlockArmorRecipes();
		unlockMaterialRecipes();
	}
	else if (type == "dye")
	{
		unlockDyeRecipes();
	}
	else if (type == "mutagen")
	{
		unlockMutagenRecipes();
	}
	else if (type == "quest")
	{
		unlockQuestRecipes();
	}
	else if (type == "sword")
	{
		unlockSwordRecipes();
	}
	else if (type == "armor")
	{
		unlockArmorRecipes();
	}
	else if (type == "material")
	{
		unlockMaterialRecipes();
	}
}

exec function breakSync()
{
	var syncInstance : CAnimationManualSlotSyncInstance;
	var syncParent : CEntity;
	
	syncInstance = theGame.GetSyncAnimManager().GetSyncInstance( 0 );
	if( syncInstance )
	{
		syncParent = theGame.GetSyncAnimManager().masterEntity;
		if( syncParent )
		{
			syncInstance.BreakIfPossible( syncParent );
		}
	}
}

exec function StopEffect( fx : name, optional entityTag : name )
{
	var i : int;
	var ents : array< CEntity >;
	
	if( entityTag != '' )
	{
		theGame.GetEntitiesByTag( entityTag, ents );
	}
	else
	{
		ents.PushBack( thePlayer );
	}
	
	for( i=0; i<ents.Size(); i+=1 )
	{
		ents[i].StopEffect( fx );
	}
}

exec function Refill()
{
	thePlayer.inv.SingletonItemsRefillAmmoNoAlco(true);
}

exec function debugfirstlaunch()
{
	theGame.DebugFirstLaunch();
}

exec function debugforcecrash(crashType : string)
{
	if(!theGame.DebugForceCrash(crashType))
		Log("temp.ws:debugforcecrash: Crash type not existing");
	else
		Log("temp.ws:debugforcecrash: Should've crashed by now, but certain types of crashed might be disabled or recovered from");
}



exec function writePGO(optional counter : int)
{
	theGame.WritePGO(counter);
}
