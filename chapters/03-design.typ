// ============================================================================
// 📄 РАЗДЕЛ 2: ПРОЕКТНЫЙ
// Архитектура системы + Техническое задание
// ============================================================================

#import "../template.typ": cite-src, cite-range, vkr-table, vkr-long-table, vkr-code, vkr-code-file, vkr-fig-num, vkr-table-num
#import "@preview/cetz:0.3.4"

= Проектный раздел

== Общая архитектура системы управления конфигурацией

=== Концептуальная модель

Система управления конфигурацией строится на принципах:

- *Единый источник правды* — все конфигурации хранятся в одном Git-репозитории;
- *Декларативность* — описание желаемого состояния, а не процесса;
- *Модульность* — декомпозиция на переиспользуемые компоненты;
- *Иерархия абстракций* — от низкоуровневых модулей к высокоуровневым профилям.

=== Технологический стек

Состав технологического стека системы приведён в таблице #vkr-table-num(<tbl:design-tech-stack>).

#vkr-table(
  columns: (auto, auto, 1fr),
  caption: [Технологический стек системы],
  [*Компонент*], [*Технология*], [*Назначение*],
  [Операционная система], [NixOS], [Декларативная ОС с конгруэнтной моделью],
  [Пакетный менеджер], [Nix с Flakes], [Воспроизводимое управление зависимостями],
  [Фреймворк организации], [Snowfall Lib], [Структурирование Nix flakes],
  [Контроль версий], [Git], [Версионирование конфигураций],
  [Развёртывание], [nixos-rebuild, deploy-rs], [Применение конфигураций],
) <tbl:design-tech-stack>

=== Архитектурные уровни

Система организована в три уровня абстракции:

+ *Уровень модулей (Modules)* — атомарные переиспользуемые компоненты, отвечающие за конкретные аспекты конфигурации;
+ *Уровень наборов (Suites)* — логически связанные группы модулей для типовых сценариев;
+ *Уровень профилей (Profiles)* — высокоуровневые композиции с механизмом наследования для ролей машин.

=== Диаграмма вариантов использования (Use Case)

Для определения функциональных требований к системе управления конфигурацией разработана диаграмма вариантов использования в нотации UML.

Диаграмма вариантов использования системы представлена на рисунке #vkr-fig-num(<fig:design-use-case>).

#figure(
  cetz.canvas(length: 0.7cm, {
    import cetz.draw: *
    
    // Функция для рисования актора
    let draw-actor(pos, label) = {
      let (x, y) = pos
      // Голова
      circle((x, y + 1.4), radius: 0.4, stroke: black + 1pt)
      // Тело
      line((x, y + 1.0), (x, y + 0.1), stroke: 1pt)
      // Руки
      line((x - 0.6, y + 0.7), (x + 0.6, y + 0.7), stroke: 1pt)
      // Ноги
      line((x, y + 0.1), (x - 0.5, y - 0.6), stroke: 1pt)
      line((x, y + 0.1), (x + 0.5, y - 0.6), stroke: 1pt)
      // Подпись
      content((x, y - 1.2), text(size: 9pt, weight: "bold", label))
    }
    
    // Функция для рисования варианта использования (эллипс)
    let draw-usecase(pos, label) = {
      circle(
        pos,
        radius: (3.5, 0.9),
        fill: rgb("#E3F2FD"),
        stroke: rgb("#1976D2") + 1pt
      )
      content(pos, text(size: 8pt, label))
    }
    
    // Граница системы
    rect((4, 11.5), (16, -1.5), stroke: rgb("#424242") + 1pt, fill: rgb("#FAFAFA"))
    content((10, 10.8), text(size: 10pt, weight: "bold")[Система vladOS])
    
    // Акторы слева
    draw-actor((1, 8), [Администратор])
    draw-actor((1, 2), [Разработчик])
    
    // Актор справа
    draw-actor((19, 5), [CI/CD])
    
    // Варианты использования (увеличенные эллипсы, вертикальный интервал 1.8)
    let uc-x = 10
    draw-usecase((uc-x, 9.2), [UC1: Создать модуль])
    draw-usecase((uc-x, 7.3), [UC2: Создать профиль])
    draw-usecase((uc-x, 5.4), [UC3: Добавить хост])
    draw-usecase((uc-x, 3.5), [UC4: Собрать конфигурацию])
    draw-usecase((uc-x, 1.6), [UC5: Развернуть])
    draw-usecase((uc-x, -0.3), [UC6: Откатить])
    
    // === СВЯЗИ ===
    set-style(stroke: black + 0.6pt)
    
    // Администратор -> все UC
    line((2.2, 8.5), (6.5, 9.2))
    line((2.2, 8.2), (6.5, 7.3))
    line((2.2, 7.8), (6.5, 5.4))
    line((2.2, 7.5), (6.5, 3.5))
    line((2.2, 7.2), (6.5, 1.6))
    line((2.2, 6.9), (6.5, -0.3))
    
    // Разработчик -> UC3, UC4, UC5
    line((2.2, 2.8), (6.5, 5.4))
    line((2.2, 2.4), (6.5, 3.5))
    line((2.2, 2.0), (6.5, 1.6))
    
    // CI/CD -> UC4, UC5
    line((17.8, 5.5), (13.5, 3.5))
    line((17.8, 5.0), (13.5, 1.6))
    
    // Связи include/extend (пунктирные)
    set-style(stroke: (dash: "dashed", thickness: 0.6pt))
    
    // UC3 --include--> UC4
    line((uc-x, 4.5), (uc-x, 4.2))
    content((uc-x + 2, 4.35), text(size: 8pt)[«include»])
    
    // UC5 --extend--> UC6
    line((uc-x, 0.7), (uc-x, 0.4))
    content((uc-x + 2, 0.55), text(size: 8pt)[«extend»])
  }),
  caption: [Диаграмма вариантов использования системы],
  kind: image,
  supplement: [Рисунок],
) <fig:design-use-case>

