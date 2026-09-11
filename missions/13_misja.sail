; 13_misja.sail — Baza Eos — Przedpola
; Mapa: maps/03_akt_III/13_baza_eos_przedpola.map — 112x112 bunker, indywidualna
; Vault: 03 Akt III - Protokół Eos/13 - Baza Eos — Przedpola.md, 05 Fabuła/09 - Sens i Logika — Audyt.md (4 terminale = 3 kody + master)
; Zasada: nowa historia nie związana z ori, postapo, 3 poziomy równocześnie, poprawna pisownia PL

export un_humans[5];
export un_terminals[4];
export un_turrets[8];

Starting
begin
    RegisterGoal(0, 'PRZEJMIJ_4_TERMINALE');
    RegisterGoal(1, 'WYLACZ_AUTOSektury');
    EnableGoal(0, true);

    // Drużyna 5 + 2 pojazdy HT
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
    vc_x := 55; vc_y := 102; CreateVehicle;
    vc_x := 57; vc_y := 102; CreateVehicle;

    // 4 terminale — 3 kody Mirona (Sokolov/Chen/Reyes) + master EON-2
    // Pozycje: 20,20 90,20 20,90 90,90
    bc_side := 2; bc_type := b_lab; // terminal jako lab
    for i:=1 to 4 do
    begin
        // CreateBuilding terminal
    end;

    // 8 autosektur b_turret — pierścień obronny
    // Pozycje wokół Eos 56,56

    // Skalowanie trudnością — terminale hack time, autosektury HP, timer
    if difficulty = 0 then // łatwy — 15s, słabe, hack 1=2 wyłączone, 25 min, można szturmować
    begin
        AddHint('Łatwy: terminale 15s, autosektury słabe, hack 1=2 wyłączone, 25 min. Możesz szturmować. Sokolov łatwy.');
    end
    else if difficulty = 1 then // średni — 20s, mocne, hack 2=4, 20 min
    begin
        AddHint('Średni: 20s, mocne, hack 2=4 wyłączone, 20 min, pod ostrzałem. Hack oszczędza ludzi.');
    end
    else // trudny — 30s, bardzo mocne, hack 4 dopiero, 15 min
    begin
        AddHint('Trudny: 30s, bardzo mocne, hack 4 dopiero, 15 min, ciągły ostrzał. Szturm = śmierć.');
    end;

    ForceSay(un_humans[3], 'PZ13_01'); // Maya: "Terminal prosi o hasło..."
    CenterOnXY(56,100);
end;

// Hack terminala — tylko Inżynier (Maya), czas skalowany
export function HackTerminal(human, terminal);
begin
    if GetHumanClass(human) <> class_engineer then
    begin
        AddMessage('Tylko Inżynier (Maya) hackuje terminale.');
        Exit;
    end;
    if difficulty = 0 then Wait(15$0)
    else if difficulty = 1 then Wait(20$0)
    else Wait(30$0);
    SetSide(terminal, 1);
    AddMessage('Terminal przejęty! ' + IntToStr(GetHackedCount) + '/4');
    // Efekty: na Łatwym 1 terminal = 2 autosektury off, Średni 2=4, Trudny 4 dopiero
    if difficulty = 0 and GetHackedCount >= 1 then DisableTurrets(2);
    if difficulty = 1 and GetHackedCount = 2 then DisableTurrets(4);
    if difficulty = 2 and GetHackedCount = 4 then DisableTurrets(8);
    if GetHackedCount >= 4 then
    begin
        SetGoalState(0, goal_achieved);
        SetGoalState(1, goal_achieved);
        AddMessage('Pierścień Eos wyłączony! Droga do krateru otwarta.');
        YouWin;
    end;
end;

export function DisableTurrets(count);
begin
    // SetSide(turret, 0) lub SetHitPoints 0
end;

function GetHackedCount: Integer;
begin
    Result := 0; // placeholder licznik
end;

// Postapo: pierścień koncentryczny Mirona, terminale w rogach, Autosektury — hack zamiast szturmu ma sens
// 3 poziomy równocześnie — obligatoryjnie, solucja: docs/solucje/13 - Solucja - Baza Eos — Przedpola.pdf

