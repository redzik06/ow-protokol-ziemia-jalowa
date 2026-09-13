; 03_misja.sail — Pierwsza Pomoc
; Mapa: maps/01_akt_I/03_pierwsza_pomoc.map — 80x80 snow_ruins, indywidualna
; Vault: 05 Fabuła/04 - Oś Czasowa 15 Misji.md, 99 Mechaniki SAIL/03 - System Choroba Pyłowa.md, 00 - Zasady Poziomy Trudności.md
; Zasada: nowa historia nie związana z ori, postapo, 3 poziomy równocześnie (obligatoryjnie), poprawna pisownia PL
; SAIL: difficulty 0/1/2, EnterBuilding/LeaveBuilding, filters, zamieć

int filters = 0;
int zamiec_timer = 0; // sekundy do zamieci (720/540) — format SAIL s$ticks
int choroba_dmg = 2;
int leki = 0;
int leki_taken[3];
int filtr_taken[6];
int sheltered[6]; // 0-4 drużyna, 5 Lina — flagi z EnterBuilding/LeaveBuilding

export un_humans[6];
export un_lina;

int goal_state[3]; // 0=off 1=aktywny 2=done 3=fail

Starting
begin
    // cel 0: LEKI_3 // 3 skrzynie leków
    // cel 1: FILTRY_5 // 5 filtrów
    // cel 2: EWAKUACJA
    goal_state[0] := 1; goal_state[1] := 1; goal_state[2] := 1;

    // Drużyna 5 persistent
    uc_side := 1; uc_nation := nation_american; uc_x := 40; uc_y := 40;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    hc_gallery := 1; hc_face_number := 1;
    un_humans[0] := CreateHuman;
    uc_x := 41; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    hc_gallery := 1; hc_face_number := 2;
    un_humans[1] := CreateHuman;
    uc_x := 42; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    hc_gallery := 1; hc_face_number := 3;
    un_humans[2] := CreateHuman;
    uc_x := 40; uc_y := 41; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    hc_gallery := 1; hc_face_number := 4;
    un_humans[3] := CreateHuman;
    uc_x := 41; uc_y := 41; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    hc_gallery := 1; hc_face_number := 5;
    un_humans[4] := CreateHuman;

    // Lina Needle — medyk Sojuszu, posterunek
    uc_side := 1; uc_nation := nation_american; uc_x := 45; uc_y := 45;
    hc_name := 'Lina Ortega'; hc_class := class_scientistic; hc_sex := sex_female; hc_skills := [1,1,1,5];
    hc_gallery := 1; hc_face_number := 11;
    un_lina := CreateHuman;

    // Skrzynie leków 3 (area_leki1..3) + filtry 6 (area_filtr1..6) — strefy na mapie
    // Łatwy: start z 1 filtrem gratis; Średni: 0; Trudny: 0, apteka dalej
    // Apteka centralna 50,50 + baraki
    if difficulty = 0 then filters := 1 // łatwy start z 1 filtrem gratis
    else filters := 0;

    // Zamieć i choroba skalowane trudnością (obligatoryjnie) — sekundy
    if difficulty = 0 then
    begin
        zamiec_timer := 900; // 15 min
        choroba_dmg := 1; // -1 HP/s
        Hint('Łatwy: zamieć 15 min, choroba -1 HP/s, masz filtr na start. 4 budynki-schrony.');
    end
    else if difficulty = 1 then
    begin
        zamiec_timer := 720; // 12 min
        choroba_dmg := 2;
        Hint('Średni: zamieć 12 min, -2 HP/s. Budynek = schronienie.');
    end
    else
    begin
        zamiec_timer := 540; // 9 min
        choroba_dmg := 3;
        Hint('Trudny: zamieć 9 min, -3 HP/s, 2 filtry ukryte. Biegnij budynek->budynek.');
    end;

    // Poprawka sensu 03→05: Viktor dostaje rozkaz Mirona Karpova via radio w 03
    Wait(5$0);
    ForceSay(un_lina, 'PZ03_01'); // Lina: "Filtr? Mam. Działa? Też mam. Oba nie naraz."
    Wait(2$0);
    // Radio Mirona
    Hint('Radio (Miron Karpov): "Drachev, wróć do Kirowa albo zgiń jako dezerter."');
    ForceSay(un_humans[2], 'PZ03_02'); // Viktor: "Miałeś wrócić. Ja wybrałem Sojusz." (odmowa)
    Wait(2$0);
    ForceSay(un_humans[0], 'PZ03_03'); // Elena: "12 minut do zamieci. 12 minut do bycia pyłem. Romantyczne." // na Średnim

    CenterOnXY(40,40);
end;

// Schronienie: eventy wejścia/wyjścia z budynków (zamiast IsInBuilding)
export function EnterBuilding(building, un);
begin
    if un = un_humans[0] then sheltered[0] := 1
    else if un = un_humans[1] then sheltered[1] := 1
    else if un = un_humans[2] then sheltered[2] := 1
    else if un = un_humans[3] then sheltered[3] := 1
    else if un = un_humans[4] then sheltered[4] := 1
    else if un = un_lina then sheltered[5] := 1;
end;
export function LeaveBuilding(building, un);
begin
    if un = un_humans[0] then sheltered[0] := 0
    else if un = un_humans[1] then sheltered[1] := 0
    else if un = un_humans[2] then sheltered[2] := 0
    else if un = un_humans[3] then sheltered[3] := 0
    else if un = un_humans[4] then sheltered[4] := 0
    else if un = un_lina then sheltered[5] := 0;
