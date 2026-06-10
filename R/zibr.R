#### Implementacion limpia de SAEM-ZIBR ####
#### Base para desarrollo posterior de paquete R ####

#### Utilidades internas ####

.zibr_check_packages <- function(inference = TRUE) {
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

.zibr_diag <- function(x) {
  if (length(x) == 1) {
    matrix(x, nrow = 1, ncol = 1)
  } else {
    diag(x)
  }
}

.zibr_diag_inverse <- function(G) {
  .zibr_diag(.zibr_diag(G)^-1)
}

.zibr_covariate_matrix <- function(x, n, prefix) {
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

.zibr_replicate_design <- function(design, n_chains) {
  do.call("rbind", replicate(n_chains, design, simplify = FALSE))
}

.zibr_linear_prob <- function(psi, cols, id, design) {
  psi_obs <- psi[id, cols, drop = FALSE]

  if (length(cols) == 1) {
    eta <- psi_obs[, 1] * design[, 1]
  } else {
    eta <- rowSums(psi_obs * design)
  }

  plogis(eta)
}

.zibr_validate_y <- function(y, zi, eps = 1e-6) {
  y <- as.numeric(y)

  if (any(!is.finite(y))) {
    stop("Y contiene valores no finitos.", call. = FALSE)
  }
  if (any(y < 0 | y > 1)) {
    stop("ZIBR requiere proporciones en el intervalo [0, 1].", call. = FALSE)
  }
  if (any(y == 1)) {
    warning("Y contiene valores exactamente 1; se reemplazan por 1 - eps para evitar log(0).", call. = FALSE)
    y[y == 1] <- 1 - eps
  }
  if (!zi) {
    y[y == 0] <- eps
  }

  y
}


#### Log-verosimilitudes condicionales usadas en el paso M ####

.zibr_neg_loglik_zero <- function(alpha_fixed, psi_chain, alpha_random,
                                  x_design_chain, id_chain, is_positive_chain,
                                  is_zero_chain, n_alpha) {
  fixed_index <- which(!alpha_random)
  n_rows <- nrow(psi_chain)

  psi_chain[, fixed_index] <- matrix(
    rep(alpha_fixed, each = n_rows),
    ncol = length(alpha_fixed),
    nrow = n_rows
  )

  p <- .zibr_linear_prob(psi_chain, seq_len(n_alpha), id_chain, x_design_chain)
  loglik <- sum(log(1 - p[is_zero_chain])) + sum(log(p[is_positive_chain]))

  -loglik
}

.zibr_neg_loglik_beta <- function(par, psi_chain, beta_random,
                                  z_design_chain, id_chain,
                                  is_positive_chain, y_chain,
                                  n_alpha, n_beta, n_beta_random) {
  phi <- par[length(par)]
  n_rows <- nrow(psi_chain)

  if (n_beta_random != n_beta) {
    beta_fixed <- par[-length(par)]
    fixed_index <- which(!beta_random)

    psi_chain[, n_alpha + fixed_index] <- matrix(
      rep(beta_fixed, each = n_rows),
      ncol = length(beta_fixed),
      nrow = n_rows
    )
  }

  u <- .zibr_linear_prob(
    psi_chain,
    n_alpha + seq_len(n_beta),
    id_chain,
    z_design_chain
  )

  loglik <- sum(
    lgamma(phi) -
      lgamma(phi * u[is_positive_chain]) -
      lgamma((1 - u[is_positive_chain]) * phi) +
      phi * u[is_positive_chain] * log(y_chain[is_positive_chain]) +
      phi * (1 - u[is_positive_chain]) * log(1 - y_chain[is_positive_chain])
  )

  -loglik
}


#### Importance sampling para log-verosimilitud marginal ####

.zibr_loglik_importance <- function(mu, G, phi, zi, y, id,
                                    x_design, z_design, n_alpha, n_beta,
                                    is_positive, is_zero,
                                    psi_mean, psi_var, random_index,
                                    n_random, n_samples = 500, seed = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
  }

  G_inv <- .zibr_diag_inverse(G)
  G_det <- prod(diag(G))

  psi_array <- array(rep(psi_mean, n_samples), dim = c(dim(psi_mean), n_samples))
  sd_array <- array(rep(sqrt(psi_var), n_samples), dim = dim(psi_array))
  t_draws <- array(rt(prod(dim(psi_array)), df = 5), dim = dim(psi_array))
  psi_draws <- psi_array + sd_array * t_draws

  u_draws <- apply(
    psi_draws,
    3,
    .zibr_linear_prob,
    cols = n_alpha + seq_len(n_beta),
    id = id,
    design = z_design
  )

  if (zi) {
    p_draws <- apply(
      psi_draws,
      3,
      .zibr_linear_prob,
      cols = seq_len(n_alpha),
      id = id,
      design = x_design
    )
  } else {
    p_draws <- u_draws / u_draws
  }

  log_y_given_psi <- matrix(0, nrow = length(id), ncol = n_samples)

  if (zi) {
    log_y_given_psi[is_zero, ] <- log(1 - p_draws[is_zero, ])
  }

  log_y_given_psi[is_positive, ] <-
    log(p_draws[is_positive, ]) +
    log(y[is_positive]) * (phi * u_draws[is_positive, ] - 1) +
    log(1 - y[is_positive]) * (phi * (1 - u_draws[is_positive, ]) - 1) -
    lbeta(phi * u_draws[is_positive, ], phi * (1 - u_draws[is_positive, ]))

  P1 <- apply(log_y_given_psi, 2, function(x) tapply(x, id, sum))

  mu_random <- matrix(rep(mu[random_index], n_samples), nrow = n_random, ncol = n_samples)
  random_draws <- array(
    psi_draws[, random_index, ],
    dim = c(nrow(psi_mean), n_random, n_samples)
  )

  P2 <- apply(random_draws, 1, function(x) {
    -0.5 * (
      diag(t(x - mu_random) %*% G_inv %*% (x - mu_random)) +
        log(G_det) +
        n_random * log(2 * pi)
    )
  })

  log_proposal_terms <-
    dt(
      array(t_draws[, random_index, ], dim = c(nrow(psi_mean), n_random, n_samples)),
      df = 5,
      log = TRUE
    ) -
    log(array(sd_array[, random_index, ], dim = c(nrow(psi_mean), n_random, n_samples)))

  P3 <- apply(log_proposal_terms, 3, rowSums)

  log_weights <- P1 + t(P2) - P3
  sum(log(rowMeans(exp(log_weights))))
}


#### Gradiente y Hessiano de la log-verosimilitud completa ####

.zibr_complete_grad <- function(mu, G, phi, zi, psi_chain,
                                random_index, alpha_random, beta_random,
                                n_random, x_design_chain = NULL, id_chain,
                                is_positive_chain, is_zero_chain,
                                n_alpha, n_beta, z_design_chain,
                                y_chain, n_alpha_random, n_beta_random) {
  G_diag <- .zibr_diag(G)
  n_rows <- nrow(psi_chain)

  if (zi) {
    alpha <- mu[seq_len(n_alpha)]
  }
  beta <- mu[n_alpha + seq_len(n_beta)]

  psi_random <- as.matrix(psi_chain[, random_index, drop = FALSE])
  psi_sum <- colSums(psi_random)
  psi_sum2 <- colSums(psi_random^2)

  mu_grad <- rep(0, length(mu))
  mu_grad[random_index] <- (psi_sum - n_rows * mu[random_index]) / G_diag

  G_grad <- 0.5 * (
    (psi_sum2 - 2 * mu[random_index] * psi_sum + n_rows * mu[random_index]^2) /
      G_diag^2 -
      n_rows / G_diag
  )

  alpha_grad <- NULL

  if (zi && n_alpha_random != n_alpha) {
    alpha_grad <- -numDeriv::grad(
      .zibr_neg_loglik_zero,
      alpha[!alpha_random],
      psi_chain = psi_chain,
      alpha_random = alpha_random,
      x_design_chain = x_design_chain,
      id_chain = id_chain,
      is_positive_chain = is_positive_chain,
      is_zero_chain = is_zero_chain,
      n_alpha = n_alpha
    )
  }

  if (n_beta_random != n_beta) {
    beta_phi_par <- c(beta[!beta_random], phi)
  } else {
    beta_phi_par <- phi
  }

  beta_phi_grad <- -numDeriv::grad(
    .zibr_neg_loglik_beta,
    beta_phi_par,
    psi_chain = psi_chain,
    beta_random = beta_random,
    z_design_chain = z_design_chain,
    id_chain = id_chain,
    is_positive_chain = is_positive_chain,
    y_chain = y_chain,
    n_alpha = n_alpha,
    n_beta = n_beta,
    n_beta_random = n_beta_random
  )

  phi_grad <- beta_phi_grad[length(beta_phi_par)]

  if (n_beta_random != n_beta) {
    beta_grad <- beta_phi_grad[-length(beta_phi_par)]
  } else {
    beta_grad <- NULL
  }

  if (n_random != length(mu)) {
    mu_grad[-random_index] <- c(alpha_grad, beta_grad)
  }

  c(mu_grad, phi_grad, G_grad)
}

.zibr_complete_hess <- function(mu, G, phi, zi, psi_chain,
                                random_index, alpha_random, beta_random,
                                n_random, x_design_chain = NULL, id_chain,
                                is_positive_chain, is_zero_chain,
                                n_alpha, n_beta, z_design_chain,
                                y_chain, n_alpha_random, n_beta_random) {
  G_diag <- .zibr_diag(G)
  n_rows <- nrow(psi_chain)

  if (zi) {
    alpha <- mu[seq_len(n_alpha)]
  }
  beta <- mu[n_alpha + seq_len(n_beta)]

  psi_random <- as.matrix(psi_chain[, random_index, drop = FALSE])
  psi_sum <- colSums(psi_random)
  psi_sum2 <- colSums(psi_random^2)

  n_hess <- n_alpha + n_beta + n_random + 1
  H <- matrix(0, nrow = n_hess, ncol = n_hess)

  diag(H)[random_index] <- -n_rows / G_diag

  variance_index <- (n_hess - n_random + 1):n_hess
  diag(H)[variance_index] <-
    (1 / G_diag^2) *
    (
      0.5 * n_rows -
        (psi_sum2 - 2 * mu[random_index] * psi_sum + n_rows * mu[random_index]^2) /
        G_diag
    )

  H[random_index, variance_index] <-
    .zibr_diag(-1 / G_diag^2) %*% .zibr_diag(psi_sum - n_rows * mu[random_index])
  H[variance_index, random_index] <-
    .zibr_diag(-1 / G_diag^2) %*% .zibr_diag(psi_sum - n_rows * mu[random_index])

  if (zi && n_alpha_random != n_alpha) {
    alpha_hess <- -numDeriv::hessian(
      .zibr_neg_loglik_zero,
      alpha[!alpha_random],
      psi_chain = psi_chain,
      alpha_random = alpha_random,
      x_design_chain = x_design_chain,
      id_chain = id_chain,
      is_positive_chain = is_positive_chain,
      is_zero_chain = is_zero_chain,
      n_alpha = n_alpha
    )

    alpha_fixed_index <- setdiff(seq_len(n_alpha), which(alpha_random))
    H[alpha_fixed_index, alpha_fixed_index] <- alpha_hess
  }

  if (n_beta_random != n_beta) {
    beta_phi_par <- c(beta[!beta_random], phi)
  } else {
    beta_phi_par <- phi
  }

  beta_phi_hess <- -numDeriv::hessian(
    .zibr_neg_loglik_beta,
    beta_phi_par,
    psi_chain = psi_chain,
    beta_random = beta_random,
    z_design_chain = z_design_chain,
    id_chain = id_chain,
    is_positive_chain = is_positive_chain,
    y_chain = y_chain,
    n_alpha = n_alpha,
    n_beta = n_beta,
    n_beta_random = n_beta_random
  )

  beta_phi_index <- setdiff(seq_len(n_beta + 1), which(beta_random)) + n_alpha
  H[beta_phi_index, beta_phi_index] <- beta_phi_hess

  H
}


#### Ajuste principal SAEM-ZIBR ####

fit_zibr <- function(y, id, X = NULL, Z = NULL, zi = TRUE,
                     phi_start, alpha_start = NULL, beta_start,
                     n_iter = 500, n_chains = 5, seed = NULL,
                     alpha_random = NULL, beta_random = NULL,
                     n_is = 500, compute_fim = TRUE, eps = 1e-6) {
  .zibr_check_packages(inference = compute_fim)

  if (!is.null(seed)) {
    set.seed(seed)
  }

  y <- .zibr_validate_y(y, zi = zi, eps = eps)

  if (length(y) != length(id)) {
    stop("y e id deben tener la misma longitud.", call. = FALSE)
  }

  n_total <- length(y)
  subject_id <- as.numeric(factor(id, levels = unique(id)))
  n_subjects <- length(unique(subject_id))

  if (zi) {
    x_design <- .zibr_covariate_matrix(X, n_total, "X")
    n_alpha <- ncol(x_design)

    if (length(alpha_start) != n_alpha) {
      stop("alpha_start debe tener longitud igual a 1 + numero de columnas de X.", call. = FALSE)
    }

    alpha_random <- if (is.null(alpha_random)) c(TRUE, rep(FALSE, n_alpha - 1)) else alpha_random
    if (length(alpha_random) != n_alpha) {
      stop("alpha_random debe tener longitud igual a length(alpha_start).", call. = FALSE)
    }

    x_design_chain <- .zibr_replicate_design(x_design, n_chains)
    alpha_labels <- colnames(x_design)
    n_alpha_random <- sum(alpha_random)
  } else {
    if (!is.null(X) || !is.null(alpha_start)) {
      stop("No entregue X ni alpha_start cuando zi = FALSE.", call. = FALSE)
    }

    x_design <- NULL
    x_design_chain <- NULL
    n_alpha <- 0
    alpha_start <- NULL
    alpha_random <- NULL
    alpha_labels <- NULL
    n_alpha_random <- 0
  }

  z_design <- .zibr_covariate_matrix(Z, n_total, "Z")
  n_beta <- ncol(z_design)

  if (length(beta_start) != n_beta) {
    stop("beta_start debe tener longitud igual a 1 + numero de columnas de Z.", call. = FALSE)
  }

  beta_random <- if (is.null(beta_random)) c(TRUE, rep(FALSE, n_beta - 1)) else beta_random
  if (length(beta_random) != n_beta) {
    stop("beta_random debe tener longitud igual a length(beta_start).", call. = FALSE)
  }

  beta_labels <- colnames(z_design)
  n_beta_random <- sum(beta_random)
  z_design_chain <- .zibr_replicate_design(z_design, n_chains)

  is_positive <- y != 0
  is_zero <- y == 0

  n_psi <- length(c(alpha_start, beta_start))
  random_index <- which(c(alpha_random, beta_random))
  n_random <- length(random_index)

  id_rep <- rep(subject_id, n_chains)
  id_chain <- id_rep + n_subjects * (rep(seq_len(n_chains), each = n_total) - 1)

  is_positive_chain <- rep(is_positive, n_chains)
  is_zero_chain <- rep(is_zero, n_chains)
  y_chain <- rep(y, n_chains)

  mu <- c(alpha_start, beta_start)
  G_full <- 0.5 * .zibr_diag(abs(mu))
  G <- as.matrix(G_full[random_index, random_index, drop = FALSE])
  phi <- phi_start

  psi_chain <- matrix(
    rep(mu, n_chains * n_subjects),
    nrow = n_chains * n_subjects,
    ncol = n_psi,
    byrow = TRUE
  )

  u_chain <- .zibr_linear_prob(
    psi_chain,
    n_alpha + seq_len(n_beta),
    id_chain,
    z_design_chain
  )

  if (zi) {
    p_chain <- .zibr_linear_prob(psi_chain, seq_len(n_alpha), id_chain, x_design_chain)
  } else {
    p_chain <- u_chain / u_chain
  }

  proposal_sd_uni <- 0.5 * G
  proposal_sd_uni[proposal_sd_uni < 0.5 & proposal_sd_uni > 0] <- 0.5
  proposal_sd_multi <- proposal_sd_uni

  if (compute_fim) {
    grad_avg <- rep(0, n_psi + n_random + 1)
    hess_avg <- matrix(0, nrow = n_psi + n_random + 1, ncol = n_psi + n_random + 1)
    score2_avg <- matrix(0, nrow = n_psi + n_random + 1, ncol = n_psi + n_random + 1)
    fisher_stoch <- matrix(0, nrow = n_psi + n_random + 1, ncol = n_psi + n_random + 1)
  } else {
    fisher_stoch <- NULL
  }

  psi_subject_mean <- apply(psi_chain, 2, function(x) tapply(x, rep(seq_len(n_subjects), n_chains), mean))
  psi_subject_second <- apply(psi_chain^2, 2, function(x) tapply(x, rep(seq_len(n_subjects), n_chains), mean))

  stat1 <- n_subjects * mu
  stat2 <- G_full
  trace <- NULL
  burn_in <- floor(0.75 * n_iter)

  for (iter in seq_len(n_iter)) {
    gamma <- if (iter <= burn_in) 1 else 1 / (iter - burn_in)

    mu_chain <- matrix(
      rep(mu, n_chains * n_subjects),
      nrow = n_chains * n_subjects,
      ncol = n_psi,
      byrow = TRUE
    )

    G_inv <- .zibr_diag(diag(G)^-1)
    log_ratio_data <- rep(0, n_chains * n_total)

    for (mh_iter in seq_len(4)) {
      psi_candidate <- MASS::mvrnorm(n_subjects * n_chains, mu, G_full)
      psi_candidate[, -random_index] <- psi_chain[, -random_index]

      if (zi) {
        p_candidate <- .zibr_linear_prob(
          psi_candidate,
          seq_len(n_alpha),
          id_chain,
          x_design_chain
        )
        log_ratio_data[is_zero_chain] <-
          log(1 - p_chain[is_zero_chain]) - log(1 - p_candidate[is_zero_chain])
      } else {
        p_candidate <- p_chain
      }

      u_candidate <- .zibr_linear_prob(
        psi_candidate,
        n_alpha + seq_len(n_beta),
        id_chain,
        z_design_chain
      )

      log_ratio_data[is_positive_chain] <-
        lgamma(phi * u_candidate[is_positive_chain]) +
        lgamma(phi * (1 - u_candidate[is_positive_chain])) +
        log(p_chain[is_positive_chain]) -
        lgamma(phi * u_chain[is_positive_chain]) -
        lgamma(phi * (1 - u_chain[is_positive_chain])) -
        log(p_candidate[is_positive_chain]) +
        phi * (u_chain[is_positive_chain] - u_candidate[is_positive_chain]) *
        (log(y_chain[is_positive_chain]) - log(1 - y_chain[is_positive_chain]))

      subject_log_ratio <- as.vector(tapply(log_ratio_data, id_chain, sum))
      accept <- subject_log_ratio < -log(runif(n_subjects * n_chains))

      psi_chain <- psi_candidate * accept + psi_chain * (!accept)

      if (zi) {
        p_chain <- .zibr_linear_prob(psi_chain, seq_len(n_alpha), id_chain, x_design_chain)
      }
      u_chain <- .zibr_linear_prob(psi_chain, n_alpha + seq_len(n_beta), id_chain, z_design_chain)
    }

    accepted_uni <- proposed_uni <- rep(0, n_random)

    for (mh_iter in seq_len(4)) {
      delta <- matrix(0, nrow = n_subjects * n_chains, ncol = n_random)
      delta[
        matrix(
          c(
            seq_len(n_chains * n_subjects),
            sample(seq_len(n_random), n_chains * n_subjects, replace = TRUE)
          ),
          nrow = n_chains * n_subjects
        )
      ] <- rnorm(n_chains * n_subjects)

      psi_candidate <- psi_chain
      psi_candidate[, random_index] <- psi_chain[, random_index] + delta %*% proposal_sd_uni

      if (zi) {
        p_candidate <- .zibr_linear_prob(
          psi_candidate,
          seq_len(n_alpha),
          id_chain,
          x_design_chain
        )
        log_ratio_data[is_zero_chain] <-
          log(1 - p_chain[is_zero_chain]) - log(1 - p_candidate[is_zero_chain])
      } else {
        p_candidate <- p_chain
      }

      u_candidate <- .zibr_linear_prob(
        psi_candidate,
        n_alpha + seq_len(n_beta),
        id_chain,
        z_design_chain
      )

      log_ratio_data[is_positive_chain] <-
        lgamma(phi * u_candidate[is_positive_chain]) +
        lgamma(phi * (1 - u_candidate[is_positive_chain])) +
        log(p_chain[is_positive_chain]) -
        lgamma(phi * u_chain[is_positive_chain]) -
        lgamma(phi * (1 - u_chain[is_positive_chain])) -
        log(p_candidate[is_positive_chain]) +
        phi * (u_chain[is_positive_chain] - u_candidate[is_positive_chain]) *
        (log(y_chain[is_positive_chain]) - log(1 - y_chain[is_positive_chain]))

      d_candidate <- psi_candidate[, random_index, drop = FALSE] - mu_chain[, random_index, drop = FALSE]
      d_current <- psi_chain[, random_index, drop = FALSE] - mu_chain[, random_index, drop = FALSE]

      subject_log_ratio <- as.vector(tapply(log_ratio_data, id_chain, sum)) +
        0.5 * (
          diag(d_candidate %*% G_inv %*% t(d_candidate)) -
            diag(d_current %*% G_inv %*% t(d_current))
        )

      accept <- subject_log_ratio < -log(runif(n_subjects * n_chains))
      psi_chain <- psi_candidate * accept + psi_chain * (!accept)

      if (zi) {
        p_chain <- .zibr_linear_prob(psi_chain, seq_len(n_alpha), id_chain, x_design_chain)
      }
      u_chain <- .zibr_linear_prob(psi_chain, n_alpha + seq_len(n_beta), id_chain, z_design_chain)

      accepted_uni <- accepted_uni + colSums((delta * accept) != 0)
      proposed_uni <- proposed_uni + colSums(delta != 0)
    }

    proposal_sd_uni <- (1 + 0.4 * (accepted_uni / proposed_uni - 0.4)) * proposal_sd_uni

    accepted_multi <- 0

    for (mh_iter in seq_len(4)) {
      psi_candidate <- psi_chain
      psi_candidate[, random_index] <-
        psi_chain[, random_index] +
        matrix(rnorm(n_chains * n_subjects * n_random),
               nrow = n_chains * n_subjects,
               ncol = n_random) %*%
        proposal_sd_multi

      if (zi) {
        p_candidate <- .zibr_linear_prob(
          psi_candidate,
          seq_len(n_alpha),
          id_chain,
          x_design_chain
        )
        log_ratio_data[is_zero_chain] <-
          log(1 - p_chain[is_zero_chain]) - log(1 - p_candidate[is_zero_chain])
      } else {
        p_candidate <- p_chain
      }

      u_candidate <- .zibr_linear_prob(
        psi_candidate,
        n_alpha + seq_len(n_beta),
        id_chain,
        z_design_chain
      )

      log_ratio_data[is_positive_chain] <-
        lgamma(phi * u_candidate[is_positive_chain]) +
        lgamma(phi * (1 - u_candidate[is_positive_chain])) +
        log(p_chain[is_positive_chain]) -
        lgamma(phi * u_chain[is_positive_chain]) -
        lgamma(phi * (1 - u_chain[is_positive_chain])) -
        log(p_candidate[is_positive_chain]) +
        phi * (u_chain[is_positive_chain] - u_candidate[is_positive_chain]) *
        (log(y_chain[is_positive_chain]) - log(1 - y_chain[is_positive_chain]))

      d_candidate <- psi_candidate[, random_index, drop = FALSE] - mu_chain[, random_index, drop = FALSE]
      d_current <- psi_chain[, random_index, drop = FALSE] - mu_chain[, random_index, drop = FALSE]

      subject_log_ratio <- as.vector(tapply(log_ratio_data, id_chain, sum)) +
        0.5 * (
          diag(d_candidate %*% G_inv %*% t(d_candidate)) -
            diag(d_current %*% G_inv %*% t(d_current))
        )

      accept <- subject_log_ratio < -log(runif(n_subjects * n_chains))
      psi_chain <- psi_candidate * accept + psi_chain * (!accept)

      if (zi) {
        p_chain <- .zibr_linear_prob(psi_chain, seq_len(n_alpha), id_chain, x_design_chain)
      }
      u_chain <- .zibr_linear_prob(psi_chain, n_alpha + seq_len(n_beta), id_chain, z_design_chain)

      accepted_multi <- accepted_multi + sum(accept)
    }

    proposal_sd_multi <-
      (1 + 0.4 * (accepted_multi / (4 * n_chains * n_subjects) - 0.4)) *
      proposal_sd_multi

    psi_subject_mean <- psi_subject_mean +
      gamma * (
        apply(psi_chain, 2, function(x) tapply(x, rep(seq_len(n_subjects), n_chains), mean)) -
          psi_subject_mean
      )

    psi_subject_second <- psi_subject_second +
      gamma * (
        apply(psi_chain^2, 2, function(x) tapply(x, rep(seq_len(n_subjects), n_chains), mean)) -
          psi_subject_second
      )

    stat1 <- stat1 + gamma * (colSums(psi_chain) / n_chains - stat1)
    stat2 <- stat2 + gamma * ((t(psi_chain) %*% psi_chain) / n_chains - stat2)

    if (iter > 10) {
      mu <- stat1 / n_subjects
      G_full <- stat2 / n_subjects - (stat1 %*% t(stat1)) / n_subjects^2
      G <- as.matrix(G_full[random_index, random_index, drop = FALSE])

      beta <- mu[n_alpha + seq_len(n_beta)]

      if (zi) {
        alpha <- mu[seq_len(n_alpha)]

        if (n_alpha_random != n_alpha) {
          alpha_opt <- stats::nlminb(
            start = alpha[!alpha_random],
            objective = .zibr_neg_loglik_zero,
            psi_chain = psi_chain,
            alpha_random = alpha_random,
            x_design_chain = x_design_chain,
            id_chain = id_chain,
            is_positive_chain = is_positive_chain,
            is_zero_chain = is_zero_chain,
            n_alpha = n_alpha
          )$par

          alpha[!alpha_random] <- alpha[!alpha_random] +
            gamma * (alpha_opt - alpha[!alpha_random])
        }
      } else {
        alpha <- NULL
      }

      if (n_beta_random != n_beta) {
        beta_phi_par <- c(beta[!beta_random], phi)
      } else {
        beta_phi_par <- phi
      }

      beta_phi_opt <- stats::nlminb(
        start = beta_phi_par,
        objective = .zibr_neg_loglik_beta,
        psi_chain = psi_chain,
        beta_random = beta_random,
        z_design_chain = z_design_chain,
        id_chain = id_chain,
        is_positive_chain = is_positive_chain,
        y_chain = y_chain,
        n_alpha = n_alpha,
        n_beta = n_beta,
        n_beta_random = n_beta_random,
        lower = c(rep(-Inf, length(beta_phi_par) - 1), 0.0001)
      )$par

      beta_phi_par <- beta_phi_par + gamma * (beta_phi_opt - beta_phi_par)
      phi <- beta_phi_par[length(beta_phi_par)]

      if (n_beta_random != n_beta) {
        beta[!beta_random] <- beta_phi_par[-length(beta_phi_par)]
      }

      mu <- c(alpha, beta)
      G_full[, -random_index] <- 0
      G_full[-random_index, ] <- 0

      psi_chain[, -random_index] <- matrix(
        rep(mu[-random_index], each = n_chains * n_subjects),
        ncol = n_psi - n_random,
        nrow = n_chains * n_subjects
      )

      if (compute_fim) {
        grad_current <- .zibr_complete_grad(
          mu, G, phi, zi, psi_chain, random_index, alpha_random,
          beta_random, n_random, x_design_chain, id_chain,
          is_positive_chain, is_zero_chain, n_alpha, n_beta,
          z_design_chain, y_chain, n_alpha_random, n_beta_random
        )

        hess_current <- .zibr_complete_hess(
          mu, G, phi, zi, psi_chain, random_index, alpha_random,
          beta_random, n_random, x_design_chain, id_chain,
          is_positive_chain, is_zero_chain, n_alpha, n_beta,
          z_design_chain, y_chain, n_alpha_random, n_beta_random
        )

        score2_current <- matrix(0, nrow = n_psi + n_random + 1, ncol = n_psi + n_random + 1)

        for (chain in seq_len(n_chains)) {
          row_index <- n_subjects * (chain - 1) + seq_len(n_subjects)

          grad_chain <- .zibr_complete_grad(
            mu, G, phi, zi, psi_chain[row_index, , drop = FALSE],
            random_index, alpha_random, beta_random, n_random,
            x_design, subject_id, is_positive, is_zero,
            n_alpha, n_beta, z_design, y,
            n_alpha_random, n_beta_random
          )

          score2_current <- score2_current + grad_chain %*% t(grad_chain)
        }

        grad_avg <- grad_avg + gamma * (grad_current - grad_avg)
        hess_avg <- hess_avg + gamma * (hess_current - hess_avg)
        score2_avg <- score2_avg + gamma * (score2_current - score2_avg)

        fisher_stoch <-
          (hess_avg + score2_avg) / n_chains -
          (grad_avg %*% t(grad_avg)) / n_chains^2
      }
    }

    trace <- rbind(trace, c(mu, .zibr_diag(G), phi))

    if (zi) {
      colnames(trace) <- c(
        paste("A", seq_len(n_alpha), sep = "."),
        paste("B", seq_len(n_beta), sep = "."),
        paste("SIGMA", seq_len(n_random), sep = "."),
        "V"
      )
    } else {
      colnames(trace) <- c(
        paste("B", seq_len(n_beta), sep = "."),
        paste("SIGMA", seq_len(n_random), sep = "."),
        "V"
      )
    }
  }

  psi_mean <- apply(psi_chain, 2, function(x) tapply(x, rep(seq_len(n_subjects), n_chains), mean))
  psi_var <- psi_subject_second - psi_subject_mean^2
  psi_var[, -random_index] <- 0

  loglik <- .zibr_loglik_importance(
    mu = mu,
    G = G,
    phi = phi,
    zi = zi,
    y = y,
    id = subject_id,
    x_design = x_design,
    z_design = z_design,
    n_alpha = n_alpha,
    n_beta = n_beta,
    is_positive = is_positive,
    is_zero = is_zero,
    psi_mean = psi_mean,
    psi_var = psi_var,
    random_index = random_index,
    n_random = n_random,
    n_samples = n_is,
    seed = seed
  )

  out <- list(
    mu = mu,
    G = G,
    phi = phi,
    psi_mean = psi_mean,
    psi_var = psi_var,
    loglik = loglik,
    zi = zi,
    trace = trace,
    alpha_labels = alpha_labels,
    beta_labels = beta_labels,
    n_alpha = n_alpha,
    n_beta = n_beta,
    alpha_random = alpha_random,
    beta_random = beta_random,
    random_index = random_index,
    fisher_stoch = fisher_stoch,
    nobs = n_total,
    call = match.call()
  )

  out$MU <- out$mu
  out$V <- out$phi
  out$psi.mean <- out$psi_mean
  out$psi.var <- out$psi_var
  out$graph <- out$trace
  out$labs.X <- out$alpha_labels
  out$labs.Z <- out$beta_labels
  out$nxcov <- out$n_alpha
  out$nzcov <- out$n_beta
  out$ind.a.aleat <- out$alpha_random
  out$ind.b.aleat <- out$beta_random
  out["FIM.stoch"] <- list(out$fisher_stoch)

  class(out) <- c("zibr_saem", "SAEM_ZIBR_result")
  out
}


#### Simulacion de datos ZIBR ####

simulate_zibr_data <- function(n_subjects, n_time, zi = TRUE,
                               X = NULL, Z = NULL, alpha = NULL, beta,
                               sigma_alpha = NULL, sigma_beta,
                               phi, seed = NULL) {
  .zibr_check_packages(inference = FALSE)

  if (!is.null(seed)) {
    set.seed(seed)
  }

  n_total <- n_subjects * n_time

  if (zi) {
    x_design <- .zibr_covariate_matrix(X, n_total, "X")
    n_alpha <- ncol(x_design)

    if (length(alpha) != n_alpha) {
      stop("alpha debe tener longitud igual a 1 + numero de columnas de X.", call. = FALSE)
    }

    random_cols <- c(1, n_alpha + 1)
  } else {
    if (!is.null(X) || !is.null(alpha)) {
      stop("No entregue X ni alpha cuando zi = FALSE.", call. = FALSE)
    }

    x_design <- NULL
    n_alpha <- 0
    random_cols <- 1
  }

  z_design <- .zibr_covariate_matrix(Z, n_total, "Z")
  n_beta <- ncol(z_design)

  if (length(beta) != n_beta) {
    stop("beta debe tener longitud igual a 1 + numero de columnas de Z.", call. = FALSE)
  }

  id <- rep(seq_len(n_subjects), each = n_time)
  mu <- c(alpha, beta)

  if (zi) {
    G <- .zibr_diag(c(sigma_alpha^2, sigma_beta^2))
  } else {
    G <- .zibr_diag(sigma_beta^2)
  }

  psi <- matrix(
    rep(mu, n_subjects),
    ncol = n_alpha + n_beta,
    nrow = n_subjects,
    byrow = TRUE
  )

  psi[, random_cols] <- MASS::mvrnorm(n = n_subjects, mu = mu[random_cols], Sigma = G)

  u <- .zibr_linear_prob(psi, n_alpha + seq_len(n_beta), id, z_design)

  if (zi) {
    p <- .zibr_linear_prob(psi, seq_len(n_alpha), id, x_design)
  } else {
    p <- u / u
  }

  present <- stats::rbinom(n_total, size = 1, prob = p)
  y_positive <- stats::rbeta(n_total, shape1 = u * phi, shape2 = (1 - u) * phi)
  y <- present * y_positive

  if (zi) {
    covariates <- data.frame(x_design[, -1, drop = FALSE], z_design[, -1, drop = FALSE])
    colnames(covariates) <- c(colnames(x_design)[-1], colnames(z_design)[-1])
  } else {
    covariates <- data.frame(z_design[, -1, drop = FALSE])
    colnames(covariates) <- colnames(z_design)[-1]
  }

  data.frame(
    Subject = paste("Subject", id, sep = "."),
    Time = rep(seq_len(n_time), n_subjects),
    Y = y,
    covariates,
    check.names = FALSE
  )
}


#### Metodos basicos ####

print.zibr_saem <- function(x, ...) {
  cat("===== Resultados SAEM-ZIBR =====\n")

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

  cat("== Parte beta: u_it ==\n")
  print(beta_tab[, c("Estimate", "Type")])

  cat("=== Varianzas de efectos aleatorios ===\n")
  if (x$zi && n_alpha_random > 0) {
    cat("== Parte logistica ==\n")
    print(alpha_tab[x$alpha_random, c("Variance", "sqrt.Var"), drop = FALSE])
  }
  if (n_beta_random > 0) {
    cat("== Parte beta ==\n")
    print(beta_tab[x$beta_random, c("Variance", "sqrt.Var"), drop = FALSE])
  }

  cat("=== Phi: ", x$phi, "\n", sep = "")
  cat("=== Log-verosimilitud marginal (importance sampling): ", x$loglik, "\n", sep = "")

  invisible(x)
}

plot.zibr_saem <- function(x, ...) {
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

logLik.zibr_saem <- function(object, ...) {
  value <- object$loglik
  attr(value, "df") <- length(object$mu) + 1 + length(diag(object$G))
  attr(value, "nobs") <- object$nobs
  class(value) <- "logLik"
  value
}

coef.zibr_saem <- function(object, ...) {
  object$mu
}

vcov.zibr_saem <- function(object, ...) {
  if (is.null(object$fisher_stoch)) {
    stop("El ajuste no contiene matriz FIM. Reajusta con compute_fim = TRUE.", call. = FALSE)
  }

  -solve(object$fisher_stoch)
}

se.zibr_saem <- function(object) {
  sqrt(diag(vcov(object)))
}


#### Funciones limpias para analisis por taxon ####

fit_zibr_taxon <- function(data, taxon, covariates = NULL,
                           x_covariates = covariates,
                           z_covariates = covariates,
                           id, zi = TRUE, phi_start = NULL,
                           alpha_start = NULL, beta_start = NULL,
                           seed = 232, n_iter = 500, n_chains = 5,
                           compute_fim = FALSE, ...) {
  if (!taxon %in% names(data)) {
    stop("El taxon indicado no existe en data.", call. = FALSE)
  }
  if (!id %in% names(data)) {
    stop("La columna id no existe en data.", call. = FALSE)
  }

  if (is.null(x_covariates)) {
    x_covariates <- character(0)
  }
  if (is.null(z_covariates)) {
    z_covariates <- character(0)
  }

  if (!all(x_covariates %in% names(data))) {
    stop("Al menos una covariable de x_covariates no existe en data.", call. = FALSE)
  }
  if (!all(z_covariates %in% names(data))) {
    stop("Al menos una covariable de z_covariates no existe en data.", call. = FALSE)
  }

  n_x_covariates <- length(x_covariates)
  n_z_covariates <- length(z_covariates)

  if (!is.null(seed)) {
    set.seed(seed)
  }

  if (is.null(phi_start)) {
    phi_start <- runif(1, 10, 20)
  }
  if (zi && is.null(alpha_start)) {
    alpha_start <- runif(n_x_covariates + 1, -0.1, 0.1)
  }
  if (is.null(beta_start)) {
    beta_start <- runif(n_z_covariates + 1, -0.1, 0.1)
  }

  X <- if (!zi || length(x_covariates) == 0) NULL else data[, x_covariates, drop = FALSE]
  Z <- if (length(z_covariates) == 0) NULL else data[, z_covariates, drop = FALSE]

  fit_zibr(
    y = data[[taxon]],
    id = data[[id]],
    X = X,
    Z = Z,
    zi = zi,
    phi_start = phi_start,
    alpha_start = alpha_start,
    beta_start = beta_start,
    n_iter = n_iter,
    n_chains = n_chains,
    seed = seed,
    compute_fim = compute_fim,
    ...
  )
}

fit_zibr_taxa <- function(data, taxa, covariates = NULL,
                          x_covariates = covariates,
                          z_covariates = covariates,
                          id, zi = TRUE, seed = 232,
                          n_iter = 500, n_chains = 5,
                          compute_fim = FALSE, ...) {
  fits <- lapply(taxa, function(taxon) {
    fit_zibr_taxon(
      data = data,
      taxon = taxon,
      x_covariates = x_covariates,
      z_covariates = z_covariates,
      id = id,
      zi = zi,
      seed = seed,
      n_iter = n_iter,
      n_chains = n_chains,
      compute_fim = compute_fim,
      ...
    )
  })

  names(fits) <- taxa
  fits
}

.zibr_extract_loglik <- function(model) {
  if (inherits(model, "zibr_saem")) {
    return(model$loglik)
  }

  as.numeric(stats::logLik(model))
}

lrt_zibr <- function(full, reduced, df = 2) {
  ll_full <- .zibr_extract_loglik(full)
  ll_reduced <- .zibr_extract_loglik(reduced)
  statistic <- 2 * (ll_full - ll_reduced)

  data.frame(
    LL_full = ll_full,
    LL_reduced = ll_reduced,
    LRT = statistic,
    df = df,
    p_value = stats::pchisq(statistic, df = df, lower.tail = FALSE)
  )
}

lrt_zibr_table <- function(full_models, reduced_models, species = names(full_models),
                           df = 2, alpha = 0.05) {
  if (length(full_models) != length(reduced_models)) {
    stop("full_models y reduced_models deben tener la misma longitud.", call. = FALSE)
  }

  if (is.null(species) || length(species) == 0) {
    species <- seq_along(full_models)
  }

  out <- do.call(
    rbind,
    Map(function(full, reduced, sp) {
      res <- lrt_zibr(full, reduced, df = df)
      data.frame(Species = sp, res, row.names = NULL)
    }, full_models, reduced_models, species)
  )

  out$Detected <- out$p_value < alpha
  rownames(out) <- NULL
  out
}

zibr_results_table <- function(species,
                               mod1_full, mod1_no_preg,
                               mod2_full, mod2_no_preg, mod2_no_inter,
                               df = 2, alpha = 0.05) {
  LL1.0 <- vapply(mod1_full, .zibr_extract_loglik, numeric(1))
  LL1.1 <- vapply(mod1_no_preg, .zibr_extract_loglik, numeric(1))
  LL2.0 <- vapply(mod2_full, .zibr_extract_loglik, numeric(1))
  LL2.1 <- vapply(mod2_no_preg, .zibr_extract_loglik, numeric(1))
  LL2.2 <- vapply(mod2_no_inter, .zibr_extract_loglik, numeric(1))

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


#### Preparacion de datos Romero para ZIBR ####

prepare_romero_zibr <- function(romero, taxa_out = c(31, 49, 50, 60),
                                zero_range = c(0.1, 0.9)) {
  if (!all(c("SampleData", "OTU") %in% names(romero))) {
    stop("romero debe contener los elementos SampleData y OTU.", call. = FALSE)
  }

  sample_data <- romero$SampleData
  otu <- romero$OTU

  keep_age <- stats::complete.cases(sample_data$Age)
  sample_data <- sample_data[keep_age, , drop = FALSE]
  otu <- otu[keep_age, , drop = FALSE]

  subject_id <- as.numeric(factor(sample_data$Subect_ID, levels = unique(sample_data$Subect_ID)))
  age_sc <- as.numeric(scale(
    sample_data$Age,
    center = min(sample_data$Age),
    scale = max(sample_data$Age) - min(sample_data$Age)
  ))

  month <- ifelse(
    sample_data$pregnant == 1,
    7 * sample_data$GA_Days / 30,
    sample_data$GA_Days / 30
  )

  time <- as.numeric(scale(
    month,
    center = min(month),
    scale = max(month) - min(month)
  ))

  covariates <- data.frame(
    Subect_ID = sample_data$Subect_ID,
    ID = subject_id,
    Time = time,
    pregnant = sample_data$pregnant,
    AGE_SC = age_sc,
    Time_Preg = time * sample_data$pregnant,
    Total.Read.Counts = sample_data$Total.Read.Counts,
    Month = month
  )

  rel_abund <- as.data.frame(sweep(otu, 1, sample_data$Total.Read.Counts, FUN = "/"))
  zero_prop <- vapply(rel_abund, function(x) mean(x == 0), numeric(1))
  taxa_filtered <- rel_abund[, zero_prop >= zero_range[1] & zero_prop <= zero_range[2], drop = FALSE]

  taxa_def <- setdiff(seq_len(ncol(taxa_filtered)), taxa_out)
  taxa_names <- colnames(taxa_filtered)[taxa_def]

  list(
    data = cbind(covariates, taxa_filtered[, taxa_def, drop = FALSE]),
    taxa = taxa_names,
    covariates = covariates,
    abundances = taxa_filtered[, taxa_def, drop = FALSE],
    taxa_removed = taxa_out,
    zero_range = zero_range
  )
}


#### Alias de compatibilidad con nombres del codigo original ####

saem_zibr_clean <- function(Y, X = NULL, Z = NULL, index, zi = TRUE,
                            v0, a0 = NULL, b0, seed, iter = 500, ncad = 5,
                            a.fix = NULL, b.fix = NULL, compute_fim = TRUE) {
  fit_zibr(
    y = Y,
    id = index,
    X = X,
    Z = Z,
    zi = zi,
    phi_start = v0,
    alpha_start = a0,
    beta_start = b0,
    n_iter = iter,
    n_chains = ncad,
    seed = seed,
    alpha_random = if (is.null(a.fix)) NULL else a.fix == 0,
    beta_random = if (is.null(b.fix)) NULL else b.fix == 0,
    compute_fim = compute_fim
  )
}

sim_zibr_data_clean <- function(n.ind, n.obs.ind, zi = TRUE,
                                X = NULL, Z = NULL, alpha = NULL, beta,
                                s1 = NULL, s2, v, seed) {
  simulate_zibr_data(
    n_subjects = n.ind,
    n_time = n.obs.ind,
    zi = zi,
    X = X,
    Z = Z,
    alpha = alpha,
    beta = beta,
    sigma_alpha = s1,
    sigma_beta = s2,
    phi = v,
    seed = seed
  )
}
