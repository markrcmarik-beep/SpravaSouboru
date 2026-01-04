# ver: 2025-11-11
using SpravaSouboru
idx, text = menugui("Zvol činnost:", ["Spustit", "Zastavit", "Konec"])
println("Vybral jsi možnost č. $idx: $text")