# Ajustar un modelo ZIBR (zero-inflated beta regression) via SAEM

Estima por Stochastic Approximation EM (SAEM) un modelo mixto de
regresion beta con inflacion de ceros para una variable respuesta
acotada en `[0, 1)` (por ejemplo, abundancia relativa de un taxon de
microbioma), siguiendo el metodo descrito en Barrera (ZIBR: "A
stochastic method to estimate a zero-inflated two-part mixed model for
human microbiome data"). El modelo tiene dos partes: una logistica para
la probabilidad de presencia (`X`/`alpha`) y una beta para la magnitud
condicional a estar presente (`Z`/`beta`, `phi`), ambas con un
intercepto aleatorio por sujeto.

## Usage

``` r
fit_zibr(
  y,
  id,
  X = NULL,
  Z = NULL,
  zi = TRUE,
  phi_start,
  alpha_start = NULL,
  beta_start,
  n_iter = 500,
  n_chains = 5,
  seed = NULL,
  alpha_random = NULL,
  beta_random = NULL,
  n_is = 500,
  compute_fim = TRUE,
  eps = 1e-06
)
```

## Arguments

- y:

  Vector numerico de proporciones en `[0, 1)` (la respuesta).

- id:

  Vector (o factor) que identifica al sujeto de cada observacion en `y`.
  Debe tener la misma longitud que `y`.

- X:

  Matriz o data frame de covariables para la parte de inflacion de ceros
  (parte logistica). `NULL` si `zi = FALSE`.

- Z:

  Matriz o data frame de covariables para la parte beta (magnitud
  condicional). `NULL` equivale a solo intercepto.

- zi:

  Logico. Si `TRUE` (por defecto) ajusta la parte de inflacion de ceros;
  si `FALSE`, asume que `y` no tiene ceros estructurales.

- phi_start:

  Valor inicial del parametro de dispersion `phi` de la parte beta.

- alpha_start:

  Vector de valores iniciales para los coeficientes de la parte
  logistica (intercepto + columnas de `X`). Requerido si `zi = TRUE`.

- beta_start:

  Vector de valores iniciales para los coeficientes de la parte beta
  (intercepto + columnas de `Z`).

- n_iter:

  Numero de iteraciones del algoritmo SAEM.

- n_chains:

  Numero de cadenas MCMC paralelas usadas en el paso de simulacion
  estocastica (S-step).

- seed:

  Semilla aleatoria opcional.

- alpha_random:

  Vector logico que indica que coeficientes de la parte logistica son
  efectos aleatorios (por defecto, solo el intercepto).

- beta_random:

  Vector logico que indica que coeficientes de la parte beta son efectos
  aleatorios (por defecto, solo el intercepto).

- n_is:

  Numero de muestras de importance sampling usadas para estimar la
  log-verosimilitud marginal al final del ajuste.

- compute_fim:

  Logico. Si `TRUE`, calcula la matriz de informacion de Fisher
  estocastica (necesaria para
  [`vcov()`](https://rdrr.io/r/stats/vcov.html)/[`se()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/se.md)).

- eps:

  Valor pequeno usado para evitar `log(0)` cuando `y` contiene valores
  exactamente 0 (con `zi = FALSE`) o exactamente 1.

## Value

Un objeto de clase `zibr_saem` (y `SAEM_ZIBR_result` por
compatibilidad), una lista con, entre otros, los elementos `mu` (alpha y
beta concatenados), `G` (varianza de efectos aleatorios), `phi`,
`loglik`, `trace` y `fisher_stoch`. Tiene metodos
[`print()`](https://rdrr.io/r/base/print.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`stats::logLik()`](https://rdrr.io/r/stats/logLik.html),
[`stats::coef()`](https://rdrr.io/r/stats/coef.html),
[`stats::vcov()`](https://rdrr.io/r/stats/vcov.html) y
[`se()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/se.md).

## See also

[`fit_zibr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr_taxon.md)
para ajustar directamente sobre una columna de un data frame,
[`simulate_zibr_data()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/simulate_zibr_data.md)
para generar datos de prueba,
[`lrt_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibr.md)
para comparar modelos anidados.

## Examples

``` r
# \donttest{
dat <- simulate_zibr_data(
  n_subjects = 20, n_time = 4, alpha = c(-0.3, 0.5), beta = c(0.2, -0.4),
  sigma_alpha = 0.4, sigma_beta = 0.3, phi = 15,
  X = matrix(rbinom(80, 1, 0.5)), Z = matrix(rbinom(80, 1, 0.5)), seed = 1
)
fit <- fit_zibr(
  y = dat$Y, id = dat$Subject, X = dat$X.1, Z = dat$Z.1,
  phi_start = 10, alpha_start = c(-0.2, 0.1), beta_start = c(0.1, 0.1),
  n_iter = 50, seed = 1, compute_fim = FALSE
)
print(fit)
#> ===== Resultados SAEM-ZIBR =====
#> == Parte logistica: p_it ==
#>             Estimate   Type
#> Intercept -0.6427290 Random
#> X.1        0.8896106  Fixed
#> == Parte beta: u_it ==
#>             Estimate   Type
#> Intercept  0.2046442 Random
#> Z.1       -0.3698988  Fixed
#> === Varianzas de efectos aleatorios ===
#> == Parte logistica ==
#>             Variance  sqrt.Var
#> Intercept 0.03175983 0.1782129
#> == Parte beta ==
#>             Variance  sqrt.Var
#> Intercept 0.01772203 0.1331241
#> === Phi: 24.4882
#> === Log-verosimilitud marginal (importance sampling): -22.43429
# }
```
