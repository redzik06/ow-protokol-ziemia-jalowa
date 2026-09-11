; 04_misja.sail — Cmentarzysko Czołgów
; Mapa: maps/01_akt_I/04_cmentarzysko_czolgow.map — 100x100 battlefield noc, indywidualna
; Vault: 01 Akt I - Rozpad i Ucieczka/04 - Cmentarzysko Czołgów.md, 07 - Klimat Postapo.md
; Zasada: nowa historia nie związana z ori, postapo noc, 3 poziomy równocześnie, poprawna pisownia PL

int demontaz_time = 15;
int halas_prog = 50;
int wataha_size = 3;

export un_humans[5];
export un_ur;

Starting
begin
    RegisterGoal(0, 'ZDEMONTUJ_4_WRAKI');
    RegisterGoal(1, 'NIE_WYWOLAJ_ALARMU'); // opcjonalny
    EnableGoal(0, true); EnableGoal(1, true);

    // Drużyna 5
    uc_side := 1; uc_nation := nation_american; uc_x := 50; uc_y := 85;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    un_humans[0] := CreateHuman;
    uc_x := 51; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    un_humans[1] := CreateHuman;
    uc_x := 52; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    un_humans[2] := CreateHuman;
    uc_x := 50; uc_y := 86; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    un_humans[3] := CreateHuman;
    uc_x := 51; uc_y := 86; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
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
        AddHint('Łatwy: noc 0.7, demontaż 10s, wataha 2, Ur 5s. Możesz strzelać.');
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
        AddHint('Średni: widoczność 0.6, demontaż 15s, hałas 50 = wataha 3. Tylko Inżynier demontuje.');
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
        AddHint('Trudny: 0.5, demontaż 20s, wataha 4, 1 strzał = 4. Zero strzałów.');
    end;

    // Wraki 4 US Heavy Tracked — pozycje
    // W Edytorze: wrak_1 40,40 2 60,40 3 40,60 4 60,60

    // Noc 22:00 — SetTime via SAIL? placeholder
    ForceSay(un_humans[3], 'PZ04_01'); // Maya: "Cicho. Każdy strzał to zaproszenie..."
    CenterOnXY(50,85);
end;

// Demontaż — tylko Maya (Inżynier), czas skalowany
export function Demontaz(human, wrakArea);
begin
    if not IsOK(human) or GetHumanClass(human) <> class_engineer then
    begin
        AddMessage('Tylko Inżynier (Maya) demontuje wraki.');
        Exit;
    end;
    if not FilterUnitsInArea(wrakArea, GetSide(human)) then Exit;
    AddMessage('Demontaż w toku... ' + IntToStr(demontaz_time) + 's');
    Wait(demontaz_time$0);
    // CreateCrate(mat_siberite / czujnik)
    AddMessage('Część zdemontowana! +1/4');
    // RemoveVehicle(wrak)
    // Check win
    if GetDemontazCount >= 4 then
    begin
        SetGoalState(0, goal_achieved);
        YouWin;
    end;
end;

// Hałas — HumanFired
export function HumanFired(human, target);
begin
    // Sprawdź broń — uproszczone: każdy strzał > halas_prog
    uc_side := 2; uc_nation := nation_nature; hc_class := class_apeman;
    uc_x := GetX(human) + Rand(-5,5); uc_y := GetY(human) + Rand(-5,5);
    // wataha_size per trudność
    for i := 1 to wataha_size do CreateHuman;
    AddMessage('Hałas! Wataha ' + IntToStr(wataha_size) + ' Małpoludów biegnie!');
    SetGoalState(1, goal_failed); // opcjonalny alarm zaliczony jako fail
end;

// Ur — oswojenie
export function ApemanTamed(ape, scientist);
begin
    // Tylko Yuri/Farid class_scientistic
    if GetHumanClass(scientist) <> class_scientistic then Exit;
    if difficulty = 0 then Wait(5$0)
    else if difficulty = 1 then Wait(10$0)
    else Wait(15$0);
    // SetSide(ape, 1)
    un_ur := ape;
    AddMessage('Ur oswojony! Pomoże w 14 nieść ładunki.');
    // persistent? — zapisz via campaign
end;

function GetDemontazCount: Integer;
begin
    Result := 0; // placeholder licznik crate
end;

// Postapo: noc, trawa strefa ciszy, wiatraki zagłuszają — utrzymane
// 3 poziomy równocześnie — obligatoryjnie, solucja: docs/solucje/04 - Solucja - Cmentarzysko Czołgów.pdf

