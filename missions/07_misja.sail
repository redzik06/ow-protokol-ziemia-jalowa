; 07_misja.sail — Czysty Tlen
; Mapa: maps/02_akt_II/07_czysty_tlen.map — 96x96 snow_valley, indywidualna
; Vault: 02 Akt II - Szara Pustynia/07 - Czysty Tlen.md, 05 Fabuła/07 - Klimat Postapo.md
; Zasada: nowa historia nie związana z ori, postapo, 3 poziomy równocześnie, poprawna pisownia PL

int generatorHP = 500;
int obronaTimer = 0;

export un_humans[5];
export un_generator;
export un_turrets[3];

Starting
begin
    RegisterGoal(0, 'OCZYSC_PRZEPOMPOWNIE');
    RegisterGoal(1, 'OBRONA_8MIN');
    EnableGoal(0, true); EnableGoal(1, true);

    // Drużyna 5 + Branch (Wiktor/Farid)
    uc_side := 1; uc_nation := nation_american; uc_x := 48; uc_y := 80;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    un_humans[0] := CreateHuman;
    uc_x := 49; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    un_humans[1] := CreateHuman;
    uc_x := 50; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    un_humans[2] := CreateHuman;
    uc_x := 48; uc_y := 81; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    un_humans[3] := CreateHuman;
    uc_x := 49; uc_y := 81; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    un_humans[4] := CreateHuman;
    // Branch via GetGlobalVar rekrut_06 — spawn Wiktor/Farid jeśli wybrany
    if GetGlobalVar('rekrut_06') = 1 then
    begin
        uc_x := 50; uc_y := 81; hc_name := 'Wiktor Volkov'; hc_class := class_mechanic;
        CreateHuman;
    end
    else if GetGlobalVar('rekrut_06') = 2 then
    begin
        uc_x := 50; uc_y := 81; hc_name := 'Farid Al-Hadi'; hc_class := class_scientistic;
        CreateHuman;
    end;

    // Przepompownia i generator — skalowane trudnością
    // b_siberite_mine? Tu b_depot jako przepompownia
    bc_side := 1; bc_type := b_depot; bc_x := 48; bc_y := 48;
    un_generator := CreateBuilding; // generator jako budynek
    if difficulty = 0 then generatorHP := 700
    else if difficulty = 1 then generatorHP := 500
    else generatorHP := 300;
    SetHitPoints(un_generator, generatorHP);

    // 3 wieżyczki do przejęcia — początkowo neutral/wróg, po hacku SetSide 1
    // Pozycje: 40,48 56,48 48,60
    // Tworzone jako b_turret

    // Skalowanie obrony
    if difficulty = 0 then obronaTimer := 10$00 // łatwy 10 min + fale co 120s
    else if difficulty = 1 then obronaTimer := 8$00 // średni 8 min fale co 90s
    else obronaTimer := 6$00; // trudny 6 min fale co 60s

    if difficulty = 0 then AddHint('Łatwy: generator 700 HP, 10 min, fale 4 co 120s, wieżyczki mocne.')
    else if difficulty = 1 then AddHint('Średni: 500 HP, 8 min, fale 6 co 90s.')
    else AddHint('Trudny: 300 HP, 6 min, fale 8 co 60s, ciągła naprawa.');

    ForceSay(un_humans[1], 'PZ07_01'); // Yuri: "Prąd jest. Dopóki ktoś nie kichnie."
    CenterOnXY(48,48);
end;

// Naprawa generatora — tylko Inżynier/Mechanik
Every 1$0 do
begin
    if IsOK(un_generator) and IsInBuilding(un_humans[3], un_generator) then // Maya
    begin
        if GetHitPoints(un_generator) < generatorHP then
            SetHitPoints(un_generator, GetHitPoints(un_generator) + 5);
        // Wiktor buff +2 na Łatwym
        if difficulty = 0 and IsOK(un_humans[5]) then SetHitPoints(un_generator, GetHitPoints(un_generator) + 2);
    end;
    if GetHitPoints(un_generator) <= 0 then
    begin
        // wieżyczki offline
        AddMessage('Generator padł! Wieżyczki offline!');
    end;
end;

// Fale Legionu — skalowane
Every 90$0 do
begin
    if difficulty = 0 then // łatwy co 120s ale Every 90 więc co drugie
    begin
        // 4 wrogów
    end;
    // Real: spawn via CreateHuman
end;

Every 60$0 do
begin
    if difficulty = 2 then
    begin
        // trudny co 60s 8 wrogów
    end;
end;

// Hack wieżyczek — Inżynier 10/15/20s? Już w 07 przejęcie via terminal
export function HackTurret(human, turret);
begin
    if GetHumanClass(human) <> class_engineer then Exit;
    Wait(10$0); // skalowane? łatwy 8, średni 10, trudny 15 — placeholder 10
    SetSide(turret, 1);
    AddMessage('Wieżyczka przejęta!');
end;

Every 0$5 do
begin
    obronaTimer := obronaTimer - 0$5;
    if obronaTimer <= 0 then
    begin
        SetGoalState(1, goal_achieved);
        YouWin;
    end;
end;

// Postapo: woda pod zmarzliną jedyna czysta — Lina Needle w 03 wpływa na leki tu
// 3 poziomy równocześnie — obligatoryjnie, solucja: docs/solucje/07 - Solucja - Czysty Tlen.pdf

