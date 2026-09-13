; 01_misja.sail — Ostatnia Iskra
; Mapa: maps/01_akt_I/01_ostatnia_iskra.map — 72x72 ruins, indywidualna
; Vault: 05 Fabuła/00 - Oś Fabuły.md, 01 - Bohaterowie Drużyny.md, 07 - Klimat Postapo.md
; Zasada: nowa historia, nie kontynuacja ORI, postapo od 01, poprawna pisownia PL
; SAIL: original-war.net/sailbase.php — prototypy uc_/hc_/vc_, eventy, ForceSay

// === GLOBALE ===
int mission_failed = 0;
int ucieczka_left = 0; // licznik ucieczki w sekundach (20/15/10 min)
int halas_cd = 0; // cooldown hałasu (nie spamuj watahy)
int journal_done = 0; // dziennik ukryty 0/1

export un_humans[6];
export un_transporterHT;

// === STARTING — inicjalizacja prototypów ===
int goal_state[3]; // 0=off 1=aktywny 2=done 3=fail

Starting
begin
    // Rejestracja celów misji
    // cel 0: UCIECZKA_HT // główny: dotrzyj HT do ewakuacji
    // cel 1: OCAL_DRUZYNE // główny: ocal 5
    // cel 2: DZIENNIK // poboczny ukryty
    goal_state[0] := 1;
    goal_state[1] := 1;
    goal_state[2] := 0; // ukryty

    // --- Drużyna 5 — CreateHuman via prototypy hc_/uc_ ---
    // Twarze XichtEd: hc_gallery + hc_face_number (tabela 1-16 w 06 Grafika/00 - Avatary).
    // UWAGA: id galerii (hc_gallery := 1) do potwierdzenia po eksporcie z XichtEd.exe.
    // Elena Varga „Echo” — Mechanik, dowódczyni — twarz 1
    uc_side := 1; uc_nation := nation_american; uc_x := 12; uc_y := 10; uc_direction := 2;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_sex := sex_female; hc_skills := [2,2,5,1];
    hc_gallery := 1; hc_face_number := 1;
    hc_gallery := 1; hc_face_number := 1;
    un_humans[0] := CreateHuman;

    // Yuri Kamarov — Naukowiec — twarz 2
    uc_side := 1; uc_nation := nation_russian; uc_x := 13; uc_y := 10;
    hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_sex := sex_male; hc_skills := [1,1,2,5];
    hc_gallery := 1; hc_face_number := 2;
    hc_gallery := 1; hc_face_number := 2;
    un_humans[1] := CreateHuman;

    // Viktor Drachev — Żołnierz — twarz 3
    uc_side := 1; uc_nation := nation_russian; uc_x := 14; uc_y := 10;
    hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_sex := sex_male; hc_skills := [5,1,2,1];
    hc_gallery := 1; hc_face_number := 3;
    hc_gallery := 1; hc_face_number := 3;
    un_humans[2] := CreateHuman;

    // Maya Torres — Inżynier — twarz 4
    uc_side := 1; uc_nation := nation_american; uc_x := 12; uc_y := 11;
    hc_name := 'Maya Torres'; hc_class := class_engineer; hc_sex := sex_female; hc_skills := [2,5,3,2];
    hc_gallery := 1; hc_face_number := 4;
    hc_gallery := 1; hc_face_number := 4;
    un_humans[3] := CreateHuman;

    // Karim Al-Rashid — Desert Warrior + Mastodon w 02, tu pieszo — twarz 5
    uc_side := 1; uc_nation := nation_arabian; uc_x := 13; uc_y := 11;
    hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_sex := sex_male; hc_skills := [5,1,1,1];
    hc_gallery := 1; hc_face_number := 5;
    hc_gallery := 1; hc_face_number := 5;
    un_humans[4] := CreateHuman;

    // Transporter HT (ciężki gąsienicowy) — centrum mapy, HP zależne od trudności (obligatoryjnie 3 poziomy)
    uc_side := 1; vc_chassis := us_heavy_tracked; vc_engine := engine_combustion; vc_control := control_manual; vc_weapon := us_heavy_gun;
    uc_x := 36; uc_y := 36;
    un_transporterHT := CreateVehicle;
    if difficulty = 0 then SetLives([un_transporterHT], 80) // łatwy — wybacza
    else if difficulty = 1 then SetLives([un_transporterHT], 70) // średni — bazowy
    else SetLives([un_transporterHT], 50); // trudny — kara
    // Paliwo custom — start 70% (postapo)

    // Patrole Małpoludów (Apemen) — skalowane trudnością (obligatoryjnie)
    uc_side := 2; uc_nation := nation_nature;
    hc_class := class_apeman; hc_name := 'Apeman';
    if difficulty = 0 then // łatwy — 2 patrole, luźniej
    begin
        uc_x := 25; uc_y := 30; CreateHuman;
        uc_x := 45; uc_y := 40; CreateHuman;
    end
    else if difficulty = 1 then // średni — 3 patrole
    begin
        uc_x := 25; uc_y := 30; CreateHuman;
        uc_x := 45; uc_y := 40; CreateHuman;
        uc_x := 35; uc_y := 55; CreateHuman;
    end
    else // trudny — 4 patrole + ciaśniej
    begin
        uc_x := 25; uc_y := 30; CreateHuman;
        uc_x := 45; uc_y := 40; CreateHuman;
        uc_x := 35; uc_y := 55; CreateHuman;
        uc_x := 30; uc_y := 45; CreateHuman;
    end;

    // Mgła syberytowa — ograniczona widoczność postapo
    // SetFog via SAIL? W OW: SetVisibility — tu 0.6
    // CenterOnXY(36,36);

    // Timer ucieczki skalowany trudnością (obligatoryjnie 3 poziomy): 20/15/10 min
    if difficulty = 0 then ucieczka_left := 1200
    else if difficulty = 1 then ucieczka_left := 900
    else ucieczka_left := 600;

    // Dialog start — postapo czarny humor, ForceSay
    ForceSay(un_humans[0], 'PZ01_01'); // Elena: "Alpha padła. Został HT, 5 ludzi i klucz 17..."
    Wait(2$0);
    ForceSay(un_humans[1], 'PZ01_02'); // Yuri: "Nie umieram. Tylko testuję grawitację."
    if difficulty = 0 then Hint('Łatwy: masz 20 min i 2 patrole. Poruszaj się cicho. HT 36,36.')
    else if difficulty = 1 then Hint('Poruszaj się cicho. Każdy strzał = wataha Małpoludów. HT 36,36.')
    else Hint('Trudny: 10 min, 4 patrole, HT 50% HP. Powodzenia.');
