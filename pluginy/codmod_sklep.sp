#include <sourcemod>
#include <codmod>
#include <colors>
#include <codmod_monety>

#define PREFIKS " \x06\x04[COD:MW]\x01"

char MALO_MONET[] = "%s Masz za mało monet!",
	MALO_DOLAROW[] = "%s Masz za mało dolarów!",
	MAKS_WYTRZ[] = "%s Twój perk ma pełną wytrzymałość!",
	TYLKO_VIP[] = "%s Ta opcja jest dostępna tylko dla VIP'ów!";

public Plugin:myinfo = {
	name = "Call Of Duty: Sklep za monety",
	author = "Kamil? edited by KarajuSs",
	description = "Cod Dodatek",
	version = "1.1",
	url = "http://steamcommunity.com/id/nnk4"
};
public OnPluginStart() {
	RegConsoleCmd("sklep", MenuSklepu);
	RegConsoleCmd("codsklep", MenuSklepu);
	RegConsoleCmd("shop", MenuSklepu);
}

public Action:MenuSklepu(client, args) {
	if(!cod_get_user_class(client))
		PrintToChat(client, "%s Musisz mieć wybraną klasę aby włączyć sklep!", PREFIKS);
	else
	{
		new Handle:menu = CreateMenu(MenuSklepu_Handler);
		SetMenuTitle(menu, "Sklep:");
		AddMenuItem(menu, "1", "| Apteka");
		AddMenuItem(menu, "2", "| EXP");
		AddMenuItem(menu, "3", "| Ruletka");
		AddMenuItem(menu, "4", "| Naprawy");
		AddMenuItem(menu, "5", "| Inne");
		DisplayMenu(menu, client, 250);
	}

	return Plugin_Handled;
}

public MenuSklepu_Handler(Handle:classhandle, MenuAction:action, client, Position) {
	if(action == MenuAction_Select) {
		new String:Item[32];
		GetMenuItem(classhandle, Position, Item, sizeof(Item));
		MenuSklepu(client, 0);

		if(StrEqual(Item, "1"))
			SklepApteka(client, 0);
		else if(StrEqual(Item, "2"))
			SklepExp(client, 0);
		else if(StrEqual(Item, "3"))
			SklepRuletka(client, 0);
		else if(StrEqual(Item, "4"))
			SklepNaprawy(client, 0);
		else if(StrEqual(Item, "5"))
			SklepInne(client, 0);
	}
}

public Action:SklepApteka(client, args) {
	new Handle:menu = CreateMenu(SklepApteka_Handler);

	SetMenuTitle(menu, "[SKLEP] Apteka:");
	AddMenuItem(menu, "1", "| [+25HP] - 9 Monet");
	AddMenuItem(menu, "2", "| [+50HP] - 18 Monet");
	AddMenuItem(menu, "3", "| [+75HP] - 27 Monet");
	DisplayMenu(menu, client, 250);
}