Описание вариантов использования приведено в таблице #vkr-table-num(<tbl:design-use-case-desc>).

#vkr-table(
  columns: (auto, auto, 1fr),
  caption: [Описание вариантов использования],
  [*ID*], [*Название*], [*Описание*],
  [UC1], [Создать/изменить модуль], [Создание нового или модификация существующего NixOS-модуля для конфигурирования определённого аспекта системы],
  [UC2], [Создать/изменить профиль], [Создание профиля роли машины с указанием наследования и включаемых наборов],
  [UC3], [Добавить новый хост], [Добавление конфигурации нового хоста с привязкой к профилю и hardware-configuration],
  [UC4], [Собрать конфигурацию], [Выполнение `nixos-rebuild build` для генерации системного derivation],
  [UC5], [Развернуть на хосте], [Применение конфигурации на целевом хосте через `nixos-rebuild switch` или `deploy-rs`],
  [UC6], [Откатить конфигурацию], [Возврат к предыдущему поколению системы при обнаружении ошибок],
) <tbl:design-use-case-desc>

=== Дерево функций системы

Для детализации функциональных возможностей системы построено дерево функций, отражающее иерархию компонентов и их назначение.

Дерево функций системы представлено на рисунке #vkr-fig-num(<fig:design-function-tree>).

