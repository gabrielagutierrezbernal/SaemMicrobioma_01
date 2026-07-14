# Bitacora de cambios - paquete saemMicrobiome

Registro ordenado y detallado de todo el trabajo realizado sobre el paquete,
desde la version inicial hasta el estado actual. Cada bloque corresponde a una
etapa de trabajo, con su fecha. El identificador entre parentesis (p. ej.
`ca0a2d2`) es el "commit" de git: el sello unico que marca ese cambio en el
historial y permite recuperar el codigo exactamente como estaba en ese momento
(`git show <id>` o `git log`).

Referencias complementarias:
- `NEWS.md`: los mismos cambios en el formato estandar de un paquete R.
- `git log --oneline`: el registro tecnico automatico de cada commit.
- `estudios/`: scripts de validacion y comparacion que respaldan lo de abajo.

---

## Etapa 0 - Punto de partida (2026-06-10)

- **Version inicial del paquete** (`ca0a2d2`, `e7539ef`). El codigo de los
  modelos ZIBR y ZIBBMR (basado en el trabajo de John Barrera) reunido como un
  primer paquete R: los archivos `R/zibr.R`, `R/zibbmr.R`, `R/modelo_madre.R` y
  `R/simulacion.R`. Funcionaba, pero sin documentacion, sin pruebas, sin
  control de que funciones eran publicas, y con codigo duplicado entre modelos.

## Etapa 1 - Formalizacion del paquete (2026-07-05 a 2026-07-06)

- **Limpieza inicial** (`f8a26af`). Se configuro `.gitignore` y `.Rbuildignore`
  (para no versionar ni empaquetar archivos temporales) y se completo el
  `DESCRIPTION` (metadatos: version, dependencias reales, enlaces).
- **API publica y documentacion** (`ae192bb`). Se definio que funciones expone
  el paquete (`fit_zibr`, `fit_zibbmr`, etc.) y se documentaron con roxygen2
  (las fichas de ayuda `?funcion`). Se consolido en `R/utils.R` codigo que
  estaba duplicado entre ZIBR y ZIBBMR.
- **Pruebas automaticas** (`733e7f4`). Se agregaron tests con `testthat` que
  verifican que el paquete funciona y que los resultados no cambian sin querer.
- **README, vignette, sitio web y CI** (`7e6165e`). Manual de inicio (README),
  guia introductoria (vignette), sitio de documentacion (pkgdown) e
  integracion continua en GitHub Actions (que instala y prueba el paquete solo
  en cada cambio).
- **Reconciliacion e arreglo de CI** (`82bd4cb`, `635c22b`). Se unifico el
  historial con el repositorio remoto y se arreglo la instalacion de la
  dependencia `NBZIMM` (que no esta en CRAN) para que la CI pasara.
- **Segunda pasada de limpieza** (`692f76b`). Se consolidaron 11 funciones mas
  que estaban duplicadas entre los dos modelos (metodos S3, comparacion de
  modelos). Verificado: los resultados numericos no cambian.
- **Atribucion y mas tests** (`b16482f`). Se agrego a John Barrera como autor
  original en el `DESCRIPTION`, se actualizo `NEWS.md` y se amplio la cobertura
  de tests de 66 a 85 pruebas.
- **Funcion "madre" mas robusta** (`77a00b4`). `ajustar_modelo_microbioma()`/
  `fit_saem_microbiome()` pasaron a admitir covariables separadas, generar
  valores iniciales razonables y validar los datos; se corrigio un error con
  `zi = FALSE`.

## Etapa 2 - Optimizacion de rendimiento (2026-07-08)

- **Fase 1: optimizacion en R puro** (`9b9e368`). Sin cambiar la logica
  estadistica (resultados byte-identicos): se reemplazaron patrones lentos del
  loop SAEM (`tapply` por `rowsum`; una matriz gigante innecesaria por una
  identidad equivalente). Resultado: ~2.3x mas rapido.
- **Fase 2: C++/Rcpp** (`849450b`, luego corregido en `c4d5190`). Se llevo a
  C++ la funcion interna mas llamada. (Ver nota en Etapa 4: al medir con rigor
  se comprobo que esta fase, hecha byte-identica, no acelera de forma
  apreciable sobre la Fase 1; el grueso de la mejora vino de la Fase 1.)

## Etapa 3 - Validacion y estudios (2026-07-12)

- **Ejemplos mas mantenibles** (`4a8c392`). En los ejemplos, el numero de
  observaciones se deriva de `n_subjects * n_time`, para no tener que cambiarlo
  en varios lugares al modificar el tamano de muestra.
- **Carpeta `estudios/`** (`b25c394`). Material de validacion reproducible para
  ZIBR y ZIBBMR: comparacion contra el codigo original de John (resultan
  identicos) y estudio de simulacion (a mas sujetos, mejor estimacion).
- **Redaccion neutral** (`b7b23cd`). Se ajustaron comentarios para que esten en
  una voz de autor consistente.
- **Semilla y chequeo de estabilidad** (`12f3611`). En el estudio de
  simulacion la semilla del ajuste varia por replica; se agrego un estudio que
  mide cuanto depende el resultado de la semilla (y como se reduce con mas
  cadenas MCMC).

## Etapa 4 - Correccion honesta del C++ y comparacion de tiempos (2026-07-12 a 2026-07-14)

- **Correccion del C++ y benchmark honesto** (`c4d5190`). Al medir con rigor se
  detecto que la primera version del C++ estaba mal (era mas lenta que el R
  puro). Se reescribio para que sea byte-identica y ya no lenta, y se
  documento honestamente que el C++ no acelera de forma apreciable: el gran
  salto (~2.3x) fue la Fase 1 en R puro. Se agrego `estudios/comparacion_tiempos/`
  con la tabla y la metodologia.
- **Benchmark historico correcto** (`1998817`). Se corrigio el script que media
  las versiones historicas (v0, Fase 1): ahora corre cada version en un proceso
  R separado, la unica forma fiable (R no permite dos versiones del mismo
  paquete en una sesion). Numeros verificados: v0 = 8.0s, Fase 1 = 3.4s,
  actual = 3.4s, John (original) = 11.1s; las cuatro estiman lo mismo.

---

## Estado actual

- Paquete funcional, documentado, con 93 pruebas automaticas que pasan y
  `R CMD check` sin errores/warnings/notas.
- Verificado que reproduce exactamente el codigo original de John Barrera.
- Optimizado (~2.3x mas rapido que la version inicial) sin alterar ningun
  resultado.
- Publicado en https://github.com/gabrielagutierrezbernal/SaemMicrobioma_01
  con sitio de documentacion e integracion continua activos.
