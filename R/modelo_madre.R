#' Ajustar un modelo SAEM de microbioma (ZIBR o ZIBBMR) desde un data frame
#'
#' Funcion "madre" que despacha a [saem_zibr_clean()] o [saem_zibbmr_clean()]
#' segun `modelo`, extrayendo la respuesta, el total de lecturas (si aplica)
#' y las covariables directamente de un data frame por nombre de columna, y
#' generando valores iniciales por defecto razonables. Pensada para ajustar
#' rapidamente un taxon sin tener que armar a mano las matrices `X`/`Z` y los
#' vectores de valores iniciales que piden [fit_zibr()]/[fit_zibbmr()].
#'
#' `fit_saem_microbiome()` es un alias identico, con un nombre que sigue la
#' convencion `fit_*` del resto del paquete.
#'
#' @param modelo Cual modelo ajustar: `"zibbmr"` (por defecto, conteos con
#'   profundidad de secuenciacion) o `"zibr"` (proporciones).
#' @param datos Data frame con una fila por observacion.
#' @param taxon Nombre de la columna en `datos` con la respuesta (conteo o
#'   proporcion, segun `modelo`) a modelar.
#' @param id Nombre de la columna en `datos` que identifica al sujeto.
#' @param total Nombre de la columna en `datos` con el total de lecturas.
#'   Solo se usa si `modelo = "zibbmr"`.
#' @param covariables Vector de nombres de columnas en `datos` a usar como
#'   covariables, tanto en la parte logistica como en la parte
#'   beta/beta-binomial.
#' @param zi Logico, ver [fit_zibr()]/[fit_zibbmr()].
#' @param iter Numero de iteraciones SAEM.
#' @param ncad Numero de cadenas MCMC.
#' @param seed Semilla aleatoria.
#'
#' @return Un objeto `zibr_saem` o `zibbmr_saem`, segun `modelo`.
#' @seealso [fit_zibr_taxon()], [fit_zibbmr_taxon()] para envoltorios
#'   equivalentes con la firma de argumentos moderna (`n_iter`, `n_chains`,
#'   `x_covariates`/`z_covariates` separados).
#' @export
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

#' @rdname ajustar_modelo_microbioma
#' @export
fit_saem_microbiome <- function(modelo = c("zibbmr", "zibr"),
                                datos,
                                taxon,
                                id = "id",
                                total = "N",
                                covariables = c("tiempo", "grupo"),
                                zi = TRUE,
                                iter = 200,
                                ncad = 5,
                                seed = 1) {
  ajustar_modelo_microbioma(
    modelo = modelo,
    datos = datos,
    taxon = taxon,
    id = id,
    total = total,
    covariables = covariables,
    zi = zi,
    iter = iter,
    ncad = ncad,
    seed = seed
  )
}
