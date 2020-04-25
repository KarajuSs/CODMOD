#include <sourcemod>
#include <codmod>

#define PREFIKS " \x06\x04[COD:MW]\x01"

char NIEMA_GRACZA[] = "%s Nie odnaleziono wybranego gracza!",
	NADAWCA_PERK[] = "%s Wybrany gracz musi posiadać perk by od niego odebrać!",
	WYMAGANY_PERK[] = "%s Musisz posiadać perk aby móc go przekazać!",
	ODBIORCA_BRAK[] = "%s Wybrany gracz nie może posiadać perka aby mu go podarować!",
	WYMAGANY_BRAK[] = "%s Nie możesz posiadać perka aby odebrać podarunek!",
	BRAK_ZGODY[] = "%s Wybrany gracz nie zgodził się na przyjęcie podarunku!",
	PAUZA[] = "%s Musisz odczekać 60 sekund by ponowanie podarować perk!",
	PRZEKAZANIE_GLOBAL[] = "%s Gracz\x09 %s\x01 podarował perk graczowi\x09 %s\x01.";

new String:nazwa_oferujacego[65][32],
	Float:time_gracza[65];

char item[65],
	item_gracza[65],
	item2_gracza[65],
	losowa_wartosc[21],
	opis_itemu[128],
	item_menu[512];

public Plugin:myinfo =
{
	name = "Call of Duty: Oddawanie",
	author = "Linux` edited by KarajuSs",
	description = "Cod Dodatek",
	version = "1.1",
	url = "http://steamcommunity.com/id/linux2006"
};
public OnPluginStart()
{
	RegConsoleCmd("daj", MenuPodarowania);
	RegConsoleCmd("oddaj", MenuPodarowania);
	RegConsoleCmd("podaruj", MenuPodarowania);
}
public OnClientAuthorized(client)
{
	time_gracza[client] = 0.0;
}

public Action:MenuPodarowania(client, args) {
	new Handle:menu = CreateMenu(MenuPodarowaniaPerka_Handler);

	cod_get_item_name(cod_get_user_item(client, 0), item_gracza, sizeof(item_gracza));
	cod_get_item_name(cod_get_user_item(client, 1), item2_gracza, sizeof(item2_gracza));

	SetMenuTitle(menu, "Wybierz, który perk chcesz podarować:");
	AddMenuItem(menu, "1", item_gracza);
	AddMenuItem(menu, "2", item2_gracza);
	DisplayMenu(menu, client, 250);
}
public MenuPodarowaniaPerka_Handler(Handle:classhandle, MenuAction:action, client, Position) {
	if(action == MenuAction_Select) {
		GetMenuItem(classhandle, Position, item, sizeof(item));
		MenuPodarowania(client, 0);

		new target = FindTarget(0, item);
		if(!IsValidClient(target) || target == -1) {
			PrintToChat(client, NIEMA_GRACZA, PREFIKS);
			return;
		}
		if(!cod_get_user_item(client, 0) || !cod_get_user_item(client, 1)) {
			PrintToChat(client, WYMAGANY_PERK, PREFIKS);
			return;
		}

		if(StrEqual(item, "1"))
			OddajItem(client, 0);
		else if(StrEqual(item, "2"))
			OddajItem2(client, 0);
	}
}

public Action:OddajItem(client, args)
{
	new String:name[64];
	new Handle:menu = CreateMenu(OddajItem_Handler);
	SetMenuTitle(menu, "Podaruj I Perk:");
	for(new i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || i == client)
			continue;

		if(IsFakeClient(i) || IsClientSourceTV(i))
			continue;

		GetClientName(i, name, sizeof(name));
		AddMenuItem(menu, name, name);
	}

	DisplayMenu(menu, client, 250);
	return Plugin_Handled;
}
public OddajItem_Handler(Handle:classhandle, MenuAction:action, client, position)
{
	if(action == MenuAction_Select)
	{
		GetMenuItem(classhandle, position, item, sizeof(item));
		position ++;

		new target = FindTarget(0, item);
		if(cod_get_user_item(target, 0)) {
			PrintToChat(client, ODBIORCA_BRAK, PREFIKS);
			return;
		}

		new Float:gametime = GetGameTime();
		if(gametime > time_gracza[client]+60.0)
			time_gracza[client] = gametime;
		else
		{
			PrintToChat(client, PAUZA, PREFIKS);
			return;
		}

		GetClientName(client, nazwa_oferujacego[target], sizeof(nazwa_oferujacego[]));

		cod_get_item_name(cod_get_user_item(client, 0), item_gracza, sizeof(item_gracza));
		IntToString(cod_get_user_item_skill(client, 0), losowa_wartosc, sizeof(losowa_wartosc));
		cod_get_item_desc(cod_get_user_item(client, 0), opis_itemu, sizeof(opis_itemu));

		Format(item_menu, sizeof(item_menu), "Gracz %s zaproponował ci podarowanie I perku:\n \nPerk: %s (%i%%%%)\nOpis: %s",
		nazwa_oferujacego[target], item_gracza, cod_get_user_item_stamina(client, 0), opis_itemu);

		new Handle:menu = CreateMenu(OddajItem_Handler2);
		SetMenuTitle(menu, item_menu);
		AddMenuItem(menu, "1", "Przyjmnij");
		AddMenuItem(menu, "2", "Odrzuć");
		DisplayMenu(menu, target, 250);
	}
	else if(action == MenuAction_End)
		CloseHandle(classhandle);
}
public OddajItem_Handler2(Handle:classhandle, MenuAction:action, client, position)
{
	if(action == MenuAction_Select)
	{
		GetMenuItem(classhandle, position, item, sizeof(item));
		new target = FindTarget(0, nazwa_oferujacego[client]);

		if(StrEqual(item, "1"))
		{
			if(!IsValidClient(target) || target == -1)
			{
				PrintToChat(client, NIEMA_GRACZA, PREFIKS);
				return;
			}
			if(!cod_get_user_item(target, 0))
			{
				PrintToChat(client, NADAWCA_PERK, PREFIKS);
				return;
			}
			if(cod_get_user_item(client, 0))
			{
				PrintToChat(client, WYMAGANY_BRAK, PREFIKS);
				return;
			}

			cod_set_user_item(client, cod_get_user_item(target, 0), cod_get_user_item_skill(target, 0), cod_get_user_item_stamina(target, 0), 0);
			cod_set_user_item(target, 0, 0, 0, 0);

			new String:name[32];
			GetClientName(client, name, sizeof(name));
			PrintToChatAll(PRZEKAZANIE_GLOBAL, PREFIKS, nazwa_oferujacego[client], name);
		}
		else if(StrEqual(item, "2"))
		{
			if(!(!IsValidClient(target) || target == -1))
				PrintToChat(target, BRAK_ZGODY, PREFIKS);
		}
	}
	else if(action == MenuAction_End)
		CloseHandle(classhandle);
}

