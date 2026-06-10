ajustar_modelo_microbioma <- function(modelo = c("zibbmr", "zibr"),
                                      datos,
                                      taxon,
                                      id = "id",
                                      total = "N",
                                      covariables = c("tiempo", "grupo"),
                                      zi = TRUE,
                                      iter = 200,
                                      ncad = 5,
                                      seed = 1) {
  modelo <- match.arg(modelo)
  
  Y <- datos[[taxon]]
  index <- datos[[id]]
  
  X <- as.matrix(datos[, covariables, drop = FALSE])
  Z <- as.matrix(datos[, covariables, drop = FALSE])
  
  a0 <- rep(0.1, ncol(X) + 1)
  b0 <- rep(0.1, ncol(Z) + 1)
  
  a0[1] <- -0.2
  b0[1] <- -0.2
  
  v0 <- 10
  
  if (modelo == "zibr") {
    ajuste <- saem_zibr_clean(
      Y = Y,
      X = X,
      Z = Z,
      index = index,
      zi = zi,
      v0 = v0,
      a0 = a0,
      b0 = b0,
      iter = iter,
      ncad = ncad,
      seed = seed,
      compute_fim = FALSE
    )
  }
  
  if (modelo == "zibbmr") {
    ajuste <- saem_zibbmr_clean(
      Y = Y,
      S = datos[[total]],
      X = X,
      Z = Z,
      index = index,
      zi = zi,
      v0 = v0,
      a0 = a0,
      b0 = b0,
      iter = iter,
      ncad = ncad,
      seed = seed,
      compute_fim = FALSE
    )
  }
  
  ajuste
}