#figure(
  cetz.canvas(length: 0.65cm, {
    import cetz.draw: *
    
    // Функция для рисования узла дерева
    let draw-node(pos, label, width: 3.5, fill-color: rgb("#E3F2FD")) = {
      let (x, y) = pos
      rect(
        (x - width/2, y - 0.5),
        (x + width/2, y + 0.5),
        radius: 0.15,
        fill: fill-color,
        stroke: rgb("#1976D2") + 0.5pt
      )
      content(pos, text(size: 8pt, label))
    }
    
    // === УРОВЕНЬ 0: Корень ===
    draw-node((10, 10), [vladOS — система CM], width: 5, fill-color: rgb("#BBDEFB"))
    
    // === УРОВЕНЬ 1: Основные подсистемы ===
    let y1 = 8
    draw-node((3.5, y1), [Модули], width: 3, fill-color: rgb("#E3F2FD"))
    draw-node((10, y1), [Профили], width: 3, fill-color: rgb("#E3F2FD"))
    draw-node((16.5, y1), [Деплой], width: 3, fill-color: rgb("#E3F2FD"))
    
    // Связи корень -> уровень 1
    line((10, 9.5), (10, 8.8), (3.5, 8.8), (3.5, 8.5), stroke: 0.5pt)
    line((10, 9.5), (10, 8.5), stroke: 0.5pt)
    line((10, 9.5), (10, 8.8), (16.5, 8.8), (16.5, 8.5), stroke: 0.5pt)
    
    // === УРОВЕНЬ 2 ===
    let y2 = 6
    
    // Подкатегории модулей
    draw-node((1, y2), [hardware], width: 2.5, fill-color: rgb("#C8E6C9"))
    draw-node((3.5, y2), [services], width: 2.5, fill-color: rgb("#C8E6C9"))
    draw-node((6, y2), [suites], width: 2.5, fill-color: rgb("#C8E6C9"))
    
    // Подкатегории профилей
    draw-node((9, y2), [Desktop], width: 2.5, fill-color: rgb("#FFF9C4"))
    draw-node((11.5, y2), [Server], width: 2.5, fill-color: rgb("#FFF9C4"))
    
    // Подкатегории деплоя
    draw-node((15, y2), [Локально], width: 2.5, fill-color: rgb("#FFCCBC"))
    draw-node((18, y2), [Удалённо], width: 2.5, fill-color: rgb("#FFCCBC"))
    
    // Связи уровень 1 -> уровень 2
    line((3.5, 7.5), (3.5, 6.8), (1, 6.8), (1, 6.5), stroke: 0.5pt)
    line((3.5, 7.5), (3.5, 6.5), stroke: 0.5pt)
    line((3.5, 7.5), (3.5, 6.8), (6, 6.8), (6, 6.5), stroke: 0.5pt)
    
    line((10, 7.5), (10, 6.8), (9, 6.8), (9, 6.5), stroke: 0.5pt)
    line((10, 7.5), (10, 6.8), (11.5, 6.8), (11.5, 6.5), stroke: 0.5pt)
    
    line((16.5, 7.5), (16.5, 6.8), (15, 6.8), (15, 6.5), stroke: 0.5pt)
    line((16.5, 7.5), (16.5, 6.8), (18, 6.8), (18, 6.5), stroke: 0.5pt)
    
    // === УРОВЕНЬ 3: Примеры ===
    let y3 = 4
    let y3b = 2.8
    
    // Примеры hardware
    draw-node((1, y3), [audio], width: 2, fill-color: rgb("#E8F5E9"))
    draw-node((1, y3b), [gpu], width: 2, fill-color: rgb("#E8F5E9"))
    
    // Примеры services
    draw-node((3.5, y3), [docker], width: 2, fill-color: rgb("#E8F5E9"))
    draw-node((3.5, y3b), [k3s], width: 2, fill-color: rgb("#E8F5E9"))
    
    // Примеры suites
    draw-node((6, y3), [common], width: 2, fill-color: rgb("#E8F5E9"))
    draw-node((6, y3b), [devops], width: 2, fill-color: rgb("#E8F5E9"))
    
    // Примеры Desktop
    draw-node((9, y3), [minimal], width: 2, fill-color: rgb("#FFFDE7"))
    draw-node((9, y3b), [developer], width: 2, fill-color: rgb("#FFFDE7"))
    
    // Примеры Server
    draw-node((11.5, y3), [base], width: 2, fill-color: rgb("#FFFDE7"))
    draw-node((11.5, y3b), [ci], width: 2, fill-color: rgb("#FFFDE7"))
    
    // Примеры локального деплоя
    draw-node((15, y3), [rebuild], width: 2.3, fill-color: rgb("#FBE9E7"))
    
    // Примеры удалённого деплоя
    draw-node((18, y3), [deploy-rs], width: 2.3, fill-color: rgb("#FBE9E7"))
    draw-node((18, y3b), [rollback], width: 2.3, fill-color: rgb("#FBE9E7"))
    
    // Связи уровень 2 -> уровень 3
    line((1, 5.5), (1, 4.5), stroke: 0.5pt)
    line((1, 5.5), (1, 5.2), (1, 5.2), (1, 3.3), stroke: 0.5pt)
    
    line((3.5, 5.5), (3.5, 4.5), stroke: 0.5pt)
    line((3.5, 5.5), (3.5, 5.2), (3.5, 3.3), stroke: 0.5pt)
    
    line((6, 5.5), (6, 4.5), stroke: 0.5pt)
    line((6, 5.5), (6, 5.2), (6, 3.3), stroke: 0.5pt)
    
    line((9, 5.5), (9, 4.5), stroke: 0.5pt)
    line((9, 5.5), (9, 5.2), (9, 3.3), stroke: 0.5pt)
    
    line((11.5, 5.5), (11.5, 4.5), stroke: 0.5pt)
    line((11.5, 5.5), (11.5, 5.2), (11.5, 3.3), stroke: 0.5pt)
    
    line((15, 5.5), (15, 4.5), stroke: 0.5pt)
    
    line((18, 5.5), (18, 4.5), stroke: 0.5pt)
    line((18, 5.5), (18, 5.2), (18, 3.3), stroke: 0.5pt)
  }),
  caption: [Дерево функций системы управления конфигурацией],
  kind: image,
  supplement: [Рисунок],
) <fig:design-function-tree>

== Уровень модулей

=== Назначение

Модули — это атомарные, переиспользуемые компоненты конфигурации, отвечающие за конкретные аспекты системы.

=== Классификация модулей

Классификация модулей по категориям приведена в таблице #vkr-table-num(<tbl:design-modules-classification>).

