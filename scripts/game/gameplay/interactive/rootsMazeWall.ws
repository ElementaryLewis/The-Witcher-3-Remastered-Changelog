/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3RootsMazeWall extends W3RootsEntrance
{
	private editable var isDangerous 			: bool;
	private editable var damage					: float;
	private editable var shouldStartOpen		: bool;
	private editable var collisionOpenDelay		: float;
	private editable var collisionCloseDelay	: float;
	private var instantTransition				: bool;
	private var meshComp 						: CMeshComponent;
	
	default damage							= 50.0f;
	default isDangerous						= false;
	default shouldStartOpen					= false;
	default collisionOpenDelay				= 3.0f;
	default collisionCloseDelay				= 1.0f;
	default instantTransition				= false;
	
	hint isDangerous						= "Should the roots deal any damage.";
	hint damage								= "Damage dealt by the roots.";
	hint shouldStartOpen					= "Should wall be opened from the start.";
	hint collisionOpenDelay					= "Delay for collision appear";
	hint collisionCloseDelay				= "Delay for collision disappear";
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if( spawnData.restored )
		{
			if( isOpened )
			{
				OpenFromStart();
			}
			else
			{
				CloseFromStart();
			}
		}
		else
		{
			if ( shouldStartOpen )
			{
				instantTransition = true;
				Open();
			}
			else
			{
				Close();
			}
		}
	}
	
	public function Open()
	{
		meshComp = (CMeshComponent)GetComponentByClassName('CMeshComponent');
		isOpened = true;
		
		if ( instantTransition )
		{
			if ( meshComp )
			{
				meshComp.SetVisible(false);	
				instantTransition = false;
			}
		}
		PlayEffect('open');
		AddTimer('DisableCollision', collisionOpenDelay);
	}
	
	public function Close()
	{
		meshComp = (CMeshComponent)GetComponentByClassName('CMeshComponent');
		meshComp.SetVisible(true);
		
		isOpened = false;
		PlayEffect('close');
		AddTimer('EnableCollision', collisionCloseDelay);
	}
	
	public function CloseFromStart()
	{
		var appComp : CAppearanceComponent;		
		
		isOpened = false;
        appComp = (CAppearanceComponent)GetComponentByClassName('CAppearanceComponent');

        if (appComp)
            appComp.ApplyAppearance('closed_from_start');
	}
	
	public function OpenFromStart()
	{
		var appComp : CAppearanceComponent;

        appComp = (CAppearanceComponent)GetComponentByClassName('CAppearanceComponent');

        if (appComp)
            appComp.ApplyAppearance('open');
            
		meshComp = (CMeshComponent)GetComponentByClassName('CMeshComponent');
		isOpened = true;
		
		if ( meshComp )
		{
			meshComp.SetVisible(false);	
		}
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var victim	: CActor;
		var areaName : string;
		
		victim = (CActor) activator.GetEntity();
		areaName = area.GetName();
		
		if( victim && !isOpened && areaName == "DamageArea" && isDangerous )
		{
			DealDamage(victim);
		}	
	}
	
	private function DealDamage( victim : CActor )
	{
		var action : W3DamageAction;
		
		action = new W3DamageAction in this;
		action.Initialize(this ,victim, this,this.GetName(),EHRT_Heavy,CPS_AttackPower,false,true,false,false);
		
		
		action.AddDamage( theGame.params.DAMAGE_NAME_PIERCING, damage ); 

		action.SetCanPlayHitParticle(false);
		theGame.damageMgr.ProcessAction( action );
		delete action;	
	}
	
	timer function DisableCollision( delta : float , id : int)
    {
        var appComp : CAppearanceComponent;

        appComp = (CAppearanceComponent)GetComponentByClassName('CAppearanceComponent');

        if (appComp)
            appComp.ApplyAppearance('open');
    }

    timer function EnableCollision( delta : float , id : int)
    {
        var appComp : CAppearanceComponent;

        appComp = (CAppearanceComponent)GetComponentByClassName('CAppearanceComponent');

        if (appComp)
            appComp.ApplyAppearance('closed');
    }
}
exec function TestRootsMaze ( tag : name, shouldOpen : bool )
{
	var entity : CEntity;
	var roots : W3RootsEntrance;
	
	entity = theGame.GetEntityByTag( tag );

	if( entity )
	{
		roots = (W3RootsEntrance)entity;
		
		if( roots )
		{
			if( shouldOpen )
			{
				roots.Open();
			}
			else
			{
				roots.Close();
			}
		}
	}
}