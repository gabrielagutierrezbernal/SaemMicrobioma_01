# Coeficientes estimados de un ajuste ZIBR

Coeficientes estimados de un ajuste ZIBR

## Usage

``` r
# S3 method for class 'zibr_saem'
coef(object, ...)
```

## Arguments

- object:

  Un objeto `zibr_saem`, resultado de
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md).

- ...:

  No usado, por compatibilidad con el generico
  [`stats::coef()`](https://rdrr.io/r/stats/coef.html).

## Value

Vector numerico `mu` con los coeficientes de la parte logistica seguidos
de los de la parte beta.
