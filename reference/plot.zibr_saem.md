# Graficos de un ajuste ZIBR

Genera distintos graficos de diagnostico/resultado segun `which`:

- `"convergencia"`:

  (por defecto) traza iteracion-a-iteracion de los parametros, para
  revisar la convergencia del algoritmo SAEM.

- `"coeficientes"`:

  coeficientes estimados con su intervalo de confianza al 95% (tipo
  forest plot). Requiere haber ajustado con `compute_fim = TRUE` para
  mostrar los intervalos.

- `"aleatorios"`:

  distribucion entre sujetos de los efectos aleatorios estimados (uno
  por sujeto); la linea roja marca la media poblacional.

## Usage

``` r
# S3 method for class 'zibr_saem'
plot(x, which = c("convergencia", "coeficientes", "aleatorios"), ...)
```

## Arguments

- x:

  Un objeto `zibr_saem`, resultado de
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md).

- which:

  Tipo de grafico: `"convergencia"`, `"coeficientes"` o `"aleatorios"`.

- ...:

  Argumentos adicionales (no usados por ahora).

## Value

`x`, de forma invisible. Se llama por su efecto secundario de graficar.
