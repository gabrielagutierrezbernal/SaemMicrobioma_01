# Alias historico de fit_zibr con la firma del codigo original de Barrera

Envoltorio de compatibilidad hacia atras que expone
[`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)
con los mismos nombres de argumento que el script original `saem_zibr()`
(`jbarrera232/saem-zibr`). Se mantiene para no romper analisis
existentes; el codigo nuevo deberia usar
[`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)
directamente.

## Usage

``` r
saem_zibr_clean(
  Y,
  X = NULL,
  Z = NULL,
  index,
  zi = TRUE,
  v0,
  a0 = NULL,
  b0,
  seed,
  iter = 500,
  ncad = 5,
  a.fix = NULL,
  b.fix = NULL,
  compute_fim = TRUE
)
```

## Arguments

- Y, X, Z, index, zi, v0, a0, b0, seed, iter, ncad, a.fix, b.fix:

  Ver los argumentos equivalentes de
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md):
  `Y = y`, `index = id`, `v0 = phi_start`, `a0 = alpha_start`,
  `b0 = beta_start`, `iter = n_iter`, `ncad = n_chains`, `a.fix`/`b.fix`
  equivalen a `alpha_random`/ `beta_random` (`a.fix == 0` marca las
  posiciones aleatorias).

- compute_fim:

  Ver
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md).

## Value

Un objeto `zibr_saem`, igual que
[`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md).

## See also

[`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)
