# Tabla resumen de tres comparaciones LRT tipicas para ZIBR

Arma una tabla de resultados con dos pruebas de razon de verosimilitudes
sobre un efecto principal (`mod1` vs. `mod2`, ej. embarazo) y una prueba
de interaccion (`mod2` con y sin termino de interaccion), replicando el
formato de reporte usado en el analisis de datos tipo Romero.

## Usage

``` r
zibr_results_table(
  species,
  mod1_full,
  mod1_no_preg,
  mod2_full,
  mod2_no_preg,
  mod2_no_inter,
  df = 2,
  alpha = 0.05
)
```

## Arguments

- species:

  Vector de nombres/etiquetas para cada taxon.

- mod1_full, mod1_no_preg:

  Listas de modelos ZIBR (con y sin el efecto principal) para la primera
  comparacion, uno por taxon.

- mod2_full, mod2_no_preg, mod2_no_inter:

  Listas de modelos ZIBR para la segunda comparacion (efecto principal)
  y la prueba de interaccion, uno por taxon.

- df:

  Grados de libertad usados en las tres pruebas.

- alpha:

  Nivel de significancia usado para las columnas `Detec_*`.

## Value

Un data frame con una fila por taxon, con las log-verosimilitudes,
p-valores y detecciones de las tres comparaciones.