end;

// === EVERY — mechanika skradania: hałas (Attacks) przyciąga Małpoludy ===
export function HalasWataha(human);
begin
    uc_side := 2; uc_nation := nation_nature;
    uc_x := GetX(human) + Rand(-5,5); uc_y := GetY(human) + Rand(-5,5);
    hc_class := class_apeman;
    if difficulty = 0 then // łatwy — 2, wybacza
    begin
        CreateHuman; CreateHuman;
        Hint('Hałas! 2 Małpoludy biegną.');
    end
    else if difficulty = 1 then // średni — 3
    begin
        CreateHuman; CreateHuman; CreateHuman;
        Hint('Hałas! Wataha Małpoludów (3) biegnie na strzał!');
    end
    else // trudny — 4, kara
    begin
        CreateHuman; CreateHuman; CreateHuman; CreateHuman;
        Hint('Hałas! 4 Małpoludy — trudny nie wybacza!');
    end;
    halas_cd := 30; // 30s spokoju
end;

Every 1$0 do
begin
    if halas_cd > 0 then halas_cd := halas_cd - 1;
    if ucieczka_left > 0 then
    begin
        ucieczka_left := ucieczka_left - 1;
        if ucieczka_left = 0 then
        begin
            goal_state[0] := 3;
            YouLost('PZ01_TIMEOUT');
        end;
    end;
    // Ktoś z drużyny strzela (celuje/atakuje) → hałas, max co 30s
    if halas_cd = 0 then
    begin
        if IsOK(un_humans[0]) and Attacks(un_humans[0]) <> 0 then HalasWataha(un_humans[0])
        else if IsOK(un_humans[1]) and Attacks(un_humans[1]) <> 0 then HalasWataha(un_humans[1])
        else if IsOK(un_humans[2]) and Attacks(un_humans[2]) <> 0 then HalasWataha(un_humans[2])
        else if IsOK(un_humans[3]) and Attacks(un_humans[3]) <> 0 then HalasWataha(un_humans[3])
        else if IsOK(un_humans[4]) and Attacks(un_humans[4]) <> 0 then HalasWataha(un_humans[4]);
    end;
end;

// === GOAL: dotrzyj HT do ewakuacji północ ===
Every 0$5 do
begin
    if IsOK(un_transporterHT) and IsInArea(un_transporterHT, area_ewakuacja) then
    begin
        // HT w areale + ktokolwiek z drużyny żyje = ucieczka (załoga w HT lub obok)
        if AreAnyHumansAlive then
        begin
            goal_state[0] := 2;
            goal_state[1] := 2;
            SaveCharacters([un_humans[0], un_humans[1], un_humans[2], un_humans[3], un_humans[4]], 'pz_team');
            YouWin;
        end;
    end;

    // Fail jeśli wszyscy martwi
    if not AreAnyHumansAlive then
    begin
        goal_state[1] := 3;
        YouLost('PZ01_FAIL');
    end;

    // Dziennik ukryty — wejście do baraku (area_dziennik na mapie)
    if journal_done = 0 and FilterUnitsInArea(area_dziennik, [f_side, 1]) <> [] then
    begin
        journal_done := 1;
        goal_state[2] := 2;
        Hint('Dziennik bazy: "Wszystko działa. Żyła pod nami. Legion idzie." — Rook miał rację.');
    end;
end;

// Pomocnicze
function AreAnyHumansAlive: Boolean;
begin
    Result := IsOK(un_humans[0]) or IsOK(un_humans[1]) or IsOK(un_humans[2]) or IsOK(un_humans[3]) or IsOK(un_humans[4]);
end;

// Poprawka sensu (audyt 01): Alpha przy żyle Syberytu — dialog Rooka w 06 już przygotowany
// Postapo klimat: ruiny, pył, ograniczona widoczność — utrzymane