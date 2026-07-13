## ===== CHEQUEO DE SENSIBILIDAD A LA SEMILLA - modelo ZIBBMR =====
## SAEM es estocastico: el resultado depende de la semilla del ajuste.
## Este script toma UN dataset fijo y lo ajusta con muchas semillas distintas,
## para medir cuanto varia el resultado por el azar del algoritmo (ruido de
## Monte Carlo) y mostrar que ese ruido se reduce usando mas cadenas MCMC.
library(saemMicrobiome)

## --- Un dataset fijo (100 sujetos) ---
set.seed(1)
n_subjects <- 100; n_time <- 4; n_obs <- n_subjects * n_time
S <- rep(1000, n_obs)
verdadero <- c(alpha_int=-0.3, alpha_grp=0.5, beta_int=0.2, beta_grp=-0.4, phi=15)
dat <- simulate_zibbmr_data(
  n_subjects=n_subjects, n_time=n_time, S=S,
  X=matrix(rbinom(n_obs,1,0.5)), Z=matrix(rbinom(n_obs,1,0.5)),
  alpha=c(-0.3,0.5), beta=c(0.2,-0.4),
  sigma_alpha=0.4, sigma_beta=0.3, phi=15, seed=1)

## --- Ajustar el MISMO dataset con muchas semillas ---
semillas <- 1:20
ajustar_con_semillas <- function(n_chains) {
  t(sapply(semillas, function(s)
    fit_zibbmr(y=dat$Y, S=dat$TotalCounts, id=dat$Subject, X=dat$X.1, Z=dat$Z.1,
               phi_start=10, alpha_start=c(-0.2,0.1), beta_start=c(0.1,0.1),
               n_iter=200, n_chains=n_chains, seed=s, compute_fim=FALSE)[c("mu","phi")] |>
      (\(x) c(x$mu, x$phi))()))
}

cat("Ajustando con", length(semillas), "semillas y n_chains = 5 ...\n")
est5  <- ajustar_con_semillas(5)
cat("Ajustando con", length(semillas), "semillas y n_chains = 15 ...\n")
est15 <- ajustar_con_semillas(15)
colnames(est5) <- colnames(est15) <- names(verdadero)

## --- Resumen: desviacion estandar entre semillas (ruido de Monte Carlo) ---
cat("\n===== DESVIACION ESTANDAR entre semillas (ruido del algoritmo) =====\n")
cat(sprintf("%-14s", "n_chains"), sprintf("%10s", names(verdadero)), "\n")
cat(sprintf("%-14s", "5 cadenas"),  sprintf("%10.4f", apply(est5, 2, sd)), "\n")
cat(sprintf("%-14s", "15 cadenas"), sprintf("%10.4f", apply(est15, 2, sd)), "\n")
cat("\n(con mas cadenas MCMC el resultado depende menos de la semilla)\n")

## --- Grafico: dispersion de los estimados entre semillas ---
png("chequeo_semilla_zibbmr.png", width = 1100, height = 700, res = 110)
op <- par(mfrow = c(2, 3), mar = c(4, 4, 3, 1))
etiquetas <- c("alpha (intercepto)", "alpha (grupo)", "beta (intercepto)", "beta (grupo)", "phi")
for (j in seq_len(5)) {
  boxplot(list("5 cad." = est5[, j], "15 cad." = est15[, j]),
          main = etiquetas[j], ylab = "Estimado",
          col = c("#fddbc7", "#d1e5f0"), border = "gray30")
  abline(h = verdadero[j], col = "red", lwd = 2, lty = 2)
}
plot.new()
legend("center",
       legend = c("Valor verdadero", "5 cadenas", "15 cadenas"),
       col = c("red", "#fddbc7", "#d1e5f0"),
       lty = c(2, NA, NA), lwd = c(2, NA, NA), pch = c(NA, 15, 15),
       pt.cex = 2, bty = "n", cex = 1.1)
par(op)
dev.off()
cat("\nGrafico guardado en: chequeo_semilla_zibbmr.png\n")
