library(Rcpp)
library(zoo)
library(rbenchmark)

myrollmean <- cppFunction('
  NumericVector myrollmean( NumericVector x, double width) {
    double temp = 0;
    unsigned int n = x.size(), i, counter = 0;
    NumericVector out(n - width + 1);
    
    for(i = 0; i < width; i++) {
      temp += x[i];
    }
    
    out[0] = temp / width;
    counter += 1;
    
    for( i = width; i < n; i++ ) {
      temp = temp - x[i - width] + x[i];
      out[counter] = temp / width;
      counter += 1;
    }
    
    return out;
  }')


vec <- 1:10000
width <- 1000


res_r <- rollmean(vec, width)
res_c <- myrollmean(vec, width)

identical(res_r, res_c)

res <- benchmark("r" = rollmean(vec, width),
                 "c" = myrollmean(vec, width),
                 replications = 1000,
                 columns = c("test", "replications", "relative", "elapsed", "user.self", "sys.self"))
res
