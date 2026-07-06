# Prueba de razon de verosimilitudes entre dos ajustes ZIBR anidados

Compara dos modelos ZIBR anidados (por ejemplo, con y sin una
covariable) mediante un test de razon de verosimilitudes usando la
log-verosimilitud marginal (importance sampling) de cada ajuste.

## Usage

``` r
lrt_zibr(full, reduced, df = 2)
```

## Arguments

- full:

  Modelo completo: un objeto `zibr_saem` o cualquier objeto con metodo
  [`stats::logLik()`](https://rdrr.io/r/stats/logLik.html).

- reduced:

  Modelo reducido (anidado en `full`), mismo tipo que `full`.

- df:

  Grados de libertad de la prueba (numero de parametros extra en `full`
  respecto a `reduced`).

## Value

Un data frame de una fila con `LL_full`, `LL_reduced`, `LRT`
(estadistico), `df` y `p_value`.

## See also

[`lrt_zibr_table()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibr_table.md)
