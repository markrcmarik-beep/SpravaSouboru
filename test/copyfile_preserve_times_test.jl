
using Test
using Dates, SpravaSouboru

# Načteme soubor s tvou funkcí (předpokládáme, že je ve stejné složce)
#include("copyfile_preserve_times.jl")

# Definice testovací sady
@testset "Testy copyfile_preserve_times" begin
    
    # 1. Příprava prostředí (Setup)
    src_file = "test_source.txt"
    dst_file = "test_dest.txt"
    dst_dir  = "test_backup_dir"
    
    # Úklid z předchozích testů (pokud existují)
    rm(src_file, force=true)
    rm(dst_file, force=true)
    rm(dst_dir, force=true, recursive=true)

    # Vytvoření zdrojového souboru
    open(src_file, "w") do f
        write(f, "Toto je testovací data pro inženýrský výpočet.")
    end

    # Nastavíme čas modifikace (mtime) na 1 hodinu zpět
    # To je důležité, abychom poznali, že se čas opravdu zkopíroval, 
    # a ne že se nastavil aktuální čas při vytvoření kopie.
    old_time = time() - 3600 # aktuální čas minus 3600 sekund
    touch(src_file, old_time)

    println("Generuji testovací data...")
    println("Zdroj mtime: $(unix2datetime(stat(src_file).mtime))")

    # 2. Test kopírování soubor -> soubor
    @testset "Kopie Soubor -> Soubor" begin
        # Spuštění testované funkce
        SpravaSouboru.copyfile_preserve_times(src_file, dst_file)

        # Ověření existence
        @test isfile(dst_file)

        # Získání statistik o souborech
        s_stat = stat(src_file)
        d_stat = stat(dst_file)

        # Porovnání časů (mtime - modification time)
        # Tolerance 1 sekunda (kvůli různým souborovým systémům jako FAT32 vs NTFS/ext4)
        @test isapprox(s_stat.mtime, d_stat.mtime, atol=1.0)
        
        println("  -> Soubor -> Soubor: OK")
        println("     Zdroj mtime: $(s_stat.mtime)")
        println("     Cíl   mtime: $(d_stat.mtime)")
    end

    # 3. Test kopírování soubor -> adresář
    @testset "Kopie Soubor -> Adresář" begin
        # Vytvoření cílového adresáře (funkce by ho měla umět vytvořit, ale pro jistotu testujeme i do existujícího)
        mkpath(dst_dir)
        
        # Cesta, kam se to má zkopírovat
        expected_dst_path = joinpath(dst_dir, src_file)

        SpravaSouboru.copyfile_preserve_times(src_file, dst_dir)

        @test isfile(expected_dst_path)
        
        s_stat = stat(src_file)
        d_stat = stat(expected_dst_path)

        @test isapprox(s_stat.mtime, d_stat.mtime, atol=1.0)
        println("  -> Soubor -> Adresář: OK")
    end

    # 4. Úklid (Teardown)
    # Po testech smažeme dočasné soubory, abychom nenechávali nepořádek
    rm(src_file, force=true)
    rm(dst_file, force=true)
    rm(dst_dir, force=true, recursive=true)
    println("Úklid hotov.")
end
