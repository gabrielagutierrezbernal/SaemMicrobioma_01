# Preparar datos tipo Romero para ZIBBMR

Analogo de
[`prepare_romero_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/prepare_romero_zibr.md),
pero conserva los conteos crudos por taxon (en vez de convertirlos a
abundancia relativa), listos para usarse con
[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md)/[`fit_zibbmr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr_taxon.md)
junto con la columna `Total.Read.Counts` como profundidad de
secuenciacion.

## Usage

``` r
prepare_romero_zibbmr(
  romero,
  taxa_out = c(31, 49, 50, 60),
  zero_range = c(0.1, 0.9)
)
```

## Arguments

- romero:

  Una lista con elementos `SampleData` y `OTU`, ver
  [`prepare_romero_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/prepare_romero_zibr.md).

- taxa_out:

  Indices de columnas de taxones a excluir explicitamente tras el filtro
  por proporcion de ceros.

- zero_range:

  Vector de largo 2 con el rango `[min, max]` de proporcion de ceros
  permitido para retener un taxon (calculado sobre los conteos crudos).

## Value

Una lista con `data` (covariables + conteos de los taxones retenidos),
`taxa`, `covariates`, `counts`, `taxa_removed` y `zero_range`.

## See also

[`prepare_romero_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/prepare_romero_zibr.md)
para la version en proporciones (ZIBR).
