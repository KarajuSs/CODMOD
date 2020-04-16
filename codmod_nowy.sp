#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>

#define PLUGIN_NAME "Call of Duty: MW Mod"
#define PLUGIN_VERSION "1.2"
#define PLUGIN_AUTHOR "Linux` edited KarajuSs"
#define PLUGIN_DESCRIPTION "Plugin oparty na kodzie QTM_CodMod by QTM_Peyote"
#define PLUGIN_URL "http://steamcommunity.com/id/linux2006"

#define MAKSYMALNA_WARTOSC_ZMIENNEJ 90
#define MAKSYMALNA_ILOSC_KLAS 100
#define MAKSYMALNA_ILOSC_ITEMOW 120
#define MINIMALNA_ILOSC_GRACZY 2

#define MNOZNIK_OBRAZEN 0.003
#define MNOZNIK_WYTRZYMALOSCI 0.002
#define MNOZNIK_KONDYCJI 0.004

#define IsPlayer(%1) (1<=%1<=MAXPLAYERS)

new Handle:sql,
	Handle:hud_task[65],
	Handle:zapis_task[65],
	Handle:cvar_doswiadczenie_za_zabojstwo,
	Handle:cvar_doswiadczenie_za_zabojstwo_hs,
	Handle:cvar_doswiadczenie_za_asyste,
	Handle:cvar_doswiadczenie_za_zemste,
	Handle:cvar_doswiadczenie_za_obrazenia,
	Handle:cvar_doswiadczenie_za_wygrana_runde,
	Handle:cvar_doswiadczenie_za_cele_mapy,
	Handle:cvar_limit_poziomu,
	Handle:cvar_proporcja_poziomu,
	Handle:cvar_proporcja_punktow,
	Handle:cvar_limit_inteligencji,
	Handle:cvar_limit_zdrowia,
	Handle:cvar_limit_obrazen,
	Handle:cvar_limit_wytrzymalosci,
	Handle:cvar_limit_kondycji,
	Handle:cvar_wytrzymalosc_itemow,
	Handle:cvar_max_wytrzymalosc_itemow,
	bool:freezetime;
	
new String:frakcje_klas[MAKSYMALNA_ILOSC_KLAS+1][64];

new bool:wczytane_dane[65],
	nowa_klasa_gracza[65],
	klasa_gracza[65],
	zdobyty_poziom_gracza[65],
	poziom_gracza[65],
	zdobyte_doswiadczenie_gracza[65],
	doswiadczenie_gracza[65],
	item_gracza[2][65],
	wartosc_itemu_gracza[2][65],
	wytrzymalosc_itemu_gracza[2][65];

new rozdane_punkty_gracza[65],
	punkty_gracza[65],
	zdobyta_inteligencja_gracza[65],
	inteligencja_gracza[65],
	zdobyte_zdrowie_gracza[65],
	zdrowie_gracza[65],
	zdobyte_obrazenia_gracza[65],
	obrazenia_gracza[65],
	zdobyta_wytrzymalosc_gracza[65],
	wytrzymalosc_gracza[65],
	zdobyta_kondycja_gracza[65],
	kondycja_gracza[65];

new String:bonusowe_bronie_gracza[65][256],
	bonusowa_inteligencja_gracza[65],
	bonusowe_zdrowie_gracza[65],
	bonusowe_obrazenia_gracza[65],
	bonusowa_wytrzymalosc_gracza[65],
	bonusowa_kondycja_gracza[65];

new maksymalna_inteligencja_gracza[65],
	maksymalne_zdrowie_gracza[65],
	Float:maksymalne_obrazenia_gracza[65],
	Float:maksymalna_wytrzymalosc_gracza[65],
	Float:maksymalna_kondycja_gracza[65];

new lvl_klasy_gracza[65][MAKSYMALNA_ILOSC_KLAS+1],
	xp_klasy_gracza[65][MAKSYMALNA_ILOSC_KLAS+1],
	int_klasy_gracza[65][MAKSYMALNA_ILOSC_KLAS+1],
	zdr_klasy_gracza[65][MAKSYMALNA_ILOSC_KLAS+1],
	obr_klasy_gracza[65][MAKSYMALNA_ILOSC_KLAS+1],
	wyt_klasy_gracza[65][MAKSYMALNA_ILOSC_KLAS+1],
	kon_klasy_gracza[65][MAKSYMALNA_ILOSC_KLAS+1];

new String:nazwy_klas[MAKSYMALNA_ILOSC_KLAS+1][64],
	String:opisy_klas[MAKSYMALNA_ILOSC_KLAS+1][128],
	String:bronie_klas[MAKSYMALNA_ILOSC_KLAS+1][512],
	inteligencja_klas[MAKSYMALNA_ILOSC_KLAS+1], 
	zdrowie_klas[MAKSYMALNA_ILOSC_KLAS+1],
	obrazenia_klas[MAKSYMALNA_ILOSC_KLAS+1],
	wytrzymalosc_klas[MAKSYMALNA_ILOSC_KLAS+1],
	kondycja_klas[MAKSYMALNA_ILOSC_KLAS+1],
	Handle:pluginy_klas[MAKSYMALNA_ILOSC_KLAS+1],
	ilosc_klas;

new String:nazwy_itemow[MAKSYMALNA_ILOSC_ITEMOW+1][64],
	String:opisy_itemow[MAKSYMALNA_ILOSC_ITEMOW+1][128],
	max_wartosci_itemow[MAKSYMALNA_ILOSC_ITEMOW+1],
	min_wartosci_itemow[MAKSYMALNA_ILOSC_ITEMOW+1],
	Handle:pluginy_itemow[MAKSYMALNA_ILOSC_ITEMOW+1],
	ilosc_itemow;

new String:bronie_dozwolone[][] = {"weapon_knife", "weapon_c4"},
	punkty_statystyk[] = {1, 10, 25, 50, -1};

