## ===== Benchmark ZIBBMR: John vs paquete saemMicrobiome, mismos datos =====
## Verifica que estiman lo mismo y compara tiempos de computo (modelo de
## conteos, beta-binomial). La tabla completa (incluyendo las versiones
## historicas del paquete) esta en RESULTADOS.md. Este script reproduce la
## comparacion John vs version ACTUAL; para las versiones historicas ver el
## script aparte `benchmark_historico_zibbmr.R`.

library(saemMicrobiome)

## --- 1. Datos comunes (150 sujetos x 4 tiempos, profundidad S = 1000) ---
set.seed(20260712)
n_sub <- 150; n_time <- 4; n_obs <- n_sub * n_time
grupo <- rbinom(n_obs, 1, 0.5)
S <- rep(1000, n_obs)
datos <- simulate_zibbmr_data(
  n_subjects = n_sub, n_time = n_time, S = S,
  X = matrix(grupo, ncol = 1), Z = matrix(grupo, ncol = 1),
  alpha = c(-0.3, 0.5), beta = c(0.2, -0.4),
  sigma_alpha = 0.4, sigma_beta = 0.3, phi = 15, seed = NULL)
Y <- datos$Y; S <- datos$TotalCounts; X <- matrix(datos$X.1, ncol = 1)
Z <- matrix(datos$Z.1, ncol = 1); index <- datos$Subject

med_tiempo <- function(f, nrep = 5) median(replicate(nrep, system.time(f())["elapsed"]))

## --- 2. Version ACTUAL del paquete ---
fit_actual <- function()
  fit_zibbmr(y = Y, S = S, id = index, X = X, Z = Z,
             phi_start = 10, alpha_start = c(-0.2, 0.1), beta_start = c(0.1, 0.1),
             n_iter = 300, n_chains = 5, seed = 232, compute_fim = FALSE)
f_act <- fit_actual()
t_actual <- med_tiempo(fit_actual)

## --- 3. Codigo ORIGINAL de John (descargado y corregido automaticamente) ---
##    El archivo de John para ZIBBMR tiene un parentesis sobrante y un bloque de
##    ejemplos roto al final; se corrigen al descargarlo, sin tocar la logica.
url_john <- "https://raw.githubusercontent.com/jbarrera232/saem-zibbmr/main/saem_zibbmr.R"
lineas <- readLines(url_john)
i <- grep("FIM\\.stoch=Hk\\)", lineas)
if (length(i) == 1 && trimws(lineas[i + 1]) == ")") lineas <- lineas[-(i + 1)]
j <- grep("^## Examples", lineas)
if (length(j) >= 1) lineas <- lineas[seq_len(j[1] - 1)]
tmp <- tempfile(fileext = ".R"); writeLines(lineas, tmp); source(tmp)

fit_john <- function()
  saem_zibbmr(Y = Y, X = X, Z = Z, S = S, index = index, zi = TRUE,
              v0 = 10, a0 = c(-0.2, 0.1), b0 = c(0.1, 0.1),
              seed = 232, iter = 300, ncad = 5)
f_john <- fit_john()
t_john <- med_tiempo(fit_john, 3)

## --- 4. Comparacion ---
cat("\n===== ESTIMACION ZIBBMR (deben coincidir) =====\n")
comp <- rbind(John = c(f_john$MU, f_john$V, f_john$loglik),
              Actual = c(f_act$mu, f_act$phi, f_act$loglik))
colnames(comp) <- c("alpha_int","alpha_grp","beta_int","beta_grp","phi","loglik")
print(round(comp, 8))
cat("\nDiferencia maxima John vs actual:",
    format(max(abs(comp[1,] - comp[2,])), scientific = TRUE), "\n")

cat("\n===== TIEMPOS (mediana, segundos) =====\n")
cat(sprintf("  John (original) : %.2f s\n", t_john))
cat(sprintf("  Paquete actual  : %.2f s\n", t_actual))

## ---------------------------------------------------------------------------
## Versiones HISTORICAS del paquete (v0 sin optimizar, Fase 1 en R puro):
## ver el script aparte `benchmark_historico_zibbmr.R`. Hay que medirlas en
## procesos R separados (R no permite tener dos versiones del mismo paquete
## cargadas en una sesion). Ejecutarlo desde la raiz del repositorio:
##   setwd("ruta/al/repo")
##   source("estudios/comparacion_tiempos/benchmark_historico_zibbmr.R")
