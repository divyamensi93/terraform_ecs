output "ecr_urls" {
  value = data.null_data_source.ecr_urls.*.outputs
}
