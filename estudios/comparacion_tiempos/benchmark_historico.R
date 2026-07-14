## ===== Benchmark de las versiones HISTORICAS del paquete =====
## Mide los tiempos de v0 (sin optimizar) y Fase 1 (optimizacion en R puro),
## instalando cada commit en una libreria temporal y corriendo el ajuste en un
## proceso R SEPARADO (unica forma fiable: R no permite tener dos versiones del
## mismo paquete cargadas en una misma sesion).
##
## IMPORTANTE: ejecutar desde la RAIZ del repositorio (la carpeta que contiene
## el directorio .git). Requiere git y un compilador de C++/R.
##   setwd("ruta/al/repo"); source("estudios/comparacion_tiempos/benchmark_historico.R")

if (!dir.exists(".git")) {
  stop("Ejecuta este script desde la raiz del repositorio (no se encontro .git). ",
       "Usa setwd() para ir a la carpeta del repo antes de correrlo.", call. = FALSE)
}

## --- 1. Dataset comun, guardado a un RDS temporal ---
suppressMessages(library(saemMicrobiome))
set.seed(20260712)
n_sub <- 150; n_time <- 4; n_obs <- n_sub * n_time
grupo <- rbinom(n_obs, 1, 0.5)
datos <- simulate_zibr_data(
  n_subjects = n_sub, n_time = n_time,
  X = matrix(grupo, ncol = 1), Z = matrix(grupo, ncol = 1),
  alpha = c(-0.3, 0.5), beta = c(0.2, -0.4),
  sigma_alpha = 0.4, sigma_beta = 0.3, phi = 15, seed = NULL)
bench_data <- list(Y = datos$Y, X = matrix(datos$X.1, ncol = 1),
                   Z = matrix(datos$Z.1, ncol = 1), id = datos$Subject)
data_file <- tempfile(fileext = ".rds"); saveRDS(bench_data, data_file)

## --- 2. Script "worker": se ejecuta en un proceso R fresco ---
worker <- tempfile(fileext = ".R")
writeLines(sprintf('
  lib <- commandArgs(trailingOnly = TRUE)[1]
  .libPaths(c(lib, .libPaths()))
  suppressMessages(library(saemMicrobiome, lib.loc = lib))
  d <- readRDS("%s")
  f <- function() fit_zibr(y = d$Y, id = d$id, X = d$X, Z = d$Z, phi_start = 10,
        alpha_start = c(-0.2, 0.1), beta_start = c(0.1, 0.1),
        n_iter = 300, n_chains = 5, seed = 232, compute_fim = FALSE)
  fit <- f()
  ts <- replicate(5, system.time(f())["elapsed"])
  cat(sprintf("TIME=%%.4f MU=%%s PHI=%%.8f LL=%%.6f\\n",
      median(ts), paste(sprintf("%%.8f", fit$mu), collapse = ","), fit$phi, fit$loglik))
', data_file), worker)

## --- 3. Medir un commit (en proceso separado, con chequeos que fallan ruidoso) ---
medir_commit <- function(hash) {
  wt <- tempfile("wt_"); lib <- tempfile("lib_"); dir.create(lib)
  on.exit(suppressWarnings(system2("git", c("worktree", "remove", "--force", wt),
                                   stdout = FALSE, stderr = FALSE)), add = TRUE)
  if (system2("git", c("worktree", "add", "-f", wt, hash), stdout = FALSE, stderr = FALSE) != 0)
    stop("git worktree fallo para ", hash, call. = FALSE)
  if (system2("R", c("CMD", "INSTALL", "-l", lib, wt), stdout = FALSE, stderr = FALSE) != 0)
    stop("R CMD INSTALL fallo para ", hash, call. = FALSE)
  if (!dir.exists(file.path(lib, "saemMicrobiome")))
    stop("el paquete no quedo instalado en la libreria temporal para ", hash, call. = FALSE)
  out <- system2("Rscript", c(worker, lib), stdout = TRUE, stderr = FALSE)
  linea <- grep("^TIME=", out, value = TRUE)
  if (length(linea) != 1) stop("el proceso de medicion no devolvio un tiempo para ", hash, call. = FALSE)
  as.numeric(sub("TIME=([0-9.]+).*", "\\1", linea))
}

## --- 4. Ejecutar ---
cat("Midiendo v0 (77a00b4, sin optimizar) ... puede tardar unos minutos\n")
t_v0 <- medir_commit("77a00b4")
cat("Midiendo Fase 1 (9b9e368, optimizacion en R puro) ...\n")
t_f1 <- medir_commit("9b9e368")

cat("\n===== TIEMPOS HISTORICOS (mediana, segundos) =====\n")
cat(sprintf("  v0 - sin optimizar : %.2f s\n", t_v0))
cat(sprintf("  Fase 1 - R puro    : %.2f s\n", t_f1))
