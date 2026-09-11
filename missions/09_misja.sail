; 09_misja.sail — Anomalia Łza
; Mapa: maps/02_akt_II/09_anomalia_lza.map — 112x112 wasteland, indywidualna
; Vault: 02 Akt II - Szara Pustynia/09 - Anomalia Łza.md, 05 Fabuła/09 - Sens i Logika — Audyt.md (poprawka 09: 3 stałe typy zamiast RNG)
; Zasada: nowa historia nie związana z ori, postapo, 3 poziomy równocześnie, poprawna pisownia PL
; SAIL: 3 stałe anomalie Źródło/Cofka/Zwarcie, cooldown, IsInArea

int cooldownHT1 = 0;
int cooldownHT2 = 0;

export un_humans[5];
export un_HT1;
export un_HT2;

Starting
begin
    RegisterGoal(0, 'PRZEPROWADZ_KONWOJ');
    EnableGoal(0, true);

    // Drużyna 5 + 2 pojazdy HT (z 08)
    uc_side := 1; uc_nation := nation_american; uc_x := 56; uc_y := 100;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    un_humans[0] := CreateHuman;
    uc_x := 57; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    un_humans[1] := CreateHuman;
    uc_x := 58; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    un_humans[2] := CreateHuman;
    uc_x := 56; uc_y := 101; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    un_humans[3] := CreateHuman;
    uc_x := 57; uc_y := 101; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    un_humans[4] := CreateHuman;

    vc_side := 1; vc_chassis := us_heavy_tracked; vc_engine := engine_combustion; vc_control := control_manual; vc_weapon := us_heavy_gun;
    vc_x := 55; vc_y := 102;
    un_HT1 := CreateVehicle;
    vc_x := 57; vc_y := 102; // 2. pojazd z 08
    un_HT2 := CreateVehicle;

    // 6 anomalii — 3 typy stałe (nie RNG): Źródło (zielony leczy), Cofka (niebieski cofa), Zwarcie (czerwony wyłącza)
    // Pozycje: anomalia_zrodlo 40,80 60,60 80,40 / cofka 50,70 70,50 / zwarcie 30,60 90,30
    // W Edytorze: area_anomalia_zrodlo_1..3 etc.

    // Skalowanie trudnością — cooldown, czas wyłączenia, cofka odległość
    if difficulty = 0 then AddHint('Łatwy: zielony leczy, niebieski cofa -5, czerwony wyłącza 7s, cooldown 3s. Łatwo ominąć.')
    else if difficulty = 1 then AddHint('Średni: wyłącza 10s, cofka -5, cooldown 5s. Ucz się trasy, pieszo obejdziesz.')
    else AddHint('Trudny: wyłącza 15s, cofka -8, cooldown 7s, ciaśniej. Rozdziel konwój — zwiad pieszo.');

    ForceSay(un_humans[1], 'PZ09_01'); // Yuri: "Sublimacja odsłoniła metal — to EON-2! Leżał pod lodem 6 miesięcy!"
    Wait(2$0);
    ForceSay(un_humans[4], 'PZ09_02'); // Karim: "A ja myślałem że to tylko ładne światło..."
    CenterOnXY(56,100);
end;

// Cooldown tick
Every 0$5 do
begin
    if cooldownHT1 > 0 then cooldownHT1 := cooldownHT1 - 1;
    if cooldownHT2 > 0 then cooldownHT2 := cooldownHT2 - 1;
end;

// Sprawdzanie anomalii co 0.5s
Every 0$5 do
begin
    CheckAnomaly(un_HT1, cooldownHT1);
    CheckAnomaly(un_HT2, cooldownHT2);
end;

export function CheckAnomaly(veh, var cd);
begin
    if cd > 0 then Exit;
    if not IsOK(veh) then Exit;

    // Typ A Źródło — leczy
    if IsInArea(veh, area_anomalia_zrodlo) then
    begin
        SetHitPoints(veh, GetHitPoints(veh) + 30);
        if GetHitPoints(veh) > 100 then SetHitPoints(veh, 100);
        AddMessage('Anomalia Źródło: +30 HP!');
        // CreateEffect(heal)
        cd := GetCooldownByDifficulty;
        Exit;
    end;
    // Typ B Cofka — teleport wstecz
    if IsInArea(veh, area_anomalia_cofka) then
    begin
        if difficulty = 0 then
        begin
            // cofka -5 krat
            SetPosition(veh, GetX(veh)-5, GetY(veh)-5);
        end
        else if difficulty = 1 then SetPosition(veh, GetX(veh)-5, GetY(veh)-5)
        else SetPosition(veh, GetX(veh)-8, GetY(veh)-8); // trudny -8
        AddMessage('Anomalia Cofka: teleport wstecz!');
        cd := GetCooldownByDifficulty;
        Exit;
    end;
    // Typ C Zwarcie — wyłącza
    if IsInArea(veh, area_anomalia_zwarcie) then
    begin
        ComStop([veh]);
        if difficulty = 0 then Wait(7$0)
        else if difficulty = 1 then Wait(10$0)
        else Wait(15$0);
        AddMessage('Anomalia Zwarcie: HT wyłączony!');
        cd := GetCooldownByDifficulty;
        Exit;
    end;
end;

function GetCooldownByDifficulty: Integer;
begin
    if difficulty = 0 then Result := 6 // 3s = 6*0.5s
    else if difficulty = 1 then Result := 10 // 5s
    else Result := 14; // 7s
end;

// Meta północ
Every 0$5 do
begin
    if IsOK(un_HT1) and IsOK(un_HT2) and IsInArea(un_HT1, area_meta) and IsInArea(un_HT2, area_meta) then
    begin
        SetGoalState(0, goal_achieved);
        YouWin;
    end;
end;

// Poprawka sensu 09→11: sublimacja Syberytu odsłania EON-2 pod lodem — link do 11
// Postapo: nałożone pola 3 EON-ów, stałe typy, nie RNG — sens z audytu
// 3 poziomy równocześnie — obligatoryjnie, solucja: docs/solucje/09 - Solucja - Anomalia Łza.pdf (stałe, nie losowe)

