\name{ala_cache_filename}
\alias{ala_cache_filename}
\title{Returns the name of the cache file associated with the given URL. Note that this file
may not actually exist, this function just provides the mapping from URL to filename}
\usage{
ala_cache_filename(url)
}
\arguments{
  \item{url}{string: the URL}
}
\value{
string: the file path and name
}
\description{
Returns the name of the cache file associated with the
given URL. Note that this file may not actually exist, this
function just provides the mapping from URL to filename
}
\examples{
ala_cache_filename("http://biocache.ala.org.au/ws/index/fields")
}
\author{
Atlas of Living Australia \email{support@ala.org.au}
}
\references{
\url{http://api.ala.org.au/}
}
\seealso{
\code{ala_config} for cache settings, particularly the
cache directory
}

