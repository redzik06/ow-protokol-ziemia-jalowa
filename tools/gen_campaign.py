# -*- coding: utf-8 -*-
"""gen_campaign.py — buduje pakiet kampanii OW z repo (odtwarzalnie).
Wejście: missions/*.sail, strings/texts_pl.txt + metadane poniżej.
Wyjście: campaign/{Missions/__PZ/NN, Campaigns/PZ} — gotowe do Mods/<mod>/.
Kodowania jak w oryginale: misje cp1250 CRLF, kampania UTF-16LE+BOM CRLF.
Uruchomienie: py -3 tools/gen_campaign.py (z katalogu moda)
"""
import pathlib, re, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "campaign"

MISSIONS = [
 (1, "Ostatnia Iskra", 1, "Ruiny bazy Alpha, świt.",
  "Baza Alpha padła. Legion idzie po żyłę Syberytu. Zbierz drużynę i wyrwij HT na północ.",
  [("Elena", "Alpha padła. Został HT, pięciu ludzi i klucz 17."),
   ("Yuri", "Żyła pod nami. Dlatego tu idą. Ruszamy, zanim nas policzą."),
   ("Elena", "Cicho. Każdy strzał to wataha. Po HT — i nie oglądać się.")]),
 (2, "Droga przez Rdzę", 1, "Kanion Wiatru, południe.",
  "Jedyna droga na północ. Bak niepełny, wraki pełne. Maya spuszcza ropę, reszta osłania.",
  [("Viktor", "To nie ropa. To krew bitwy. Ale pojadę i na tym."),
   ("Elena", "Wrak po wraku. Nie stajemy bez osłony."),
   ("Maya", "Dajcie mi pięć sekund przy każdym. Tylko pięć.")]),
 (3, "Pierwsza Pomoc", 1, "Posterunek Sojuszu, zamieć.",
  "Choroba pyłowa. Lina czeka z rannymi. Budynek to życie, zamieć to śmierć.",
  [("Lina", "Filtr? Mam. Działa? Też mam. Oba nie naraz."),
   ("Viktor", "Miałeś wrócić. Ja wybrałem Sojusz."),
   ("Elena", "Leki, filtry i do ewakuacji. Szybko.")]),
 (4, "Cmentarzysko Czołgów", 1, "Pole bitwy, noc 22:00.",
  "Cztery wraki, części do HT. Małpoludy słyszą każdy strzał. Ktoś tam nas obserwuje.",
  [("Maya", "Cicho. Każdy strzał to zaproszenie, a nie jesteśmy gospodarzami."),
   ("Karim", "Wódz patrzy. Może da się dogadać bez krwi."),
   ("Elena", "Demontaż po cichu. Noc jest po naszej stronie.")]),
 (5, "Brama na Północ", 1, "Przełęcz górska, barykada RU.",
  "Ostatnia barykada przed Pustynią. Siergiej nie przepuści. Maya robi ładunki.",
  [("Maya", "Jak wybuchnie za wcześnie, to przynajmniej nie usłyszę narzekań."),
   ("Viktor", "Przepraszam, Siergiej. Ale ty byś nas zostawił. Ja nie."),
   ("Elena", "Po wybuchu nie stajemy. Północ. Gaz.")]),
 (6, "Wolne Targowisko", 2, "Enklawa Nowa Nadzieja, bazar.",
  "Rozejm. Rook handluje, Alya targuje, a my musimy wybrać: młotek czy medyk.",
  [("Rook", "Mam wszystko. Nadzieja najdroższa. I najbardziej przeterminowana."),
   ("Alya", "Mogę was zabić, mogę was kupić. To drugie droższe. Wybierajcie."),
   ("Elena", "Jedno krzesło wolne. Decyzja teraz.")]),
 (7, "Czysty Tlen", 2, "Dolina Szarej Pustyni, przepompownia.",
  "Jedyna czysta woda. Generator żyje — my żyjemy. Legion idzie z trzech stron.",
  [("Yuri", "Prąd jest. Dopóki ktoś nie kichnie."),
   ("Maya", "Wieżyczki nasze, jak je przejmę. Osłaniajcie."),
   ("Elena", "Trzymać pompownię. Bez wody nie ma konwoju.")]),
 (8, "Wzmocnienie Konwoju", 2, "Porzucony garaż ZSRR.",
  "Cztery części, jeden warsztat, drugi HT. Spawajcie, póki Legion śpi.",
  [("Maya", "Spawaj szybciej. Legion puka. I nie puka delikatnie."),
   ("Wiktor", "Daj ropę i młotek, pojadę na Księżyc."),
   ("Elena", "Drugi wóz to podwójne szanse na lodzie.")]),
 (9, "Anomalia Łza", 2, "Strefa zerowa Syberytu.",
  "Sześć anomalii, trzy kolory, zero litości. Pod lodem coś leży. Coś wielkiego.",
  [("Yuri", "Sublimacja odsłoniła metal. To EON-2! Leżał tu pół roku!"),
   ("Karim", "A ja myślałem, że to tylko ładne światło..."),
   ("Elena", "Zielone leczy, niebieskie cofa, czerwone zabija. Zapamiętać.")]),
 (10, "Przechwycenie Sygnału", 2, "Płaskowyż, wieża kontrolna.",
  "Naprawić, nadać, przeżyć. Alya usłyszy — i przyjdzie sprawdzić.",
  [("Maya", "Trzydzieści sekund i wieża nasza."),
   ("Yuri", "Piętnaście sekund i cały Eos nas usłyszy."),
   ("Elena", "Miny na ścieżkach. Potem tylko czekać.")]),
 (11, "Zamarznięta Pamięć", 3, "Wnętrze EON-2, ciemność.",
  "Sześć miesięcy pod lodem. Kody Mirona są w środku. Latarki i nóż.",
  [("Elena", "Ciemno jak w dupie. I tak samo zimno."),
   ("Yuri", "Latarka działa. Dopóki bateria. Bateria nie działa. Wnioski?"),
   ("Echo-baz", "Stabilność: 73%. Szansa przeżycia: 12%. Miłego dnia.")]),
 (12, "Czerwony Zmierzch", 3, "Zlodowaciałe koryto rzeki.",
  "Dowódca Legionu ucieka lodem. Dwóch naszych ma ze sobą rachunki. Jeden wróci.",
  [("Viktor", "Ty zdradziłeś Legion, ja rozkazy. Jesteśmy kwita."),
   ("Karim", "Chcesz gonić po lodzie? To samobójstwo na łyżwach."),
   ("Elena", "Szturm albo rozmowa. Wybierajcie, nim lód wybierze.")]),
 (13, "Baza Eos — Przedpola", 3, "Pierścień obronny Eos.",
  "Cztery terminale, osiem autosektur. Trzy kody Mirona plus master. Hack, nie szturm.",
  [("Maya", "Terminal prosi o hasło. Hasło: nie zabijaj mnie. Wpisuję."),
   ("Yuri", "Pierścień myśli, że jesteśmy swoi. Nie wyprowadzaj go z błędu."),
   ("Elena", "Terminal po terminalu. Powoli.")]),
 (14, "Bitwa w Kraterze", 3, "Krater Szochowa, trzy silosy.",
  "Trzy rakiety Mirona. Behemoth. I dług Yuri do spłacenia przy ostatnim silosie.",
  [("Yuri", "Podpisałem. Teraz skreślam."),
   ("Miron", "Podpisałeś, Jurij? Teraz patrz, jak działa długopis."),
   ("Elena", "Dzielimy się na grupy. Krater nie wybacza tłoku.")]),
 (15, "Ostatni Świt", 3, "Serwerownia Eos, filtr.",
  "Filtr albo koniec. Kto przeżył piętnaście misji, ten decyduje, co będzie dalej.",
  [("Alya", "EON-2 jest mój. Był mój, zanim nauczyliście się go pisać."),
   ("Elena", "To go sobie zabierz. Tylko najpierw przejdź przeze mnie."),
   ("Farid", "Uczyłaś mnie leczyć. Teraz uczę cię umierać. Symetria.")]),
]