public Action:OddajItem2(client, args)
{
	new String:name[64];
	new Handle:menu = CreateMenu(OddajItem2_Handler);
	SetMenuTitle(menu, "Podaruj II Perk:");
	for(new i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || i == client)
			continue;

		if(IsFakeClient(i) || IsClientSourceTV(i))
			continue;

		GetClientName(i, name, sizeof(name));
		AddMenuItem(menu, name, name);
	}

	DisplayMenu(menu, client, 250);
	return Plugin_Handled;
}
public OddajItem2_Handler(Handle:classhandle, MenuAction:action, client, position)
{
	if(action == MenuAction_Select)
	{
		GetMenuItem(classhandle, position, item, sizeof(item));
		position ++;

		new target = FindTarget(0, item);
		if(!IsValidClient(target) || target == -1)
		{
			PrintToChat(client, NIEMA_GRACZA, PREFIKS);
			return;
		}
		if(cod_get_user_item(target, 1))
		{
			PrintToChat(client, ODBIORCA_BRAK, PREFIKS);
			return;
		}
		if(!cod_get_user_item(client, 1))
		{
			PrintToChat(client, WYMAGANY_PERK, PREFIKS);
			return;
		}

		new Float:gametime = GetGameTime();
		if(gametime > time_gracza[client]+60.0)
			time_gracza[client] = gametime;
		else
		{
			PrintToChat(client, PAUZA, PREFIKS);
			return;
		}

		GetClientName(client, nazwa_oferujacego[target], sizeof(nazwa_oferujacego[]));

		cod_get_item_name(cod_get_user_item(client, 1), item2_gracza, sizeof(item2_gracza));
		IntToString(cod_get_user_item_skill(client, 1), losowa_wartosc, sizeof(losowa_wartosc));
		cod_get_item_desc(cod_get_user_item(client, 1), opis_itemu, sizeof(opis_itemu));

		Format(item_menu, sizeof(item_menu), "Gracz %s zaproponował ci podarowanie II perku:\n \nPerk: %s (%i%%%%)\nOpis: %s",
		nazwa_oferujacego[target], item2_gracza, cod_get_user_item_stamina(client, 1), opis_itemu);

		new Handle:menu = CreateMenu(OddajItem2_Handler2);
		SetMenuTitle(menu, item_menu);
		AddMenuItem(menu, "1", "Przyjmnij");
		AddMenuItem(menu, "2", "Odrzuć");
		DisplayMenu(menu, target, 250);
	}
	else if(action == MenuAction_End)
		CloseHandle(classhandle);
}
public OddajItem2_Handler2(Handle:classhandle, MenuAction:action, client, position)
{
	if(action == MenuAction_Select)
	{
		GetMenuItem(classhandle, position, item, sizeof(item));
		new target = FindTarget(0, nazwa_oferujacego[client]);

		if(StrEqual(item, "1"))
		{
			if(!IsValidClient(target) || target == -1)
			{
				PrintToChat(client, NIEMA_GRACZA, PREFIKS);
				return;
			}
			if(!cod_get_user_item(target, 1))
			{
				PrintToChat(client, NADAWCA_PERK, PREFIKS);
				return;
			}
			if(cod_get_user_item(client, 1))
			{
				PrintToChat(client, WYMAGANY_BRAK, PREFIKS);
				return;
			}

			cod_set_user_item(client, cod_get_user_item(target, 1), cod_get_user_item_skill(target, 1), cod_get_user_item_stamina(target, 0), 1);
			cod_set_user_item(target, 0, 0, 0, 1);

			new String:name[32];
			GetClientName(client, name, sizeof(name));
			PrintToChatAll(PRZEKAZANIE_GLOBAL, PREFIKS, nazwa_oferujacego[client], name);
		}
		else if(StrEqual(item, "2"))
		{
			if(!(!IsValidClient(target) || target == -1))
				PrintToChat(target, BRAK_ZGODY, PREFIKS);
		}
	}
	else if(action == MenuAction_End)
		CloseHandle(classhandle);
}