#vkr-table(
  columns: (auto, auto, 1fr, auto),
  caption: [Классификация модулей по категориям (реализовано 25 модулей)],
  [*Категория*], [*Количество*], [*Модули*], [*LOC*],
  [hardware], [3], [audio, bluetooth, printing], [140],
  [services], [9], [docker, k3s, tailscale, openssh, wireguard, flatpak, github-runners, libvirt, copyparty], [891],
  [programs], [1], [nh], [98],
  [system], [3], [boot, locale, networking], [226],
  [security], [2], [default (polkit, sudo), sops], [198],
  [desktop], [1], [plasma], [87],
  [users], [1], [управление пользователями], [187],
  [suites], [5], [common, desktop, development, devops, server], [570],
) <tbl:design-modules-classification>

=== Структура модуля

Каждый модуль следует стандартной структуре с использованием namespace:

#vkr-code(
  caption: [Структура модуля NixOS],
  lang: "nix",
  ```
# modules/nixos/<category>/<module-name>/default.nix
{ config, lib, pkgs, namespace, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) mkBoolOpt enabled;
  
  cfg = config.${namespace}.<category>.<module-name>;
in
{
  options.${namespace}.<category>.<module-name> = {
    enable = mkEnableOption "<module-name>";
    someOption = mkBoolOpt false "Описание опции";
  };

  config = mkIf cfg.enable {
    # Конфигурация при включении модуля
  };
}
  ```.text,
)

=== Пример модуля Docker

#vkr-code(
  caption: [Модуль Docker],
  lang: "nix",
  ```
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
    environment.systemPackages = pkgGroups.containers;
  };
}
  ```.text,
)

== Уровень наборов (Suites)

=== Назначение

Наборы (Suites) — это логически связанные группы модулей, объединённые по функциональному назначению.

=== Типы наборов

Состав и назначение наборов (suites) приведены в таблице #vkr-table-num(<tbl:design-suites>).

#vkr-table(
  columns: (auto, auto, 1fr, 1fr),
  caption: [Типы наборов и их состав (реализовано 5 наборов, 570 LOC)],
  [*Набор*], [*LOC*], [*Описание*], [*Включаемые компоненты*],
  [common], [202], [Базовые настройки для всех хостов], [boot, locale, networking, security, Nix-оптимизации, ZRAM],
  [desktop], [132], [Настройки рабочей станции], [audio, bluetooth, printing, flatpak, шрифты, KDE Plasma],
  [server], [111], [Серверные настройки], [openssh, firewall, headless режим],
  [development], [68], [Инструменты разработки], [docker, direnv, neovim, vscode, Python/Node инструменты],
  [devops], [57], [DevOps инструменты], [kubernetes (kubectl, helm, k9s), terraform, ansible],
) <tbl:design-suites>

== Уровень профилей (Profiles)

=== Назначение

Профили — это высокоуровневые композиции наборов и модулей, определяющие роль машины в инфраструктуре.

=== Механизм наследования

Профили поддерживают наследование через механизм `extends`:

#vkr-code(
  caption: [Профиль developer с наследованием],
  lang: "nix",
  ```
# lib/profiles/desktop/developer.nix
{ namespace, ... }:
{
  extends = "workstation";  # Наследует от workstation
  suites = [ "development" ];
  services = [ "tailscale" ];
  programs = [ "shells.xonsh" ];
  config = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
  ```.text,
)

=== Иерархия профилей

*Desktop-профили (6):*

Перечень Desktop-профилей системы приведён в таблице #vkr-table-num(<tbl:design-desktop-profiles>).

#vkr-table(
  columns: (auto, auto, auto, 1fr),
  caption: [Desktop-профили системы],
  [*Профиль*], [*Наследует*], [*Наборы*], [*Компоненты*],
  [minimal], [—], [common], [openssh, базовая конфигурация],
  [workstation], [—], [common, desktop], [audio, bluetooth, printing, plasma, firefox],
  [developer], [workstation], [development], [tailscale, xonsh, direnv],
  [senior-developer], [developer], [devops], [kubernetes, terraform],
  [gamer], [workstation], [—], [Steam, Proton, gaming-оптимизации],
  [media], [workstation], [—], [Мультимедиа инструменты],
) <tbl:design-desktop-profiles>

*Server-профили (7):*

Перечень Server-профилей системы приведён в таблице #vkr-table-num(<tbl:design-server-profiles>).

#vkr-table(
  columns: (auto, auto, auto, 1fr),
  caption: [Server-профили системы],
  [*Профиль*], [*Наследует*], [*Наборы*], [*Компоненты*],
  [server-base], [—], [common, server], [openssh, docker],
  [server-ci], [server-base], [—], [github-runners],
  [server-gpu], [server-base], [—], [GPU nvidia (headless), container toolkit],
  [server-k3s-agent], [server-base], [—], [k3s (agent), wireguard, containerd],
  [server-k3s-server], [server-base], [—], [k3s (server), wireguard, containerd],
  [server-storage], [server-base], [—], [copyparty (файловый сервер)],
  [server-virt], [server-base], [—], [libvirt, QEMU/KVM],
) <tbl:design-server-profiles>

