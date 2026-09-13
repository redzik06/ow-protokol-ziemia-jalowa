; 09_misja.sail — Anomalia Łza
; Mapa: maps/02_akt_II/09_anomalia_lza.map — 112x112 wasteland, indywidualna
; Vault: 02 Akt II - Szara Pustynia/09 - Anomalia Łza.md, 05 Fabuła/09 - Sens i Logika — Audyt.md (poprawka 09: 3 stałe typy zamiast RNG)
; Zasada: nowa historia nie związana z ori, postapo, 3 poziomy równocześnie, poprawna pisownia PL
; SAIL: 3 stałe anomalie Źródło/Cofka/Zwarcie, cooldown, IsInArea

int cooldownHT1 = 0;
int cooldownHT2 = 0;

export un_humans[6];
export un_HT1;
export un_HT2;

int goal_state[3]; // 0=off 1=aktywny 2=done 3=fail

Starting
begin
    // cel 0: PRZEPROWADZ_KONWOJ
    goal_state[0] := 1;

    // Drużyna 5 + 2 pojazdy HT (z 08)
    uc_side := 1; uc_nation := nation_american; uc_x := 56; uc_y := 100;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    hc_gallery := 1; hc_face_number := 1;
    un_humans[0] := CreateHuman;
    uc_x := 57; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    hc_gallery := 1; hc_face_number := 2;
    un_humans[1] := CreateHuman;
    uc_x := 58; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    hc_gallery := 1; hc_face_number := 3;
    un_humans[2] := CreateHuman;
    uc_x := 56; uc_y := 101; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    hc_gallery := 1; hc_face_number := 4;
    un_humans[3] := CreateHuman;
    uc_x := 57; uc_y := 101; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    hc_gallery := 1; hc_face_number := 5;
    un_humans[4] := CreateHuman;
    // Branch z 06 (TestVariable) — domyślnie Wiktor
    if TestVariable('rekrut_farid') then
    begin
        uc_x := 58; uc_y := 101; hc_name := 'Farid Al-Hadi'; hc_class := class_scientistic;
        hc_gallery := 1; hc_face_number := 7;
        un_humans[5] := CreateHuman;
    end
    else
    begin
        uc_x := 58; uc_y := 101; hc_name := 'Wiktor Volkov'; hc_class := class_mechanic;
        hc_gallery := 1; hc_face_number := 6;
        un_humans[5] := CreateHuman;
    end;

    uc_side := 1; vc_chassis := us_heavy_tracked; vc_engine := engine_combustion; vc_control := control_manual; vc_weapon := us_heavy_gun;
    uc_x := 55; uc_y := 102;
    un_HT1 := CreateVehicle;
    uc_x := 57; uc_y := 102; // 2. pojazd z 08
    un_HT2 := CreateVehicle;

    // 6 anomalii — 3 typy stałe (nie RNG): Źródło (zielony leczy), Cofka (niebieski cofa), Zwarcie (czerwony wyłącza)
    // Strefy: area_anomalia_zrodlo_1/2, area_anomalia_cofka_1/2, area_anomalia_zwarcie_1/2 (pary na mapie)

    // Skalowanie trudnością — cooldown, czas wyłączenia, cofka odległość
    if difficulty = 0 then Hint('Łatwy: zielony leczy, niebieski cofa -5, czerwony wyłącza 7s, cooldown 3s. Łatwo ominąć.')
    else if difficulty = 1 then Hint('Średni: wyłącza 10s, cofka -5, cooldown 5s. Ucz się trasy, pieszo obejdziesz.')
    else Hint('Trudny: wyłącza 15s, cofka -8, cooldown 7s, ciaśniej. Rozdziel konwój — zwiad pieszo.');

    DialogueOn;
    ForceSay(un_humans[1], 'PZ09_01'); // Yuri: "Sublimacja odsłoniła metal — to EON-2! Leżał pod lodem 6 miesięcy!"
    Wait(2$0);
    ForceSay(un_humans[4], 'PZ09_02'); // Karim: "A ja myślałem że to tylko ładne światło..."
    CenterOnXY(56,100);
    DialogueOff;
    ChangeMissionObjectives('OBJ_09');
    SaveForQuickRestart;
end;

