# ver: 2025-10-30
using SpravaSouboru
#include(joinpath(@__DIR__, "sprsheetRef.jl"))

A1=sprsheetRef([1, 1])
println(A1)
A2=sprsheetRef([5, 143])
println(A2)
A3=sprsheetRef("AB23")
println(A3)
