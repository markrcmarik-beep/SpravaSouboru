# ver: 2026-07-31
using SpravaSouboru
using Test

@testset "Kontrola existence souboru" begin
    # Ověříme, že soubor na dané cestě existuje a je to soubor
    @test isfile(joinpath(dirname(@__DIR__), "src", "copyfile_preserve_times.jl"))
end

nothing
