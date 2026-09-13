; 06_misja.sail — Wolne Targowisko
; Mapa: maps/02_akt_II/06_wolne_targowisko.map — 64x64 ruins_town hub, indywidualna
; Vault: 02 Akt II - Szara Pustynia/06 - Wolne Targowisko.md, 05 Fabuła/01 - Bohaterowie Drużyny.md
; Zasada: nowa historia nie związana z ori, postapo hub, 3 poziomy równocześnie, poprawna pisownia PL
; SAIL: dialog branch, SaveVariable/TestVariable, persistent, handel

int wybor = 0; // 0=brak, 1=Wiktor, 2=Farid
int handel_cena = 0;
int rekrut_06 = 0; // branch do SaveVariable (TestVariable w 07-15)
int wybor_left = 0; // licznik timeoutu wyboru (zamiast SetTimer)

export un_humans[6];
export un_wiktor;
export un_farid;

int goal_state[3]; // 0=off 1=aktywny 2=done 3=fail

Starting
begin
    // cel 0: POROZMAWIAJ_3_FRAKCJE
    // cel 1: WYBOR_REKRUTA
    goal_state[0] := 1; goal_state[1] := 1;

    // Drużyna 5
    uc_side := 1; uc_nation := nation_american; uc_x := 32; uc_y := 32;
    hc_name := 'Elena Varga'; hc_class := class_mechanic; hc_skills := [2,2,5,1];
    hc_gallery := 1; hc_face_number := 1;
    un_humans[0] := CreateHuman;
    uc_x := 33; hc_name := 'Yuri Kamarov'; hc_class := class_scientistic; hc_skills := [1,1,2,5];
    hc_gallery := 1; hc_face_number := 2;
    un_humans[1] := CreateHuman;
    uc_x := 34; hc_name := 'Viktor Drachev'; hc_class := class_soldier; hc_skills := [5,1,2,1];
    hc_gallery := 1; hc_face_number := 3;
    un_humans[2] := CreateHuman;
    uc_x := 32; uc_y := 33; hc_name := 'Maya Torres'; hc_class := class_engineer; hc_skills := [2,5,3,2];
    hc_gallery := 1; hc_face_number := 4;
    un_humans[3] := CreateHuman;
    uc_x := 33; uc_y := 33; hc_name := 'Karim Al-Rashid'; hc_class := class_desert_warior; hc_skills := [5,1,1,1];
    hc_gallery := 1; hc_face_number := 5;
    un_humans[4] := CreateHuman;

    // NPC frakcji — neutralni handlarze (twarze XichtEd 10 i 8)
    uc_side := 3; uc_nation := nation_american; uc_x := 20; uc_y := 20; hc_name := 'Rook Nowak'; hc_class := class_mechanic;
    hc_gallery := 1; hc_face_number := 10;
    CreateHuman; // Rook Szczur
    uc_x := 40; uc_y := 20; hc_name := 'Alya Hassan'; hc_class := class_soldier; hc_sex := sex_female;
    hc_gallery := 1; hc_face_number := 8;
    CreateHuman; // Alya
    uc_x := 30; uc_y := 45; hc_name := 'Miron Karpov'; hc_class := class_soldier;
    // Miron nie osobiście, tylko via namiot RU

    // Skalowanie trudnością — handel i czas wyboru (obligatoryjnie)
    if difficulty = 0 then // łatwy — tani, bez presji, podpowiedzi
    begin
        handel_cena := 10;
        Hint('Łatwy: handel tani, wybór bez limitu czasu, Alya neutral. Podpowiedzi włączone.');
    end
    else if difficulty = 1 then // średni — drogi, 60s
    begin
        handel_cena := 20;
        Hint('Średni: handel drogi, wybór 60s. „Tu się nie strzela, tu się handluje.”');
        wybor_left := 60; // licznik zamiast SetTimer
    end
    else // trudny — bardzo drogi, 30s, brak podpowiedzi
    begin
        handel_cena := 35;
        Hint('Trudny: handel bardzo drogi, wybór 30s, Alya wrogo jeśli Wiktor. Brak podpowiedzi.');
        wybor_left := 30;
    end;

    ForceSay(un_humans[0], 'PZ06_01'); // Rook: "Mam wszystko..."
    Wait(2$0);
    ForceSay(un_humans[4], 'PZ06_02'); // Alya: "Mogę was zabić, mogę was kupić..."
    CenterOnXY(32,32);
