# Prueba de razon de verosimilitudes entre dos ajustes ZIBBMR anidados

Analogo de
[`lrt_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibr.md)
para modelos ZIBBMR.

## Usage

``` r
lrt_zibbmr(full, reduced, df = 2)
```

## Arguments

- full:

  Modelo completo: un objeto `zibbmr_saem` o cualquier objeto con metodo
  [`stats::logLik()`](https://rdrr.io/r/stats/logLik.html).

- reduced:

  Modelo reducido (anidado en `full`), mismo tipo que `full`.

- df:

  Grados de libertad de la prueba.

## Value

Un data frame de una fila con `LL_full`, `LL_reduced`, `LRT`, `df` y
`p_value`.

## See also

[`lrt_zibbmr_table()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibbmr_table.md),
[`lrt_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibr.md)
