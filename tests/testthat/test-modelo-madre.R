test_that("ajustar_modelo_microbioma despacha a zibbmr por defecto", {
  set.seed(1)
  sim <- simular_datos_microbioma(n_ind = 10, n_time = 3, n_taxa = 2, N = 500, seed = 1)

  fit <- ajustar_modelo_microbioma(
    modelo = "zibbmr", datos = sim$conteo, taxon = "Taxon1",
    id = "id", total = "N", covariables = c("tiempo", "grupo"),
    iter = 20, seed = 1
  )

  expect_s3_class(fit, "zibbmr_saem")
})

test_that("ajustar_modelo_microbioma despacha a zibr cuando se pide", {
  set.seed(1)
  sim <- simular_datos_microbioma(n_ind = 10, n_time = 3, n_taxa = 2, N = 500, seed = 1)

  fit <- ajustar_modelo_microbioma(
    modelo = "zibr", datos = sim$proporcion, taxon = "Taxon1",
    id = "id", covariables = c("tiempo", "grupo"),
    iter = 20, seed = 1
  )

  expect_s3_class(fit, "zibr_saem")
})

test_that("fit_saem_microbiome es un alias identico a ajustar_modelo_microbioma", {
  sim <- simular_datos_microbioma(n_ind = 10, n_time = 3, n_taxa = 2, N = 500, seed = 1)

  via_alias <- fit_saem_microbiome(
    modelo = "zibbmr", datos = sim$conteo, taxon = "Taxon1",
    id = "id", total = "N", covariables = c("tiempo", "grupo"),
    iter = 20, seed = 1
  )
  via_original <- ajustar_modelo_microbioma(
    modelo = "zibbmr", datos = sim$conteo, taxon = "Taxon1",
    id = "id", total = "N", covariables = c("tiempo", "grupo"),
    iter = 20, seed = 1
  )

  expect_equal(via_alias$mu, via_original$mu)
  expect_equal(via_alias$loglik, via_original$loglik)
})

test_that("ajustar_modelo_microbioma exige un modelo valido", {
  sim <- simular_datos_microbioma(n_ind = 5, n_time = 2, n_taxa = 1, seed = 1)
  expect_error(
    ajustar_modelo_microbioma(modelo = "otro", datos = sim$conteo, taxon = "Taxon1"),
    "arg"
  )
})
