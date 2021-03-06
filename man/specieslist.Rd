\name{specieslist}
\alias{specieslist}
\title{Get list of taxa and their occurrence counts}
\usage{
specieslist(taxon, wkt, fq)
}
\arguments{
  \item{taxon}{string: Text of taxon, e.g. "Macropus rufus"
  or "macropodidae"}

  \item{wkt}{string: WKT (well-known text) defining a
  polygon within which to limit taxon search, e.g.
  "POLYGON((140 -37,151 -37,151 -26,140 -26,140 -37))"}

  \item{fq}{string: character string or vector of strings,
  specifying filters to be applied to the original query.
  These are of the form "INDEXEDFIELD:VALUE" e.g.
  "kingdom:Fungi". See \code{ala_fields("occurrence")} for
  all the fields that are queryable. NOTE that fq matches
  are case-sensitive, but sometimes the entries in the
  fields are not consistent in terms of case (e.g. kingdom
  names "Fungi" and "Plantae" but "ANIMALIA"). fq matches
  are ANDed by default (e.g. c("field1:abc","field2:def")
  will match records that have field1 value "abc" and
  field2 value "def"). To obtain OR behaviour, use the form
  c("field1:abc OR field2:def")}
}
\value{
data frame of results, where each row is a taxon, its
classification information, and its occurrence count
}
\description{
Retrieve a list of taxa matching a search query, within a
spatial search area, or both
}
\examples{
\dontrun{
x=specieslist(taxon="macropus",wkt="POLYGON((145 -37,150 -37,150 -30,145 -30,145 -37))")

x=specieslist(wkt="POLYGON((147.62 -42.83,147.60 -42.86,147.65 -42.87,147.70 -42.86,147.62 -42.83))",fq="rank:species")
}
}
\author{
Atlas of Living Australia \email{support@ala.org.au}
}
\references{
\url{http://api.ala.org.au/}
\url{http://www.geoapi.org/3.0/javadoc/org/opengis/referencing/doc-files/WKT.html}
}
\seealso{
\code{\link{ala_fields}} for occurrence fields that are
queryable via the \code{fq} parameter
}