public Plugin:myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};
public OnPluginStart()
{
	CreateConVar(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	cvar_doswiadczenie_za_zabojstwo = CreateConVar("cod_xp_kill", "800");
	cvar_doswiadczenie_za_zabojstwo_hs = CreateConVar("cod_xp_killhs", "360");
	cvar_doswiadczenie_za_asyste = CreateConVar("cod_xp_assist", "140");
	cvar_doswiadczenie_za_zemste = CreateConVar("cod_xp_revenge", "220");
	cvar_doswiadczenie_za_obrazenia = CreateConVar("cod_xp_damage", "2");
	cvar_doswiadczenie_za_wygrana_runde = CreateConVar("cod_xp_winround", "150");
	cvar_doswiadczenie_za_cele_mapy = CreateConVar("cod_xp_objectives", "400");
	cvar_limit_poziomu = CreateConVar("cod_max_level", "201");
	cvar_proporcja_poziomu = CreateConVar("cod_level_ratio", "35");
	cvar_proporcja_punktow = CreateConVar("cod_points_level", "2");
	cvar_limit_inteligencji = CreateConVar("cod_max_intelligence", "30");
	cvar_limit_zdrowia = CreateConVar("cod_max_health", "50");
	cvar_limit_obrazen = CreateConVar("cod_max_damage", "40");
	cvar_limit_wytrzymalosci = CreateConVar("cod_max_stamina", "60");
	cvar_limit_kondycji = CreateConVar("cod_max_trim", "80");
	cvar_wytrzymalosc_itemow = CreateConVar("cod_item_stamina", "20");
	cvar_max_wytrzymalosc_itemow = CreateConVar("cod_item_max_stamina", "100");

	RegConsoleCmd("klasa", WybierzKlase);
	RegConsoleCmd("class", WybierzKlase);
	RegConsoleCmd("klasy", OpisKlas);
	RegConsoleCmd("classinfo", OpisKlas);
	RegConsoleCmd("items", OpisItemow);
	RegConsoleCmd("perks", OpisItemow);
	RegConsoleCmd("perki", OpisItemow);
	RegConsoleCmd("item", OpisItemu);
	RegConsoleCmd("perk", OpisItemu);
	RegConsoleCmd("p", OpisItemu);
	RegConsoleCmd("wyrzuc", WyrzucItem);
	RegConsoleCmd("d", WyrzucItem);
	// START: DRUGI PERK
	RegConsoleCmd("item2", OpisItemu2);
	RegConsoleCmd("perk2", OpisItemu2);
	RegConsoleCmd("p2", OpisItemu2);
	RegConsoleCmd("wyrzuc2", WyrzucItem2);
	RegConsoleCmd("d2", WyrzucItem2);
	RegConsoleCmd("useitem2", UzyjItemu2);
	RegConsoleCmd("useperk2", UzyjItemu2);
	RegConsoleCmd("Use_Perk2", UzyjItemu2);
	// KONIEC: DRUGI PERK
	RegConsoleCmd("useclass", UzyjKlasy);
	RegConsoleCmd("useskill", UzyjKlasy);
	RegConsoleCmd("Use_Class", UzyjKlasy);
	RegConsoleCmd("useitem", UzyjItemu);
	RegConsoleCmd("useperk", UzyjItemu);
	RegConsoleCmd("Use_Perk", UzyjItemu);
	RegConsoleCmd("statystyki", PrzydzielPunkty);
	RegConsoleCmd("staty", PrzydzielPunkty);
	RegConsoleCmd("s", PrzydzielPunkty);
	RegConsoleCmd("reset", ResetujPunkty);
	RegConsoleCmd("r", ResetujPunkty);

	RegConsoleCmd("buy", BlokujKomende);
	RegConsoleCmd("buyequip", BlokujKomende);
	RegConsoleCmd("buyammo1", BlokujKomende);
	RegConsoleCmd("buyammo2", BlokujKomende);
	RegConsoleCmd("rebuy", BlokujKomende);
	RegConsoleCmd("autobuy", BlokujKomende);

	HookEvent("round_freeze_end", PoczatekRundy);
	HookEvent("round_start", NowaRunda);
	HookEvent("round_end", KoniecRundy);

	HookEvent("hostage_rescued", ZakladnikUratowany);
	HookEvent("bomb_defused", BombaRozbrojona);
	HookEvent("bomb_planted", BombaPodlozona);

	HookEvent("player_spawn", OdrodzenieGracza);
	HookEvent("player_death", SmiercGracza);

	HookUserMessage(GetUserMessageId("TextMsg"), TextMessage, true);
	LoadTranslations("common.phrases");

	nazwy_klas[0] = "Brak";
	opisy_klas[0] = "Brak dodatkowych uzdolnień";
	bronie_klas[0] = "";
	inteligencja_klas[0] = 0;
	zdrowie_klas[0] = 100;
	obrazenia_klas[0] = 0;
	wytrzymalosc_klas[0] = 0;
	kondycja_klas[0] = 100;

	nazwy_itemow[0] = "Brak";
	opisy_itemow[0] = "Zabij kogoś, aby otrzymać perk";
}
public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("cod_set_user_bonus_weapons", UstawBonusoweBronie);
	CreateNative("cod_get_user_bonus_weapons", PobierzBonusoweBronie);

	CreateNative("cod_set_user_bonus_intelligence", UstawBonusowaInteligencje);
	CreateNative("cod_set_user_bonus_health", UstawBonusoweZdrowie);
	CreateNative("cod_set_user_bonus_damage", UstawBonusoweObrazenia);
	CreateNative("cod_set_user_bonus_stamina", UstawBonusowaWytrzymalosc);
	CreateNative("cod_set_user_bonus_trim", UstawBonusowaKondycje);

	CreateNative("cod_get_user_intelligence", PobierzInteligencje);
	CreateNative("cod_get_user_health", PobierzZdrowie);
	CreateNative("cod_get_user_damage", PobierzObrazenia);
	CreateNative("cod_get_user_stamina", PobierzWytrzymalosc);
	CreateNative("cod_get_user_trim", PobierzKondycje);
	CreateNative("cod_get_user_points", PobierzPunkty);

	CreateNative("cod_get_user_maks_intelligence", PobierzMaksymalnaInteligencje);
	CreateNative("cod_get_user_maks_health", PobierzMaksymalneZdrowie);
	CreateNative("cod_get_user_maks_damage", PobierzMaksymalneObrazenia);
	CreateNative("cod_get_user_maks_stamina", PobierzMaksymalnaWytrzymalosc);
	CreateNative("cod_get_user_maks_trim", PobierzMaksymalnaKondycje);

	CreateNative("cod_set_user_xp", UstawDoswiadczenie);
	CreateNative("cod_set_user_class", UstawKlase);
	CreateNative("cod_set_user_item", UstawItem);

	CreateNative("cod_get_user_xp", PobierzDoswiadczenie);
	CreateNative("cod_get_level_xp", PobierzDoswiadczeniePoziomu);
	CreateNative("cod_get_user_level", PobierzPoziom);
	CreateNative("cod_get_user_level_all", PobierzCalkowityPoziom);
	CreateNative("cod_get_user_class", PobierzKlase);
	CreateNative("cod_get_user_item", PobierzItem);
	CreateNative("cod_get_user_item_skill", PobierzWartoscItemu);
	CreateNative("cod_get_user_item_stamina", PobierzWytrzymaloscItemu);

	CreateNative("cod_get_classes_num", PobierzIloscKlas);
	CreateNative("cod_get_classid", PobierzKlasePrzezNazwe);
	CreateNative("cod_get_class_name", PobierzNazweKlasy);
	CreateNative("cod_get_class_desc", PobierzOpisKlasy);
	CreateNative("cod_get_class_weapon", PobierzBronieKlasy);
	CreateNative("cod_get_class_intelligence", PobierzInteligencjeKlasy);
	CreateNative("cod_get_class_health", PobierzZdrowieKlasy);
	CreateNative("cod_get_class_damage", PobierzObrazeniaKlasy);
	CreateNative("cod_get_class_stamina", PobierzWytrzymaloscKlasy);
	CreateNative("cod_get_class_trim", PobierzKondycjeKlasy);

	CreateNative("cod_get_items_num", PobierzIloscItemow);
	CreateNative("cod_get_itemid", PobierzItemPrzezNazwe);
	CreateNative("cod_get_item_name", PobierzNazweItemu);
	CreateNative("cod_get_item_desc", PobierzOpisItemu);

	CreateNative("cod_inflict_damage", ZadajObrazenia);
	CreateNative("cod_register_class", ZarejestrujKlase);
	CreateNative("cod_register_item", ZarejestrujItem);
}
public OnMapStart()
{
	AddFileToDownloadsTable("sound/cod/levelup.mp3");

	new String:file[256];
	BuildPath(Path_SM, file, sizeof(file), "configs/frakcje.txt");
	new Handle:kv = CreateKeyValues("Frakcje");
	FileToKeyValues(kv, file);
	for(new i = 1; i <= ilosc_klas; i ++)
	{
		KvGetString(kv, nazwy_klas[i], frakcje_klas[i], sizeof(frakcje_klas[]));
		TrimString(frakcje_klas[i]);
	}

	CloseHandle(kv);

	AutoExecConfig(true, "codmod");
	DataBaseConnect();
}
public OnClientAuthorized(client)
{
	UsunUmiejetnosci(client);
	UsunZadania(client);
}
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_WeaponCanUse, WeaponCanUse);
	WczytajDane(client);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKUnhook(client, SDKHook_WeaponCanUse, WeaponCanUse);

	ZapiszDane_Handler(client);
	UsunUmiejetnosci(client);
	UsunZadania(client);
}
public Action:UsunUmiejetnosci(client)
{
	for(new i = 0; i <= ilosc_klas; i ++)
	{
		lvl_klasy_gracza[client][i] = 1;
		xp_klasy_gracza[client][i] = 0;
		int_klasy_gracza[client][i] = 0;
		zdr_klasy_gracza[client][i] = 0;
		obr_klasy_gracza[client][i] = 0;
		wyt_klasy_gracza[client][i] = 0;
		kon_klasy_gracza[client][i] = 0;
	}

	wczytane_dane[client] = false;
	rozdane_punkty_gracza[client] = 0;

	bonusowe_bronie_gracza[client] = "";
	bonusowa_inteligencja_gracza[client] = 0;
	bonusowe_zdrowie_gracza[client] = 0;
	bonusowe_obrazenia_gracza[client] = 0;
	bonusowa_wytrzymalosc_gracza[client] = 0;
	bonusowa_kondycja_gracza[client] = 0;

	nowa_klasa_gracza[client] = 0;
	UstawNowaKlase(client);
	UstawNowyItem(client, 0, 0, 0, 0);
	UstawNowyItem(client, 0, 0, 0, 1);
}
public Action:UsunZadania(client)
{
	if(hud_task[client] != null)
	{
		KillTimer(hud_task[client]);
		hud_task[client] = null;
	}
	if(zapis_task[client] != null)
	{
		KillTimer(zapis_task[client]);
		zapis_task[client] = null;
	}
}
public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(client) || !IsValidClient(attacker))
		return Plugin_Continue;

	if(GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;

	if(klasa_gracza[attacker])
	{
		new doswiadczenie_za_obrazenia = GetConVarInt(cvar_doswiadczenie_za_obrazenia);
		if(doswiadczenie_za_obrazenia)
		{
			new wartosc_obrazen = 20;
			new obrazenia = RoundFloat(damage);
			if(obrazenia >= wartosc_obrazen)
			{
				new doswiadczenie = doswiadczenie_za_obrazenia*(obrazenia/wartosc_obrazen);
				UstawNoweDoswiadczenie(attacker, doswiadczenie_gracza[attacker]+doswiadczenie);
			}
		}
	}

	damage = damage*(1.0+(maksymalne_obrazenia_gracza[attacker]-maksymalna_wytrzymalosc_gracza[client]));
	return Plugin_Changed;
}
public Action:WeaponCanUse(client, weapon)
{
	if(!IsValidClient(client) || !IsPlayerAlive(client))
		return Plugin_Continue;

	new String:weapons[32];
	GetEdictClassname(weapon, weapons, sizeof(weapons));
	new weaponindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	switch(weaponindex)
	{
		case 23: strcopy(weapons, sizeof(weapons), "weapon_mp5sd");
		case 60: strcopy(weapons, sizeof(weapons), "weapon_m4a1_silencer");
		case 61: strcopy(weapons, sizeof(weapons), "weapon_usp_silencer");
		case 63: strcopy(weapons, sizeof(weapons), "weapon_cz75a");
		case 64: strcopy(weapons, sizeof(weapons), "weapon_revolver");
		case 500: strcopy(weapons, sizeof(weapons), "weapon_bayonet");
		case 505: strcopy(weapons, sizeof(weapons), "weapon_knife_flip");
		case 506: strcopy(weapons, sizeof(weapons), "weapon_knife_gut");
		case 507: strcopy(weapons, sizeof(weapons), "weapon_knife_karambit");
		case 508: strcopy(weapons, sizeof(weapons), "weapon_knife_m9_bayonet");
		case 509: strcopy(weapons, sizeof(weapons), "weapon_knife_tactical");
		case 512: strcopy(weapons, sizeof(weapons), "weapon_knife_falchion");
		case 514: strcopy(weapons, sizeof(weapons), "weapon_knife_survival_bowie");
		case 515: strcopy(weapons, sizeof(weapons), "weapon_knife_butterfly");
		case 516: strcopy(weapons, sizeof(weapons), "weapon_knife_push");
	}

	new String:weaponsclass[10][32];
	ExplodeString(bronie_klas[klasa_gracza[client]], "#", weaponsclass, sizeof(weaponsclass), sizeof(weaponsclass[]));
	for(new i = 0; i < sizeof(weaponsclass); i ++)
	{
		if(StrEqual(weaponsclass[i], weapons))
			return Plugin_Continue;
	}

	new String:weaponsbonus[5][32];
	ExplodeString(bonusowe_bronie_gracza[client], "#", weaponsbonus, sizeof(weaponsbonus), sizeof(weaponsbonus[]));
	for(new i = 0; i < sizeof(weaponsbonus); i ++)
	{
		if(StrEqual(weaponsbonus[i], weapons))
			return Plugin_Continue;
	}

	for(new i = 0; i < sizeof(bronie_dozwolone); i ++)
	{
		if(StrEqual(bronie_dozwolone[i], weapons))
			return Plugin_Continue;
	}

	return Plugin_Handled;
}
public Action:PoczatekRundy(Handle:event, const String:name[], bool:dontbroadcast)
{
	freezetime = false;
}
public Action:NowaRunda(Handle:event, const String:name[], bool:dontbroadcast)
{
	freezetime = true;
}
public Action:KoniecRundy(Handle:event, const String:name[], bool:dontbroadcast)
{
	if(IsValidPlayers() < MINIMALNA_ILOSC_GRACZY)
		return Plugin_Continue;

	new doswiadczenie_za_wygrana_runde = GetConVarInt(cvar_doswiadczenie_za_wygrana_runde);
	if(doswiadczenie_za_wygrana_runde)
	{
		new wygrana_druzyna = GetEventInt(event, "winner");
		for(new i = 1; i <= MaxClients; i ++)
		{
			if(!IsClientInGame(i) || !klasa_gracza[i])
				continue;

			if(GetClientTeam(i) != ((wygrana_druzyna == 2)? CS_TEAM_T: CS_TEAM_CT))
				continue;

			if(IsPlayerAlive(i))
			{
				UstawNoweDoswiadczenie(i, doswiadczenie_gracza[i]+doswiadczenie_za_wygrana_runde);
				PrintToChat(i, " \x06\x04[COD:MW]\x01 Dostałeś\x06 %i \x01doświadczenia za wygranie rundy.", doswiadczenie_za_wygrana_runde);
			}
			else
			{
				UstawNoweDoswiadczenie(i, doswiadczenie_gracza[i]+doswiadczenie_za_wygrana_runde/2);
				PrintToChat(i, " \x06\x04[COD:MW]\x01 Dostałeś\x06 %i \x01doświadczenia za wygranie rundy przez twoją drużynę.", doswiadczenie_za_wygrana_runde/2);
			}
		}
	}

	return Plugin_Continue;
}
public Action:ZakladnikUratowany(Handle:event, const String:name[], bool:dontbroadcast)
{
	if(IsValidPlayers() < MINIMALNA_ILOSC_GRACZY)
		return Plugin_Continue;

	new doswiadczenie_za_cele_mapy = GetConVarInt(cvar_doswiadczenie_za_cele_mapy);
	if(doswiadczenie_za_cele_mapy)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		for(new i = 1; i <= MaxClients; i ++)
		{
			if(!IsClientInGame(i) || !klasa_gracza[i])
				continue;

			if(GetClientTeam(i) != CS_TEAM_CT)
				continue;

			if(i == client)
			{
				UstawNoweDoswiadczenie(i, doswiadczenie_gracza[i]+doswiadczenie_za_cele_mapy);
				PrintToChat(i, " \x06\x04[COD:MW]\x01 Dostałeś\x06 %i \x01doświadczenia za uratowanie zakładnika.", doswiadczenie_za_cele_mapy);
			}
			else
			{
				UstawNoweDoswiadczenie(i, doswiadczenie_gracza[i]+doswiadczenie_za_cele_mapy/2);
				PrintToChat(i, " \x06\x04[COD:MW]\x01 Dostałeś\x06 %i \x01doświadczenia za uratowanie zakładnika przez twoją drużynę.", doswiadczenie_za_cele_mapy/2);
			}
		}
	}

	return Plugin_Continue;
}
public Action:BombaRozbrojona(Handle:event, const String:name[], bool:dontbroadcast)
{
	if(IsValidPlayers() < MINIMALNA_ILOSC_GRACZY)
		return Plugin_Continue;

	new doswiadczenie_za_cele_mapy = GetConVarInt(cvar_doswiadczenie_za_cele_mapy);
	if(doswiadczenie_za_cele_mapy)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		for(new i = 1; i <= MaxClients; i ++)
		{
			if(!IsClientInGame(i) || !klasa_gracza[i])
				continue;

			if(GetClientTeam(i) != CS_TEAM_CT)
				continue;

			if(i == client)
			{
				UstawNoweDoswiadczenie(i, doswiadczenie_gracza[i]+doswiadczenie_za_cele_mapy);
				PrintToChat(i, " \x06\x04[COD:MW]\x01 Dostałeś\x06 %i \x01doświadczenia za rozbrojenie bomby.", doswiadczenie_za_cele_mapy);
			}
			else
			{
				UstawNoweDoswiadczenie(i, doswiadczenie_gracza[i]+doswiadczenie_za_cele_mapy/2);
				PrintToChat(i, " \x06\x04[COD:MW]\x01 Dostałeś\x06 %i \x01doświadczenia za rozbrojenie bomby przez twoją drużynę.", doswiadczenie_za_cele_mapy/2);
			}
		}
	}

	return Plugin_Continue;
}
public Action:BombaPodlozona(Handle:event, const String:name[], bool:dontbroadcast)
{
	if(IsValidPlayers() < MINIMALNA_ILOSC_GRACZY)
		return Plugin_Continue;

	new doswiadczenie_za_cele_mapy = GetConVarInt(cvar_doswiadczenie_za_cele_mapy);
	if(doswiadczenie_za_cele_mapy)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		for(new i = 1; i <= MaxClients; i ++)
		{
			if(!IsClientInGame(i) || !klasa_gracza[i])
				continue;

			if(GetClientTeam(i) != CS_TEAM_T)
				continue;

			if(i == client)
			{
				UstawNoweDoswiadczenie(i, doswiadczenie_gracza[i]+doswiadczenie_za_cele_mapy);
				PrintToChat(i, " \x06\x04[COD:MW]\x01 Dostałeś\x06 %i \x01doświadczenia za podłożenie bomby.", doswiadczenie_za_cele_mapy);
			}
			else
			{
				UstawNoweDoswiadczenie(i, doswiadczenie_gracza[i]+doswiadczenie_za_cele_mapy/2);
				PrintToChat(i, " \x06\x04[COD:MW]\x01 Dostałeś\x06 %i \x01doświadczenia za podłożenie bomby przez twoją drużynę.", doswiadczenie_za_cele_mapy/2);
			}
		}
	}

	return Plugin_Continue;
}
public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client))
		return Plugin_Continue;

	if(hud_task[client] == null)
		hud_task[client] = CreateTimer(0.5, PokazInformacje, client, TIMER_FLAG_NO_MAPCHANGE);

	if(zapis_task[client] == null)
		zapis_task[client] = CreateTimer(30.0, ZapiszDane, client, TIMER_FLAG_NO_MAPCHANGE);

	if(nowa_klasa_gracza[client])
		UstawNowaKlase(client);

	if(!klasa_gracza[client])
		WybierzKlase(client, 0);
	else if(punkty_gracza[client])
		PrzydzielPunkty(client, 0);

	ZastosujAtrybuty(client);
	DajBronie(client);

	return Plugin_Continue;
}
public Action:SmiercGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new killer = GetClientOfUserId(GetEventInt(event, "attacker"));
	new assister = GetClientOfUserId(GetEventInt(event, "assister"));
	new bool:headshot = GetEventBool(event, "headshot");
	new bool:revenge = GetEventBool(event, "revenge");
	if(!IsValidClient(client) || !IsValidClient(killer) || !IsValidClient(assister))
		return Plugin_Continue;

	if(klasa_gracza[killer] && GetClientTeam(client) != GetClientTeam(killer))
	{
		if(headshot)
		{
			new doswiadczenie_za_zabojstwo_hs = GetConVarInt(cvar_doswiadczenie_za_zabojstwo_hs);
			if(doswiadczenie_za_zabojstwo_hs)
			{
				UstawNoweDoswiadczenie(killer, doswiadczenie_gracza[killer]+doswiadczenie_za_zabojstwo_hs);
				PrintToChat(killer, " \x06\x04[COD:MW]\x01 Otrzymałeś\x06 %i \x01doświadczenia za zabicie przeciwnika w głowę.", doswiadczenie_za_zabojstwo_hs);
			}
		}
		else
		{
			new doswiadczenie_za_zabojstwo = GetConVarInt(cvar_doswiadczenie_za_zabojstwo);
			if(doswiadczenie_za_zabojstwo)
			{
				UstawNoweDoswiadczenie(killer, doswiadczenie_gracza[killer]+doswiadczenie_za_zabojstwo);
				PrintToChat(killer, " \x06\x04[COD:MW]\x01 Otrzymałeś\x06 %i \x01doświadczenia za zabicie przeciwnika.", doswiadczenie_za_zabojstwo);
			}
		}
		if(revenge) {
			new doswiadczenie_za_zemste = GetConVarInt(cvar_doswiadczenie_za_zemste);
			if(doswiadczenie_za_zemste)
			{
				UstawNoweDoswiadczenie(killer, doswiadczenie_gracza[killer]+doswiadczenie_za_zemste);
				PrintToChat(killer, " \x06\x04[COD:MW]\x01 Otrzymałeś\x06 %i \x01doświadczenia za zemstę.", doswiadczenie_za_zemste);
			}
		}
		if (IsPlayer(assister) && IsClientInGame(assister) && klasa_gracza[assister]) {
			new doswiadczenia_za_asyste = GetConVarInt(cvar_doswiadczenie_za_asyste);
			if(doswiadczenia_za_asyste)
			{
				UstawNoweDoswiadczenie(assister, doswiadczenie_gracza[assister]+doswiadczenia_za_asyste);
				PrintToChat(assister, " \x06\x04[COD:MW]\x01 Otrzymałeś\x06 %i \x01doświadczenia za asyste.", doswiadczenia_za_asyste);
			}
		}
		if(!item_gracza[0][killer])
		{
			UstawNowyItem(killer, -1, -1, -1, 0);
			PrintToChat(killer, " \x06\x04[COD:MW]\x01 Zdobyłeś pierwszy perk:\x06 %s.", nazwy_itemow[item_gracza[0][killer]]);
		}
		else if(GetUserFlagBits(killer) & ADMFLAG_RESERVATION){
			if(!item_gracza[1][killer]){
				UstawNowyItem(killer, -1, -1, -1, 1);
				PrintToChat(killer, " \x06\x04[COD:MW]\x01 Zdobyłeś drugi perk:\x06 %s.", nazwy_itemow[item_gracza[1][killer]]);
			}
		}
	}

	new wytrzymalosc_itemow = GetConVarInt(cvar_wytrzymalosc_itemow);
	if(wytrzymalosc_itemow && wytrzymalosc_itemu_gracza[0][client])
	{
		if(wytrzymalosc_itemu_gracza[0][client] > wytrzymalosc_itemow)
			wytrzymalosc_itemu_gracza[0][client] -= wytrzymalosc_itemow;
		else
		{
			UstawNowyItem(client, 0, 0, 0, 0);
			PrintToChat(client, " \x06\x04[COD:MW]\x01 Twój pierwszy perk uległ zniszczeniu.");
		}
	}
	if(wytrzymalosc_itemow && wytrzymalosc_itemu_gracza[1][client])
	{
		if(wytrzymalosc_itemu_gracza[1][client] > wytrzymalosc_itemow)
			wytrzymalosc_itemu_gracza[1][client] -= wytrzymalosc_itemow;
		else
		{
			UstawNowyItem(client, 0, 0, 0, 1);
			PrintToChat(client, " \x06\x04[COD:MW]\x01 Twój drugi perk uległ zniszczeniu.");
		}
	}

	return Plugin_Continue;
}
public Action:TextMessage(UserMsg:msg_text, Handle:pb, const players[], playersNum, bool:reliable, bool:init)
{
	if(!reliable || PbReadInt(pb, "msg_dst") != 3)
		return Plugin_Continue;

	new String:buffer[256];
	PbReadString(pb, "params", buffer, sizeof(buffer), 0);
	if(StrContains(buffer, "#Player_Cash_Award_") == 0 || StrContains(buffer, "#Team_Cash_Award_") == 0)
		return Plugin_Handled;

	return Plugin_Continue;
}
public Action:WybierzKlase(client, args)
{
	if(wczytane_dane[client])
	{
		lvl_klasy_gracza[client][klasa_gracza[client]] = poziom_gracza[client];	
		xp_klasy_gracza[client][klasa_gracza[client]] = doswiadczenie_gracza[client];
		int_klasy_gracza[client][klasa_gracza[client]] = inteligencja_gracza[client];
		zdr_klasy_gracza[client][klasa_gracza[client]] = zdrowie_gracza[client];
		obr_klasy_gracza[client][klasa_gracza[client]] = obrazenia_gracza[client];
		wyt_klasy_gracza[client][klasa_gracza[client]] = wytrzymalosc_gracza[client];
		kon_klasy_gracza[client][klasa_gracza[client]] = kondycja_gracza[client];

		new Handle:menu = CreateMenu(WybierzKlaseMenu_Handler);
		SetMenuTitle(menu, "Wybierz Typ Klasy:");
		for(new i = 1; i <= ilosc_klas; i ++)
		{
			if(!StrEqual(frakcje_klas[i], "") && !is_in_previous(frakcje_klas[i], i))
				AddMenuItem(menu, frakcje_klas[i], frakcje_klas[i]);
		}

		DisplayMenu(menu, client, 250);
	}
	else
		PrintToChat(client, " \x06\x04[COD:MW]\x01 Trwa wczytywanie twoich danych!");

	return Plugin_Handled;
}
public WybierzKlaseMenu_Handler(Handle:classhandle, MenuAction:action, client, position)
{
	if(action == MenuAction_Select)
	{
		new String:item[64];
		GetMenuItem(classhandle, position, item, sizeof(item));
		position ++;

		new String:menu_item[128];
		new String:numer_klasy[10];
		new Handle:menu = CreateMenu(WybierzKlase_Handler);
		SetMenuTitle(menu, "Wybierz Klase:");
		for(new i = 1; i <= ilosc_klas; i ++)
		{
			if(StrEqual(item, frakcje_klas[i]))
			{
				IntToString(i, numer_klasy, sizeof(numer_klasy));
				Format(menu_item, sizeof(menu_item), "%s (Poziom: %i)", nazwy_klas[i], lvl_klasy_gracza[client][i]);
				AddMenuItem(menu, numer_klasy, menu_item);
			}
		}

		DisplayMenu(menu, client, 250);
	}
	else if(action == MenuAction_End)
		CloseHandle(classhandle);
}
public bool:is_in_previous(const String:frakcja[], from)
{
	for(new i = from - 1; i >= 1; i --)
	{
		if(StrEqual(frakcje_klas[i], frakcja))
			return true;
	}

	return false;
}
public WybierzKlase_Handler(Handle:classhandle, MenuAction:action, client, position)
{
	if(action == MenuAction_Select)
	{
		new String:item[32];
		GetMenuItem(classhandle, position, item, sizeof(item));
		position = StringToInt(item);

		if(position == klasa_gracza[client] && !nowa_klasa_gracza[client])
			return;

		nowa_klasa_gracza[client] = position;
		if(klasa_gracza[client])
			PrintToChat(client, " \x06\x04[COD:MW]\x01 Klasa zostanie zmieniona w nastepnęj rundzie.");
		else
		{
			UstawNowaKlase(client);
			ZastosujAtrybuty(client);
			DajBronie(client);
		}
	}
	else if(action == MenuAction_End)
		CloseHandle(classhandle);
}
public Action:OpisKlas(client, args)
{
	new Handle:menu = CreateMenu(OpisKlas_Handler);
	SetMenuTitle(menu, "Wybierz Klase:");
	for(new i = 1; i <= ilosc_klas; i ++)
		AddMenuItem(menu, "", nazwy_klas[i]);

	DisplayMenu(menu, client, 250);
	return Plugin_Handled;
}
public OpisKlas_Handler(Handle:classhandle, MenuAction:action, client, position)
{
	if(action == MenuAction_Select)
	{
		new String:item[32];
		GetMenuItem(classhandle, position, item, sizeof(item));
		position ++;

		new String:bronie[512];
		Format(bronie, sizeof(bronie), "%s", bronie_klas[position]);
		ReplaceString(bronie, sizeof(bronie), "#weapon_", "|");

		new String:opis[1024];
		new Function:forward_klasy = GetFunctionByName(pluginy_klas[position], "cod_class_skill_used");
		if(forward_klasy != INVALID_FUNCTION)
			Format(opis, sizeof(opis), "Klasa: %s\nInteligencja: %i\nZdrowie: %i\nObrażenia: %i\nWytrzymałość: %i\nKondycja: %i\nBronie: %s\nOpis: %s\nUżycie Umiejętności: useclass", nazwy_klas[position], inteligencja_klas[position], zdrowie_klas[position], obrazenia_klas[position], wytrzymalosc_klas[position], kondycja_klas[position], bronie, opisy_klas[position]);
		else
			Format(opis, sizeof(opis), "Klasa: %s\nInteligencja: %i\nZdrowie: %i\nObrażenia: %i\nWytrzymałość: %i\nKondycja: %i\nBronie: %s\nOpis: %s", nazwy_klas[position], inteligencja_klas[position], zdrowie_klas[position], obrazenia_klas[position], wytrzymalosc_klas[position], kondycja_klas[position], bronie, opisy_klas[position]);

		new Handle:menu = CreateMenu(OpisKlas2_Handler);
		SetMenuTitle(menu, opis);
		AddMenuItem(menu, "", "Lista Klas");
		DisplayMenu(menu, client, 250);
	}
	else if(action == MenuAction_End)
		CloseHandle(classhandle);
}
public OpisKlas2_Handler(Handle:classhandle, MenuAction:action, client, position)
{
	if(action == MenuAction_Select)
		OpisKlas(client, 0);
	else if(action == MenuAction_End)
		CloseHandle(classhandle);
}
public Action:OpisItemow(client, args)
{
	new Handle:menu = CreateMenu(OpisItemow_Handler);
	SetMenuTitle(menu, "Wybierz Item:");
	for(new i = 1; i <= ilosc_itemow; i ++)
		AddMenuItem(menu, "", nazwy_itemow[i]);

	DisplayMenu(menu, client, 250);
	return Plugin_Handled;
}
public OpisItemow_Handler(Handle:classhandle, MenuAction:action, client, position)
{
	if(action == MenuAction_Select)
	{
		new String:item[32];
		GetMenuItem(classhandle, position, item, sizeof(item));
		position ++;

		new String:opis_itemu[128];
		new String:losowa_wartosc[21];
		Format(losowa_wartosc, sizeof(losowa_wartosc), "%i-%i", min_wartosci_itemow[position], max_wartosci_itemow[position]);
		Format(opis_itemu, sizeof(opis_itemu), opisy_itemow[position]);
		ReplaceString(opis_itemu, sizeof(opis_itemu), "LW", losowa_wartosc);

		new String:opis[512];
		new Function:forward_itemu = GetFunctionByName(pluginy_itemow[position], "cod_item_used");
		if(forward_itemu != INVALID_FUNCTION)
			Format(opis, sizeof(opis), "Perk: %s\nOpis: %s\nUżycie Umiejętności: useperk", nazwy_itemow[position], opis_itemu);
		else
			Format(opis, sizeof(opis), "Perk: %s\nOpis: %s", nazwy_itemow[position], opis_itemu);

		new Handle:menu = CreateMenu(OpisItemow_Handler2);
		SetMenuTitle(menu, opis);
		AddMenuItem(menu, "", "Lista Perków");
		DisplayMenu(menu, client, 250);
	}
	else if(action == MenuAction_End)
		CloseHandle(classhandle);
}
public OpisItemow_Handler2(Handle:classhandle, MenuAction:action, client, position)
{
	if(action == MenuAction_Select)
		OpisItemow(client, 0);
	else if(action == MenuAction_End)
		CloseHandle(classhandle);
}
public Action:OpisItemu(client, args)
{
	new String:opis_itemu[128];
	new String:losowa_wartosc[10];
	IntToString(wartosc_itemu_gracza[0][client], losowa_wartosc, sizeof(losowa_wartosc));
	Format(opis_itemu, sizeof(opis_itemu), opisy_itemow[item_gracza[0][client]]);
	ReplaceString(opis_itemu, sizeof(opis_itemu), "LW", losowa_wartosc);

	PrintToChat(client, " \x06\x04[COD:MW]\x01 Perk: %s (%i%%).", nazwy_itemow[item_gracza[0][client]], wytrzymalosc_itemu_gracza[0][client]);
	PrintToChat(client, " \x06\x04[COD:MW]\x01 Opis: %s.", opis_itemu);

	new Function:forward_itemu = GetFunctionByName(pluginy_itemow[item_gracza[0][client]], "cod_item_used");
	if(forward_itemu != INVALID_FUNCTION)
		PrintToChat(client, " \x06\x04[COD:MW]\x01 Użycie Umiejętności: useperk.");

	return Plugin_Handled;
}
public Action:OpisItemu2(client, args)
{
	new String:opis_itemu[128];
	new String:losowa_wartosc[10];
	IntToString(wartosc_itemu_gracza[1][client], losowa_wartosc, sizeof(losowa_wartosc));
	Format(opis_itemu, sizeof(opis_itemu), opisy_itemow[item_gracza[1][client]]);
	ReplaceString(opis_itemu, sizeof(opis_itemu), "LW", losowa_wartosc);

	PrintToChat(client, " \x06\x04[COD:MW]\x01 Perk: %s (%i%%).", nazwy_itemow[item_gracza[1][client]], wytrzymalosc_itemu_gracza[1][client]);
	PrintToChat(client, " \x06\x04[COD:MW]\x01 Opis: %s.", opis_itemu);

	new Function:forward_itemu = GetFunctionByName(pluginy_itemow[item_gracza[1][client]], "cod_item_used");
	if(forward_itemu != INVALID_FUNCTION)
		PrintToChat(client, " \x06\x04[COD:MW]\x01 Użycie Umiejętności: useperk2.");

	return Plugin_Handled;
}
public Action:WyrzucItem(client, args)
{
	if(item_gracza[0][client])
	{
		UstawNowyItem(client, 0, 0, 0, 0);
		PrintToChat(client, " \x06\x04[COD:MW]\x01 Wyrzuciłeś swój pierwszy perk.");
	}
	else
		PrintToChat(client, " \x06\x04[COD:MW]\x01 Nie posiadasz żadnego perku.");

	return Plugin_Handled;
}
public Action:WyrzucItem2(client, args)
{
	if(item_gracza[1][client])
	{
		UstawNowyItem(client, 0, 0, 0, 1);
		PrintToChat(client, " \x06\x04[COD:MW]\x01 Wyrzuciłeś swój drugi perk.");
	}
	else
		PrintToChat(client, " \x06\x04[COD:MW]\x01 Nie posiadasz żadnego perku.");

	return Plugin_Handled;
}
public Action:UzyjKlasy(client, args)
{
	if(!(!IsPlayerAlive(client) || freezetime))
	{
		new Function:forward_klasy = GetFunctionByName(pluginy_klas[klasa_gracza[client]], "cod_class_skill_used");
		if(forward_klasy != INVALID_FUNCTION)
		{
			Call_StartFunction(pluginy_klas[klasa_gracza[client]], forward_klasy);
			Call_PushCell(client);
			Call_PushCell(klasa_gracza[client]);
			Call_Finish();
		}
	}

	return Plugin_Handled;
}
public Action:UzyjItemu(client, args)
{
	if(!(!IsPlayerAlive(client) || freezetime))
	{
		new Function:forward_itemu = GetFunctionByName(pluginy_itemow[item_gracza[0][client]], "cod_item_used");
		if(forward_itemu != INVALID_FUNCTION)
		{
			Call_StartFunction(pluginy_itemow[item_gracza[0][client]], forward_itemu);
			Call_PushCell(client);
			Call_PushCell(item_gracza[0][client]);
			Call_Finish();
		}
	}

	return Plugin_Handled;
}
public Action:UzyjItemu2(client, args)
{
	if(!(!IsPlayerAlive(client) || freezetime))
	{
		new Function:forward_itemu = GetFunctionByName(pluginy_itemow[item_gracza[1][client]], "cod_item_used");
		if(forward_itemu != INVALID_FUNCTION)
		{
			Call_StartFunction(pluginy_itemow[item_gracza[1][client]], forward_itemu);
			Call_PushCell(client);
			Call_PushCell(item_gracza[1][client]);
			Call_Finish();
		}
	}

	return Plugin_Handled;
}
public Action:PrzydzielPunkty(client, args)
{
	new proporcja_punktow = GetConVarInt(cvar_proporcja_punktow);
	if(!proporcja_punktow)
		return Plugin_Continue;

	new limit_inteligencji = GetConVarInt(cvar_limit_inteligencji);
	if(!limit_inteligencji)
		limit_inteligencji = MAKSYMALNA_WARTOSC_ZMIENNEJ;

	new limit_zdrowia = GetConVarInt(cvar_limit_zdrowia);
	if(!limit_zdrowia)
		limit_zdrowia = MAKSYMALNA_WARTOSC_ZMIENNEJ;

	new limit_obrazen = GetConVarInt(cvar_limit_obrazen);
	if(!limit_obrazen)
		limit_obrazen = MAKSYMALNA_WARTOSC_ZMIENNEJ;

	new limit_wytrzymalosci = GetConVarInt(cvar_limit_wytrzymalosci);
	if(!limit_wytrzymalosci)
		limit_wytrzymalosci = MAKSYMALNA_WARTOSC_ZMIENNEJ;

	new limit_kondycji = GetConVarInt(cvar_limit_kondycji);
	if(!limit_kondycji)
		limit_kondycji = MAKSYMALNA_WARTOSC_ZMIENNEJ;

	if(inteligencja_gracza[client] > limit_inteligencji || zdrowie_gracza[client] > limit_zdrowia || obrazenia_gracza[client] > limit_obrazen || wytrzymalosc_gracza[client] > limit_wytrzymalosci || kondycja_gracza[client] > limit_kondycji)
		ResetujPunkty(client, 0);
	else
	{
		new String:opis[128];
		new Handle:menu = CreateMenu(PrzydzielPunkty_Handler);

		Format(opis, sizeof(opis), "Przydziel Punkty (%i):", punkty_gracza[client]);
		SetMenuTitle(menu, opis);

		if(punkty_statystyk[rozdane_punkty_gracza[client]] == -1)
			Format(opis, sizeof(opis), "Ile dodawać: ALL (Po ile punktów dodawać do statystyk)");
		else
			Format(opis, sizeof(opis), "Ile dodawać: %i (Po ile punktów dodawać do statystyk)", punkty_statystyk[rozdane_punkty_gracza[client]]);

		AddMenuItem(menu, "1", opis);

		Format(opis, sizeof(opis), "Inteligencja: %i/%i (Zwiększa sile perków i umiejętności klas)", inteligencja_klas[klasa_gracza[client]]+inteligencja_gracza[client], inteligencja_klas[klasa_gracza[client]]+limit_inteligencji);
		AddMenuItem(menu, "2", opis);

		Format(opis, sizeof(opis), "Zdrowie: %i/%i (Zwiększa zdrowie)", zdrowie_klas[klasa_gracza[client]]+zdrowie_gracza[client], zdrowie_klas[klasa_gracza[client]]+limit_zdrowia);
		AddMenuItem(menu, "3", opis);

		Format(opis, sizeof(opis), "Obrażenia: %i/%i (Zwiększa zadawane obrażenia)", obrazenia_klas[klasa_gracza[client]]+obrazenia_gracza[client], obrazenia_klas[klasa_gracza[client]]+limit_obrazen);
		AddMenuItem(menu, "4", opis);

		Format(opis, sizeof(opis), "Wytrzymałość: %i/%i (Zmniejsza otrzymywane obrażenia)", wytrzymalosc_klas[klasa_gracza[client]]+wytrzymalosc_gracza[client], wytrzymalosc_klas[klasa_gracza[client]]+limit_wytrzymalosci);
		AddMenuItem(menu, "5", opis);

		Format(opis, sizeof(opis), "Kondycja: %i/%i (Zwiększa tempo chodu)", kondycja_klas[klasa_gracza[client]]+kondycja_gracza[client], kondycja_klas[klasa_gracza[client]]+limit_kondycji);
		AddMenuItem(menu, "6", opis);

		DisplayMenu(menu, client, 250);
	}

	return Plugin_Handled;
}
public PrzydzielPunkty_Handler(Handle:classhandle, MenuAction:action, client, position)
{
	if(action == MenuAction_Select)
	{
		if(!punkty_gracza[client])
			return;

		new String:item[32];
		GetMenuItem(classhandle, position, item, sizeof(item));

		new wartosc;
		if(punkty_statystyk[rozdane_punkty_gracza[client]] == -1)
			wartosc = punkty_gracza[client];
		else
			wartosc = (punkty_statystyk[rozdane_punkty_gracza[client]] > punkty_gracza[client])? punkty_gracza[client]: punkty_statystyk[rozdane_punkty_gracza[client]];

		if(StrEqual(item, "1"))
		{
			if(rozdane_punkty_gracza[client] < sizeof(punkty_statystyk)-1)
				rozdane_punkty_gracza[client] ++;
			else
				rozdane_punkty_gracza[client] = 0;
		}
		else if(StrEqual(item, "2"))
		{
			new limit_inteligencji = GetConVarInt(cvar_limit_inteligencji);
			if(!limit_inteligencji)
				limit_inteligencji = MAKSYMALNA_WARTOSC_ZMIENNEJ;

			if(inteligencja_gracza[client] < limit_inteligencji)
			{
				if(inteligencja_gracza[client]+wartosc <= limit_inteligencji)
				{
					zdobyta_inteligencja_gracza[client] += wartosc;
					inteligencja_gracza[client] += wartosc;
					punkty_gracza[client] -= wartosc;
				}
				else
				{
					new punktydodania;
					punktydodania = limit_inteligencji-inteligencja_gracza[client];
					zdobyta_inteligencja_gracza[client] += punktydodania;
					inteligencja_gracza[client] += punktydodania;
					punkty_gracza[client] -= punktydodania;
				}
			}
			else
				PrintToChat(client, " \x06\x04[COD:MW]\x01 Osiągnąłeś już maksymalny poziom inteligencji!");
		}
		else if(StrEqual(item, "3"))
		{
			new limit_zdrowia = GetConVarInt(cvar_limit_zdrowia);
			if(!limit_zdrowia)
				limit_zdrowia = MAKSYMALNA_WARTOSC_ZMIENNEJ;

			if(zdrowie_gracza[client] < limit_zdrowia)
			{
				if(zdrowie_gracza[client]+wartosc <= limit_zdrowia)
				{
					zdobyte_zdrowie_gracza[client] += wartosc;
					zdrowie_gracza[client] += wartosc;
					punkty_gracza[client] -= wartosc;
				}
				else
				{
					new punktydodania;
					punktydodania = limit_zdrowia-zdrowie_gracza[client];
					zdobyte_zdrowie_gracza[client] += punktydodania;
					zdrowie_gracza[client] += punktydodania;
					punkty_gracza[client] -= punktydodania;
				}
			}
			else
				PrintToChat(client, " \x06\x04[COD:MW]\x01 Osiągnąłeś już maksymalny poziom zdrowia!");
		}
		else if(StrEqual(item, "4"))
		{
			new limit_obrazen = GetConVarInt(cvar_limit_obrazen);
			if(!limit_obrazen)
				limit_obrazen = MAKSYMALNA_WARTOSC_ZMIENNEJ;

			if(obrazenia_gracza[client] < limit_obrazen)
			{
				if(obrazenia_gracza[client]+wartosc <= limit_obrazen)
				{
					zdobyte_obrazenia_gracza[client] += wartosc;
					obrazenia_gracza[client] += wartosc;
					punkty_gracza[client] -= wartosc;
				}
				else
				{
					new punktydodania;
					punktydodania = limit_obrazen-obrazenia_gracza[client];
					zdobyte_obrazenia_gracza[client] += punktydodania;
					obrazenia_gracza[client] += punktydodania;
					punkty_gracza[client] -= punktydodania;
				}
			}
			else
				PrintToChat(client, " \x06\x04[COD:MW]\x01 Osiągnąłeś już maksymalny poziom obrażeń!");
		}
		else if(StrEqual(item, "5"))
		{
			new limit_wytrzymalosci = GetConVarInt(cvar_limit_wytrzymalosci);
			if(!limit_wytrzymalosci)
				limit_wytrzymalosci = MAKSYMALNA_WARTOSC_ZMIENNEJ;

			if(wytrzymalosc_gracza[client] < limit_wytrzymalosci)
			{
				if(wytrzymalosc_gracza[client]+wartosc <= limit_wytrzymalosci)
				{
					zdobyta_wytrzymalosc_gracza[client] += wartosc;
					wytrzymalosc_gracza[client] += wartosc;
					punkty_gracza[client] -= wartosc;
				}
				else
				{
					new punktydodania;
					punktydodania = limit_wytrzymalosci-wytrzymalosc_gracza[client];
					zdobyta_wytrzymalosc_gracza[client] += punktydodania;
					wytrzymalosc_gracza[client] += punktydodania;
					punkty_gracza[client] -= punktydodania;
				}
			}
			else
				PrintToChat(client, " \x06\x04[COD:MW]\x01 Osiągnąłeś już maksymalny poziom wytrzymałości!");
		}
		else if(StrEqual(item, "6"))
		{
			new limit_kondycji = GetConVarInt(cvar_limit_kondycji);
			if(!limit_kondycji)
				limit_kondycji = MAKSYMALNA_WARTOSC_ZMIENNEJ;

			if(kondycja_gracza[client] < limit_kondycji)
			{
				if(kondycja_gracza[client]+wartosc <= limit_kondycji)
				{
					zdobyta_kondycja_gracza[client] += wartosc;
					kondycja_gracza[client] += wartosc;
					punkty_gracza[client] -= wartosc;
				}
				else
				{
					new punktydodania;
					punktydodania = limit_kondycji-kondycja_gracza[client];
					zdobyta_kondycja_gracza[client] += punktydodania;
					kondycja_gracza[client] += punktydodania;
					punkty_gracza[client] -= punktydodania;
				}
			}
			else
				PrintToChat(client, " \x06\x04[COD:MW]\x01 Osiągnąłeś już maksymalny poziom kondycji!");
		}
		if(punkty_gracza[client])
			PrzydzielPunkty(client, 0);
	}
	else if(action == MenuAction_End)
		CloseHandle(classhandle);
}
public Action:ResetujPunkty(client, args)
{
	zdobyta_inteligencja_gracza[client] -= inteligencja_gracza[client];
	inteligencja_gracza[client] = 0;

	zdobyte_zdrowie_gracza[client] -= zdrowie_gracza[client];
	zdrowie_gracza[client] = 0;

	zdobyte_obrazenia_gracza[client] -= obrazenia_gracza[client];
	obrazenia_gracza[client] = 0;

	zdobyta_wytrzymalosc_gracza[client] -= wytrzymalosc_gracza[client];
	wytrzymalosc_gracza[client] = 0;

	zdobyta_kondycja_gracza[client] -= kondycja_gracza[client];
	kondycja_gracza[client] = 0;

	punkty_gracza[client] = (GetConVarInt(cvar_proporcja_punktow) < 1)? 0: (poziom_gracza[client]/GetConVarInt(cvar_proporcja_punktow))-inteligencja_gracza[client]-zdrowie_gracza[client]-obrazenia_gracza[client]-wytrzymalosc_gracza[client]-kondycja_gracza[client];
	if(punkty_gracza[client])
		PrzydzielPunkty(client, 0);

	PrintToChat(client, " \x06\x04[COD:MW]\x01 Umiejętności zostały zresetowane.");
	return Plugin_Handled;
}
public Action:BlokujKomende(client, args)
{
	return Plugin_Handled;
}
public Action:ZastosujAtrybuty(client)
{
	if(!IsPlayerAlive(client))
		return Plugin_Continue;

	maksymalna_inteligencja_gracza[client] = (inteligencja_gracza[client]+bonusowa_inteligencja_gracza[client]+inteligencja_klas[klasa_gracza[client]]);
	maksymalne_zdrowie_gracza[client] = 100+(zdrowie_gracza[client]+bonusowe_zdrowie_gracza[client]+zdrowie_klas[klasa_gracza[client]]);
	maksymalne_obrazenia_gracza[client] = (obrazenia_gracza[client]+bonusowe_obrazenia_gracza[client]+obrazenia_klas[klasa_gracza[client]])*MNOZNIK_OBRAZEN;
	maksymalna_wytrzymalosc_gracza[client] = (wytrzymalosc_gracza[client]+bonusowa_wytrzymalosc_gracza[client]+wytrzymalosc_klas[klasa_gracza[client]])*MNOZNIK_WYTRZYMALOSCI;
	maksymalna_kondycja_gracza[client] = 1.0+(kondycja_gracza[client]+bonusowa_kondycja_gracza[client]+kondycja_klas[klasa_gracza[client]])*MNOZNIK_KONDYCJI;

	SetEntData(client, FindDataMapInfo(client, "m_iHealth"), maksymalne_zdrowie_gracza[client]);
	SetEntProp(client, Prop_Send, "m_ArmorValue", wytrzymalosc_gracza[client]+wytrzymalosc_klas[klasa_gracza[client]], 1);
	SetEntProp(client, Prop_Send, "m_bHasHelmet", wytrzymalosc_gracza[client]+wytrzymalosc_klas[klasa_gracza[client]] >= 90 ? 1 : 0);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", maksymalna_kondycja_gracza[client]);

	return Plugin_Continue;
}
public Action:DajBronie(client)
{
	if(!IsPlayerAlive(client))
		return Plugin_Continue;

	new ent = -1;
	for(new slot = 0; slot < 4; slot ++)
	{
		if(slot == 2)
			continue;

		ent = GetPlayerWeaponSlot(client, slot);
		if(ent != -1)
			RemovePlayerItem(client, ent);
	}

	new String:weapons[10][32];
	ExplodeString(bronie_klas[klasa_gracza[client]], "#", weapons, sizeof(weapons), sizeof(weapons[]));
	for(new i = 0; i < sizeof(weapons); i ++)
	{
		if(!StrEqual(weapons[i], ""))
			GivePlayerItem(client, weapons[i]);
	}

	new String:weapons2[5][32];
	ExplodeString(bonusowe_bronie_gracza[client], "#", weapons2, sizeof(weapons2), sizeof(weapons2[]));
	for(new i = 0; i < sizeof(weapons2); i ++)
	{
		if(!StrEqual(weapons2[i], ""))
			GivePlayerItem(client, weapons2[i]);
	}

	return Plugin_Continue;
}
public Action:SprawdzPoziom(client)
{
	if(!klasa_gracza[client])
		return Plugin_Continue;

	new bool:zdobyty_poziom = false;
	new bool:stracony_poziom = false;
	new limit_poziomu = GetConVarInt(cvar_limit_poziomu);
	if(!limit_poziomu)
		limit_poziomu = MAKSYMALNA_WARTOSC_ZMIENNEJ;

	while(doswiadczenie_gracza[client] >= SprawdzDoswiadczenie(poziom_gracza[client]) && poziom_gracza[client] < limit_poziomu)
	{
		zdobyty_poziom_gracza[client] ++;
		poziom_gracza[client] ++;
		zdobyty_poziom = true;
	}
	while(doswiadczenie_gracza[client] < SprawdzDoswiadczenie(poziom_gracza[client]-1))
	{
		zdobyty_poziom_gracza[client] --;
		poziom_gracza[client] --;
		stracony_poziom = true;
	}
	if(poziom_gracza[client] > limit_poziomu)
	{
		zdobyty_poziom_gracza[client] -= (poziom_gracza[client]-limit_poziomu);
		poziom_gracza[client] = limit_poziomu;
		stracony_poziom = true;
	}
	if(stracony_poziom)
		ResetujPunkty(client, 0);
	else if(zdobyty_poziom)
	{
		punkty_gracza[client] = (GetConVarInt(cvar_proporcja_punktow) < 1)? 0: (poziom_gracza[client]/GetConVarInt(cvar_proporcja_punktow))-inteligencja_gracza[client]-zdrowie_gracza[client]-obrazenia_gracza[client]-wytrzymalosc_gracza[client]-kondycja_gracza[client];
		ClientCommand(client, "play *cod/levelup.mp3");
	}

	return Plugin_Continue;
}
public Action:PokazInformacje(Handle:timer, any:client)
{
	if(!IsValidClient(client))
		return;

	if(IsPlayerAlive(client)) {
		if(GetUserFlagBits(client) & ADMFLAG_RESERVATION) {
			PrintHintText(client, "[Klasa: %s]\n[Exp: %i | Poziom: %i]\n[Perk: %s [%i%%]]\n[Perk2: %s [%i%%]]",
			nazwy_klas[klasa_gracza[client]], doswiadczenie_gracza[client], poziom_gracza[client],
			nazwy_itemow[item_gracza[0][client]], wytrzymalosc_itemu_gracza[0][client],
			nazwy_itemow[item_gracza[1][client]], wytrzymalosc_itemu_gracza[1][client]);
		} else {
			PrintHintText(client, "[Klasa: %s]\n[Exp: %i | Poziom: %i]\n[Perk: %s [%i%%]]\n[Perk2: TYLKO VIP]",
			nazwy_klas[klasa_gracza[client]], doswiadczenie_gracza[client], poziom_gracza[client],
			nazwy_itemow[item_gracza[0][client]], wytrzymalosc_itemu_gracza[0][client]);
		}
	}
	else
	{
		new spect = GetEntProp(client, Prop_Send, "m_iObserverMode");
		if(spect == 4 || spect == 5) 
		{
			new target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
			if(target != -1 && IsValidClient(target)) {
				PrintHintText(client, "[Klasa: %s]\n[Exp: %i | Poziom: %i]\n[Perk: %s [%i%%]]\n[Perk2: %s [%i%%]]",
				nazwy_klas[klasa_gracza[target]], doswiadczenie_gracza[target], poziom_gracza[target],
				nazwy_itemow[item_gracza[0][target]], wytrzymalosc_itemu_gracza[0][target],
				nazwy_itemow[item_gracza[1][target]], wytrzymalosc_itemu_gracza[1][target]);
			}
		}
	}

	hud_task[client] = CreateTimer(0.5, PokazInformacje, client, TIMER_FLAG_NO_MAPCHANGE);
}
public Action:DataBaseConnect()
{
	new String:error[128];
	sql = SQL_Connect("codmod_lvl_sql", true, error, sizeof(error));
	if(sql == INVALID_HANDLE)
	{
		LogError("Could not connect: %s", error);
		return Plugin_Continue;
	}

	new String:zapytanie[1024];
	Format(zapytanie, sizeof(zapytanie), "CREATE TABLE IF NOT EXISTS `codmod` (`authid` VARCHAR(48) NOT NULL, `klasa` VARCHAR(64) NOT NULL, `poziom` INT UNSIGNED NOT NULL DEFAULT 1, `doswiadczenie` INT UNSIGNED NOT NULL DEFAULT 1, PRIMARY KEY(`authid`, `klasa`), ");
	StrCat(zapytanie, sizeof(zapytanie), "`inteligencja` INT UNSIGNED NOT NULL DEFAULT 0, `zdrowie` INT UNSIGNED NOT NULL DEFAULT 0, `obrazenia` INT UNSIGNED NOT NULL DEFAULT 0, `wytrzymalosc` INT UNSIGNED NOT NULL DEFAULT 0, `kondycja` INT UNSIGNED NOT NULL DEFAULT 0)");

	SQL_LockDatabase(sql);
	SQL_FastQuery(sql, zapytanie);
	SQL_UnlockDatabase(sql);

	return Plugin_Continue;
}
public Action:ZapiszDane(Handle:timer, any:client)
{
	if(!IsValidClient(client))
		return Plugin_Continue;

	ZapiszDane_Handler(client);
	zapis_task[client] = CreateTimer(30.0, ZapiszDane, client, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Continue;
}
public Action:ZapiszDane_Handler(client)
{
	if(IsFakeClient(client) || !klasa_gracza[client] || !wczytane_dane[client])
		return Plugin_Continue;

	new String:authid[64];
	GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));

	new String:zapytanie[1024];
	Format(zapytanie, sizeof(zapytanie), "UPDATE `codmod` SET `poziom` = (`poziom` + '%i'), `doswiadczenie` = (`doswiadczenie` + '%i'), `inteligencja` = (`inteligencja` + '%i'), `zdrowie` = (`zdrowie` + '%i'), `obrazenia` = (`obrazenia` + '%i'), `wytrzymalosc` = (`wytrzymalosc` + '%i'), `kondycja` = (`kondycja` + '%i') WHERE `authid` = '%s' AND `klasa` = '%s'",
	zdobyty_poziom_gracza[client], zdobyte_doswiadczenie_gracza[client], zdobyta_inteligencja_gracza[client], zdobyte_zdrowie_gracza[client], zdobyte_obrazenia_gracza[client], zdobyta_wytrzymalosc_gracza[client], zdobyta_kondycja_gracza[client], authid, nazwy_klas[klasa_gracza[client]]);
	SQL_TQuery(sql, HandleIgnore, zapytanie, client);

	zdobyty_poziom_gracza[client] = 0;
	lvl_klasy_gracza[client][klasa_gracza[client]] = poziom_gracza[client];

	zdobyte_doswiadczenie_gracza[client] = 0;
	xp_klasy_gracza[client][klasa_gracza[client]] = doswiadczenie_gracza[client];

	zdobyta_inteligencja_gracza[client] = 0;
	int_klasy_gracza[client][klasa_gracza[client]] = inteligencja_gracza[client];

	zdobyte_zdrowie_gracza[client] = 0;
	zdr_klasy_gracza[client][klasa_gracza[client]] = zdrowie_gracza[client];

	zdobyte_obrazenia_gracza[client] = 0;
	obr_klasy_gracza[client][klasa_gracza[client]] = obrazenia_gracza[client];

	zdobyta_wytrzymalosc_gracza[client] = 0;
	wyt_klasy_gracza[client][klasa_gracza[client]] = wytrzymalosc_gracza[client];

	zdobyta_kondycja_gracza[client] = 0;
	kon_klasy_gracza[client][klasa_gracza[client]] = kondycja_gracza[client];

	return Plugin_Continue;
}
public Action:WczytajDane(client)
{
	if(IsClientSourceTV(client))
		return Plugin_Continue;

	if(IsFakeClient(client))
	{
		wczytane_dane[client] = true;
		return Plugin_Continue;
	}

	new String:authid[64];
	GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));

	new String:zapytanie[512];
	Format(zapytanie, sizeof(zapytanie), "SELECT `klasa`, `poziom`, `doswiadczenie`, `inteligencja`, `zdrowie`, `obrazenia`, `wytrzymalosc`, `kondycja` FROM `codmod` WHERE `authid` = '%s'", authid);
	SQL_TQuery(sql, WczytajDane_Handler, zapytanie, client);

	return Plugin_Continue;
}
public WczytajDane_Handler(Handle:owner, Handle:query, const String:error[], any:client)
{
	if(query == INVALID_HANDLE)
	{
		LogError("Load error: %s", error);
		return;
	}
	if(SQL_GetRowCount(query))
	{
		new String:klasa[64];
		while(SQL_MoreRows(query))
		{
			while(SQL_FetchRow(query))
			{
				SQL_FetchString(query, 0, klasa, sizeof(klasa));
				for(new i = 1; i <= ilosc_klas; i ++)
				{
					if(!StrEqual(nazwy_klas[i], klasa))
						continue;

					lvl_klasy_gracza[client][i] = SQL_FetchInt(query, 1);
					xp_klasy_gracza[client][i] = SQL_FetchInt(query, 2);
					int_klasy_gracza[client][i] = SQL_FetchInt(query, 3);
					zdr_klasy_gracza[client][i] = SQL_FetchInt(query, 4);
					obr_klasy_gracza[client][i] = SQL_FetchInt(query, 5);
					wyt_klasy_gracza[client][i] = SQL_FetchInt(query, 6);
					kon_klasy_gracza[client][i] = SQL_FetchInt(query, 7);
					break;
				}
			}
		}
	}

	wczytane_dane[client] = true;
}
public Action:ZmienDane(client)
{
	zdobyty_poziom_gracza[client] = 0;
	poziom_gracza[client] = lvl_klasy_gracza[client][klasa_gracza[client]];

	zdobyte_doswiadczenie_gracza[client] = 0;
	doswiadczenie_gracza[client] = xp_klasy_gracza[client][klasa_gracza[client]];

	zdobyta_inteligencja_gracza[client] = 0;
	inteligencja_gracza[client] = int_klasy_gracza[client][klasa_gracza[client]];

	zdobyte_zdrowie_gracza[client] = 0;
	zdrowie_gracza[client] = zdr_klasy_gracza[client][klasa_gracza[client]];

	zdobyte_obrazenia_gracza[client] = 0;
	obrazenia_gracza[client] = obr_klasy_gracza[client][klasa_gracza[client]];

	zdobyta_wytrzymalosc_gracza[client] = 0;
	wytrzymalosc_gracza[client] = wyt_klasy_gracza[client][klasa_gracza[client]];

	zdobyta_kondycja_gracza[client] = 0;
	kondycja_gracza[client] = kon_klasy_gracza[client][klasa_gracza[client]];

	punkty_gracza[client] = (GetConVarInt(cvar_proporcja_punktow) < 1)? 0: (poziom_gracza[client]/GetConVarInt(cvar_proporcja_punktow))-inteligencja_gracza[client]-zdrowie_gracza[client]-obrazenia_gracza[client]-wytrzymalosc_gracza[client]-kondycja_gracza[client];
	if(!IsFakeClient(client) && wczytane_dane[client] && klasa_gracza[client] && !doswiadczenie_gracza[client])
	{
		new String:authid[64];
		GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));

		new String:zapytanie[512];
		Format(zapytanie, sizeof(zapytanie), "INSERT INTO `codmod` (`authid`, `klasa`) VALUES ('%s', '%s')", authid, nazwy_klas[klasa_gracza[client]]);
		SQL_TQuery(sql, HandleIgnore, zapytanie, client);
		UstawNoweDoswiadczenie(client, doswiadczenie_gracza[client]+1);
	}

	return Plugin_Continue;
}
public HandleIgnore(Handle:owner, Handle:query, const String:error[], any:client)
{
	if(query == INVALID_HANDLE)
	{
		LogError("Save error: %s", error);
		return;
	}
}
public UstawBonusoweBronie(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new String:nazwa[256];
		GetNativeString(2, nazwa, sizeof(nazwa));
		bonusowe_bronie_gracza[client] = nazwa;
	}

	return -1;
}
public PobierzBonusoweBronie(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		SetNativeString(2, bonusowe_bronie_gracza[client], GetNativeCell(3));
		return 1;
	}

	return 0;
}
public UstawBonusowaInteligencje(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new wartosc = GetNativeCell(2);
		maksymalna_inteligencja_gracza[client] += (wartosc-bonusowa_inteligencja_gracza[client]);
		bonusowa_inteligencja_gracza[client] = wartosc;
	}

	return -1;
}
public UstawBonusoweZdrowie(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new wartosc = GetNativeCell(2);
		maksymalne_zdrowie_gracza[client] += (wartosc-bonusowe_zdrowie_gracza[client]);
		if(IsPlayerAlive(client))
		{
			new zdrowie = GetClientHealth(client)+(wartosc-bonusowe_zdrowie_gracza[client]);
			SetEntData(client, FindDataMapInfo(client, "m_iHealth"), (zdrowie < 1)? 1: zdrowie);
		}

		bonusowe_zdrowie_gracza[client] = wartosc;
	}

	return -1;
}
public UstawBonusoweObrazenia(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new wartosc = GetNativeCell(2);
		maksymalne_obrazenia_gracza[client] += float((wartosc-bonusowe_obrazenia_gracza[client]))*MNOZNIK_OBRAZEN;
		bonusowe_obrazenia_gracza[client] = wartosc;
	}

	return -1;
}
public UstawBonusowaWytrzymalosc(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new wartosc = GetNativeCell(2);
		maksymalna_wytrzymalosc_gracza[client] += float((wartosc-bonusowa_wytrzymalosc_gracza[client]))*MNOZNIK_WYTRZYMALOSCI;
		bonusowa_wytrzymalosc_gracza[client] = wartosc;
	}

	return -1;
}
public UstawBonusowaKondycje(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new wartosc = GetNativeCell(2);
		maksymalna_kondycja_gracza[client] += float((wartosc-bonusowa_kondycja_gracza[client]))*MNOZNIK_KONDYCJI;
		if(IsPlayerAlive(client))
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", maksymalna_kondycja_gracza[client]);

		bonusowa_kondycja_gracza[client] = wartosc;
	}

	return -1;
}
public PobierzInteligencje(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new inteligencja;
		if(GetNativeCell(2))
			inteligencja += inteligencja_gracza[client];
		if(GetNativeCell(3))	
			inteligencja += bonusowa_inteligencja_gracza[client];
		if(GetNativeCell(4))
			inteligencja += inteligencja_klas[klasa_gracza[client]];

		return inteligencja;
	}

	return -1;
}
public PobierzZdrowie(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new zdrowie;
		if(GetNativeCell(2))	
			zdrowie += zdrowie_gracza[client];
		if(GetNativeCell(3))
			zdrowie += bonusowe_zdrowie_gracza[client];
		if(GetNativeCell(4))	
			zdrowie += zdrowie_klas[klasa_gracza[client]];

		return zdrowie;
	}

	return -1;
}
public PobierzObrazenia(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new obrazenia;
		if(GetNativeCell(2))
			obrazenia += obrazenia_gracza[client];
		if(GetNativeCell(3))
			obrazenia += bonusowe_obrazenia_gracza[client];
		if(GetNativeCell(4))
			obrazenia += obrazenia_klas[klasa_gracza[client]];

		return obrazenia;
	}

	return -1;
}
public PobierzWytrzymalosc(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new wytrzymalosc;
		if(GetNativeCell(2))
			wytrzymalosc += wytrzymalosc_gracza[client];
		if(GetNativeCell(3))
			wytrzymalosc += bonusowa_wytrzymalosc_gracza[client];
		if(GetNativeCell(4))
			wytrzymalosc += wytrzymalosc_klas[klasa_gracza[client]];

		return wytrzymalosc;
	}

	return -1;
}
public PobierzKondycje(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new kondycja;
		if(GetNativeCell(2))
			kondycja += kondycja_gracza[client];
		if(GetNativeCell(3))
			kondycja += bonusowa_kondycja_gracza[client];
		if(GetNativeCell(4))
			kondycja += kondycja_klas[klasa_gracza[client]];

		return kondycja;
	}

	return -1;
}
public PobierzPunkty(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		return punkty_gracza[client];

	return -1;
}
public PobierzMaksymalnaInteligencje(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		return maksymalna_inteligencja_gracza[client];

	return -1;
}
public PobierzMaksymalneZdrowie(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		return maksymalne_zdrowie_gracza[client];

	return -1;
}
public PobierzMaksymalneObrazenia(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new String:obrazenia[10];
		FloatToString(maksymalne_obrazenia_gracza[client], obrazenia, sizeof(obrazenia));

		SetNativeString(2, obrazenia, GetNativeCell(3));
		return 1;
	}

	return -1;
}
public PobierzMaksymalnaWytrzymalosc(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new String:wytrzymalosc[10];
		FloatToString(maksymalna_wytrzymalosc_gracza[client], wytrzymalosc, sizeof(wytrzymalosc));

		SetNativeString(2, wytrzymalosc, GetNativeCell(3));
		return 1;
	}

	return -1;
}
public PobierzMaksymalnaKondycje(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new String:kondycja[10];
		FloatToString(maksymalna_kondycja_gracza[client], kondycja, sizeof(kondycja));

		SetNativeString(2, kondycja, GetNativeCell(3));
		return 1;
	}

	return -1;
}
public Action:UstawNoweDoswiadczenie(client, doswiadczenie)
{
	new nowe_doswiadczenie = doswiadczenie-doswiadczenie_gracza[client];
	zdobyte_doswiadczenie_gracza[client] += nowe_doswiadczenie;
	doswiadczenie_gracza[client] = nowe_doswiadczenie+doswiadczenie_gracza[client];

	SprawdzPoziom(client);
	return Plugin_Continue;
}
public UstawDoswiadczenie(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		UstawNoweDoswiadczenie(client, GetNativeCell(2));

	return -1;
}
public Action:UstawNowaKlase(client)
{
	if(!ilosc_klas)
		return Plugin_Continue;

	new Function:forward_klasy;
	forward_klasy = GetFunctionByName(pluginy_klas[klasa_gracza[client]], "cod_class_disabled");
	if(forward_klasy != INVALID_FUNCTION)
	{
		Call_StartFunction(pluginy_klas[klasa_gracza[client]], forward_klasy);
		Call_PushCell(client);
		Call_PushCell(klasa_gracza[client]);
		Call_Finish();
	}

	new ret;
	forward_klasy = GetFunctionByName(pluginy_klas[nowa_klasa_gracza[client]], "cod_class_enabled");
	if(forward_klasy != INVALID_FUNCTION)
	{
		Call_StartFunction(pluginy_klas[nowa_klasa_gracza[client]], forward_klasy);
		Call_PushCell(client);
		Call_PushCell(nowa_klasa_gracza[client]);
		Call_Finish(ret);
	}
	if(ret == 4)
	{
		nowa_klasa_gracza[client] = klasa_gracza[client];
		UstawNowaKlase(client);
		return Plugin_Continue;
	}

	ZapiszDane_Handler(client);
	klasa_gracza[client] = nowa_klasa_gracza[client];
	nowa_klasa_gracza[client] = 0;
	ZmienDane(client);

	UstawNowyItem(client, item_gracza[0][client], wartosc_itemu_gracza[0][client], wytrzymalosc_itemu_gracza[0][client], 0);
	UstawNowyItem(client, item_gracza[1][client], wartosc_itemu_gracza[1][client], wytrzymalosc_itemu_gracza[1][client], 1);
	return Plugin_Continue;
}
public UstawKlase(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		nowa_klasa_gracza[client] = GetNativeCell(2);
		if(GetNativeCell(3))
		{
			UstawNowaKlase(client);
			DajBronie(client);
			ZastosujAtrybuty(client);
		}
	}

	return -1;
}
public Action:UstawNowyItem(client, item, wartosc, wytrzymalosc, lp)
{
	if(!ilosc_itemow)
		return Plugin_Continue;

	new limit_wytrzymalosci_itemu = GetConVarInt(cvar_max_wytrzymalosc_itemow);
	if(!limit_wytrzymalosci_itemu)
		limit_wytrzymalosci_itemu = MAKSYMALNA_WARTOSC_ZMIENNEJ;

	item = (item < 0 || item > ilosc_itemow)? GetRandomInt(1, ilosc_itemow): item;
	wartosc = (wartosc < min_wartosci_itemow[item] || wartosc > max_wartosci_itemow[item])? GetRandomInt(min_wartosci_itemow[item], max_wartosci_itemow[item]): wartosc;
	wytrzymalosc = (wytrzymalosc < 0 || wytrzymalosc > limit_wytrzymalosci_itemu)? limit_wytrzymalosci_itemu: wytrzymalosc;

	new Function:forward_itemu;
	forward_itemu = GetFunctionByName(pluginy_itemow[item_gracza[lp][client]], "cod_item_disabled");
	if(forward_itemu != INVALID_FUNCTION)
	{
		Call_StartFunction(pluginy_itemow[item_gracza[lp][client]], forward_itemu);
		Call_PushCell(client);
		Call_PushCell(item_gracza[lp][client]);
		Call_Finish();
	}

	new ret;
	forward_itemu = GetFunctionByName(pluginy_itemow[item], "cod_item_enabled");
	if(forward_itemu != INVALID_FUNCTION)
	{
		Call_StartFunction(pluginy_itemow[item], forward_itemu);
		Call_PushCell(client);
		Call_PushCell(wartosc);
		Call_PushCell(item);
		Call_Finish(ret);
	}

	item_gracza[lp][client] = item;
	wartosc_itemu_gracza[lp][client] = wartosc;
	wytrzymalosc_itemu_gracza[lp][client] = wytrzymalosc;
	if(ret == 4)
		UstawNowyItem(client, -1, -1, -1, lp);

	return Plugin_Continue;
}
public UstawItem(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		UstawNowyItem(client, GetNativeCell(2), GetNativeCell(3), GetNativeCell(4), GetNativeCell(5));

	return -1;
}
public PobierzDoswiadczenie(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		return doswiadczenie_gracza[client];

	return -1;
}
public SprawdzDoswiadczenie(poziom)
{
	new proporcja_poziomu = GetConVarInt(cvar_proporcja_poziomu);
	if(!proporcja_poziomu)
		proporcja_poziomu = 1;

	return RoundFloat(Pow(float(poziom), 2.0))*proporcja_poziomu;
}
public PobierzDoswiadczeniePoziomu(Handle:plugin, numParams)
{
	return SprawdzDoswiadczenie(GetNativeCell(1));
}
public PobierzPoziom(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		return poziom_gracza[client];

	return -1;
}
public PobierzCalkowityPoziom(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new poziom;
		for(new i = 1; i <= ilosc_klas; i ++)
		{
			if(lvl_klasy_gracza[client][i] > poziom)
				poziom = lvl_klasy_gracza[client][i];
		}

		return poziom;
	}

	return -1;
}
public PobierzKlase(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		return klasa_gracza[client];

	return -1;
}
public PobierzItem(Handle:plugin, numParams)
{
	new client = GetNativeCell(1), lp = GetNativeCell(2);
	if(IsValidClient(client))
		return item_gracza[lp][client];

	return -1;
}
public PobierzWartoscItemu(Handle:plugin, numParams)
{
	new client = GetNativeCell(1), lp = GetNativeCell(2);
	if(IsValidClient(client))
		return wartosc_itemu_gracza[lp][client];

	return -1;
}
public PobierzWytrzymaloscItemu(Handle:plugin, numParams)
{
	new client = GetNativeCell(1), lp = GetNativeCell(2);
	if(IsValidClient(client))
		return wytrzymalosc_itemu_gracza[lp][client];

	return -1;
}
public PobierzIloscKlas(Handle:plugin, numParams)
{
	if(ilosc_klas)
		return ilosc_klas;

	return -1;
}
public PobierzKlasePrzezNazwe(Handle:plugin, numParams)
{
	new String:nazwa[64];
	GetNativeString(1, nazwa, sizeof(nazwa));
	for(new i = 1; i <= ilosc_klas; i ++)
	{
		if(StrEqual(nazwa, nazwy_klas[i]))
			return i;
	}

	return -1;
}
public PobierzNazweKlasy(Handle:plugin, numParams)
{
	new klasa = GetNativeCell(1);
	if(klasa <= ilosc_klas)
	{
		SetNativeString(2, nazwy_klas[klasa], GetNativeCell(3));
		return 1;
	}

	return -1;
}
public PobierzOpisKlasy(Handle:plugin, numParams)
{
	new klasa = GetNativeCell(1);
	if(klasa <= ilosc_klas)
	{
		SetNativeString(2, opisy_klas[klasa], GetNativeCell(3));	
		return 1;
	}

	return -1;
}
public PobierzBronieKlasy(Handle:plugin, numParams)
{
	new klasa = GetNativeCell(1);
	if(klasa <= ilosc_klas)
	{
		SetNativeString(2, bronie_klas[klasa], GetNativeCell(3));
		return 1;
	}

	return 0;
}
public PobierzInteligencjeKlasy(Handle:plugin, numParams)
{
	new klasa = GetNativeCell(1);
	if(klasa <= ilosc_klas)
		return inteligencja_klas[klasa];

	return -1;
}
public PobierzZdrowieKlasy(Handle:plugin, numParams)
{
	new klasa = GetNativeCell(1);
	if(klasa <= ilosc_klas)
		return zdrowie_klas[klasa];

	return -1;
}
public PobierzObrazeniaKlasy(Handle:plugin, numParams)
{
	new klasa = GetNativeCell(1);
	if(klasa <= ilosc_klas)
		return obrazenia_klas[klasa];

	return -1;
}
public PobierzWytrzymaloscKlasy(Handle:plugin, numParams)
{
	new klasa = GetNativeCell(1);
	if(klasa <= ilosc_klas)
		return wytrzymalosc_klas[klasa];

	return -1;
}
public PobierzKondycjeKlasy(Handle:plugin, numParams)
{
	new klasa = GetNativeCell(1);
	if(klasa <= ilosc_klas)
		return kondycja_klas[klasa];

	return -1;
}
public PobierzIloscItemow(Handle:plugin, numParams)
{
	if(ilosc_itemow)
		return ilosc_itemow;

	return -1;
}
public PobierzItemPrzezNazwe(Handle:plugin, numParams)
{
	new String:nazwa[64];
	GetNativeString(1, nazwa, sizeof(nazwa));
	for(new i = 1; i <= ilosc_itemow; i ++)
	{
		if(StrEqual(nazwa, nazwy_itemow[i]))
			return i;
	}

	return -1;
}
public PobierzNazweItemu(Handle:plugin, numParams)
{
	new item = GetNativeCell(1);
	if(item <= ilosc_itemow)
	{
		SetNativeString(2, nazwy_itemow[item], GetNativeCell(3));
		return 1;
	}

	return -1;
}
public PobierzOpisItemu(Handle:plugin, numParams)
{
	new item = GetNativeCell(1);
	if(item <= ilosc_itemow)
	{
		SetNativeString(2, opisy_itemow[item], GetNativeCell(3));
		return 1;
	}

	return -1;
}
public ZadajObrazenia(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new attacker = GetNativeCell(2);
	new damage = GetNativeCell(3);

	new Handle:data = CreateDataPack();
	WritePackCell(data, client);
	WritePackCell(data, attacker);
	WritePackCell(data, damage);

	CreateTimer(0.1, ZadajObrazenia_Handler, data, TIMER_FLAG_NO_MAPCHANGE);
	return -1;
}
public Action:ZadajObrazenia_Handler(Handle:timer, Handle:data)
{
	ResetPack(data);
	new client = ReadPackCell(data);
	new attacker = ReadPackCell(data);
	new damage = ReadPackCell(data);
	CloseHandle(data);

	if(IsValidClient(client) && IsPlayerAlive(client) && IsValidClient(attacker))
		SDKHooks_TakeDamage(client, attacker, attacker, float(damage), DMG_GENERIC);

	return Plugin_Continue;
} 

