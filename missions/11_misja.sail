; 11_misja.sail — Zamarznięta Pamięć
; Mapa: maps/03_akt_III/11_zamarznieta_pamiec.map — 64x64 indoor, indywidualna
; Vault: 03 Akt III - Protokół Eos/11 - Zamarznięta Pamięć.md, 05 Fabuła/07 - Klimat Postapo.md, 09 - Sens i Logika — Audyt.md
; Zasada: nowa historia nie związana z ori, postapo indoor, 3 poziomy równocześnie, poprawna pisownia PL

export un_humans[6];

int goal_state[3]; // 0=off 1=aktywny 2=done 3=fail
int halas_cd = 0; // cooldown alarmu (Trudny)

Starting
begin
    // cel 0: ODNAJDZ_RDZEN_EON2
    goal_state[0] := 1;

    // 5 pieszo — HT zostaje na zewnątrz (indoor)
    uc_side := 1; uc_nation := nation_american; uc_x := 32; uc_y := 60;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    hc_gallery := 1; hc_face_number := 1;
    un_humans[0] := CreateHuman;
    uc_x := 33; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    hc_gallery := 1; hc_face_number := 2;
    un_humans[1] := CreateHuman;
    uc_x := 34; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    hc_gallery := 1; hc_face_number := 3;
    un_humans[2] := CreateHuman;
    uc_x := 32; uc_y := 61; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    hc_gallery := 1; hc_face_number := 4;
    un_humans[3] := CreateHuman;
    uc_x := 33; uc_y := 61; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    hc_gallery := 1; hc_face_number := 5;
    un_humans[4] := CreateHuman;
    // Branch z 06 (TestVariable) — domyślnie Wiktor
    if TestVariable('rekrut_farid') then
    begin
        uc_x := 34; uc_y := 61; hc_name := 'Farid Al-Hadi'; hc_class := class_scientistic;
        hc_gallery := 1; hc_face_number := 7;
        un_humans[5] := CreateHuman;
    end
    else
    begin
        uc_x := 34; uc_y := 61; hc_name := 'Wiktor Volkov'; hc_class := class_mechanic;
        hc_gallery := 1; hc_face_number := 6;
        un_humans[5] := CreateHuman;
    end;

    // EON-2 rdzeń — area 32,10
    // Korytarze 2 kafle, wysokie ściany, ciemność 0.3 (oświetlenie map-side w Edytorze)

    // Skalowanie trudnością — patrole stasis RU w korytarzach
    uc_side := 2; uc_nation := nation_russian; hc_class := class_soldier;
    if difficulty = 0 then // łatwy — 6 wrogów
    begin
        uc_x := 20; uc_y := 40; CreateHuman; uc_x := 44; uc_y := 40; CreateHuman;
        uc_x := 20; uc_y := 25; CreateHuman; uc_x := 44; uc_y := 25; CreateHuman;
        uc_x := 28; uc_y := 15; CreateHuman; uc_x := 36; uc_y := 15; CreateHuman;
        Hint('Łatwy: ciemno, 6 wrogów stasis, bateria nielimit. Echo-baz podpowiada.');
    end
    else if difficulty = 1 then // średni — 10 wrogów
    begin
        uc_x := 20; uc_y := 40; CreateHuman; uc_x := 44; uc_y := 40; CreateHuman;
        uc_x := 20; uc_y := 25; CreateHuman; uc_x := 44; uc_y := 25; CreateHuman;
        uc_x := 28; uc_y := 15; CreateHuman; uc_x := 36; uc_y := 15; CreateHuman;
        uc_x := 24; uc_y := 32; CreateHuman; uc_x := 40; uc_y := 32; CreateHuman;
        uc_x := 24; uc_y := 20; CreateHuman; uc_x := 40; uc_y := 20; CreateHuman;
        Hint('Średni: ciemno, 10 wrogów CQB, bateria 60s (doładuj przy generatorze).');
    end
    else // trudny — 14 wrogów + alarm na strzał
    begin
        uc_x := 20; uc_y := 40; CreateHuman; uc_x := 44; uc_y := 40; CreateHuman;
        uc_x := 20; uc_y := 25; CreateHuman; uc_x := 44; uc_y := 25; CreateHuman;
        uc_x := 28; uc_y := 15; CreateHuman; uc_x := 36; uc_y := 15; CreateHuman;
        uc_x := 24; uc_y := 32; CreateHuman; uc_x := 40; uc_y := 32; CreateHuman;
        uc_x := 24; uc_y := 20; CreateHuman; uc_x := 40; uc_y := 20; CreateHuman;
        uc_x := 32; uc_y := 45; CreateHuman; uc_x := 32; uc_y := 35; CreateHuman;
        uc_x := 28; uc_y := 25; CreateHuman; uc_x := 36; uc_y := 25; CreateHuman;
        Hint('Trudny: ciemno, 14 wrogów, bateria 45s, 1 strzał = alarm. Tylko latarka i nóż.');
    end;

    // Latarka: oświetlenie map-side (Edytor) — SAIL nie ma CreateLight

    // Poprawka sensu 11: EON-2 leżał pod lodem 6 mies., sublimacja 09 go odsłoniła
    ForceSay(un_humans[0], 'PZ11_01'); // Elena: "Ciemno jak w dupie..."
    Wait(1$0);
    ForceSay(un_humans[1], 'PZ11_02'); // Yuri: "Latarka działa. Dopóki bateria..."
    CenterOnXY(32,60);
