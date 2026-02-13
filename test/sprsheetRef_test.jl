# ver: 2026-02-10
using Test
using SpravaSouboru

@testset "sprsheetRef" begin
# Základní převod [row, col] -> "AB3"
@test sprsheetRef([1, 1]) == "A1"
@test sprsheetRef([3, 28]) == "AB3"
@test sprsheetRef([5, 143]) == "EM5"

# Základní převod "AB3" -> [row, col]
@test sprsheetRef("A1") == [1, 1]
@test sprsheetRef("AB3") == [3, 28]
@test sprsheetRef("em5") == [5, 143]  # otestuje case-insensitive písmena

# Vektor adres
@test sprsheetRef(["A1", "B2", "AB3"]) == [[1, 1], [2, 2], [3, 28]]

# Neplatné vstupy
@test_throws ErrorException sprsheetRef([1, 0])       # sloupec <= 0
@test_throws ErrorException sprsheetRef("AB")         # chybí řádek
@test_throws ErrorException sprsheetRef("12")         # chybí sloupec
end
