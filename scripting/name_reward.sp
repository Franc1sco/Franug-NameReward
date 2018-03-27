/*
	SM Franug Name Reward

	Copyright (C) 2018 Francisco 'Franc1sco' García

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <sourcemod>
#include <sdktools>
#include <store>
#include <colorvariables>

#pragma newdecls required

#define VERSION "1.0"

ConVar gcv_Time, gcv_Credits, gcv_Advert;


Handle g_Timer;

int g_iCredits;
char g_sAdvert[128];

public Plugin myinfo = {
	name = "SM Franug Name Reward",
	author = "Franc1sco franug",
	description = "",
	version = VERSION,
	url = "http://steamcommunity.com/id/franug"
};

public void OnPluginStart()
{
	LoadTranslations("namereward.phrases");
	
	CreateConVar("sm_namereward_version", VERSION, "Version", FCVAR_SPONLY|FCVAR_NOTIFY);
	
	gcv_Time = CreateConVar("sm_namereward_time", "60.0");
	gcv_Credits = CreateConVar("sm_namereward_credits", "1");
	gcv_Advert = CreateConVar("sm_namereward_advert", "Cola-Team.com");
	
	g_iCredits = GetConVarInt(gcv_Credits);
	GetConVarString(gcv_Advert, g_sAdvert, sizeof(g_sAdvert));
	
	HookConVarChange(gcv_Time, OnSettingChanged);
	HookConVarChange(gcv_Credits, OnSettingChanged);
	HookConVarChange(gcv_Advert, OnSettingChanged);
	
	g_Timer = CreateTimer(GetConVarFloat(gcv_Time), Timer_GetCredits, _, TIMER_REPEAT);
}

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gcv_Time)
	{
		if (g_Timer != null)KillTimer(g_Timer);
		
		g_Timer = CreateTimer(StringToFloat(newValue), Timer_GetCredits, _, TIMER_REPEAT);
	}
	else if (convar == gcv_Credits)
	{
		g_iCredits = StringToInt(newValue);
	}
	else if (convar == gcv_Advert)
	{
		strcopy(g_sAdvert, sizeof(g_sAdvert), newValue);
	}
}

public Action Timer_GetCredits(Handle hTimer)
{
	char sName[128];
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && GetClientTeam(i) > 1)
		{
			GetClientName(i, sName, 128);
			if(StrContains(sName, g_sAdvert, false) > -1)
			{
				Store_SetClientCredits(i, Store_GetClientCredits(i) + g_iCredits);
				CPrintToChat(i, "%T", "HaveTag", i, g_iCredits, g_sAdvert);
			}	
			else CPrintToChat(i, "%T","NeedTag", i, g_sAdvert);	
		}
}