# Ajustar un modelo SAEM de microbioma (ZIBR o ZIBBMR) desde un data frame

Funcion "madre" que despacha a
[`saem_zibr_clean()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/saem_zibr_clean.md)
o
[`saem_zibbmr_clean()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/saem_zibbmr_clean.md)
segun `modelo`, extrayendo la respuesta, el total de lecturas (si
aplica) y las covariables directamente de un data frame por nombre de
columna, y generando valores iniciales por defecto razonables si no se
entregan. Pensada para ajustar rapidamente un taxon sin tener que armar
a mano las matrices `X`/`Z` y los vectores de valores iniciales que
piden
[`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)/[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md).
Sigue el mismo patron que
[`fit_zibr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr_taxon.md)/[`fit_zibbmr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr_taxon.md).

## Usage

``` r
ajustar_modelo_microbioma(
  modelo = c("zibbmr", "zibr"),
  datos,
  taxon,
  id = "id",
  total = "N",
  covariables = c("tiempo", "grupo"),
  x_covariables = covariables,
  z_covariables = covariables,
  zi = TRUE,
  phi_start = NULL,
  alpha_start = NULL,
  beta_start = NULL,
  iter = 200,
  ncad = 5,
  compute_fim = FALSE,
  seed = 1
)

fit_saem_microbiome(
  modelo = c("zibbmr", "zibr"),
  datos,
  taxon,
  id = "id",
  total = "N",
  covariables = c("tiempo", "grupo"),
  x_covariables = covariables,
  z_covariables = covariables,
  zi = TRUE,
  phi_start = NULL,
  alpha_start = NULL,
  beta_start = NULL,
  iter = 200,
  ncad = 5,
  compute_fim = FALSE,
  seed = 1
)
```

## Arguments

- modelo:

  Cual modelo ajustar: `"zibbmr"` (por defecto, conteos con profundidad
  de secuenciacion) o `"zibr"` (proporciones).

- datos:

  Data frame con una fila por observacion.

- taxon:

  Nombre de la columna en `datos` con la respuesta (conteo o proporcion,
  segun `modelo`) a modelar.

- id:

  Nombre de la columna en `datos` que identifica al sujeto.

- total:

  Nombre de la columna en `datos` con el total de lecturas. Solo se usa
  si `modelo = "zibbmr"`.

- covariables:

  Vector de nombres de columnas en `datos` a usar como covariables tanto
  en la parte logistica como en la parte beta/beta-binomial. Se ignora
  si se entregan `x_covariables`/ `z_covariables` por separado.

- x_covariables:

  Nombres de columnas para la parte de inflacion de ceros (por defecto,
  igual a `covariables`).

- z_covariables:

  Nombres de columnas para la parte beta/beta-binomial (por defecto,
  igual a `covariables`).

- zi:

  Logico, ver
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)/[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md).

- phi_start:

  Valor inicial de dispersion. Si es `NULL` (por defecto), se sortea con
  `runif(1, 10, 20)`.

- alpha_start:

  Valores iniciales de la parte logistica. Si es `NULL` (por defecto),
  se sortean con `runif(., -0.1, 0.1)`. Se ignora si `zi = FALSE`.

- beta_start:

  Valores iniciales de la parte beta/beta-binomial. Si es `NULL` (por
  defecto), se sortean con `runif(., -0.1, 0.1)`.

- iter:

  Numero de iteraciones SAEM.

- ncad:

  Numero de cadenas MCMC.

- compute_fim:

  Logico. Si `TRUE`, calcula la matriz de informacion de Fisher
  estocastica (necesaria para
  [`vcov()`](https://rdrr.io/r/stats/vcov.html)/[`se()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/se.md)).

- seed:

  Semilla aleatoria, usada tanto para los valores iniciales (cuando se
  sortean) como para el ajuste SAEM.

## Value

Un objeto `zibr_saem` o `zibbmr_saem`, segun `modelo`.

## Details

`fit_saem_microbiome()` es un alias identico, con un nombre que sigue la
convencion `fit_*` del resto del paquete.

## See also

[`fit_zibr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr_taxon.md),
[`fit_zibbmr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr_taxon.md)
para envoltorios equivalentes con la firma de argumentos moderna
(`n_iter`, `n_chains`).
