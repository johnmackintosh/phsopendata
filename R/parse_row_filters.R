#' Create JSON 'dict' from named list or vector
#' @description Formats a list or named vector into a valid query
#' @param row_filters list or named vectors matching fields to values
#' @return a json as a character string
#' @keywords internal
#' @noRd
parse_row_filters <- function(row_filters) {
  # exit function if no filters
  if (is.null(row_filters)) {
    return(NULL)
  }

  # Check if `row_filters` is a list or a character or numeric vector
  if (class(row_filters) != "list" && !is.character(row_filters) && !is.numeric(row_filters)) {
    cli::cli_abort(
      "{.arg row_filters} must be a named {.cls list} or a named
      {.cls character} or {.cls numeric} vector, not a {.cls {class(row_filters)}}."
    )
  }

  # Ensure it's elements are named
  if (is.null(names(row_filters)) || any(names(row_filters) == "")) {
    cli::cli_abort("{.arg row_filters} should be a named {.cls list}.")
  }

  # check if any filters in list have length > 1
  too_many <- purrr::map_lgl(row_filters, ~ length(.x) > 1)

  if (any(too_many)) {
    cli::cli_abort(c(
      "Invalid input for {.arg row_filters}",
      i = "The {.val {names(row_filters)[which(too_many)]}} filter{?s} {?has/have} too many values.",
      x = "The {.arg row_filters} list must only contain vectors of length 1."
    ))
  }

  # check if any items in the list/vector are duplicates
  duplicates <- duplicated(names(row_filters))
  if (any(duplicates)) {
    cli::cli_abort(c(
      "Invalid input for {.arg row_filters}",
      x = "The {.val {names(row_filters)[which(duplicates)]}} filter{?s} {?is/are} duplicated.",
      i = "Only one filter per field is currently supported by {.fun get_resource}."
    ))
  }

  filter_body <- paste0(
    '"', names(row_filters), '":"', row_filters, '"',
    collapse = ","
  )

  return(
    paste0("{", filter_body, "}")
  )
}
