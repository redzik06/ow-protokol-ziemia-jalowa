; 14_misja.sail — Bitwa w Kraterze
; Mapa: maps/03_akt_III/14_bitwa_w_kraterze.map — 128x128 crater, indywidualna
; Vault: 03 Akt III - Protokół Eos/14 - Bitwa w Kraterze.md, 05 Fabuła/03 - Kto Kogo Odstrzeli.md (Yuri → Miron)
; Zasada: nowa historia nie związana z ori, postapo, 3 poziomy równocześnie, poprawna pisownia PL, podział sił

int silosyRozbrojone = 0;

export un_humans[5];
export un_silos[3];
export un_behemoth;

Starting
begin
    RegisterGoal(0, 'ROZBRAJ_3_SILOSY'); // NW/NE/S
    RegisterGoal(1, 'ODEPRZYJ_FALE');
    RegisterGoal(2, 'YURI_VS_MIRON');
    EnableGoal(0, true); EnableGoal(1, true);

    // Drużyna 5 + Branch
    uc_side := 1; uc_nation := nation_american; uc_x := 64; uc_y := 100;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    un_humans[0] := CreateHuman;
    uc_x := 65; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    un_humans[1] := CreateHuman;
    uc_x := 66; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    un_humans[2] := CreateHuman;
    uc_x := 64; uc_y := 101; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    un_humans[3] := CreateHuman;
    uc_x := 65; uc_y := 101; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    un_humans[4] := CreateHuman;

    // 3 silosy z rakietami ru_siberium_rocket — pozycje NW 20,20 NE 100,20 S 64,90
    // Każdy silos to b_siberite_mine? Uproszczone: area_silos_1..3

    // Behemoth — mini-boss Mirona (tylko Średni/Trudny)
    if difficulty <> 0 then
    begin
        vc_side := 2; vc_nation := nation_russian; vc_chassis := ru_heavy_tracked; // Behemoth jako heavy
        vc_engine := engine_combustion; vc_control := control_manual; vc_weapon := us_heavy_gun;
        vc_x := 64; vc_y := 64;
        un_behemoth := CreateVehicle;
        if difficulty = 1 then SetHitPoints(un_behemoth, 800)
        else SetHitPoints(un_behemoth, 1200);
    end;

    // Skalowanie trudnością — odległość silosów, czas rozbrajania, fale, timer
    if difficulty = 0 then // łatwy — silosy blisko 30 krat, rozbrajanie 10s, fale 4 co 90s, 15 min, Behemoth bez rakiet, można 1 grupą
    begin
        AddHint('Łatwy: silosy 30 krat, rozbrajanie 10s, fale 4 co 90s, 15 min. Możesz iść jedną grupą.');
    end
    else if difficulty = 1 then // średni — 60 krat, 15s, fale 6 co 45s, 12 min, Behemoth z rakietami, podział konieczny
    begin
        AddHint('Średni: 60 krat, 15s, fale 6 co 45s, 12 min, Behemoth z rakietami. Podział na 2 grupy.');
    end
    else // trudny — 80 krat, 20s (30s jeśli Maya martwa), fale 8 co 30s, 8 min, Behemoth +2 HT
    begin
        AddHint('Trudny: 80 krat, 20s (30s bez Mayi), fale 8 co 30s, 8 min, Behemoth +2 HT. Sprint + podział.');
        // Jeśli Maya martwa w 05 — piekło
        if not IsOK(un_humans[3]) then AddHint('Maya martwa w 05 — rozbrajanie 30s! Piekło.');
    end;

    ForceSay(un_humans[1], 'PZ14_01'); // Yuri: "Podpisałem..."
    CenterOnXY(64,100);
end;

// Rozbrajanie — tylko Inżynier (Maya), czas skalowany, Miron przy ostatnim
export function RozbrojSilos(human, silosArea);
begin
    if GetHumanClass(human) <> class_engineer then
    begin
        AddMessage('Tylko Inżynier (Maya) rozbraja silosy.');
        Exit;
    end;
    // Sprawdź który silos
    // Jeśli ostatni i Yuri vs Miron — Yuri musi zabić Mirona
    if silosArea = area_silos_3 and IsOK(un_humans[1]) then // ostatni
    begin
        AddMessage('Miron Karpov przy silosie! Yuri musi go zastrzelić!');
        // ForceSay Miron: "Podpisałeś, Jurij? Teraz patrz jak działa długopis."
        // Yuri → Miron
        Wait(2$0);
        // KillUnit(Miron)
        AddMessage('Yuri → Miron Karpov: strzał. Uczeń zabił mistrza. Kod Gamma zdobyty.');
        SetGoalState(2, goal_achieved);
    end;

    if difficulty = 0 then Wait(10$0)
    else if difficulty = 1 then Wait(15$0)
    else
    begin
        if IsOK(un_humans[3]) then Wait(20$0) // Maya żyje
        else Wait(30$0); // Maya martwa — 30s
    end;
    silosyRozbrojone := silosyRozbrojone + 1;
    AddMessage('Silos rozbrojony: ' + IntToStr(silosyRozbrojone) + '/3');
    if silosyRozbrojone >= 3 then
    begin
        SetGoalState(0, goal_achieved);
        YouWin;
    end;
end;

// Fale Kultu — skalowane
Every 90$0 do
begin
    if difficulty = 0 and GetGoalState(0) <> goal_achieved then SpawnWave(4);
end;
Every 45$0 do
begin
    if difficulty = 1 and GetGoalState(0) <> goal_achieved then SpawnWave(6);
end;
Every 30$0 do
begin
    if difficulty = 2 and GetGoalState(0) <> goal_achieved then SpawnWave(8);
end;

export function SpawnWave(count);
begin
    uc_side := 2; uc_nation := nation_russian; hc_class := class_soldier;
    for i:=1 to count do
    begin
        uc_x := 64 + Rand(-60,60); uc_y := 64 + Rand(-60,60); CreateHuman;
    end;
end;

// Chen Beta — chce zdezerterować, można przekonać (sekret)
export function DialogChen;
begin
    AddMessage('Chen: "Mam kod Beta. Mam dość. Bierzcie i puśćcie mnie." — oddaje bez walki.');
    silosyRozbrojone := silosyRozbrojone + 1; // skrót
end;

// Postapo: 3 silosy rozrzucone NW/NE/S — dlatego podział sił ma sens (audyt 14)
// 3 poziomy równocześnie — obligatoryjnie, solucja: docs/solucje/14 - Solucja - Bitwa w Kraterze.pdf

