% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/browse_cxg.R
\name{browse_cxg}
\alias{browse_cxg}
\title{simple shiny browser that works with the portal \code{db} components
to present titles of collections and datasets and facilitate
selection and conversion of cellxgene resources}
\usage{
browse_cxg()
}
\value{
list, possibly empty, of SingleCellExperiment instances, obtained on
interactive selections using \code{files_download()}
}
\description{
simple shiny browser that works with the portal \code{db} components
to present titles of collections and datasets and facilitate
selection and conversion of cellxgene resources
}
\examples{
if (interactive()) sel = browse_cxg()
}
