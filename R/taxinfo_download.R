#' Download taxonomic data
#' 
#' @author Atlas of Living Australia \email{support@@ala.org.au}
#' @references \url{http://api.ala.org.au/}
#' 
#' @param query string: (optional) query of the form field:value (e.g. "genus:Macropus") or a free text search ("Alaba vibex")
#' @param fq string: character string or vector of strings, specifying filters to be applied to the original query. 
#' These are of the form "INDEXEDFIELD:VALUE" e.g. "kingdom:Fungi". See \code{ala_fields("general")} for all the 
#' fields that are queryable. NOTE that fq matches are case-sensitive, but sometimes the entries in the fields are 
#' not consistent in terms of case (e.g. kingdom names "Fungi" and "Plantae" but "ANIMALIA"). fq matches are ANDed 
#' by default (e.g. c("field1:abc","field2:def") will match records that have field1 value "abc" and field2 value "def"). 
#' To obtain OR behaviour, use the form c("field1:abc OR field2:def")
#' @param fields string vector: (optional) a vector of field names to return. Note that the columns of the returned data 
#' frame are not guaranteed to retain the ordering of the field names given here. If not specified, a default list of 
#' fields will be returned. See \code{ala_fields("general")} for valid field names
#' @param verbose logical: show additional progress information? [default is set by ala_config()]
#' @param use_data_table logical: if TRUE, attempt to read the data.csv file using the fread function from the 
#' data.table package. Requires data.table to be available. If this fails, or use_data_table is FALSE, then read.table 
#' will be used (which may be slower)
#' @return data frame of results, containing one row per taxon, typically with name, guid, and taxonomic information. The columns returned will depend on the field requested
#' @seealso \code{\link{ala_fields}}, \code{\link{ala_config}}
#' @examples
#' \dontrun{
#' # Download data for Fabaceae
#' x=taxinfo_download("family:Fabaceae",fields=c("guid","parentGuid","kingdom","phylum","class","bioOrder","family","genus","nameComplete"))
#' ## note that requesting "nameComplete" gives the scientific name but requesting "scientificName" will not --- bug to be fixed in ALA's web service
#' # equivalent direct URL: http://bie.ala.org.au/ws/download?fields=guid,parentGuid,kingdom,phylum,class,bioOrder,family,genus,nameComplete&q=family:Fabaceae
#' }
#' @export taxinfo_download

# see issue #754 for the scientific name / name complete issue

taxinfo_download=function(query,fq,fields,verbose=ala_config()$verbose,use_data_table=TRUE) {
    assert_that(is.flag(use_data_table))
    base_url=paste(ala_config()$base_url_bie,"download",sep="")
    this_query=list()
    ## have we specified a query?
    if (!missing(query)) {
        assert_that(is.string(query))
        this_query$q=query
    }
    if (length(this_query)==0) {
        ## not a valid request!
        stop("invalid request: query must be specified")
    }
    if (!missing(fq)) {
        assert_that(is.character(fq))
        ## can have multiple fq parameters, need to specify in url as fq=a:b&fq=c:d&fq=...
        check_fq(fq,type="general") ## check that fq fields are valid
        fq=as.list(fq)
        names(fq)=rep("fq",length(fq))
        this_query=c(this_query,fq)
    }
    if (!missing(fields)) {
        assert_that(is.character(fields))
        ## user has specified some fields
        valid_fields=ala_fields(fields_type="general")
        unknown=setdiff(fields,valid_fields$name)
        if (length(unknown)>0) {
            stop("invalid fields requested: ", str_c(unknown,collapse=", "), ". See ala_fields(\"general\")")
        }
        this_query$fields=str_c(fields,collapse=",")
    }
    
    this_url=parse_url(base_url)
    this_url$query=this_query
    
    ## these downloads can potentially be large, so we want to download directly to file and then read the file
    thisfile=cached_get(url=build_url(this_url),type="binary_filename",verbose=verbose)

    if (!(file.info(thisfile)$size>0)) {
        ## empty file
        x=NULL
    } else {
        ## if data.table is available, first try using this
        read_ok=FALSE
        if (use_data_table & is.element('data.table', installed.packages()[,1])) { ## if data.table package is available
            require(data.table) ## load it
            tryCatch({
                x=fread(thisfile,stringsAsFactors=FALSE,header=TRUE,verbose=verbose)
                ## make sure names of x are valid, as per data.table
                setnames(x,make.names(names(x)))
                ## now coerce it back to data.frame (for now at least, unless we decide to not do this!)
                x=as.data.frame(x)
                if (!empty(x)) {
                    ## convert column data types
                    ## ALA supplies *all* values as quoted text, even numeric, and they appear here as character type
                    ## we will convert whatever looks like numeric or logical to those classes
                    x=colwise(convert_dt)(x)
                }
                read_ok=TRUE
            }, error=function(e) {
                warning("ALA4R: reading of csv as data.table failed, will fall back to read.table (may be slow). The error message was: ",e)
                read_ok=FALSE
            })
        }
        if (!read_ok) {
            x=read.table(thisfile,sep=",",header=TRUE,comment.char="",as.is=TRUE)
            if (!empty(x)) {
                ## convert column data types
                ## read.table handles quoted numerics but not quoted logicals
                x=colwise(convert_dt)(x,test_numeric=FALSE)
            }
        }

        if (empty(x)) {
            if (ala_config()$warn_on_empty) {
                warning("no matching records were returned")
            }
        } else {
            xcols=setdiff(names(x),unwanted_columns(type="general"))
            x=subset(x,select=xcols)
            names(x)=rename_variables(names(x),type="general")
        }
    }
    #class(x) <- c('taxinfo_download',class(x)) #add the custom class
    x
}
        
