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


#### Parte de inflacion de ceros: identica para ZIBR y ZIBBMR ####
#### (la probabilidad de presencia/ausencia no depende de si la parte ####
#### positiva es beta o beta-binomial) ####

.saem_neg_loglik_zero <- function(alpha_fixed, psi_chain, alpha_random,
                                  x_design_chain, id_chain, is_positive_chain,
                                  is_zero_chain, n_alpha) {
  fixed_index <- which(!alpha_random)
  n_rows <- nrow(psi_chain)

  psi_chain[, fixed_index] <- matrix(
    rep(alpha_fixed, each = n_rows),
    ncol = length(alpha_fixed),
    nrow = n_rows
  )

  p <- .saem_linear_prob(psi_chain, seq_len(n_alpha), id_chain, x_design_chain)
  loglik <- sum(log(1 - p[is_zero_chain])) + sum(log(p[is_positive_chain]))

  -loglik
}


#### Extraccion de log-verosimilitud y comparacion de modelos anidados (LRT) ####
#### Comun a ambos modelos: solo dependen de que el objeto tenga $loglik ####
#### o un metodo logLik() generico. ####

.saem_extract_loglik <- function(model) {
  if (inherits(model, c("zibr_saem", "zibbmr_saem"))) {
    return(model$loglik)
  }

  as.numeric(stats::logLik(model))
}

.saem_lrt <- function(full, reduced, df = 2) {
  ll_full <- .saem_extract_loglik(full)
  ll_reduced <- .saem_extract_loglik(reduced)
  statistic <- 2 * (ll_full - ll_reduced)

  data.frame(
    LL_full = ll_full,
    LL_reduced = ll_reduced,
    LRT = statistic,
    df = df,
    p_value = stats::pchisq(statistic, df = df, lower.tail = FALSE)
  )
}

.saem_lrt_table <- function(full_models, reduced_models, species, df, alpha, lrt_fn) {
  if (length(full_models) != length(reduced_models)) {
    stop("full_models y reduced_models deben tener la misma longitud.", call. = FALSE)
  }

  if (is.null(species) || length(species) == 0) {
    species <- seq_along(full_models)
  }

  out <- do.call(
    rbind,
    Map(function(full, reduced, sp) {
      res <- lrt_fn(full, reduced, df = df)
      data.frame(Species = sp, res, row.names = NULL)
    }, full_models, reduced_models, species)
  )

  out$Detected <- out$p_value < alpha
  rownames(out) <- NULL
  out
}

.saem_results_table <- function(species,
                                mod1_full, mod1_no_preg,
                                mod2_full, mod2_no_preg, mod2_no_inter,
                                df, alpha) {
  LL1.0 <- vapply(mod1_full, .saem_extract_loglik, numeric(1))
  LL1.1 <- vapply(mod1_no_preg, .saem_extract_loglik, numeric(1))
  LL2.0 <- vapply(mod2_full, .saem_extract_loglik, numeric(1))
  LL2.1 <- vapply(mod2_no_preg, .saem_extract_loglik, numeric(1))
  LL2.2 <- vapply(mod2_no_inter, .saem_extract_loglik, numeric(1))

  pval_Preg1 <- stats::pchisq(2 * (LL1.0 - LL1.1), df = df, lower.tail = FALSE)
  pval_Preg2 <- stats::pchisq(2 * (LL2.0 - LL2.1), df = df, lower.tail = FALSE)
  pval_Inter <- stats::pchisq(2 * (LL2.0 - LL2.2), df = df, lower.tail = FALSE)

  data.frame(
    Species = species,
    LL1.0 = LL1.0,
    LL1.1 = LL1.1,
    LL2.0 = LL2.0,
    LL2.1 = LL2.1,
    LL2.2 = LL2.2,
    pval_Preg1 = pval_Preg1,
    pval_Preg2 = pval_Preg2,
    pval_Inter = pval_Inter,
    Detec_Preg1 = pval_Preg1 < alpha,
    Detec_Preg2 = pval_Preg2 < alpha,
    Detec_Inter = pval_Inter < alpha,
    row.names = NULL
  )
}


