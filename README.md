# ow mod test — Original War: Protokół Ziemia Jałowa

> Ten folder to **kod moda** (SAIL + mapy). 
> Dokumentacja designu jest w Obsidian Vault, żeby się nie mieszało.

**Design docs:** `C:\Users\user\Documents\Obsidian Vault\OW-Protokol-Ziemia-Jalowa\`

- Przegląd kampanii: `00 - Przeglad Kampanii.md`
- Mapy indywidualne: `00 - Mapy Przeglad.md` — 15 map, każda pod misję/akt
- 15 misji w `01 Akt I/` `02 Akt II/` `03 Akt III/` — każda z sekcją `## Mapa — Specyfikacja Indywidualna`
- Mechaniki SAIL w `99 Mechaniki SAIL/`

**Struktura kodu (aktualna):**
```
ow mod test/
  README.md
  maps/
    01_akt_I/ 01_ostatnia_iskra.map.txt ... 05_brama_na_polnoc.map.txt (72x72 .. 64x96)
    02_akt_II/ 06_wolne_targowisko.map.txt ... 10_przechwycenie_sygnalu.map.txt (64x64 .. 112x112)
    03_akt_III/ 11_zamarznieta_pamiec.map.txt ... 15_ostatni_swit.map.txt (64x64 .. 128x128)
  missions/
    01_misja.sail.txt ... 15_misja.sail.txt (placeholdery pod .sail)
```

**Zasada:** każda mapa indywidualna — nie reużywana. Edytor OW: nowa mapa per misja, rozmiar i tileset jak w `00 - Mapy Przeglad.md`.

**Zasada:** wszystko istotne → Obsidian `OW-Protokol-Ziemia-Jalowa/00 - Zasady - Wszystko na Obsidian.md` — ten README to tylko skrót.

**Status:** design + struktura map gotowe — do stworzenia .map w Edytorze OW.

