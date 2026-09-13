; 04_misja.sail — Cmentarzysko Czołgów
; Mapa: maps/01_akt_I/04_cmentarzysko_czolgow.map — 100x100 battlefield noc, indywidualna
; Vault: 01 Akt I - Rozpad i Ucieczka/04 - Cmentarzysko Czołgów.md, 07 - Klimat Postapo.md
; Zasada: nowa historia nie związana z ori, postapo noc, 3 poziomy równocześnie, poprawna pisownia PL

int demontaz_time = 15;
int halas_prog = 50;
int wataha_size = 3;
int demontaz_done = 0;
int wrak_ok[4];
int halas_cd = 0;
int demontaz_busy = 0;

export un_humans[6];
export un_ur;

int goal_state[3]; // 0=off 1=aktywny 2=done 3=fail

Starting
begin
    // cel 0: ZDEMONTUJ_4_WRAKI
    // cel 1: NIE_WYWOLAJ_ALARMU // opcjonalny
    goal_state[0] := 1; goal_state[1] := 1;

    // Drużyna 5
    uc_side := 1; uc_nation := nation_american; uc_x := 50; uc_y := 85;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    hc_gallery := 1; hc_face_number := 1;
    un_humans[0] := CreateHuman;
    uc_x := 51; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    hc_gallery := 1; hc_face_number := 2;
    un_humans[1] := CreateHuman;
    uc_x := 52; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    hc_gallery := 1; hc_face_number := 3;
    un_humans[2] := CreateHuman;
    uc_x := 50; uc_y := 86; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    hc_gallery := 1; hc_face_number := 4;
    un_humans[3] := CreateHuman;
    uc_x := 51; uc_y := 86; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    hc_gallery := 1; hc_face_number := 5;
    un_humans[4] := CreateHuman;

    // Skalowanie trudnością — noc, widoczność, demontaż, patrole, Ur
    if difficulty = 0 then // łatwy — wybacza
    begin
        demontaz_time := 10;
        halas_prog := 25;
        wataha_size := 2;
        // widoczność 0.7, 3 patrole
        uc_side := 2; uc_nation := nation_nature; hc_class := class_apeman;
        uc_x := 30; uc_y := 50; CreateHuman;
        uc_x := 60; uc_y := 50; CreateHuman;
        uc_x := 45; uc_y := 70; CreateHuman;
        Hint('Łatwy: noc 0.7, demontaż 10s, wataha 2, Ur 5s. Możesz strzelać.');
    end
    else if difficulty = 1 then // średni — bazowy
    begin
        demontaz_time := 15;
        halas_prog := 50;
        wataha_size := 3;
        uc_side := 2; uc_nation := nation_nature; hc_class := class_apeman;
        uc_x := 30; uc_y := 50; CreateHuman;
        uc_x := 60; uc_y := 50; CreateHuman;
        uc_x := 45; uc_y := 70; CreateHuman;
        uc_x := 30; uc_y := 70; CreateHuman;
        Hint('Średni: widoczność 0.6, demontaż 15s, hałas 50 = wataha 3. Tylko Inżynier demontuje.');
    end
    else // trudny — kara
    begin
        demontaz_time := 20;
        halas_prog := 50;
        wataha_size := 4;
        uc_side := 2; uc_nation := nation_nature; hc_class := class_apeman;
        uc_x := 30; uc_y := 50; CreateHuman;
        uc_x := 60; uc_y := 50; CreateHuman;
        uc_x := 45; uc_y := 70; CreateHuman;
        uc_x := 30; uc_y := 70; CreateHuman;
        uc_x := 60; uc_y := 70; CreateHuman;
        Hint('Trudny: 0.5, demontaż 20s, wataha 4, 1 strzał = 4. Zero strzałów.');
    end;

    // Wraki 4 US Heavy Tracked — strefy area_wrak1..4 na mapie
    // W Edytorze: wrak_1 40,40 2 60,40 3 40,60 4 60,60

    // Noc 22:00 — klimat mapy (Edytor)
    ForceSay(un_humans[3], 'PZ04_01'); // Maya: "Cicho. Każdy strzał to zaproszenie..."
    CenterOnXY(50,85);
end;

// Demontaż — tylko Maya (un_humans[3], Inżynier), czas skalowany, raz per wrak
export function Demontaz(idx);
begin
    demontaz_busy := 1;
    Hint('Demontaż w toku... ' + demontaz_time + 's');
    for d := 1 to demontaz_time do Wait(1$0);
    wrak_ok[idx] := 1;
    demontaz_done := demontaz_done + 1;
    demontaz_busy := 0;
    Hint('Część zdemontowana! ' + demontaz_done + '/4');
    if demontaz_done >= 4 then
    begin
        goal_state[0] := 2;
        if IsOK(un_ur) then SaveCharacters([un_humans[0], un_humans[1], un_humans[2], un_humans[3], un_humans[4], un_ur], 'pz_team')
        else SaveCharacters([un_humans[0], un_humans[1], un_humans[2], un_humans[3], un_humans[4]], 'pz_team');
        YouWin;
    end;
end;

Every 1$0 do
begin
    // Maya przy wraku → demontaż (auto, raz per wrak)
    if demontaz_busy = 0 and IsOK(un_humans[3]) then
    begin
        if wrak_ok[0] = 0 and IsInArea(un_humans[3], area_wrak1) then Demontaz(0)
        else if wrak_ok[1] = 0 and IsInArea(un_humans[3], area_wrak2) then Demontaz(1)
        else if wrak_ok[2] = 0 and IsInArea(un_humans[3], area_wrak3) then Demontaz(2)
        else if wrak_ok[3] = 0 and IsInArea(un_humans[3], area_wrak4) then Demontaz(3);
    end;
    // Hałas: strzał drużyny (Attacks) → wataha, max co 30s
    if halas_cd > 0 then halas_cd := halas_cd - 1;
    if halas_cd = 0 then
    begin
        if IsOK(un_humans[0]) and Attacks(un_humans[0]) <> 0 then begin HalasWataha(un_humans[0]); end
        else if IsOK(un_humans[2]) and Attacks(un_humans[2]) <> 0 then begin HalasWataha(un_humans[2]); end
        else if IsOK(un_humans[4]) and Attacks(un_humans[4]) <> 0 then begin HalasWataha(un_humans[4]); end;
    end;
end;

export function HalasWataha(human);
begin
    uc_side := 2; uc_nation := nation_nature; hc_class := class_apeman;
    uc_x := GetX(human) + Rand(-5,5); uc_y := GetY(human) + Rand(-5,5);
    for i := 1 to wataha_size do CreateHuman;
    Hint('Hałas! Wataha ' + wataha_size + ' Małpoludów biegnie!');
    goal_state[1] := 3; // opcjonalny alarm zaliczony jako fail
    halas_cd := 30;
end;

// Ur — oswojenie (prawdziwy event ApemanTamed: ComTameXY gracza)
export function ApemanTamed(ape, scientist);
begin
    SetSide(ape, 1);
    un_ur := ape;
    Hint('Ur oswojony! Pomoże w 14 nieść ładunki.');
end;

// Postapo: noc, trawa strefa ciszy, wiatraki zagłuszają — utrzymane
// 3 poziomy równocześnie — obligatoryjnie, solucja: docs/solucje/04 - Solucja - Cmentarzysko Czołgów.pdf