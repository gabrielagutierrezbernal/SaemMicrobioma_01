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
