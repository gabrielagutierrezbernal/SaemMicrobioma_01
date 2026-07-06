# Coeficientes estimados de un ajuste ZIBBMR

Coeficientes estimados de un ajuste ZIBBMR

## Usage

``` r
# S3 method for class 'zibbmr_saem'
coef(object, ...)
```

## Arguments

- object:

  Un objeto `zibbmr_saem`, resultado de
  [`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md).

- ...:

  No usado, por compatibilidad con el generico
  [`stats::coef()`](https://rdrr.io/r/stats/coef.html).

## Value

Vector numerico `mu` con los coeficientes de la parte logistica seguidos
de los de la parte beta-binomial.
