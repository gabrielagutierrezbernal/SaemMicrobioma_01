# Ajustar ZIBR para varios taxones de un data frame

Aplica
[`fit_zibr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr_taxon.md)
a cada elemento de `taxa`, con la misma configuracion de covariables e
iteraciones para todos.

## Usage

``` r
fit_zibr_taxa(
  data,
  taxa,
  covariates = NULL,
  x_covariates = covariates,
  z_covariates = covariates,
  id,
  zi = TRUE,
  seed = 232,
  n_iter = 500,
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
  [`fit_zibr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr_taxon.md).

- id:

  Nombre de la columna que identifica al sujeto.

- zi:

  Logico, ver
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md).

- seed:

  Semilla aleatoria (se reutiliza para cada taxon).

- n_iter:

  Numero de iteraciones SAEM.

- n_chains:

  Numero de cadenas MCMC.

- compute_fim:

  Logico, ver
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md).

- ...:

  Argumentos adicionales pasados a
  [`fit_zibr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr_taxon.md).

## Value

Una lista de objetos `zibr_saem`, nombrada segun `taxa`.

## See also

[`fit_zibr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr_taxon.md)
