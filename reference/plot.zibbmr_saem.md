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

- `"ajuste"`:

  observados frente a predichos de la parte continua, en las
  observaciones positivas (el conteo esperado dado presencia, `u * S`),
  con la recta `y = x` de referencia.

- `"residuos"`:

  residuos de la parte continua (observado menos predicho individual, en
  observaciones positivas): su dispersion contra el valor predicho y su
  distribucion.

Los graficos `"ajuste"` y `"residuos"` usan los datos originales que el
ajuste guarda.

## Usage

``` r
# S3 method for class 'zibbmr_saem'
plot(
  x,
  which = c("convergencia", "coeficientes", "aleatorios", "ajuste", "residuos"),
  ...
)
```

## Arguments

- x:

  Un objeto `zibbmr_saem`, resultado de
  [`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md).

- which:

  Tipo de grafico: `"convergencia"`, `"coeficientes"`, `"aleatorios"`,
  `"ajuste"` o `"residuos"`.

- ...:

  Argumentos adicionales (no usados por ahora).

## Value

`x`, de forma invisible. Se llama por su efecto secundario de graficar.
