# Ajustar ZIBBMR para varios taxones de un data frame

Aplica
[`fit_zibbmr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr_taxon.md)
a cada elemento de `taxa`, con la misma configuracion de covariables e
iteraciones para todos.

## Usage

``` r
fit_zibbmr_taxa(
  data,
  taxa,
  covariates = NULL,
  x_covariates = covariates,
  z_covariates = covariates,
  total,
  id,
  zi = TRUE,
  seed = 232,
  n_iter = 1000,
  n_chains = 5,
  compute_fim = FALSE,
  ...
)
```

## Arguments

- data:

  Data frame con una fila por observacion.

- taxa:

  Vector de nombres de columnas (taxones) a ajustar.

- covariates, x_covariates, z_covariates:

  Ver
  [`fit_zibbmr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr_taxon.md).

- total:

  Nombre de la columna con el total de lecturas.

- id:

  Nombre de la columna que identifica al sujeto.

- zi:

  Logico, ver
  [`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md).

- seed:

  Semilla aleatoria (se reutiliza para cada taxon).

- n_iter:

  Numero de iteraciones SAEM.

- n_chains:

  Numero de cadenas MCMC.

- compute_fim:

  Logico, ver
  [`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md).

- ...:

  Argumentos adicionales pasados a
  [`fit_zibbmr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr_taxon.md).

## Value

Una lista de objetos `zibbmr_saem`, nombrada segun `taxa`.

## See also

[`fit_zibbmr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr_taxon.md)
