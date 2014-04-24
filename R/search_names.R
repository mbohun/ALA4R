#' Lookup of taxonomic names
#' 
#' Provides GUID, taxonomic classification, and other information for a list of names. 
#' Case-insensitive but otherwise exact matches are used.
#' 
#' @author Atlas of Living Australia \email{support@@ala.org.au}
#' @references \url{http://api.ala.org.au/}
#' 
#' @param taxa string: a single name or vector of names
#' @param vernacular logical: if TRUE, match on common names as well as scientific names, otherwise match only on scientific names
#' @param guids_only logical: if TRUE, only return a named list of GUIDs
#' @return A data frame of results, or named list of GUIDs if guid_only is TRUE

#' @examples
#' 
#' search_names(c("Grevillea humilis","Grevillea humilis subsp. maritima","Macropus","Thisisnot aname"))
#' search_names(c("Grevillea humilis","Grevillea humilis subsp. maritima","Macropus","Thisisnot aname"),guids_only=TRUE)
#' search_names("Grevillea",vernacular=FALSE) ## should return the genus Grevillea
#' search_names("Grevillea",vernacular=TRUE) ## should return the species Grevillea banksii, because it has the common name ``Grevillea"
#' x=search_names("Alaba",vernacular=FALSE) ## should return info on the genus "Alaba"
#' str(x) ## tidy list of Alaba details
#' 
#' 
#' @export search_names

# TODO: Should #occurrences be returned to help identification?

# service currently gives an error for single-word all-lower-case names (issue #649)

search_names=function(taxa=c(),vernacular=FALSE,guids_only=FALSE) {
    ## input argument checks
    if (identical(class(taxa),"list")) {
        taxa=unlist(taxa)
    }
    assert_that(is.character(taxa))
    if (any(nchar(taxa)<1)) {
        stop("input contains empty string")
    }
    if (length(taxa)<1) {
        stop("empty input")
    }
    assert_that(is.flag(vernacular))
    taxa_original=taxa
    taxa = sapply(taxa,clean_string,USE.NAMES=FALSE) ## clean up the taxon name
    taxa=toupper(taxa) ## to avoid errors with all-lower-case single-word names
    ## re-check names, since clean_string may have changed them
    if (any(nchar(taxa)<1)) {
        stop("input contains empty string after cleaning (did the input name contain only non-alphabetic characters?)")
    }    
    base_url=paste(ala_config()$base_url_bie,"species/lookup/bulk",sep="")
    temp=jsonlite::toJSON(list(names=taxa,vernacular=vernacular))
    ## toJSON puts vernacular as a single-element array, which causes failures.
    temp=str_replace(temp,"\\[[ ]*false[ ]*\\]","false")
    temp=str_replace(temp,"\\[[ ]*true[ ]*\\]","true")
    x=cached_post(url=base_url,body=temp,type="json")
    if (guids_only) {
        if (nrow(x)>0) {
            x=as.list(x$guid)
            names(x)=make.names(taxa_original)
        } else {
            x=list()
        }
    }
    x
}