end;

// === EVERY — choroba pyłowa (budynek = schronienie) ===
Every 1$0 do
begin
    zamiec_timer := zamiec_timer - 1;
    if zamiec_timer <= 0 then
    begin
        Hint('Zamieć syberytowa! Widoczność 0.4, choroba x2!');
        choroba_dmg := choroba_dmg * 2;
        zamiec_timer := 999999; // jednorazowo
    end;

    // Co 1s: każdy poza budynkiem bez filtrów traci HP
    for i := 0 to 4 do
    begin
        if IsOK(un_humans[i]) and sheltered[i] = 0 and filters = 0 then
        begin
            SetLives([un_humans[i]], GetLives([un_humans[i]]) - choroba_dmg);
            if GetLives([un_humans[i]]) < 20 then Hint('Ranny umiera! Wróć do budynku!');
        end;
    end;
    if IsOK(un_lina) and sheltered[5] = 0 and filters = 0 then
    begin
        SetLives([un_lina], GetLives([un_lina]) - choroba_dmg);
        if GetLives([un_lina]) < 20 then Hint('Lina umiera! Wróć do budynku!');
    end;
end;

// Leki 3 (area_leki1..3) i filtry 6 (area_filtr1..6) — strefy na mapie, raz każda
Every 1$0 do
begin
    if leki_taken[0] = 0 and FilterUnitsInArea(area_leki1, [f_side, 1]) <> [] then begin leki_taken[0] := 1; leki := leki + 1; Hint('Leki +1/3'); end;
    if leki_taken[1] = 0 and FilterUnitsInArea(area_leki2, [f_side, 1]) <> [] then begin leki_taken[1] := 1; leki := leki + 1; Hint('Leki +1/3'); end;
    if leki_taken[2] = 0 and FilterUnitsInArea(area_leki3, [f_side, 1]) <> [] then begin leki_taken[2] := 1; leki := leki + 1; Hint('Leki +1/3'); end;
    if leki >= 3 then goal_state[0] := 2;
    if filtr_taken[0] = 0 and FilterUnitsInArea(area_filtr1, [f_side, 1]) <> [] then begin filtr_taken[0] := 1; filters := filters + 1; Hint('Filtr +1.'); end;
    if filtr_taken[1] = 0 and FilterUnitsInArea(area_filtr2, [f_side, 1]) <> [] then begin filtr_taken[1] := 1; filters := filters + 1; Hint('Filtr +1.'); end;
    if filtr_taken[2] = 0 and FilterUnitsInArea(area_filtr3, [f_side, 1]) <> [] then begin filtr_taken[2] := 1; filters := filters + 1; Hint('Filtr +1.'); end;
    if filtr_taken[3] = 0 and FilterUnitsInArea(area_filtr4, [f_side, 1]) <> [] then begin filtr_taken[3] := 1; filters := filters + 1; Hint('Filtr +1.'); end;
    if filtr_taken[4] = 0 and FilterUnitsInArea(area_filtr5, [f_side, 1]) <> [] then begin filtr_taken[4] := 1; filters := filters + 1; Hint('Filtr +1.'); end;
    if filtr_taken[5] = 0 and FilterUnitsInArea(area_filtr6, [f_side, 1]) <> [] then begin filtr_taken[5] := 1; filters := filters + 1; Hint('Filtr +1.'); end;
    if filters >= 5 then goal_state[1] := 2;
end;

// Yuri/Lina dekontaminują — leczą za filtr (tylko un_humans[1] i un_lina)
export function Dekontaminacja(naukowiec, cel);
begin
    if not IsOK(naukowiec) or not IsOK(cel) then Exit;
    if (naukowiec <> un_humans[1]) and (naukowiec <> un_lina) then
    begin
        Hint('Tylko Naukowiec (Yuri/Lina) dekontaminuje.');
        Exit;
    end;
    if filters <= 0 then
    begin
        Hint('Brak filtrów!');
        Exit;
    end;
    SetLives([cel], GetLives([cel]) + 20);
    if GetLives([cel]) > 100 then SetLives([cel], 100);
    filters := filters - 1;
    Hint('Dekontaminacja +20 HP. Filtry: ' + filters);
end;

// Ewakuacja — strefa
Every 0$5 do
begin
    if FilterUnitsInArea(area_ewakuacja, [f_side, 1]) <> [] and leki >= 3 and filters >= 1 then
    begin
        goal_state[1] := 2;
        goal_state[2] := 2;
        SaveCharacters([un_humans[0], un_humans[1], un_humans[2], un_humans[3], un_humans[4]], 'pz_team');
        YouWin;
    end;
    if not AreAnyHumansAlive then YouLost('PZ03_FAIL');
end;

function AreAnyHumansAlive: Boolean;
begin
    Result := IsOK(un_humans[0]) or IsOK(un_humans[1]) or IsOK(un_humans[2]) or IsOK(un_humans[3]) or IsOK(un_humans[4]);
end;

// Poprawka sensu 03: posterunek to dawny punkt zrzutu crates mat_cans (EON tech_MatPred), przerobiony na medbay
// Klimat postapo: 4 budynki-schrony, woda skażona, tylko przepompownia 07 czysta — tu przedsmak
// 3 poziomy równocześnie — obligatoryjnie, solucja lista: docs/solucje/03 - Solucja - Pierwsza Pomoc.pdf