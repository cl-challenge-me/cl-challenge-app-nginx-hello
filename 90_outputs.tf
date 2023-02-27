output "convenience_message" {
  value       = "The application should be available here:\n\n  https://${module.cloud-ep-dns.endpoint}\n"
  description = "Convenience message"
}