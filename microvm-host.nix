# microvm-host.nix — MicroVM template usando microvm.nix
#
# O QUE É: define uma VM NixOS leve rodando com QEMU/KVM dentro do seu host.
# A VM é um serviço systemd — liga/desliga com um comando.
#
# LIGAR:    systemctl start microvm@template
# DESLIGAR: systemctl stop microvm@template
# STATUS:   systemctl status microvm@template
# LOGS:     journalctl -u microvm@template
# CONSOLE:  microvm -l /var/lib/microvms/template
# SSH:      ssh -p 2222 root@localhost (com forwardPorts configurado)
#
# RECURSOS COM VM LIGADA:    ~2 GB RAM + 2 vCPUs (ajustável)
# RECURSOS COM VM DESLIGADA: 0 CPU/RAM (só o disco qcow2 ocupa espaço)
#
# Para ajustar: edite microvm.vcpu / microvm.mem / volumes abaixo,
# depois sudo nixos-rebuild switch.

{ inputs, pkgs, config, lib, ... }:

{
  imports = [ inputs.microvm.nixosModules.host ];

  microvm.host.enable = true;

  # Template de VM — defina o que roda dentro dela no block `config`
  microvm.vms.template = {
    autostart = false;         # NÃO inicia no boot — manual
    restartIfChanged = true;

    # ═══════════════════════════════════════════════════════
    # Configuração DO CONVIDADO (rodando dentro da VM)
    # ═══════════════════════════════════════════════════════
    config = { config, pkgs, ... }: {

      # ═══ RECURSOS DA VM ═══
      microvm.vcpu = 2;       # 2 CPUs virtuais
      microvm.mem  = 2048;    # 2048 MB = 2 GB RAM

      # ═══ DISCO ═══
      # Auto-cria disco qcow2 na pasta /var/lib/microvms/template/
      microvm.volumes = [{
        mountPoint = "/";
        image      = "root.qcow2";
        size       = 16384;   # 16 GiB
        autoCreate = true;
        label      = "vm-root";
      }];

      # ═══ REDE ═══
      microvm.interfaces = [{
        type = "user";
        id   = "usernet";
        mac  = "02:00:00:01:01:01";
      }];

      # Port forward: host:2222 IÚ guest:22 (SSH)
      microvm.forwardPorts = [
        { from = "host"; host.port = 2222; guest.port = 22; }
      ];

      # ═══ SERVIÃçOS BÃ¡SICOS ─────────────────────────────────────
      services.openssh.enable = true;
      users.users.root.openssh.authorizedKeys.keys = [];
      # Adicione sua chave aqui:
      # users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3..." ];

      # ponytail: sem firewall por padrão na VM — a rede é user-mode
      # networking.firewall.enable = false;

      # ═══ SERVIÃçOS EXTRAS ───────────────────────────────────────
      # Exemplos de services que você pode adicionar aqui:
      # services.nginx.enable = true;
      # services.postgresql.enable = true;
      # services.minecraft-servers = { ... };

      system.stateVersion = "25.05";
    };
  };
}