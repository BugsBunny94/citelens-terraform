resource "random_password" "database_password" {
  length  = 16
  special = true
}

resource "google_sql_database_instance" "postgres_instance" {
  name             = "my-datatabe"
  database_version = "POSTGRES_17"
  region           = local.region

  settings {
    edition = "ENTERPRISE"
    tier = "db-custom-1-3840"

    backup_configuration {
      enabled = true
    }
  }
}

resource "google_sql_database" "database" {
  name     = "my-datatabe"
  instance = google_sql_database_instance.postgres_instance.name
}

resource "google_sql_user" "database_user" {
  name     = "citelens"
  instance = google_sql_database_instance.postgres_instance.name
  password = random_password.database_password.result
}

resource "google_secret_manager_secret" "database_password_secret" {
  secret_id = "my-database-password"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "database_password_version" {
  secret = google_secret_manager_secret.database_password_secret.name
  secret_data = random_password.database_password.result
}

output "database_instance_connection_name" {
  value = google_sql_database_instance.postgres_instance.connection_name
}

output "database_user" {
  value = google_sql_user.database_user.name
}

output "secret_name" {
  value = google_secret_manager_secret.database_password_secret.name
}