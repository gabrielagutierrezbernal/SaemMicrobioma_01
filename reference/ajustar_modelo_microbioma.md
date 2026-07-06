# Ajustar un modelo SAEM de microbioma (ZIBR o ZIBBMR) desde un data frame

Funcion "madre" que despacha a
[`saem_zibr_clean()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/saem_zibr_clean.md)
o
[`saem_zibbmr_clean()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/saem_zibbmr_clean.md)
segun `modelo`, extrayendo la respuesta, el total de lecturas (si
aplica) y las covariables directamente de un data frame por nombre de
columna, y generando valores iniciales por defecto razonables. Pensada
para ajustar rapidamente un taxon sin tener que armar a mano las
matrices `X`/`Z` y los vectores de valores iniciales que piden
[`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)/[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md).

## Usage

``` r
ajustar_modelo_microbioma(
  modelo = c("zibbmr", "zibr"),
  datos,
  taxon,
  id = "id",
  total = "N",
  covariables = c("tiempo", "grupo"),
  zi = TRUE,
  iter = 200,
  ncad = 5,
  seed = 1
)

fit_saem_microbiome(
  modelo = c("zibbmr", "zibr"),
  datos,
  taxon,
  id = "id",
  total = "N",
  covariables = c("tiempo", "grupo"),
  zi = TRUE,
  iter = 200,
  ncad = 5,
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

  Vector de nombres de columnas en `datos` a usar como covariables,
  tanto en la parte logistica como en la parte beta/beta-binomial.

- zi:

  Logico, ver
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)/[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md).

- iter:

  Numero de iteraciones SAEM.

- ncad:

  Numero de cadenas MCMC.

- seed:

  Semilla aleatoria.

## Value

Un objeto `zibr_saem` o `zibbmr_saem`, segun `modelo`.

## Details

`fit_saem_microbiome()` es un alias identico, con un nombre que sigue la
convencion `fit_*` del resto del paquete.

## See also

[`fit_zibr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr_taxon.md),
[`fit_zibbmr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr_taxon.md)
para envoltorios equivalentes con la firma de argumentos moderna
(`n_iter`, `n_chains`, `x_covariates`/`z_covariates` separados).