public SklepApteka_Handler(Handle:classhandle, MenuAction:action, client, Position) {
	if(action == MenuAction_Select)
	{
		new String:Item[32];
		GetMenuItem(classhandle, Position, Item, sizeof(Item));
		SklepApteka(client, 0);

		new monety_gracza = cod_get_user_coins(client);
		new zdrowie_gracza = GetClientHealth(client);
		new maksymalne_zdrowie = cod_get_user_maks_health(client);
		if(!IsPlayerAlive(client) || maksymalne_zdrowie <= zdrowie_gracza)
			PrintToChat(client, "%s Jesteś w pełni zdrowy!", PREFIKS);

		else if(StrEqual(Item, "1"))
		{
			if(monety_gracza < 9)
				PrintToChat(client, MALO_MONET, PREFIKS);
			else
			{
				SetEntData(client, FindDataMapInfo(client, "m_iHealth"), (zdrowie_gracza+25 < maksymalne_zdrowie)? zdrowie_gracza+25: maksymalne_zdrowie);
				PrintToChat(client, "%s Uleczono cię o 25 hp!", PREFIKS);
				cod_set_user_coins(client, monety_gracza-9);
			}
		}
		else if(StrEqual(Item, "2"))
		{
			if(monety_gracza < 18)
				PrintToChat(client, MALO_MONET, PREFIKS);
			else
			{
				SetEntData(client, FindDataMapInfo(client, "m_iHealth"), (zdrowie_gracza+50 < maksymalne_zdrowie)? zdrowie_gracza+50: maksymalne_zdrowie);
				PrintToChat(client, "%s Uleczono cię o 50 hp!", PREFIKS);
				cod_set_user_coins(client, monety_gracza-18);
			}
		}
		else if(StrEqual(Item, "3"))
		{
			if(monety_gracza < 27)
				PrintToChat(client, MALO_MONET, PREFIKS);
			else
			{
				SetEntData(client, FindDataMapInfo(client, "m_iHealth"), (zdrowie_gracza+75 < maksymalne_zdrowie)? zdrowie_gracza+75: maksymalne_zdrowie);
				PrintToChat(client, "%s Uleczono cię o 75 hp!", PREFIKS);
				cod_set_user_coins(client, monety_gracza-27);
			}
		}
	}
}

public SklepExp(client, args) {
	new Handle:menu = CreateMenu(SklepExp_Handler);

	SetMenuTitle(menu, "[SKLEP] EXP:");
	AddMenuItem(menu, "1", "| [+1K EXP] - 200 Monet");
	AddMenuItem(menu, "2", "| [+3K EXP] - 400 Monet");
	AddMenuItem(menu, "3", "| [+7K EXP] - 750 Monet");
	AddMenuItem(menu, "4", "| [+18K EXP] - 1800 Monet");
	AddMenuItem(menu, "5", "| [+35K EXP] - 3450 Monet");
	DisplayMenu(menu, client, 250);
}

public SklepExp_Handler(Handle:classhandle, MenuAction:action, client, Position) {
	if(action == MenuAction_Select)
	{
		new String:Item[32];
		GetMenuItem(classhandle, Position, Item, sizeof(Item));
		SklepExp(client, 0);

		new monety_gracza = cod_get_user_coins(client);

		if(StrEqual(Item, "1"))
		{
			if(monety_gracza < 200)
				PrintToChat(client, MALO_MONET, PREFIKS);
			else
			{
				cod_set_user_xp(client, cod_get_user_xp(client)+1000)
				PrintToChat(client, "%s Kupiłeś 1.000 EXP'a!", PREFIKS);
				cod_set_user_coins(client, monety_gracza-200);
			}
		}
		else if(StrEqual(Item, "2"))
		{
			if(monety_gracza < 400)
				PrintToChat(client, MALO_MONET, PREFIKS);
			else
			{
				cod_set_user_xp(client, cod_get_user_xp(client)+3000)
				PrintToChat(client, "%s Kupiłeś 3.000 EXP'a!", PREFIKS);
				cod_set_user_coins(client, monety_gracza-400);
			}
		}
		else if(StrEqual(Item, "3"))
		{
			if(monety_gracza < 750)
				PrintToChat(client, MALO_MONET, PREFIKS);
			else
			{
				cod_set_user_xp(client, cod_get_user_xp(client)+7000)
				PrintToChat(client, "%s Kupiłeś 7.000 EXP'a!", PREFIKS);
				cod_set_user_coins(client, monety_gracza-750);
			}
		}
		else if(StrEqual(Item, "4"))
		{
			if(monety_gracza < 1800)
				PrintToChat(client, MALO_MONET, PREFIKS);
			else
			{
				cod_set_user_xp(client, cod_get_user_xp(client)+18000)
				PrintToChat(client, "%s Kupiłeś 18.000 EXP'a!", PREFIKS);
				cod_set_user_coins(client, monety_gracza-1800);
			}
		}
		else if(StrEqual(Item, "5"))
		{
			if(monety_gracza < 3450)
				PrintToChat(client, MALO_MONET, PREFIKS);
			else
			{
				cod_set_user_xp(client, cod_get_user_xp(client)+35000)
				PrintToChat(client, "%s Kupiłeś 35.000 EXP'a!", PREFIKS);
				cod_set_user_coins(client, monety_gracza-3450);
			}
		}
	}
}

