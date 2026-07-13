## ===== COMPARACION: codigo de John Barrera vs paquete saemMicrobiome =====
## Modelo ZIBBMR (conteos con profundidad de secuenciacion): 100 sujetos x 5 tiempos.

## 1. Codigo ORIGINAL de John, descargado de su GitHub.
##    Nota: el archivo de John para ZIBBMR tiene un parentesis sobrante (un
##    error de tipeo suyo) que impide hacer source() directo, y un bloque de
##    ejemplos al final con una funcion mal escrita. Aqui se descarga el
##    archivo y se corrigen esos dos detalles automaticamente ANTES de cargarlo,
##    sin tocar nada de la logica del metodo.
url_john <- "https://raw.githubusercontent.com/jbarrera232/saem-zibbmr/main/saem_zibbmr.R"
lineas <- readLines(url_john)
i <- grep("FIM\\.stoch=Hk\\)", lineas)              # parentesis sobrante
if (length(i) == 1 && trimws(lineas[i + 1]) == ")") lineas <- lineas[-(i + 1)]
j <- grep("^## Examples", lineas)                    # bloque de ejemplos roto
if (length(j) >= 1) lineas <- lineas[seq_len(j[1] - 1)]
tmp <- tempfile(fileext = ".R"); writeLines(lineas, tmp); source(tmp)

## 2. Paquete saemMicrobiome
library(saemMicrobiome)

## 3. Datos con parametros del ejemplo de John (alpha, beta, s1, s2, v)
n_subjects <- 100; n_time <- 5
n_obs <- n_subjects * n_time
grupo <- c(rep(0, 50 * n_time), rep(1, 50 * n_time))
S <- rep(1000, n_obs)   # profundidad de secuenciacion (total de lecturas)

datos <- simulate_zibbmr_data(
  n_subjects = n_subjects, n_time = n_time, S = S,
  X = matrix(grupo, ncol = 1), Z = matrix(grupo, ncol = 1),
  alpha = c(-0.5, 0.5), beta = c(-0.5, 0.5),
  sigma_alpha = 0.43, sigma_beta = 0.76, phi = 17.2, seed = 332
)

Y <- datos$Y
S <- datos$TotalCounts
X <- matrix(datos$X.1, ncol = 1)
Z <- matrix(datos$Z.1, ncol = 1)
index <- datos$Subject

## 4. Ajuste con el codigo ORIGINAL de John
res_john <- saem_zibbmr(
  Y = Y, X = X, Z = Z, S = S, index = index, zi = TRUE,
  v0 = 15, a0 = c(-0.3, 0.5), b0 = c(-0.2, 0.8),
  seed = 232, iter = 500, ncad = 10
)

## 5. Ajuste con el paquete saemMicrobiome (misma funcion, mismos argumentos)
res_gabriela <- saem_zibbmr_clean(
  Y = Y, X = X, Z = Z, S = S, index = index, zi = TRUE,
  v0 = 15, a0 = c(-0.3, 0.5), b0 = c(-0.2, 0.8),
  seed = 232, iter = 500, ncad = 10, compute_fim = FALSE
)

## 6. Comparacion
cat("\n============= COMPARACION ZIBBMR =============\n")
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
