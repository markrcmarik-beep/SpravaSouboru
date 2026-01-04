# ver: 2025-11-06
#using FileIO # Pro práci s cestami a soubory
#using Dates   # Pro práci s datumem (vyžadováno v jiných funkcích)
#using JLD2    # Pro práci s keší (vyžadováno v jiných funkcích)
# using XLSX    # Pro práci s .xlsx (vyžadováno v jiných funkcích)
# using OdsIO   # Pro práci s .ods (vyžadováno v jiných funkcích)
using SpravaSouboru
# using OdsIO # Použij, pokud pracuješ s .ods

# Poznámka: Funkce SprdsheetRef a sprdsheet2velkst musí být dostupné
# (tj. definované v tomtéž souboru nebo načtené pomocí 'include' či 'using').


    # 1. Definice cest a názvů souborů
    # Nahrazení [cesta01,~,~]=fileparts(fullfile(mfilename('fullpath')));
    cesta01 = dirname(@__FILE__) # Získá cestu k adresáři aktuálního souboru
    podslozka = "sprsheet2tabl_test" # Podadresář s testovacími soubory
    list_nazev1 = "material" # Místo list{listCi}
    list_nazev2 = "material" # Místo list{listCi}
    
    soubor1 = "sprsheet2tabl1_test.ods" # Název testovacího souboru .ods
    souborDat1 = "sprsheet2tabl1_test.jld2" # Změna na standardní Julia kešovací formát
    soubor2 = "sprsheet2tabl2_test.xlsx"
    souborDat2 = "sprsheet2tabl2_test.jld2"

    STRTradk = 3
    
    # 2. Určení úplné cesty k souboru spreadsheetu
    cesta_spreadsheetu1 = joinpath(cesta01, podslozka, soubor1)
    cesta_spreadsheetu2 = joinpath(cesta01, podslozka, soubor2)

    # 3. Získání rozsahu celého datového bloku
    # rozsah = sprdsheet2velkst(...)
    rozsah1 = sprdsheet2velkst(cesta_spreadsheetu1, list_nazev1) # Předpokládá se, že vrací např. "A1:G10"
    rozsah2 = sprdsheet2velkst(cesta_spreadsheetu2, list_nazev2)
    # 4. Zpracování rozsahů
    # W1=souredniceRefSprdsheet(extractAfter(rozsah,':'));
    # W1(1)=STRTradk; 
    # W1=souredniceRefSprdsheet(W1);
    
    # Získání koncových souřadnic (např. G10)
    koncova_adresa1 = last(split(rozsah1, ':'))
    
    # Převod koncové adresy na číselné souřadnice [řádek, sloupec]
    W1 = sprsheetRef(koncova_adresa1)
    
    # Nastavení řádku na STRTradk (např. 3) a zpět na textovou adresu
    W1_nova_adresa = sprsheetRef([STRTradk, W1[2]])
    
    # Rozsah nadpisů
    # rozsahNadpis=['A',num2str(STRTradk),':',W1];
    # explicitní interpolace, aby bylo jasné kde končí číslo
    rozsahNadpis = "A$(STRTradk):$W1_nova_adresa"
    
    # Rozsah tabulky dat
    # rozsahTabulka=strcat('A5:',extractAfter(rozsah,':'));
    rozsahTabulka = "A5:$koncova_adresa1" # Předpoklad: data tabulky začínají na řádku 5

    # 5. Volání cílové funkce
    # [~,~,TBL1]=sprsheet2tabl(...)
    cesta_pro_sprsheet2tabl1 = joinpath(cesta01, podslozka)
    cesta_pro_sprsheet2tabl2 = joinpath(cesta01, podslozka)
    
    # Použijeme zástupné znaky pro nepoužité výstupy
    # Funkce `sprsheet2tabl` očekává 3 rozsahy: [nadpis X, nadpis Y, tabulka dat].
    # Testovací data mají v některých případech jen jeden nadpisový rozsah,
    # proto pro test zde použijeme nadpisový rozsah jako placeholder i pro druhý prvek.
    X1 , Y1 , TBL1 = sprsheet2tabl(
        cesta_pro_sprsheet2tabl1,
        [soubor1, souborDat1],
        list_nazev1,
        [rozsahNadpis, rozsahNadpis, rozsahTabulka]
    )
    _ , _ , TBL2 = sprsheet2tabl(
        cesta_pro_sprsheet2tabl2,
        [soubor2, souborDat2],
        list_nazev2,
        [rozsahNadpis, rozsahNadpis, rozsahTabulka]
    )
    
    # 6. Zobrazení výsledku
    println("Načtená tabulka (TBL1):")
    display(X1)
    display(Y1)
    display(TBL1)
    println("Načtená tabulka (TBL2):")
    display(TBL2)

# sprdsheet2tabl_test() # Odkomentuj pro spuštění