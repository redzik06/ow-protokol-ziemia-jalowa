; 15_misja.sail — Ostatni Świt — FINAŁ
; Mapa: maps/03_akt_III/15_ostatni_swit.map — 80x80 indoor_server, indywidualna
; Vault: 03 Akt III - Protokół Eos/15 - Ostatni Świt.md, 05 Fabuła/03 - Kto Kogo Odstrzeli.md, 01 - Bohaterowie Drużyny.md (3 zakończenia via CountScientists/CountMechanics)
; Zasada: nowa historia nie związana z ori, postapo finał, 3 poziomy równocześnie, poprawna pisownia PL, persistent decyduje

int filtrHP = 800;
int filtrTime = 60;
int filtr_prog = 0; // postęp hacku filtra (Yuri/Farid w area_terminal)
int jest_farid = 0; // 1 = branch Farid (TestVariable), 0 = Wiktor/default
int final_event = 0; // konfrontacja z Alyą — raz

export un_humans[6];
export un_filtr;
export un_terminal;
export un_alya;

int goal_state[3]; // 0=off 1=aktywny 2=done 3=fail

Starting
begin
    // cel 0: URUCHOM_FILTR_60S
    // cel 1: OBRONA_10MIN
    goal_state[0] := 1;

    // Tylko żywi z 01-14 — persistent campaign recall
    // W prototypie tworzymy 5, w pełnej kampanii będą ImportCharacters — tylko żywi
    uc_side := 1; uc_nation := nation_american; uc_x := 40; uc_y := 70;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    hc_gallery := 1; hc_face_number := 1;
    un_humans[0] := CreateHuman;
    uc_x := 41; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    hc_gallery := 1; hc_face_number := 2;
    un_humans[1] := CreateHuman;
    uc_x := 42; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    hc_gallery := 1; hc_face_number := 3;
    un_humans[2] := CreateHuman;
    uc_x := 40; uc_y := 71; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    hc_gallery := 1; hc_face_number := 4;
    un_humans[3] := CreateHuman;
    uc_x := 41; uc_y := 71; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    hc_gallery := 1; hc_face_number := 5;
    un_humans[4] := CreateHuman;
    // Branch z 06 (TestVariable) — domyślnie Wiktor
    if TestVariable('rekrut_farid') then
    begin
        jest_farid := 1;
        uc_x := 42; uc_y := 71; hc_name := 'Farid Al-Hadi'; hc_class := class_scientistic;
        hc_gallery := 1; hc_face_number := 7;
        un_humans[5] := CreateHuman;
    end
    else
    begin
        uc_x := 42; uc_y := 71; hc_name := 'Wiktor Volkov'; hc_class := class_mechanic;
        hc_gallery := 1; hc_face_number := 6;
        un_humans[5] := CreateHuman;
    end;
    // Alya Hassan — finałowa konfrontacja (twarz 8)
    uc_side := 2; uc_nation := nation_arabian; uc_x := 40; uc_y := 15;
    hc_name := 'Alya Hassan'; hc_class := class_soldier; hc_sex := sex_female;
    hc_gallery := 1; hc_face_number := 8;
    un_alya := CreateHuman;

    // Filtr b_siberite_power + terminal — HP i czas skalowane trudnością (obligatoryjnie)
    uc_side := 1; bc_type := b_siberite_power; uc_x := 40; uc_y := 40;
    un_filtr := CreateBuilding;
    bc_type := b_lab; uc_x := 40; uc_y := 45;
    un_terminal := CreateBuilding;

    if difficulty = 0 then // łatwy — wybacza, filtr 1200 HP, 40s, 12 min, mało wrogów
    begin
        filtrHP := 1200; filtrTime := 40;
        Hint('Łatwy: filtr 1200 HP, 40s hack, 12 min, fale 4. Wybaczający.');
    end
    else if difficulty = 1 then // średni — finałowy test składu, 800 HP, 60s, 10 min
    begin
        filtrHP := 800; filtrTime := 60;
        Hint('Średni: 800 HP, 60s, 10 min. Finałowy test składu — tylko ocaleni.');
    end
    else // trudny — brutalny, 400 HP, 90s, 8 min, fale non-stop, brak crates
    begin
        filtrHP := 400; filtrTime := 90;
        Hint('Trudny: 400 HP, 90s, 8 min, fale 8 non-stop, brak ammo. Brutalny.');
    end;
    SetLives([un_filtr], filtrHP);

    // Wrogowie — Legion + RU resztki — skalowani
    // Łatwy 4 co 120s, Średni 6 co 90s, Trudny 8 co 60s non-stop

    ForceSay(un_humans[0], 'PZ15_01'); // Elena vs Alya
    ForceSay(un_humans[4], 'PZ15_02'); // Karim?
    CenterOnXY(40,40);
