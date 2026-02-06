# ver: 2026-02-06
using Test
using SpravaSouboru

# Neinteraktivní test pomocí auto_choice.
@testset "menugui" begin
    options = ["Spustit", "Zastavit", "Konec"]
    idx, text = menugui("Zvol činnost:", options; auto_choice=2)

    @test idx == 2
    @test text == "Zastavit"

    idx0, text0 = menugui("Zvol činnost:", options; auto_choice=0)
    @test idx0 == 0
    @test text0 == ""

    @test_throws ArgumentError menugui("Zvol činnost:", options; auto_choice=99)
end
