# saemMicrobiome 0.0.1

* Auditoria de fidelidad metodologica (2026-07-05): se comparo `fit_zibr()`/
  `fit_zibbmr()` contra los scripts originales de John Barrera
  (`jbarrera232/saem-zibr`, `jbarrera232/saem-zibbmr`). El algoritmo SAEM
  (kernels Metropolis-Hastings del S-step, aproximacion estocastica,
  importance sampling, verosimilitudes cero-inflada y continua/beta-binomial)
  es matematicamente identico al original; verificado empiricamente con
  semilla y valores iniciales equivalentes: `fit_zibr()`/`fit_zibbmr()`
  reproducen exactamente (`mu`, `phi`, `G`, `loglik`) los resultados de
  `saem_zibr()`/`saem_zibbmr()` originales bajo la configuracion por defecto
  (efecto aleatorio = intercepto).
* Correccion heredada del refactor previo a esta auditoria (no introducida en
  esta sesion): los scripts originales de Barrera indexan las posiciones de
  efectos fijos con `A[-ind.a.aleat]` / `setdiff(1:n, ind.a.aleat)`, donde
  `ind.a.aleat`/`ind.b.aleat` es un vector logico. Esa expresion solo
  funciona cuando el efecto aleatorio esta en la posicion 1 (el caso por
  defecto, y el unico usado por `fit_zibr_taxon()`/`fit_zibbmr_taxon()`, por
  tanto el unico usado en cualquier analisis corrido hasta ahora con este
  paquete). Si se llama a `fit_zibr()`/`fit_zibbmr()` directamente con
  `alpha_random`/`beta_random` personalizado (equivalente a `a.fix`/`b.fix`
  en el original) y el efecto aleatorio no esta en la primera posicion, el
  original deja de actualizar el parametro fijo correspondiente (queda
  congelado en su valor inicial), tanto en la estimacion puntual como en el
  Hessiano/FIM. El paquete usa `alpha[!alpha_random]` (negacion logica) en
  vez de la aritmetica sobre el vector logico, lo cual evita el problema;
  verificado empiricamente. Impacto practico: ninguno para el uso estandar
  del paquete; solo relevante para quien llame `fit_zibr()`/`fit_zibbmr()`
  directamente con posiciones de efecto aleatorio no estandar.
* Se definio la API publica del paquete via roxygen2/NAMESPACE: `fit_zibr()`,
  `fit_zibbmr()`, `simulate_zibr_data()`, `simulate_zibbmr_data()`,
  `fit_zibr_taxon()`/`fit_zibr_taxa()`, `fit_zibbmr_taxon()`/
  `fit_zibbmr_taxa()`, `lrt_zibr()`/`lrt_zibbmr()` y sus `_table()`,
  `zibr_results_table()`/`zibbmr_results_table()`, `prepare_romero_zibr()`/
  `prepare_romero_zibbmr()`, los metodos S3 (`print`, `plot`, `logLik`,
  `coef`, `vcov`, `se`) y los alias historicos `saem_zibr_clean()`/
  `saem_zibbmr_clean()`. Se agrego `fit_saem_microbiome()` como alias de
  `ajustar_modelo_microbioma()`.
* Se agrego el generico `se()` (antes `se.zibr_saem()`/`se.zibbmr_saem()`
  existian pero no eran invocables por faltar el generico).
* Segunda pasada de optimizacion (2026-07-06): se consolidan en `R/utils.R`
  once funciones mas que estaban duplicadas palabra por palabra entre
  `zibr.R` y `zibbmr.R` (la formula de la parte de inflacion de ceros, la
  comparacion de modelos por LRT, y los metodos `print`/`plot`/`logLik`/
  `coef`/`vcov`/`se`). Las funciones publicas mantienen nombre, firma y
  documentacion exactos. Verificado empiricamente que los resultados
  numericos no cambian.
* Se corrige `simular_datos_microbioma()` para que funcione con `n_taxa = 1`
  (antes fallaba por una conversion implicita de data.frame a vector).
* Se agrega `Remotes: nyiuab/NBZIMM` a `DESCRIPTION`, ya que `NBZIMM` no esta
  en CRAN; esto era necesario para que la instalacion de dependencias en
  CI (GitHub Actions) pudiera resolverlo.