// Anomalie co 0.5s — jawne bloki per pojazd (bez var-parametrów)
export function AnomaliaHT1;
begin
    if cooldownHT1 > 0 then Exit;
    if not IsOK(un_HT1) then Exit;
    // Typ A Źródło — leczy
    if IsInArea(un_HT1, area_anomalia_zrodlo_1) or IsInArea(un_HT1, area_anomalia_zrodlo_2) then
    begin
        SetLives([un_HT1], GetLives([un_HT1]) + 30);
        if GetLives([un_HT1]) > 100 then SetLives([un_HT1], 100);
        Hint('Anomalia Źródło: +30 HP!');
        cooldownHT1 := AnomaliaCD;
        Exit;
    end;
    // Typ B Cofka — odepchnięcie wstecz (ComMoveXY, nie teleport)
    if IsInArea(un_HT1, area_anomalia_cofka_1) or IsInArea(un_HT1, area_anomalia_cofka_2) then
    begin
        if difficulty = 2 then ComMoveXY([un_HT1], GetX(un_HT1)-8, GetY(un_HT1)-8) // trudny -8
        else ComMoveXY([un_HT1], GetX(un_HT1)-5, GetY(un_HT1)-5); // -5 krat
        Hint('Anomalia Cofka: teleport wstecz!');
        cooldownHT1 := AnomaliaCD;
        Exit;
    end;
    // Typ C Zwarcie — stop + postój
    if IsInArea(un_HT1, area_anomalia_zwarcie_1) or IsInArea(un_HT1, area_anomalia_zwarcie_2) then
    begin
        ComStop([un_HT1]);
        if difficulty = 0 then Wait(7$0)
        else if difficulty = 1 then Wait(10$0)
        else Wait(15$0);
        Hint('Anomalia Zwarcie: HT wyłączony!');
        cooldownHT1 := AnomaliaCD;
        Exit;
    end;
end;

export function AnomaliaHT2;
begin
    if cooldownHT2 > 0 then Exit;
    if not IsOK(un_HT2) then Exit;
    if IsInArea(un_HT2, area_anomalia_zrodlo_1) or IsInArea(un_HT2, area_anomalia_zrodlo_2) then
    begin
        SetLives([un_HT2], GetLives([un_HT2]) + 30);
        if GetLives([un_HT2]) > 100 then SetLives([un_HT2], 100);
        Hint('Anomalia Źródło: +30 HP!');
        cooldownHT2 := AnomaliaCD;
        Exit;
    end;
    if IsInArea(un_HT2, area_anomalia_cofka_1) or IsInArea(un_HT2, area_anomalia_cofka_2) then
    begin
        if difficulty = 2 then ComMoveXY([un_HT2], GetX(un_HT2)-8, GetY(un_HT2)-8)
        else ComMoveXY([un_HT2], GetX(un_HT2)-5, GetY(un_HT2)-5);
        Hint('Anomalia Cofka: teleport wstecz!');
        cooldownHT2 := AnomaliaCD;
        Exit;
    end;
    if IsInArea(un_HT2, area_anomalia_zwarcie_1) or IsInArea(un_HT2, area_anomalia_zwarcie_2) then
    begin
        ComStop([un_HT2]);
        if difficulty = 0 then Wait(7$0)
        else if difficulty = 1 then Wait(10$0)
        else Wait(15$0);
        Hint('Anomalia Zwarcie: HT wyłączony!');
        cooldownHT2 := AnomaliaCD;
        Exit;
    end;
end;

function AnomaliaCD: Integer;
begin
    if difficulty = 0 then Result := 6 // 3s = 6*0.5s
    else if difficulty = 1 then Result := 10 // 5s
    else Result := 14; // 7s
end;

Every 0$5 do
begin
    if cooldownHT1 > 0 then cooldownHT1 := cooldownHT1 - 1;
    if cooldownHT2 > 0 then cooldownHT2 := cooldownHT2 - 1;
    AnomaliaHT1;
    AnomaliaHT2;
end;

// Meta północ
Every 0$5 do
begin
    if IsOK(un_HT1) and IsOK(un_HT2) and IsInArea(un_HT1, area_meta) and IsInArea(un_HT2, area_meta) then
    begin
        goal_state[0] := 2;
        SaveCharacters([un_humans[0], un_humans[1], un_humans[2], un_humans[3], un_humans[4]], 'pz_team');
        YouWin;
    end;
end;

// Poprawka sensu 09->11: sublimacja Syberytu odsłania EON-2 pod lodem — link do 11
// Postapo: nałożone pola 3 EON-ów, stałe typy, nie RNG — sens z audytu
// 3 poziomy równocześnie — obligatoryjnie, solucja: docs/solucje/09 - Solucja - Anomalia Łza.pdf (stałe, nie losowe)
