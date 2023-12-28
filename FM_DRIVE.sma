#pragma compress 1

#include "feckinmad/fm_global"
#include "feckinmad/fm_mapfunc"
#include <fakemeta>
#include <xs>

new g_szPluginAuthor[] = "syc & DarthMan";
new const g_szFileName[] = "drivemaps.ini";
new g_iMsgTrain;
const InvalidMessage = 0;
const g_iLinMacDiff = 5;
const g_iFlyablePlane = (1 << 0);
const g_iAllowRollFlag = (1 << 1);
const Float: g_fMaxDistance = 4096.0;
const Float: g_fSphereDistance = 30.0;
const Float: g_fTouchDistance = 128.0;
const Float: g_fAngleMultiplier = 2.75;
const Float: g_fAngleDiff = 3.5;
const Float: g_fNullAngle = 0.0;
new const Float: g_fVecAngleDeg[] = {180.0, 360.0};
new g_iPlayerTrainFlags[MAX_PLAYERS + 1] = {FM_NULLENT, ...},
g_iPlayerTrainEnt[MAX_PLAYERS + 1] = {FM_NULLENT, ...},
g_iPlayerPlane[MAX_PLAYERS + 1] = {FM_NULLENT, ...};
new Float: g_fPlayerOldAngle[MAX_PLAYERS + 1];

#define PFLAG_ONTRAIN		( 1<<1 )

public plugin_init()
{
	fm_RegisterPlugin(g_szPluginAuthor);
	
	if(!Read_DriveFile())
	{
		pause("d");
		
		return;
	}

	g_iMsgTrain = get_user_msgid("Train");
	
	register_message(g_iMsgTrain, "Handle_TrainMsg");
	
	register_forward(FM_StartFrame, "Handle_TrailTimer", true);
}

bool: Read_DriveFile()
{
	new szFile[128];
	
	fm_BuildAMXFilePath(g_szFileName, szFile, charsmax(szFile), "amxx_configsdir");
	
	new hFile = fopen(szFile, "rt");
	
	if(!hFile)
	{
		fm_WarningLog(FM_FOPEN_WARNING, szFile);
		
		return false;
	}
	else
	{
		new szCurrentMap[32], szFileBuffer[32];
		
		get_mapname(szCurrentMap, charsmax(szCurrentMap));
		
		while(!feof(hFile) && fgets(hFile, szFileBuffer, charsmax(szFileBuffer)))
		{
			trim(szFileBuffer);
			
			if(fm_Comment(szFileBuffer))
			{
				continue;
			}
			
			if(!fm_IsMapValid(szFileBuffer))
			{
				continue;
			}
			
			if(equali(szCurrentMap, szFileBuffer))
			{
				fclose(hFile);
				
				return true;
			}
		}
		
		fclose(hFile);
	}
	
	return false;
}

public Handle_TrailTimer()
{
	static Float: fTickAt, Float: fGameTime;
	
	fGameTime = get_gametime();
	
	if(fTickAt > fGameTime)
	{
		return;
	}
	
	static iPlayers[32], iPlayer, iNum, i;
	
	get_players(iPlayers, iNum, "ahi");
	
	if(iNum)
	{
		for(i = 0; i < iNum; i++)
		{
			iPlayer = iPlayers[i];
			
			if((pev_valid(g_iPlayerTrainEnt[iPlayer]) == 2) && (pev_valid(g_iPlayerPlane[iPlayer]) == 2))
			{
				Update_Train(iPlayer, g_iPlayerTrainEnt[iPlayer]);
			}
		}
	}
	
	fTickAt = fGameTime + 0.1;
}

