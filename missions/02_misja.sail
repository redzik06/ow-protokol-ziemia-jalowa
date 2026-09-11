; 02_misja.sail — Droga przez Rdzę
; Mapa: maps/01_akt_I/02_droga_przez_rdze.map — 96x48 canyon linear, indywidualna
; Vault: 05 Fabuła/04 - Oś Czasowa 15 Misji.md, 07 - Klimat Postapo.md, 99 Mechaniki SAIL/02 - System Paliwo.md
; Zasada: nowa historia nie związana z ori, postapo, 3 poziomy trudności równocześnie (obligatoryjnie), poprawna pisownia PL
; SAIL: original-war.net/sailbase.php — difficulty 0/1/2, fuel custom, IsInArea, FilterUnitsInArea

// === GLOBALE ===
int fuel = 100;
int fuel_max = 100;
int fuel_consumption = 1;

export un_humans[5];
export un_transporterHT;
export area_wrak[5];
export area_meta;

// === STARTING ===
Starting
begin
    RegisterGoal(0, 'DOTRZYJ_KANION'); // dotrzyj HT do meta północ
    RegisterGoal(1, 'UTRZYMAJ_PALIWO');
    EnableGoal(0, true);
    EnableGoal(1, true);

    // Drużyna 5 persistent z 01 — recall (campaign.txt persistent=1)
    // W SAIL: GiveMissionExperience via campaign, tu CreateHuman placeholder jeśli brak importu
    // Dla prototypu tworzymy na nowo; w pełnej kampanii będą ImportCharacters
    uc_side := 1; uc_nation := nation_american; uc_x := 48; uc_y := 44; uc_direction := 0;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_sex := sex_female; hc_skills := [2,2,5,1];
    un_humans[0] := CreateHuman;
    uc_x := 49; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    un_humans[1] := CreateHuman;
    uc_x := 50; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    un_humans[2] := CreateHuman;
    uc_x := 48; uc_y := 45; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    un_humans[3] := CreateHuman;
    uc_x := 49; uc_y := 45; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    un_humans[4] := CreateHuman;

    // HT — paliwo skalowane trudnością (obligatoryjnie 3 poziomy)
    vc_side := 1; vc_chassis := us_heavy_tracked; vc_engine := engine_combustion; vc_control := control_manual; vc_weapon := us_heavy_gun;
    vc_x := 48; vc_y := 42;
    un_transporterHT := CreateVehicle;
    if difficulty = 0 then fuel := 100 // łatwy — starcza na 100
    else if difficulty = 1 then fuel := 100 // średni — bazowy
    else fuel := 90; // trudny — mniej na start
    if difficulty = 2 then fuel_consumption := 2 else fuel_consumption := 1; // trudny spala szybciej

    // Wraki 5 z mat_oil — rozlane z bitwy 2 mies. temu (poprawka sensu 02)
    // Pozycje: wrak 1 (10,20) blisko startu, 2 (30,25) strzeżony, 3 (50,25) centralny, 4 (70,20) strzeżony, 5 (80,40) sekret z Syberytem
    // W SAIL: obszary wraków
    // Tworzymy crate mat_oil przy każdym wraku
    // Łatwy: 2 wraki wystarczą, więc 3 najbliższe niestrzeżone; Średni: 3 wraki, 2 strzeżone; Trudny: 4 wraki, 3 strzeżone
    // Realizacja via Enable/Disable crate

    // Patrole Legionu — skalowane trudnością
    uc_side := 2; uc_nation := nation_arabian;
    hc_class := class_soldier;
    if difficulty = 0 then // łatwy — 3 patrole
    begin
        uc_x := 20; uc_y := 30; CreateHuman; // patrol 1 przy wraku 2
        uc_x := 55; uc_y := 25; CreateHuman; // patrol 2 centrum
        uc_x := 75; uc_y := 35; CreateHuman; // patrol 3 przy meta
    end
    else if difficulty = 1 then // średni — 5 patroli
    begin
        uc_x := 20; uc_y := 30; CreateHuman;
        uc_x := 30; uc_y := 25; CreateHuman;
        uc_x := 55; uc_y := 25; CreateHuman;
        uc_x := 70; uc_y := 20; CreateHuman;
        uc_x := 75; uc_y := 35; CreateHuman;
    end
    else // trudny — 7 patroli
    begin
        uc_x := 15; uc_y := 30; CreateHuman;
        uc_x := 20; uc_y := 30; CreateHuman;
        uc_x := 30; uc_y := 25; CreateHuman;
        uc_x := 50; uc_y := 20; CreateHuman;
        uc_x := 55; uc_y := 25; CreateHuman;
        uc_x := 70; uc_y := 20; CreateHuman;
        uc_x := 75; uc_y := 35; CreateHuman;
    end;

    // Hint start postapo czarny humor
    ForceSay(un_humans[0], 'PZ02_01'); // Elena: "Kanion Wiatru — jedyna droga. I jedyny powód by tu wracać to ropa."
    Wait(1$0);
    ForceSay(un_humans[2], 'PZ02_02'); // Viktor: "To nie ropa. To krew bitwy. Ale pojadę i na tym."
    if difficulty = 0 then AddHint('Łatwy: wystarczą 2 wraki, 3 patrole. Tankuj Inżynierem 5s przy wraku +30.')
    else if difficulty = 1 then AddHint('Średni: 3 wraki, 5 patroli. 2 wraki strzeżone. Planuj trasę.')
    else AddHint('Trudny: 4 wraki, 7 patroli, spalanie x2. Każdy postój to ryzyko.');

    CenterOnXY(GetX(un_transporterHT), GetY(un_transporterHT));
