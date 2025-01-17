#' @importFrom dplyr bind_rows mutate arrange desc
.db <-
    function(overwrite)
{
    path <- .cellxgene_cache_get(
        .COLLECTIONS, "collections", overwrite = overwrite
    )
    readLines(path) |>
        parse_json(simplifyVector = TRUE) |>
        bind_rows()
}

.db_detail <-
    function(id)
{
    ## called in parallel; be sure to return a result & check for errors
    tryCatch({
        uri <- paste0(.COLLECTIONS, id)
        path <- .cellxgene_cache_get(uri)
        readLines(path)
    }, error = identity)
}

#' @importFrom curl nslookup
.db_online <-
    function()
{
    response <- nslookup(.CELLXGENE_PRODUCTION_HOST, error = FALSE)
    !is.null(response)
}

#' @importFrom parallel mclapply
#' @rdname db
#' @title Retrieve updated cellxgene database metadata
#'
#' @details The database is retrieved from the cellxgene data portal
#'     web site. 'collections' metadata are retrieved on each call;
#'     metadata on each collection is cached locally for re-use.
#'
#' @param overwrite logical(1) indicating whether the database of
#'     collections should be updated from the internet (the default,
#'     when internet is available), or read from disk (assuming
#'     previous successful access to the internet). `overwrite =
#'     FALSE` might be useful for reproducibility, testing, or when
#'     working in an environment with restricted internet access.
#'
#' @examples
#' db()
#'
#' @export
db <-
    function(overwrite = .db_online())
{
    stopifnot(
        .is_scalar_logical(overwrite)
    )

    db <- .db(overwrite)
    details <- mclapply(db$id, .db_detail)
    errors <- vapply(details, inherits, logical(1), "error")
    if (any(errors)) {
        stop(
            sum(errors), " error(s) updating database; first error:\n",
            "  ", conditionMessage(details[[head(which(errors), 1L)]])
        )
    }
    details <- sprintf("[%s]", paste(details, collapse=","))

    class(details) <- c("cellxgene_db", class(details))
    details
}

#' @importFrom utils head
#'
#' @export
print.cellxgene_db <-
    function(x, ...)
{
    cat(
        head(class(x), 1L), "\n",
        "number of collections(): ", jmespath(x, "length([])"), "\n",
        "number of datasets(): ", jmespath(x, "length([].datasets[])"), "\n",
        "number of files(): ",
        jmespath(x, "length([].datasets[].dataset_assets[])"), "\n",
        sep = ""
    )
}
