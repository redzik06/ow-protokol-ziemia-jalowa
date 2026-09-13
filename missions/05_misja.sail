; 05_misja.sail — Brama na Północ
; Mapa: maps/01_akt_I/05_brama_na_polnoc.map — 64x96 mountain, indywidualna
; Vault: 01 Akt I - Rozpad i Ucieczka/05 - Brama na Północ.md, 05 Fabuła/03 - Kto Kogo Odstrzeli.md
; Zasada: nowa historia nie związana z ori, postapo, 3 poziomy równocześnie, poprawna pisownia PL

int ladunki = 0;
int material_A = 0;
int material_B = 0;
int mat_taken[3];
int craft_cd = 0;
int place_done = 0;

export un_humans[6];
export un_transporterHT;

int goal_state[3]; // 0=off 1=aktywny 2=done 3=fail

Starting
begin
    // cel 0: ZBIERZ_3_LADUNKI
    // cel 1: WYSADZ_BARYKADE
    // cel 2: OBRONA_I_UCIECZKA
    goal_state[0] := 1;

    // Drużyna 5 + HT
    uc_side := 1; uc_nation := nation_american; uc_x := 32; uc_y := 85;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    hc_gallery := 1; hc_face_number := 1;
    un_humans[0] := CreateHuman;
    uc_x := 33; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    hc_gallery := 1; hc_face_number := 2;
    un_humans[1] := CreateHuman;
    uc_x := 34; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    hc_gallery := 1; hc_face_number := 3;
    un_humans[2] := CreateHuman;
    uc_x := 32; uc_y := 86; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    hc_gallery := 1; hc_face_number := 4;
    un_humans[3] := CreateHuman;
    uc_x := 33; uc_y := 86; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    hc_gallery := 1; hc_face_number := 5;
    un_humans[4] := CreateHuman;

    uc_side := 1; vc_chassis := us_heavy_tracked; vc_engine := engine_combustion; vc_control := control_manual; vc_weapon := us_heavy_gun;
    uc_x := 32; uc_y := 84;
    un_transporterHT := CreateVehicle;
    SetLives([un_transporterHT], 80);

    // Skalowanie trudnością — złoża na mapie (area_mat1..3), fale pościgu
    // Ammo w OW jest nielimitowane na podstawową broń — trudność robią fale i czas
    if difficulty = 0 then // łatwy
    begin
        Hint('Łatwy: 3 złoża blisko, fala 4. Maya ma czas.');
    end
    else if difficulty = 1 then // średni
    begin
        Hint('Średni: materiały rozrzucone, fala 6. Planuj miny.');
    end
    else // trudny
    begin
        // fala 8 + Behemoth cień
        Hint('Trudny: złoża daleko i strzeżone, fala 8 + Behemoth.');
    end;

    ForceSay(un_humans[3], 'PZ05_01'); // Maya: "Jak wybuchnie za wcześnie..."
    ForceSay(un_humans[2], 'PZ05_02'); // Viktor: "Przepraszam, Siergiej. Ale ty byś nas zostawił."
    CenterOnXY(32,85);
end;

// Materiały: Maya zbiera w złożach (area_mat1..3 na mapie), raz każde
Every 1$0 do
begin
    if craft_cd > 0 then craft_cd := craft_cd - 1;
    if IsOK(un_humans[3]) and craft_cd = 0 then
    begin
        if mat_taken[0] = 0 and IsInArea(un_humans[3], area_mat1) then begin mat_taken[0] := 1; material_A := material_A + 1; material_B := material_B + 1; Hint('Materiały +1.'); craft_cd := 3; end
        else if mat_taken[1] = 0 and IsInArea(un_humans[3], area_mat2) then begin mat_taken[1] := 1; material_A := material_A + 1; material_B := material_B + 1; Hint('Materiały +1.'); craft_cd := 3; end
        else if mat_taken[2] = 0 and IsInArea(un_humans[3], area_mat3) then begin mat_taken[2] := 1; material_A := material_A + 1; material_B := material_B + 1; Hint('Materiały +1.'); craft_cd := 3; end;
        // Craft w warsztacie (area_warsztat): 1A+1B = 1 ładunek
        if IsInArea(un_humans[3], area_warsztat) and material_A > 0 and material_B > 0 and ladunki < 3 then
        begin
            material_A := material_A - 1; material_B := material_B - 1;
            ladunki := ladunki + 1;
            Hint('Ładunek zcraftowany: ' + ladunki + '/3');
            craft_cd := 5;
            if ladunki >= 3 then goal_state[0] := 2;
        end;
        // Podłożenie przy barykadzie (areaBarykada): ładunek + Maya → detonacja
        if place_done = 0 and ladunki > 0 and IsInArea(un_humans[3], areaBarykada) then PodlozLadunek;
    end;
end;

// Podłożenie przy barykadzie — ładunek czasowy 32,20, wybuch niszczy mur (silnik)
export function PodlozLadunek;
begin
    place_done := 1;
    Hint('Podkładanie ładunku... 10s');
    Wait(10$0);
    ladunki := ladunki - 1;
    AddComPlaceDelayedCharge([un_humans[3]], 32, 20, 0);
    Hint('Ładunek podłożony! Wycofaj się!');
    Wait(10$0); // lont
    goal_state[1] := 2;
    goal_state[2] := 1;
    // Pościg Legionu — skalowany
    if difficulty = 0 then SpawnPursuit(4)
    else if difficulty = 1 then SpawnPursuit(6)
    else SpawnPursuit(8);
    Hint('Barykada zniszczona! Uciekaj HT na północ (32,5)!');
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
        uc_side := 2; vc_chassis := ru_heavy_tracked; vc_engine := engine_combustion; vc_weapon := us_heavy_gun;
        uc_x := 32; uc_y := 65; CreateVehicle;
    end;
end;

// Meta północ
Every 0$5 do
begin
    if IsOK(un_transporterHT) and IsInArea(un_transporterHT, area_escape_polnoc) then
    begin
        if FilterUnitsInArea(area_escape_polnoc, [f_side, 1]) <> [] then
        begin
            goal_state[2] := 2;
            SaveCharacters([un_humans[0], un_humans[1], un_humans[2], un_humans[3], un_humans[4]], 'pz_team');
            YouWin;
        end;
    end;
    if not IsOK(un_transporterHT) then YouLost('PZ05_HT');
end;

// Jeśli Maya zginie — sekret: brak inżyniera w 14 piekło (vault 03 - Kto Kogo Odstrzeli)
export function UnitDestroyed(un);
begin
    if un = un_humans[3] then // Maya
        Hint('Maya zginęła przy podkładaniu — w 14 nie będzie inżyniera! (sekret)');
end;

// Koniec Aktu I — przejście do 06 Wolne Targowisko hub
// 3 poziomy równocześnie — obligatoryjnie, solucja: docs/solucje/05 - Solucja - Brama na Północ.pdf