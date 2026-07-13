# Simular datos longitudinales para un modelo ZIBR

Genera un data frame de datos longitudinales compatibles con
[`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md):
una respuesta continua acotada en `[0, 1]`, con inflacion de ceros
opcional, efectos fijos y un intercepto (u otros coeficientes)
aleatorios por sujeto con distribucion normal multivariada.

## Usage

``` r
simulate_zibr_data(
  n_subjects,
  n_time,
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

- zi:

  Logico. Si `TRUE` (por defecto), simula presencia/ausencia con un
  modelo logistico (`X`/`alpha`) antes de simular la magnitud beta.

- X:

  Matriz o data frame de covariables para la parte de inflacion de
  ceros. `NULL` si `zi = FALSE`.

- Z:

  Matriz o data frame de covariables para la parte beta.

- alpha:

  Vector de coeficientes verdaderos de la parte logistica (intercepto +
  columnas de `X`). Requerido si `zi = TRUE`.

- beta:

  Vector de coeficientes verdaderos de la parte beta (intercepto

  - columnas de `Z`).

- sigma_alpha:

  Desviacion estandar del intercepto aleatorio de la parte logistica.
  Requerido si `zi = TRUE`.

- sigma_beta:

  Desviacion estandar del intercepto aleatorio de la parte beta.

- phi:

  Parametro de dispersion de la distribucion beta.

- seed:

  Semilla aleatoria opcional.

## Value

Un data frame con columnas `Subject`, `Time`, `Y` (la respuesta
simulada) y las covariables de `X`/`Z` usadas.

## See also

[`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)

## Examples

``` r
n_subjects <- 10
n_time <- 3
n_obs <- n_subjects * n_time
dat <- simulate_zibr_data(
  n_subjects = n_subjects, n_time = n_time, alpha = c(-0.3, 0.5),
  beta = c(0.2, -0.4), sigma_alpha = 0.4, sigma_beta = 0.3, phi = 15,
  X = matrix(rbinom(n_obs, 1, 0.5)), Z = matrix(rbinom(n_obs, 1, 0.5)),
  seed = 1
)
head(dat)
#>     Subject Time         Y X.1 Z.1
#> 1 Subject.1    1 0.0000000   0   0
#> 2 Subject.1    2 0.0000000   0   1
#> 3 Subject.1    3 0.0000000   1   0
#> 4 Subject.2    1 0.0000000   1   0
#> 5 Subject.2    2 0.3663058   0   1
#> 6 Subject.2    3 0.5593978   1   1
```