Update_Train(const iID, const iEnt)
{
	if(!GetTouchedEntity(iID, g_iPlayerPlane[iID]))
	{
		g_iPlayerPlane[iID] = FM_NULLENT;
		g_iPlayerTrainEnt[iID] = FM_NULLENT;
		g_iPlayerTrainFlags[iID] = FM_NULLENT;
		g_fPlayerOldAngle[iID] = g_fNullAngle;
		
		UnUseTrain(iID);
		
		return;
	}
	
	static Float:fVecPlayerOrigin[3];
	pev(iID, pev_origin, fVecPlayerOrigin);
	
	static Float: fVecPlayerAngles[3];
	pev(iID, pev_angles, fVecPlayerAngles);
	
	static Float: fVecEntOrigin[3];
	pev(iEnt, pev_origin, fVecEntOrigin);
	
	static Float: fAngleDiff, Float: fVecNewOrigin[3];
	fAngleDiff = fVecPlayerAngles[1] - g_fPlayerOldAngle[iID];
	
	if(fAngleDiff < -g_fVecAngleDeg[0])
	{
		fAngleDiff += g_fVecAngleDeg[1];
	}
	if(fAngleDiff > g_fVecAngleDeg[0])
	{
		fAngleDiff -= g_fVecAngleDeg[1];
	}
	
	if(fAngleDiff >= g_fAngleDiff)
	{
		fVecPlayerAngles[1] = g_fPlayerOldAngle[iID] + g_fAngleDiff;
		
		if(fVecPlayerAngles[1] > g_fVecAngleDeg[0])
		{
			fVecPlayerAngles[1] -= g_fVecAngleDeg[1];
		}
	}
	else if(fAngleDiff <= -g_fAngleDiff)
	{
		fVecPlayerAngles[1] = g_fPlayerOldAngle[iID] - g_fAngleDiff;
			
		if(fVecPlayerAngles[1] < g_fVecAngleDeg[0])
		{
			fVecPlayerAngles[1] += g_fVecAngleDeg[1];
		}
	}
	
	g_fPlayerOldAngle[iID] = fVecPlayerAngles[1];
	
	if(!(g_iPlayerTrainFlags[iID] & g_iAllowRollFlag))
	{
		fVecPlayerOrigin[2] = fVecEntOrigin[2];
		
		planar_velocity_by_angle(fVecPlayerOrigin, fVecPlayerAngles, g_fMaxDistance, fVecNewOrigin);
	}
	else
	{
		velocity_by_angle(fVecPlayerOrigin, fVecPlayerAngles, g_fMaxDistance, fVecNewOrigin);
	}
	
	engfunc(EngFunc_SetOrigin, iEnt, fVecNewOrigin);
}

public Handle_TrainMsg(const iMsg, const iDest, const iEnt)
{
	new iControl = get_msg_arg_int(1);
	
	if((iControl != 0) && (g_iPlayerTrainEnt[iEnt] == FM_NULLENT))
	{
		new iTrain = pev(iEnt, pev_groundentity);
		
		new szClassName[32];
		pev(iTrain, pev_classname, szClassName, charsmax(szClassName));
	
		if(pev_valid(iTrain) != 2)
		{
			fm_WarningLog("Player #%d triggered Train message with an invalid ground entity id: #%d.", iEnt);
		
			return PLUGIN_CONTINUE;
		}
		
		g_iPlayerPlane[iEnt] = iTrain;
	
		g_iPlayerTrainFlags[iEnt] = pev(iTrain, pev_skin);
	
		if(!(g_iPlayerTrainFlags[iEnt] & g_iFlyablePlane))
		{
			return PLUGIN_CONTINUE;
		}
	
		new szBuffer[32], iTrainPath = FM_NULLENT;
		pev(iTrain, pev_target, szBuffer, charsmax(szBuffer));
	
		iTrainPath = engfunc(EngFunc_FindEntityByString, iTrainPath, "targetname", szBuffer);
		pev(iTrainPath, pev_target, szBuffer, charsmax(szBuffer));
	
		if(pev_valid(iTrainPath) != 2)
		{
			fm_WarningLog("Path id: #%d of entity id: #%d does not exist.", iTrainPath, iEnt);
		
			return PLUGIN_CONTINUE;
		}
		
		new Float: fVecPlayerAngles[3];
		pev(iEnt, pev_angles, fVecPlayerAngles);
		
		g_fPlayerOldAngle[iEnt] = fVecPlayerAngles[1];
	
		g_iPlayerTrainEnt[iEnt] = engfunc(EngFunc_FindEntityByString, -1, "targetname", szBuffer);
	}
	else
	{
		if(!iControl)
		{
			g_iPlayerPlane[iEnt] = FM_NULLENT;
			g_iPlayerTrainEnt[iEnt] = FM_NULLENT;
			g_iPlayerTrainFlags[iEnt] = FM_NULLENT;
			g_fPlayerOldAngle[iEnt] = g_fNullAngle;
		}
	}
	
	return PLUGIN_CONTINUE;
}

