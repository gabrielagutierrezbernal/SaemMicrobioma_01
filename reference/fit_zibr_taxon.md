# Ajustar ZIBR para un taxon de un data frame

Envoltorio de
[`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)
pensado para trabajar directamente sobre un data frame de microbioma en
formato largo (una fila por sujeto-tiempo, una columna por taxon).
Extrae la columna del taxon y las covariables por nombre, genera valores
iniciales aleatorios razonables si no se entregan, y llama a
[`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md).

## Usage

``` r
fit_zibr_taxon(
  data,
  taxon,
  covariates = NULL,
  x_covariates = covariates,
  z_covariates = covariates,
  id,
  zi = TRUE,
  phi_start = NULL,
  alpha_start = NULL,
  beta_start = NULL,
  seed = 232,
  n_iter = 500,
  n_chains = 5,
  compute_fim = FALSE,
  ...
)
```

## Arguments

- data:

  Data frame con una fila por observacion, incluyendo la columna del
  taxon, la columna de id y las covariables.

- taxon:

  Nombre de la columna en `data` con la proporcion del taxon a modelar.

- covariates:

  Vector de nombres de columnas a usar como covariables tanto en la
  parte logistica como en la parte beta. Se ignora si se entregan
  `x_covariates`/`z_covariates` por separado.

- x_covariates:

  Nombres de columnas para la parte de inflacion de ceros (por defecto,
  igual a `covariates`).

- z_covariates:

  Nombres de columnas para la parte beta (por defecto, igual a
  `covariates`).

- id:

  Nombre de la columna en `data` que identifica al sujeto.

- zi:

  Logico, ver
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md).

- phi_start:

  Valor inicial de `phi`. Si es `NULL`, se sortea con
  `runif(1, 10, 20)`.

- alpha_start:

  Valores iniciales de la parte logistica. Si es `NULL`, se sortean con
  `runif(., -0.1, 0.1)`.

- beta_start:

  Valores iniciales de la parte beta. Si es `NULL`, se sortean con
  `runif(., -0.1, 0.1)`.

- seed:

  Semilla aleatoria, usada tanto para los valores iniciales como para el
  ajuste SAEM.

- n_iter:

  Numero de iteraciones SAEM.

- n_chains:

  Numero de cadenas MCMC.

- compute_fim:

  Logico, ver
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md).

- ...:

  Argumentos adicionales pasados a
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md).

## Value

Un objeto `zibr_saem`, igual que
[`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md).

## See also

[`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md),
[`fit_zibr_taxa()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr_taxa.md)
