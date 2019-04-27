#include <tf2_stocks>

public Plugin myinfo = 
{
	name = "Infection",
	author = "myst",
	description = "Spawn as any class you want and make everyone turn into your class.",
	version = "1.0",
	url = "https://titan.tf"
}

public void OnPluginStart()
{
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_changeclass", Event_PlayerClass);
}

public Action Event_PlayerClass(Handle hEvent, const char[] sEventName, bool bDontBroadcast)
{
	if (GameRules_GetRoundState() != RoundState_Preround)
	{
		PrintCenterText(GetClientOfUserId(GetEventInt(hEvent, "userid")), "You cannot change classes during a round! You can only select classes once during setup each round.")
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerDeath(Handle hEvent, const char[] sEventName, bool bDontBroadcast)
{
	int iVictim = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	int iAttacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));
	
	if (IsValidClient(iVictim) && IsValidClient(iAttacker))
	{
		TFClassType TFClass = TF2_GetPlayerClass(iAttacker);
		TF2_SetPlayerClass(iVictim, TFClass);
		
		char sClass[32];
		switch (TFClass)
		{
			case TFClass_Scout:  	Format(sClass, sizeof(sClass), "Scout");
			case TFClass_Soldier:	Format(sClass, sizeof(sClass), "Soldier");
			case TFClass_Pyro:		Format(sClass, sizeof(sClass), "Pyro");
			case TFClass_DemoMan:	Format(sClass, sizeof(sClass), "Demoman");
			case TFClass_Heavy:		Format(sClass, sizeof(sClass), "Heavy");
			case TFClass_Engineer:	Format(sClass, sizeof(sClass), "Engineer");
			case TFClass_Medic:		Format(sClass, sizeof(sClass), "Medic");
			case TFClass_Sniper:	Format(sClass, sizeof(sClass), "Sniper");
			case TFClass_Spy:		Format(sClass, sizeof(sClass), "Spy");
		}
		
		char sFormat[256];
		Format(sFormat, sizeof(sFormat), "has turned %N into %s", iVictim, sClass);
		
		CreateEvent_Capture(iAttacker, sFormat);
		if (GetPlayerNotClassCount(TFClass, (GetClientTeam(iAttacker) == 2) ? 3 : 2) == 0)
			ForceTeamWin(GetClientTeam(iAttacker));
	}
}

public void CreateEvent_Capture(int iClient, char[] sMessage)
{
	if (IsValidClient(iClient))
	{
		Event hEvent = CreateEvent("teamplay_point_captured");
		if (hEvent != INVALID_HANDLE)
		{
			char sClient[1];
			sClient[0] = iClient;
			
			SetEventString(hEvent, "cpname", sMessage);
			SetEventInt(hEvent, "team", GetClientTeam(iClient));
			SetEventString(hEvent, "cappers", sClient);
			
			FireEvent(hEvent);
		}
	}
}

stock void ForceTeamWin(int iTeam)
{
	int iEntity = FindEntityByClassname(-1, "team_control_point_master");
	if (iEntity == -1)
	{
		iEntity = CreateEntityByName("team_control_point_master");
		DispatchSpawn(iEntity);
		
		AcceptEntityInput(iEntity, "Enable");
	}
	
	SetVariantInt(iTeam);
	AcceptEntityInput(iEntity, "SetWinner");
}

stock int GetPlayerNotClassCount(TFClassType TFClass, int iTeam) 
{ 
	int iCount = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && GetClientTeam(i) == iTeam && TF2_GetPlayerClass(i) != TFClass) 
			iCount++; 
	}
	return iCount; 
}

stock bool IsValidClient(int iClient, bool bReplay = true)
{
	if (iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient))
		return false;
	if (bReplay && (IsClientSourceTV(iClient) || IsClientReplay(iClient)))
		return false;
	return true;
}