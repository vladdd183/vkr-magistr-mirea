// ============================================================================
// 📄 НАУЧНАЯ СТАТЬЯ ДЛЯ ПУБЛИКАЦИИ В ЖУРНАЛЕ РИНЦ
// ============================================================================
//
// По мотивам ВКР магистра:
//   «Управление конфигурацией вычислительной инфраструктуры на базе
//    декларативной операционной системы»
//
// Соответствует общим требованиям к статьям РИНЦ:
//   - объём: ~10 стр.
//   - структура IMRAD (Introduction → Methods → Results → Discussion);
//   - аннотация и ключевые слова на русском и английском;
//   - список литературы по ГОСТ Р 7.0.5-2008.
//
// Компиляция:
//   typst compile article/article.typ
//   just article            (см. justfile)
// ============================================================================

#import "article-template.typ": (
  article-doc,
  article-header,
  article-references,
)

// ============================================================================
// 🧾 МЕТАДАННЫЕ СТАТЬИ
// ============================================================================

#let article-meta = (
  // ----- УДК -----
  // 004.413 — Программная инженерия. Архитектура программного обеспечения
  // 004.451 — Операционные системы
  udc: "004.413:004.451",

  // ----- Названия (RU/EN) -----
  title-ru: "Модульная архитектура управления конфигурацией " +
    "вычислительной инфраструктуры на базе декларативной " +
    "операционной системы NixOS",
  title-en: "A modular configuration management architecture for " +
    "computing infrastructure based on the declarative operating " +
    "system NixOS",

  // ----- Авторы (RU) — по стилю шаблона: ФИО / Должность / ВУЗ -----
  authors-ru: (
    (
      name: "Сухов Владислав Александрович",
      role: "Магистрант кафедры математического обеспечения и стандартизации " +
        "информационных технологий",
      affiliation: "МИРЭА — Российский технологический университет",
    ),
    // Раскомментируйте и заполните при необходимости (научный руководитель)
    // (
    //   name: "Иванов Иван Иванович",
    //   role: "К.т.н., доцент кафедры математического обеспечения и " +
    //     "стандартизации информационных технологий",
    //   affiliation: "МИРЭА — Российский технологический университет",
    // ),
  ),

  // ----- Авторы (EN) -----
  authors-en: (
    (
      name: "Sukhov Vladislav Aleksandrovich",
      role: "Master's student, Department of Mathematical Support and " +
        "Standardization of Information Technologies",
      affiliation: "MIREA — Russian Technological University",
    ),
  ),

  // ----- Аннотация (RU) — 150–250 слов, по требованиям шаблона -----
  abstract-ru: "В работе рассматривается задача снижения избыточности " +
    "конфигурационного кода и устранения configuration drift при " +
    "управлении вычислительной инфраструктурой, состоящей из " +
    "разнородных хостов. Показано, что традиционные инструменты " +
    "управления конфигурацией реализуют конвергентную модель " +
    "управления состоянием, при которой полное устранение " +
    "конфигурационного дрейфа принципиально невозможно. " +
    "Альтернативой является конгруэнтная модель, реализованная в " +
    "декларативных операционных системах. Предложен интегральный " +
    "показатель качества управления конфигурацией, объединяющий " +
    "коэффициент переиспользования модулей, степень модульности, " +
    "сокращение кода и избыточность с обоснованными весовыми " +
    "коэффициентами и системой ограничений. Разработана " +
    "трёхуровневая архитектура «модули — наборы — профили» с " +
    "механизмом наследования профилей, реализующая конгруэнтную " +
    "модель управления состоянием на базе декларативной операционной " +
    "системы NixOS и фреймворка Snowfall Lib. Экспериментальная " +
    "оценка реализованной системы, управляющей тремя хостами " +
    "различного назначения, продемонстрировала достижение целевых " +
    "значений по четырём показателям из шести. Время подготовки " +
    "нового хоста сокращено с 60–120 до 10–15 минут. По " +
    "интегральному показателю качества разработанная система " +
    "превосходит распространённые конвергентные инструменты в " +
    "1,6–2 раза. Установлен положительный эффект масштаба: при " +
    "расширении инфраструктуры до 10 хостов прогнозируется " +
    "дальнейший рост показателей переиспользования и модульности.",

  // ----- Аннотация (EN) -----
  abstract-en: "The paper addresses the problem of configuration code " +
    "redundancy and configuration drift in the management of " +
    "heterogeneous computing infrastructure. It is shown that " +
    "traditional configuration management tools implement a convergent " +
    "state management model, in which the complete elimination of " +
    "configuration drift is in principle unattainable. An alternative " +
    "is the congruent model implemented in declarative operating " +
    "systems. An integral configuration management quality index is " +
    "proposed that combines the module reusability ratio, modularity, " +
    "code reduction and redundancy with justified weighting " +
    "coefficients and a system of constraints. A three-tier " +
    "architecture “modules — suites — profiles” with a profile " +
    "inheritance mechanism is developed; the architecture implements " +
    "a congruent state management model on top of the declarative " +
    "operating system NixOS and the Snowfall Lib framework. " +
    "Experimental evaluation of the implemented system, managing " +
    "three hosts of different purposes, demonstrated the achievement " +
    "of the target values for four indicators out of six. The time " +
    "required to add a new host was reduced from 60–120 to 10–15 " +
    "minutes. With respect to the integral quality index, the " +
    "proposed system outperforms common convergent tools by a factor " +
    "of 1.6 to 2. A positive scaling effect is established: as the " +
    "infrastructure grows to 10 hosts, a further increase in the " +
    "reusability and modularity indicators is predicted.",

  // ----- Ключевые слова (RU) — 6–8 терминов по требованиям шаблона -----
  keywords-ru: (
    "управление конфигурацией",
    "Infrastructure as Code",
    "NixOS",
    "декларативный подход",
    "модульная архитектура",
    "конгруэнтная модель",
    "Snowfall Lib",
    "DevOps",
  ),

  // ----- Ключевые слова (EN) -----
  keywords-en: (
    "configuration management",
    "Infrastructure as Code",
    "NixOS",
    "declarative approach",
    "modular architecture",
    "congruent model",
    "Snowfall Lib",
    "DevOps",
  ),
)

