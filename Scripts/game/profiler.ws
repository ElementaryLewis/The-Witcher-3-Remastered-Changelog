/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import function PROFILER_Init( bufforSize : int );
import function PROFILER_InitEx( bufforSize : int, bufforSignalsSize : int );
import function PROFILER_ScriptEnable();
import function PROFILER_ScriptDisable();
import function PROFILER_Start();
import function PROFILER_Stop();
import function PROFILER_Store( profileName : string );
import function PROFILER_StoreDef();
import function PROFILER_StoreInstrFuncList();
import function PROFILER_StartCatchBreakpoint();
import function PROFILER_StopCatchBreakpoint();
import function PROFILER_SetTimeBreakpoint( instrFuncName : string, time : float, stopOnce : bool );
import function PROFILER_SetHitCountBreakpoint( instrFuncName : string, counter : int );
import function PROFILER_DisableTimeBreakpoint( instrFuncName : string );
import function PROFILER_DisableHitCountBreakpoint( instrFuncName : string );
	