end;

// Dialog branch — wybór rekruta (vault 01 - Bohaterowie, 03 - Kto Kogo Odstrzeli)
export function DialogWiktor;
begin
    if wybor <> 0 then
    begin
        Hint('Już wybrałeś!');
        Exit;
    end;
    wybor := 1;
    // Wiktor Volkov — RU Mechanik, buff pojazdów — twarz XichtEd 6
    uc_side := 1; uc_nation := nation_russian; uc_x := 33; uc_y := 34;
    hc_name := 'Wiktor Volkov'; hc_class := class_mechanic; hc_skills := [3,2,5,1];
    hc_gallery := 1; hc_face_number := 6;
    hc_gallery := 1; hc_face_number := 6;
    un_wiktor := CreateHuman;
    rekrut_06 := 1; SaveVariable(rekrut_06, 'rekrut_wiktor'); // branch testem TestVariable w 07-15
    Hint('Wybrano: Wiktor Volkov (Sojusz, -20% paliwo). Alya wrogo od 12.');
    goal_state[1] := 2;
    // Heike/Alya hostile od 12
end;

export function DialogFarid;
begin
    if wybor <> 0 then
    begin
        Hint('Już wybrałeś!');
        Exit;
    end;
    wybor := 2;
    // Farid Al-Hadi — Arab Naukowiec-Medyk — twarz XichtEd 7
    uc_side := 1; uc_nation := nation_arabian; uc_x := 33; uc_y := 34;
    hc_name := 'Farid Al-Hadi'; hc_class := class_scientistic; hc_skills := [1,2,2,5];
    hc_gallery := 1; hc_face_number := 7;
    hc_gallery := 1; hc_face_number := 7;
    un_farid := CreateHuman;
    rekrut_06 := 2; SaveVariable(rekrut_06, 'rekrut_farid');
    Hint('Wybrano: Farid Al-Hadi (Legion, medyk, Alya neutral do 12). Farid zdradzi Alyę w 15.');
    goal_state[1] := 2;
end;

export function DialogHandel(crateType, amount);
begin
    // Handel mat_cans/oil/siberite — cena skalowana trudnością
    // Łatwy 10, Średni 20, Trudny 35
    Hint('Handel: ' + handel_cena + ' mat_cans za ' + crateType);
end;

// Timeout wyboru — na Średnim/Trudnym, licznik zamiast SetTimer
export function WYBOR_TIMEOUT;
begin
    if wybor = 0 then
    begin
        Hint('Czas minął! Rook wybiera za ciebie: Wiktor (Sojusz).');
        DialogWiktor;
    end;
end;

Every 1$0 do
begin
    if wybor = 0 and wybor_left > 0 then
    begin
        wybor_left := wybor_left - 1;
        if wybor_left = 0 then WYBOR_TIMEOUT;
    end;
end;

// Koniec hub — persistent branch
Every 0$5 do
begin
    if wybor <> 0 and FilterUnitsInArea(area_rynek, [f_side, 1]) <> [] then
    begin
        // Zapisz persistent — Wiktor/Farid idzie do 07-15
        SaveCharacters([un_humans[0], un_humans[1], un_humans[2], un_humans[3], un_humans[4]], 'pz_team');
        YouWin;
    end;
end;

// Poprawka sensu 06: Enklawa to rozejm handlowy — „Tu się nie strzela, tu się handluje. Poza Enklawą — róbta co chceta.”
// Postapo: bazar pod plandekami, beczki po ropie jako stoły — hub bez walki, jedyny taki w kampanii
// 3 poziomy równocześnie — handel drogi/bardzo drogi, czas 60s/30s, obligatoryjnie
// Solucja lista: docs/solucje/06 - Solucja - Wolne Targowisko.pdf (3 warianty Ł/Ś/T)