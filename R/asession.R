##    archivist package for R
##
#' @title Show Artifact's Session Info
#'
#' @description
#' \code{asession} extracts artifact's session info. This allows to check in what conditions 
#' the artifact was created.
#' 
#' @param md5hash One of the following (see \link{aread}):
#' 
#' A character vector which elements  are consisting of at least three components separated with '/': Remote user name, Remote repository and name of the artifact (MD5 hash) or it's abbreviation.
#' 
#' MD5 hashes of artifacts in current local default directory or its abbreviations.
#' 
#' @return An object of the class \code{session_info}.
#' 
#' @author 
#' Przemyslaw Biecek, \email{przemyslaw.biecek@@gmail.com}
#' 
#' @note 
#' Bug reports and feature requests can be sent to \href{https://github.com/pbiecek/archivist/issues}{https://github.com/pbiecek/archivist/issues}
#' 
#' @examples
#' \dontrun{
#' setLocalRepo(system.file("graphGallery", package = "archivist"))
#' asession("2a6e492cb6982f230e48cf46023e2e4f")
#' 
#' # no session info
#' asession("pbiecek/graphGallery/2a6e492cb6982f230e48cf46023e2e4f")
#' # nice session info
#' asession("pbiecek/graphGallery/f05f0ed0662fe01850ec1b928830ef32")
#' }
#' @family archivist
#' @rdname asession
#' @export

asession <- function( md5hash = NULL) {
  elements <- strsplit(md5hash, "/")[[1]]
  stopifnot( length(elements) >= 3 | length(elements) == 1)
  if (is.url(md5hash)) {
    tags <- getTagsRemoteByUrl(tail(elements,1), 
                               paste(elements[-length(elements)], collapse="/"), 
                               tag = "")
  
    tagss <- grep(tags, pattern="^session_info:", value = TRUE)

    if (length(tagss) == 0) {
      warning(paste0("No session info archived for ", md5hash))
      return(NA)
    }
    return(loadFromLocalRepo(gsub(tagss[1], pattern = "^session_info:", replacement = ""), 
                             repoDir = paste(elements[-length(elements)], collapse="/"),
                             value = TRUE))
  } else {
    if (length(elements) == 1) {
      # local directory
      tags <- getTagsLocal(md5hash, tag = "")
      tagss <- grep(tags, pattern="^session_info:", value = TRUE)
      if (length(tagss) == 0) {
        warning(paste0("No session info archived for ", md5hash))
        return(NA)
      }
      return(loadFromLocalRepo(gsub(tagss[1], pattern = "^session_info:", replacement = ""), value = TRUE))
    } else {
      # Remote directory
      tags <- getTagsRemote(tail(elements,1), repo = elements[2],
                            subdir = ifelse(length(elements) > 3, paste(elements[3:(length(elements)-1)], collapse="/"), "/"),
                            user = elements[1], tag = "")
      tagss <- grep(tags, pattern="^session_info:", value = TRUE)
      if (length(tagss) == 0) {
        warning(paste0("No session info archived for ", md5hash))
        return(NA)
      }
      return(loadFromRemoteRepo(gsub(tagss[1], pattern = "^session_info:", replacement = ""), 
                                repo = elements[2],
                                subdir = ifelse(length(elements) > 3, paste(elements[3:(length(elements)-1)], collapse="/"), "/"),
                                user = elements[1],
                                value = TRUE))
    }
  }
}
