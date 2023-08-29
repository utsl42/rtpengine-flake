{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption optionalString types concatStringsSep concatMapStrings mapAttrsToList;
  cfg = config.services.rtpengine;
  caps = [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" "CAP_SYS_NICE" ];
in
{
  options = {
    services.rtpengine = {
      enable = mkEnableOption (lib.mdDoc "RTPEngine");
      settings = mkOption {
        type = types.attrs;
        default = {};
        description = ''
          Configuration for the Sipwise media proxy
        '';
      };
    };
  };

  config = mkIf cfg.enable
    {
      environment.systemPackages = [ pkgs.rtpengine ];

      environment.etc."rtpengine/rtpengine.conf".source = pkgs.writeTextFile {
        name = "rtpengine.conf";
        text = lib.generators.toINI {} { rtpengine = cfg.settings;};
      };

      users.users.rtpengine = {
        description = "RTPEngine daemon user";
        isSystemUser = true;
        group = "rtpengine";
      };
      users.groups.rtpengine = {};

      systemd.services.rtpengine = {
        description = "RTPEngine";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "forking";
          Restart = "on-failure";
          RestartSec = "3s";
          TimeoutSec = "15s";
          User = "rtpengine";
          Group = "rtpengine";
          ExecStart = "${pkgs.rtpengine}/bin/rtpengine --config-file /etc/rtpengine/rtpengine.conf --pidfile=/run/rtpengine/rtpengine.pid";
          RuntimeDirectory = "rtpengine";
          PIDFile="/run/rtpengine/rtpengine.pid";
          CapabilityBoundingSet = caps;
          AmbientCapabilities = caps;
          ProtectSystem = "full";
          ProtectHome = "yes";
          ProtectKernelTunables = true;
          ProtectControlGroups = true;
          PrivateTmp = true;
          PrivateDevices = true;
          SystemCallFilter = "~@cpu-emulation @debug @keyring @module @mount @obsolete @raw-io";
          MemoryDenyWriteExecute = "yes";
          LimitNOFILE = 262144;
        };
      };
    };
}