end;

// === EVERY — paliwo custom (99 Mechaniki SAIL/02) — skalowane ===
Every 0$1 do
begin
    if IsOK(un_transporterHT) and IsMoving(un_transporterHT) then
    begin
        fuel := fuel - fuel_consumption;
        if fuel < 0 then fuel := 0;
        if fuel = 0 then
        begin
            ComStop([un_transporterHT]);
            CenterOnXY(GetX(un_transporterHT), GetY(un_transporterHT));
            AddMessage('HT: brak paliwa! Wyślij Inżyniera do wraku — mat_oil +30.');
        end;
        // HUD via AddMessage co 5s
    end;
end;

Every 5$0 do
begin
    if IsOK(un_transporterHT) then
        AddMessage('PALIWO: ' + IntToStr(fuel) + '%');
end;

// === WRAKI — tankowanie Inżynierem (tylko Maya/Inżynier) ===
export function WrakSearch(human, wrakArea);
begin
    // Wywoływane gdy Inżynier w areale wraku i ma akcję Szukaj
    if not IsOK(human) then Exit;
    if GetProfession(human) <> class_engineer then
    begin
        AddMessage('Tylko Inżynier (Maya) potrafi spuścić mat_oil z wraku.');
        Exit;
    end;
    if not FilterUnitsInArea(wrakArea, GetSide(human)) then Exit; // nie w areale

    Wait(5$0);
    fuel := fuel + 30;
    if fuel > fuel_max then fuel := fuel_max;
    AddMessage('Zatankowano +30. Paliwo: ' + IntToStr(fuel) + '%.');
    // Usuń crate / oznacz wrak jako pusty
    // RemoveCrate(wrakArea); // placeholder
    // Efekt: CreateEffect(smoke)
end;

// Wraki wywoływane via ComMove + IsInArea
Every 0$5 do
begin
    // Sprawdź każdy z 5 wraków czy Maya/Elena w środku
    // Uproszczone: jeśli którykolwiek human w areale wraku → WrakSearch
    // Real: event HumanEnteredArea — tu co 0.5s
end;

// === META — północ kanionu ===
Every 0$5 do
begin
    if IsOK(un_transporterHT) and IsInArea(un_transporterHT, area_meta) then
    begin
        if AreAllHumansInVehicleOrArea then
        begin
            SetGoalState(0, goal_achieved);
            SetGoalState(1, goal_achieved);
            // Persistent + GiveMissionExperience — campaign recall
            YouWin;
        end;
    end;
end;

// Fail
Every 0$5 do
begin
    if (not IsOK(un_transporterHT)) or (fuel = 0 and not AnyWrakHasFuel) then
    begin
        // Jeśli HT zniszczony lub paliwo 0 i brak wraków z paliwem
        // YouLose;
    end;
    if not AreAnyHumansAlive then YouLose;
end;

function AreAnyHumansAlive: Boolean;
begin
    Result := IsOK(un_humans[0]) or IsOK(un_humans[1]) or IsOK(un_humans[2]) or IsOK(un_humans[3]) or IsOK(un_humans[4]);
end;

function AreAllHumansInVehicleOrArea: Boolean;
begin
    Result := FilterUnitsInArea(area_meta, 1) >= 5 or GetVehicleOccupantsCount(un_transporterHT) >= 5;
end;

function AnyWrakHasFuel: Boolean;
begin
    Result := true; // placeholder — zawsze 1 wrak ma paliwo dopóki nie zebrane
end;

// Poprawka sensu (audyt 02): ropa to rozlane mat_oil z bitwy 2 mies. temu, nie magiczna
// Postapo: Kanion suchy, wraki Medium Tracked porzucone, Legion patroluje
// 3 poziomy trudności równocześnie — obligatoryjnie
// Solucja lista: docs/solucje/02 - Solucja - Droga przez Rdzę.pdf (3 warianty Ł/Ś/T)