OBJ = {1: "Ucieknij HT na północ. Ocal drużynę.",
       2: "Przejedź kanion. Tankuj Mayą we wrakach.",
       3: "Zbierz leki i filtry. Ewakuuj się.",
       4: "Zdemontuj 4 wraki. Nie hałasuj.",
       5: "Zcraftuj ładunki, wysadź barykadę.",
       6: "Porozmawiaj z frakcjami. Wybierz rekruta.",
       7: "Broń przepompowni.",
       8: "Zbierz części. Złóż drugi pojazd.",
       9: "Przeprowadź konwój przez anomalie.",
       10: "Napraw wieżę, nadaj sygnał, obroń.",
       11: "Znajdź rdzeń EON-2.",
       12: "Zniszcz dowódcę. Strać max 1 pojazd.",
       13: "Przejmij 4 terminale.",
       14: "Rozbrój 3 silosy.",
       15: "Uruchom filtr. Przeżyj."}

TEXTS = ROOT / "strings" / "texts_pl.txt"


def parse_texts():
    cur = {}
    for line in TEXTS.read_text(encoding="utf-8").splitlines():
        m = re.match(r'^(PZ\d+_\w+)\s*=\s*"(.*)"\s*$', line.strip())
        if m:
            ident, val = m.group(1), m.group(2)
            mm = re.match(r"PZ(\d+)_", ident)
            if mm:
                cur.setdefault(int(mm.group(1)), []).append((ident, val))
    return cur


