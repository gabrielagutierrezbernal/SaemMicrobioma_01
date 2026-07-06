# Tabla resumen de tres comparaciones LRT tipicas para ZIBBMR

Analogo de
[`zibr_results_table()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/zibr_results_table.md)
para modelos ZIBBMR.

## Usage

``` r
zibbmr_results_table(
  species,
  mod1_full,
  mod1_no_preg,
  mod2_full,
  mod2_no_preg,
  mod2_no_inter,
  df = 2,
  alpha = 0.05
)
```

## Arguments

- species:

  Vector de nombres/etiquetas para cada taxon.

- mod1_full, mod1_no_preg:

  Listas de modelos ZIBBMR para la primera comparacion, uno por taxon.

- mod2_full, mod2_no_preg, mod2_no_inter:

  Listas de modelos ZIBBMR para la segunda comparacion y la prueba de
  interaccion, uno por taxon.

- df:

  Grados de libertad usados en las tres pruebas.

- alpha:

  Nivel de significancia usado para las columnas `Detec_*`.

## Value

Un data frame con una fila por taxon.

## See also

[`zibr_results_table()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/zibr_results_table.md)
