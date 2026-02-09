# ver: 2026-02-09
using Test
using SpravaSouboru

cesta1 = joinpath(@__DIR__, "sprdsheet2velkst_test/sprdsheet2velkst_test.ods")
cesta2 = joinpath(@__DIR__, "sprdsheet2velkst_test/sprdsheet2velkst_2_test.ods")
cesta3 = joinpath(@__DIR__, "sprdsheet2velkst_test/sprdsheet2velkst_3_test.xlsx")

@testset "sprdsheet2velkst" begin
    @test sprdsheet2velkst(cesta1, "List1") == "A2:AQG1590"
    @test sprdsheet2velkst(cesta1, "List2") == "A4:BD739"

    @test sprdsheet2velkst(cesta2, "material") == "A1:T91"
    @test sprdsheet2velkst(cesta2, "material2") == "A1:M37"

    @test sprdsheet2velkst(cesta3, "material") == "A1:T90"
    @test sprdsheet2velkst(cesta3, "material2") == "A1:L36"

    @test sprdsheet2velkst(cesta1, "List1"; druh="první") == "A2"
    @test sprdsheet2velkst(cesta1, "List1"; druh="poslední") == "AQG1590"
    @test sprdsheet2velkst(cesta1, "List1"; druh="první písmeno") == "A"
    @test sprdsheet2velkst(cesta1, "List1"; druh="první číslo") == "2"
    @test sprdsheet2velkst(cesta1, "List1"; druh="poslední písmeno") == "AQG"
    @test sprdsheet2velkst(cesta1, "List1"; druh="poslední číslo") == "1590"

    @test sprdsheet2velkst(cesta2, "material2"; druh="první") == "A1"
    @test sprdsheet2velkst(cesta2, "material2"; druh="poslední") == "M37"
    @test sprdsheet2velkst(cesta2, "material2"; druh="první písmeno") == "A"
    @test sprdsheet2velkst(cesta2, "material2"; druh="první číslo") == "1"
    @test sprdsheet2velkst(cesta2, "material2"; druh="poslední písmeno") == "M"
    @test sprdsheet2velkst(cesta2, "material2"; druh="poslední číslo") == "37"

    @test sprdsheet2velkst(cesta3, "material2"; druh="první") == "A1"
    @test sprdsheet2velkst(cesta3, "material2"; druh="poslední") == "L36"
    @test sprdsheet2velkst(cesta3, "material2"; druh="první písmeno") == "A"
    @test sprdsheet2velkst(cesta3, "material2"; druh="první číslo") == "1"
    @test sprdsheet2velkst(cesta3, "material2"; druh="poslední písmeno") == "L"
    @test sprdsheet2velkst(cesta3, "material2"; druh="poslední číslo") == "36"
end