public ZarejestrujKlase(Handle:plugin, numParams)
{
	if(numParams != 8)
		return -1;

	if(++ilosc_klas > MAKSYMALNA_ILOSC_KLAS)
		return -2;

	pluginy_klas[ilosc_klas] = plugin;
	GetNativeString(1, nazwy_klas[ilosc_klas], sizeof(nazwy_klas[]));
	GetNativeString(2, opisy_klas[ilosc_klas], sizeof(opisy_klas[]));
	GetNativeString(3, bronie_klas[ilosc_klas], sizeof(bronie_klas[]));
	inteligencja_klas[ilosc_klas] = GetNativeCell(4);
	zdrowie_klas[ilosc_klas] = GetNativeCell(5);
	obrazenia_klas[ilosc_klas] = GetNativeCell(6);
	wytrzymalosc_klas[ilosc_klas] = GetNativeCell(7);
	kondycja_klas[ilosc_klas] = GetNativeCell(8);
	frakcje_klas[ilosc_klas] = "";

	return ilosc_klas;
}
public ZarejestrujItem(Handle:plugin, numParams)
{
	if(numParams != 4)
		return -1;

	if(++ilosc_itemow > MAKSYMALNA_ILOSC_ITEMOW)
		return -2;

	pluginy_itemow[ilosc_itemow] = plugin;
	GetNativeString(1, nazwy_itemow[ilosc_itemow], sizeof(nazwy_itemow[]));
	GetNativeString(2, opisy_itemow[ilosc_itemow], sizeof(opisy_itemow[]));
	min_wartosci_itemow[ilosc_itemow] = GetNativeCell(3);
	max_wartosci_itemow[ilosc_itemow] = GetNativeCell(4);

	return ilosc_itemow;
}
public IsValidPlayers()
{
	new gracze;
	for(new i = 1; i <= MaxClients; i ++)
	{
		if(!IsClientInGame(i) || IsFakeClient(i))
			continue;

		gracze ++;
	}

	return gracze;
}
public bool:IsValidClient(client)
{
	if(client >= 1 && client <= MaxClients && IsClientInGame(client))
		return true;

	return false;
}