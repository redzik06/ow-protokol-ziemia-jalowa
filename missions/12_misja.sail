; 12_misja.sail — Czerwony Zmierzch
; Mapa: maps/03_akt_III/12_czerwony_zmierzch.map — 128x48 ice_river, indywidualna
; Vault: 03 Akt III - Protokół Eos/12 - Czerwony Zmierzch.md, 05 Fabuła/03 - Kto Kogo Odstrzeli.md (Viktor vs Karim)
; Zasada: nowa historia nie związana z ori, postapo lód, 3 poziomy równocześnie, poprawna pisownia PL

export un_humans[6];
export un_HT1;
export un_HT2;
export un_mastodon;
export un_dowodcaLegionu;

int goal_state[3]; // 0=off 1=aktywny 2=done 3=fail
int stracone = 0; // stracone pojazdy gracza (VehicleDestroyed)
int wybor12 = 0; // 0=brak, 1=Szturm, 2=Negocjacje
int wybor_left = 0; // timer wyboru (Ś 60s, T 30s)

Starting
begin
    // cel 0: ZNISZCZ_DOWODCE_LEGIONU
    // cel 1: NIE_STRAC_WIECEJ_NIZ_1_POJAZD
    goal_state[0] := 1; goal_state[1] := 1;

    // Drużyna 5 + 2 HT + Mastodon Karima (jedyny nie ślizga się)
    uc_side := 1; uc_nation := nation_american; uc_x := 10; uc_y := 24;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    hc_gallery := 1; hc_face_number := 1;
    un_humans[0] := CreateHuman;
    uc_x := 11; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    hc_gallery := 1; hc_face_number := 2;
    un_humans[1] := CreateHuman;
    uc_x := 12; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    hc_gallery := 1; hc_face_number := 3;
    un_humans[2] := CreateHuman;
    uc_x := 10; uc_y := 25; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    hc_gallery := 1; hc_face_number := 4;
    un_humans[3] := CreateHuman;
    uc_x := 11; uc_y := 25; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    hc_gallery := 1; hc_face_number := 5;
    un_humans[4] := CreateHuman;
    // Branch z 06 (TestVariable) — domyślnie Wiktor
    if TestVariable('rekrut_farid') then
    begin
        uc_x := 12; uc_y := 25; hc_name := 'Farid Al-Hadi'; hc_class := class_scientistic;
        hc_gallery := 1; hc_face_number := 7;
        un_humans[5] := CreateHuman;
    end
    else
    begin
        uc_x := 12; uc_y := 25; hc_name := 'Wiktor Volkov'; hc_class := class_mechanic;
        hc_gallery := 1; hc_face_number := 6;
        un_humans[5] := CreateHuman;
    end;

    uc_side := 1; vc_chassis := us_heavy_tracked; vc_engine := engine_combustion; vc_control := control_manual; vc_weapon := us_heavy_gun;
    uc_x := 10; uc_y := 24;
    un_HT1 := CreateVehicle;
    uc_x := 12; uc_y := 24;
    un_HT2 := CreateVehicle;
    // Mastodon Karima — half-tracked? W OW: Mastodon jako zwierzę, tu jako pojazd Half-Tracked z kontrolą apeman? Uproszczone: Half-Tracked
    vc_chassis := ar_half_tracked; vc_engine := engine_combustion; vc_control := control_manual;
    uc_x := 11; uc_y := 26;
    un_mastodon := CreateVehicle; // Bura

    // Dowódca Legionu — na wschodzie rzeki
    uc_side := 2; uc_nation := nation_arabian; vc_chassis := ar_half_tracked; vc_engine := engine_combustion; vc_control := control_manual; vc_weapon := us_heavy_gun;
    uc_x := 115; uc_y := 24;
    un_dowodcaLegionu := CreateVehicle;
    if difficulty = 0 then SetLives([un_dowodcaLegionu], 600)
    else if difficulty = 1 then SetLives([un_dowodcaLegionu], 800)
    else SetLives([un_dowodcaLegionu], 1000);

    // Lód — poślizg zapewnia silnik na kaflach lodu (map-side); SAIL dokłada stress na Trudnym
    if difficulty = 0 then Hint('Łatwy: lód śliski, dowódca 600 HP, wybór bez presji. Mastodon stabilny.')
    else if difficulty = 1 then begin Hint('Średni: lód śliski, 800 HP, wybór 60s: Szturm vs Negocjacje.'); wybor_left := 60; end
    else begin Hint('Trudny: lód śliski i pęka (HT traci HP na lodzie), 1000 HP, wybór 30s.'); wybor_left := 30; end;

    // Patrole Legionu na lodzie — skalowane
    uc_side := 2; uc_nation := nation_arabian; hc_class := class_soldier;
    if difficulty = 0 then for i:=1 to 4 do begin uc_x:= 30+Rand(0,60); uc_y:=24; CreateHuman; end
    else if difficulty = 1 then for i:=1 to 6 do begin uc_x:= 30+Rand(0,60); uc_y:=24; CreateHuman; end
    else for i:=1 to 8 do begin uc_x:= 30+Rand(0,60); uc_y:=24; CreateHuman; end;

    DialogueOn;
    ForceSay(un_humans[2], 'PZ12_01'); // Viktor: "Ty zdradziłeś Legion..."
    ForceSay(un_humans[4], 'PZ12_02'); // Karim: "Chcesz gonić po lodzie? To samobójstwo..."
    CenterOnXY(60,24);
    DialogueOff;
    ChangeMissionObjectives('OBJ_12');
    SaveForQuickRestart;
