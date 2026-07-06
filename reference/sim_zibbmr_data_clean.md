# Alias historico de simulate_zibbmr_data con la firma del codigo original

Envoltorio de compatibilidad hacia atras que expone
[`simulate_zibbmr_data()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/simulate_zibbmr_data.md)
con los nombres de argumento del script original de Barrera.

## Usage

``` r
sim_zibbmr_data_clean(
  n.ind,
  n.obs.ind,
  s.tot,
  zi = TRUE,
  X = NULL,
  Z = NULL,
  alpha = NULL,
  beta,
  s1 = NULL,
  s2,
  v,
  seed
)
```

## Arguments

- n.ind, n.obs.ind, s.tot, zi, X, Z, alpha, beta, s1, s2, v, seed:

  Ver los argumentos equivalentes de
  [`simulate_zibbmr_data()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/simulate_zibbmr_data.md):
  `n.ind = n_subjects`, `n.obs.ind = n_time`, `s.tot = S`,
  `s1 = sigma_alpha`, `s2 = sigma_beta`, `v = phi`.

## Value

Un data frame, igual que
[`simulate_zibbmr_data()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/simulate_zibbmr_data.md).

## See also

[`simulate_zibbmr_data()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/simulate_zibbmr_data.md)
