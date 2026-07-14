# Comparacion de estimacion y tiempos de computo

Compara, sobre **el mismo conjunto de datos**, cuatro versiones del codigo:

1. **John (original):** el codigo de John Barrera, sin modificar.
2. **v0 - sin optimizar:** la primera version del paquete, antes de cualquier
   optimizacion de rendimiento (commit `77a00b4`).
3. **Fase 1 - optimizacion en R puro:** commit `9b9e368`.
4. **Fase 2 - con C++ (Rcpp):** version final (byte-identica a las anteriores).

Objetivo doble: (a) verificar que **todas estiman lo mismo** y (b) comparar los
**tiempos de computo**.

## Condiciones del benchmark

- Datos: 150 sujetos x 4 tiempos (600 observaciones), una covariable de grupo
  binaria. Se comparan los dos modelos: **ZIBR** (proporciones) y **ZIBBMR**
  (conteos, con profundidad de secuenciacion S = 1000).
- Ajuste: `iter = 300`, `ncad = 5` (5 cadenas), `seed = 232`, valores
  iniciales `v0 = 10`, `a0 = c(-0.2, 0.1)`, `b0 = c(0.1, 0.1)`.
- Tiempo = mediana de varias corridas, misma maquina, cada version instalada
  del mismo modo (`R CMD INSTALL`) y medida via `library()`.

## Resultados - ZIBR (proporciones)

### ¿Estiman lo mismo?

Si. Las cuatro versiones producen estimados **byte-identicos** (coinciden hasta
el ultimo decimal, ~10 cifras significativas):

| Parametro | Valor estimado (identico en las 4 versiones) |
|-----------|----------------------------------------------|
| alpha (intercepto) | -0.4360474219 |
| alpha (grupo)      |  0.6793310611 |
| beta (intercepto)  |  0.1497290626 |
| beta (grupo)       | -0.3844309790 |
| phi                | 12.5052837900 |
| log-verosimilitud  | -257.5439760000 |

### Tiempos de computo

| Version | Tiempo (mediana) | Aceleracion vs sin optimizar |
|---------|------------------|------------------------------|
| John (original)              | 11.10 s | referencia |
| v0 - sin optimizar           |  8.01 s | 1.0x |
| Fase 1 - R puro              |  3.45 s | **2.3x** |
| Fase 2 - con C++ (Rcpp)      |  3.38 s | 2.4x |

## Resultados - ZIBBMR (conteos)

### ¿Estiman lo mismo?

Si, tambien byte-identicos entre las cuatro versiones:

| Parametro | Valor estimado (identico en las 4 versiones) |
|-----------|----------------------------------------------|
| alpha (intercepto) | -0.3968228 |
| alpha (grupo)      |  0.5467545 |
| beta (intercepto)  |  0.1875829 |
| beta (grupo)       | -0.3809879 |
| phi                | 13.8987700 |
| log-verosimilitud  | -2218.608 |

### Tiempos de computo

| Version | Tiempo (mediana) | Aceleracion vs sin optimizar |
|---------|------------------|------------------------------|
| John (original)              | 12.57 s | referencia |
| v0 - sin optimizar           |  8.47 s | 1.0x |
| Fase 1 - R puro              |  3.78 s | **2.2x** |
| Fase 2 - con C++ (Rcpp)      |  3.78 s | 2.2x |

(Nota: John siempre calcula ademas la matriz de informacion de Fisher, que en
el paquete se puede omitir con `compute_fim = FALSE`; parte de su mayor tiempo
se debe a ese paso extra.)

## Interpretacion

- **Todas las versiones estiman exactamente lo mismo.** Las optimizaciones son
  puramente de rendimiento: no cambian la logica estadistica ni los resultados.
- **El grueso de la aceleracion (2.3x) proviene de la Fase 1, en R puro.** Se
  logro reemplazando patrones interpretados lentos del loop SAEM: `tapply()`
  por `rowsum()` (evitando reconstruir el agrupamiento por sujeto en cada
  iteracion) y las formas cuadraticas `diag(d %*% G_inv %*% t(d))` -que
  construian una matriz completa (n_subjects*n_chains)^2 solo para tomar la
  diagonal- por la identidad `rowSums((d %*% G_inv) * d)`.
- **La Fase 2 (C++) mantiene los resultados byte-identicos pero no acelera de
  forma apreciable.** El motivo es que las operaciones restantes (`plogis`,
  productos de matrices, `rowSums`) R ya las ejecuta en C compilado; C++ solo
  aporta cuando reemplaza loops interpretados de R, que es lo que ya habia
  hecho la Fase 1. Es un resultado honesto y esperable: el codigo en R puro
  ya estaba cerca del optimo para este tipo de operaciones.
- **El patron es el mismo en los dos modelos** (ZIBR y ZIBBMR): ~2.2-2.3x mas
  rapido gracias a la Fase 1, sin cambiar ningun resultado. Es esperable,
  porque las optimizaciones estan en las mismas funciones internas compartidas
  por ambos modelos.

## Reproducir

Comparacion John vs version ACTUAL (verifica que estiman lo mismo y mide sus
tiempos; se puede correr desde cualquier carpeta con el paquete instalado):

- `benchmark_tiempos_zibr.R` (modelo ZIBR)
- `benchmark_tiempos_zibbmr.R` (modelo ZIBBMR)

Versiones HISTORICAS del paquete (v0 y Fase 1). DEBEN ejecutarse desde la raiz
del repositorio (necesitan git y compilador) porque instalan cada commit y lo
miden en un proceso R separado. Correr en la misma sesion no sirve: R no
permite tener dos versiones del mismo paquete cargadas a la vez, y daria
tiempos falsos (todos iguales a la version actual):

- `benchmark_historico_zibr.R` (modelo ZIBR)
- `benchmark_historico_zibbmr.R` (modelo ZIBBMR)
