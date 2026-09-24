/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
function ArrayFindMaxF( a : array< float > ) : int
{
	var i, s, index : int;
	var val : float;	
	
	s = a.Size();
	if( s > 0 )
	{			
		index = 0;
		val = a[0];
		for( i=1; i<s; i+=1 )
		{
			if( a[i] > val )
			{
				index = i;
				val = a[i];
			}
		};
		
		return index;
	}	
	
	return -1;			
}


function ArrayMaskedFindMaxF( a : array< float >, thresholdVal : float ) : int
{
	var i, s, index : int;
	var val : float;	
	
	s = a.Size();
	if( s > 0 )
	{			
		val = a[0];
		if ( val < thresholdVal )
		{
			index = 0;
		}
		else
		{
			index = -1;
			val = -100000000;
		}
		for( i=1; i<s; i+=1 )
		{
			if( a[i] > val && a[i] < thresholdVal )
			{
				index = i;
				val = a[i];
			}
		};
		
		return index;
	}	
	
	return -1;			
}



function ArrayFindMinF( a : array< float > ) : int
{
	var i, s, index : int;
	var val : float;	
	
	s = a.Size();
	if( s > 0 )
	{			
		index = 0;
		val = a[0];
		for( i=1; i<s; i+=1 )
		{
			if( a[i] < val )
			{
				index = i;
				val = a[i];
			}
		};
		
		return index;
	}	
	
	return -1;			
}


function ArrayFindMinIndexInt( a : array< int > ) : int
{
	var i, s, val, index : int;
	
	s = a.Size();
	if( s > 0 )
	{			
		index = 0;
		val = a[0];
		for( i=1; i<s; i+=1 )
		{
			if( a[i] < val )
			{
				index = i;
				val = a[i];
			}
		}
		
		return index;
	}	
	
	return -1;			
}


function ArrayFindMinInt( a : array< int > ) : int
{
	var i, s, val : int;
	
	s = a.Size();
	if( s > 0 )
	{			
		val = a[0];
		for( i=1; i<s; i+=1 )
		{
			if( a[i] < val )
			{
				val = a[i];
			}
		}
		
		return val;
	}	
	
	return -1;			
}


function ArrayFindMaxInt( a : array< int > ) : int
{
	var i, s, val, index : int;
	
	s = a.Size();
	if( s > 0 )
	{			
		index = 0;
		val = a[0];
		for( i=1; i<s; i+=1 )
		{
			if( a[i] > val )
			{
				index = i;
				val = a[i];
			}
		};
		
		return index;
	}	
	
	return -1;			
}

function ArraySortNames(out names : array<name>)
{
	var i, j, size : int;
	var ret : array<name>;
	var found : bool;
	
	if(names.Size() <= 0)
		return;
		
	size = names.Size();	
	ret.PushBack(names[0]);
	
	for(i=1; i<size; i+=1)
	{
		found = false;
		
		for(j=0; j<ret.Size(); j+=1)
		{
			if( StrCmp( StrLower(NameToString(names[i])), StrLower(NameToString(ret[j]))) < 0 )
			{
				ret.Insert(j, names[i]);
				found = true;
				break;
			}
		}
		
		if ( !found )
		{
			ret.PushBack(names[i]);
		}
	}
	
	names.Clear();
	names = ret;
}


function ArraySortNamesByKey(out names : array<name>, out keys : array<int>){
	if(names.Size() == 0 || keys.Size() == 0 || keys.Size() != names.Size())
		return;
	ArraySortNamesByKeyQSort(names,keys,0,names.Size());
}

function ArraySortNamesByKeyQSort(out names : array<name>, out keys : array<int>, start : int, stop : int){
	var i,tmp_i : int;
	var tmp_n : name;
	
	for(i=start+1; i<stop; i+=1){
		if(keys[start] > keys[i]){
			tmp_i = keys[start];
			keys[start] = keys[i];
			keys[i] = keys[start+1];
			keys[start+1] = tmp_i;
			
			tmp_n = names[start];
			names[start] = names[i];
			names[i] = names[start+1];
			names[start+1] = tmp_n;
			
			start+=1;
		}
	}
  
	if(start > 1)
		ArraySortNamesByKeyQSort(names,keys,0,start);
	if( (stop-(start+1)) > 1)
		ArraySortNamesByKeyQSort(names,keys,start+1,stop);
}

function ArraySortNPCsByKey(out actors : array<CNewNPC>, out keys : array<int>){
	if(actors.Size() == 0 || keys.Size() == 0 || keys.Size() != actors.Size())
		return;
	ArraySortNPCsByKeyQSort(actors,keys,0,actors.Size());
}

