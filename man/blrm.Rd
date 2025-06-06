% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/blrm.r
\name{blrm}
\alias{blrm}
\title{Bayesian Binary and Ordinal Logistic Regression}
\usage{
blrm(
  formula,
  ppo = NULL,
  cppo = NULL,
  data = environment(formula),
  subset,
  na.action = na.delete,
  priorsdppo = rep(100, pppo),
  iprior = 0,
  conc = 1/(0.8 + 0.35 * max(k, 3)),
  ascale = 1,
  psigma = 1,
  rsdmean = if (psigma == 1) 0 else 1,
  rsdsd = 1,
  normcppo = FALSE,
  pcontrast = NULL,
  npcontrast = NULL,
  backend = c("rstan", "cmdstan"),
  iter = 2000,
  warmup = iter/2,
  chains = 4,
  refresh = 0,
  progress = if (refresh > 0) "stan-progress.txt" else "",
  x = TRUE,
  y = TRUE,
  loo = n <= 1000,
  ppairs = NULL,
  method = c("both", "sampling", "optimizing"),
  inito = if (length(ppo)) 0 else "random",
  inits = inito,
  standata = FALSE,
  file = NULL,
  debug = FALSE,
  sampling.args = NULL,
  showopt = FALSE,
  ...
)
}
\arguments{
\item{formula}{a R formula object that can use \code{rms} package enhancements such as the restricted interaction operator}

\item{ppo}{formula specifying the model predictors for which proportional odds is not assumed}

\item{cppo}{a function that if present causes a constrained partial PO model to be fit.  The function specifies the values in the Gamma vector in Peterson and Harrell (1990) equation (6).  Sometimes to make posterior sampling better behaved, the function should be scaled and centered.  This is done by wrapping \code{cppo} in a function that scales the \code{cppo} result before returning the vector value, when \code{normcppo} is \code{TRUE}. The default normalization is based on the mean and standard deviation of the function values over the distribution of observed Y.  For getting predicted values and estimates post-\code{\link[=blrm]{blrm()}}, \code{cppo} must not reference any functions that are not available at such later times.}

\item{data}{a data frame; defaults to using objects from the calling environment}

\item{subset}{a logical vector or integer subscript vector specifying which subset of data whould be used}

\item{na.action}{default is \code{na.delete} to remove missings and report on them}

\item{priorsdppo}{vector of prior standard deviations for non-proportional odds parameters.  The last element is the only one for which the SD corresponds to the original data scale.  This only applies to the unconstrained PPO model.}

\item{iprior}{specifies whether to use a Dirichlet distribution for the cell probabilities, which induce a more complex prior distribution for the intercepts (\code{iprior=0}, the default), non-informative priors (\code{iprior=1}) directly on the intercept parameters,  or to directly use a t-distribution with 3 d.f. and scale parameter \code{ascale} (\code{iprior=2}).}

\item{conc}{the Dirichlet distribution concentration parameter for the prior distribution of cell probabilities at covariate means.  The default is the reciprocal of 0.8 + 0.35 max(k, 3) where k is the number of Y categories.  The default is chosen to make the posterior mean of the intercepts more closely match the MLE.  For optimizing, the concentration parameter is always 1.0 when \code{iprior=0} to obtain results very close to the MLE for providing the posterior mode.}

\item{ascale}{scale parameter for the t-distribution for priors for the intercepts if \code{iprior=2}, defaulting to 1.0}

\item{psigma}{defaults to 1 for a half-t distribution with 4 d.f., location parameter \code{rsdmean} and scale parameter \code{rsdsd}.  Set \code{psigma=2} to use the exponential distribution.}

\item{rsdmean}{the assumed mean of the prior distribution of the standard deviation of random effects.  When \code{psigma=2} this is the mean of an exponential distribution and defaults to 1.  When \code{psigma=1} this is the mean of the half-t distribution and defaults to zero.}

\item{rsdsd}{applies only to \code{psigma=1} and is the scale parameter for the half t distribution for the SD of random effects, defaulting to 1.}

\item{normcppo}{set to \code{TRUE} to modify the \code{cppo} function automatically centering and scaling the result}

\item{pcontrast}{a list specifying contrasts that are to be given Gaussian prior distributions.  The predictor combinations specified in \code{pcontrast} are run through \code{\link[rms:gendata]{rms::gendata()}} so that contrasts are specified in units of original variables, and unspecified variables are set to medians or modes as saved by \code{\link[rms:datadist]{rms::datadist()}}.  Thanks to \code{Stan}, putting priors on combinations and transformations of model parameters has the same effect of putting different priors on the original parameters without figuring out how to do that.  The syntax used here allows specification of differences, double differences (e.g., interactions or nonlinearity), triple differences (e.g., to put contraints on nonlinear interactions), etc.  The requested predictor combinations must be named so they may be referred to inside \code{contrast}.  The syntax is \code{pcontrast=list(..., contrast=expression(...), mu=, sd=, weights=, expand=)}.  \code{...} denotes one or more \code{list()}s with predictor combinations, and each \code{list()} must be named, e.g., \code{pcontrast=list(c1=list(sex='female'), c2=list(sex='male'))} to set up for a \code{female - male} contrast specified as \code{contrast=expression(c1 - c2)}.  The \code{c1 - c2} subtraction will operate on the design matrices generated by the covariate settings in the \code{list()}s.  For \verb{weights, expand} see \code{\link[rms:Xcontrast]{rms::Xcontrast()}} and \code{\link[rms:contrast]{rms::contrast.rms()}}.  \code{mu} is a vector of prior means associated with the rows of the stacked contrasts, and \code{sd} is a corresponding vector of Gaussian prior SDs.  When \code{mu} is not given it defaults to 0.0, and \code{sd} defaults to 100.0.  Values of \code{mu} and/or \code{sd} are repeated to the number of contrasts if they are of length 1.  Full examples are given \href{https://hbiostat.org/rmsc/genreg#bayes}{here}.}

\item{npcontrast}{like \code{pcontrast} but applies to the non-proportional odds submodel in \code{ppo}.  Priors for the amount of departure from proportional odds are isolated from the priors of the "main effects" in \code{formula}.  The mean and standard deviation for the non-PO contrasts are on the scale of Z*tau before \code{cppo} is applied.  If \code{cppo} picks off a single condition, i.e., death is the highest level of Y and you want a special effect of treatment on death, then \code{cppo} will be something like \code{function(y) y == 4} and the contrast prior will be on the scale of the additional treatment effect for death.  If \code{cppo} is more of a continuous function you will have to take into account the values of that function when figuring the prior mean and SD.  For example, if y ranges from 10-90 and \code{cppo} is \code{sqrt(y)}, and you want to specify a prior on the log odds ratio for y=10 vs. y=90 you'll need to divide the prior standard deviation in \code{npcontrast} by \code{sqrt(90) - sqrt(10)}.}

\item{backend}{set to \code{cmdstan} to use \code{cmdstan} through the R \code{cmdstanr} package instead of the default \code{rstan}.  You can also specify this with a global option \code{rmsb.backend}.}

\item{iter}{number of posterior samples per chain for \code{\link[rstan:stanmodel-method-sampling]{rstan::sampling()}} to run, counting warmups}

\item{warmup}{number of warmup iterations to discard.  Default is \code{iter}/2.}

\item{chains}{number of separate chains to run}

\item{refresh}{see \code{\link[rstan:stanmodel-method-sampling]{rstan::sampling()}} and \code{\link[cmdstanr:model-method-sample]{cmdstanr::sample()}}.  The default is 0, indicating that no progress notes are output.  If \code{refresh > 0} and \code{progress} is not \code{''}, progress output will be appended to file \code{progress}.  The default file name is \code{'stan-progress.txt'}.}

\item{progress}{see \code{refresh}.  Defaults to \code{''} if \code{refresh = 0}.  Note: If running interactively but not under RStudio, \code{rstan} will open a browser window for monitoring progress.}

\item{x}{set to \code{FALSE} to not store the design matrix in the fit.  \code{x=TRUE} is needed if running \code{blrmStats} for example.}

\item{y}{set to \code{FALSE} to not store the response variable in the fit}

\item{loo}{set to \code{FALSE} to not run \code{loo} and store its result as object \code{loo} in the returned object.  \code{loo} defaults to \code{FALSE} if the sample size is greater than 1000, as \code{loo} requires the per-observation likelihood components, which creates a matrix N times the number of posterior draws.}

\item{ppairs}{set to a file name to run \code{rstan} \code{pairs} or, if \code{backend='cmdstan'} \code{bayesplot::mcmc_pairs} and store the resulting png plot there.  Set to \code{TRUE} instead to directly plot these diagnostics.  The default is not to run pair plots.}

\item{method}{set to \code{'optimizing'} to run the Stan optimizer and not do posterior sampling, \code{'both'} (the default) to run both the optimizer and posterior sampling, or \code{'sampling'} to run only the posterior sampling and not compute posterior modes. Running \code{optimizing} is a way to obtain maximum likelihood estimates and allows one to quickly study the effect of changing the prior distributions.  When \code{method='optimizing'} is used the result returned is not a standard \code{\link[=blrm]{blrm()}} object but is instead the parameter estimates, -2 log likelihood, and optionally the Hession matrix (if you specify \code{hessian=TRUE} in ...; not available with \code{cmdstan}).  When \code{method='both'} is used, \code{\link[rstan:stanmodel-method-sampling]{rstan::sampling()}} and \code{\link[rstan:stanmodel-method-optimizing]{rstan::optimizing()}} are both run, and parameter estimates (posterior modes) from \code{optimizing} are stored in a matrix \code{param} in the fit object, which also contains the posterior means and medians, and other results from \code{optimizing} are stored in object \code{opt} in the \code{\link[=blrm]{blrm()}} fit object.  When random effects are present, \code{method} is automatically set to \code{'sampling'} as maximum likelihood estimates without marginalizing over the random effects do not make sense.  When you specify \code{method='optimizing'} specify \verb{iprior=} to get regular MLEs in which no prior is put on the intercepts.}

\item{inito}{intial value for optimization.  The default is the \code{rstan} default \code{'random'}.  Frequently specifying \code{init=0} will benefit when the number of distinct Y categories grows or when using \code{ppo} hence 0 is the default for that.}

\item{inits}{initial value for sampling, defaults to \code{inito}}

\item{standata}{set to \code{TRUE} to return the Stan data list and not run the model}

\item{file}{a file name for a \code{saveRDS}-created file containing or to contain the saved fit object.  If \code{file} is specified and the file does not exist, it will be created right before the fit object is returned, less the large \code{rstan} object.  If the file already exists, its stored \code{md5} hash string \code{datahash} fit object component is retrieved and compared to that of the current \code{rstan} inputs.  If the data to be sent to \code{rstan}, the priors, and all sampling and optimization options and stan code are identical, the previously stored fit object is immediately returned and no new calculatons are done.}

\item{debug}{set to \code{TRUE} to output timing and progress information to /tmp/debug.txt}

\item{sampling.args}{a list containing parameters to pass to \code{\link[rstan:stanmodel-method-sampling]{rstan::sampling()}} or to the \code{rcmdstan} \code{sample} function, other than these arguments: \verb{iter, warmup, chains, refresh, init} which are already arguments to \code{blrm}.  A good use of this is \code{sampling.args=list(seed=3)} to get reproducible sampling.}

\item{showopt}{set to \code{TRUE} to show Stan optimizer output}

\item{...}{passed to \code{\link[rstan:stanmodel-method-optimizing]{rstan::optimizing()}} or the \code{rcmdstan} optimizing function.  \code{sampling.args} is usually used instead.}
}
\value{
an \code{rms} fit object of class \code{blrm}, \code{rmsb}, \code{rms} that also contains \code{rstan} or \code{cmdstanr} results under the name \code{rstan}.  In the \code{rstan} results, which are also used to produce diagnostics, the intercepts are shifted because of the centering of columns of the design matrix done by \code{\link[=blrm]{blrm()}}.  With \code{method='optimizing'} a class-less list is return with these elements: \code{coefficients} (MLEs), \code{beta} (non-intercept parameters on the QR decomposition scale), \code{deviance} (-2 log likelihood), \code{return_code} (see \code{\link[rstan:stanmodel-method-optimizing]{rstan::optimizing()}}), and, if you specified \code{hessian=TRUE} to \code{\link[=blrm]{blrm()}}, the Hessian matrix.  To learn about the scaling of orthogonalized QR design matrix columns, look at the \code{xqrsd} object in the returned object.  This is the vector of SDs for all the columns of the transformed matrix.  The returned element \code{sampling_time} is the elapsed time for running posterior samplers, in seconds.  This will be just a little more than the time for running one CPU core for one chain.
}
\description{
Uses \code{rstan} with pre-compiled Stan code, or \code{cmdstan} to get posterior draws of parameters from a binary logistic or proportional odds semiparametric ordinal logistic model.  The Stan code internally using the qr decompositon on the design matrix so that highly collinear columns of the matrix do not hinder the posterior sampling.  The parameters are transformed back to the original scale before returning results to R.   Design matrix columns are centered before running Stan, so Stan diagnostic output will have the intercept terms shifted but the results of \code{\link[=blrm]{blrm()}} for intercepts are for the original uncentered data.  The only prior distributions for regression betas are normal with mean zero.  Priors are specified on contrasts so that they can be specified on a meaningful scale and so that more complex patterns can be imposed.  Parameters that are not involved in any contrasts in \code{pcontrast} or \code{npcontrast} have non-informative priors.  Contrasts are automatically converted to the QR space used in Stan code.
}
\details{
The partial proportional odds model of Peterson and Harrell (1990) is implemented, and is invoked when the user specifies a second model formula as the \code{ppo} argument.  This formula has no left-hand-side variable, and has right-side variables that are a subset of those in \code{formula} specifying for which predictors the proportional odds assumption is relaxed.

The Peterson and Harrell (1990) constrained partial proportional odds is also implemented, and is usually preferred to the above unconstrained PPO model as it adds a vector of coefficients instead of a matrix of coefficients.  In the constrained PPO model the user provides a function \code{cppo} that computes a score for all observed values of the dependent variable.  For example with a discrete ordinal outcome \code{cppo} may return a value of 1.0 for a specific value of Y and zero otherwise.  That will result in a departure from the proportional odds assumption for just that one level of Y.  The value returned by \code{cppo} at the lowest Y value is never used in any case.

\code{\link[=blrm]{blrm()}} also handles single-level hierarchical random effects models for the case when there are repeated measurements per subject which are reflected as random intercepts, and a different experimental model that allows for AR(1) serial correlation within subject.  For both setups, a \code{cluster} term in the model signals the existence of subject-specific random effects.

When using the \code{cmdstan} backend, \code{cmdstanr} will need to compile the Stan code once per computer, only recompiling the code when the Stan source code changes.  By default the compiled code is stored in directory \code{.rmsb} under your home directory.  Specify \code{options(rmsbdir=)} to specify a different location.  You should specify \code{rmsbdir} to be in a project-specific location if you want to archive code for old projects.

If you want to run MCMC sampling even when no inputs or Stan code have changed, i.e., to use a different random number seed for the sampling process when you did not specify \code{sampling.args(seed=...)}, remove the \code{file} before running \code{blrm}.

Set \code{options(rmsbmsg=FALSE)} to suppress certain information messages.

See \href{https://hbiostat.org/R/examples/blrm/blrm.html}{here} and \href{https://hbiostat.org/R/examples/blrm/blrmc.html}{here} for multiple examples with results.
}
\examples{
\dontrun{
  getHdata(titanic3)
  dd <- datadist(titanic3); options(datadist='dd')
  f <- blrm(survived ~ (rcs(age, 5) + sex + pclass)^2, data=titanic3)
  f                   # model summary using print.blrm
  coef(f)             # compute posterior mean parameter values
  coef(f, 'median')   # compute posterior median values
  stanDx(f)           # print basic Stan diagnostics
  s <- stanGet(f)     # extract rstan object from fit
  plot(s, pars=f$betas)       # Stan posteriors for beta parameters
  stanDxplot(s)       # Stan diagnostic plots by chain
  blrmStats(f)        # more details about predictive accuracy measures
  ggplot(Predict(...))   # standard rms output
  summary(f, ...)     # invokes summary.rms
  contrast(f, ...)    # contrast.rms computes HPD intervals
  plot(nomogram(f, ...)) # plot nomogram using posterior mean parameters

  # Fit a random effects model to handle multiple observations per
  # subject ID using cmdstan
  # options(rmsb.backend='cmdstan')
  f <- blrm(outcome ~ rcs(age, 5) + sex + cluster(id), data=mydata)
}
}
\seealso{
\code{\link[=print.blrm]{print.blrm()}}, \code{\link[=blrmStats]{blrmStats()}}, \code{\link[=stanDx]{stanDx()}}, \code{\link[=stanGet]{stanGet()}}, \code{\link[=coef.rmsb]{coef.rmsb()}}, \code{\link[=vcov.rmsb]{vcov.rmsb()}}, \code{\link[=print.rmsb]{print.rmsb()}}, \code{\link[=coef.rmsb]{coef.rmsb()}}
}
\author{
Frank Harrell and Ben Goodrich
}
