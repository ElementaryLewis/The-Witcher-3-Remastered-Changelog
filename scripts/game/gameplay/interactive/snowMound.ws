/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SnowMound extends CInteractiveEntity
{
	editable var TagRemovedAfterMelt : name;
	
	hint TagRemovedAfterMelt = "This is the tag Ciri will look for when searching for unmelted snow mounds";
	
	private var isMelted : bool;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		
		if ( !HasTag(theGame.params.TAG_SOFT_LOCK) )
			AddTag(theGame.params.TAG_SOFT_LOCK);
		if ( !HasTag('softLock_Igni') )
			AddTag('softLock_Igni');
	}
	
	event OnIgniHit( sign : W3IgniProjectile )
	{
		PlayEffect('igni');
		MeltSnow();
		super.OnIgniHit( sign );
	}
	
	protected function MeltSnow()
	{
		if( isMelted)
		{
			return;
		}
		
		this.ApplyAppearance("02_puddle");
		
		RemoveTag(TagRemovedAfterMelt);
		RemoveTag( theGame.params.TAG_SOFT_LOCK );
		RemoveTag( 'softLock_Igni' );
	}
	
}