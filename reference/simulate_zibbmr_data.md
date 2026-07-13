# Simular datos longitudinales de conteo para un modelo ZIBBMR

Genera un data frame de datos longitudinales compatibles con
[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md):
un conteo de lecturas `Y` sobre un total `S`, con inflacion de ceros
opcional, efectos fijos y un intercepto (u otros coeficientes)
aleatorios por sujeto.

## Usage

``` r
simulate_zibbmr_data(
  n_subjects,
  n_time,
  S,
  zi = TRUE,
  X = NULL,
  Z = NULL,
  alpha = NULL,
  beta,
  sigma_alpha = NULL,
  sigma_beta,
  phi,
  seed = NULL
)
```

## Arguments

- n_subjects:

  Numero de sujetos.

- n_time:

  Numero de observaciones (tiempos) por sujeto.

- S:

  Vector con el total de lecturas de cada observacion, de longitud
  `n_subjects * n_time`.

- zi:

  Logico. Si `TRUE` (por defecto), simula presencia/ausencia con un
  modelo logistico (`X`/`alpha`) antes de simular el conteo.

- X:

  Matriz o data frame de covariables para la parte de inflacion de
  ceros. `NULL` si `zi = FALSE`.

- Z:

  Matriz o data frame de covariables para la parte beta-binomial.

- alpha:

  Vector de coeficientes verdaderos de la parte logistica. Requerido si
  `zi = TRUE`.

- beta:

  Vector de coeficientes verdaderos de la parte beta-binomial.

- sigma_alpha:

  Desviacion estandar del intercepto aleatorio de la parte logistica.
  Requerido si `zi = TRUE`.

- sigma_beta:

  Desviacion estandar del intercepto aleatorio de la parte
  beta-binomial.

- phi:

  Parametro de dispersion de la distribucion beta-binomial.

- seed:

  Semilla aleatoria opcional.

## Value

Un data frame con columnas `Subject`, `Time`, `Y` (conteo simulado),
`TotalCounts` (igual a `S`) y las covariables usadas.

## See also

[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md)

## Examples

``` r
n_subjects <- 10
n_time <- 3
n_obs <- n_subjects * n_time
dat <- simulate_zibbmr_data(
  n_subjects = n_subjects, n_time = n_time, S = rep(1000, n_obs),
  alpha = c(-0.3, 0.5), beta = c(0.2, -0.4),
  sigma_alpha = 0.4, sigma_beta = 0.3, phi = 15,
  X = matrix(rbinom(n_obs, 1, 0.5)), Z = matrix(rbinom(n_obs, 1, 0.5)),
  seed = 1
)
head(dat)
#>     Subject Time   Y TotalCounts X.1 Z.1
#> 1 Subject.1    1   0        1000   0   0
#> 2 Subject.1    2   0        1000   0   1
#> 3 Subject.1    3   0        1000   1   0
#> 4 Subject.2    1 736        1000   1   0
#> 5 Subject.2    2   0        1000   0   1
#> 6 Subject.2    3   0        1000   1   1
```
