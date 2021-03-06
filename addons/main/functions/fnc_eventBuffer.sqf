/*
 * Author: Titan
 * Loops through an array of events waiting to be saved to the database
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call FUNC(eventBuffer);
 *
 * Public: No
 */

#include "script_component.hpp"
private _functionLogName = "AAR > eventBuffer";

DBUG("Starting event saving buffer", _functionLogName);

private _timeSinceLastInfantryInsert = time;
private _timeSinceLastGroundVehicleInsert = time;
private _timeSinceLastAirVehicleInsert = time;

while { GVAR(logEvents) } do {

    // We save unit positions at different frequencies depending on their vehicle

    if (time >= _timeSinceLastInfantryInsert + GVAR(insertFrequencyInfantry)) then {
        call FUNC(trackInfantry);
        _timeSinceLastInfantryInsert = time;
    };

    if (time >= _timeSinceLastGroundVehicleInsert + GVAR(insertFrequencyGroundVehicle)) then {
        ["ground"] call FUNC(trackVehicles);
        _timeSinceLastGroundVehicleInsert = time;
    };

    if (time >= _timeSinceLastAirVehicleInsert + GVAR(insertFrequencyAirVehicle)) then {
        ["air"] call FUNC(trackVehicles);
        _timeSinceLastAirVehicleInsert = time;
    };

    // Do we have any events to process?
    if(count GVAR(eventSavingQueue) > 0) then {

        // Get the next event.
        private _event = (GVAR(eventSavingQueue) select 0);

        // Check an event is selected
        if !(isNil "_event") then {

            _event params ["_playerId", "_eventType", "_eventData", "_missionTime"];

            // Commit the event to the database
            private _query = str formatText["1:SQLRAW:
                INSERT INTO
                    events
                (replayId, playerId, type, value, missionTime, added)
                    VALUES
                ('%1', '%2', '%3', '%4', %5, NOW())",
                GVAR(replayId), _playerId, _eventType, _eventData call CBA_fnc_trim, _missionTime];

            call compile ("extDB3" callExtension _query);

            // Clear down the selected event from the global variable.
            GVAR(eventSavingQueue) set [0,0];
            GVAR(eventSavingQueue) = GVAR(eventSavingQueue) - [0];
        };

        _event = Nil;
    };

    sleep ( 0.5 / (if(count GVAR(eventSavingQueue) > 1) then { count GVAR(eventSavingQueue) } else {1}) );
};
