#include <sourcemod>
#include <codmod>
#include <codmod_monety>

#define PLUGIN_NAME "Call of Duty: Komendy Administratora"
#define PLUGIN_VERSION "1.0"
#define PLUGIN_AUTHOR "KarajuSs"
#define PLUGIN_DESCRIPTION "Plugin dodaje komendy admina dla CoD Moda typu: ustawianie lvl'a/expa/monet/perków"
#define PLUGIN_URL "http://steamcommunity.com/id/karajussg"

public Plugin:myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

char BRAK_GRACZA[] = "[KONSOLA COD:MW] Nie odnaleziono danego gracza!",
	BRAK_KLASY[] = "[KONSOLA COD:MW] Gracz nie wybrał żadnej klasy!",
	WART_UJEMNA[] = "[KONSOLA COD:MW] Podana wartość jest niepoprawna! Wartość nie może być ujemna!";

public OnPluginStart() {
	CreateConVar(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	//DOŚWIADCZENIE/POZIOM
	RegAdminCmd("cod_dajxp", Komenda_DajXp, ADMFLAG_ROOT);
	RegAdminCmd("cod_ustawxp", Komenda_UstawXp, ADMFLAG_ROOT);
	RegAdminCmd("cod_dajlvl", Komenda_DajPoziom, ADMFLAG_ROOT);
	RegAdminCmd("cod_ustawlvl", Komenda_UstawPoziom, ADMFLAG_ROOT);
	//PERKI
	/*RegAdminCmd("cod_ustawperk1", Komenda_UstawPerk1, ADMFLAG_ROOT);
	RegAdminCmd("cod_ustawperk2", Komenda_UstawPerk2, ADMFLAG_ROOT);*/
	//MONETY
	RegAdminCmd("cod_dajmonety", Komenda_DajMonety, ADMFLAG_ROOT);
	RegAdminCmd("cod_ustawmonety", Komenda_UstawMonety, ADMFLAG_ROOT);
}

public Action Komenda_DajXp(int client, int args) {
	if(args != 2) {
		PrintToConsole(client, "Użyj: cod_dajxp <nick> <wartość>");
		return Plugin_Handled;
	}
 
	char targetName[64];
	GetCmdArg(1, targetName, sizeof(targetName));
	int target = FindTarget(client, targetName, true, true);

	if(target <= 0) {
		ReplyToCommand(client, BRAK_GRACZA);
		return Plugin_Handled;
	}

	if(!cod_get_user_class(target)) {
		ReplyToCommand(client, BRAK_KLASY);
		return Plugin_Handled;
	}

	int exp;
	char sExp[32];

	GetCmdArg(2, sExp, sizeof(sExp));
	exp = StringToInt(sExp);

	if(exp <= 0) {
		ReplyToCommand(client, WART_UJEMNA);
		return Plugin_Handled;
	}

	GetClientName(target, targetName, sizeof(targetName));
	cod_set_user_xp(target, cod_get_user_xp(target)+exp);
	PrintToConsole(client, "[KONSOLA COD:MW] Graczowi %s dodano +%d doświadczenia.", targetName, exp);

	return Plugin_Handled;
}

public Action Komenda_UstawXp(int client, int args) {
	if (args != 2) {
		PrintToConsole(client, "Użyj: cod_ustawxp <nick> <wartość>");
		return Plugin_Handled;
	}
 
	char targetName[64];
	GetCmdArg(1, targetName, sizeof(targetName));
	int target = FindTarget(client, targetName, true, true);

	if(target <= 0) {
		ReplyToCommand(client, BRAK_GRACZA);
		return Plugin_Handled;
	}

	if(!cod_get_user_class(target)) {
		ReplyToCommand(client, BRAK_KLASY);
		return Plugin_Handled;
	}

	int exp;
	char sExp[32];

	GetCmdArg(2, sExp, sizeof(sExp));
	exp = StringToInt(sExp);

	if(exp < 0) {
		ReplyToCommand(client, WART_UJEMNA);
		return Plugin_Handled;
	}

	GetClientName(target, targetName, sizeof(targetName));
	cod_set_user_xp(target, exp);
	PrintToConsole(client, "[KONSOLA COD:MW] Graczowi %s ustawiono %d doświadczenia.", targetName, exp);

	return Plugin_Handled;
}

public Action Komenda_DajPoziom(int client, int args) {
	if(args != 2) {
		PrintToConsole(client, "Użyj: cod_dajlvl <nick> <wartość>");
		return Plugin_Handled;
	}

	char targetName[64];
	GetCmdArg(1, targetName, sizeof(targetName));
	int target = FindTarget(client, targetName, true, true);

	if(target <= 0) {
		ReplyToCommand(client, BRAK_GRACZA);
		return Plugin_Handled;
	}

	if(!cod_get_user_class(target)) {
		ReplyToCommand(client, BRAK_KLASY);
		return Plugin_Handled;
	}

	int level;
	char sLevel[16];

	GetCmdArg(2, sLevel, sizeof(sLevel));
	level = StringToInt(sLevel);

	if(level <= 0) {
		ReplyToCommand(client, WART_UJEMNA);
		return Plugin_Handled;
	}

	new NowyPoziom = cod_get_level_xp(cod_get_user_level(target)+level-1);

	GetClientName(target, targetName, sizeof(targetName));
	cod_set_user_xp(target, NowyPoziom);
	PrintToConsole(client, "[KONSOLA COD:MW] Graczowi %s dodano +%d poziom.", targetName, sLevel);

	return Plugin_Handled;
}

public Action Komenda_UstawPoziom(int client, int args) {
	if(args != 2) {
		PrintToConsole(client, "Użyj: cod_ustawlvl <nick> <wartość>");
		return Plugin_Handled;
	}
 
	char targetName[64];
	GetCmdArg(1, targetName, sizeof(targetName));
	int target = FindTarget(client, targetName, true, true);

	if(target <= 0) {
		ReplyToCommand(client, BRAK_GRACZA);
		return Plugin_Handled;
	}

	if(!cod_get_user_class(target)) {
		ReplyToCommand(client, BRAK_KLASY);
		return Plugin_Handled;
	}

	int level;
	char sLevel[16];

	GetCmdArg(2, sLevel, sizeof(sLevel));
	level = StringToInt(sLevel);

	if(level <= 0) {
		ReplyToCommand(client, WART_UJEMNA);
		return Plugin_Handled;
	}

	GetClientName(target, targetName, sizeof(targetName));
	cod_set_user_xp(target, cod_get_level_xp(level-1));
	PrintToConsole(client, "[KONSOLA COD:MW] Graczowi %s ustawiono %d poziom", targetName, level);

	return Plugin_Handled;
}
/*
public Action Komenda_UstawPerk1(int client, int args) {
	if(args < 2) {
		PrintToConsole(client, "Użyj: cod_ustawperk1 <nick> <nazwa perka> [wartość perku]");
		return Plugin_Handled;
	}
 
	char targetName[64];
	GetCmdArg(1, targetName, sizeof(targetName));
	int target = FindTarget(client, targetName, true, true);

	if(target <= 0) {
		ReplyToCommand(client, BRAK_GRACZA);
		return Plugin_Handled;
	}

	if(!cod_get_user_class(target)) {
		ReplyToCommand(client, BRAK_KLASY);
		return Plugin_Handled;
	}

	int perkID, perkValue = -1;
	char perkName[MAX_PERKNAME_LENGTH+1];

	GetCmdArg(2, perkName, sizeof(perkName));
	perkID = GetPerkID(perkName);

	if(!perkID) {
		PrintToConsole(client, "[KONSOLA COD:MW] Nie znaleziono perku");
		return Plugin_Handled;
	}

	if(args == 3) {
		char sPerkValue[32];

		GetCmdArg(3, sPerkValue, sizeof(sPerkValue));
		perkValue = StringToInt(sPerkValue);
	}

	GetClientName(target, targetName, sizeof(targetName));
	SetClientPerk(target, perkID, perkValue);
	PrintToConsole(client, "[KONSOLA COD:MW] Graczowi %s ustawiono perk %s", targetName, perkName);

	return Plugin_Handled;
}
public Action Komenda_UstawPerk2(int client, int args) {
	if(args < 2) {
		PrintToConsole(client, "Użyj: cod_ustawperk2 <nick> <nazwa perka> [wartość perku]");
		return Plugin_Handled;
	}
 
	char targetName[64];
	GetCmdArg(1, targetName, sizeof(targetName));
	int target = FindTarget(client, targetName, true, true);

	if(target <= 0) {
		ReplyToCommand(client, BRAK_GRACZA);
		return Plugin_Handled;
	}

	if(!cod_get_user_class(target)) {
		ReplyToCommand(client, BRAK_KLASY);
		return Plugin_Handled;
	}

	int perkID, perkValue = -1;
	char perkName[MAX_PERKNAME_LENGTH+1];

	GetCmdArg(2, perkName, sizeof(perkName));
	perkID = GetPerkID(perkName);

	if(!perkID) {
		PrintToConsole(client, "[KONSOLA COD:MW] Nie znaleziono perku");
		return Plugin_Handled;
	}

	if(args == 3) {
		char sPerkValue[32];

		GetCmdArg(3, sPerkValue, sizeof(sPerkValue));
		perkValue = StringToInt(sPerkValue);
	}

	GetClientName(target, targetName, sizeof(targetName));
	SetClientPerk(target, perkID, perkValue);
	PrintToConsole(client, "[KONSOLA COD:MW] Graczowi %s ustawiono perk %s", targetName, perkName);

	return Plugin_Handled;
}
*/

public Action Komenda_DajMonety(int client, int args) {
	if(args != 2) {
		ReplyToCommand(client, "Użyj: cod_dajmonety <nick> <wartość>");
		return Plugin_Handled;
	}

	char targetName[64];
	GetCmdArg(1, targetName, sizeof(targetName));
	int target = FindTarget(client, targetName, true, true);

	if(target <= 0) {
		ReplyToCommand(client, BRAK_GRACZA);
		return Plugin_Handled;
	}

	char NoweMonety[32];

	GetCmdArg(2, NoweMonety, sizeof(NoweMonety));
	new amount = StringToInt(NoweMonety);
	
	if(amount <= 0) {
		ReplyToCommand(client, WART_UJEMNA);
		return Plugin_Handled;
	}

	GetClientName(target, targetName, sizeof(targetName));
	cod_set_user_coins(target, cod_get_user_coins(client)+amount);
	PrintToConsole(client, "[KONSOLA COD:MW] Graczowi %s dodano %d monet.", targetName, amount);

	return Plugin_Handled;
}

public Action Komenda_UstawMonety(int client, int args) {
	if(args != 2) {
		ReplyToCommand(client, "Użyj: cod_ustawmonety <nick> <wartość>");
		return Plugin_Handled;
	}

	char targetName[64];
	GetCmdArg(1, targetName, sizeof(targetName));
	int target = FindTarget(client, targetName, true, true);

	if(target <= 0) {
		ReplyToCommand(client, BRAK_GRACZA);
		return Plugin_Handled;
	}

	char NoweMonety[32];

	GetCmdArg(2, NoweMonety, sizeof(NoweMonety));
	new amount = StringToInt(NoweMonety);

	if(amount <= 0) {
		ReplyToCommand(client, WART_UJEMNA);
		return Plugin_Handled;
	}

	GetClientName(target, targetName, sizeof(targetName));
	cod_set_user_coins(target, amount);
	PrintToConsole(client, "[KONSOLA COD:MW] Graczowi %s ustawiono %d monet.", targetName, amount);

	return Plugin_Handled;
}