== Структура репозитория

=== Организация директорий

#vkr-code-file(
  "input/code/dir-tree.txt",
  caption: [Структура директорий репозитория vladOS-v2],
  line-numbers: false,
  breakable: false,
) <lst:dir-tree>

=== Алгоритм сборки конфигурации хоста

Процесс сборки конфигурации хоста из модульных компонентов представлен в виде блок-схемы алгоритма.

Блок-схема алгоритма сборки конфигурации хоста представлена на рисунке #vkr-fig-num(<fig:design-host-build-flow>).

#figure(
  cetz.canvas(length: 0.8cm, {
    import cetz.draw: *
    
    // Функция для рисования терминатора (начало/конец)
    let draw-terminal(pos, label, name: none) = {
      let (x, y) = pos
      rect(
        (x - 2, y - 0.5),
        (x + 2, y + 0.5),
        radius: 0.5,
        fill: rgb("#C8E6C9"),
        stroke: rgb("#2E7D32"),
        name: name
      )
      content(pos, text(size: 8pt, label))
    }
    
    // Функция для рисования процесса (прямоугольник)
    let draw-process(pos, label, name: none, width: 4) = {
      let (x, y) = pos
      rect(
        (x - width/2, y - 0.6),
        (x + width/2, y + 0.6),
        fill: rgb("#E3F2FD"),
        stroke: rgb("#1976D2"),
        name: name
      )
      content(pos, text(size: 7pt, label))
    }
    
    // Функция для рисования решения (ромб)
    let draw-decision(pos, label, name: none) = {
      let (x, y) = pos
      let s = 1.0
      line(
        (x, y + s), (x + s*1.5, y), (x, y - s), (x - s*1.5, y),
        close: true,
        fill: rgb("#FFF9C4"),
        stroke: rgb("#F9A825"),
        name: name
      )
      content(pos, text(size: 7pt, label))
    }
    
    // Функция для рисования данных (параллелограмм)
    let draw-data(pos, label, name: none) = {
      let (x, y) = pos
      let w = 2
      let h = 0.5
      let skew = 0.3
      line(
        (x - w + skew, y - h), (x + w + skew, y - h),
        (x + w - skew, y + h), (x - w - skew, y + h),
        close: true,
        fill: rgb("#FFCCBC"),
        stroke: rgb("#E64A19"),
        name: name
      )
      content(pos, text(size: 7pt, label))
    }
    
    // Функция для рисования подпроцесса
    let draw-subprocess(pos, label, name: none) = {
      let (x, y) = pos
      rect(
        (x - 2.2, y - 0.6),
        (x + 2.2, y + 0.6),
        fill: rgb("#E1BEE7"),
        stroke: rgb("#7B1FA2"),
        name: name
      )
      // Вертикальные линии подпроцесса
      line((x - 1.9, y - 0.6), (x - 1.9, y + 0.6), stroke: rgb("#7B1FA2"))
      line((x + 1.9, y - 0.6), (x + 1.9, y + 0.6), stroke: rgb("#7B1FA2"))
      content(pos, text(size: 7pt, label))
    }
    
    let cx = 5  // Центр по X
    
    // Блок-схема
    draw-terminal((cx, 14), [Начало])
    
    draw-data((cx, 12.5), [Файл хоста\ (systems/x86_64-linux/host/)], name: "d1")
    
    draw-process((cx, 10.8), [Чтение профиля\ (applyProfile "developer")], name: "p1")
    
    draw-subprocess((cx, 9), [Рекурсивное разрешение\ наследования профиля], name: "s1")
    
    draw-decision((cx, 7), [Есть\ extends?], name: "dec1")
    
    draw-process((cx + 5, 7), [Загрузить родительский\ профиль], name: "p2")
    
    draw-process((cx, 5), [Объединить suites\ из всех профилей], name: "p3")
    
    draw-subprocess((cx, 3.2), [Для каждого suite:\ загрузить модули], name: "s2")
    
    draw-process((cx, 1.4), [Применить host-specific\ конфигурацию], name: "p4")
    
    draw-process((cx, -0.4), [Слияние всех атрибутов\ (lib.mkMerge)], name: "p5")
    
    draw-data((cx, -2.2), [Итоговая конфигурация\ NixOS], name: "d2")
    
    draw-terminal((cx, -4), [Конец])
    
    // Стрелки
    set-style(mark: (end: ">", fill: black, scale: 0.5))
    
    line((cx, 13.5), (cx, 13.1))
    line((cx, 12.0), (cx, 11.5))
    line((cx, 10.2), (cx, 9.7))
    line((cx, 8.3), (cx, 8.0))
    
    // Решение -> Да (вправо)
    line((cx + 1.5, 7), (cx + 2.8, 7))
    content((cx + 2.1, 7.3), text(size: 6pt)[Да])
    
    // От p2 обратно к s1
    line((cx + 5, 7.6), (cx + 5, 9), (cx + 2.2, 9))
    
    // Решение -> Нет (вниз)
    line((cx, 6.0), (cx, 5.6))
    content((cx + 0.5, 5.8), text(size: 6pt)[Нет])
    
    line((cx, 4.4), (cx, 4.0))
    line((cx, 2.5), (cx, 2.1))
    line((cx, 0.8), (cx, 0.3))
    line((cx, -1.0), (cx, -1.6))
    line((cx, -2.8), (cx, -3.4))
    
    // Комментарии справа (путь к файлам)
    content((cx + 4, 12.5), text(size: 7pt, fill: rgb("#757575"), style: "italic")[default.nix], anchor: "west")
    content((cx + 4, 10.8), text(size: 7pt, fill: rgb("#757575"), style: "italic")[lib/profiles/], anchor: "west")
    content((cx + 4, 5), text(size: 7pt, fill: rgb("#757575"), style: "italic")[common, desktop, dev...], anchor: "west")
    content((cx + 4, 3.2), text(size: 7pt, fill: rgb("#757575"), style: "italic")[modules/nixos/suites/], anchor: "west")
    content((cx + 4, 1.4), text(size: 7pt, fill: rgb("#757575"), style: "italic")[hardware, users, etc.], anchor: "west")
  }),
  caption: [Блок-схема алгоритма сборки конфигурации хоста],
  kind: image,
  supplement: [Рисунок],
) <fig:design-host-build-flow>

