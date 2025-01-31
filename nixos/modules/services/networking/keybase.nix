{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.keybase;
in
{

  ###### interface

  options = {

    services.keybase = {

      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to start the Keybase service.";
      };

    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    # Upstream: https://github.com/keybase/client/blob/master/packaging/linux/systemd/keybase.service
    systemd.user.services.keybase = {
      description = "Keybase service";
      unitConfig.ConditionUser = "!@system";
      environment.KEYBASE_SERVICE_TYPE = "systemd";
      serviceConfig = {
        Type = "notify";
        EnvironmentFile = [
          "-%E/keybase/keybase.autogen.env"
          "-%E/keybase/keybase.env"
        ];
        ExecStart = "${pkgs.keybase}/bin/keybase service";
        Restart = "on-failure";
        PrivateTmp = true;
      };
      wantedBy = [ "default.target" ];
    };

    environment.systemPackages = [ pkgs.keybase ];
  };
}
