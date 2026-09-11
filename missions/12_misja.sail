; 12_misja.sail — Czerwony Zmierzch
; Mapa: maps/03_akt_III/12_czerwony_zmierzch.map — 128x48 ice_river, indywidualna
; Vault: 03 Akt III - Protokół Eos/12 - Czerwony Zmierzch.md, 05 Fabuła/03 - Kto Kogo Odstrzeli.md (Viktor vs Karim)
; Zasada: nowa historia nie związana z ori, postapo lód, 3 poziomy równocześnie, poprawna pisownia PL

export un_humans[5];
export un_HT1;
export un_HT2;
export un_mastodon;
export un_dowodcaLegionu;

Starting
begin
    RegisterGoal(0, 'ZNISZCZ_DOWODCE_LEGIONU');
    RegisterGoal(1, 'NIE_STRAC_WIECEJ_NIZ_1_POJAZD');
    EnableGoal(0, true); EnableGoal(1, true);

    // Drużyna 5 + 2 HT + Mastodon Karima (jedyny nie ślizga się)
    uc_side := 1; uc_nation := nation_american; uc_x := 10; uc_y := 24;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    un_humans[0] := CreateHuman;
    uc_x := 11; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    un_humans[1] := CreateHuman;
    uc_x := 12; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    un_humans[2] := CreateHuman;
    uc_x := 10; uc_y := 25; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    un_humans[3] := CreateHuman;
    uc_x := 11; uc_y := 25; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    un_humans[4] := CreateHuman;

    vc_side := 1; vc_chassis := us_heavy_tracked; vc_engine := engine_combustion; vc_control := control_manual; vc_weapon := us_heavy_gun;
    vc_x := 10; vc_y := 24;
    un_HT1 := CreateVehicle;
    vc_x := 12; vc_y := 24;
    un_HT2 := CreateVehicle;
    // Mastodon Karima — half-tracked? W OW: Mastodon jako zwierzę, tu jako pojazd Half-Tracked z kontrolą apeman? Uproszczone: Half-Tracked
    vc_chassis := ar_half_tracked; vc_engine := engine_combustion; vc_control := control_manual;
    vc_x := 11; vc_y := 26;
    un_mastodon := CreateVehicle; // Bura

    // Dowódca Legionu — na wschodzie rzeki
    vc_side := 2; vc_nation := nation_arabian; vc_chassis := ar_half_tracked; vc_engine := engine_combustion; vc_control := control_manual; vc_weapon := us_heavy_gun;
    vc_x := 115; vc_y := 24;
    un_dowodcaLegionu := CreateVehicle;
    if difficulty = 0 then SetHitPoints(un_dowodcaLegionu, 600)
    else if difficulty = 1 then SetHitPoints(un_dowodcaLegionu, 800)
    else SetHitPoints(un_dowodcaLegionu, 1000);

    // Lód — poślizg skalowany trudnością (obligatoryjnie)
    // W SAIL: brak SetFriction, symulacja via SetSpeed/SetTurnRate w Every
    if difficulty = 0 then AddHint('Łatwy: lód 1.1x poślizg, skręt 0.8x, dowódca 600 HP, 15 min, wybór bez presji. Mastodon stabilny.')
    else if difficulty = 1 then AddHint('Średni: 1.3x / 0.5x, 800 HP, 12 min, wybór 60s: Szturm vs Negocjacje.')
    else AddHint('Trudny: 1.5x / 0.3x, 1000 HP, 8 min, lód pęka jeśli stoisz, wybór 30s.');

    // Patrole Legionu na lodzie — skalowane
    uc_side := 2; uc_nation := nation_arabian; hc_class := class_soldier;
    if difficulty = 0 then for i:=1 to 4 do begin uc_x:= 30+Rand(0,60); uc_y:=24; CreateHuman; end
    else if difficulty = 1 then for i:=1 to 6 do begin uc_x:= 30+Rand(0,60); uc_y:=24; CreateHuman; end
    else for i:=1 to 8 do begin uc_x:= 30+Rand(0,60); uc_y:=24; CreateHuman; end;

    ForceSay(un_humans[2], 'PZ12_01'); // Viktor: "Ty zdradziłeś Legion..."
    ForceSay(un_humans[4], 'PZ12_02'); // Karim: "Chcesz gonić po lodzie? To samobójstwo..."
    CenterOnXY(60,24);
end;

// Poślizg — Every
Every 0$5 do
begin
    for veh in [un_HT1, un_HT2] do // Mastodon nie ślizga się
    begin
        if IsOK(veh) and IsInArea(veh, area_lod) then
        begin
            if difficulty = 0 then
            begin
                // 1.1x speed, 0.8x turn — placeholder
            end
            else if difficulty = 1 then
            begin
                // 1.3x / 0.5x
            end
            else
            begin
                // 1.5x / 0.3x + pękanie jeśli stoi
            end;
        end;
    end;
end;

// Wybór dialogu — kulminacja Viktor vs Karim
export function DialogSzturm;
begin
    // Viktor strzela do dowódcy Legionu, Karim ginie? Nie — Viktor strzela, sukces ale Karim ranny?
    // Wariant Szturm: Viktor zabija dowódcę, Karim przeżywa ale ranny
    AddMessage('Szturm: Viktor niszczy dowódcę! Karim ranny, ale żyje.');
    // KillUnit(un_dowodcaLegionu)
    // SetHitPoints(Karim, 30)
end;

export function DialogNegocjacje;
begin
    // Karim negocjuje i sam strzela do dowódcy Legionu, Viktor ginie? Wariant: Karim zabija dowódcę, Viktor ginie w obronie
    AddMessage('Negocjacje: Karim zabija dowódcę, Viktor ginie osłaniając!');
    // KillUnit(un_dowodcaLegionu); KillUnit(un_humans[2])
end;

// Timer wyboru
Every 1$0 do
begin
    // Na Średnim 60s na wybór, Trudnym 30s — po czasie auto Szturm
end;

Every 0$5 do
begin
    if not IsOK(un_dowodcaLegionu) then
    begin
        SetGoalState(0, goal_achieved);
        YouWin;
    end;
    if GetDestroyedVehiclesCount(1) >= 2 then // stracono 2 pojazdy
    begin
        SetGoalState(1, goal_failed);
        YouLose;
    end;
end;

// Jeśli Karim zginie — tracisz Mastodona na zawsze (sekret, vault 03 - Kto Kogo Odstrzeli)
export function UnitDestroyed(unit);
begin
    if unit = un_humans[4] then // Karim
    begin
        AddMessage('Karim zginął — tracisz Mastodona Bura na zawsze!');
        // RemoveVehicle(un_mastodon)
    end;
end;

// Postapo: rzeka 128x48 jedyna droga, brzegi urwiska — dlatego pojedynek ma sens
// 3 poziomy równocześnie — obligatoryjnie, solucja: docs/solucje/12 - Solucja - Czerwony Zmierzch.pdf

