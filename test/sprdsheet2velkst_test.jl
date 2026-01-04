# ver: 2025-11-02
using SpravaSouboru
#include(joinpath(@__DIR__, "sprdsheet2velkst.jl"))

cesta1 = joinpath(@__DIR__, "sprdsheet2velkst_test/sprdsheet2velkst_test.ods")
cesta2 = joinpath(@__DIR__, "sprdsheet2velkst_test/sprdsheet2velkst_2_test.ods")
cesta3 = joinpath(@__DIR__, "sprdsheet2velkst_test/sprdsheet2velkst_3_test.xlsx")
list11  = "List1"
list12  = "List2"
list21  = "material"
list22  = "material2"
list31  = "material"
list32  = "material2"

A11=sprdsheet2velkst(cesta1, list11)
println(A11)
A12=sprdsheet2velkst(cesta1, list12)
println(A12)
A21=sprdsheet2velkst(cesta2, list21)
println(A21)
A22=sprdsheet2velkst(cesta2, list22)
println(A22)
A31=sprdsheet2velkst(cesta3, list31)
println(A31)
A32=sprdsheet2velkst(cesta3, list32)
println(A32)