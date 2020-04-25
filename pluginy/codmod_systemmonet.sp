#include <sourcemod>
#include <sdkhooks>

#define PLUGIN_NAME "Call of Duty: System Monet"
#define PLUGIN_VERSION "1.0"
#define PLUGIN_AUTHOR "KarajuSs"
#define PLUGIN_DESCRIPTION "Dodaje na serwer nową walutę: monety"
#define PLUGIN_URL "http://steamcommunity.com/id/karajussg"

#define MINIMALNA_ILOSC_GRACZY 2
#define VIP(%1) CheckCommandAccess(%1,"sm_accesstovip",ADMFLAG_RESERVATION)

public Plugin:myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

new monety_gracza[MAXPLAYERS];

Database DB;

new	Handle:cvar_coins_kill,
	Handle:cvar_coins_hskill,
	Handle:cvar_coins_bomb_defused,
	Handle:cvar_coins_bomb_plantend,
	Handle:cvar_coins_rescue_hostage,
	Handle:cvar_coins_kill_hostage,
	Handle:cvar_coins_vip_kill,
	Handle:cvar_coins_vip_hskill,
	Handle:cvar_coins_bomb_vip_plantend,
	Handle:cvar_coins_bomb_vip_defused,
	Handle:cvar_coins_vip_rescue_hostage,
	Handle:cvar_coins_vip_kill_hostage;

