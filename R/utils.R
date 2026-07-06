#### Utilidades internas compartidas por ZIBR y ZIBBMR ####
#### Estas funciones no dependen de la verosimilitud de cada modelo: ####
#### construccion de matrices de diseno, predictor lineal logistico, ####
#### replicacion de cadenas MCMC y verificacion de paquetes requeridos. ####

.saem_check_packages <- function(inference = TRUE) {
  required <- "MASS"
  if (inference) {
    required <- c(required, "numDeriv")
  }

  missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]

  if (length(missing) > 0) {
    stop(
      "Faltan paquetes requeridos: ",
      paste(missing, collapse = ", "),
      ". Instala antes de ajustar el modelo.",
      call. = FALSE
    )
  }
}

.saem_diag <- function(x) {
  if (length(x) == 1) {
    matrix(x, nrow = 1, ncol = 1)
  } else {
    diag(x)
  }
}

.saem_diag_inverse <- function(G) {
  .saem_diag(.saem_diag(G)^-1)
}

.saem_covariate_matrix <- function(x, n, prefix) {
  if (is.null(x)) {
    mat <- matrix(nrow = n, ncol = 0)
  } else {
    mat <- as.matrix(x)
    if (nrow(mat) != n) {
      stop("La matriz de covariables no tiene el mismo numero de filas que Y.", call. = FALSE)
    }
  }

  if (ncol(mat) == 0) {
    out <- matrix(1, nrow = n, ncol = 1)
    colnames(out) <- "Intercept"
    return(out)
  }

  if (is.null(colnames(mat))) {
    colnames(mat) <- paste(prefix, seq_len(ncol(mat)), sep = ".")
  }

  cbind(Intercept = 1, mat)
}

.saem_replicate_design <- function(design, n_chains) {
  do.call("rbind", replicate(n_chains, design, simplify = FALSE))
}

.saem_linear_prob <- function(psi, cols, id, design) {
  psi_obs <- psi[id, cols, drop = FALSE]

  if (length(cols) == 1) {
    eta <- psi_obs[, 1] * design[, 1]
  } else {
    eta <- rowSums(psi_obs * design)
  }

  plogis(eta)
}