def w_cp1250(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(text.replace("\n", "\r\n").encode("cp1250"))


def w_utf16(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(("\ufeff" + text.replace("\n", "\r\n")).encode("utf-16-le"))


def main():
    per_mission = parse_texts()
    for num, name, sub, coords, brief, dlg in MISSIONS:
        nn = f"{num:02d}"
        sail = (ROOT / "missions" / f"{nn}_misja.sail").read_text(encoding="utf-8")
        mdir = OUT / "Missions" / "__PZ" / nn
        w_cp1250(mdir / "main.src", sail)
        w_cp1250(mdir / "sources.txt",
                 "SOURCE_CODES\n  ENABLED main\nEND_OF_SOURCE_CODES\n")
        w_cp1250(mdir / "description.txt",
                 "MISSION\n  MAP map.txt\n  TEXTS texts.txt\n  SOURCES sources.txt\n"
                 f"  CAMPAIGN 1 {num}\n  AUTOR PZJ\nEND_OF_MISSION\n")
        lines = [f"// Misja {nn} - {name}", "",
                 f"$ OBJ_{nn}", f"- {OBJ[num]}"]
        for ident, val in per_mission.get(num, []):
            lines += ["", f"$ {ident}", f"- {val}"]
        w_cp1250(mdir / "texts.txt", "\n".join(lines) + "\n")
    dat = ['CAMPAIGN "Protokół Ziemia Jałowa"',
           "  MISSION 0", '    NAME "Prolog"', "    NEXT 1"]
    for num, name, sub, coords, brief, dlg in MISSIONS:
        nn = f"{num:02d}"
        dat += [f"  MISSION {num}", f"    MAP {nn}",
                f'    NAME "Misja {num}: {name}"', f"    SUBCAMP {sub}",
                f"    PREV {num - 1}"]
        dat += ["    NEXT " + str(num + 1)] if num < 15 else ["    FINISH"]
    dat += ["END_OF_CAMPAIGN"]
    w_utf16(OUT / "Campaigns" / "PZ" / "missions.dat", "\n".join(dat) + "\n")
    w_utf16(OUT / "Campaigns" / "PZ" / "#pol" / "missions.dat", "\n".join(dat) + "\n")
    hdr = []
    for num, name, sub, coords, brief, dlg in MISSIONS:
        nn = f"{num:02d}"
        hdr += [f"__pz\\{nn}", f"{num}. {name}", "Briefing", brief,
                "Co-ordinates", coords]
    for rel in ["Campaigns/PZ/headers.wri", "Campaigns/PZ/#pol/headers.wri",
                "Campaigns/headers.wri", "Campaigns/#pol/headers.wri"]:
        w_utf16(OUT / rel, "\n".join(hdr) + "\n")
    for num, name, sub, coords, brief, dlg in MISSIONS:
        nn = f"{num:02d}"
        lines = [f"// Misja {nn} - {name}", ""]
        for sp, tx in dlg:
            lines += [f"$ {sp}", f"- {tx}", ""]
        for rel in [f"Campaigns/PZ/Txt{nn}.wri", f"Campaigns/PZ/#pol/Txt{nn}.wri"]:
            w_utf16(OUT / rel, "\n".join(lines))
    g = ["// Protokół Ziemia Jałowa - teksty globalne", ""]
    for num in range(1, 16):
        g += [f"$ OBJ_{num:02d}", f"- {OBJ[num]}", ""]
    w_utf16(OUT / "Texts" / "LangPOL.wri", "\n".join(g))
    n = sum(1 for _ in OUT.rglob("*") if _.is_file())
    print(f"campaign package: {n} files in {OUT}")


if __name__ == "__main__":
    sys.exit(main())
