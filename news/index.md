# Changelog

## saemMicrobiome 0.0.1

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
