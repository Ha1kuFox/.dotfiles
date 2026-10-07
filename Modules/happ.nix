{pkgs, ...}: let
  happ = pkgs.callPackage ../Packages/happ {};
in {
  environment.systemPackages = [happ];

  # Happ's bundled Qt reads the machine ID ONLY from
  # /usr/local/var/lib/dbus/machine-id (its QSysInfo::machineUniqueId has
  # no /etc/machine-id fallback). Neither that nor the classic
  # /var/lib/dbus/machine-id exists on NixOS, so HWID came out empty and
  # providers gated the subscription ("app not supported" mirror).
  # Symlink both to the real machine-id.
  systemd.tmpfiles.rules = [
    "d /var/lib/dbus 0755 root root -"
    "L /var/lib/dbus/machine-id - - - - /etc/machine-id"
    "d /usr/local/var/lib/dbus 0755 root root -"
    "L /usr/local/var/lib/dbus/machine-id - - - - /etc/machine-id"
  ];
  systemd.services.happd = {
    description = "Happ Process Control Daemon";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      # NOTE: the wrapper, not the raw binary — it sets LD_LIBRARY_PATH
      # (openssl for the Qt TLS backend, etc.). The raw binary falls back
      # to the "cert-only" TLS backend and everything HTTPS in the
      # daemon fails (seen in /var/log/happd.log).
      ExecStart = "${happ}/bin/happd";
      Restart = "always";
      RestartSec = "5s";
      TimeoutStopSec = "10s";
      KillMode = "mixed";
      KillSignal = "SIGTERM";
    };
  };
}
