## ===== COMPARACION: codigo de John Barrera vs paquete saemMicrobiome =====
## Modelo ZIBR (proporciones). Ejemplo completo de John: 100 sujetos x 5 tiempos.
##
## Objetivo: verificar que el paquete reproduce EXACTAMENTE el resultado del
## codigo original de John, corriendo ambos sobre los mismos datos.

## 1. Codigo ORIGINAL de John (de su GitHub, sin modificar)
source("https://raw.githubusercontent.com/jbarrera232/saem-zibr/main/saem-estimation.R")

## 2. Tu paquete
library(saemMicrobiome)

## 3. Datos con los parametros del ejemplo completo de John
n_subjects <- 100; n_time <- 5
grupo <- c(rep(0, 50 * n_time), rep(1, 50 * n_time))

datos <- simulate_zibr_data(
  n_subjects = n_subjects, n_time = n_time,
  X = matrix(grupo, ncol = 1), Z = matrix(grupo, ncol = 1),
  alpha = c(-0.5, 0.5), beta = c(-0.5, 0.5),
  sigma_alpha = 0.43, sigma_beta = 0.76, phi = 17.2, seed = 332
)

Y <- datos$Y
X <- matrix(datos$X.1, ncol = 1)
Z <- matrix(datos$Z.1, ncol = 1)
index <- datos$Subject

## 4. Ajuste con el codigo ORIGINAL de John.
##    (argumentos con nombre: John agrego 'zi' en dic-2025 y su ejemplo
##     posicional comentado quedo desactualizado)
res_john <- saem_zibr(
  Y = Y, X = X, Z = Z, index = index, zi = TRUE,
  v0 = 15, a0 = c(-0.3, 0.5), b0 = c(-0.2, 0.8),
  seed = 232, iter = 500, ncad = 10
)

## 5. Ajuste con TU paquete (misma funcion historica, mismos argumentos)
res_gabriela <- saem_zibr_clean(
  Y = Y, X = X, Z = Z, index = index, zi = TRUE,
  v0 = 15, a0 = c(-0.3, 0.5), b0 = c(-0.2, 0.8),
  seed = 232, iter = 500, ncad = 10, compute_fim = FALSE
)

## 6. Comparacion
cat("\n============= COMPARACION ZIBR =============\n")
etiquetas <- c("alpha_int", "alpha_grp", "beta_int ", "beta_grp ")
for (i in seq_along(res_john$MU)) {
  cat(sprintf("%s  | John: %16.12f | Paquete: %16.12f\n",
              etiquetas[i], res_john$MU[i], res_gabriela$mu[i]))
}
cat(sprintf("phi        | John: %16.12f | Paquete: %16.12f\n", res_john$V, res_gabriela$phi))
cat(sprintf("loglik     | John: %16.12f | Paquete: %16.12f\n", res_john$loglik, res_gabriela$loglik))

max_dif <- max(abs(c(res_john$MU - res_gabriela$mu,
                     res_john$V - res_gabriela$phi,
                     res_john$loglik - res_gabriela$loglik)))
cat(sprintf("\nDiferencia maxima absoluta: %.2e\n", max_dif))
if (max_dif < 1e-8) cat(">>> IDENTICOS: el paquete reproduce exactamente el codigo de John <<<\n")
