# Simular un conjunto de datos de microbioma con varios taxones

Genera conteos multinomiales por sujeto-tiempo para varios taxones
simultaneamente, pensado como dataset de juguete rapido para probar el
flujo completo del paquete (no usa un modelo ZIBR/ZIBBMR generador; para
simular datos consistentes con esos modelos usar
[`simulate_zibr_data()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/simulate_zibr_data.md)
o
[`simulate_zibbmr_data()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/simulate_zibbmr_data.md)).

## Usage

``` r
simular_datos_microbioma(
  n_ind = 8,
  n_time = 3,
  n_taxa = 5,
  N = 1000,
  seed = 123
)
```

## Arguments

- n_ind:

  Numero de sujetos.

- n_time:

  Numero de observaciones (tiempos) por sujeto.

- n_taxa:

  Numero de taxones a simular.

- N:

  Total de lecturas por observacion (profundidad de secuenciacion).

- seed:

  Semilla aleatoria.

## Value

Una lista con `conteo` (data frame de conteos por taxon, con columnas
`id`, `tiempo`, `grupo`, `N` y una columna por taxon), `proporcion`
(igual pero con las columnas de taxon convertidas a proporciones) y
`taxa` (nombres de las columnas de taxon).

## See also

[`simulate_zibr_data()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/simulate_zibr_data.md),
[`simulate_zibbmr_data()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/simulate_zibbmr_data.md)

## Examples

``` r
sim <- simular_datos_microbioma(n_ind = 5, n_time = 3, n_taxa = 4)
head(sim$conteo)
#>   id tiempo grupo    N Taxon1 Taxon2 Taxon3 Taxon4
#> 1  1      1     0 1000     35    286    283    396
#> 2  1      2     0 1000    428    226    207    139
#> 3  1      3     0 1000    573    166    221     40
#> 4  2      1     1 1000     41    554    297    108
#> 5  2      2     1 1000     11    150    163    676
#> 6  2      3     1 1000     76    326    228    370
```
