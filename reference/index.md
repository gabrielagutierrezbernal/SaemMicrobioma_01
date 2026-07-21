# Package index

## Ajuste de modelos

Funciones principales para ajustar ZIBR y ZIBBMR.

- [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)
  : Ajustar un modelo ZIBR (zero-inflated beta regression) via SAEM
- [`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md)
  : Ajustar un modelo ZIBBMR (zero-inflated beta-binomial mixed
  regression) via SAEM
- [`ajustar_modelo_microbioma()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/ajustar_modelo_microbioma.md)
  [`fit_saem_microbiome()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/ajustar_modelo_microbioma.md)
  : Ajustar un modelo SAEM de microbioma (ZIBR o ZIBBMR) desde un data
  frame

## Ajuste por taxon

- [`fit_zibr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr_taxon.md)
  : Ajustar ZIBR para un taxon de un data frame
- [`fit_zibr_taxa()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr_taxa.md)
  : Ajustar ZIBR para varios taxones de un data frame
- [`fit_zibbmr_taxon()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr_taxon.md)
  : Ajustar ZIBBMR para un taxon de un data frame
- [`fit_zibbmr_taxa()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr_taxa.md)
  : Ajustar ZIBBMR para varios taxones de un data frame

## Simulacion de datos

- [`simulate_zibr_data()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/simulate_zibr_data.md)
  : Simular datos longitudinales para un modelo ZIBR
- [`simulate_zibbmr_data()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/simulate_zibbmr_data.md)
  : Simular datos longitudinales de conteo para un modelo ZIBBMR
- [`simular_datos_microbioma()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/simular_datos_microbioma.md)
  : Simular un conjunto de datos de microbioma con varios taxones

## Comparacion de modelos (LRT)

- [`lrt_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibr.md)
  : Prueba de razon de verosimilitudes entre dos ajustes ZIBR anidados
- [`lrt_zibr_table()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibr_table.md)
  : Tabla de pruebas de razon de verosimilitudes para varios taxones
  ZIBR
- [`zibr_results_table()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/zibr_results_table.md)
  : Tabla resumen de tres comparaciones LRT tipicas para ZIBR
- [`lrt_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibbmr.md)
  : Prueba de razon de verosimilitudes entre dos ajustes ZIBBMR anidados
- [`lrt_zibbmr_table()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/lrt_zibbmr_table.md)
  : Tabla de pruebas de razon de verosimilitudes para varios taxones
  ZIBBMR
- [`zibbmr_results_table()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/zibbmr_results_table.md)
  : Tabla resumen de tres comparaciones LRT tipicas para ZIBBMR

## Metodos S3

- [`print(`*`<zibr_saem>`*`)`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/print.zibr_saem.md)
  : Imprimir un ajuste ZIBR
- [`plot(`*`<zibr_saem>`*`)`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/plot.zibr_saem.md)
  : Graficos de un ajuste ZIBR
- [`coef(`*`<zibr_saem>`*`)`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/coef.zibr_saem.md)
  : Coeficientes estimados de un ajuste ZIBR
- [`vcov(`*`<zibr_saem>`*`)`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/vcov.zibr_saem.md)
  : Matriz de varianza-covarianza de un ajuste ZIBR
- [`logLik(`*`<zibr_saem>`*`)`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/logLik.zibr_saem.md)
  : Log-verosimilitud marginal de un ajuste ZIBR
- [`print(`*`<zibbmr_saem>`*`)`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/print.zibbmr_saem.md)
  : Imprimir un ajuste ZIBBMR
- [`plot(`*`<zibbmr_saem>`*`)`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/plot.zibbmr_saem.md)
  : Graficos de un ajuste ZIBBMR
- [`coef(`*`<zibbmr_saem>`*`)`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/coef.zibbmr_saem.md)
  : Coeficientes estimados de un ajuste ZIBBMR
- [`vcov(`*`<zibbmr_saem>`*`)`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/vcov.zibbmr_saem.md)
  : Matriz de varianza-covarianza de un ajuste ZIBBMR
- [`logLik(`*`<zibbmr_saem>`*`)`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/logLik.zibbmr_saem.md)
  : Log-verosimilitud marginal de un ajuste ZIBBMR
- [`se()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/se.md)
  : Errores estandar de un ajuste SAEM

## Preparacion de datos

- [`prepare_romero_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/prepare_romero_zibr.md)
  : Preparar datos tipo Romero para ZIBR
- [`prepare_romero_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/prepare_romero_zibbmr.md)
  : Preparar datos tipo Romero para ZIBBMR

## Compatibilidad historica

Alias con la firma de los scripts originales de John Barrera.

- [`saem_zibr_clean()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/saem_zibr_clean.md)
  : Alias historico de fit_zibr con la firma del codigo original de
  Barrera
- [`sim_zibr_data_clean()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/sim_zibr_data_clean.md)
  : Alias historico de simulate_zibr_data con la firma del codigo
  original
- [`saem_zibbmr_clean()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/saem_zibbmr_clean.md)
  : Alias historico de fit_zibbmr con la firma del codigo original de
  Barrera
- [`sim_zibbmr_data_clean()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/sim_zibbmr_data_clean.md)
  : Alias historico de simulate_zibbmr_data con la firma del codigo
  original
