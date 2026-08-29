test_that("standardize_normative works", {
  set.seed(123)

  hc_data <- matrix(
    rnorm(100 * 10),
    nrow = 100,
    ncol = 10
  )

  new_data <- matrix(
    rnorm(10 * 10),
    nrow = 10,
    ncol = 10
  )

  colnames(hc_data) <- paste0("test", 1:10)
  colnames(new_data) <- colnames(hc_data)

  result <- standardize_normative(hc_data, new_data)

  expect_equal(dim(result$hc_z), c(100, 10))
  expect_equal(dim(result$new_z), c(10, 10))
  expect_equal(result$variables, colnames(hc_data))
})