Алгоритм сборки конфигурации состоит из следующих этапов:

+ *Чтение конфигурации хоста* — загружается файл `default.nix` из директории хоста;
+ *Применение профиля* — вызывается функция `applyProfile` с именем профиля;
+ *Разрешение наследования* — рекурсивно обрабатываются все родительские профили через механизм `extends`;
+ *Объединение наборов* — собираются все `suites` из цепочки наследования;
+ *Загрузка модулей* — для каждого набора загружаются соответствующие модули;
+ *Применение специфичных настроек* — добавляются настройки, уникальные для конкретного хоста;
+ *Слияние атрибутов* — все конфигурационные атрибуты объединяются через `lib.mkMerge`.

== Конфигурация хоста

=== Реальная конфигурация хоста vladOS

Благодаря модульной архитектуре, конфигурация хоста сводится к применению профиля и указанию специфичных параметров:

#vkr-code(
  caption: [Конфигурация хоста vladOS (фрагмент)],
  lang: "nix",
  ```
{ config, lib, pkgs, namespace, ... }:

let
  inherit (lib.${namespace}) enabled applyProfile;
in
{
  imports = [ ./hardware-configuration.nix ];

  config = lib.mkMerge [
    # Применяем профиль developer
    (applyProfile "developer")

    # Пользователи
    { ${namespace}.users = lib.${namespace}.mkHostUsersConfig "vladOS" {
        homeManager.enable = true;
        accounts.vladdd183.homeManager = true;
      };
    }

    # Дополнительные suites
    { ${namespace}.suites.devops = { 
        enable = true; 
        kubernetes = true; 
        terraform = true; 
      }; 
    }

    # Специфичные настройки
    { system.stateVersion = "25.11"; }
  ];
}
  ```.text,
)

=== Сравнение с изолированной конфигурацией

Сравнение объёма конфигурации в изолированном и модульном подходах приведено в таблице #vkr-table-num(<tbl:design-config-size-compare>).

#vkr-table(
  columns: (1fr, auto, auto),
  caption: [Сравнение объёма конфигурации (реальные данные)],
  [*Аспект*], [*Изолированная*], [*Модульная*],
  [Nix-настройки, кэши, оптимизации], [100 LOC], [0 (в common)],
  [Пользователи и группы], [50 LOC], [5 LOC],
  [Docker + nvidia-container], [30 LOC], [0 (в профиле)],
  [Сеть, boot, locale], [60 LOC], [0 (в common)],
  [Audio, Bluetooth, Plasma], [80 LOC], [0 (в desktop)],
  [DevOps (kubectl, helm)], [40 LOC], [3 LOC (enable)],
  [Специфичное (OBS, пакеты)], [110 LOC], [110 LOC],
  [*Итого*], [*~500 LOC*], [*~221 LOC*],
) <tbl:design-config-size-compare>

*Сокращение:* ~56% (с ~500 до ~220 LOC).

== Информационное обеспечение системы

=== Особенности информационной модели

Разрабатываемая система управления конфигурацией не использует реляционную базу данных в традиционном понимании. Хранение, версионирование и обработка данных осуществляются посредством следующих механизмов:

