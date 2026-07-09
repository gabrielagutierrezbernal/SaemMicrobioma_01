#include <Rcpp.h>
using namespace Rcpp;

// Version compilada de .saem_linear_prob(): calcula el predictor lineal
// logistico por observacion y le aplica plogis(). Es la funcion mas llamada
// del motor SAEM (~6 veces por iteracion). Fusiona en un solo recorrido el
// "gather" de filas de psi por sujeto-cadena (id), el producto por la matriz
// de diseno y la suma por fila, evitando materializar las matrices
// intermedias que creaba la version en R puro.
//
// Es deterministica (no usa RNG) y usa R::plogis(), la MISMA rutina que
// stats::plogis() en R, de modo que el resultado es identico al ultimo bit.
//
// psi:    matriz (n_subjects*n_chains) x n_psi con los efectos por sujeto-cadena
// cols:   indices de columna de psi a usar (base 1, como en R)
// id:     indice de fila de psi para cada observacion (base 1, longitud M)
// design: matriz M x length(cols) con las covariables (incluye intercepto)
//
// [[Rcpp::export]]
NumericVector saem_linear_prob_cpp(NumericMatrix psi,
                                   IntegerVector cols,
                                   IntegerVector id,
                                   NumericMatrix design) {
  const int m = design.nrow();
  const int k = cols.size();
  NumericVector out(m);

  // indices base 0
  std::vector<int> col0(k);
  for (int j = 0; j < k; ++j) col0[j] = cols[j] - 1;

  for (int i = 0; i < m; ++i) {
    const int row = id[i] - 1;
    double eta = 0.0;
    for (int j = 0; j < k; ++j) {
      eta += psi(row, col0[j]) * design(i, j);
    }
    // R::plogis(x, location, scale, lower_tail, log_p): misma rutina que
    // stats::plogis(), numericamente estable en las colas.
    out[i] = R::plogis(eta, 0.0, 1.0, 1, 0);
  }

  return out;
}
