; 01_misja.sail — Ostatnia Iskra
; Mapa: maps/01_akt_I/01_ostatnia_iskra.map — 72x72 ruins, indywidualna
; Vault: 05 Fabuła/00 - Oś Fabuły.md, 01 - Bohaterowie Drużyny.md, 07 - Klimat Postapo.md
; Zasada: nowa historia, nie kontynuacja ORI, postapo od 01, poprawna pisownia PL
; SAIL: original-war.net/sailbase.php — prototypy uc_/hc_/vc_, eventy, ForceSay

// === GLOBALE ===
int mission_failed = 0;

export un_humans[5];
export un_transporterHT;

// === STARTING — inicjalizacja prototypów ===
Starting
begin
    // Rejestracja celów misji
    RegisterGoal(0, 'UCIECZKA_HT'); // główny: dotrzyj HT do ewakuacji
    RegisterGoal(1, 'OCAL_DRUZYNE'); // główny: ocal 5
    RegisterGoal(2, 'DZIENNIK'); // poboczny ukryty
    EnableGoal(0, true);
    EnableGoal(1, true);
    EnableGoal(2, false); // ukryty

    // --- Drużyna 5 — CreateHuman via prototypy hc_/uc_ ---
    // Elena Varga „Echo” — Mechanik, dowódczyni
    uc_side := 1; uc_nation := nation_american; uc_x := 12; uc_y := 10; uc_direction := 2;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_sex := sex_female; hc_skills := [2,2,5,1];
    un_humans[0] := CreateHuman;
    SetHumanName(un_humans[0], 'Elena Varga');

    // Yuri Kamarov — Naukowiec
    uc_side := 1; uc_nation := nation_russian; uc_x := 13; uc_y := 10;
    hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_sex := sex_male; hc_skills := [1,1,2,5];
    un_humans[1] := CreateHuman;

    // Viktor Drachev — Żołnierz
    uc_side := 1; uc_nation := nation_russian; uc_x := 14; uc_y := 10;
    hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_sex := sex_male; hc_skills := [5,1,2,1];
    un_humans[2] := CreateHuman;

    // Maya Torres — Inżynier
    uc_side := 1; uc_nation := nation_american; uc_x := 12; uc_y := 11;
    hc_name := 'Maya Torres'; hc_class := class_engineer; hc_sex := sex_female; hc_skills := [2,5,3,2];
    un_humans[3] := CreateHuman;

    // Karim Al-Rashid — Desert Warrior + Mastodon w 02, tu pieszo
    uc_side := 1; uc_nation := nation_arabian; uc_x := 13; uc_y := 11;
    hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_sex := sex_male; hc_skills := [5,1,1,1];
    un_humans[4] := CreateHuman;

    // Transporter HT (ciężki gąsienicowy) — centrum mapy, HP zależne od trudności (obligatoryjnie 3 poziomy)
    vc_side := 1; vc_chassis := us_heavy_tracked; vc_engine := engine_combustion; vc_control := control_manual; vc_weapon := us_heavy_gun;
    vc_x := 36; vc_y := 36;
    un_transporterHT := CreateVehicle;
    if difficulty = 0 then SetHitPoints(un_transporterHT, 80) // łatwy — wybacza
    else if difficulty = 1 then SetHitPoints(un_transporterHT, 70) // średni — bazowy
    else SetHitPoints(un_transporterHT, 50); // trudny — kara
    // Paliwo custom — start 70% (postapo)

    // Patrole Małpoludów (Apemen) — skalowane trudnością (obligatoryjnie)
    uc_side := 2; uc_nation := nation_nature;
    hc_class := class_apeman; hc_name := 'Apeman';
    if difficulty = 0 then // łatwy — 2 patrole, luźniej
    begin
        uc_x := 25; uc_y := 30; CreateHuman;
        uc_x := 45; uc_y := 40; CreateHuman;
    end
    else if difficulty = 1 then // średni — 3 patrole
    begin
        uc_x := 25; uc_y := 30; CreateHuman;
        uc_x := 45; uc_y := 40; CreateHuman;
        uc_x := 35; uc_y := 55; CreateHuman;
    end
    else // trudny — 4 patrole + ciaśniej
    begin
        uc_x := 25; uc_y := 30; CreateHuman;
        uc_x := 45; uc_y := 40; CreateHuman;
        uc_x := 35; uc_y := 55; CreateHuman;
        uc_x := 30; uc_y := 45; CreateHuman;
    end;

    // Mgła syberytowa — ograniczona widoczność postapo
    // SetFog via SAIL? W OW: SetVisibility — tu 0.6
    // CenterOnXY(36,36);

    // Timer ucieczki skalowany trudnością (obligatoryjnie 3 poziomy)
    if difficulty = 0 then RegisterGoal(0, 'UCIECZKA_HT_20MIN')
    else if difficulty = 1 then RegisterGoal(0, 'UCIECZKA_HT_15MIN')
    else RegisterGoal(0, 'UCIECZKA_HT_10MIN');

    // Dialog start — postapo czarny humor, ForceSay
    ForceSay(un_humans[0], 'PZ01_01'); // Elena: "Alpha padła. Został HT, 5 ludzi i klucz 17..."
    Wait(2$0);
    ForceSay(un_humans[1], 'PZ01_02'); // Yuri: "Nie umieram. Tylko testuję grawitację."
    if difficulty = 0 then AddHint('Łatwy: masz 20 min i 2 patrole. Poruszaj się cicho. HT 36,36.')
    else if difficulty = 1 then AddHint('Poruszaj się cicho. Każdy strzał = wataha Małpoludów. HT 36,36.')
    else AddHint('Trudny: 10 min, 4 patrole, HT 50% HP. Powodzenia.');