public SklepRuletka(client, args) {
	new Handle:menu = CreateMenu(SklepRuletka_Handler);

	SetMenuTitle(menu, "[SKLEP] Ruletka:");
	AddMenuItem(menu, "1", "| Losowy I Perk - 20 Monet");
	AddMenuItem(menu, "2", "| Losowy II Perk - 20 Monet");
	AddMenuItem(menu, "3", "| Losowy Exp - 50 Monet");
	AddMenuItem(menu, "4", "| Mały Lotek Monet - 30 Monet");
	AddMenuItem(menu, "5", "| Duży Lotek Monet - 80 Monet");
	AddMenuItem(menu, "6", "| Mega Jackpot Monet i EXP'a - 280 Monet");
	DisplayMenu(menu, client, 250);
}

public SklepRuletka_Handler(Handle:classhandle, MenuAction:action, client, Position) {
	if(action == MenuAction_Select)
	{
		new String:Item[32];
		GetMenuItem(classhandle, Position, Item, sizeof(Item));
		SklepRuletka(client, 0);

		new monety_gracza = cod_get_user_coins(client);

		if(StrEqual(Item, "1"))
		{
			if(monety_gracza < 20)
				PrintToChat(client, MALO_MONET, PREFIKS);
			else
			{
				new String:item[64];
				cod_set_user_item(client, -1, -1, -1, 0);
				cod_get_item_name(cod_get_user_item(client, 0), item, sizeof(item));
				PrintToChat(client, "%s Wylosowałeś I perk: %s!", PREFIKS, item);
				cod_set_user_coins(client, monety_gracza-20);
			}
		}
		else if(StrEqual(Item, "2"))
		{
			if(!(GetUserFlagBits(client) & ADMFLAG_RESERVATION))
				PrintToChat(client, TYLKO_VIP, PREFIKS);
			else
			{
				if(monety_gracza < 20)
					PrintToChat(client, MALO_MONET, PREFIKS);
				else
				{
					new String:item[64];
					cod_set_user_item(client, -1, -1, -1, 1);
					cod_get_item_name(cod_get_user_item(client, 1), item, sizeof(item));
					PrintToChat(client, "%s Wylosowałeś II perk: %s!", PREFIKS, item);
					cod_set_user_coins(client, monety_gracza-20);
				}
			}
		}
		else if(StrEqual(Item, "3"))
		{
			if(monety_gracza < 50)
				PrintToChat(client, MALO_MONET, PREFIKS);
			else
			{
				new losowy = GetRandomInt(50, 15000);
				cod_set_user_xp(client, cod_get_user_xp(client)+losowy)
				PrintToChat(client, "%s Otrzymałeś %i EXP'a!", PREFIKS, losowy);
				cod_set_user_coins(client, monety_gracza-50);
			}
		}
		else if(StrEqual(Item, "4"))
		{
			if(monety_gracza < 30)
				PrintToChat(client, MALO_MONET, PREFIKS);
			else
			{
				new losowy = GetRandomInt(1, 60);
				cod_set_user_coins(client, monety_gracza+losowy);
				PrintToChat(client, "%s Otrzymałeś %i Monet!", PREFIKS, losowy);
				cod_set_user_coins(client, monety_gracza-30);
			}
		}
		else if(StrEqual(Item, "5"))
		{
			if(monety_gracza < 80)
				PrintToChat(client, MALO_MONET, PREFIKS);
			else
			{
				new losowy = GetRandomInt(1, 160);
				cod_set_user_coins(client, monety_gracza+losowy);
				PrintToChat(client, "%s Otrzymałeś %i Monet!", PREFIKS, losowy);
				cod_set_user_coins(client, monety_gracza-80);
			}
		}
		else if(StrEqual(Item, "6"))
		{
			if(monety_gracza < 280)
				PrintToChat(client, MALO_MONET, PREFIKS);
			else
			{
				new losowy = GetRandomInt(1, 500);
				new losowy2 = GetRandomInt(1, 10000);

				cod_set_user_coins(client, monety_gracza+losowy);
				cod_set_user_xp(client, cod_get_user_xp(client)+losowy2)

				PrintToChat(client, "%s Otrzymałeś %i Monet!", PREFIKS, losowy);
				PrintToChat(client, "%s Otrzymałeś %i EXP'a!", PREFIKS, losowy2);
				cod_set_user_coins(client, monety_gracza-280);
			}
		}
	}
}

