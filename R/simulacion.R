simular_datos_microbioma <- function(n_ind = 8, n_time = 3, n_taxa = 5,
                                     N = 1000, seed = 123) {
  set.seed(seed)
  
  n <- n_ind * n_time
  taxa <- paste0("Taxon", seq_len(n_taxa))
  
  conteos <- matrix(0, nrow = n, ncol = n_taxa)
  
  for (i in seq_len(n)) {
    p <- rgamma(n_taxa, shape = 1.2, rate = 1)
    p <- p / sum(p)
    
    conteos[i, ] <- as.vector(rmultinom(1, size = N, prob = p))
  }
  
  colnames(conteos) <- taxa
  
  datos_conteo <- data.frame(
    id = rep(seq_len(n_ind), each = n_time),
    tiempo = rep(seq_len(n_time), times = n_ind),
    grupo = rep(rep(c(0, 1), length.out = n_ind), each = n_time),
    N = N,
    conteos,
    check.names = FALSE
  )
  
  datos_proporcion <- datos_conteo
  datos_proporcion[, taxa] <- datos_conteo[, taxa] / rowSums(datos_conteo[, taxa])
  
  list(
    conteo = datos_conteo,
    proporcion = datos_proporcion,
    taxa = taxa
  )
}