; 13_misja.sail — Baza Eos — Przedpola
; Mapa: maps/03_akt_III/13_baza_eos_przedpola.map — 112x112 bunker, indywidualna
; Vault: 03 Akt III - Protokół Eos/13 - Baza Eos — Przedpola.md, 05 Fabuła/09 - Sens i Logika — Audyt.md (4 terminale = 3 kody + master)
; Zasada: nowa historia nie związana z ori, postapo, 3 poziomy równocześnie, poprawna pisownia PL

export un_humans[6];
export un_terminals[4];
export un_turrets[8];

int goal_state[3]; // 0=off 1=aktywny 2=done 3=fail
int hacked[4];
int hack_prog[4];
int hack_need = 20; // sekundy hacku: 15/20/30
int hacked_cnt = 0;

Starting
begin
    // cel 0: PRZEJMIJ_4_TERMINALE
    // cel 1: WYLACZ_AUTOSektury
    goal_state[0] := 1;

    // Drużyna 5 + 2 pojazdy HT
    uc_side := 1; uc_nation := nation_american; uc_x := 56; uc_y := 100;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    hc_gallery := 1; hc_face_number := 1;
    un_humans[0] := CreateHuman;
    uc_x := 57; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    hc_gallery := 1; hc_face_number := 2;
    un_humans[1] := CreateHuman;
    uc_x := 58; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    hc_gallery := 1; hc_face_number := 3;
    un_humans[2] := CreateHuman;
    uc_x := 56; uc_y := 101; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    hc_gallery := 1; hc_face_number := 4;
    un_humans[3] := CreateHuman;
    uc_x := 57; uc_y := 101; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    hc_gallery := 1; hc_face_number := 5;
    un_humans[4] := CreateHuman;
    // Branch z 06 (TestVariable) — domyślnie Wiktor
    if TestVariable('rekrut_farid') then
    begin
        uc_x := 58; uc_y := 101; hc_name := 'Farid Al-Hadi'; hc_class := class_scientistic;
        hc_gallery := 1; hc_face_number := 7;
        un_humans[5] := CreateHuman;
    end
    else
    begin
        uc_x := 58; uc_y := 101; hc_name := 'Wiktor Volkov'; hc_class := class_mechanic;
        hc_gallery := 1; hc_face_number := 6;
        un_humans[5] := CreateHuman;
    end;

    uc_side := 1; vc_chassis := us_heavy_tracked; vc_engine := engine_combustion; vc_control := control_manual; vc_weapon := us_heavy_gun;
    uc_x := 55; uc_y := 102; CreateVehicle;
    uc_x := 57; uc_y := 102; CreateVehicle;

    // 4 terminale b_lab strony 2 — 3 kody Mirona (Sokolov/Chen/Reyes) + master EON-2
    // Pozycje: 20,20 90,20 20,90 90,90
    uc_side := 2; bc_type := b_lab;
    uc_x := 20; uc_y := 20; un_terminals[0] := CreateBuilding;
    uc_x := 90; uc_y := 20; un_terminals[1] := CreateBuilding;
    uc_x := 20; uc_y := 90; un_terminals[2] := CreateBuilding;
    uc_x := 90; uc_y := 90; un_terminals[3] := CreateBuilding;

    // 8 autosektur b_turret strony 2 — pierścień wokół Eos 56,56
    bc_type := b_turret;
    uc_x := 40; uc_y := 40; un_turrets[0] := CreateBuilding;
    uc_x := 56; uc_y := 40; un_turrets[1] := CreateBuilding;
    uc_x := 72; uc_y := 40; un_turrets[2] := CreateBuilding;
    uc_x := 40; uc_y := 56; un_turrets[3] := CreateBuilding;
    uc_x := 72; uc_y := 56; un_turrets[4] := CreateBuilding;
    uc_x := 40; uc_y := 72; un_turrets[5] := CreateBuilding;
    uc_x := 56; uc_y := 72; un_turrets[6] := CreateBuilding;
    uc_x := 72; uc_y := 72; un_turrets[7] := CreateBuilding;

    // Skalowanie trudnością — terminale hack time, autosektury HP, timer
    if difficulty = 0 then // łatwy — 15s, słabe, hack 1=2 wyłączone, 25 min, można szturmować
    begin
        hack_need := 15;
        Hint('Łatwy: terminale 15s, autosektury słabe, hack 1=2 wyłączone, 25 min. Możesz szturmować. Sokolov łatwy.');
    end
    else if difficulty = 1 then // średni — 20s, mocne, hack 2=4, 20 min
    begin
        hack_need := 20;
        Hint('Średni: 20s, mocne, hack 2=4 wyłączone, 20 min, pod ostrzałem. Hack oszczędza ludzi.');
    end
    else // trudny — 30s, bardzo mocne, hack 4 dopiero, 15 min
    begin
        Hint('Trudny: 30s, bardzo mocne, hack 4 dopiero, 15 min, ciągły ostrzał. Szturm = śmierć.');
    end;

    ForceSay(un_humans[3], 'PZ13_01'); // Maya: "Terminal prosi o hasło..."
    CenterOnXY(56,100);
end;

// Hack terminali — Maya w strefie terminala (area_term1..4), postęp co 1s
export function HackPostep(idx, areaTerm);
begin
    if hacked[idx] = 0 and IsOK(un_humans[3]) and IsInArea(un_humans[3], areaTerm) then
    begin
        hack_prog[idx] := hack_prog[idx] + 1;
        if hack_prog[idx] >= hack_need then
        begin
            hacked[idx] := 1;
            hacked_cnt := hacked_cnt + 1;
            SetSide(un_terminals[idx], 1);
            Hint('Terminal przejęty! ' + hacked_cnt + '/4');
            // Efekty: Łatwy 1 terminal = 2 off, Średni 2=4, Trudny 4 dopiero
            if difficulty = 0 and hacked_cnt >= 1 then DisableTurrets(2);
            if difficulty = 1 and hacked_cnt = 2 then DisableTurrets(4);
            if difficulty = 2 and hacked_cnt = 4 then DisableTurrets(8);
            if hacked_cnt >= 4 then
            begin
                goal_state[0] := 2;
                goal_state[1] := 2;
                Hint('Pierścień Eos wyłączony! Droga do krateru otwarta.');
                SaveCharacters([un_humans[0], un_humans[1], un_humans[2], un_humans[3], un_humans[4]], 'pz_team');
                YouWin;
            end;
        end;
    end
    else if hacked[idx] = 0 then hack_prog[idx] := 0; // Maya odeszła — postęp reset
end;

export function DisableTurrets(count);
begin
    for t := 0 to count - 1 do
        if IsOK(un_turrets[t]) then SetSide(un_turrets[t], 0);
end;

Every 1$0 do
begin
    HackPostep(0, area_term1);
    HackPostep(1, area_term2);
    HackPostep(2, area_term3);
    HackPostep(3, area_term4);
end;

// Postapo: pierścień koncentryczny Mirona, terminale w rogach, Autosektury — hack zamiast szturmu ma sens
// 3 poziomy równocześnie — obligatoryjnie, solucja: docs/solucje/13 - Solucja - Baza Eos — Przedpola.pdf