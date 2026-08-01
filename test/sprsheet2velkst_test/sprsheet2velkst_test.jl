# ver: 2026-08-01
using Test
using SpravaSouboru

@testset "Kontrola existence souboru" begin
    # Ověříme, že soubor na dané cestě existuje a je to soubor
    @test isfile(joinpath(dirname(dirname(@__DIR__)), "src", "sprsheet2velkst", "sprsheet2velkst.jl"))
end

cesta1 = joinpath(@__DIR__, "sprsheet2velkst_test.ods")
cesta2 = joinpath(@__DIR__, "sprsheet2velkst_2_test.ods")
cesta3 = joinpath(@__DIR__, "sprsheet2velkst_3_test.xlsx")
cache_file1 = joinpath(@__DIR__, "sprsheet2velkst_test_sprsheet2velkstF.jld2")
cache_file2 = joinpath(@__DIR__, "sprsheet2velkst_2_test_sprsheet2velkstF.jld2")

function cleanup_cache_files()
    rm(cache_file1, force=true)
    rm(cache_file2, force=true)
end

cleanup_cache_files() # Zajistí čistý stav před spuštěním testů

@testset "sprsheet2velkst" begin

    @test sprsheet2velkst(cesta1, "List1") == "A2:AQG1590"
    @test sprsheet2velkst(cesta1, "List2") == "A4:BD739"

    @test sprsheet2velkst(cesta2, "material") == "A1:T91"
    @test sprsheet2velkst(cesta2, "material2") == "A1:M37"

    @test sprsheet2velkst(cesta3, "material") == "A1:T90"
    @test sprsheet2velkst(cesta3, "material2") == "A1:L36"

    @test sprsheet2velkst(cesta1, "List1"; druh="první") == "A2"
    @test sprsheet2velkst(cesta1, "List1"; druh="poslední") == "AQG1590"
    @test sprsheet2velkst(cesta1, "List1"; druh="první písmeno") == "A"
    @test sprsheet2velkst(cesta1, "List1"; druh="první číslo") == "2"
    @test sprsheet2velkst(cesta1, "List1"; druh="poslední písmeno") == "AQG"
    @test sprsheet2velkst(cesta1, "List1"; druh="poslední číslo") == "1590"

    @test sprsheet2velkst(cesta2, "material2"; druh="první") == "A1"
    @test sprsheet2velkst(cesta2, "material2"; druh="poslední") == "M37"
    @test sprsheet2velkst(cesta2, "material2"; druh="první písmeno") == "A"
    @test sprsheet2velkst(cesta2, "material2"; druh="první číslo") == "1"
    @test sprsheet2velkst(cesta2, "material2"; druh="poslední písmeno") == "M"
    @test sprsheet2velkst(cesta2, "material2"; druh="poslední číslo") == "37"

    @test sprsheet2velkst(cesta3, "material2"; druh="první") == "A1"
    @test sprsheet2velkst(cesta3, "material2"; druh="poslední") == "L36"
    @test sprsheet2velkst(cesta3, "material2"; druh="první písmeno") == "A"
    @test sprsheet2velkst(cesta3, "material2"; druh="první číslo") == "1"
    @test sprsheet2velkst(cesta3, "material2"; druh="poslední písmeno") == "L"
    @test sprsheet2velkst(cesta3, "material2"; druh="poslední číslo") == "36"
end

cleanup_cache_files() # Uklidí soubory po testech, i když selžou

nothing
