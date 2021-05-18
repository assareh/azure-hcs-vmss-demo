"acl" = {
  "default_policy" = "deny"

  "down_policy" = "async-cache"

  "enabled" = true

  "tokens" = {
    "agent" = "${acl_token}"
  }
}

"auto_encrypt" = {
  "tls" = true
}

"bind_addr" = "{{ GetInterfaceIP \"eth0\" }}"

"ca_file" = "/etc/consul.d/ca.pem"

"data_dir" = "/opt/consul/data"

"datacenter" = "dc1"

"enable_syslog" = true

"encrypt" = "2A+8UGYrGqxEnq2MV6tONQ=="

"log_level" = "INFO"

"retry_join" = ["${consul_addr}"]

"server" = false

"verify_outgoing" = true

"enable_local_script_checks" = true