- *Nix Store* — хранилище всех собранных пакетов, конфигураций и derivation'ов с адресацией по криптографическому хешу содержимого (путь вида `/nix/store/<hash>-<name>`);
- *Git-репозиторий* — единый источник правды для всех декларативных конфигураций с полной историей изменений;
- *Файл `flake.lock`* — фиксация версий всех внешних зависимостей, обеспечивающая воспроизводимость;
- *sops-nix* — зашифрованные файлы секретов, дешифруемые при развёртывании.

Обоснование отсутствия реляционной БД: система управления конфигурацией оперирует декларативными описаниями в виде Nix-выражений, которые представляют собой чистые функции без побочных эффектов. Состояние системы полностью определяется содержимым Git-репозитория и файла `flake.lock`, что делает реляционное хранилище избыточным. Nix Store выполняет роль контентно-адресуемого хранилища результатов вычислений.

=== Логическая модель данных

Логическая модель данных системы представляет собой иерархию конфигурационных сущностей и их взаимосвязей.

Основные сущности логической модели данных приведены в таблице #vkr-table-num(<tbl:design-data-entities>).

#vkr-table(
  columns: (auto, 1fr, 1fr),
  caption: [Сущности логической модели данных],
  [*Сущность*], [*Атрибуты*], [*Связи*],
  [Модуль (Module)], [имя, категория, LOC, опции (enable, параметры)], [Входит в Набор (M:N)],
  [Набор (Suite)], [имя, описание, список модулей], [Входит в Профиль (M:N)],
  [Профиль (Profile)], [имя, тип (desktop/server), extends, suites, services, hardware], [Наследует Профиль (1:1), применяется к Хосту (1:N)],
  [Хост (Host)], [hostname, архитектура, профиль, hardware-configuration, stateVersion], [Использует Профиль (N:1), содержит Пользователей (1:N)],
  [Пользователь (User)], [имя, группы, shell, homeManager], [Принадлежит Хосту (N:1)],
  [Секрет (Secret)], [имя, sopsFile, формат], [Привязан к Хосту (N:1)],
  [Поколение (Generation)], [номер, дата, путь в Nix Store], [Принадлежит Хосту (1:N)],
) <tbl:design-data-entities>

Связи между сущностями:
- *Профиль → Набор:* профиль включает один или несколько наборов через атрибут `suites`;
- *Набор → Модуль:* набор активирует группу модулей при включении;
- *Профиль → Профиль:* наследование через механизм `extends` (один родитель);
- *Хост → Профиль:* хост применяет профиль через функцию `applyProfile`;
- *Хост → Поколение:* каждая успешная сборка создаёт новое поколение в Nix Store.

== Техническое задание (по ГОСТ 34.602-2020)

=== Общие сведения

*Полное наименование:* Система управления конфигурацией вычислительной инфраструктуры на базе декларативной операционной системы NixOS.

*Краткое наименование:* vladOS — модульная система управления конфигурацией.

*Условное обозначение:* СКУ-NixOS.

=== Цели создания системы

+ Повышение эффективности управления конфигурациями за счёт применения декларативного подхода и модульной архитектуры.
+ Снижение трудозатрат на сопровождение путём максимизации переиспользования модулей.
+ Устранение проблемы Configuration Drift посредством реализации конгруэнтной модели.
+ Обеспечение воспроизводимости — гарантия идентичного состояния при повторном развёртывании.

=== Требования к функциям системы

Функции управления конфигурациями приведены в таблице #vkr-table-num(<tbl:design-functions>).

#vkr-table(
  columns: (auto, auto, 1fr),
  caption: [Функции управления конфигурациями],
  [*№*], [*Функция*], [*Описание*],
  [Ф1], [Декларативное описание], [Описание состояния системы в виде Nix-выражений],
  [Ф2], [Модульная композиция], [Сборка конфигурации из переиспользуемых модулей],
  [Ф3], [Профилирование хостов], [Типизация машин через систему профилей],
  [Ф4], [Версионирование], [Хранение конфигураций в Git с фиксацией версий],
  [Ф5], [Развёртывание], [Применение конфигураций локально и удалённо],
  [Ф6], [Откат], [Возврат к предыдущим поколениям конфигураций],
) <tbl:design-functions>

=== Требования к надёжности

+ *Атомарность обновлений* — обновление системы должно быть атомарным;
+ *Откат* — должна обеспечиваться возможность отката к любому из предыдущих поколений;
+ *Воспроизводимость* — повторное развёртывание должно давать идентичный результат;
+ *Изоляция сборки* — сборка должна выполняться в изолированной среде (sandbox).

=== Требования к безопасности

+ Секреты не должны храниться в открытом виде в репозитории;
+ Доступ к конфигурациям должен контролироваться через Git;
+ SSH-ключи для удалённого развёртывания должны храниться безопасно;
+ Должна обеспечиваться проверка целостности пакетов.

