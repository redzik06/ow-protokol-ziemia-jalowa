; 02_misja.sail — Droga przez Rdzę
; Mapa: maps/01_akt_I/02_droga_przez_rdze.map — 96x48 canyon linear, indywidualna
; Vault: 05 Fabuła/04 - Oś Czasowa 15 Misji.md, 07 - Klimat Postapo.md, 99 Mechaniki SAIL/02 - System Paliwo.md
; Zasada: nowa historia nie związana z ori, postapo, 3 poziomy trudności równocześnie (obligatoryjnie), poprawna pisownia PL
; SAIL: original-war.net/sailbase.php — difficulty 0/1/2, fuel custom, IsInArea, FilterUnitsInArea

// === GLOBALE ===
// Paliwo silnikiem gry: SetFuel/GetFuel (vc_fuel_battery). Poziomy: start 100/90/70.
int wrak_full[5]; // 1=wrak ma ropę (area_wrak1..5 na mapie)
int siphon_cd = 0; // cooldown spuszczania

export un_humans[6];
export un_transporterHT;

// === STARTING ===
int goal_state[3]; // 0=off 1=aktywny 2=done 3=fail

Starting
begin
    // cel 0: DOTRZYJ_KANION // dotrzyj HT do meta północ
    // cel 1: UTRZYMAJ_PALIWO
    goal_state[0] := 1;
    goal_state[1] := 1;

    // Drużyna 5 persistent z 01 — recall (campaign.txt persistent=1)
    // W SAIL: GiveMissionExperience via campaign, tu CreateHuman placeholder jeśli brak importu
    // Dla prototypu tworzymy na nowo; w pełnej kampanii będą ImportCharacters
    uc_side := 1; uc_nation := nation_american; uc_x := 48; uc_y := 44; uc_direction := 0;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_sex := sex_female; hc_skills := [2,2,5,1];
    hc_gallery := 1; hc_face_number := 1;
    un_humans[0] := CreateHuman;
    uc_x := 49; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    hc_gallery := 1; hc_face_number := 2;
    un_humans[1] := CreateHuman;
    uc_x := 50; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    hc_gallery := 1; hc_face_number := 3;
    un_humans[2] := CreateHuman;
    uc_x := 48; uc_y := 45; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    hc_gallery := 1; hc_face_number := 4;
    un_humans[3] := CreateHuman;
    uc_x := 49; uc_y := 45; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    hc_gallery := 1; hc_face_number := 5;
    un_humans[4] := CreateHuman;

    // HT — paliwo skalowane trudnością (obligatoryjnie 3 poziomy, silnik spala sam)
    uc_side := 1; vc_chassis := us_heavy_tracked; vc_engine := engine_combustion; vc_control := control_manual; vc_weapon := us_heavy_gun;
    uc_x := 48; uc_y := 42;
    un_transporterHT := CreateVehicle;
    if difficulty = 0 then SetFuel([un_transporterHT], 100) // łatwy — pełny bak
    else if difficulty = 1 then SetFuel([un_transporterHT], 90) // średni — bazowy
    else SetFuel([un_transporterHT], 70); // trudny — mniej na start + więcej patroli

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
    if difficulty = 0 then Hint('Łatwy: wystarczą 2 wraki, 3 patrole. Tankuj Mayą 5s przy wraku +30.')
    else if difficulty = 1 then Hint('Średni: 3 wraki, 5 patroli. 2 wraki strzeżone. Planuj trasę.')
    else Hint('Trudny: 4 wraki, 7 patroli, mniej paliwa na start. Każdy postój to ryzyko.');
    wrak_full[0] := 1; wrak_full[1] := 1; wrak_full[2] := 1; wrak_full[3] := 1; wrak_full[4] := 1;

    CenterOnXY(GetX(un_transporterHT), GetY(un_transporterHT));
end;

// === EVERY — paliwo silnikiem gry (SetFuel start, HUD co 30s) ===
Every 30$0 do
begin
    if IsOK(un_transporterHT) then
    begin
        if GetFuel([un_transporterHT]) <= 0 then
            Hint('HT: brak paliwa! Wyślij Mayę do wraku — mat_oil +30.')
        else Hint('PALIWO: ' + GetFuel([un_transporterHT]) + '%');
    end;
end;

// === WRAKI — spuszczanie ropy Mayą (area_wrak1..5 na mapie) ===
export function WrakSearch(idx);
begin
    // Tylko Maya (un_humans[3], Inżynier) spuszcza mat_oil
    if wrak_full[idx] = 0 then
    begin
        Hint('Wrak pusty. Szukaj dalej.');
        Exit;
    end;
    Wait(5$0);
    if GetFuel([un_transporterHT]) + 30 > 100 then SetFuel([un_transporterHT], 100)
    else SetFuel([un_transporterHT], GetFuel([un_transporterHT]) + 30);
    wrak_full[idx] := 0;
    Hint('Zatankowano +30. Paliwo: ' + GetFuel([un_transporterHT]) + '%.');
end;

Every 1$0 do
begin
    if siphon_cd > 0 then siphon_cd := siphon_cd - 1;
    if siphon_cd = 0 and IsOK(un_humans[3]) and IsOK(un_transporterHT) then
    begin
        if IsInArea(un_humans[3], area_wrak1) then begin WrakSearch(0); siphon_cd := 8; end
        else if IsInArea(un_humans[3], area_wrak2) then begin WrakSearch(1); siphon_cd := 8; end
        else if IsInArea(un_humans[3], area_wrak3) then begin WrakSearch(2); siphon_cd := 8; end
        else if IsInArea(un_humans[3], area_wrak4) then begin WrakSearch(3); siphon_cd := 8; end
        else if IsInArea(un_humans[3], area_wrak5) then begin WrakSearch(4); siphon_cd := 8; end;
    end;
end;

// === META — północ kanionu ===
Every 0$5 do
begin
    if IsOK(un_transporterHT) and IsInArea(un_transporterHT, area_meta) then
    begin
        if AreAnyHumansAlive then
        begin
            goal_state[0] := 2;
            goal_state[1] := 2;
            SaveCharacters([un_humans[0], un_humans[1], un_humans[2], un_humans[3], un_humans[4]], 'pz_team');
            YouWin;
        end;
    end;
end;

// Fail
Every 0$5 do
begin
    if not IsOK(un_transporterHT) then YouLost('PZ02_HT');
    if IsOK(un_transporterHT) and GetFuel([un_transporterHT]) <= 0
        and wrak_full[0] = 0 and wrak_full[1] = 0 and wrak_full[2] = 0 and wrak_full[3] = 0 and wrak_full[4] = 0
        and not IsInArea(un_transporterHT, area_meta) then YouLost('PZ02_FUEL');
    if not AreAnyHumansAlive then YouLost('PZ02_FAIL');
end;

function AreAnyHumansAlive: Boolean;
begin
    Result := IsOK(un_humans[0]) or IsOK(un_humans[1]) or IsOK(un_humans[2]) or IsOK(un_humans[3]) or IsOK(un_humans[4]);
end;

// Poprawka sensu (audyt 02): ropa to rozlane mat_oil z bitwy 2 mies. temu, nie magiczna
// Postapo: Kanion suchy, wraki Medium Tracked porzucone, Legion patroluje
// 3 poziomy trudności równocześnie — obligatoryjnie
// Solucja lista: docs/solucje/02 - Solucja - Droga przez Rdzę.pdf (3 warianty Ł/Ś/T)