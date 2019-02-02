type = "controller";
bind_socket = "*:11334";
password = "{{.Env.RSPAMD_PASSWORD}}";
secure_ip = "{{.Env.SUBNET}}";
