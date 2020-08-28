{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.parsedmarc;
  configFile = pkgs.writeText "parsedmarc.ini" (lib.generators.toINI { } {
    general = {
      save_aggregate = "True";
      save_forensic = "True";
      debug = cfg.debug;
    };
    imap = {
      host = cfg.imapHost;
      user = cfg.imapUser;
      password = cfg.imapPassword;
      watch = "True";
      test = cfg.test;
    };
    elasticsearch = {
      hosts = cfg.elasticsearchHosts;
      ssl = cfg.elasticsearchSSL;
    };
  });
in {
  options = {
    services.parsedmarc = {
      enable = mkEnableOption "parsedmarc";

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/parsedmarc";
        description = "The directory where parsedmarc stores its files.";
      };

      user = mkOption {
        type = types.str;
        default = "parsedmarc";
        description = "User account under which parsedmarc runs.";
      };

      group = mkOption {
        type = types.str;
        default = "parsedmarc";
        description = "Group under which parsedmarc runs.";
      };

      imapHost = mkOption {
        type = types.str;
        example = "imap.domain.tld";
        description = "IMAP server address.";
      };

      imapUser = mkOption {
        type = types.str;
        example = "dmarc.reporting@domain.tld";
        description = "IMAP username of report mailbox.";
      };

      imapPassword = mkOption {
        type = types.str;
        description = "IMAP password of report mailbox.";
      };

      debug = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to log debug information.";
      };

      test = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to run in test mode (not moving/deleting) messages.";
      };

      elasticsearchHosts = mkOption {
        type = types.str;
        default = "http://localhost:9200";
        example = "http://elastic01:9200,http://elastic02:9200";
        description = "A comma separated list of hostnames and ports or URLs.";
      };

      elasticsearchSSL = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to connect securely to the elasticsearch hosts.";
      };

    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d '${cfg.dataDir}' - - - - -" ];

    systemd.services.parsedmarc = {
      description = "parsedmarc";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.parsedmarc}/bin/parsedmarc -c ${configFile}";
        Restart = "on-failure";
        StateDirectory = cfg.dataDir;
        DynamicUser = true;
        WorkingDirectory = cfg.dataDir;
      };
    };
  };
}