function ArraySortNPCsByKeyQSort(out actors : array<CNewNPC>, out keys : array<int>, start : int, stop : int){
	var i,tmp_i : int;
	var tmp_n : CNewNPC;
	
	for(i=start+1; i<stop; i+=1){
		if(keys[start] > keys[i]){
			tmp_i = keys[start];
			keys[start] = keys[i];
			keys[i] = keys[start+1];
			keys[start+1] = tmp_i;
			
			tmp_n = actors[start];
			actors[start] = actors[i];
			actors[i] = actors[start+1];
			actors[start+1] = tmp_n;
			
			start+=1;
		}
	}
  
	if(start > 1)
		ArraySortNPCsByKeyQSort(actors,keys,0,start);
	if( (stop-(start+1)) > 1)
		ArraySortNPCsByKeyQSort(actors,keys,start+1,stop);
}

import function ArraySortInts   ( out arrayToSort : array< int > );
import function ArraySortFloats ( out arrayToSort : array< float > );
import function ArraySortStrings( out arrayToSort : array< string > );


function ArrayOfNamesAppend(out first : array<name>, second : array<name>)
{
	var i, s : int;
	
	s = second.Size();
	for(i=0; i<s; i+=1)
		first.PushBack(second[i]);
}


function ArrayOfNamesAppendUnique(out first : array<name>, second : array<name>)
{
	var i, s : int;
	
	s = second.Size();
	for(i=0; i<s; i+=1)
	{
		if(!first.Contains(second[i]))
		{
			first.PushBack(second[i]);
		}
	}
}


function ArrayOfNamesPushBackUnique(out arr : array<name>, val : name)
{
	if ( !arr.Contains( val ) )
	{
		arr.PushBack( val );
	}
}


function ArrayOfActorsAppend(out first : array<CActor>, second : array<CActor>)
{
	var i, s : int;
	
	s = second.Size();
	for(i=0; i<s; i+=1)
		first.PushBack(second[i]);
}


function ArrayOfActorsAppendUnique(out first : array<CActor>, second : array<CActor>)
{
	var i, s : int;
	
	s = second.Size();
	for(i=0; i<s; i+=1)
	{
		if( !first.Contains( second[i] ) )
		{
			first.PushBack(second[i]);
		}
	}
}


function ArrayOfActorsAppendArrayOfGameplayEntities(out first : array< CActor >, second : array< CGameplayEntity >)
{
	var i, s : int;
	var actor : CActor;
	
	s = second.Size();
	for ( i = 0; i < s; i+=1 )
	{
		actor = (CActor)second[i];
		if ( actor )
		{
			first.PushBack( actor );
		}
	}
}


function ArrayOfIdsAppend(out first : array<SItemUniqueId>, second : array<SItemUniqueId>)
{
	var i, s : int;
	
	s = second.Size();
	for(i=0; i<s; i+=1)
		first.PushBack(second[i]);
}


function ArrayOfIdsAppendUnique(out first : array<SItemUniqueId>, second : array<SItemUniqueId>)
{
	var i, s : int;
	
	s = second.Size();
	for(i=0; i<s; i+=1)
	{
		if (!first.Contains(second[i]))
		{
			first.PushBack(second[i]);
		}
	}
}



function ArrayOfGameplayEntitiesAppendArrayOfActorsUnique(out first : array<CGameplayEntity>, second : array<CActor>)
{
	var i, s : int;
	
	s = second.Size();
	for(i=0; i<s; i+=1)
	{
		if (!first.Contains(second[i]))
		{
			first.PushBack(second[i]);
		}
	}
}


function ArrayOfGameplayEntitiesAppendUnique(out first : array<CGameplayEntity>, second : array<CGameplayEntity>)
{
	var i, s : int;
	
	s = second.Size();
	for(i=0; i<s; i+=1)
	{
		if (!first.Contains(second[i]))
		{
			first.PushBack(second[i]);
		}
	}
}

function ArrayOfNamesCount(arr : array<name>, item : name) : int
{
	var i, cnt : int;
	
	cnt = 0;
	for(i=0; i<arr.Size(); i+=1)
		if(arr[i] == item)
			cnt += 1;
			
	return cnt;
}

function ArrayOfNamesRemoveAll(out arr : array<name>, item : name)
{
	var i : int;
	
	while(true)
	{
		i = arr.FindFirst(item);
		if(i == -1)
			return;
			
		arr.Erase(i);
	}
}


function ArrayOfStringsRemove( toRemoveFrom : array< string >, toRemove : array< string > ) : array < string >
{
	var i : int;
	var ret : array< string >;
	
	for( i=0; i<toRemoveFrom.Size(); i+=1 )
	{
		if( !toRemove.Contains( toRemoveFrom[i] ) )
		{
			ret.PushBack( toRemoveFrom[i] );
		}
	}
	
	return ret;
}


function ArrayOfStringsRemoveDuplicatesRO( out arr : array< string > )
{
	var i,j : int;
	
	if( arr.Size() < 2 )
	{
		return;
	}
	
	for( i=arr.Size()-2; i>=0; i-= 1 )
	{
		for( j=arr.Size()-1; j>i; j-=1 )
		{
			if( arr[j] == arr[i] )
			{
				arr.EraseFast( i );
				break;
			}
		}
	}
}