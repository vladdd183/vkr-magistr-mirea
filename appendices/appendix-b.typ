// ============================================================================
// 📎 ПРИЛОЖЕНИЕ Б: Конфигурации хостов и определения профилей
// ============================================================================

#import "../template.typ": vkr-code, vkr-appendix

#vkr-appendix("Б", "Конфигурации хостов и определения профилей")[

== Б.1. Конфигурация хоста vladOS (рабочая станция)

#vkr-code(
  caption: [Конфигурация хоста vladOS — рабочая станция разработчика (фрагмент)],
  lang: "nix",
  ```
# systems/x86_64-linux/vladOS/default.nix
{ config, lib, pkgs, namespace, ... }:

let
  inherit (lib.${namespace}) enabled applyProfile;
in
{
  imports = [ ./hardware-configuration.nix ];

  config = lib.mkMerge [
    # Применяем профиль developer (наследует workstation → minimal)
    (applyProfile "developer")

    # Пользователи
    {
      ${namespace}.users = lib.${namespace}.mkHostUsersConfig "vladOS" {
        homeManager.enable = true;
        accounts.vladdd183.homeManager = true;
      };
      users.users.vladdd183.extraGroups = [ "input" "uinput" ];
    }

    # Дополнительные suites
    {
      ${namespace}.suites = {
        devops = { enable = true; kubernetes = true; terraform = true; };
        desktop.gaming = true;
      };
    }

    # Сервисы
    {
      ${namespace}.services.github-runners = {
        enable = true;
        runners.my-runner = {
          url = "https://github.com/vladdd183/ipfs";
          tokenFile = "/secrets/github-tokens/fatdata";
          ephemeral = true;
        };
      };
    }

    # Безопасность
    {
      ${namespace}.security = {
        enable = true;
        polkitWheelBypass = true;
        sops = { enable = true; defaultSopsFile = "hosts/vladOS.yaml"; };
      };
    }

    # Специфичные настройки
    {
      programs.nix-ld.enable = true;
      boot.kernelModules = [ "v4l2loopback" ];
      hardware.graphics.enable32Bit = true;
      environment.systemPackages = with pkgs; [
        qtcreator kdePackages.kdenlive unstable.code-cursor
      ];
      system.stateVersion = "25.11";
    }
  ];
}
  ```.text,
)

#pagebreak()

== Б.2. Конфигурация хоста perturabo-gpu4gb-node0 (K3s + GPU)

#vkr-code(
  caption: [Конфигурация серверного хоста с K3s (фрагмент)],
  lang: "nix",
  ```
# systems/x86_64-linux/perturabo-gpu4gb-node0/default.nix
{ config, lib, pkgs, namespace, ... }:

let
  inherit (lib.${namespace}) enabled applyProfile combineProfiles;
in
{
  imports = [ ./hardware-configuration.nix ];

  config = lib.mkMerge [
    # Комбинируем серверные профили
    (combineProfiles [ "server-k3s-agent" "server-gpu" ])

    # Пользователи
    {
      ${namespace}.users = lib.${namespace}.mkHostUsersConfig "perturabo-gpu4gb-node0" {
        accounts.kubeadmin = {};
      };
    }

    # K3s конфигурация
    {
      ${namespace}.services.k3s = {
        token = "<K3s cluster token>";
        serverAddr = "https://10.0.0.1:6443";
        nodeIP = "10.0.0.2";
        flannelInterface = "wg0";
      };
    }

    # Сеть
    {
      ${namespace}.system.networking = {
        enable = true;
        hostName = "perturabo-gpu4gb-node0";
      };
      ${namespace}.services.wireguard = enabled;
    }

    { system.stateVersion = "25.11"; }
  ];
}
  ```.text,
)

#pagebreak()

== Б.3. Определения профилей

#vkr-code(
  caption: [Профиль developer — разработчик],
  lang: "nix",
  ```
# lib/profiles/desktop/developer.nix
{ namespace, ... }:
{
  extends = "workstation";           # Наследует от workstation
  suites = [ "development" ];        # Добавляет development suite
  services = [ "tailscale" ];        # VPN для удалённой работы
  programs = [ "shells.xonsh" ];     # Оболочка xonsh
  config = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;      # Автоматические Nix-окружения
    };
  };
}
  ```.text,
)

#vkr-code(
  caption: [Профиль workstation — рабочая станция],
  lang: "nix",
  ```
# lib/profiles/desktop/workstation.nix
{ namespace, ... }:
{
  suites = [ "common" "desktop" ];   # Базовые + Desktop окружение
  hardware = [ "audio" "bluetooth" "printing" ];
  services = [ "docker" "flatpak" ];
  programs = [ "browsers.firefox" ]; # Браузер Firefox
  desktop = "plasma";                # KDE Plasma
  config = {};
}
  ```.text,
)

#vkr-code(
  caption: [Профиль minimal — минимальная конфигурация],
  lang: "nix",
  ```
# lib/profiles/desktop/minimal.nix
{ ... }:
{
  # Базовый профиль без наследования
  suites = [ "common" ];             # Только базовые настройки
  hardware = [];
  services = [ "openssh" ];          # SSH доступ
  programs = [];
  desktop = null;
  config = {};
}
  ```.text,
)

#vkr-code(
  caption: [Профиль server-base — базовый серверный],
  lang: "nix",
  ```
# lib/profiles/server/base.nix
{ lib, namespace }:
{
  suites = [ "common" "server" ];    # common + серверные настройки
  hardware = [];
  services = [ "openssh" "docker" ]; # SSH + Docker
  programs = [];
  desktop = null;
  config = {
    # Headless режим — отключаем X server
    services.xserver.enable = lib.mkDefault false;
  };
}
  ```.text,
)

#vkr-code(
  caption: [Профиль server-k3s-agent — K3s worker node],
  lang: "nix",
  ```
# lib/profiles/server/k3s-agent.nix
{ lib ? null, namespace, ... }:
{
  extends = "server-base";           # Наследует серверную базу
  services = [ "k3s" "wireguard" ];  # K3s + VPN
  config = {
    ${namespace}.services.k3s.role = "agent";
    virtualisation.containerd.enable = true;
  };
}
  ```.text,
)

== Б.4. Иерархия наследования профилей

#vkr-code(
  caption: [Иерархия наследования профилей],
  lang: "text",
  ```
DESKTOP ПРОФИЛИ:
  minimal                     # Автономный базовый профиль
  workstation                 # Автономный (common + desktop)
    ├── developer
    │     └── senior-developer
    ├── gamer
    └── media

SERVER ПРОФИЛИ:
  server-base                 # Автономный (common + server)
    ├── server-ci
    ├── server-gpu
    ├── server-k3s-agent
    ├── server-k3s-server
    ├── server-storage
    └── server-virt
  ```.text,
)

]
