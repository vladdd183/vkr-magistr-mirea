// ============================================================================
// 📚 СПИСОК ИСТОЧНИКОВ
// ============================================================================
// 
// ИСПОЛЬЗОВАНИЕ ССЫЛОК В ТЕКСТЕ:
// 
// 1. Импортируй функции в файле главы:
//    #import "../template.typ": cite-src, cite-range
//
// 2. Используй в тексте:
//    - #cite-src(1)           → [1]
//    - #cite-src(1, 2, 3)     → [1, 2, 3]
//    - #cite-range(5, 7)      → [5-7]
//
// ============================================================================

#let sources = (
  // ВАЖНО: список упорядочен по первому упоминанию в тексте (методичка МИРЭА).
  // Используем только те источники, на которые есть ссылки в главах.
  // Для web-источников: формат «Название [Электронный ресурс] / Автор. — Дата. — URL: ... (дата обращения: ...)»

  // --- Научные публикации и исследования ---
  "Annual Outage Analysis 2023: The causes and impacts of IT and data center outages [Электронный ресурс] / Uptime Institute. — 03.2023. — URL: https://uptimeinstitute.com/uptime_assets/5f40588be8d57272f91e4526dc8f821521950b7bec7148f815b6612651d5a9b3-annual-outages-analysis-2023.pdf (дата обращения: 31.01.2026).",

  // --- Электронные ресурсы и отчёты (web) ---
  "Configuration Drift: Why It's Bad and How to Eliminate It [Электронный ресурс] / Aqua Security. — 2022. — URL: https://www.aquasec.com/cloud-native-academy/vulnerability-management/configuration-drift/ (дата обращения: 31.01.2026).",
  "Why Configuration Drift Is a Growing Concern for IT Managers in 2025 [Электронный ресурс] / Josys. — 2025. — URL: https://www.josys.com/article/saas-security-why-configuration-drift-is-a-growing-concern-for-it-managers-in-2025 (дата обращения: 31.01.2026).",
  "The State of Network Automation: Configuration Management Obstacles are Universal [Электронный ресурс] / EMA Research, Itential. — 2021. — URL: https://www.itential.com/what-is-network-automation/research-state-of-network-automation/ (дата обращения: 31.01.2026).",
  "Industry's Largest Survey Finds Enterprises Realize 2X ROI on Observability [Электронный ресурс] / New Relic. — 12.09.2023. — URL: https://newrelic.com/press-release/20230912 (дата обращения: 31.01.2026).",
  "State of DevOps Report 2024 [Электронный ресурс] / Puppet. — 2024. — URL: https://www.puppet.com/resources/state-of-devops-report (дата обращения: 31.01.2026).",
  "DevOps Market Size, Share & Trends Analysis Report [Электронный ресурс] / Polaris Market Research. — 2024. — URL: https://www.polarismarketresearch.com/industry-analysis/devops-market (дата обращения: 31.01.2026).",

  // --- Монографии и учебные издания ---
  "What is the DRY principle? [Электронный ресурс] / TechTarget. — 04.08.2025. — URL: https://www.techtarget.com/whatis/definition/DRY-principle (дата обращения: 31.01.2026).",

  // --- Документация ---
  "NixOS Manual [Электронный ресурс]. — URL: https://nixos.org/manual/nixos/stable/ (дата обращения: 31.01.2026).",

  // --- Нормативные документы и стандарты ---
  "ГОСТ 34.602-2020. Техническое задание на создание автоматизированной системы.",
  "ANSI/EIA-649B. National Consensus Standard for Configuration Management. — SAE International, 2011. — 48 p.",
  "ISO/IEC 20000-1:2018. Information technology — Service management — Part 1: Service management system requirements.",

  // --- Электронные ресурсы (web) ---
  "What is configuration management? A comprehensive guide [Электронный ресурс] / TechTarget. — 01.10.2024. — URL: https://www.techtarget.com/searchitoperations/definition/configuration-management-CM (дата обращения: 31.01.2026).",
  "What is Infrastructure as Code (IaC)? [Электронный ресурс] / Red Hat. — 2025. — URL: https://www.redhat.com/en/topics/automation/what-is-infrastructure-as-code-iac (дата обращения: 31.01.2026).",
  "Infrastructure as Code (IaC) Market Size, Share & Segmentation (Global Forecast 2024–2032) [Электронный ресурс] / SNS Insider. — 2024. — URL: https://www.snsinsider.com/reports/infrastructure-as-code-market-4659 (дата обращения: 31.01.2026).",
  "Declarative Management of Kubernetes Objects Using Configuration Files [Электронный ресурс] / Kubernetes Documentation. — 24.08.2023. — URL: https://kubernetes.io/docs/tasks/manage-kubernetes-objects/declarative-config/ (дата обращения: 31.01.2026).",

  // --- Практики неизменяемой инфраструктуры (immutable infrastructure) ---
  "AWS Well-Architected Framework: REL08-BP04 Deploy using immutable infrastructure [Электронный ресурс] / AWS. — 10.04.2023. — URL: https://docs.aws.amazon.com/wellarchitected/2023-04-10/framework/rel_tracking_change_management_immutable_infrastructure.html (дата обращения: 31.01.2026).",

  // --- Документация ---
  "Snowfall Lib Documentation [Электронный ресурс]. — URL: https://snowfall.org/guides/lib/quickstart/ (дата обращения: 31.01.2026).",

  // --- Нормативные документы и стандарты ---
  "ГОСТ 34.601-90. Автоматизированные системы. Стадии создания.",
  "ГОСТ 19.201-78. Техническое задание. Требования к содержанию и оформлению.",
  "ISO/IEC 25010:2011. Systems and software engineering — Systems and software Quality Requirements and Evaluation (SQuaRE) — System and software quality models.",
)