public OnPluginStart() {
	HookEvent("hostage_rescued", ZakladnikUratowany);
	HookEvent("hostage_killed", ZakladnikZabity);
	HookEvent("bomb_defused", BombaRozbrojona);
	HookEvent("bomb_planted", BombaPodlozona);
	HookEvent("player_death", SmiercGracza);

	CreateConVar(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	cvar_coins_kill = CreateConVar("cod_coins_kill", "1");
	cvar_coins_hskill = CreateConVar("cod_coins_kill_hs", "3");
	cvar_coins_bomb_plantend = CreateConVar("cod_coins_planted", "1");
	cvar_coins_bomb_defused = CreateConVar("cod_coins_defused", "1");
	cvar_coins_rescue_hostage = CreateConVar("cod_coins_rescue_hostage", "1");
	cvar_coins_kill_hostage = CreateConVar("cod_coins_kill_hostage", "2");

	cvar_coins_vip_kill = CreateConVar("cod_coins_kill_vip", "2");
	cvar_coins_vip_hskill = CreateConVar("cod_coins_kill_hs_vip", "6");
	cvar_coins_bomb_vip_plantend = CreateConVar("cod_coins_planted_vip", "2");
	cvar_coins_bomb_vip_defused = CreateConVar("cod_coins_defused_vip", "2");
	cvar_coins_vip_rescue_hostage = CreateConVar("cod_coins_rescue_hostage_vip", "2");
	cvar_coins_vip_kill_hostage = CreateConVar("cod_coins_kill_hostage_vip", "1");
}
public OnMapStart() {
	DataBaseConnect();
}

public OnClientPutInServer(client) {
	WczytajMonety(client);
}
public OnClientDisconnect(client) {
	ZapiszMonety(client);
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max) {
	RegPluginLibrary("codmod_monety");

	CreateNative("cod_set_user_coins", UstawMonety);
	CreateNative("cod_get_user_coins", PobierzMonety);

	return APLRes_Success;
}

public Action DataBaseConnect() {
	char error[128];
	DB = SQL_Connect("codmod_lvl_sql", true, error, sizeof(error));
	if(DB == INVALID_HANDLE) {
		LogError("Problem z połączeniem się z bazą danych codmod_lvl_sql: %s", error);
		return;
	}

	char zapytanie[1024];
	Format(zapytanie, sizeof(zapytanie), "CREATE TABLE IF NOT EXISTS `codmod_monety` (`ID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY, ");
	StrCat(zapytanie, sizeof(zapytanie), "`steamID` INT NOT NULL, `nick` VARCHAR(64) NOT NULL, `monety` INT UNSIGNED NOT NULL DEFAULT 0);");

	if(!SQL_FastQuery(DB, zapytanie)) {
		SQL_GetError(DB, error, sizeof(error));
		PrintToServer("Nie udało się stworzyć tabeli 'codmod_monety'! Błąd: %s", error);
	}
}

public Action WczytajMonety(client) {
	if (IsFakeClient(client) || IsClientSourceTV(client))
		return;

	/*new String:steamID[64];
	GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));*/
	
	int sid = GetSteamAccountID(client);
	char zapytanie[1024];
	Format(zapytanie, sizeof(zapytanie), "SELECT `monety` FROM `codmod_monety` WHERE `steamID`=%d;", sid);
	DBResultSet query = SQL_Query(DB, zapytanie);
	if (query == null) {
		char error[255];
		SQL_GetError(DB, error, sizeof(error));
		PrintToServer("Nie udało się pobrać danych gracza %N! (błąd: %s)", client, error);
		return;
	}

	if (!SQL_GetRowCount(query)) {
		Format(zapytanie, sizeof(zapytanie), "INSERT INTO `codmod_monety` (`steamID`, `nick`) VALUES (%d, '%N')", sid, client);
		if (!SQL_FastQuery(DB, zapytanie)) {
			char error[255];
			SQL_GetError(DB, error, sizeof(error));
			PrintToServer("Nie udało się dodać nowego gracza %N! (błąd: %s)", client, error);
		}
		return;
	}

	while (SQL_FetchRow(query)) {
		monety_gracza[client] = SQL_FetchInt(query, 0);
	}
}

public Action ZapiszMonety(client) {
	char zapytanie[1024];
	Format(zapytanie, sizeof(zapytanie), "UPDATE `codmod_monety` SET `monety`=%d WHERE `steamID`=%d;", monety_gracza[client], GetSteamAccountID(client));
	if (!SQL_FastQuery(DB, zapytanie)) {
		char error[255];
		SQL_GetError(DB, error, sizeof(error));
		PrintToServer("Nie udało się zaktualizować danych gracza %N! (błąd: %s)", client, error);
	}
}

public Action SmiercGracza(Handle event, char[] name, bool dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new killer = GetClientOfUserId(GetEventInt(event, "attacker"));
	new bool:hs = GetEventBool(event, "headshot");

	if(!IsValidClient(client) || !IsValidClient(killer))
		return Plugin_Continue;

	if(VIP(killer)){
		if(hs)
			monety_gracza[killer] += GetConVarInt(cvar_coins_vip_hskill);
		else
			monety_gracza[killer] += GetConVarInt(cvar_coins_vip_kill);
	} else {
		if(hs)
			monety_gracza[killer] += GetConVarInt(cvar_coins_hskill);
		else
			monety_gracza[killer] += GetConVarInt(cvar_coins_kill);
	}

	return Plugin_Continue;
}

public Action BombaPodlozona(Handle event, char[] name, bool dontbroadcast) {
	if(IsValidPlayers() < MINIMALNA_ILOSC_GRACZY)
		return Plugin_Continue;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(VIP(client))
		monety_gracza[client] += GetConVarInt(cvar_coins_bomb_vip_plantend);
	else
		monety_gracza[client] += GetConVarInt(cvar_coins_bomb_plantend);

	return Plugin_Continue;
}

public Action BombaRozbrojona(Handle event, char[] name, bool dontbroadcast) {
	if(IsValidPlayers() < MINIMALNA_ILOSC_GRACZY)
		return Plugin_Continue;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(VIP(client))
		monety_gracza[client] += GetConVarInt(cvar_coins_bomb_vip_defused);
	else
		monety_gracza[client] += GetConVarInt(cvar_coins_bomb_defused);

	return Plugin_Continue;
}

public Action ZakladnikUratowany(Handle event, char[] name, bool dontbroadcast) {
	if(IsValidPlayers() < MINIMALNA_ILOSC_GRACZY)
		return Plugin_Continue;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(VIP(client))
		monety_gracza[client] += GetConVarInt(cvar_coins_vip_rescue_hostage);
	else
		monety_gracza[client] += GetConVarInt(cvar_coins_rescue_hostage);

	return Plugin_Continue;
}

public Action ZakladnikZabity(Handle event, char[] name, bool dontbroadcast) {
	if(IsValidPlayers() < MINIMALNA_ILOSC_GRACZY)
		return Plugin_Continue;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(VIP(client))
		monety_gracza[client] -= GetConVarInt(cvar_coins_vip_kill_hostage);
	else
		monety_gracza[client] -= GetConVarInt(cvar_coins_kill_hostage);

	return Plugin_Continue;
}

public UstawMonety(Handle:plugin, numParams) {
	new client = GetNativeCell(1);
	new amount = GetNativeCell(2);

	monety_gracza[client] = amount;
}

public PobierzMonety(Handle:plugin, numParams) {
	new client = GetNativeCell(1);
	new amount = monety_gracza[client];

	return amount;
}

public IsValidPlayers() {
	new gracze;
	for(new i = 1; i <= MaxClients; i ++) {
		if(!IsClientInGame(i) || IsFakeClient(i))
			continue;

		gracze ++;
	}

	return gracze;
}
public bool IsValidClient(client) {
	if(client >= 1 && client <= MaxClients && IsClientInGame(client))
		return true;

	return false;
}