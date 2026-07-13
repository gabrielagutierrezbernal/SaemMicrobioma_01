## ===== ESTUDIO DE SIMULACION - modelo ZIBBMR =====
## Analogo al de ZIBR, pero para el modelo de conteos (beta-binomial). Repite el
## ajuste sobre muchos datasets simulados, para distintos tamanos de muestra, y
## muestra que al aumentar el numero de sujetos el PROMEDIO de los estimados se
## acerca al valor verdadero y su DISPERSION (error) se achica.
## Genera un grafico de cajas: estudio_simulacion_zibbmr.png
library(saemMicrobiome)

## --- Valores verdaderos con los que se generan los datos ---
true_alpha <- c(-0.3, 0.5); true_beta <- c(0.2, -0.4)
true_sigma_alpha <- 0.4; true_sigma_beta <- 0.3; true_phi <- 15
n_time <- 4
S_depth <- 1000   # profundidad de secuenciacion (total de lecturas por muestra)

sample_sizes <- c(30, 100, 300)   # tamanos de muestra a comparar
n_rep <- 30                        # repeticiones (datasets) por tamano
## (para una prueba rapida, baja n_rep a 10; para promedios mas estables, subelo a 100)

verdadero <- c(alpha_int=-0.3, alpha_grp=0.5, beta_int=0.2, beta_grp=-0.4, phi=15)
etiquetas <- c("alpha (intercepto)", "alpha (grupo)",
               "beta (intercepto)", "beta (grupo)", "phi")

resultados <- list()
for (n_sub in sample_sizes) {
  n_obs <- n_sub * n_time
  ests <- matrix(NA_real_, nrow=n_rep, ncol=5, dimnames=list(NULL, names(verdadero)))
  for (r in seq_len(n_rep)) {
    set.seed(1000 * n_sub + r)                 # semilla distinta por dataset
    grupo <- rbinom(n_obs, 1, 0.5)
    S <- rep(S_depth, n_obs)
    dat <- simulate_zibbmr_data(
      n_subjects=n_sub, n_time=n_time, S=S,
      X=matrix(grupo, ncol=1), Z=matrix(grupo, ncol=1),
      alpha=true_alpha, beta=true_beta,
      sigma_alpha=true_sigma_alpha, sigma_beta=true_sigma_beta,
      phi=true_phi, seed=NULL)
    fit <- tryCatch(
      fit_zibbmr(y=dat$Y, S=dat$TotalCounts, id=dat$Subject, X=dat$X.1, Z=dat$Z.1,
                 phi_start=10, alpha_start=c(-0.2,0.1), beta_start=c(0.1,0.1),
                 n_iter=200, seed=1, compute_fim=FALSE),
      error=function(e) NULL)
    if (!is.null(fit)) ests[r, ] <- c(fit$mu, fit$phi)
  }
  resultados[[as.character(n_sub)]] <- ests
  cat("Terminado n =", n_sub, "\n")
}

## --- Resumen 1: PROMEDIO de los estimados ---
cat("\n===== PROMEDIO de los estimados (ZIBBMR) =====\n")
cat(sprintf("%-11s", "n_sujetos"), sprintf("%10s", names(verdadero)), "\n")
cat(sprintf("%-11s", "VERDADERO"), sprintf("%10.3f", verdadero), "\n")
for (n_sub in sample_sizes)
  cat(sprintf("%-11d", n_sub), sprintf("%10.3f", colMeans(resultados[[as.character(n_sub)]], na.rm=TRUE)), "\n")

## --- Resumen 2: DESVIACION ESTANDAR ---
cat("\n===== DESVIACION ESTANDAR de los estimados (ZIBBMR) =====\n")
cat(sprintf("%-11s", "n_sujetos"), sprintf("%10s", names(verdadero)), "\n")
for (n_sub in sample_sizes)
  cat(sprintf("%-11d", n_sub), sprintf("%10.3f", apply(resultados[[as.character(n_sub)]], 2, sd, na.rm=TRUE)), "\n")

## --- Grafico (se guarda como PNG en la carpeta de trabajo) ---
## Para verlo en pantalla en RStudio en vez de guardarlo, omite las lineas
## png(...) y dev.off().
png("estudio_simulacion_zibbmr.png", width = 1100, height = 700, res = 110)
op <- par(mfrow = c(2, 3), mar = c(4, 4, 3, 1))
for (j in seq_len(5)) {
  datos_j <- lapply(sample_sizes, function(n) resultados[[as.character(n)]][, j])
  names(datos_j) <- paste0("n=", sample_sizes)
  boxplot(datos_j, main = etiquetas[j], ylab = "Estimado",
          col = c("#f4a582", "#92c5de", "#4393c3"), border = "gray30")
  abline(h = verdadero[j], col = "red", lwd = 2, lty = 2)
}
plot.new()
legend("center", legend = c("Valor verdadero", "n = 30", "n = 100", "n = 300"),
       col = c("red", "#f4a582", "#92c5de", "#4393c3"),
       lty = c(2, NA, NA, NA), lwd = c(2, NA, NA, NA),
       pch = c(NA, 15, 15, 15), pt.cex = 2, bty = "n", cex = 1.1)
par(op)
dev.off()
cat("\nGrafico guardado en: estudio_simulacion_zibbmr.png\n")