* Se agrega a John Barrera como colaborador (`ctb`) en `DESCRIPTION`, autor
  original del metodo de estimacion SAEM para ZIBR y ZIBBMR.
* Se amplia la cobertura de tests de 66 a 85 pruebas (cobertura de codigo
  medida con `covr`: 83.8% -> 89.8%), agregando casos para `plot()`, los
  errores de `vcov()` sin `compute_fim = TRUE`, `zibr_results_table()`/
  `zibbmr_results_table()`, el caso `zi = FALSE` (sin inflacion de ceros) en
  ambos modelos, y objetos genericos con metodo `logLik()` propio en
  `lrt_zibr()`/`lrt_zibbmr()`.
* Optimizacion de rendimiento en R puro del motor SAEM (fase 1), sin cambiar
  la logica estadistica: los resultados numericos son byte-identicos antes y
  despues (verificado con semilla fija en ZIBR y ZIBBMR). Cambios:
  (a) en el loop MCMC, `tapply(., id_chain, sum)` -> `rowsum(., id_chain)` y
      `apply(., 2, function(x) tapply(x, grupo, mean))` ->
      `rowsum(., grupo)/n_chains`, evitando reconstruir el factor de
      agrupamiento en cada iteracion;
  (b) las formas cuadraticas `diag(d %*% G_inv %*% t(d))`, que construian una
      matriz (n_subjects*n_chains) x (n_subjects*n_chains) completa solo para
      quedarse con la diagonal, se reemplazan por la identidad equivalente
      `rowSums((d %*% G_inv) * d)`.
  Resultado: ~2.3x mas rapido (en un benchmark controlado de 150 sujetos x
  300 iteraciones: de ~8s sin optimizar a ~3.4s), y proporcionalmente en
  casos mas chicos. La magnitud exacta depende del dataset. Ver
  `estudios/comparacion_tiempos/`.
* Optimizacion con C++/Rcpp (fase 2): la funcion interna mas llamada del
  motor SAEM (`.saem_linear_prob`, el predictor lineal por observacion) se
  reimplementa parcialmente en C++ (`src/saem_linear_prob.cpp`): el predictor
  lineal `eta` (gather de filas de `psi` + producto por el diseno + suma) se
  calcula en C++ y `plogis()` se aplica despues en R (vectorizado). Asi el
  resultado es byte-identico al de la version en R puro (verificado con
  semilla fija en ZIBR y ZIBBMR; los 93 tests siguen pasando) y se evita
  materializar la matriz intermedia `psi[id, cols]` y el `rowSums`. El
  paquete ahora requiere un compilador de C++ (dependencia `Rcpp`).
  **Nota honesta de rendimiento:** medido de forma controlada (misma maquina,
  mismo dataset, mediana de varias corridas), esta fase C++ NO produce una
  aceleracion apreciable sobre la fase 1 en R puro (~3.4s en ambos casos para
  150 sujetos x 300 iteraciones). El motivo es que las operaciones que
  quedaban (`plogis`, productos de matrices, `rowSums`) R ya las ejecuta en C
  compilado; C++ solo ayuda cuando reemplaza loops interpretados de R, que es
  justo lo que hizo la fase 1. El grueso de la mejora (~2.3x: de ~8s a ~3.4s
  frente a la version sin optimizar; el codigo original de John esta en ~11s)
  proviene de la fase 1. Ver `estudios/comparacion_tiempos/` para la tabla y
  la metodologia.
* `ajustar_modelo_microbioma()`/`fit_saem_microbiome()` se robustecen para
  seguir el mismo patron que `fit_zibr_taxon()`/`fit_zibbmr_taxon()`:
  admiten `x_covariables`/`z_covariables` por separado (antes forzaba las
  mismas covariables en ambas partes del modelo), generan valores iniciales
  aleatorios razonables cuando no se entregan (antes usaban siempre los
  mismos valores fijos), exponen `compute_fim`, y validan que `taxon`/`id`/
  `total` existan en los datos. Se corrige ademas un bug: con `zi = FALSE`
  se seguia armando la matriz `X`, lo que hacia fallar el ajuste (
  `fit_zibr()`/`fit_zibbmr()` no aceptan `X` cuando `zi = FALSE`). Se
  amplian los tests de 85 a 93.
