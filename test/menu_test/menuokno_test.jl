# ver: 2026-07-31
using Test
using SpravaSouboru

@testset "Kontrola existence souboru" begin
    # Ověříme, že soubor na dané cestě existuje a je to soubor
    @test isfile(joinpath(dirname(dirname(@__DIR__)), "src", "menu", "menuokno.jl"))
end
# Neinteraktivní test pomocí auto_choice.
@testset "menuokno" begin
    options = ["Spustit", "Zastavit", "Konec"]
    idx, text = menuokno("Zvol činnost:", options; auto_choice=2)

    @test idx == 2
    @test text == "Zastavit"

    idx0, text0 = menuokno("Zvol činnost:", options; auto_choice=0)
    @test idx0 == 0
    @test text0 == ""

    @test_throws ArgumentError menuokno("Zvol činnost:", options; auto_choice=99)
end

nothing
