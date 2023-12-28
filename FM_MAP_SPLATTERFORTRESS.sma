/**
 * @file FM_MAP_SPLATTERFORTRESS.sma
 * @brief Plugin for changing players' views to a rocket in the SplatterFortress map.
 * @author teh ORiON
 * @version 1.0
 */

#pragma semicolon 1
#pragma ctrlchar '\'
#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

/**
 * @brief Precaches the rocket model.
 * @return Always returns 0.
 */
public plugin_precache()
{
    precache_model("models/rpgrocket.mdl");
    return 0;
}

/**
 * @brief Initializes the plugin.
 * @return Always returns 0.
 */
public plugin_init()
{
    register_plugin("FM_MAP_SPLATTERFORTRESS", "1.0", "teh ORiON");
    RegisterHam(Ham_Use, "multi_manager", "MMUSE", 0);
    return 0;
}

/**
 * @brief Handles the MMUSE event.
 * @param id The entity ID.
 * @param a The first parameter.
 * @param b The second parameter.
 * @param c The third parameter.
 * @param d The fourth parameter.
 * @return Always returns 0.
 */
public MMUSE(id, a, b, c, Float:d)
{
    new sStoreClassName[32];
    pev(id, pev_targetname, sStoreClassName, 31);
    if (equali(sStoreClassName, "mirror", 0))
    {
        new iEnt = -1;
        iEnt = find_ent_by_tname(iEnt, "camera");
        entity_set_model(iEnt, "models/rpgrocket.mdl");
        attachviews(iEnt);
    }
    return 0;
}

/**
 * @brief Attaches the rocket view to all connected players.
 * @param ent The entity ID of the rocket.
 * @return Always returns 0.
 */
public attachviews(ent)
{
    new i = 0;
    i = 1;
    while (i < 32)
    {
        if (is_valid_ent(i))
        {
            if (is_user_connected(i))
            {
                attach_view(i, ent);
                i++;
            }
            i++;
        }
        i++;
    }
    return 0;
}