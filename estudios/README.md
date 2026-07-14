# Estudios de validación

Esta carpeta contiene material de validación del paquete `saemMicrobiome`. No
forma parte del código del paquete (esta excluida del build via `.Rbuildignore`);
son scripts reproducibles para respaldar dos afirmaciones:

1. **El paquete reproduce exactamente el código original de John Barrera.**
2. **El método es estadisticamente correcto (consistente):** con más sujetos,
   los estimados se acercan al valor verdadero y su error disminuye.

Hay una carpeta por modelo: `zibr/` (proporciones) y `zibbmr/` (conteos con
profundidad de secuenciacion). Cada una tiene los mismos tres estudios. Además,
`comparacion_tiempos/` compara la estimación y los tiempos de cómputo entre el
código de John y las distintas versiónes del paquete (sin optimizar, con la
optimización en R puro, y con C++).

## `01_comparacion_john_vs_paquete.R`

Corre el código **original de John** (descargado en vivo de su GitHub, sin
modificar) y el paquete sobre **los mismos datos**, y compara los estimados.

Resultado esperado: los dos coinciden hasta la precisión numerica de la máquina
(diferencia < 1e-8), lo que prueba que el paquete es una implementación fiel del
método, no una versión alterada.

Notas:
- Se llama a la función de John con argumentos **por nombre**, porque John
  agregó el parametro `zi` en dic-2025 y su ejemplo posicional comentado quedó
  desactualizado.
- Para ZIBBMR, el archivo de John tiene un parentesis sobrante (error de tipeo)
  y un bloque de ejemplos roto al final; el script los corrige automaticamente
  al descargarlo, **sin tocar la lógica del método**.

## `02_estudio_simulación.R`

Estudio de simulación: repite el ajuste sobre muchos datasets simulados
(`n_rep = 30` por defecto) para tres tamaños de muestra (30, 100 y 300 sujetos),
con valores verdaderos conocidos. Imprime el promedio y la desviación estándar
de los estimados por tamaño, y guarda un gráfico de cajas
(`estudio_simulación_<modelo>.png`).

Lectura del gráfico: la linea roja punteada es el valor verdadero. Al subir el
número de sujetos, la caja (a) se estrecha -el error disminuye- y (b) se centra
en la línea roja -el estimador apunta al valor correcto-. Es la demostración de
que el "ruido" con pocos sujetos es un efecto de tamaño de muestra, no un
problema del código.

Los gráficos ya generados estan guardados como `estudio_simulación_zibr.png` y
`estudio_simulación_zibbmr.png`.

La semilla del ajuste varia por replica (`seed = r`), de modo que cada
repetición es una muestra independiente que incluye tanto el ruido de los
datos como el ruido de Monte Carlo del algoritmo.

## `03_chequeo_semilla.R`

El algoritmo SAEM es estocastico: dado un mismo conjunto de datos, el
resultado depende de la semilla del ajuste (el camino aleatorio de las cadenas
MCMC). Este script toma UN dataset fijo y lo ajusta con 20 semillas distintas,
para cuantificar cuanto varia el resultado por ese azar (ruido de Monte Carlo)
y mostrar que ese ruido se reduce al usar más cadenas MCMC (`n_chains`).

Imprime la desviación estándar de los estimados entre semillas para
`n_chains = 5` y `n_chains = 15`, y guarda un gráfico
(`chequeo_semilla_<modelo>.png`). Conclusión típica: al triplicar el número de
cadenas (5 -> 15), la desviación entre semillas se reduce aproximadamente a la
mitad.
Es decir: para reportar estimados estables conviene usar suficientes cadenas
(e iteraciones), no una sola semilla puntual.

## Como correrlos

Con el paquete instalado, desde R:

```r
source("estudios/zibr/01_comparacion_john_vs_paquete.R")   # ~40 seg
source("estudios/zibr/02_estudio_simulación.R")            # ~3 min
source("estudios/zibr/03_chequeo_semilla.R")               # ~2 min
source("estudios/zibbmr/01_comparacion_john_vs_paquete.R") # ~40 seg
source("estudios/zibbmr/02_estudio_simulación.R")          # ~3.5 min
source("estudios/zibbmr/03_chequeo_semilla.R")             # ~2 min
```

Los estudios de comparación requieren conexión a internet (descargan el código
de John) y los paquetes `boot`, `numDeriv` y `MASS`.
