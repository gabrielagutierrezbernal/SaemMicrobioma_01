# Bitacora de cambios - paquete saemMicrobiome

Registro ordenado y detallado de los avances realizados sobre el
paquete, desde la versión inicial hasta el estado actual. Cada bloque
corresponde a una etapa de trabajo. El identificador entre parentesis
(p. ej. `ca0a2d2`) es el “commit” de git: el sello único que marca ese
cambio en el historial y permite recuperar el código tal como estaba en
ese punto (`git show <id>`).

Referencias complementarias: - `NEWS.md`: los mismos cambios en el
formato estandar de un paquete R. - `estudios/`: scripts de validación y
comparación que respaldan lo de abajo.

------------------------------------------------------------------------

## Etapa 0 - Punto de partida

- **Versión inicial del paquete** (`ca0a2d2`). El código de los modelos
  ZIBR y ZIBBMR (basado en el trabajo de John Barrera) reunido como un
  primer paquete R: los archivos `R/zibr.R`, `R/zibbmr.R`,
  `R/modelo_madre.R` y `R/simulacion.R`.

## Etapa 1 - Formalización del paquete

- **Estructura y metadatos** (`f8a26af`). Configuración de `.gitignore`
  y `.Rbuildignore` (para no versionar ni empaquetar archivos
  temporales) y `DESCRIPTION` completo (version, dependencias, enlaces
  del proyecto).
- **API publica y documentación** (`ae192bb`). Se definió que funciones
  expone el paquete (`fit_zibr`, `fit_zibbmr`, etc.) y se documentaron
  con roxygen2 (las fichas de ayuda `?funcion`). Se consolidó en
  `R/utils.R` código común a ZIBR y ZIBBMR.
- **Pruebas automaticas** (`733e7f4`). Tests con `testthat` que
  verifican el funcionamiento del paquete y que los resultados se
  mantengan estables.
- **README, vignette, sitio web y CI** (`7e6165e`). Manual de inicio
  (README), guia introductoria (vignette), sitio de documentación
  (pkgdown) e integración continua en GitHub Actions (instala y prueba
  el paquete de forma automatica en cada cambio).
- **Consolidacion adicional** (`692f76b`). Se unificaron funciones
  comunes a los dos modelos (métodos S3, comparación de modelos),
  manteniendo los resultados numericos.
- **Atribución y cobertura de tests** (`b16482f`). Se registró a John
  Barrera como autor original en el `DESCRIPTION` y se amplió la
  cobertura de pruebas.
- **Función “madre” más completa** (`77a00b4`).
  [`ajustar_modelo_microbioma()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/ajustar_modelo_microbioma.md)/
  [`fit_saem_microbiome()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/ajustar_modelo_microbioma.md)
  pasaron a admitir covariables separadas para cada parte del modelo,
  generar valores iniciales razonables y validar los datos de entrada.

## Etapa 2 - Optimización de rendimiento

- **Optimización en R puro** (`9b9e368`). Sin cambiar la lógica
  estadística (resultados byte-identicos), se optimizaron las
  operaciones internas del loop SAEM (agrupación por sujeto y formas
  cuadraticas). Resultado: ~2.3x más rápido que la versión inicial.
- **Núcleo en C++/Rcpp** (`849450b`, `c4d5190`). Se incorporó un
  componente en C++ para el cálculo del predictor lineal del motor SAEM,
  manteniendo los resultados byte-identicos.

## Etapa 3 - Validación y estudios

- **Ejemplos más mantenibles** (`4a8c392`). El número de observaciones
  se deriva de `n_subjects * n_time`, para cambiar el tamaño de muestra
  en un solo lugar.
- **Carpeta `estudios/`** (`b25c394`, `12f3611`). Material de validación
  reproducible para ZIBR y ZIBBMR:
  - Comparación contra el código original de John Barrera: ambos
    producen resultados identicos.
  - Estudio de simulación: al aumentar el número de sujetos, los
    estimados se acercan al valor verdadero y su error disminuye.
  - Chequeo de sensibilidad a la semilla: cuanto depende el resultado
    del azar del algoritmo y como se reduce con más cadenas MCMC.

## Etapa 4 - Comparación de tiempos

- **Comparación de estimación y tiempos** (`c4d5190`, `1998817`). Se
  creó `estudios/comparacion_tiempos/` con la tabla y los scripts que
  comparan, sobre el mismo conjunto de datos, el codigo de John y las
  distintas versiones del paquete. Resultado: las cuatro versiones
  **estiman exactamente lo mismo** (byte-identico), con estos tiempos de
  computo:

  | Version           | Tiempo |
  |-------------------|--------|
  | John (original)   | 11.1 s |
  | Version inicial   | 8.0 s  |
  | Optimizacion en R | 3.4 s  |
  | Con nucleo en C++ | 3.4 s  |

## Etapa 5 - Graficos y diagnosticos

- **Graficos del ajuste** (inspirados en `saemix`). El metodo
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) de ambos
  modelos ofrece, via el argumento `which`, cinco graficos: convergencia
  del algoritmo, coeficientes con intervalo de confianza, distribucion
  de los efectos aleatorios por sujeto, observados vs. predichos y
  residuos (estos dos ultimos sobre la parte continua). El ajuste guarda
  ademas los datos originales para poder calcularlos. Documentado en
  `estudios/graficos/`.
- **Ejemplos que estiman cerca de la verdad.** Los ejemplos del README y
  de la vignette se ajustaron para usar un tamano de muestra suficiente
  (300 sujetos, 500 iteraciones), de modo que los estimados quedan cerca
  de los valores verdaderos de la simulacion y
  [`se()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/se.md)
  devuelve errores estandar validos.

## Etapa 6 - Covarianza de los efectos aleatorios

- **Estimacion de la correlacion entre las dos partes del modelo**
  (parche de Cristian Meza). El paso M del SAEM estima la matriz de
  covarianza completa, pero tres calculos internos la trataban como
  diagonal, lo que impedia estimar la correlacion entre el efecto
  aleatorio de la parte de inflacion de ceros y el de la parte de
  abundancia. Se corrige y se agrega el argumento `cov_random` a
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md)/[`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md):
  `"diag"` (por defecto, la especificacion del articulo) o
  `"unstructured"` (estima tambien la covarianza, algo que ni `glmmTMB`
  ni `gamlss` pueden representar). Con `"diag"` los resultados no
  cambian materialmente. Es una capacidad relevante para la revision del
  paper de ZIBBMR.

------------------------------------------------------------------------

## Estado actual

- Paquete funcional, documentado, con 118 pruebas automaticas que pasan
  y `R CMD check` sin errores, warnings ni notas.
- Reproduce el codigo original de John Barrera.
- Optimizado (~2.3x más rapido que la versión inicial) sin alterar los
  resultados.
- Cinco graficos de diagnostico/resultado por ajuste, inspirados en
  `saemix`.
- Permite estimar la covarianza entre los efectos aleatorios de las dos
  partes del modelo (`cov_random = "unstructured"`).
- Publicado en
  <https://github.com/gabrielagutierrezbernal/SaemMicrobioma_01> con
  sitio de documentación e integración continua activos.
