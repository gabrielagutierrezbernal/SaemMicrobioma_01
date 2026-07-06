# Tabla de pruebas de razon de verosimilitudes para varios taxones ZIBR

Aplica
[`lrt_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibr.md)
pareando cada elemento de `full_models` con el correspondiente en
`reduced_models`, y arma una tabla con una fila por taxon.

## Usage

``` r
lrt_zibr_table(
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

  Vector de nombres/etiquetas para cada taxon (por defecto,
  `names(full_models)`).

- df:

  Grados de libertad de la prueba, ver
  [`lrt_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibr.md).

- alpha:

  Nivel de significancia usado para marcar `Detected`.

## Value

Un data frame con una fila por taxon: `Species`, las columnas de
[`lrt_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibr.md),
y `Detected` (logico, `p_value < alpha`).

## See also

[`lrt_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibr.md)