GetPlayerEntity(const iID, const Float: fDistance = g_fMaxDistance)
{
	static Float: fVecOrigin[3], Float: fVecAngles[3], Float: fVecDown[3], Float: fVecEnd[3];

	pev(iID, pev_origin, fVecOrigin);
	pev(iID, pev_view_ofs, fVecDown);

	xs_vec_add(fVecOrigin, fVecDown, fVecOrigin);

	pev(iID, pev_angles, fVecAngles);

	angle_vector(fVecAngles, ANGLEVECTOR_UP, fVecDown);
	xs_vec_neg(fVecDown, fVecDown);
    
	xs_vec_add_scaled(fVecOrigin, fVecDown, fDistance, fVecEnd);
    
	static iTrace, iHit, Float: fFraction;
	iTrace = create_tr2();

	engfunc(EngFunc_TraceLine, fVecOrigin, fVecEnd, IGNORE_MONSTERS, iID, iTrace);
    
	iHit = get_tr2(iTrace, TR_pHit);
	get_tr2(iTrace, TR_flFraction, fFraction);

	free_tr2(iTrace);

	if(fFraction >= 1.0)
	{
		return -1;
	}

	return (pev_valid(iHit) == 2) ? iHit : 0;
}

GetTouchedEntity(const iID, const iPlane)
{
	static Float: fOrigin[3];
	
	pev(iID, pev_origin, fOrigin);
	
	static iEnt;
	iEnt = FM_NULLENT;

	if(GetPlayerEntity(iID, g_fTouchDistance) == iPlane)
	{
		return iEnt;
	}
	
	while((iEnt = engfunc(EngFunc_FindEntityInSphere, iEnt, fOrigin, g_fSphereDistance)) > 0)
	{
		if(iEnt == iPlane)
		{
			return iEnt;
		}
	}
	
	return 0;
}

UnUseTrain(const iID)
{
	static iFlags;
	iFlags = pev(iID, pev_flags);
	
	if(iFlags & FL_ONTRAIN)
	{
		set_pev(iID, pev_flags, iFlags & ~FL_ONTRAIN);
	}
	
	static iButtons;
	pev(iID, pev_button, iButtons);
	
	if(iButtons & IN_USE)
	{
		set_pev(iID, pev_button, iButtons & ~IN_USE);
		set_pev(iID, pev_oldbuttons, pev(iID, pev_oldbuttons) | IN_USE); 
	}
	
	static iPhysFlags;
	iPhysFlags = get_ent_data(iID, "CBasePlayer", "m_afPhysicsFlags");
	
	if(iPhysFlags &= PFLAG_ONTRAIN)
	{
		iPhysFlags &= ~PFLAG_ONTRAIN;
		set_ent_data(iID, "CBasePlayer", "m_afPhysicsFlags", iPhysFlags);
	}
	
	message_begin(MSG_ONE, g_iMsgTrain, _, iID);
	write_byte(0);
	message_end();
}

velocity_by_angle(const Float: fVecOrigin[3], Float: fVecAngles[3], const Float: fDistance, Float: fVecOutput[3])
{
	fVecAngles[0] *= g_fAngleMultiplier;
	
	fVecOutput[0] = fVecOrigin[0] + fDistance * floatcos(fVecAngles[1], degrees);
	fVecOutput[1] = fVecOrigin[1] + fDistance * floatsin(fVecAngles[1], degrees);
	fVecOutput[2] = fVecOrigin[2] + fDistance * floatsin(fVecAngles[0], degrees);
}

planar_velocity_by_angle(const Float: fVecOrigin[3], Float: fVecAngles[3], const Float: fDistance, Float: fVecOutput[3])
{
	fVecAngles[0] *= g_fAngleMultiplier;
	
	fVecOutput[0] = fVecOrigin[0] + fDistance * floatcos(fVecAngles[1], degrees);
	fVecOutput[1] = fVecOrigin[1] + fDistance * floatsin(fVecAngles[1], degrees);
	fVecOutput[2] = fVecOrigin[2];
}