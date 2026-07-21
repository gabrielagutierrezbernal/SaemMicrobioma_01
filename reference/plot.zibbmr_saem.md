# Graficos de un ajuste ZIBBMR

Analogo a
[`plot.zibr_saem()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/plot.zibr_saem.md);
genera distintos graficos segun `which`:

- `"convergencia"`:

  (por defecto) traza iteracion-a-iteracion de los parametros, para
  revisar la convergencia del algoritmo SAEM.

- `"coeficientes"`:

  coeficientes estimados con su intervalo de confianza al 95%. Requiere
  `compute_fim = TRUE` para mostrar los intervalos.

- `"aleatorios"`:

  distribucion entre sujetos de los efectos aleatorios estimados; la
  linea roja marca la media poblacional.

## Usage

``` r
# S3 method for class 'zibbmr_saem'
plot(x, which = c("convergencia", "coeficientes", "aleatorios"), ...)
```

## Arguments

- x:

  Un objeto `zibbmr_saem`, resultado de
  [`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md).

- which:

  Tipo de grafico: `"convergencia"`, `"coeficientes"` o `"aleatorios"`.

- ...:

  Argumentos adicionales (no usados por ahora).

## Value

`x`, de forma invisible. Se llama por su efecto secundario de graficar.
