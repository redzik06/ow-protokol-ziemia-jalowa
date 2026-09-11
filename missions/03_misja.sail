; 03_misja.sail — Pierwsza Pomoc
; Mapa: maps/01_akt_I/03_pierwsza_pomoc.map — 80x80 snow_ruins, indywidualna
; Vault: 05 Fabuła/04 - Oś Czasowa 15 Misji.md, 99 Mechaniki SAIL/03 - System Choroba Pyłowa.md, 00 - Zasady Poziomy Trudności.md
; Zasada: nowa historia nie związana z ori, postapo, 3 poziomy równocześnie (obligatoryjnie), poprawna pisownia PL
; SAIL: difficulty 0/1/2, IsInBuilding, filters, zamieć

int filters = 0;
int zamiec_timer = 0;
int choroba_dmg = 2;

export un_humans[5];
export un_lina;

Starting
begin
    RegisterGoal(0, 'LEKI_3'); // 3 skrzynie leków
    RegisterGoal(1, 'FILTRY_5'); // 5 filtrów
    RegisterGoal(2, 'EWAKUACJA');
    EnableGoal(0, true); EnableGoal(1, true); EnableGoal(2, true);

    // Drużyna 5 persistent
    uc_side := 1; uc_nation := nation_american; uc_x := 40; uc_y := 40;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    un_humans[0] := CreateHuman;
    uc_x := 41; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    un_humans[1] := CreateHuman;
    uc_x := 42; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    un_humans[2] := CreateHuman;
    uc_x := 40; uc_y := 41; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    un_humans[3] := CreateHuman;
    uc_x := 41; uc_y := 41; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    un_humans[4] := CreateHuman;

    // Lina Needle — medyk Sojuszu, posterunek
    uc_side := 1; uc_nation := nation_american; uc_x := 45; uc_y := 45;
    hc_name := 'Lina Ortega'; hc_class := class_scientistic; hc_sex := sex_female; hc_skills := [1,1,1,5];
    un_lina := CreateHuman;

    // Skrzynie leków 3 + filtry 5 — rozmieszczenie skalowane trudnością
    // Łatwy: filtry 6 (1 bonusowa), Średni: 5, Trudny: 5 ale 2 ukryte trudniej dostępne
    // W SAIL: crate spawn via CreateCrate? Tu placeholder areas
    // Apteka centralna 50,50 + baraki
    if difficulty = 0 then filters := 1 // łatwy start z 1 filtrem gratis
    else filters := 0;

    // Zamieć i choroba skalowane trudnością (obligatoryjnie)
    if difficulty = 0 then
    begin
        zamiec_timer := 15$00; // 15 min
        choroba_dmg := 1; // -1 HP/s
        AddHint('Łatwy: zamieć 15 min, choroba -1 HP/s, masz filtr na start. 4 budynki-schrony.');
    end
    else if difficulty = 1 then
    begin
        zamiec_timer := 12$00; // 12 min
        choroba_dmg := 2;
        AddHint('Średni: zamieć 12 min, -2 HP/s. Budynek = schronienie (IsInBuilding).');
    end
    else
    begin
        zamiec_timer := 9$00; // 9 min
        choroba_dmg := 3;
        AddHint('Trudny: zamieć 9 min, -3 HP/s, 2 filtry ukryte. Biegnij budynek->budynek.');
    end;

    // Poprawka sensu 03→05: Viktor dostaje rozkaz Mirona Karpova via radio w 03
    Wait(5$0);
    ForceSay(un_lina, 'PZ03_01'); // Lina: "Filtr? Mam. Działa? Też mam. Oba nie naraz."
    Wait(2$0);
    // Radio Mirona
    AddMessage('Radio (Miron Karpov): "Drachev, wróć do Kirowa albo zgiń jako dezerter."');
    ForceSay(un_humans[2], 'PZ03_02'); // Viktor: "Miałeś wrócić. Ja wybrałem Sojusz." (odmowa)
    Wait(2$0);
    ForceSay(un_humans[0], 'PZ03_03'); // Elena: "12 minut do zamieci. 12 minut do bycia pyłem. Romantyczne." // na Średnim

    CenterOnXY(40,40);
