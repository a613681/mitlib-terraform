variable ftp_host {
  type        = "string"
  description = "Hostname of FTP server"
}

variable ftp_path {
  type        = "map"
  description = "A map with the FTP path to the file keyed to the feed type (articles, people)"
}

variable ftp_user {
  type        = "string"
  description = "FTP username"
}

variable schedule {
  type        = "map"
  description = "A map with the cron schedule expression keyed to the feed type (articles, people)"
}
