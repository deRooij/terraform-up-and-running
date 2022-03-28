output "address" {
    value = aws_db_instance.example-db.address
    description = "Connect to the database at this endpoint"
}

output "db_port" {
    value = aws_db_instance.example-db.port
    description = "The port the database is listening on"
}