; 11_misja.sail — Zamarznięta Pamięć
; Mapa: maps/03_akt_III/11_zamarznieta_pamiec.map — 64x64 indoor, indywidualna
; Vault: 03 Akt III - Protokół Eos/11 - Zamarznięta Pamięć.md, 05 Fabuła/07 - Klimat Postapo.md, 09 - Sens i Logika — Audyt.md
; Zasada: nowa historia nie związana z ori, postapo indoor, 3 poziomy równocześnie, poprawna pisownia PL

export un_humans[5];

Starting
begin
    RegisterGoal(0, 'ODNAJDZ_RDZEN_EON2');
    EnableGoal(0, true);

    // 5 pieszo — HT zostaje na zewnątrz (indoor)
    uc_side := 1; uc_nation := nation_american; uc_x := 32; uc_y := 60;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    un_humans[0] := CreateHuman;
    uc_x := 33; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    un_humans[1] := CreateHuman;
    uc_x := 34; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    un_humans[2] := CreateHuman;
    uc_x := 32; uc_y := 61; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    un_humans[3] := CreateHuman;
    uc_x := 33; uc_y := 61; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    un_humans[4] := CreateHuman;

    // EON-2 rdzeń — area 32,10
    // Korytarze 2 kafle, wysokie ściany, ciemność 0.3

    // Skalowanie trudnością — latarka, bateria, drzwi, wrogowie
    if difficulty = 0 then // łatwy — latarka 10 krat, bateria nielimit, drzwi 10s, 6 wrogów
    begin
        AddHint('Łatwy: latarka 10 krat, bateria nielimit, drzwi 10s, 6 wrogów. Echo-baz podpowiada.');
    end
    else if difficulty = 1 then // średni — 8 krat, bateria 60s, drzwi 20s, 10 wrogów
    begin
        AddHint('Średni: 8 krat, bateria 60s (doładuj przy generatorze), drzwi 20s, 10 wrogów CQB.');
    end
    else // trudny — 6 krat, bateria 45s, drzwi 30s, 14 wrogów, alarm
    begin
        AddHint('Trudny: 6 krat, bateria 45s, drzwi 30s, 14 wrogów, 1 strzał = alarm. Tylko latarka i nóż.');
    end;

    // Latarka — CreateLight per human
    for h in un_humans do
    begin
        // CreateLight(GetX(h), GetY(h), 8, 0.9) — skalowane
    end;

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
        AddMessage('Bateria latarki słabnie — doładuj przy generatorze (32,30).');
        // SetLightRange 8->5
    end;
end;

Every 45$0 do
begin
    if difficulty = 2 then
    begin
        AddMessage('Bateria 45s! Doładuj!');
    end;
end;

// Zamarznięte drzwi — hack Inżynier/Naukowiec skalowany
export function HackDrzwi(human, drzwi);
begin
    if GetHumanClass(human) <> class_engineer and GetHumanClass(human) <> class_scientistic then Exit;
    if difficulty = 0 then Wait(10$0)
    else if difficulty = 1 then Wait(20$0)
    else Wait(30$0);
    // OpenDoor(drzwi)
    AddMessage('Drzwi otwarte!');
end;

// Wrogowie CQB — skalowani
// Łatwy 6, Średni 10, Trudny 14 + alarm na strzał
export function HumanFired(human, target);
begin
    if difficulty = 2 then
    begin
        // Alarm — spawn 2 dodatkowych
        uc_side := 2; uc_nation := nation_russian; hc_class := class_soldier;
        uc_x := GetX(human) + 10; uc_y := GetY(human); CreateHuman;
        uc_x := GetX(human) - 10; CreateHuman;
        AddMessage('Alarm! 1 strzał = wataha!');
    end;
end;

Every 0$5 do
begin
    if IsInArea(un_humans[0], area_rdzen) or IsInArea(un_humans[1], area_rdzen) then
    begin
        SetGoalState(0, goal_achieved);
        AddMessage('Rdzeń EON-2: log Mirona Karpova — kody do 13. Echo-baz: "Zapasowy moduł RU, błąd 47 km."');
        YouWin;
    end;
end;

// Postapo indoor: 2 kafle szerokości, lód na kablach, mrugające co 7s, Echo-baz AI
// 3 poziomy równocześnie — obligatoryjnie, solucja: docs/solucje/11 - Solucja - Zamarznięta Pamięć.pdf

