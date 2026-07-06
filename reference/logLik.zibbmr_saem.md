# Log-verosimilitud marginal de un ajuste ZIBBMR

Log-verosimilitud marginal de un ajuste ZIBBMR

## Usage

``` r
# S3 method for class 'zibbmr_saem'
logLik(object, ...)
```

## Arguments

- object:

  Un objeto `zibbmr_saem`, resultado de
  [`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md).

- ...:

  No usado, por compatibilidad con el generico
  [`stats::logLik()`](https://rdrr.io/r/stats/logLik.html).

## Value

Un objeto `logLik` con la log-verosimilitud marginal estimada por
importance sampling, con atributos `df` y `nobs`.
