
# saemMicrobiome

<!-- badges: start -->

[![R-CMD-check](https://github.com/gabrielagutierrezbernal/SaemMicrobioma_01/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/gabrielagutierrezbernal/SaemMicrobioma_01/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`saemMicrobiome` implementa dos modelos mixtos con inflación de ceros
para datos longitudinales de microbioma, estimados con el algoritmo
Stochastic Approximation EM (SAEM):

- **ZIBR** (zero-inflated beta regression) para proporciones o
  abundancias relativas — ver \[`fit_zibr()`\].
- **ZIBBMR** (zero-inflated beta-binomial mixed regression) para conteos
  con profundidad de secuenciacion conocida — ver \[`fit_zibbmr()`\].

Ambos modelos y su algoritmo de estimación fueron desarrollados
originalmente por John Barrera:

- ZIBR: <https://github.com/jbarrera232/saem-zibr>
- ZIBBMR: <https://github.com/jbarrera232/saem-zibbmr>

Este paquete organiza, documenta y testea esa implementacion para uso
general en analisis de microbioma longitudinal.

## Instalación

``` r
# install.packages("remotes")
remotes::install_github("gabrielagutierrezbernal/SaemMicrobioma_01")
```

## Ejemplo: ZIBR (proporciones)

> **Nota:** el ejemplo usa 300 sujetos, un tamaño de muestra suficiente
> para que los estimados queden cerca de los valores verdaderos usados
> en la simulación (`alpha = c(-0.3, 0.5)`, `beta = c(0.2, -0.4)`,
> `phi = 15`). Con muestras pequeñas, los estimados de un único ajuste
> traen más ruido de muestreo; en la carpeta `estudios/` se muestra cómo
> el error disminuye al aumentar el número de sujetos.

``` r
library(saemMicrobiome)

# Solo hace falta cambiar n_subjects / n_time; n_obs se deriva de ellos.
n_subjects <- 300
n_time <- 4
n_obs <- n_subjects * n_time

set.seed(3)
dat <- simulate_zibr_data(
  n_subjects = n_subjects, n_time = n_time,
  X = matrix(rbinom(n_obs, 1, 0.5)), Z = matrix(rbinom(n_obs, 1, 0.5)),
  alpha = c(-0.3, 0.5), beta = c(0.2, -0.4),
  sigma_alpha = 0.4, sigma_beta = 0.3, phi = 15, seed = 3
)

fit <- fit_zibr(
  y = dat$Y, id = dat$Subject, X = dat$X.1, Z = dat$Z.1,
  phi_start = 10, alpha_start = c(-0.2, 0.1), beta_start = c(0.1, 0.1),
  n_iter = 300, seed = 1, compute_fim = FALSE
)

# Los estimados quedan cerca de los valores verdaderos (-0.3, 0.5, 0.2, -0.4, 15)
print(fit)
#> ===== Resultados SAEM-ZIBR =====
#> == Parte logistica: p_it ==
#>             Estimate   Type
#> Intercept -0.3452425 Random
#> X.1        0.5254036  Fixed
#> == Parte beta: u_it ==
#>             Estimate   Type
#> Intercept  0.2479627 Random
#> Z.1       -0.4706110  Fixed
#> === Varianzas de efectos aleatorios ===
#> == Parte logistica ==
#>            Variance  sqrt.Var
#> Intercept 0.2284159 0.4779287
#> == Parte beta ==
#>             Variance  sqrt.Var
#> Intercept 0.09681802 0.3111559
#> === Phi: 15.4154
#> === Log-verosimilitud marginal (importance sampling): -493.6766
```

## Ejemplo: ZIBBMR (conteos con profundidad de secuenciacion)

``` r
# Reutiliza n_subjects / n_time / n_obs del ejemplo anterior.
S <- rep(1000, n_obs)
set.seed(3)
dat_counts <- simulate_zibbmr_data(
  n_subjects = n_subjects, n_time = n_time, S = S,
  X = matrix(rbinom(n_obs, 1, 0.5)), Z = matrix(rbinom(n_obs, 1, 0.5)),
  alpha = c(-0.3, 0.5), beta = c(0.2, -0.4),
  sigma_alpha = 0.4, sigma_beta = 0.3, phi = 15, seed = 3
)

fit_counts <- fit_zibbmr(
  y = dat_counts$Y, S = dat_counts$TotalCounts, id = dat_counts$Subject,
  X = dat_counts$X.1, Z = dat_counts$Z.1,
  phi_start = 10, alpha_start = c(-0.2, 0.1), beta_start = c(0.1, 0.1),
  n_iter = 300, seed = 1, compute_fim = FALSE
)

# Los estimados quedan cerca de los valores verdaderos (-0.3, 0.5, 0.2, -0.4, 15)
print(fit_counts)
#> ===== Resultados SAEM-ZIBBMR =====
#> == Parte logistica: p_it ==
#>             Estimate   Type
#> Intercept -0.3119325 Random
#> X.1        0.5250844  Fixed
#> == Parte beta-binomial: u_it ==
#>             Estimate   Type
#> Intercept  0.2222640 Random
#> Z.1       -0.4338967  Fixed
#> === Varianzas de efectos aleatorios ===
#> == Parte logistica ==
#>            Variance  sqrt.Var
#> Intercept 0.1641159 0.4051122
#> == Parte beta-binomial ==
#>            Variance  sqrt.Var
#> Intercept 0.1287425 0.3588071
#> === Phi: 17.06495
#> === Log-verosimilitud marginal (importance sampling): -4543.009
```

## Ajuste por taxon y comparación de modelos anidados

``` r
sim <- simular_datos_microbioma(n_ind = 15, n_time = 4, n_taxa = 3, seed = 1)

full <- fit_zibr_taxon(
  data = sim$proporcion, taxon = "Taxon1", id = "id",
  covariates = c("tiempo", "grupo"), n_iter = 50, seed = 1
)
reduced <- fit_zibr_taxon(
  data = sim$proporcion, taxon = "Taxon1", id = "id",
  covariates = "tiempo", n_iter = 50, seed = 1
)

lrt_zibr(full, reduced, df = 1)
#>    LL_full LL_reduced      LRT df    p_value
#> 1 14.64046   12.90933 3.462264  1 0.06278431
```

## Más información

Ver `vignette("get-started", package = "saemMicrobiome")` para una
introducción más completa, incluyendo cuando usar ZIBR vs. ZIBBMR y como
preparar datos propios.
