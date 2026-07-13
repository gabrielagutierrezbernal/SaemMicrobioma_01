# Ajustar un modelo ZIBBMR (zero-inflated beta-binomial mixed regression) via SAEM

Estima por Stochastic Approximation EM (SAEM) un modelo mixto
beta-binomial con inflacion de ceros para datos longitudinales de conteo
con profundidad de secuenciacion conocida (`S`), siguiendo el metodo
descrito en Barrera (ZIBBMR: "Stochastic EM Estimation and Inference in
Zero-Inflated Beta-Binomial Mixed Models for Longitudinal Count Data").
Es el analogo de
[`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)
para conteos: en vez de modelar una proporcion observada directamente,
modela el numero de lecturas `y` de un taxon sobre un total `S`
(profundidad de secuenciacion de la muestra) con una verosimilitud
beta-binomial.

## Usage

``` r
fit_zibbmr(
  y,
  S,
  id,
  X = NULL,
  Z = NULL,
  zi = TRUE,
  phi_start,
  alpha_start = NULL,
  beta_start,
  n_iter = 1000,
  n_chains = 5,
  seed = NULL,
  alpha_random = NULL,
  beta_random = NULL,
  n_is = 500,
  compute_fim = TRUE
)
```

## Arguments

- y:

  Vector de conteos (numero de lecturas del taxon), `0 <= y <= S`.

- S:

  Vector con el total de lecturas (profundidad de secuenciacion) de cada
  observacion, misma longitud que `y`.

- id:

  Vector (o factor) que identifica al sujeto de cada observacion.

- X:

  Matriz o data frame de covariables para la parte de inflacion de ceros
  (parte logistica). `NULL` si `zi = FALSE`.

- Z:

  Matriz o data frame de covariables para la parte beta-binomial
  (magnitud condicional). `NULL` equivale a solo intercepto.

- zi:

  Logico. Si `TRUE` (por defecto) ajusta la parte de inflacion de ceros.

- phi_start:

  Valor inicial del parametro de dispersion `phi`.

- alpha_start:

  Vector de valores iniciales para los coeficientes de la parte
  logistica. Requerido si `zi = TRUE`.

- beta_start:

  Vector de valores iniciales para los coeficientes de la parte
  beta-binomial.

- n_iter:

  Numero de iteraciones del algoritmo SAEM.

- n_chains:

  Numero de cadenas MCMC paralelas usadas en el S-step.

- seed:

  Semilla aleatoria opcional.

- alpha_random:

  Vector logico que indica que coeficientes de la parte logistica son
  efectos aleatorios (por defecto, solo el intercepto).

- beta_random:

  Vector logico que indica que coeficientes de la parte beta-binomial
  son efectos aleatorios (por defecto, solo el intercepto).

- n_is:

  Numero de muestras de importance sampling para la log-verosimilitud
  marginal.

- compute_fim:

  Logico. Si `TRUE`, calcula la matriz de informacion de Fisher
  estocastica (necesaria para
  [`vcov()`](https://rdrr.io/r/stats/vcov.html)/[`se()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/se.md)).

## Value

Un objeto de clase `zibbmr_saem` (y `SAEM_ZIBBMR_result` por
compatibilidad), con los mismos elementos que
[`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)
(`mu`, `G`, `phi`, `loglik`, `trace`, `fisher_stoch`, etc.). Tiene
metodos [`print()`](https://rdrr.io/r/base/print.html),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`stats::logLik()`](https://rdrr.io/r/stats/logLik.html),
[`stats::coef()`](https://rdrr.io/r/stats/coef.html),
[`stats::vcov()`](https://rdrr.io/r/stats/vcov.html) y
[`se()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/se.md).

## See also

[`fit_zibbmr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr_taxon.md),
[`simulate_zibbmr_data()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/simulate_zibbmr_data.md),
[`lrt_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibbmr.md),
[`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)
para la version en proporciones.

## Examples

``` r
# \donttest{
n_subjects <- 20
n_time <- 4
n_obs <- n_subjects * n_time
dat <- simulate_zibbmr_data(
  n_subjects = n_subjects, n_time = n_time, S = rep(1000, n_obs),
  alpha = c(-0.3, 0.5), beta = c(0.2, -0.4),
  sigma_alpha = 0.4, sigma_beta = 0.3, phi = 15,
  X = matrix(rbinom(n_obs, 1, 0.5)), Z = matrix(rbinom(n_obs, 1, 0.5)),
  seed = 1
)
fit <- fit_zibbmr(
  y = dat$Y, S = dat$TotalCounts, id = dat$Subject,
  X = dat$X.1, Z = dat$Z.1,
  phi_start = 10, alpha_start = c(-0.2, 0.1), beta_start = c(0.1, 0.1),
  n_iter = 50, seed = 1, compute_fim = FALSE
)
print(fit)
#> ===== Resultados SAEM-ZIBBMR =====
#> == Parte logistica: p_it ==
#>             Estimate   Type
#> Intercept -0.5592309 Random
#> X.1        0.4972774  Fixed
#> == Parte beta-binomial: u_it ==
#>             Estimate   Type
#> Intercept  0.1423486 Random
#> Z.1       -0.4908755  Fixed
#> === Varianzas de efectos aleatorios ===
#> == Parte logistica ==
#>             Variance  sqrt.Var
#> Intercept 0.05721818 0.2392032
#> == Parte beta-binomial ==
#>             Variance  sqrt.Var
#> Intercept 0.05981523 0.2445715
#> === Phi: 12.0252
#> === Log-verosimilitud marginal (importance sampling): -272.1644
# }
```
