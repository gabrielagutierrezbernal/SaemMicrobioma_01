# Matriz de varianza-covarianza de un ajuste ZIBBMR

Matriz de varianza-covarianza de un ajuste ZIBBMR

## Usage

``` r
# S3 method for class 'zibbmr_saem'
vcov(object, ...)
```

## Arguments

- object:

  Un objeto `zibbmr_saem` ajustado con `compute_fim = TRUE`.

- ...:

  No usado, por compatibilidad con el generico
  [`stats::vcov()`](https://rdrr.io/r/stats/vcov.html).

## Value

Una matriz de varianza-covarianza.
