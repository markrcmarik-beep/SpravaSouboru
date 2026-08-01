# ver: 2026-08-01
using Test
using SpravaSouboru

@testset "Kontrola existence souboru" begin
    # Ověříme, že soubor na dané cestě existuje a je to soubor
    @test isfile(joinpath(dirname(dirname(@__DIR__)), "src", "sprsheet2tabl", "sprsheet2tabl.jl"))
end
cache_file1 = joinpath(@__DIR__, "sprsheet2tabl1_test.jld2")
cache_file2 = joinpath(@__DIR__, "sprsheet2tabl2_test.jld2")

function cleanup_cache_files()
    rm(cache_file1, force=true)
    rm(cache_file2, force=true)
end

cleanup_cache_files() # Zajistí čistý stav před spuštěním testů

nothing
