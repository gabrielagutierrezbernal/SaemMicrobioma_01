# Tabla de pruebas de razon de verosimilitudes para varios taxones ZIBBMR

Analogo de
[`lrt_zibr_table()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibr_table.md)
para modelos ZIBBMR.

## Usage

``` r
lrt_zibbmr_table(
  full_models,
  reduced_models,
  species = names(full_models),
  df = 2,
  alpha = 0.05
)
```

## Arguments

- full_models:

  Lista de modelos completos (uno por taxon).

- reduced_models:

  Lista de modelos reducidos (uno por taxon, mismo orden que
  `full_models`).

- species:

  Vector de nombres/etiquetas para cada taxon.

- df:

  Grados de libertad de la prueba.

- alpha:

  Nivel de significancia usado para marcar `Detected`.

## Value

Un data frame con una fila por taxon, ver
[`lrt_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibbmr.md).

## See also

[`lrt_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibbmr.md)