// ============================================================================
// 📚 СПИСОК ЛИТЕРАТУРЫ (ГОСТ Р 7.0.5-2008)
// ============================================================================
// Источники упорядочены по первому упоминанию в тексте статьи.

#let article-sources = (
  // 1. Uptime Institute (Введение)
  "Annual Outage Analysis 2023: The Causes and Impacts of IT and Data " +
    "Center Outages [Электронный ресурс] / Uptime Institute. — 2023. — " +
    "URL: https://uptimeinstitute.com/uptime_assets/" +
    "5f40588be8d57272f91e4526dc8f821521950b7bec7148f815b6612651d5a9b3-" +
    "annual-outages-analysis-2023.pdf (дата обращения: 14.05.2026).",

  // 2. New Relic (Введение)
  "Industry's Largest Survey Finds Enterprises Realize 2X ROI on " +
    "Observability [Электронный ресурс] / New Relic. — 12.09.2023. — " +
    "URL: https://newrelic.com/press-release/20230912 " +
    "(дата обращения: 14.05.2026).",

  // 3. Aqua Security — Configuration Drift (Введение)
  "Configuration Drift: Why It's Bad and How to Eliminate It " +
    "[Электронный ресурс] / Aqua Security. — 2022. — " +
    "URL: https://www.aquasec.com/cloud-native-academy/" +
    "vulnerability-management/configuration-drift/ " +
    "(дата обращения: 14.05.2026).",

  // 4. EMA / Itential (Введение)
  "The State of Network Automation: Configuration Management Obstacles " +
    "are Universal [Электронный ресурс] / EMA Research, Itential. — " +
    "2021. — URL: https://www.itential.com/what-is-network-automation/" +
    "research-state-of-network-automation/ " +
    "(дата обращения: 14.05.2026).",

  // 5. Kubernetes Docs — Declarative Management (конвергентная модель)
  "Declarative Management of Kubernetes Objects Using Configuration " +
    "Files [Электронный ресурс] / Kubernetes Documentation. — 2023. — " +
    "URL: https://kubernetes.io/docs/tasks/manage-kubernetes-objects/" +
    "declarative-config/ (дата обращения: 14.05.2026).",

  // 6. AWS Well-Architected — Immutable Infrastructure
  "AWS Well-Architected Framework. REL08-BP04: Deploy using immutable " +
    "infrastructure [Электронный ресурс] / Amazon Web Services. — " +
    "10.04.2023. — URL: https://docs.aws.amazon.com/wellarchitected/" +
    "2023-04-10/framework/rel_tracking_change_management_" +
    "immutable_infrastructure.html (дата обращения: 14.05.2026).",

  // 7. NixOS Manual
  "NixOS Manual [Электронный ресурс] / NixOS Project. — " +
    "URL: https://nixos.org/manual/nixos/stable/ " +
    "(дата обращения: 14.05.2026).",

  // 8. DRY principle (TechTarget)
  "What is the DRY (don't repeat yourself) principle? " +
    "[Электронный ресурс] / TechTarget. — 04.08.2025. — " +
    "URL: https://www.techtarget.com/whatis/definition/DRY-principle " +
    "(дата обращения: 14.05.2026).",

  // 9. Snowfall Lib
  "Snowfall Lib Documentation [Электронный ресурс] / " +
    "Snowfall Software. — URL: https://snowfall.org/guides/lib/quickstart/ " +
    "(дата обращения: 14.05.2026).",

  // 10. Puppet State of DevOps 2024
  "State of DevOps Report 2024 [Электронный ресурс] / Puppet by " +
    "Perforce. — 2024. — URL: https://www.puppet.com/resources/" +
    "state-of-devops-report (дата обращения: 14.05.2026).",

  // 11. DevOps market forecast
  "DevOps Market Size, Share & Trends Analysis Report " +
    "[Электронный ресурс] / Polaris Market Research. — 2024. — " +
    "URL: https://www.polarismarketresearch.com/industry-analysis/" +
    "devops-market (дата обращения: 14.05.2026).",

  // 12. IaC market — SNS Insider
  "Infrastructure as Code (IaC) Market Size, Share & Segmentation " +
    "(Global Forecast 2024–2032) [Электронный ресурс] / SNS Insider. — " +
    "2024. — URL: https://www.snsinsider.com/reports/" +
    "infrastructure-as-code-market-4659 (дата обращения: 14.05.2026).",

  // 13. ГОСТ 34.602-2020 (используется при разработке ТЗ в ВКР)
  "ГОСТ 34.602-2020. Информационные технологии. Комплекс стандартов " +
    "на автоматизированные системы. Техническое задание на создание " +
    "автоматизированной системы. — М.: Стандартинформ, 2020.",

  // 14. ISO/IEC 25010:2011
  "ISO/IEC 25010:2011. Systems and Software Engineering. Systems and " +
    "Software Quality Requirements and Evaluation (SQuaRE). System and " +
    "Software Quality Models. — Geneva: ISO, 2011.",

  // 15. ANSI/EIA-649B
  "ANSI/EIA-649B. National Consensus Standard for Configuration " +
    "Management. — Warrendale: SAE International, 2011. — 48 p.",
)

// ============================================================================
// 🚀 ДОКУМЕНТ
// ============================================================================

#show: doc => article-doc(article-meta, doc)

#article-header(article-meta)

#include "article-content.typ"

#article-references(article-sources)