end;

// === EVERY — choroba pyłowa IsInBuilding ===
Every 1$0 do
begin
    zamiec_timer := zamiec_timer - 1$0;
    if zamiec_timer <= 0 then
    begin
        // Zamieć: SetVisibility, dmg x2
        AddMessage('Zamieć syberytowa! Widoczność 0.4, choroba x2!');
        choroba_dmg := choroba_dmg * 2;
        zamiec_timer := 9999$00; // jednorazowo
        // Efekt: CreateEffect(dust)
    end;

    // Co 1s sprawdzaj każdy human poza budynkiem bez filtrów
    // SAIL: IsInBuilding(human) — true jeśli w b_depot/b_bunker
    // Uproszczone: jeśli nie w areale budynku_1..4 i filters = 0
    for human in [un_humans[0], un_humans[1], un_humans[2], un_humans[3], un_humans[4], un_lina] do
    begin
        if IsOK(human) and not IsInBuilding(human) and filters = 0 then
        begin
            SetHitPoints(human, GetHitPoints(human) - choroba_dmg);
            if GetHitPoints(human) < 20 then AddMessage(GetHumanName(human) + ' umiera! Wróć do budynku!');
        end;
    end;
end;

// Filtry — crate
export function FilterCollected(crate, human);
begin
    filters := filters + 1;
    AddMessage('Filtr +1. Razem: ' + IntToStr(filters));
    // RemoveCrate(crate)
    // Na Trudnym 2 filtry ukryte — i tak liczone
end;

// Yuri/Lina dekontaminują — leczą za filtr
export function Dekontaminacja(naukowiec, cel);
begin
    if not IsOK(naukowiec) or not IsOK(cel) then Exit;
    if (GetHumanClass(naukowiec) <> class_scientistic) then
    begin
        AddMessage('Tylko Naukowiec (Yuri/Lina) dekontaminuje.');
        Exit;
    end;
    if filters <= 0 then
    begin
        AddMessage('Brak filtrów!');
        Exit;
    end;
    SetHitPoints(cel, GetHitPoints(cel) + 20);
    if GetHitPoints(cel) > 100 then SetHitPoints(cel, 100);
    filters := filters - 1;
    AddMessage('Dekontaminacja: ' + GetHumanName(cel) + ' +20 HP. Filtry: ' + IntToStr(filters));
end;

// Leki — 3 skrzynie
export function LekiCollected(crate, human);
begin
    // Licznik leków
    AddMessage('Leki +1/3');
    // Goal 0
    if GetCollectedLekiCount >= 3 then SetGoalState(0, goal_achieved);
end;

// Ewakuacja — strefa
Every 0$5 do
begin
    if FilterUnitsInArea(area_ewakuacja, 1) >= 5 and GetCollectedLekiCount >= 3 and filters >= 1 then
    begin
        SetGoalState(1, goal_achieved);
        SetGoalState(2, goal_achieved);
        // GiveMissionExperience
        YouWin;
    end;
    if not AreAnyHumansAlive then YouLose;
end;

function AreAnyHumansAlive: Boolean;
begin
    Result := IsOK(un_humans[0]) or IsOK(un_humans[1]) or IsOK(un_humans[2]) or IsOK(un_humans[3]) or IsOK(un_humans[4]);
end;

function GetCollectedLekiCount: Integer;
begin
    Result := 0; // placeholder — licznik crate
end;

// Poprawka sensu 03: posterunek to dawny punkt zrzutu crates mat_cans (EON tech_MatPred), przerobiony na medbay
// Klimat postapo: 4 budynki-schrony, woda skażona, tylko przepompownia 07 czysta — tu przedsmak
// 3 poziomy równocześnie — obligatoryjnie, solucja lista: docs/solucje/03 - Solucja - Pierwsza Pomoc.pdf

