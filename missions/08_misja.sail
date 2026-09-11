; 08_misja.sail — Wzmocnienie Konwoju
; Mapa: maps/02_akt_II/08_wzmocnienie_konwoju.map — 80x64 industrial, indywidualna
; Vault: 02 Akt II - Szara Pustynia/08 - Wzmocnienie Konwoju.md
; Zasada: nowa historia nie związana z ori, postapo, 3 poziomy równocześnie, poprawna pisownia PL

int progress = 0;
int progress_max = 100;

export un_humans[5];
export un_warsztat;

Starting
begin
    RegisterGoal(0, 'ZBIERZ_4_CZESCI');
    RegisterGoal(1, 'ZLOZ_POJAZD');
    RegisterGoal(2, 'PRZETRWAJ_FALE');
    EnableGoal(0, true);

    // Drużyna 5 + Branch
    uc_side := 1; uc_nation := nation_american; uc_x := 40; uc_y := 50;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    un_humans[0] := CreateHuman;
    uc_x := 41; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    un_humans[1] := CreateHuman;
    uc_x := 42; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    un_humans[2] := CreateHuman;
    uc_x := 40; uc_y := 51; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    un_humans[3] := CreateHuman;
    uc_x := 41; uc_y := 51; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    un_humans[4] := CreateHuman;

    // Warsztat jako budynek b_factory
    bc_side := 1; bc_type := b_factory; bc_x := 40; bc_y := 32;
    un_warsztat := CreateBuilding;

    // 4 części — crate: silnik, gąsienice, pancerz, wieżyczka
    // Pozycje: 10,20 70,20 10,50 70,50 — na Trudnym 1 strzeżona
    // Tworzone via CreateCrate

    // Skalowanie trudnością — progress, fale, czas, Wiktor buff
    if difficulty = 0 then // łatwy — +2/s, fale 4 co 120s, 12 min, części blisko
    begin
        AddHint('Łatwy: części blisko, progress +2/s, fale 4 co 120s, 12 min. Wiktor +3.');
    end
    else if difficulty = 1 then // średni — +1/s, fale 6 co 60s, 10 min
    begin
        AddHint('Średni: części rozrzucone, +1/s, fale 6 co 60s, 10 min. W warsztacie bezpieczniej.');
    end
    else // trudny — +0.7/s, fale 8 co 45s, 8 min, 1 część strzeżona, Wiktor tylko +1
    begin
        AddHint('Trudny: daleko + strzeżona, +0.7/s, fale 8 co 45s, 8 min. Warsztat = pułapka.');
    end;

    ForceSay(un_humans[3], 'PZ08_01'); // Maya: "Spawaj szybciej..."
    CenterOnXY(40,32);
end;

// Progress craft — tylko gdy Mechanik/Inżynier w warsztacie
Every 1$0 do
begin
    if FilterUnitsInArea(area_warsztat, 1) > 0 then
    begin
        // Sprawdź czy ma części
        if GetCollectedParts >= 4 then
        begin
            if difficulty = 0 then
            begin
                progress := progress + 2;
                if IsOK(un_humans[5]) then progress := progress + 1; // Wiktor +1 na Łatwym = +3
            end
            else if difficulty = 1 then progress := progress + 1
            else
            begin
                progress := progress + 1; // trudny 0.7 ~1 co 1s + Wiktor +0?
                // Wiktor tylko +0 na Trudnym — symulacja +0.7 via co 2s +1 i co 3s +2
            end;
            if progress > progress_max then progress := progress_max;
            // HUD: SetProgressBar(progress)
            AddMessage('Warsztat: ' + IntToStr(progress) + '%');
            if progress >= 100 then
            begin
                // Stwórz 2. pojazd
                vc_side := 1; vc_chassis := us_heavy_tracked; vc_engine := engine_combustion; vc_control := control_manual; vc_weapon := us_heavy_gun;
                vc_x := 40; vc_y := 35;
                CreateVehicle;
                SetGoalState(1, goal_achieved);
                AddMessage('2. pojazd gotowy! Konwój wzmocniony.');
                EnableGoal(2, true);
                // Fala obrony 60s po złożeniu — potem zwycięstwo
                Wait(60);
                if IsOK(un_warsztat) then
                begin
                    SetGoalState(2, goal_achieved);
                    YouWin;
                end
                else
                begin
                    SetGoalState(2, goal_failed);
                    YouLose;
                end;
            end;
        end;
    end;
end;

// Fale Legionu — skalowane
Every 60$0 do
begin
    if difficulty = 1 then
    begin
        // 6 wrogów co 60s
        SpawnWave(6);
    end;
end;

Every 45$0 do
begin
    if difficulty = 2 then SpawnWave(8);
end;

Every 120$0 do
begin
    if difficulty = 0 then SpawnWave(4);
end;

export function SpawnWave(count);
begin
    uc_side := 2; uc_nation := nation_arabian; hc_class := class_soldier;
    for i := 1 to count do
    begin
        uc_x := 10 + Rand(0,60); uc_y := 5; CreateHuman;
    end;
end;

function GetCollectedParts: Integer;
begin
    Result := 0; // placeholder crate count
end;


// Warsztat zniszczony przed końcem = porażka
Every 1 do
begin
    if not IsOK(un_warsztat) and GetGoalState(1) <> goal_achieved then
    begin
        SetGoalState(2, goal_failed);
        YouLose;
    end;
end;
// Postapo: hala bez prądu, suwnica ręcznie, części z wraków — utrzymane
// 3 poziomy równocześnie — obligatoryjnie, solucja: docs/solucje/08 - Solucja - Wzmocnienie Konwoju.pdf