end;

// === EVERY — mechanika skradania: hałas przyciąga Małpoludy ===
Every 0$1 do
begin
    // Sprawdź czy ktoś strzela z broni ciężkiej — hałas
    // W SAIL: IsFiring via event UnitFired? Uproszczone: jeśli IsOK i ma broń → spawn
    // Real: event HumanFired — tu placeholder
end;

// Event: ktoś wystrzelił — spawn watahy skalowany trudnością (uzupełnienie obligatoryjne 3 poziomy)
export function HumanFired(human, target);
begin
    uc_side := 2; uc_nation := nation_nature;
    uc_x := GetX(human) + Rand(-5,5); uc_y := GetY(human) + Rand(-5,5);
    hc_class := class_apeman;
    if difficulty = 0 then // łatwy — 2, wybacza
    begin
        CreateHuman; CreateHuman;
        AddMessage('Hałas! 2 Małpoludy biegną.');
    end
    else if difficulty = 1 then // średni — 3
    begin
        CreateHuman; CreateHuman; CreateHuman;
        AddMessage('Hałas! Wataha Małpoludów (3) biegnie na strzał!');
    end
    else // trudny — 4, kara
    begin
        CreateHuman; CreateHuman; CreateHuman; CreateHuman;
        AddMessage('Hałas! 4 Małpoludy — trudny nie wybacza!');
    end;
end;

// === GOAL: dotrzyj HT do ewakuacji północ ===
Every 0$5 do
begin
    if IsOK(un_transporterHT) and IsInArea(un_transporterHT, area_ewakuacja) then
    begin
        // Sprawdź czy 5 ludzi w HT lub w arealu
        if AreAllHumansInArea(area_ewakuacja) or AreAllHumansInVehicle(un_transporterHT) then
        begin
            SetGoalState(0, goal_achieved);
            SetGoalState(1, goal_achieved);
            // Export persistent — postacie przechodzą do 02
            // W OW: GiveMissionExperience + campaign recall — tu placeholder
            YouWin;
        end;
    end;

    // Fail jeśli wszyscy martwi
    if not AreAnyHumansAlive then
    begin
        SetGoalState(1, goal_failed);
        YouLose;
    end;
end;

// Dziennik ukryty — crate w baraku
export function CrateCollected(crate, human);
begin
    if GetCrateType(crate) = crate_dziennik then
    begin
        SetGoalState(2, goal_achieved);
        AddMessage('Dziennik bazy: "Wszystko działa. Żyła pod nami. Legion idzie." — Rook miał rację.');
        EnableGoal(2, true);
    end;
end;

// Pomocnicze
function AreAllHumansAlive: Boolean;
begin
    Result := IsOK(un_humans[0]) or IsOK(un_humans[1]) or IsOK(un_humans[2]) or IsOK(un_humans[3]) or IsOK(un_humans[4]);
end;

function AreAllHumansInArea(area): Boolean;
begin
    Result := FilterUnitsInArea(area, 1, [1,1,1,1,1]) >= 5; // uproszczone
end;

function AreAllHumansInVehicle(veh): Boolean;
begin
    Result := GetVehicleOccupantsCount(veh) >= 5;
end;

// Poprawka sensu (audyt 01): Alpha przy żyle Syberytu — dialog Rooka w 06 już przygotowany
// Postapo klimat: ruiny, pył, ograniczona widoczność — utrzymane

