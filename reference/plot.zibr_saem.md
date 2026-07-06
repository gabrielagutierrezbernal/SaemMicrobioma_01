# Graficar la traza de convergencia de un ajuste ZIBR

Dibuja la traza iteracion-a-iteracion de los parametros del modelo
(`x$trace`), util para revisar visualmente la convergencia del algoritmo
SAEM.

## Usage

``` r
# S3 method for class 'zibr_saem'
plot(x, ...)
```

## Arguments

- x:

  Un objeto `zibr_saem`, resultado de
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md).

- ...:

  No usado, por compatibilidad con el generico
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html).

## Value

`x`, de forma invisible. Se llama por su efecto secundario de graficar.
