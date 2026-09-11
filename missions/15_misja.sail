; 15_misja.sail — Ostatni Świt — FINAŁ
; Mapa: maps/03_akt_III/15_ostatni_swit.map — 80x80 indoor_server, indywidualna
; Vault: 03 Akt III - Protokół Eos/15 - Ostatni Świt.md, 05 Fabuła/03 - Kto Kogo Odstrzeli.md, 01 - Bohaterowie Drużyny.md (3 zakończenia via CountProfession)
; Zasada: nowa historia nie związana z ori, postapo finał, 3 poziomy równocześnie, poprawna pisownia PL, persistent decyduje

int filtrHP = 800;
int filtrTime = 60;

export un_humans[5];
export un_filtr;
export un_terminal;

Starting
begin
    RegisterGoal(0, 'URUCHOM_FILTR_60S');
    RegisterGoal(1, 'OBRONA_10MIN');
    EnableGoal(0, true);

    // Tylko żywi z 01-14 — persistent campaign recall
    // W prototypie tworzymy 5, w pełnej kampanii będą ImportCharacters — tylko żywi
    uc_side := 1; uc_nation := nation_american; uc_x := 40; uc_y := 70;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    un_humans[0] := CreateHuman;
    uc_x := 41; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    un_humans[1] := CreateHuman;
    uc_x := 42; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    un_humans[2] := CreateHuman;
    uc_x := 40; uc_y := 71; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    un_humans[3] := CreateHuman;
    uc_x := 41; uc_y := 71; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    un_humans[4] := CreateHuman;
    // Branch Wiktor/Farid via GetGlobalVar
    if GetGlobalVar('rekrut_06') = 1 then
    begin
        uc_x := 42; uc_y := 71; hc_name := 'Wiktor Volkov'; hc_class := class_mechanic;
        CreateHuman;
    end
    else if GetGlobalVar('rekrut_06') = 2 then
    begin
        uc_x := 42; uc_y := 71; hc_name := 'Farid Al-Hadi'; hc_class := class_scientistic;
        CreateHuman;
    end;

    // Filtr b_siberite_power + terminal — HP i czas skalowane trudnością (obligatoryjnie)
    bc_side := 1; bc_type := b_siberite_power; bc_x := 40; bc_y := 40;
    un_filtr := CreateBuilding;
    bc_type := b_lab; bc_x := 40; bc_y := 45;
    un_terminal := CreateBuilding;

    if difficulty = 0 then // łatwy — wybacza, filtr 1200 HP, 40s, 12 min, mało wrogów
    begin
        filtrHP := 1200; filtrTime := 40;
        AddHint('Łatwy: filtr 1200 HP, 40s hack, 12 min, fale 4. Wybaczający.');
    end
    else if difficulty = 1 then // średni — finałowy test składu, 800 HP, 60s, 10 min
    begin
        filtrHP := 800; filtrTime := 60;
        AddHint('Średni: 800 HP, 60s, 10 min. Finałowy test składu — tylko ocaleni.');
    end
    else // trudny — brutalny, 400 HP, 90s, 8 min, fale non-stop, brak crates
    begin
        filtrHP := 400; filtrTime := 90;
        AddHint('Trudny: 400 HP, 90s, 8 min, fale 8 non-stop, brak ammo. Brutalny.');
    end;
    SetHitPoints(un_filtr, filtrHP);

    // Wrogowie — Legion + RU resztki — skalowani
    // Łatwy 4 co 120s, Średni 6 co 90s, Trudny 8 co 60s non-stop

    ForceSay(un_humans[0], 'PZ15_01'); // Elena vs Alya
    ForceSay(un_humans[4], 'PZ15_02'); // Karim?
    CenterOnXY(40,40);
end;

// Uruchomienie filtra — tylko Naukowiec (Yuri/Farid) przy terminalu, czas skalowany
export function UruchomFiltr(human);
begin
    if GetHumanClass(human) <> class_scientistic then
    begin
        AddMessage('Tylko Naukowiec (Yuri/Farid) uruchamia filtr.');
        Exit;
    end;
    if not FilterUnitsInArea(area_terminal, GetSide(human)) then Exit;
    AddMessage('Uruchamianie filtra... ' + IntToStr(filtrTime) + 's');
    Wait(filtrTime$0);
    // Sprawdź kto żyje — 3 zakończenia via CountProfession
    int naukowcy := CountProfession(class_scientistic);
    int mechanicy := CountProfession(class_mechanic);
    // CountProfession custom — liczy IsOK i class
    if naukowcy >= 2 then
    begin
        // Zakończenie A Sojusz — filtr ocala Motherlode
        AddMessage('Zakończenie A: Sojusz — filtr stabilny, Motherlode ocalony, osada Sojusz+Apemeni.');
        // PlayVideo A
        SetGoalState(0, goal_achieved);
        YouWin;
    end
    else if mechanicy >= 2 then
    begin
        // Zakończenie B Legion — twierdza
        AddMessage('Zakończenie B: Legion — EON-2 jako twierdza, handel Syberytem.');
        SetGoalState(0, goal_achieved);
        YouWin;
    end
    else
    begin
        // Zakończenie C Jałowa — filtr 20%, rozproszenie
        AddMessage('Zakończenie C: Ziemia Jałowa — filtr 20%, niecka jałowa, epoka kamienia.');
        SetGoalState(0, goal_achieved); // i tak win, ale smutny
        YouWin;
    end;
end;

function CountProfession(prof): Integer;
begin
    Result := 0;
    for h in un_humans do if IsOK(h) and GetHumanClass(h) = prof then Result := Result + 1;
    // + Wiktor/Farid
end;

// Fale finałowe — skalowane
Every 120$0 do
begin
    if difficulty = 0 and IsGoalEnabled(0) then SpawnWave(4);
end;
Every 90$0 do
begin
    if difficulty = 1 and IsGoalEnabled(0) then SpawnWave(6);
end;
Every 60$0 do
begin
    if difficulty = 2 and IsGoalEnabled(0) then SpawnWave(8);
end;

export function SpawnWave(count);
begin
    uc_side := 2; uc_nation := nation_arabian; hc_class := class_soldier;
    for i:=1 to count do
    begin
        uc_x := 40 + Rand(-20,20); uc_y := 10; CreateHuman;
    end;
    // Na Trudnym brak ammo crates
end;

// Elena vs Alya — finał (vault 03 - Kto Kogo Odstrzeli)
export function Finał_Elena_vs_Alya;
begin
    // Jeśli Farid żyje — on zdradza Alyę i ginie z nią, odblokowuje A
    if GetGlobalVar('rekrut_06') = 2 and IsOK(un_humans[5]) then
    begin
        AddMessage('Farid → Alya: zdrada mentorki, oboje giną. Odblokowuje A.');
    end;
    // Else Elena → Alya
end;

Every 0$5 do
begin
    if GetHitPoints(un_filtr) <= 0 then
    begin
        AddMessage('Filtr zniszczony! Ziemia Jałowa!');
        YouLose;
    end;
end;

// Postapo finał: serwerownia b_siberite_power + filtr — serce EON-2, wąskie wejścia do obrony, brak wsparcia
// 3 poziomy równocześnie — obligatoryjnie, 3 zakończenia — persistent decyduje
// Solucja lista: docs/solucje/15 - Solucja - Ostatni Świt.pdf (3 warianty Ł/Ś/T + 3 zakończenia)

