// ============================================================================
// 📊 ДАННЫЕ СТУДЕНТА
// ============================================================================

#let meta = (
  // === Студент ===
  student: "Сухов Владислав Александрович",
  group: "ИКМО-04-24",
  
  // === Тема работы ===
  title: "Управление конфигурацией вычислительной инфраструктуры на базе декларативной операционной системы",
  
  // === Направление ===
  direction: "09.04.04 «Программная инженерия»",
  profile: "Системная инженерия",
  
  // === Руководитель ===
  supervisor: (
    name: "Руководитель И.О.",
    title: "к.т.н., доцент",
  ),
  
  // === Рецензент ===
  reviewer: (
    name: "Рецензент И.О.",
    title: "к.т.н., доцент",
  ),
  
  // === Заведующий кафедрой ===
  head: (
    name: "Головин Сергей Анатольевич",
    title: "к.т.н., доцент",
  ),
  
  // === Кафедра и институт ===
  department: "Кафедра математического обеспечения и стандартизации информационных технологий",
  institute: "Институт информационных технологий",
  university: "МИРЭА — Российский технологический университет",
  
  // === Год и город ===
  year: "2026",
  city: "Москва",
)

// ============================================================================
// 📖 СПИСОК СОКРАЩЕНИЙ
// ============================================================================

#let abbreviations = (
  (abbr: "ACM", full: "Association for Computing Machinery — Ассоциация вычислительной техники"),
  (abbr: "API", full: "Application Programming Interface — программный интерфейс приложения"),
  (abbr: "BPMN", full: "Business Process Model and Notation — нотация моделирования бизнес‑процессов"),
  (abbr: "CLI", full: "Command Line Interface — интерфейс командной строки"),
  (abbr: "CI/CD", full: "Continuous Integration / Continuous Deployment — непрерывная интеграция и доставка"),
  (abbr: "CM", full: "Configuration Management — управление конфигурацией"),
  (abbr: "CMDB", full: "Configuration Management Database — база данных управления конфигурациями"),
  (abbr: "DRY", full: "Don't Repeat Yourself — принцип «не повторяйся»"),
  (abbr: "DSL", full: "Domain-Specific Language — предметно‑ориентированный язык"),
  (abbr: "DevOps", full: "Development and Operations — практики интеграции разработки и эксплуатации"),
  (abbr: "GPG", full: "GNU Privacy Guard — реализация стандарта OpenPGP"),
  (abbr: "GitOps", full: "GitOps — подход к управлению инфраструктурой, при котором Git является единым источником правды"),
  (abbr: "GPU", full: "Graphics Processing Unit — графический процессор"),
  (abbr: "HCL", full: "HashiCorp Configuration Language — язык конфигурации HashiCorp"),
  (abbr: "IaC", full: "Infrastructure as Code — инфраструктура как код"),
  (abbr: "ISO/IEC", full: "International Organization for Standardization / International Electrotechnical Commission — международные стандарты ISO/IEC"),
  (abbr: "IT", full: "Information Technology — информационные технологии"),
  (abbr: "ITIL", full: "Information Technology Infrastructure Library — библиотека лучших практик управления ИТ"),
  (abbr: "K3s", full: "Lightweight Kubernetes — облегчённый Kubernetes"),
  (abbr: "KVM", full: "Kernel-based Virtual Machine — модуль виртуализации ядра Linux"),
  (abbr: "LOC", full: "Lines of Code — строки кода"),
  (abbr: "MIL-STD", full: "Military Standard — военный стандарт (США)"),
  (abbr: "MTTR", full: "Mean Time to Recovery — среднее время восстановления"),
  (abbr: "NAS", full: "Network Attached Storage — сетевое хранилище"),
  (abbr: "NixOS", full: "Декларативная операционная система на базе пакетного менеджера Nix"),
  (abbr: "OBS", full: "Open Broadcaster Software — программное обеспечение для записи и трансляции"),
  (abbr: "ОС", full: "Операционная система"),
  (abbr: "ПО", full: "Программное обеспечение"),
  (abbr: "QEMU", full: "Quick EMUlator — эмулятор и гипервизор"),
  (abbr: "RCS", full: "Revision Control System — система управления версиями"),
  (abbr: "RDP", full: "Remote Desktop Protocol — протокол удалённого рабочего стола"),
  (abbr: "SCCS", full: "Source Code Control System — система контроля исходного кода"),
  (abbr: "SOSP", full: "Symposium on Operating Systems Principles — симпозиум ACM по принципам операционных систем"),
  (abbr: "SSH", full: "Secure Shell — протокол удалённого управления и передачи данных"),
  (abbr: "SVG", full: "Scalable Vector Graphics — масштабируемая векторная графика"),
  (abbr: "ТЗ", full: "Техническое задание"),
  (abbr: "UML", full: "Unified Modeling Language — унифицированный язык моделирования"),
  (abbr: "URL", full: "Uniform Resource Locator — адрес ресурса"),
  (abbr: "VM", full: "Virtual Machine — виртуальная машина"),
  (abbr: "VPN", full: "Virtual Private Network — виртуальная частная сеть"),
  (abbr: "ВКР", full: "Выпускная квалификационная работа"),
  (abbr: "СКУ", full: "Система управления конфигурацией"),
  (abbr: "YAML", full: "YAML Ain't Markup Language — язык сериализации данных"),
)
