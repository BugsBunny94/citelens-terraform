resource "google_certificate_manager_certificate" "citelens_frontend_ssl_certificate" {
  name = "citelens-frontend-ssl-certificate"

  self_managed {
    pem_certificate = file("citelens_com.crt")
    pem_private_key = file("myserver.key")
  }
}
