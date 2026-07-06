# Matriz de varianza-covarianza de un ajuste ZIBR

Calcula la inversa de la matriz de informacion de Fisher estocastica
(`fisher_stoch`), estimada durante el ajuste SAEM.

## Usage

``` r
# S3 method for class 'zibr_saem'
vcov(object, ...)
```

## Arguments

- object:

  Un objeto `zibr_saem` ajustado con `compute_fim = TRUE`.

- ...:

  No usado, por compatibilidad con el generico
  [`stats::vcov()`](https://rdrr.io/r/stats/vcov.html).

## Value

Una matriz de varianza-covarianza.