=== Целевые показатели эффективности

Целевые показатели эффективности системы приведены в таблице #vkr-table-num(<tbl:design-target-metrics>).

#vkr-table(
  columns: (auto, auto, auto),
  caption: [Целевые показатели эффективности],
  [*Показатель*], [*Обозначение*], [*Целевое значение*],
  [Коэффициент переиспользования], [$R$], [$>= 0.50$],
  [Степень модульности], [$M$], [$>= 0.60$],
  [Сокращение кода], [$S$], [$>= 0.40$],
  [Избыточность], [$C$], [$<= 0.10$],
  [Индекс качества], [$Q_(C M)$], [$>= 0.41$],
  [Время развёртывания хоста], [$T_(d e p l o y)$], [$<= 15$ мин],
) <tbl:design-target-metrics>

=== Требования к программному обеспечению

*Базовое ПО:*
- Операционная система: NixOS 25.11+
- Пакетный менеджер: Nix 2.18+ с поддержкой Flakes
- Система контроля версий: Git 2.40+

*Фреймворки и библиотеки:*
- Snowfall Lib — организация Nix Flakes
- Home-manager — управление пользовательскими конфигурациями
- deploy-rs — удалённое развёртывание

=== Этапы разработки

Этапы разработки и ожидаемые результаты приведены в таблице #vkr-table-num(<tbl:design-stages>).

#vkr-table(
  columns: (auto, auto, 1fr, 1fr),
  caption: [Этапы работ],
  [*№*], [*Этап*], [*Содержание*], [*Результат*],
  [1], [Исследование], [Анализ существующих решений], [Аналитический обзор],
  [2], [Проектирование], [Разработка архитектуры], [Архитектурная документация],
  [3], [Разработка базы], [Реализация базовых модулей], [Работающие модули],
  [4], [Разработка модулей], [Аппаратные и сервисные модули], [Полный набор модулей],
  [5], [Разработка профилей], [Система профилей с наследованием], [Иерархия профилей],
  [6], [Конфигурация хостов], [Конфигурации целевых хостов], [Готовые конфигурации],
  [7], [Тестирование], [Проверка в VM, измерение метрик], [Отчёт о тестировании],
) <tbl:design-stages>

== Перечень применяемых стандартов

Перечень применяемых стандартов для разработки технической документации приведён в таблице #vkr-table-num(<tbl:design-standards-doc>).

#vkr-table(
  columns: (auto, 1fr, 1fr),
  caption: [Стандарты разработки технической документации],
  [*Стандарт*], [*Наименование*], [*Применение в работе*],
  [ГОСТ 34.602-2020 #cite-src(10)], [Техническое задание на создание АС], [Разработка ТЗ (данный раздел)],
  [ГОСТ 34.601-90 #cite-src(19)], [Автоматизированные системы. Стадии создания], [Определение этапов разработки],
  [ГОСТ 19.201-78 #cite-src(20)], [Техническое задание. Требования к оформлению], [Структурирование требований],
) <tbl:design-standards-doc>

Перечень стандартов управления конфигурацией и качества ПО приведён в таблице #vkr-table-num(<tbl:design-standards-cm>).

#vkr-table(
  columns: (auto, 1fr, 1fr),
  caption: [Стандарты Configuration Management и качества ПО],
  [*Стандарт*], [*Наименование*], [*Применение в работе*],
  [ANSI/EIA-649B #cite-src(11)], [National Consensus Standard for CM], [Методология CM],
  [ISO/IEC 20000-1:2018 #cite-src(12)], [IT Service Management], [Управление IT-сервисами],
  [ISO/IEC 25010:2011 #cite-src(21)], [Systems and software Quality], [Модель качества ПО],
) <tbl:design-standards-cm>

== Выводы по разделу 2

+ Разработана и реализована трёхуровневая архитектура системы: *25 модулей → 5 наборов → 13 профилей*.

+ Создана структура репозитория на базе Snowfall Lib общим объёмом *~6 200 LOC* в 70+ основных Nix-файлах.

+ Реализован механизм профилей с наследованием через функции `applyProfile` и `combineProfiles`.

+ Конфигурация хоста vladOS сокращена с ~500 LOC до *~221 LOC* — сокращение на *~56%*; в среднем по трём хостам объём специфичного кода составляет *~192 LOC* (сокращение на *~62%*).

+ Реализована система метаданных хостов и пользователей для автоматической генерации конфигураций.

+ Составлено техническое задание в соответствии с ГОСТ 34.602-2020 с определением требований к функциональности, надёжности и безопасности.

+ Дополнительно реализованы: deploy-rs (CI/CD деплой), nix-topology (визуализация), sops-nix (секреты).
