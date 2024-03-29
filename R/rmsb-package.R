#' The 'rmsb' package.
#'
#' @description Regression Modeling Strategies Bayesian
#'
#' The \pkg{rmsb} package is an appendage to the \pkg{rms} package that
#' implements Bayesian regression models whose fit objects can be processed
#' by \pkg{rms} functions such as \code{contrast, summary, Predict, nomogram},
#' and \code{latex}.  The fitting function
#' currently implemented in the package is \code{blrm} for Bayesian logistic
#' binary and ordinal regression with optional clustering, censoring, and
#' departures from the proportional odds assumption using the partial
#' proportional odds model of Peterson and Harrell (1990).
#' @name rmsb-package
#' @aliases rmsb
#' @useDynLib rmsb, .registration = TRUE
#' @import methods
#' @import Rcpp
#' @import rms
#' @import Hmisc
#' @import ggplot2
#' @importFrom rstan sampling optimizing
#' @importFrom grDevices contourLines dev.off gray png
#' @importFrom graphics abline hist pairs par
#' @importFrom stats approx coef cor density lowess median model.extract model.matrix plogis predict quantile sd var
#'
#' @references
#' Stan Development Team (2020). RStan: the R interface to Stan. R package version 2.19.3. https://mc-stan.org
#'
#' @seealso
#' \itemize{
#'   \item \url{https://hbiostat.org/R/rmsb/} for the package's main web page
#'   \item \url{https://hbiostat.org/R/examples/blrm/blrm.html} for a vignette with
#'       many examples of using the \code{blrm} function
#' }
#'
NULL
