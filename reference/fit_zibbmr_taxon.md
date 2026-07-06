# Ajustar ZIBBMR para un taxon de un data frame

Envoltorio de
[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md)
pensado para trabajar directamente sobre un data frame de microbioma en
formato largo con conteos por taxon y una columna de profundidad de
secuenciacion total.

## Usage

``` r
fit_zibbmr_taxon(
  data,
  taxon,
  covariates = NULL,
  x_covariates = covariates,
  z_covariates = covariates,
  total,
  id,
  zi = TRUE,
  phi_start = NULL,
  alpha_start = NULL,
  beta_start = NULL,
  seed = 232,
  n_iter = 1000,
  n_chains = 5,
  compute_fim = FALSE,
  ...
)
```

## Arguments

- data:

  Data frame con una fila por observacion, incluyendo la columna del
  taxon (conteos), la columna `total`, la columna de id y las
  covariables.

- taxon:

  Nombre de la columna en `data` con el conteo del taxon a modelar.

- covariates:

  Vector de nombres de columnas a usar como covariables en ambas partes
  del modelo. Se ignora si se entregan `x_covariates`/`z_covariates` por
  separado.

- x_covariates:

  Nombres de columnas para la parte de inflacion de ceros (por defecto,
  igual a `covariates`).

- z_covariates:

  Nombres de columnas para la parte beta-binomial (por defecto, igual a
  `covariates`).

- total:

  Nombre de la columna en `data` con el total de lecturas de cada
  observacion.

- id:

  Nombre de la columna en `data` que identifica al sujeto.

- zi:

  Logico, ver
  [`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md).

- phi_start:

  Valor inicial de `phi`. Si es `NULL`, se sortea con
  `runif(1, 10, 20)`.

- alpha_start:

  Valores iniciales de la parte logistica. Si es `NULL`, se sortean con
  `runif(., -0.1, 0.1)`.

- beta_start:

  Valores iniciales de la parte beta-binomial. Si es `NULL`, se sortean
  con `runif(., -0.1, 0.1)`.

- seed:

  Semilla aleatoria.

- n_iter:

  Numero de iteraciones SAEM.

- n_chains:

  Numero de cadenas MCMC.

- compute_fim:

  Logico, ver
  [`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md).

- ...:

  Argumentos adicionales pasados a
  [`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md).

## Value

Un objeto `zibbmr_saem`, igual que
[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md).

## See also

[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md),
[`fit_zibbmr_taxa()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr_taxa.md)