end;

// Lód pęka na Trudnym: HT na lodzie traci 1 HP/s (Mastodon nie)
Every 1$0 do
begin
    if difficulty = 2 then
    begin
        if IsOK(un_HT1) and IsInArea(un_HT1, area_lod) then SetLives([un_HT1], GetLives([un_HT1]) - 1);
        if IsOK(un_HT2) and IsInArea(un_HT2, area_lod) then SetLives([un_HT2], GetLives([un_HT2]) - 1);
    end;
end;

// Wybór dialogu — kulminacja Viktor vs Karim (BuildQuery w strefie wyboru)
Every 1$0 do
begin
    if wybor12 = 0 then
    begin
        if wybor_left > 0 then
        begin
            wybor_left := wybor_left - 1;
            if wybor_left = 0 then begin wybor12 := 1; DialogSzturm; end; // timeout = Szturm
        end;
        if IsInArea(un_HT1, area_wybor) or IsInArea(un_HT2, area_wybor) then
        begin
            if BuildQuery('SZTURM czy NEGOCJACJE?', ['Szturm', 'Negocjacje']) = 1 then begin wybor12 := 1; DialogSzturm; end
            else begin wybor12 := 2; DialogNegocjacje; end;
        end;
    end;
end;

export function DialogSzturm;
begin
    // Wariant Szturm: Viktor zabija dowódcę, Karim ranny
    Hint('Szturm: Viktor niszczy dowódcę! Karim ranny, ale żyje.');
    KillUnit(un_dowodcaLegionu);
    if IsOK(un_humans[4]) then SetLives([un_humans[4]], 30);
end;

export function DialogNegocjacje;
begin
    // Wariant Negocjacje: Karim zabija dowódcę, Viktor ginie osłaniając
    Hint('Negocjacje: Karim zabija dowódcę, Viktor ginie osłaniając!');
    KillUnit(un_dowodcaLegionu);
    if IsOK(un_humans[2]) then KillUnit(un_humans[2]);
end;

// Licznik strat pojazdów (prawdziwy event VehicleDestroyed)
export function VehicleDestroyed(un, side, nation, x, y, direction, chass, control, engine, weap);
begin
    if side = 1 then
    begin
        stracone := stracone + 1;
        if stracone >= 2 then goal_state[1] := 3;
    end;
end;

Every 0$5 do
begin
    if not IsOK(un_dowodcaLegionu) then
    begin
        goal_state[0] := 2;
        SaveCharacters([un_humans[0], un_humans[1], un_humans[2], un_humans[3], un_humans[4]], 'pz_team');
        YouWin;
    end;
    if stracone >= 2 then // stracono 2 pojazdy
    begin
        goal_state[1] := 3;
        YouLost('PZ12_POJAZDY');
    end;
end;

// Jeśli Karim zginie — tracisz Mastodona na zawsze (sekret, vault 03 - Kto Kogo Odstrzeli)
export function UnitDestroyed(un);
begin
    if un = un_humans[4] then // Karim
    begin
        Hint('Karim zginął — tracisz Mastodona Bura na zawsze!');
        if IsOK(un_mastodon) then DestroyUnit(un_mastodon);
    end;
end;

// Postapo: rzeka 128x48 jedyna droga, brzegi urwiska — dlatego pojedynek ma sens
// 3 poziomy równocześnie — obligatoryjnie, solucja: docs/solucje/12 - Solucja - Czerwony Zmierzch.pdf
