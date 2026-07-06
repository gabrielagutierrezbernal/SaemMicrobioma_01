# Errores estandar de un ajuste SAEM

Generico que calcula los errores estandar de los parametros de un modelo
ajustado, a partir de la matriz de informacion de Fisher estocastica
(`fisher_stoch`) almacenada en el objeto de ajuste. Requiere que el
modelo se haya ajustado con `compute_fim = TRUE`.

## Usage

``` r
se(object, ...)

# S3 method for class 'zibbmr_saem'
se(object, ...)

# S3 method for class 'zibr_saem'
se(object, ...)
```

## Arguments

- object:

  Un objeto ajustado por
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)
  o
  [`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md)
  (clases `zibr_saem` o `zibbmr_saem`).

- ...:

  Argumentos adicionales pasados a metodos especificos.

## Value

Un vector numerico con los errores estandar, en el mismo orden que
`coef(object)` seguido de la dispersion y las varianzas de efectos
aleatorios.

## See also

[`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md),
[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md),
[`stats::vcov()`](https://rdrr.io/r/stats/vcov.html)
