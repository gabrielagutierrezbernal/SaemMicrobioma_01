# Estudios de validacion

Esta carpeta contiene material de validacion del paquete `saemMicrobiome`. No
forma parte del codigo del paquete (esta excluida del build via `.Rbuildignore`);
son scripts reproducibles para respaldar dos afirmaciones:

1. **El paquete reproduce exactamente el codigo original de John Barrera.**
2. **El metodo es estadisticamente correcto (consistente):** con mas sujetos,
   los estimados se acercan al valor verdadero y su error disminuye.

Hay una carpeta por modelo: `zibr/` (proporciones) y `zibbmr/` (conteos con
profundidad de secuenciacion). Cada una tiene los mismos dos estudios.

## `01_comparacion_john_vs_paquete.R`

Corre el codigo **original de John** (descargado en vivo de su GitHub, sin
modificar) y el paquete sobre **los mismos datos**, y compara los estimados.

Resultado esperado: los dos coinciden hasta la precision numerica de la maquina
(diferencia < 1e-8), lo que prueba que el paquete es una implementacion fiel del
metodo, no una version alterada.

Notas:
- Se llama a la funcion de John con argumentos **por nombre**, porque John
  agrego el parametro `zi` en dic-2025 y su ejemplo posicional comentado quedo
  desactualizado.
- Para ZIBBMR, el archivo de John tiene un parentesis sobrante (error de tipeo)
  y un bloque de ejemplos roto al final; el script los corrige automaticamente
  al descargarlo, **sin tocar la logica del metodo**.

## `02_estudio_simulacion.R`

Estudio de simulacion: repite el ajuste sobre muchos datasets simulados
(`n_rep = 30` por defecto) para tres tamanos de muestra (30, 100 y 300 sujetos),
con valores verdaderos conocidos. Imprime el promedio y la desviacion estandar
de los estimados por tamano, y guarda un grafico de cajas
(`estudio_simulacion_<modelo>.png`).

Lectura del grafico: la linea roja punteada es el valor verdadero. Al subir el
numero de sujetos, la caja (a) se estrecha -el error disminuye- y (b) se centra
en la linea roja -el estimador apunta al valor correcto-. Es la demostracion de
que el "ruido" con pocos sujetos es un efecto de tamano de muestra, no un
problema del codigo.

Los graficos ya generados estan guardados como `estudio_simulacion_zibr.png` y
`estudio_simulacion_zibbmr.png`.

La semilla del ajuste varia por replica (`seed = r`), de modo que cada
repeticion es una muestra independiente que incluye tanto el ruido de los
datos como el ruido de Monte Carlo del algoritmo.

## `03_chequeo_semilla.R`

El algoritmo SAEM es estocastico: dado un mismo conjunto de datos, el
resultado depende de la semilla del ajuste (el camino aleatorio de las cadenas
MCMC). Este script toma UN dataset fijo y lo ajusta con 20 semillas distintas,
para cuantificar cuanto varia el resultado por ese azar (ruido de Monte Carlo)
y mostrar que ese ruido se reduce al usar mas cadenas MCMC (`n_chains`).

Imprime la desviacion estandar de los estimados entre semillas para
`n_chains = 5` y `n_chains = 15`, y guarda un grafico
(`chequeo_semilla_<modelo>.png`). Conclusion tipica: al triplicar el numero de
cadenas (5 -> 15), la desviacion entre semillas se reduce aproximadamente a la
mitad, coherente con un error de Monte Carlo proporcional a 1/raiz(n_chains).
Es decir: para reportar estimados estables conviene usar suficientes cadenas
(e iteraciones), no una sola semilla puntual.

## Como correrlos

Con el paquete instalado, desde R:

```r
source("estudios/zibr/01_comparacion_john_vs_paquete.R")   # ~40 seg
source("estudios/zibr/02_estudio_simulacion.R")            # ~3 min
source("estudios/zibr/03_chequeo_semilla.R")               # ~2 min
source("estudios/zibbmr/01_comparacion_john_vs_paquete.R") # ~40 seg
source("estudios/zibbmr/02_estudio_simulacion.R")          # ~3.5 min
source("estudios/zibbmr/03_chequeo_semilla.R")             # ~2 min
```

Los estudios de comparacion requieren conexion a internet (descargan el codigo
de John) y los paquetes `boot`, `numDeriv` y `MASS`.
