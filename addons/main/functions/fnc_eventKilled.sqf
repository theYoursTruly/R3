/*
 * Author: Titan
 * Event fired when unit killed
 *
 * Arguments:
 * 0: victim <OBJECT>
 * 1: attacker <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_victim, _attacker] call FUNC(eventKilled);
 *
 * Public: No
 */

#include "script_component.hpp"
private _functionLogName = "AAR > eventKilled";

params [
    ["_victim", objNull],
    ["_attacker", objNull]
];

// Handle respawnOnStart
if (_victim == objNull) exitWith {};

// We only want to log ai or players being killed, not fences being run over!
if ( (_attacker isEqualTo ObjNull) or !(getObjectType _victim isEqualTo 8) ) exitWith {};

if (_victim == _attacker) then {
    _attacker = _victim getVariable ["lastAttacker", _victim];
};

private _formatedShotData = [_victim, _attacker] call FUNC(shotTemplate);

private _victimUid = _formatedShotData select 0;
private _json = _formatedShotData select 1;

// Save details to db
GVAR(eventSavingQueue) pushBack [_victimUid, "unit_killed", _json, time];

//DBUG("Unit killed and saved to db", _functionLogName);
