/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3BuffImmunityEntity extends CGameplayEntity
{
	editable var immunities		: array<EEffectType>;
	editable saved var range	: float;
	editable saved var isActive	: bool;
	default range				= 1.0f;
	default isActive			= false;
	
	protected var actorsInRange : array<CActor>;
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		if ( isActive )
		{
			AddTimer( 'UpdateActors', 0.5f, true, , , true );
		}
		super.OnSpawned( spawnData );
	}
	
	function ToggleActivate( toggle : bool )
	{
		if ( toggle && !isActive )
		{
			AddTimer( 'UpdateActors', 0.5f, true, , , true );
		}
		else if ( !toggle && isActive )
		{
			RemoveTimer( 'UpdateActors' );
			RemoveImmunityFromActorsInRange();
		}
		isActive = toggle;
	}
		
	timer function UpdateActors( dt : float, id : int )
	{
		var entities 	: array< CGameplayEntity >;
		var newActors 	: array< CActor >;
		var actor		: CActor;
		var index		: int;
		var i, size		: int;
		
		
		FindGameplayEntitiesInSphere( entities, this.GetWorldPosition(), range, -1, '', FLAG_OnlyAliveActors );
		size = entities.Size();
		for ( i = 0; i < size; i+=1 )
		{
			actor = (CActor)entities[i];
			if ( actor )
			{
				
				index = actorsInRange.FindFirst( actor );
				if ( index != -1 )
				{
					
					
					actorsInRange.EraseFast( index );
				}
				else
				{
					
					ToggleBuffImmunity( actor, true );
				}
				newActors.PushBack( actor );
			}		
		}
		
		
		RemoveImmunityFromActorsInRange(); 
		
		actorsInRange = newActors;
	}
	
	private function RemoveImmunityFromActorsInRange()
	{	
		var i, size	: int;
		
		size = actorsInRange.Size();
		for ( i = 0; i < size; i+=1 )
		{
			ToggleBuffImmunity( actorsInRange[i], false );
		}
	}
		
	
	
	protected function ToggleBuffImmunity( actor : CActor, toggle : bool )
	{
		var i : int;
		
		for ( i = 0; i < immunities.Size(); i += 1 )
		{
			if( toggle )
			{
				actor.AddBuffImmunity( immunities[i], 'BuffImmunityInteractiveEntity', true );
			}
			else
			{
				actor.RemoveBuffImmunity( immunities[i], 'BuffImmunityInteractiveEntity' );
			}
		}
	}
}

class W3MagicBubbleEntity extends W3BuffImmunityEntity
{
	editable var activeFxName : name;
	
	private var damper : VectorSpringDamper;
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var scale : Vector;
		super.OnSpawned( spawnData );
				
		damper = new VectorSpringDamper in this;
		scale = Vector( range, range, range );
		damper.Init( scale, scale );
		SetScale( scale );
		
		if ( isActive )
			this.PlayEffect(activeFxName);
	}
	
	public function ToggleActivate( toggle : bool )
	{
		if ( toggle && !isActive )
			this.PlayEffect(activeFxName);
		else if ( !toggle && isActive )
			this.StopEffect(activeFxName);
	
		super.ToggleActivate( toggle );
	}
		
	public function ScaleOverTime( scale : Vector, duration : float )
	{
		damper.SetValue(scale);
		damper.SetSmoothTime(duration);
		
		AddTimer('ScaleUpdate',0,true, , , true);
	}
	
	private timer function ScaleUpdate( dt : float , id : int)
	{
		var currValue : Vector;
		
		damper.Update(dt);
		currValue = damper.GetValue();
		
		SetScale(currValue);
		
		if (currValue == damper.GetDestValue() )
			RemoveTimer('ScaleUpdate');
	}
	
	function SetScale( scale : Vector )
	{
		var meshComps		: array<CComponent>;
		var i 				: int;

		range = scale.X;

		meshComps = this.GetComponentsByClassName('CMeshComponent');
		
		for ( i=0 ; i < meshComps.Size() ; i+=1 )
		{
			if( meshComps[ i ] )
			{
				meshComps[i].SetScale(scale);
			}
		}
	}	
}
