/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Mutation7BaseEffect extends CBaseGameplayEffect
{
	protected var actors : array< CActor >;
	protected var sonarEntity : CEntity;
	protected var meshComponent : CMeshComponent;
	protected var streamingHax : bool;
	protected var scale : float;
	protected var isSonarIncreasing : bool;
	protected var enemyFlashFX : name;
	protected var actorsCount : int;
	protected var apBonus : float;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		var i : int;
		
		super.OnEffectAdded();
		
		actors = GetActorsInRange( target, 30, 50, '', true );
		
		for(i = actors.Size() - 1; i >= 0; i -= 1)
		{
			if( GetAttitudeBetween( target, actors[i] ) != AIA_Hostile )
			{
				actors.Erase( i );
			}
		}
		
		actorsCount = actors.Size();
		sonarEntity = target.CreateFXEntityAtPelvis( 'mutation7_sonar', false );		
	}
	
	event OnEffectRemoved()
	{
		if( sonarEntity )
		{
			sonarEntity.Destroy();
		}
		
		super.OnEffectRemoved();
	}
	
	event OnUpdate(deltaTime : float)
	{
		var dist : float;
		var sonarPos : Vector;
		var i : int;
		var fxEntity : CEntity;
		
		super.OnUpdate( deltaTime );
		
		if( sonarEntity && !streamingHax )
		{
			sonarEntity.PlayEffect( 'sonar_mesh' );		
			streamingHax = true;
		}
		
		if( timeActive <= 1.f )
		{
			if( !meshComponent )
			{
				meshComponent = ( CMeshComponent ) sonarEntity.GetComponentByClassName( 'CMeshComponent' );
			}
			
			meshComponent.SetScale( Vector( scale, scale, scale ) );
			
			
			sonarPos = sonarEntity.GetWorldPosition();
			for( i=actors.Size()-1; i>=0; i-=1 )
			{
				dist = VecDistance2D( sonarPos, actors[i].GetWorldPosition() );
				if( ( dist >= scale && !isSonarIncreasing ) || ( isSonarIncreasing && dist <= scale ) )
				{
					fxEntity = actors[i].CreateFXEntityAtPelvis( 'mutation7_flash', false );
					fxEntity.PlayEffect( enemyFlashFX );
					fxEntity.DestroyAfter( 10.f );
					actors.EraseFast( i );
				}
			}
		}
		else
		{
			if( sonarEntity )
			{
				sonarEntity.Destroy();
			}
		}
	}
	
	public function GetStacks() : int
	{
		return (int)( ( actorsCount - 1 ) * 100 * apBonus );
	}
}