public SklepNaprawy(client, args) {
	new Handle:menu = CreateMenu(SklepNaprawy_Handler);

	SetMenuTitle(menu, "[SKLEP] Naprawy:");
	AddMenuItem(menu, "1", "| Naprawa I Perku [+10] - 16.000$");
	AddMenuItem(menu, "2", "| Naprawa I Perku [+20] - 15 Monet");
	AddMenuItem(menu, "3", "| Naprawa I Perku [+60] - 25 Monet");
	AddMenuItem(menu, "4", "| Naprawa II Perku [+10] - 16.000$");
	AddMenuItem(menu, "5", "| Naprawa II Perku [+20] - 15 Monet");
	AddMenuItem(menu, "6", "| Naprawa II Perku [+60] - 25 Monet");
	DisplayMenu(menu, client, 250);
}

public SklepNaprawy_Handler(Handle:classhandle, MenuAction:action, client, Position) {
	if(action == MenuAction_Select)
	{
		new String:Item[32];
		GetMenuItem(classhandle, Position, Item, sizeof(Item));
		SklepNaprawy(client, 0);

		new monety_gracza = cod_get_user_coins(client);
		new kasa_gracza = GetEntData(client, FindSendPropInfo("CCSPlayer", "m_iAccount"));

		if(StrEqual(Item, "1"))
		{
			if(kasa_gracza < 16000)
				PrintToChat(client, MALO_DOLAROW, PREFIKS);
			else
			{
				new item_gracza = cod_get_user_item(client, 0);
				new wytrzymalosc_gracza = cod_get_user_item_stamina(client, 0);
				new maksymalna_wytrzymalosc = GetConVarInt(FindConVar("cod_item_max_stamina"));
				if(!item_gracza || maksymalna_wytrzymalosc <= wytrzymalosc_gracza)
					PrintToChat(client, MAKS_WYTRZ, PREFIKS);
				else
				{
					new nowa_wytrzymalosc = (wytrzymalosc_gracza+10 < maksymalna_wytrzymalosc)? wytrzymalosc_gracza+10: maksymalna_wytrzymalosc;
					cod_set_user_item(client, item_gracza, cod_get_user_item_skill(client, 0), nowa_wytrzymalosc, 0);
					PrintToChat(client, "%s Naprawiłeś 10% wytrzymałości pierwszego perku!", PREFIKS);
					SetEntData(client, FindSendPropInfo("CCSPlayer", "m_iAccount"), kasa_gracza-16000);
				}
			}
		}
		else if(StrEqual(Item, "2"))
		{
			if(monety_gracza < 15)
				PrintToChat(client, MALO_MONET, PREFIKS);
			else
			{
				new item_gracza = cod_get_user_item(client, 0);
				new wytrzymalosc_gracza = cod_get_user_item_stamina(client, 0);
				new maksymalna_wytrzymalosc = GetConVarInt(FindConVar("cod_item_max_stamina"));
				if(!item_gracza || maksymalna_wytrzymalosc <= wytrzymalosc_gracza)
					PrintToChat(client, MAKS_WYTRZ, PREFIKS);
				else
				{
					new nowa_wytrzymalosc = (wytrzymalosc_gracza+20 < maksymalna_wytrzymalosc)? wytrzymalosc_gracza+20: maksymalna_wytrzymalosc;
					cod_set_user_item(client, item_gracza, cod_get_user_item_skill(client, 0), nowa_wytrzymalosc, 0);
					PrintToChat(client, "%s Naprawiłeś 20% wytrzymałości pierwszego perku!", PREFIKS);
					cod_set_user_coins(client, monety_gracza-15);
				}
			}
		}
		else if(StrEqual(Item, "3"))
		{
			if(monety_gracza < 25)
				PrintToChat(client, MALO_MONET, PREFIKS);
			else
			{
				new item_gracza = cod_get_user_item(client, 0);
				new wytrzymalosc_gracza = cod_get_user_item_stamina(client, 0);
				new maksymalna_wytrzymalosc = GetConVarInt(FindConVar("cod_item_max_stamina"));
				if(!item_gracza || maksymalna_wytrzymalosc <= wytrzymalosc_gracza)
					PrintToChat(client, MAKS_WYTRZ, PREFIKS);
				else
				{
					new nowa_wytrzymalosc = (wytrzymalosc_gracza+60 < maksymalna_wytrzymalosc)? wytrzymalosc_gracza+60: maksymalna_wytrzymalosc;
					cod_set_user_item(client, item_gracza, cod_get_user_item_skill(client, 0), nowa_wytrzymalosc, 0);
					PrintToChat(client, "%s Naprawiłeś 60% wytrzymałości pierwszego perku!", PREFIKS);
					cod_set_user_coins(client, monety_gracza-25);
				}
			}
		}
		else if(StrEqual(Item, "4"))
		{
			if(!(GetUserFlagBits(client) & ADMFLAG_RESERVATION))
				PrintToChat(client, TYLKO_VIP, PREFIKS);
			else
			{
				if(kasa_gracza < 16000)
					PrintToChat(client, MALO_DOLAROW, PREFIKS);
				else
				{
					new item_gracza = cod_get_user_item(client, 1);
					new wytrzymalosc_gracza = cod_get_user_item_stamina(client, 1);
					new maksymalna_wytrzymalosc = GetConVarInt(FindConVar("cod_item_max_stamina"));
					if(!item_gracza || maksymalna_wytrzymalosc <= wytrzymalosc_gracza)
						PrintToChat(client, MAKS_WYTRZ, PREFIKS);
					else
					{
						new nowa_wytrzymalosc = (wytrzymalosc_gracza+10 < maksymalna_wytrzymalosc)? wytrzymalosc_gracza+10: maksymalna_wytrzymalosc;
						cod_set_user_item(client, item_gracza, cod_get_user_item_skill(client, 1), nowa_wytrzymalosc, 1);
						PrintToChat(client, "%s Naprawiłeś 10% wytrzymałości drugiego perku!", PREFIKS);
						SetEntData(client, FindSendPropInfo("CCSPlayer", "m_iAccount"), kasa_gracza-16000);
					}
				}
			}
		}
		else if(StrEqual(Item, "5"))
		{
			if(!(GetUserFlagBits(client) & ADMFLAG_RESERVATION))
				PrintToChat(client, TYLKO_VIP, PREFIKS);
			else
			{
				if(monety_gracza < 15)
					PrintToChat(client, MALO_MONET, PREFIKS);
				else
				{
					new item_gracza = cod_get_user_item(client, 1);
					new wytrzymalosc_gracza = cod_get_user_item_stamina(client, 1);
					new maksymalna_wytrzymalosc = GetConVarInt(FindConVar("cod_item_max_stamina"));
					if(!item_gracza || maksymalna_wytrzymalosc <= wytrzymalosc_gracza)
						PrintToChat(client, MAKS_WYTRZ, PREFIKS);
					else
					{
						new nowa_wytrzymalosc = (wytrzymalosc_gracza+20 < maksymalna_wytrzymalosc)? wytrzymalosc_gracza+20: maksymalna_wytrzymalosc;
						cod_set_user_item(client, item_gracza, cod_get_user_item_skill(client, 1), nowa_wytrzymalosc, 1);
						PrintToChat(client, "%s Naprawiłeś 20% wytrzymałości drugiego perku!", PREFIKS);
						cod_set_user_coins(client, monety_gracza-15);
					}
				}
			}
		}
		else if(StrEqual(Item, "6"))
		{
			if(!(GetUserFlagBits(client) & ADMFLAG_RESERVATION))
				PrintToChat(client, TYLKO_VIP, PREFIKS);
			else
			{
				if(monety_gracza < 25)
					PrintToChat(client, MALO_MONET, PREFIKS);
				else
				{
					new item_gracza = cod_get_user_item(client, 1);
					new wytrzymalosc_gracza = cod_get_user_item_stamina(client, 1);
					new maksymalna_wytrzymalosc = GetConVarInt(FindConVar("cod_item_max_stamina"));
					if(!item_gracza || maksymalna_wytrzymalosc <= wytrzymalosc_gracza)
						PrintToChat(client, MAKS_WYTRZ, PREFIKS);
					else
					{
						new nowa_wytrzymalosc = (wytrzymalosc_gracza+60 < maksymalna_wytrzymalosc)? wytrzymalosc_gracza+60: maksymalna_wytrzymalosc;
						cod_set_user_item(client, item_gracza, cod_get_user_item_skill(client, 1), nowa_wytrzymalosc, 1);
						PrintToChat(client, "%s Naprawiłeś 60% wytrzymałości drugiego perku!", PREFIKS);
						cod_set_user_coins(client, monety_gracza-25);
					}
				}
			}
		}
	}
}

