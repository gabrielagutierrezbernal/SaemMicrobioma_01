test_that("simulate_zibr_data devuelve la estructura esperada", {
  dat <- simulate_zibr_data(
    n_subjects = 10, n_time = 3, alpha = c(-0.3, 0.5), beta = c(0.2, -0.4),
    sigma_alpha = 0.4, sigma_beta = 0.3, phi = 15,
    X = matrix(rbinom(30, 1, 0.5)), Z = matrix(rbinom(30, 1, 0.5)), seed = 1
  )

  expect_s3_class(dat, "data.frame")
  expect_equal(nrow(dat), 30)
  expect_true(all(c("Subject", "Time", "Y") %in% names(dat)))
  expect_true(all(dat$Y >= 0 & dat$Y < 1))
})

test_that("simulate_zibr_data sin zi no admite X ni alpha", {
  expect_error(
    simulate_zibr_data(
      n_subjects = 5, n_time = 3, zi = FALSE,
      X = matrix(1, 15), alpha = 0.1, beta = c(0.1, 0.1),
      sigma_beta = 0.3, phi = 10, seed = 1
    ),
    "No entregue X ni alpha"
  )
})

test_that("fit_zibr reproduce un resultado conocido para una semilla fija", {
  n_subjects <- 40
  n_time <- 4
  X <- rep(c(0, 1), each = n_time, length.out = n_subjects * n_time)

  dat <- simulate_zibr_data(
    n_subjects = n_subjects, n_time = n_time,
    X = matrix(X, ncol = 1), Z = matrix(X, ncol = 1),
    alpha = c(-0.3, 0.5), beta = c(0.2, -0.4),
    sigma_alpha = 0.4, sigma_beta = 0.3, phi = 15, seed = 42
  )

  fit <- fit_zibr(
    y = dat$Y, id = dat$Subject, X = matrix(X, ncol = 1), Z = matrix(X, ncol = 1),
    phi_start = 10, alpha_start = c(-0.2, 0.1), beta_start = c(0.1, 0.1),
    n_iter = 300, n_chains = 5, seed = 123, compute_fim = FALSE
  )

  expect_s3_class(fit, "zibr_saem")
  expect_equal(
    fit$mu,
    c(-0.4986460, 0.8597449, 0.2693654, -0.5510695),
    tolerance = 1e-5
  )
  expect_equal(fit$phi, 11.23922, tolerance = 1e-4)
  expect_equal(fit$loglik, -63.15735, tolerance = 1e-3)
})

test_that("saem_zibr_clean (alias historico) da el mismo resultado que fit_zibr", {
  set.seed(11)
  n <- 60
  X <- matrix(rbinom(n, 1, 0.5), ncol = 1)
  Z <- X
  id <- rep(seq_len(15), each = 4)

  dat <- simulate_zibr_data(
    n_subjects = 15, n_time = 4, X = X, Z = Z,
    alpha = c(-0.2, 0.3), beta = c(0.1, -0.2),
    sigma_alpha = 0.3, sigma_beta = 0.2, phi = 12, seed = 5
  )

  via_fit <- fit_zibr(
    y = dat$Y, id = id, X = X, Z = Z,
    phi_start = 10, alpha_start = c(-0.1, 0.1), beta_start = c(0.1, 0.1),
    n_iter = 30, seed = 7, compute_fim = FALSE
  )
  via_clean <- saem_zibr_clean(
    Y = dat$Y, X = X, Z = Z, index = id,
    v0 = 10, a0 = c(-0.1, 0.1), b0 = c(0.1, 0.1),
    seed = 7, iter = 30, compute_fim = FALSE
  )

  expect_equal(via_fit$mu, via_clean$mu)
  expect_equal(via_fit$loglik, via_clean$loglik)
})

test_that("alpha_random no-default sigue optimizando el efecto fijo (regresion del fix heredado)", {
  n_subjects <- 40
  n_time <- 4
  X <- rep(c(0, 1), each = n_time, length.out = n_subjects * n_time)

  dat <- simulate_zibr_data(
    n_subjects = n_subjects, n_time = n_time,
    X = matrix(X, ncol = 1), Z = matrix(X, ncol = 1),
    alpha = c(-0.3, 0.5), beta = c(0.2, -0.4),
    sigma_alpha = 0.4, sigma_beta = 0.3, phi = 15, seed = 42
  )

  fit <- fit_zibr(
    y = dat$Y, id = dat$Subject, X = matrix(X, ncol = 1), Z = matrix(X, ncol = 1),
    phi_start = 10, alpha_start = c(-0.2, 0.1), beta_start = c(0.1, 0.1),
    n_iter = 50, n_chains = 5, seed = 123, compute_fim = FALSE,
    alpha_random = c(FALSE, TRUE)
  )

  # El efecto fijo (posicion 1) debe alejarse de su valor inicial (-0.2);
  # en el script original de Barrera quedaba congelado por un bug de indexacion
  # cuando el efecto aleatorio no esta en la posicion 1 (ver NEWS.md).
  expect_false(isTRUE(all.equal(fit$mu[1], -0.2)))
})

test_that("metodos S3 de zibr_saem devuelven la estructura esperada", {
  dat <- simulate_zibr_data(
    n_subjects = 10, n_time = 3, alpha = c(-0.2, 0.3), beta = c(0.1, -0.2),
    sigma_alpha = 0.3, sigma_beta = 0.2, phi = 12,
    X = matrix(rbinom(30, 1, 0.5)), Z = matrix(rbinom(30, 1, 0.5)), seed = 3
  )

  fit <- fit_zibr(
    y = dat$Y, id = dat$Subject, X = dat$X.1, Z = dat$Z.1,
    phi_start = 10, alpha_start = c(-0.1, 0.1), beta_start = c(0.1, 0.1),
    n_iter = 20, seed = 3, compute_fim = TRUE
  )

  expect_type(coef(fit), "double")
  expect_length(coef(fit), 4)
  expect_s3_class(logLik(fit), "logLik")
  expect_true(is.matrix(vcov(fit)))
  # con pocas iteraciones/observaciones el FIM estocastico puede quedar
  # mal condicionado y producir NaN en algun se(); solo se prueba el tipo.
  expect_type(suppressWarnings(se(fit)), "double")
  expect_output(print(fit), "SAEM-ZIBR")
})

test_that("fit_zibr valida dimensiones y rango de Y", {
  expect_error(
    fit_zibr(
      y = c(0.5, 1.5), id = c(1, 1), Z = NULL,
      phi_start = 10, beta_start = 0.1, n_iter = 1
    ),
    "proporciones en el intervalo"
  )
  expect_error(
    fit_zibr(
      y = c(0.5, 0.5, 0.5), id = c(1, 1), Z = NULL,
      phi_start = 10, beta_start = 0.1, n_iter = 1
    ),
    "misma longitud"
  )
})
