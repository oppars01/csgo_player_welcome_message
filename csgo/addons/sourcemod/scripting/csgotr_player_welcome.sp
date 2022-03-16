#include <sourcemod>
#include <csgoturkiye>

#pragma semicolon 1

public Plugin myinfo = 
{
    name = "oppa", 
    author = "oppa", 
    description = "It shows >> Welcome Message << to the player entering the server 3 seconds after choosing a team.", 
    version = "1.0", 
    url = "csgo-turkiye.com"
};

ConVar cv_type = null;
bool b_client_connect_message[ MAXPLAYERS + 1 ], b_type;

public void OnPluginStart()
{
    cv_type = CreateConVar("sm_player_welcome_message_type", "0", "Top: 0\nMiddle: 1", _, true, 0.0, true, 1.0);
    b_type = GetConVarBool(cv_type);
    HookConVarChange(cv_type, OnCvarChanged);
    AddCommandListener(JoinTeam, "jointeam");
    for(int i = 1; i <= MaxClients; i++) b_client_connect_message[ i ] = true;
}

public void OnMapStart()
{
    LoadTranslations("csgotr-player_welcome.phrases.txt");
}

public int OnCvarChanged(Handle convar, const char[] oldVal, const char[] newVal)
{
    if(convar == cv_type) b_type = GetConVarBool(cv_type);
}

public Action JoinTeam(int client, char [] command,int argc)
{
    if (IsValidClient(client) && !b_client_connect_message[ client ]){
        b_client_connect_message[ client ] = true;
        CreateTimer(3.0, WelcomeMessage, client);
    }
    return Plugin_Continue;
}

public void OnClientPostAdminCheck(int client)
{
    b_client_connect_message[client] = false;
}

public Action WelcomeMessage(Handle timer, int client)
{
    if(IsValidClient(client)){
        char s_temp[1024];
        Format(s_temp, sizeof(s_temp) ,"%t", "Welcome Message", client);
        if(b_type) PrintHintText(client, s_temp);
        else{
            Event newevent = CreateEvent("cs_win_panel_round", true);
            newevent.SetString("funfact_token", s_temp);
            newevent.FireToClient(client);
            CreateTimer(10.0, RemoveWelcomeMessage, client);
        }
    }
}

public Action RemoveWelcomeMessage(Handle timer, int client)
{
    if(IsValidClient(client)){
        Event newevent = CreateEvent("cs_win_panel_round", true);
        newevent.SetString("funfact_token", "");
        newevent.FireToClient(client);
    }
} 