public SklepInne(client, args) {
	new Handle:menu = CreateMenu(SklepInne_Handler);

	SetMenuTitle(menu, "[SKLEP] Inne:");
	AddMenuItem(menu, "1", "| Kup Monety [+10] - 16.000$");
	AddMenuItem(menu, "2", "| Kup Monety [+20] - 32.000$");
	DisplayMenu(menu, client, 250);
}

public SklepInne_Handler(Handle:classhandle, MenuAction:action, client, Position) {
	if(action == MenuAction_Select) {
		new String:Item[32];
		GetMenuItem(classhandle, Position, Item, sizeof(Item));
		SklepInne(client, 0);

		new monety_gracza = cod_get_user_coins(client);
		new kasa_gracza = GetEntData(client, FindSendPropInfo("CCSPlayer", "m_iAccount"));

		if(StrEqual(Item, "1"))
		{
			if(kasa_gracza < 16000)
				PrintToChat(client, MALO_DOLAROW, PREFIKS);
			else
			{
				SetEntData(client, FindSendPropInfo("CCSPlayer", "m_iAccount"), kasa_gracza-16000);
				cod_set_user_coins(client, monety_gracza+10);
				PrintToChat(client, "%s Kupiłeś +10 monet!", PREFIKS);
			}
		}
		else if(StrEqual(Item, "2"))
		{
			if(kasa_gracza < 32000)
				PrintToChat(client, MALO_DOLAROW, PREFIKS);
			else
			{
				SetEntData(client, FindSendPropInfo("CCSPlayer", "m_iAccount"), kasa_gracza-32000);
				cod_set_user_coins(client, monety_gracza+20);
				PrintToChat(client, "%s Kupiłeś +20 monet!", PREFIKS);
			}
		}
	}
}