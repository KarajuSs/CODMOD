#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <codmod>
#include <money>

public Plugin myinfo =  {
	name = "Cod D0: Gifts",
	author = "d0naciak edited by KarajuSs",
	description =  "",
	version = "1.0",
	url = "d0naciak.pl"
}

public void OnPluginStart() {
	HookEvent("player_death", PlayerIsDeath);
}

public void OnMapStart() {
	PrecacheModel("models/props_survival/cash/dufflebag.mdl");
	PrecacheSound("survival/money_collect_05.wav");
}

public void PlayerIsDeath(Handle event, const char[] name, bool dontBroadcast) {
	if(GameRules_GetProp("m_bWarmupPeriod") == 1) {
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (!client || !IsClientInGame(client)) {
		return;
	}

	CreateGift(client);
}

void CreateGift(client) {
	float position[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
	
	int entity = CreateEntityByName("prop_physics_override");
	DispatchKeyValue(entity, "model", "models/props_survival/cash/dufflebag.mdl");
	DispatchKeyValue(entity, "physicsmode", "2");
	DispatchKeyValue(entity, "massScale", "2.0");
	DispatchKeyValue(entity, "targetname", "cod_gift");
	DispatchSpawn(entity);
	
	SetEntProp(entity, Prop_Send, "m_usSolidFlags", 8);
	SetEntProp(entity, Prop_Send, "m_CollisionGroup", 1);

	SetVariantString("OnUser1 !self:kill::5.0:-1");
	AcceptEntityInput(entity, "AddOutput");
	AcceptEntityInput(entity, "FireUser1");

	TeleportEntity(entity, position, NULL_VECTOR, NULL_VECTOR);
	SDKHook(entity, SDKHook_StartTouch, StartTouch); 
}

public void StartTouch(int entity, int client) {
	if(!(1 <= client <= MAXPLAYERS) || !IsPlayerAlive(client)) {
		return;
	}

	new kasa_gracza = GetEntData(client, FindSendPropInfo("CCSPlayer", "m_iAccount"));
	switch(GetRandomInt(0,7)) {
		case 0: PrintToChat(client, " \x06\x04[COD:MW]\x01 Plecak był pusty!");

		case 1: {
			int exp = GetRandomInt(1, 5000);
			cod_set_user_xp(client, cod_get_user_xp(client) + exp);

			EmitSoundToClient(client, "survival/money_collect_05.wav", -2, 0, 0, 0, 0.5, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			PrintToChat(client, " \x06\x04[COD:MW]\x01 Podniosłeś +%d dodatkowego EXP'a!", exp);
		}

		case 2,3: {
			int health = GetRandomInt(1, 100),
			clientHealth = GetClientHealth(client) + health,
			maxHealth = 100 + RoundFloat(float(cod_get_user_maks_health(client)) * 0.25);

			if(clientHealth > maxHealth) {
				clientHealth = maxHealth;
			}

			SetEntityHealth(client, clientHealth);

			EmitSoundToClient(client, "survival/money_collect_05.wav", -2, 0, 0, 0, 0.5, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			PrintToChat(client, " \x06\x04[COD:MW]\x01 Podniosłeś +%d hp!", health);
		}

		case 4,5: {
			int moneybonus = GetRandomInt(1, 800);
			SetEntData(client, FindSendPropInfo("CCSPlayer", "m_iAccount"), kasa_gracza+moneybonus);

			EmitSoundToClient(client, "survival/money_collect_05.wav", -2, 0, 0, 0, 0.5, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			PrintToChat(client, " \x06\x04[COD:MW]\x01 Podniosłeś +%d$!", moneybonus);
		}

		case 6,7: {
			int coinsbonus = GetRandomInt(1, 5);
			new monety_gracza = cod_get_user_coins(client);

			EmitSoundToClient(client, "survival/money_collect_05.wav", -2, 0, 0, 0, 0.5, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			PrintToChat(client, " \x06\x04[COD:MW]\x01 Podniosłeś +%d monet!", coinsbonus);
			cod_set_user_coins(client, monety_gracza+coinsbonus);
		}
	}

	AcceptEntityInput(entity, "Kill");
}