end;

// Uruchomienie filtra — Yuri (un_humans[1]) lub Farid (branch) w area_terminal
// Postęp co 1s do filtrTime (40/60/90); start postępu = konfrontacja z Alyą (raz)
Every 1$0 do
begin
    if goal_state[0] = 1 and IsOK(un_filtr) then
    begin
        if (IsOK(un_humans[1]) and IsInArea(un_humans[1], area_terminal))
            or (jest_farid = 1 and IsOK(un_humans[5]) and IsInArea(un_humans[5], area_terminal)) then
        begin
            if filtr_prog = 0 then
            begin
                Hint('Uruchamianie filtra... ' + filtrTime + 's');
                FinalConfrontation;
            end;
            filtr_prog := filtr_prog + 1;
            if filtr_prog >= filtrTime then Zakonczenie;
        end;
    end;
end;

// Konfrontacja z Alyą — raz: Farid zdradza mentorkę (branch) albo Elena ją zabija
export function FinalConfrontation;
begin
    final_event := 1;
    if jest_farid = 1 and IsOK(un_humans[5]) and IsOK(un_alya) then
    begin
        Hint('Farid -> Alya: zdrada mentorki, oboje giną. Odblokowuje A.');
        KillUnit(un_alya);
        KillUnit(un_humans[5]);
    end
    else if IsOK(un_alya) then
    begin
        Hint('Elena -> Alya: koniec Legionu.');
        KillUnit(un_alya);
    end;
end;

function CountScientists: Integer;
begin
    Result := 0;
    if IsOK(un_humans[1]) then Result := Result + 1; // Yuri
    if jest_farid = 1 and IsOK(un_humans[5]) then Result := Result + 1; // Farid
end;

function CountMechanics: Integer;
begin
    Result := 0;
    if IsOK(un_humans[0]) then Result := Result + 1; // Elena
    if IsOK(un_humans[2]) then Result := Result + 1; // Viktor
    if jest_farid = 0 and IsOK(un_humans[5]) then Result := Result + 1; // Wiktor
end;

// 3 zakończenia — skład żywych decyduje
export function Zakonczenie;
begin
    if CountScientists >= 2 then
    begin
        // Zakończenie A Sojusz — filtr ocala Motherlode
        Hint('Zakończenie A: Sojusz — filtr stabilny, Motherlode ocalony, osada Sojusz+Apemeni.');
        goal_state[0] := 2;
        YouWin;
    end
    else if CountMechanics >= 2 then
    begin
        // Zakończenie B Legion — twierdza
        Hint('Zakończenie B: Legion — EON-2 jako twierdza, handel Syberytem.');
        goal_state[0] := 2;
        YouWin;
    end
    else
    begin
        // Zakończenie C Jałowa — filtr 20%, rozproszenie
        Hint('Zakończenie C: Ziemia Jałowa — filtr 20%, niecka jałowa, epoka kamienia.');
        goal_state[0] := 2; // i tak win, ale smutny
        YouWin;
    end;
end;

// Fale finałowe — skalowane
Every 120$0 do
begin
    if difficulty = 0 and (goal_state[0] = 1) then SpawnWave(4);
end;
Every 90$0 do
begin
    if difficulty = 1 and (goal_state[0] = 1) then SpawnWave(6);
end;
Every 60$0 do
begin
    if difficulty = 2 and (goal_state[0] = 1) then SpawnWave(8);
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

Every 0$5 do
begin
    if GetLives([un_filtr]) <= 0 then
    begin
        Hint('Filtr zniszczony! Ziemia Jałowa!');
        YouLost('PZ15_FILTR');
    end;
end;

// Postapo finał: serwerownia b_siberite_power + filtr — serce EON-2, wąskie wejścia do obrony, brak wsparcia
// 3 poziomy równocześnie — obligatoryjnie, 3 zakończenia — persistent decyduje
// Solucja lista: docs/solucje/15 - Solucja - Ostatni Świt.pdf (3 warianty Ł/Ś/T + 3 zakończenia)