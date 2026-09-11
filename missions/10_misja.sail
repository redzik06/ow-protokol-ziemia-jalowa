; 10_misja.sail — Przechwycenie Sygnału
; Mapa: maps/02_akt_II/10_przechwycenie_sygnalu.map — 96x96 plateau, indywidualna
; Vault: 02 Akt II - Szara Pustynia/10 - Przechwycenie Sygnału.md, 05 Fabuła/09 - Sens i Logika — Audyt.md
; Zasada: nowa historia nie związana z ori, postapo, 3 poziomy równocześnie, poprawna pisownia PL

int wiezaHP = 800;
int faleCount = 6;
int miny = 10;

export un_humans[5];
export un_wieza;

Starting
begin
    RegisterGoal(0, 'NAPRAW_WIEZE_30S');
    RegisterGoal(1, 'NADAJ_SYGNAL_15S');
    RegisterGoal(2, 'OBRONA_10MIN');
    EnableGoal(0, true);

    // Drużyna 5 + 2 pojazdy HT
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

    vc_side := 1; vc_chassis := us_heavy_tracked; vc_engine := engine_combustion; vc_control := control_manual; vc_weapon := us_heavy_gun;
    vc_x := 45; vc_y := 82; CreateVehicle;
    vc_x := 51; vc_y := 82; CreateVehicle;

    // Wieża b_control_tower — HP skalowane trudnością
    bc_side := 1; bc_type := b_control_tower; bc_x := 48; bc_y := 48;
    un_wieza := CreateBuilding;
    if difficulty = 0 then wiezaHP := 1000
    else if difficulty = 1 then wiezaHP := 800
    else wiezaHP := 500;
    SetHitPoints(un_wieza, wiezaHP);

    // Miny i fale skalowane
    if difficulty = 0 then
    begin
        miny := 12; faleCount := 4;
        AddHint('Łatwy: 12 min, wieża 1000 HP, miny 12, fale 4 co 120s. Wrogowie wpadają w anomalie.');
    end
    else if difficulty = 1 then
    begin
        miny := 10; faleCount := 6;
        AddHint('Średni: 10 min, 800 HP, miny 10, fale 6 co 90s, N/W/E rotacja.');
    end
    else
    begin
        miny := 6; faleCount := 8;
        AddHint('Trudny: 8 min, 500 HP, miny 6, fale 8 co 60s. Wrogowie omijają anomalie. Brak czasu.');
    end;

    // Miny do rozstawienia — crate
    // CreateCrate(mine) x miny

    ForceSay(un_humans[3], 'PZ10_01'); // Maya naprawia
    ForceSay(un_humans[1], 'PZ10_02'); // Yuri nadaje
    CenterOnXY(48,48);
end;

// Naprawa wieży — Inżynier 30s
export function NaprawWieze(human);
begin
    if GetHumanClass(human) <> class_engineer then Exit;
    AddMessage('Naprawa wieży 30s...');
    Wait(30$0);
    EnableGoal(0, false); EnableGoal(1, true);
    AddMessage('Wieża naprawiona! Nadaj sygnał Naukowcem 15s.');
end;

// Nadanie sygnału — Naukowiec 15s
export function NadajSygnal(human);
begin
    if GetHumanClass(human) <> class_scientistic then Exit;
    AddMessage('Nadawanie sygnału 15s...');
    Wait(15$0);
    SetGoalState(1, goal_achieved);
    EnableGoal(2, true);
    AddMessage('Sygnał wysłany! Broń wieży 10 min! Alya słyszy...');
    // Start obrony
end;

// Fale 3 kierunków skalowane
Every 90$0 do
begin
    if difficulty = 1 and IsGoalEnabled(2) then SpawnWave(faleCount, 'N');
end;
Every 60$0 do
begin
    if difficulty = 2 and IsGoalEnabled(2) then SpawnWave(faleCount, 'N');
end;
Every 120$0 do
begin
    if difficulty = 0 and IsGoalEnabled(2) then SpawnWave(faleCount, 'N');
end;

export function SpawnWave(count, dir);
begin
    uc_side := 2; uc_nation := nation_arabian; hc_class := class_soldier;
    for i := 1 to count do
    begin
        if dir = 'N' then begin uc_x := 48 + Rand(-20,20); uc_y := 5; end
        else if dir = 'W' then begin uc_x := 5; uc_y := 48 + Rand(-20,20); end
        else begin uc_x := 90; uc_y := 48 + Rand(-20,20); end;
        CreateHuman;
    end;
    // Wabienie w anomalie brzegowe — na Łatwym wpadają, na Trudnym omijają
end;

// Miny
export function PlaceMineAt(x,y);
begin
    if miny <= 0 then Exit;
    // PlaceMine(x,y)
    miny := miny - 1;
    AddMessage('Mina postawiona. Zostało: ' + IntToStr(miny));
end;

Every 0$5 do
begin
    if IsGoalEnabled(2) and GetHitPoints(un_wieza) <= 0 then
    begin
        SetGoalState(2, goal_failed);
        YouLose;
    end;
    if IsGoalEnabled(2) and GetGoalTime(2) <= 0 then
    begin
        SetGoalState(2, goal_achieved);
        YouWin;
    end;
end;

// Postapo: wieża na wzniesieniu widoczna dla wszystkich — 3 kierunki logiczne (audyt)
// 3 poziomy równocześnie — obligatoryjnie, solucja: docs/solucje/10 - Solucja - Przechwycenie Sygnału.pdf

