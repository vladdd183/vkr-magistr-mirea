// ============================================================================
// 📚 ВЫПУСКНАЯ КВАЛИФИКАЦИОННАЯ РАБОТА МАГИСТРА
// ============================================================================
//
// Структура проекта:
//   main.typ           — этот файл (точка входа)
//   meta.typ           — данные студента
//   template.typ       — шаблон (не трогай!)
//   chapters/          — главы работы
//   appendices/        — приложения
//   references.yaml    — библиография
//   images/            — изображения
//
// Компиляция:
//   typst compile main.typ
//   typst watch main.typ
//
// ============================================================================

// Импорт шаблона, метаданных и источников
#import "template.typ": *
#import "meta.typ": meta, abbreviations
#import "sources.typ": sources

// ============================================================================
// 🚀 ДОКУМЕНТ
// ============================================================================

#show: doc => vkr-doc(meta, doc)

// === ТИТУЛЬНЫЙ ЛИСТ ===
#vkr-title-page(meta)

// === ЗАДАНИЕ (заглушка) ===
#vkr-assignment(meta)

// === АННОТАЦИЯ ===
#vkr-annotation(include "chapters/00-annotation.typ")

// === СОДЕРЖАНИЕ ===
#vkr-toc()

// === СПИСОК СОКРАЩЕНИЙ ===
#vkr-abbreviations(abbreviations)

// === ВВЕДЕНИЕ ===
#include "chapters/01-intro.typ"

// === РАЗДЕЛ 1: ИССЛЕДОВАТЕЛЬСКИЙ ===
#include "chapters/02-research.typ"

// === РАЗДЕЛ 2: ПРОЕКТНЫЙ ===
#include "chapters/03-design.typ"

// === РАЗДЕЛ 3: ТЕХНОЛОГИЧЕСКИЙ ===
#include "chapters/04-tech.typ"

// === ЗАКЛЮЧЕНИЕ ===
#include "chapters/05-conclusion.typ"

// === СПИСОК ИСТОЧНИКОВ ===
// Источники определены в sources.typ — редактируй там!
// Или используй YAML: #vkr-sources("references.yaml")
#vkr-sources(sources)

// === ПРИЛОЖЕНИЯ ===
#vkr-appendices-toc((
  "Листинги ключевых модулей системы vladOS",
  "Конфигурации хостов и определения профилей",
))

#include "appendices/appendix-a.typ"
#include "appendices/appendix-b.typ"
