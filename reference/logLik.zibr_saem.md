# Log-verosimilitud marginal de un ajuste ZIBR

Log-verosimilitud marginal de un ajuste ZIBR

## Usage

``` r
# S3 method for class 'zibr_saem'
logLik(object, ...)
```

## Arguments

- object:

  Un objeto `zibr_saem`, resultado de
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md).

- ...:

  No usado, por compatibilidad con el generico
  [`stats::logLik()`](https://rdrr.io/r/stats/logLik.html).

## Value

Un objeto `logLik` con la log-verosimilitud marginal estimada por
importance sampling, con atributos `df` (grados de libertad) y `nobs`.
