# saemMicrobiome: modelos SAEM para microbioma longitudinal

Herramientas para ajustar, simular y comparar modelos mixtos con
inflacion de ceros para datos longitudinales de microbioma:

## Details

- **ZIBR** (zero-inflated beta regression), para proporciones o
  abundancias relativas: ver
  [`fit_zibr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibr.md).

- **ZIBBMR** (zero-inflated beta-binomial mixed regression), para
  conteos con profundidad de secuenciacion conocida: ver
  [`fit_zibbmr()`](https://gabrielagutierrezbernal.github.io/SaemMicrobioma_01/reference/fit_zibbmr.md).

Ambos se estiman con el algoritmo Stochastic Approximation EM (SAEM),
siguiendo la metodologia desarrollada por John Barrera.

## See also

Useful links:

- <https://github.com/gabrielagutierrezbernal/SaemMicrobioma_01>

- Report bugs at
  <https://github.com/gabrielagutierrezbernal/SaemMicrobioma_01/issues>

## Author

**Maintainer**: Gabriela Gutierrez
<gabriella.gutierrez.bernal@gmail.com>

Authors:

- Gabriela Gutierrez <gabriella.gutierrez.bernal@gmail.com>
