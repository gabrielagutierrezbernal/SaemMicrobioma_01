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

- `"ajuste"`:

  observados frente a predichos de la parte continua, en las
  observaciones positivas (donde el taxon esta presente), con la recta
  `y = x` de referencia. Se enfoca en la parte continua porque en un
  modelo con inflacion de ceros la prediccion marginal mezcla la masa en
  cero.

- `"residuos"`:

  residuos de la parte continua (observado menos predicho individual, en
  observaciones positivas): su dispersion contra el valor predicho y su
  distribucion.

Los graficos `"ajuste"` y `"residuos"` usan los datos originales que el
ajuste guarda; solo estan disponibles para ajustes hechos con una
version del paquete que los almacena.

## Usage

``` r
# S3 method for class 'zibr_saem'
plot(
  x,
  which = c("convergencia", "coeficientes", "aleatorios", "ajuste", "residuos"),
  ...
)
```

## Arguments

- x:

  Un objeto `zibr_saem`, resultado de
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md).

- which:

  Tipo de grafico: `"convergencia"`, `"coeficientes"`, `"aleatorios"`,
  `"ajuste"` o `"residuos"`.

- ...:

  Argumentos adicionales (no usados por ahora).

## Value

`x`, de forma invisible. Se llama por su efecto secundario de graficar.
