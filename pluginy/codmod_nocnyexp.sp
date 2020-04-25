#include <sourcemod>
#include <codmod>

ConVar odGodziny, doGodziny;
Handle ZmianaCzasu;

public Plugin myinfo = 
{
	name = "Call of Duty: Nocny EXP",
	author = "KarajuSs",
	description = "Cod Dodatek",
	version = "1.0",
	url = "http://steamcommunity.com/id/karajussg"
}

public void OnPluginStart() {
	odGodziny = CreateConVar("cod_nighthour_xp_from", "21");
	doGodziny = CreateConVar("cod_nighthour_xp_to", "8");

	AutoExecConfig(true, "codmod_nightexp");
	SprawdzGodzine();
}


public void OnConfigsExecuted() {
	SprawdzGodzine();
}

void SprawdzGodzine() {
	static ConVar XP[7];

	if(!XP[0]) {
		XP[0] = FindConVar("cod_xp_kill"),
		XP[1] = FindConVar("cod_xp_killhs"),
		XP[2] = FindConVar("cod_xp_assist"),
		XP[3] = FindConVar("cod_xp_revenge"),
		XP[4] = FindConVar("cod_xp_damage"),
		XP[5] = FindConVar("cod_xp_objectives"),
		XP[6] = FindConVar("cod_xp_winround");
	}

	char Czas[32];
	FormatTime(Czas, sizeof(Czas), "%H");
	int Godzina = StringToInt(Czas), Od = GetConVarInt(odGodziny), Do = GetConVarInt(doGodziny);

	ServerCommand("exec sourcemod/codmod.cfg");

	if(Od > Do) {
		if(Godzina >= Od || Godzina <= Do) {
			for(int i = 0; i < 8; i++) {
				SetConVarInt(XP[i], GetConVarInt(XP[i]) * 2);
			}
		}
	} else {
		if(Od <= Godzina <= Do) {
			for(int i = 0; i < 8; i++) {
				SetConVarInt(XP[i], GetConVarInt(XP[i]) * 2);
			}
		}
	}

	FormatTime(Czas, sizeof(Czas), "%m");
	int Minuta = StringToInt(Czas);

	if(ZmianaCzasu != null) {
		KillTimer(ZmianaCzasu);
	}

	ZmianaCzasu = CreateTimer(float(60-Minuta) * 60.0, sprawdz_czas);
}

public Action:sprawdz_czas(Handle hTimer) {
	SprawdzGodzine();
}
