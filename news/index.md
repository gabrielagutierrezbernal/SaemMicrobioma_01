# Changelog

## saemMicrobiome 0.0.1

- Ejemplos del README: se aumento el tamano de muestra a 300 sujetos (y
  300 iteraciones) para que los estimados de los ejemplos ZIBR y ZIBBMR
  queden cerca de los valores verdaderos de la simulacion (antes, con 30
  sujetos, un unico ajuste podia caer lejos por ruido de muestreo).
- Graficos: los metodos
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) de
  `zibr_saem`/`zibbmr_saem` aceptan ahora un argumento `which` con tres
  tipos de grafico (inspirados en `saemix`): `"convergencia"` (traza del
  algoritmo, por defecto y compatible con el comportamiento anterior),
  `"coeficientes"` (coeficientes estimados con intervalo de confianza al
  95%, tipo forest plot; requiere `compute_fim = TRUE`) y `"aleatorios"`
  (distribucion entre sujetos de los efectos aleatorios estimados). Ver
  `estudios/graficos/IDEAS_GRAFICOS.md` para las ideas de graficos
  (incluyendo los que necesitarian guardar los datos originales:
  observados vs. predichos, residuos) y ejemplos.
- Auditoria de fidelidad metodologica (2026-07-05): se comparo
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)/
  [`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md)
  contra los scripts originales de John Barrera
  (`jbarrera232/saem-zibr`, `jbarrera232/saem-zibbmr`). El algoritmo
  SAEM (kernels Metropolis-Hastings del S-step, aproximacion
  estocastica, importance sampling, verosimilitudes cero-inflada y
  continua/beta-binomial) es matematicamente identico al original;
  verificado empiricamente con semilla y valores iniciales equivalentes:
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)/[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md)
  reproducen exactamente (`mu`, `phi`, `G`, `loglik`) los resultados de
  `saem_zibr()`/`saem_zibbmr()` originales bajo la configuracion por
  defecto (efecto aleatorio = intercepto).
- Correccion heredada del refactor previo a esta auditoria (no
  introducida en esta sesion): los scripts originales de Barrera indexan
  las posiciones de efectos fijos con `A[-ind.a.aleat]` /
  `setdiff(1:n, ind.a.aleat)`, donde `ind.a.aleat`/`ind.b.aleat` es un
  vector logico. Esa expresion solo funciona cuando el efecto aleatorio
  esta en la posicion 1 (el caso por defecto, y el unico usado por
  [`fit_zibr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr_taxon.md)/[`fit_zibbmr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr_taxon.md),
  por tanto el unico usado en cualquier analisis corrido hasta ahora con
  este paquete). Si se llama a
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)/[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md)
  directamente con `alpha_random`/`beta_random` personalizado
  (equivalente a `a.fix`/`b.fix` en el original) y el efecto aleatorio
  no esta en la primera posicion, el original deja de actualizar el
  parametro fijo correspondiente (queda congelado en su valor inicial),
  tanto en la estimacion puntual como en el Hessiano/FIM. El paquete usa
  `alpha[!alpha_random]` (negacion logica) en vez de la aritmetica sobre
  el vector logico, lo cual evita el problema; verificado empiricamente.
  Impacto practico: ninguno para el uso estandar del paquete; solo
  relevante para quien llame
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)/[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md)
  directamente con posiciones de efecto aleatorio no estandar.
- Se definio la API publica del paquete via roxygen2/NAMESPACE:
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md),
  [`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md),
  [`simulate_zibr_data()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/simulate_zibr_data.md),
  [`simulate_zibbmr_data()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/simulate_zibbmr_data.md),
  [`fit_zibr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr_taxon.md)/[`fit_zibr_taxa()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr_taxa.md),
  [`fit_zibbmr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr_taxon.md)/
  [`fit_zibbmr_taxa()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr_taxa.md),
  [`lrt_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibr.md)/[`lrt_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibbmr.md)
  y sus `_table()`,
  [`zibr_results_table()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/zibr_results_table.md)/[`zibbmr_results_table()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/zibbmr_results_table.md),
  [`prepare_romero_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/prepare_romero_zibr.md)/
  [`prepare_romero_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/prepare_romero_zibbmr.md),
  los metodos S3 (`print`, `plot`, `logLik`, `coef`, `vcov`, `se`) y los
  alias historicos
  [`saem_zibr_clean()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/saem_zibr_clean.md)/
  [`saem_zibbmr_clean()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/saem_zibbmr_clean.md).
  Se agrego
  [`fit_saem_microbiome()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/ajustar_modelo_microbioma.md)
  como alias de
  [`ajustar_modelo_microbioma()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/ajustar_modelo_microbioma.md).
- Se agrego el generico
  [`se()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/se.md)
  (antes
  [`se.zibr_saem()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/se.md)/[`se.zibbmr_saem()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/se.md)
  existian pero no eran invocables por faltar el generico).
- Segunda pasada de optimizacion (2026-07-06): se consolidan en
  `R/utils.R` once funciones mas que estaban duplicadas palabra por
  palabra entre `zibr.R` y `zibbmr.R` (la formula de la parte de
  inflacion de ceros, la comparacion de modelos por LRT, y los metodos
  `print`/`plot`/`logLik`/ `coef`/`vcov`/`se`). Las funciones publicas
  mantienen nombre, firma y documentacion exactos. Verificado
  empiricamente que los resultados numericos no cambian.
- Se corrige
  [`simular_datos_microbioma()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/simular_datos_microbioma.md)
  para que funcione con `n_taxa = 1` (antes fallaba por una conversion
  implicita de data.frame a vector).
