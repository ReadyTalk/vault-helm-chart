path "auth/approle/role/my-app-role/role-id" {
  capabilities = ["read"]
}

path "auth/approle/role/my-app-role/secret-id" {
  capabilities = ["update"]
}
