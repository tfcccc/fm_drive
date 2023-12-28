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
 * @return Always returns PLUGIN_CONTINUE.
 */
public plugin_precache()
{
    precache_model("models/rpgrocket.mdl");
    return PLUGIN_CONTINUE;
}

/**
 * @brief Initializes the plugin.
 * @return Always returns PLUGIN_CONTINUE.
 */
public plugin_init()
{
    register_plugin("FM_MAP_SPLATTERFORTRESS", "1.0", "teh ORiON");
    RegisterHam(Ham_Use, "multi_manager", "mm_use", 0);
    return PLUGIN_CONTINUE;
}

/**
 * @brief Handles the use event on a multimanager with the name mirror (used on splaterfortress).
 * @param id The entity ID.
 * @param idcaller The first parameter.
 * @param idactivator The second parameter.
 * @param use_type The third parameter.
 * @param value The fourth parameter.
 * @return Always returns PLUGIN_CONTINUE.
 */
public mm_use(id, idcaller, idactivator, use_type, Float:value)
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
    return PLUGIN_CONTINUE;
}

/**
 * @brief Attaches the rocket view to all connected players.
 * @param ent The entity ID of the rocket.
 * @return Always returns PLUGIN_CONTINUE.
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
            }
        }
        i++;
    }
    return PLUGIN_CONTINUE;
}
