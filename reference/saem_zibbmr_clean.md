# Alias historico de fit_zibbmr con la firma del codigo original de Barrera

Envoltorio de compatibilidad hacia atras que expone
[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md)
con los mismos nombres de argumento que el script original
`saem_zibbmr()` (`jbarrera232/saem-zibbmr`). Se mantiene para no romper
analisis existentes; el codigo nuevo deberia usar
[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md)
directamente.

## Usage

``` r
saem_zibbmr_clean(
  Y,
  X = NULL,
  Z = NULL,
  S,
  index,
  zi = TRUE,
  v0,
  a0 = NULL,
  b0,
  seed,
  iter,
  ncad = 5,
  a.fix = NULL,
  b.fix = NULL,
  compute_fim = TRUE
)
```

## Arguments

- Y, X, Z, S, index, zi, v0, a0, b0, seed, iter, ncad, a.fix, b.fix:

  Ver los argumentos equivalentes de
  [`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md):
  `Y = y`, `index = id`, `v0 = phi_start`, `a0 = alpha_start`,
  `b0 = beta_start`, `iter = n_iter`, `ncad = n_chains`, `a.fix`/`b.fix`
  equivalen a `alpha_random`/ `beta_random` (`a.fix == 0` marca las
  posiciones aleatorias).

- compute_fim:

  Ver
  [`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md).

## Value

Un objeto `zibbmr_saem`, igual que
[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md).

## See also

[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md)