end;

// Bateria latarki — co 60s/45s spada na Średnim/Trudnym
Every 60$0 do
begin
    if difficulty = 1 then
    begin
        Hint('Bateria latarki słabnie — doładuj przy generatorze (32,30).');
        // SetLightRange 8->5
    end;
end;

Every 45$0 do
begin
    if difficulty = 2 then
    begin
        Hint('Bateria 45s! Doładuj!');
    end;
end;

// Alarm na Trudnym: strzał drużyny (Attacks) → 2 dodatkowych, max co 60s
Every 1$0 do
begin
    if halas_cd > 0 then halas_cd := halas_cd - 1;
    if difficulty = 2 and halas_cd = 0 then
    begin
        if IsOK(un_humans[0]) and Attacks(un_humans[0]) <> 0 then begin AlarmSpawn(un_humans[0]); end
        else if IsOK(un_humans[1]) and Attacks(un_humans[1]) <> 0 then begin AlarmSpawn(un_humans[1]); end
        else if IsOK(un_humans[2]) and Attacks(un_humans[2]) <> 0 then begin AlarmSpawn(un_humans[2]); end
        else if IsOK(un_humans[3]) and Attacks(un_humans[3]) <> 0 then begin AlarmSpawn(un_humans[3]); end
        else if IsOK(un_humans[4]) and Attacks(un_humans[4]) <> 0 then begin AlarmSpawn(un_humans[4]); end;
    end;
end;

export function AlarmSpawn(human);
begin
    uc_side := 2; uc_nation := nation_russian; hc_class := class_soldier;
    uc_x := GetX(human) + 10; uc_y := GetY(human); CreateHuman;
    uc_x := GetX(human) - 10; CreateHuman;
    Hint('Alarm! 1 strzał = wataha!');
    halas_cd := 60;
end;

Every 0$5 do
begin
    if IsInArea(un_humans[0], area_rdzen) or IsInArea(un_humans[1], area_rdzen) then
    begin
        goal_state[0] := 2;
        Hint('Rdzeń EON-2: log Mirona Karpova — kody do 13. Echo-baz: "Zapasowy moduł RU, błąd 47 km."');
        SaveCharacters([un_humans[0], un_humans[1], un_humans[2], un_humans[3], un_humans[4]], 'pz_team');
        YouWin;
    end;
end;

// Postapo indoor: 2 kafle szerokości, lód na kablach, mrugające co 7s, Echo-baz AI
// 3 poziomy równocześnie — obligatoryjnie, solucja: docs/solucje/11 - Solucja - Zamarznięta Pamięć.pdf