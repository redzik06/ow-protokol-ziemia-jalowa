; 05_misja.sail — Brama na Północ
; Mapa: maps/01_akt_I/05_brama_na_polnoc.map — 64x96 mountain, indywidualna
; Vault: 01 Akt I - Rozpad i Ucieczka/05 - Brama na Północ.md, 05 Fabuła/03 - Kto Kogo Odstrzeli.md
; Zasada: nowa historia nie związana z ori, postapo, 3 poziomy równocześnie, poprawna pisownia PL

int ladunki = 0;
int material_A = 0;
int material_B = 0;

export un_humans[5];
export un_transporterHT;

Starting
begin
    RegisterGoal(0, 'ZBIERZ_3_LADUNKI');
    RegisterGoal(1, 'WYSADZ_BARYKADE');
    RegisterGoal(2, 'OBRONA_I_UCIECZKA');
    EnableGoal(0, true);

    // Drużyna 5 + HT
    uc_side := 1; uc_nation := nation_american; uc_x := 32; uc_y := 85;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    un_humans[0] := CreateHuman;
    uc_x := 33; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    un_humans[1] := CreateHuman;
    uc_x := 34; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    un_humans[2] := CreateHuman;
    uc_x := 32; uc_y := 86; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    un_humans[3] := CreateHuman;
    uc_x := 33; uc_y := 86; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    un_humans[4] := CreateHuman;

    vc_side := 1; vc_chassis := us_heavy_tracked; vc_engine := engine_combustion; vc_control := control_manual; vc_weapon := us_heavy_gun;
    vc_x := 32; vc_y := 84;
    un_transporterHT := CreateVehicle;
    SetHitPoints(un_transporterHT, 80);

    // Skalowanie trudnością — materiały, obrona, ammo, fale
    if difficulty = 0 then // łatwy
    begin
        // 3 złoża blisko, obrona 3 min, ammo 40, fala 4
        material_A := 3; material_B := 3; // blisko
        AddHint('Łatwy: 3 złoża blisko, obrona 3 min, ammo 40, fala 4. Maya ma czas.');
    end
    else if difficulty = 1 then // średni
    begin
        material_A := 3; material_B := 3; // rozrzucone
        AddHint('Średni: materiały rozrzucone, obrona 2 min, ammo 20, fala 6. Planuj miny.');
    end
    else // trudny
    begin
        material_A := 3; material_B := 3; // daleko + strzeżone
        // ammo 12, fala 8 + Behemoth cień
        for h in un_humans do SetAmmo(h, 12);
        AddHint('Trudny: daleko, obrona 1.5 min, ammo 12, fala 8 + Behemoth. Każdy nabój liczony.');
    end;
    if difficulty = 1 then for h in un_humans do SetAmmo(h, 20);
    if difficulty = 0 then for h in un_humans do SetAmmo(h, 40);

    ForceSay(un_humans[3], 'PZ05_01'); // Maya: "Jak wybuchnie za wcześnie..."
    ForceSay(un_humans[2], 'PZ05_02'); // Viktor: "Przepraszam, Siergiej. Ale ty byś nas zostawił."
    CenterOnXY(32,85);
end;

// Craft ładunków — tylko Maya
export function CraftLadunek(human);
begin
    if GetHumanClass(human) <> class_engineer then
    begin
        AddMessage('Tylko Inżynier (Maya) craftuje ładunki.');
        Exit;
    end;
    if material_A > 0 and material_B > 0 then
    begin
        material_A := material_A - 1; material_B := material_B - 1;
        ladunki := ladunki + 1;
        AddMessage('Ładunek zcraftowany: ' + IntToStr(ladunki) + '/3');
        if ladunki >= 3 then SetGoalState(0, goal_achieved);
    end;
end;

// Podłożenie przy barykadzie
export function PodlozLadunek(human, areaBarykada);
begin
    if ladunki <= 0 then
    begin
        AddMessage('Brak ładunków! Zcraftuj w złożach.');
        Exit;
    end;
    if not FilterUnitsInArea(areaBarykada, GetSide(human)) then Exit;
    AddMessage('Podkładanie ładunku... 10s');
    Wait(10$0);
    ladunki := ladunki - 1;
    // PlaceBomb(areaBarykada, 10$0) — wybuch
    AddMessage('Ładunek podłożony! Wycofaj się!');
    // Po 10s: RemoveObstacle, EnableEscape, SpawnPursuit
    Wait(10$0);
    // RemoveObstacle(barykada)
    SetGoalState(1, goal_achieved);
    EnableGoal(2, true);
    // Pościg Legionu — skalowany
    if difficulty = 0 then SpawnPursuit(4)
    else if difficulty = 1 then SpawnPursuit(6)
    else SpawnPursuit(8);
    AddMessage('Barykada zniszczona! Uciekaj HT na północ (32,5)!');
end;

export function SpawnPursuit(count);
begin
    uc_side := 2; uc_nation := nation_arabian; hc_class := class_soldier;
    for i := 1 to count do
    begin
        uc_x := 32 + Rand(-10,10); uc_y := 70; CreateHuman;
    end;
    // Trudny: dodatkowo Behemoth cień
    if difficulty = 2 then
    begin
        vc_side := 2; vc_chassis := ru_heavy_tracked; vc_engine := engine_combustion; vc_weapon := us_heavy_gun;
        vc_x := 32; vc_y := 65; CreateVehicle;
    end;
end;

// Meta północ
Every 0$5 do
begin
    if IsOK(un_transporterHT) and IsInArea(un_transporterHT, area_escape_polnoc) then
    begin
        if FilterUnitsInArea(area_escape_polnoc, 1) >= 5 or GetVehicleOccupantsCount(un_transporterHT) >= 5 then
        begin
            SetGoalState(2, goal_achieved);
            // Persistent Maya — jeśli zginęła przy podkładaniu, brak inżyniera w 14
            YouWin;
        end;
    end;
    if not IsOK(un_transporterHT) then YouLose;
end;

// Jeśli Maya zginie — sekret: brak inżyniera w 14 piekło (vault 03 - Kto Kogo Odstrzeli)
export function UnitDestroyed(unit);
begin
    if unit = un_humans[3] then // Maya
        AddMessage('Maya zginęła przy podkładaniu — w 14 nie będzie inżyniera! (sekret)');
end;

// Koniec Aktu I — przejście do 06 Wolne Targowisko hub
// 3 poziomy równocześnie — obligatoryjnie, solucja: docs/solucje/05 - Solucja - Brama na Północ.pdf

