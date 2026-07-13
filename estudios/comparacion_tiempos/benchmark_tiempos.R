## ===== Benchmark: John vs paquete saemMicrobiome, mismos datos =====
## Verifica que estiman lo mismo y compara tiempos de computo.
## La tabla completa (incluyendo las versiones historicas del paquete) esta en
## RESULTADOS.md. Este script reproduce de forma directa la comparacion
## John vs version ACTUAL; para las versiones historicas ver la seccion
## opcional al final.

library(saemMicrobiome)

## --- 1. Datos comunes (150 sujetos x 4 tiempos) ---
set.seed(20260712)
n_sub <- 150; n_time <- 4; n_obs <- n_sub * n_time
grupo <- rbinom(n_obs, 1, 0.5)
datos <- simulate_zibr_data(
  n_subjects = n_sub, n_time = n_time,
  X = matrix(grupo, ncol = 1), Z = matrix(grupo, ncol = 1),
  alpha = c(-0.3, 0.5), beta = c(0.2, -0.4),
  sigma_alpha = 0.4, sigma_beta = 0.3, phi = 15, seed = NULL)
Y <- datos$Y; X <- matrix(datos$X.1, ncol = 1)
Z <- matrix(datos$Z.1, ncol = 1); index <- datos$Subject

med_tiempo <- function(f, nrep = 5) median(replicate(nrep, system.time(f())["elapsed"]))

## --- 2. Version ACTUAL del paquete ---
fit_actual <- function()
  fit_zibr(y = Y, id = index, X = X, Z = Z,
           phi_start = 10, alpha_start = c(-0.2, 0.1), beta_start = c(0.1, 0.1),
           n_iter = 300, n_chains = 5, seed = 232, compute_fim = FALSE)
f_act <- fit_actual()
t_actual <- med_tiempo(fit_actual)

## --- 3. Codigo ORIGINAL de John (descargado de su GitHub) ---
source("https://raw.githubusercontent.com/jbarrera232/saem-zibr/main/saem-estimation.R")
fit_john <- function()
  saem_zibr(Y = Y, X = X, Z = Z, index = index, zi = TRUE,
            v0 = 10, a0 = c(-0.2, 0.1), b0 = c(0.1, 0.1),
            seed = 232, iter = 300, ncad = 5)
f_john <- fit_john()
t_john <- med_tiempo(fit_john, 3)

## --- 4. Comparacion ---
cat("\n===== ESTIMACION (deben coincidir) =====\n")
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
## OPCIONAL: reproducir las versiones historicas del paquete.
## Requiere git y compilador. Se instala cada commit en una libreria temporal
## y se mide igual. Commits:
##   v0 (sin optimizar)      : 77a00b4
##   Fase 1 (optimizacion R) : 9b9e368
## Descomentar para ejecutar (tarda varios minutos):
#
# medir_commit <- function(hash) {
#   wt  <- tempfile("wt_");  lib <- tempfile("lib_"); dir.create(lib)
#   system2("git", c("worktree", "add", "-f", wt, hash), stdout = FALSE, stderr = FALSE)
#   system2("R", c("CMD", "INSTALL", "-l", lib, wt), stdout = FALSE, stderr = FALSE)
#   on.exit({ system2("git", c("worktree", "remove", "--force", wt)) }, add = TRUE)
#   pkg <- asNamespace  # placeholder
#   .libPaths(c(lib, .libPaths()))
#   ns <- loadNamespace("saemMicrobiome", lib.loc = lib)
#   ff <- get("fit_zibr", envir = ns)
#   f  <- function() ff(y = Y, id = index, X = X, Z = Z, phi_start = 10,
#                       alpha_start = c(-0.2, 0.1), beta_start = c(0.1, 0.1),
#                       n_iter = 300, n_chains = 5, seed = 232, compute_fim = FALSE)
#   med_tiempo(f)
# }
# cat(sprintf("  v0 (77a00b4)    : %.2f s\n", medir_commit("77a00b4")))
# cat(sprintf("  Fase 1 (9b9e368): %.2f s\n", medir_commit("9b9e368")))
