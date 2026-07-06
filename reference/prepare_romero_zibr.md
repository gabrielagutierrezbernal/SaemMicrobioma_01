# Preparar datos tipo Romero para ZIBR

Toma una lista con datos de microbioma en el formato del estudio Romero
(con elementos `SampleData` y `OTU`) y construye covariables estandar
(tiempo de gestacion escalado, edad escalada, interaccion
tiempo-embarazo) junto con abundancias relativas filtradas por
proporcion de ceros, listas para usarse con
[`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)/[`fit_zibr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr_taxon.md).

## Usage

``` r
prepare_romero_zibr(
  romero,
  taxa_out = c(31, 49, 50, 60),
  zero_range = c(0.1, 0.9)
)
```

## Arguments

- romero:

  Una lista con elementos `SampleData` (covariables por muestra,
  incluyendo `Age`, `Subect_ID`, `pregnant`, `GA_Days`,
  `Total.Read.Counts`) y `OTU` (matriz o data frame de conteos por
  taxon, mismo numero de filas que `SampleData`).

- taxa_out:

  Indices de columnas de taxones a excluir explicitamente tras el filtro
  por proporcion de ceros.

- zero_range:

  Vector de largo 2 con el rango `[min, max]` de proporcion de ceros
  permitido para retener un taxon.

## Value

Una lista con `data` (covariables + abundancias relativas de los taxones
retenidos), `taxa` (nombres de esos taxones), `covariates`,
`abundances`, `taxa_removed` y `zero_range`.

## See also

[`prepare_romero_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/prepare_romero_zibbmr.md)
para la version en conteos (ZIBBMR).