#### Metodos S3: la mecanica de imprimir/graficar/extraer coeficientes es ####
#### identica para zibr_saem y zibbmr_saem; solo cambian etiquetas de texto ####

.saem_print <- function(x, model_label, beta_label) {
  cat("===== Resultados ", model_label, " =====\n", sep = "")

  if (x$zi) {
    alpha <- x$mu[seq_len(x$n_alpha)]
    alpha_tab <- data.frame(
      Estimate = alpha,
      Type = ifelse(x$alpha_random, "Random", "Fixed"),
      Variance = 0,
      sqrt.Var = 0,
      row.names = x$alpha_labels
    )

    n_alpha_random <- sum(x$alpha_random)
    if (n_alpha_random > 0) {
      alpha_tab[x$alpha_random, "Variance"] <- diag(x$G)[seq_len(n_alpha_random)]
      alpha_tab[, "sqrt.Var"] <- sqrt(alpha_tab[, "Variance"])
    }

    cat("== Parte logistica: p_it ==\n")
    print(alpha_tab[, c("Estimate", "Type")])
  } else {
    n_alpha_random <- 0
  }

  beta <- x$mu[x$n_alpha + seq_len(x$n_beta)]
  beta_tab <- data.frame(
    Estimate = beta,
    Type = ifelse(x$beta_random, "Random", "Fixed"),
    Variance = 0,
    sqrt.Var = 0,
    row.names = x$beta_labels
  )

  n_beta_random <- sum(x$beta_random)
  if (n_beta_random > 0) {
    beta_tab[x$beta_random, "Variance"] <- diag(x$G)[n_alpha_random + seq_len(n_beta_random)]
    beta_tab[, "sqrt.Var"] <- sqrt(beta_tab[, "Variance"])
  }

  cat("== ", beta_label, ": u_it ==\n", sep = "")
  print(beta_tab[, c("Estimate", "Type")])

  cat("=== Varianzas de efectos aleatorios ===\n")
  if (x$zi && n_alpha_random > 0) {
    cat("== Parte logistica ==\n")
    print(alpha_tab[x$alpha_random, c("Variance", "sqrt.Var"), drop = FALSE])
  }
  if (n_beta_random > 0) {
    cat("== ", beta_label, " ==\n", sep = "")
    print(beta_tab[x$beta_random, c("Variance", "sqrt.Var"), drop = FALSE])
  }

  cat("=== Phi: ", x$phi, "\n", sep = "")
  cat("=== Log-verosimilitud marginal (importance sampling): ", x$loglik, "\n", sep = "")

  invisible(x)
}

.saem_plot_trace <- function(x, ...) {
  trace <- x$trace
  n_iter <- nrow(trace)
  burn_in <- floor(0.75 * n_iter)
  n_panels <- ncol(trace)
  n_rows <- ceiling(n_panels / 3)

  old_par <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(old_par), add = TRUE)

  graphics::par(mfrow = c(n_rows, 3))
  for (j in seq_len(n_panels)) {
    graphics::plot(
      seq_len(n_iter),
      trace[, j],
      type = "l",
      xlab = "Iteracion",
      ylab = "Valor",
      main = colnames(trace)[j]
    )
    graphics::abline(v = burn_in, lty = 2)
  }

  invisible(x)
}

.saem_logLik <- function(object) {
  value <- object$loglik
  attr(value, "df") <- length(object$mu) + 1 + length(diag(object$G))
  attr(value, "nobs") <- object$nobs
  class(value) <- "logLik"
  value
}

.saem_coef <- function(object) {
  object$mu
}

.saem_vcov <- function(object) {
  if (is.null(object$fisher_stoch)) {
    stop("El ajuste no contiene matriz FIM. Reajusta con compute_fim = TRUE.", call. = FALSE)
  }

  -solve(object$fisher_stoch)
}

.saem_se <- function(object) {
  sqrt(diag(.saem_vcov(object)))
}
