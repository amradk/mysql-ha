# This denotes the start of the configuration section for Consul. All values
# contained in this section pertain to Consul.
consul {
  # This block specifies the basic authentication information to pass with the
  # request. For more information on authentication, please see the Consul
  # documentation.
  auth {
    enabled  = false
  }
  address = "127.0.0.1:8500"
  retry {
    enabled = true
    attempts = 12
    backoff = "250ms"
    max_backoff = "1m"
  }
  ssl {
    enabled = false
  }
}

reload_signal = "SIGHUP"

kill_signal = "SIGINT"

max_stale = "10m"

log_level = "warn"

pid_file = "/var/run/consul-template.pid"

wait {
  min = "5s"
  max = "10s"
}


syslog {
  enabled = true
  facility = "LOCAL5"
}

template {
  source = "/etc/consul-template/proxysql.ctmpl"
  destination = "/etc/proxysql.cnf"
  create_dest_dirs = true
  command = "/bin/bash -c '/config/scripts/proxysql_reload.sh'"
  command_timeout = "60s"
  error_on_missing_key = false
  perms = 0600
  backup = true
  left_delimiter  = "{{"
  right_delimiter = "}}"
  wait {
    min = "2s"
    max = "10s"
  }
}