- Se agrega `Remotes: nyiuab/NBZIMM` a `DESCRIPTION`, ya que `NBZIMM` no
  esta en CRAN; esto era necesario para que la instalacion de
  dependencias en CI (GitHub Actions) pudiera resolverlo.
- Se agrega a John Barrera como colaborador (`ctb`) en `DESCRIPTION`,
  autor original del metodo de estimacion SAEM para ZIBR y ZIBBMR.
- Se amplia la cobertura de tests de 66 a 85 pruebas (cobertura de
  codigo medida con `covr`: 83.8% -\> 89.8%), agregando casos para
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html), los errores
  de [`vcov()`](https://rdrr.io/r/stats/vcov.html) sin
  `compute_fim = TRUE`,
  [`zibr_results_table()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/zibr_results_table.md)/
  [`zibbmr_results_table()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/zibbmr_results_table.md),
  el caso `zi = FALSE` (sin inflacion de ceros) en ambos modelos, y
  objetos genericos con metodo
  [`logLik()`](https://rdrr.io/r/stats/logLik.html) propio en
  [`lrt_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibr.md)/[`lrt_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibbmr.md).
- Optimizacion de rendimiento en R puro del motor SAEM (fase 1), sin
  cambiar la logica estadistica: los resultados numericos son
  byte-identicos antes y despues (verificado con semilla fija en ZIBR y
  ZIBBMR). Cambios:
  1.  en el loop MCMC, `tapply(., id_chain, sum)` -\>
      `rowsum(., id_chain)` y
      `apply(., 2, function(x) tapply(x, grupo, mean))` -\>
      `rowsum(., grupo)/n_chains`, evitando reconstruir el factor de
      agrupamiento en cada iteracion;
  2.  las formas cuadraticas `diag(d %*% G_inv %*% t(d))`, que
      construian una matriz (n_subjects*n_chains) x
      (n_subjects*n_chains) completa solo para quedarse con la diagonal,
      se reemplazan por la identidad equivalente
      `rowSums((d %*% G_inv) * d)`. Resultado: ~2.3x mas rapido (en un
      benchmark controlado de 150 sujetos x 300 iteraciones: de ~8s sin
      optimizar a ~3.4s), y proporcionalmente en casos mas chicos. La
      magnitud exacta depende del dataset. Ver
      `estudios/comparacion_tiempos/`.
- Optimizacion con C++/Rcpp (fase 2): la funcion interna mas llamada del
  motor SAEM (`.saem_linear_prob`, el predictor lineal por observacion)
  se reimplementa parcialmente en C++ (`src/saem_linear_prob.cpp`): el
  predictor lineal `eta` (gather de filas de `psi` + producto por el
  diseno + suma) se calcula en C++ y
  [`plogis()`](https://rdrr.io/r/stats/Logistic.html) se aplica despues
  en R (vectorizado). Asi el resultado es byte-identico al de la version
  en R puro (verificado con semilla fija en ZIBR y ZIBBMR; los 93 tests
  siguen pasando) y se evita materializar la matriz intermedia
  `psi[id, cols]` y el `rowSums`. El paquete ahora requiere un
  compilador de C++ (dependencia `Rcpp`). **Nota honesta de
  rendimiento:** medido de forma controlada (misma maquina, mismo
  dataset, mediana de varias corridas), esta fase C++ NO produce una
  aceleracion apreciable sobre la fase 1 en R puro (~3.4s en ambos casos
  para 150 sujetos x 300 iteraciones). El motivo es que las operaciones
  que quedaban (`plogis`, productos de matrices, `rowSums`) R ya las
  ejecuta en C compilado; C++ solo ayuda cuando reemplaza loops
  interpretados de R, que es justo lo que hizo la fase 1. El grueso de
  la mejora (~2.3x: de ~8s a ~3.4s frente a la version sin optimizar; el
  codigo original de John esta en ~11s) proviene de la fase 1. Ver
  `estudios/comparacion_tiempos/` para la tabla y la metodologia.
- [`ajustar_modelo_microbioma()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/ajustar_modelo_microbioma.md)/[`fit_saem_microbiome()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/ajustar_modelo_microbioma.md)
  se robustecen para seguir el mismo patron que
  [`fit_zibr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr_taxon.md)/[`fit_zibbmr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr_taxon.md):
  admiten `x_covariables`/`z_covariables` por separado (antes forzaba
  las mismas covariables en ambas partes del modelo), generan valores
  iniciales aleatorios razonables cuando no se entregan (antes usaban
  siempre los mismos valores fijos), exponen `compute_fim`, y validan
  que `taxon`/`id`/ `total` existan en los datos. Se corrige ademas un
  bug: con `zi = FALSE` se seguia armando la matriz `X`, lo que hacia
  fallar el ajuste (
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)/[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md)
  no aceptan `X` cuando `zi = FALSE`). Se amplian los tests de 85 a 93.
