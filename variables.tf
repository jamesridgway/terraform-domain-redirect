variable "source_domains" {
	type = "list"
	description = "List of source domains"
}
variable "destination_address" {
  type = "string"
  description = "Destination address (including protocol and host e.g. https://www.example.com)"
}