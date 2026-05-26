// ============================================================================
// 📎 ПРИЛОЖЕНИЕ А: Листинги ключевых модулей системы vladOS
// ============================================================================

#import "../template.typ": vkr-code, vkr-appendix

#vkr-appendix("А", "Листинги ключевых модулей системы vladOS")[

== А.1. Точка входа системы (flake.nix)

#vkr-code(
  caption: [Основной файл flake.nix системы vladOS (фрагмент)],
  lang: "nix",
  ```
{
  description = "VladOS v2 — Улучшенная модульная конфигурация Snowfall";

  inputs = {
    # Основные входы
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Snowfall — фреймворк организации
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Home Manager — управление пользовательскими конфигурациями
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Управление секретами
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # nix-topology — генерация диаграмм инфраструктуры
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # deploy-rs — CI/CD деплой с автоматическим rollback
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, ... }:
    let
      inherit (inputs) snowfall-lib;

      lib = snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;
        snowfall = {
          meta = { name = "vladOS"; title = "VladOS v2"; };
          namespace = "vladOS";
        };
      };
      
      flakeOutputs = lib.mkFlake {
        inherit inputs;
        src = ./.;
        
        channels-config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
        
        # Модули для NixOS
        systems.modules.nixos = with inputs; [
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          nix-topology.nixosModules.default
        ];
      };
    in
    lib.recursiveUpdate flakeOutputs {
      # deploy-rs интеграция
      deploy = flakeOutputs.lib.mkDeploy {
        self = flakeOutputs // { inherit (flakeOutputs) nixosConfigurations; };
      };
      
      # Шаблоны проектов
      templates = {
        python-porto-uv = {
          path = ./templates/python-porto-uv;
          description = "Python Porto архитектура с UV и Docker";
        };
        nextjs-app = {
          path = ./templates/nextjs-app;
          description = "Next.js 15 App Router с TypeScript и Tailwind";
        };
      };
    };
}
  ```.text,
)

#pagebreak()

== А.2. Базовый набор common (suites/common)

#vkr-code(
  caption: [Модуль suites/common — базовые настройки для всех хостов],
  lang: "nix",
  ```
# modules/nixos/suites/common/default.nix
{ config, lib, pkgs, namespace, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) enabled enabledList mkPackageGroups;
  cfg = config.${namespace}.suites.common;
  pkgGroups = mkPackageGroups pkgs;
in
{
  options.${namespace}.suites.common = {
    enable = mkEnableOption "Базовая конфигурация системы";
  };

  config = mkIf cfg.enable {
    # Базовые модули
    ${namespace} = {
      system = enabledList [ "boot" "locale" "networking" ];
      security = enabled;
      programs.nh = {
        enable = true;
        clean = { enable = true; extraArgs = "--keep-since 7d --keep 5"; };
      };
    };

    # Базовые пакеты
    environment.systemPackages = pkgGroups.cliBase ++ (with pkgs; [
      vim nano dnsutils netcat pciutils usbutils lsof git htop
    ]);

    # Настройки Nix — оптимизация сборки
    nixpkgs.config.allowUnfree = true;
    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        max-jobs = "auto";
        cores = 0;
        auto-optimise-store = true;
        keep-outputs = true;
        keep-derivations = true;
        substituters = [
          "https://nix-community.cachix.org?priority=8"
          "https://cache.nixos.org?priority=9"
        ];
        trusted-users = [ "root" "@wheel" ];
      };
      gc.automatic = false; # Используем nh clean
    };

    # ZRAM — сжатый swap в RAM
    zramSwap = { enable = true; algorithm = "zstd"; memoryPercent = 50; };
    
    # tmpfs для /tmp — сборка в RAM
    boot.tmp = { useTmpfs = true; tmpfsSize = "50%"; cleanOnBoot = true; };
    
    # TRIM для SSD
    services.fstrim = { enable = true; interval = "weekly"; };
  };
}
  ```.text,
)

#pagebreak()

== А.3. Модуль Docker

#vkr-code(
  caption: [Модуль services/docker — контейнеризация],
  lang: "nix",
  ```
# modules/nixos/services/docker/default.nix
{ config, lib, pkgs, namespace, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) mkBoolOpt mkPackageGroups;
  cfg = config.${namespace}.services.docker;
  pkgGroups = mkPackageGroups pkgs;
in
{
  options.${namespace}.services.docker = {
    enable = mkEnableOption "Docker";
    autoPrune = mkBoolOpt true "Автоматическая очистка";
    compose = mkBoolOpt true "Docker Compose";
  };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = lib.mkIf cfg.autoPrune {
        enable = true;
        dates = "weekly";
        flags = [ "--all" "--volumes" ];
      };
    };
    
    # Пакеты для работы с контейнерами
    environment.systemPackages = pkgGroups.containers;
  };
}
  ```.text,
)

#pagebreak()

== А.4. Система профилей с наследованием

#vkr-code(
  caption: [Библиотека профилей lib/profiles/default.nix (фрагмент)],
  lang: "nix",
  ```
# lib/profiles/default.nix
{ lib, namespace, ... }:

let
  inherit (lib.${namespace}) enabled;
  desktopProfiles = import ./desktop/_desktop.nix { inherit namespace; };
  serverProfiles = import ./server/_server.nix { inherit lib namespace; };
  profiles = desktopProfiles // serverProfiles;
in
rec {
  inherit profiles;

  # Развернуть профиль с рекурсивным наследованием
  expandProfile = name:
    let
      profile = profiles.${name} or (throw "Profile '${name}' not found");
      emptyProfile = {
        suites = []; hardware = []; services = []; programs = [];
        desktop = null; config = {};
      };
      parent = if profile ? extends
        then expandProfile profile.extends
        else emptyProfile;
    in {
      suites = lib.unique (parent.suites ++ (profile.suites or []));
      hardware = lib.unique (parent.hardware ++ (profile.hardware or []));
      services = lib.unique (parent.services ++ (profile.services or []));
      programs = lib.unique (parent.programs ++ (profile.programs or []));
      desktop = if profile ? desktop then profile.desktop else parent.desktop;
      config = lib.recursiveUpdate (parent.config or {}) (profile.config or {});
    };

  # Применить профиль к конфигурации NixOS
  applyProfile = profileName:
    let
      p = expandProfile profileName;
      pathToAttr = path:
        let parts = lib.splitString "." path;
        in lib.setAttrByPath parts enabled;
      programsConfig = lib.foldl' lib.recursiveUpdate {} (map pathToAttr p.programs);
      hardwareConfig = lib.foldl' lib.recursiveUpdate {} (map pathToAttr p.hardware);
    in lib.mkMerge [
      { ${namespace}.suites = lib.genAttrs p.suites (_: enabled); }
      (lib.mkIf (p.hardware != []) { ${namespace}.hardware = hardwareConfig; })
      (lib.mkIf (p.services != []) { ${namespace}.services = lib.genAttrs p.services (_: enabled); })
      (lib.mkIf (p.programs != []) { ${namespace}.programs = programsConfig; })
      (lib.mkIf (p.desktop != null) { ${namespace}.desktop.${p.desktop} = enabled; })
      p.config
    ];

  # Комбинировать несколько профилей
  combineProfiles = profileNames: lib.mkMerge (map applyProfile profileNames);
}
  ```.text,
)

]
