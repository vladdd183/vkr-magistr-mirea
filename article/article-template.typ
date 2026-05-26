// ============================================================================
// 📄 ШАБЛОН НАУЧНОЙ СТАТЬИ ДЛЯ ПУБЛИКАЦИИ В РИНЦ
// ============================================================================
// Оформление точно соответствует образцу `article/example1.doc`:
//   • Шрифт:          Times New Roman, 14 pt
//   • Поля:           левое 30 мм, правое 15 мм, верх/низ 20 мм
//   • Межстрочный:    одинарный в «шапке», 1.5 в основном тексте
//   • Красная строка: 1.25 см в шапке, 1.5 см в основном тексте
//   • Выравнивание:   УДК и авторы — по правому краю
//                     Название — по центру, заглавные, жирный
//                     Аннотация и текст — по ширине
//   • Подписи таблиц: над таблицей, обычный шрифт, «Таблица 1. Название»
//   • Подписи рисунков: под рисунком, жирный, по центру, «Рисунок 1. Название»
//   • Источник:       курсив, «Источник: …»
//   • Литература:     жирный заголовок «Литература:»
//   • Источники:      «1.<TAB>Название» с табуляцией
//   • Структура IMRAD по-русски:
//        Введение → Цель исследования → Материал и методы исследования →
//        Результаты исследования и их обсуждение → Выводы
// ============================================================================

// ============================================================================
// 🎨 КОНСТАНТЫ ОФОРМЛЕНИЯ
// ============================================================================

#let article-margin-left = 30mm
#let article-margin-right = 15mm
#let article-margin-top = 20mm
#let article-margin-bottom = 20mm

#let article-font-size = 14pt

// Межстрочный интервал в шапке статьи (одинарный)
#let head-leading = 0.65em
// Межстрочный интервал в основном тексте (полуторный)
#let body-leading = 1em

#let head-indent = 1.25cm
#let body-indent = 1.5cm

#let article-main-font = (
  "Times New Roman",
  "Liberation Serif",
  "Noto Serif",
  "DejaVu Serif",
  "PT Serif",
)
#let article-mono-font = (
  "JetBrains Mono",
  "Fira Code",
  "Liberation Mono",
  "DejaVu Sans Mono",
  "Courier New",
)

// ============================================================================
// 🔧 ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
// ============================================================================

/// Ссылка на источник списка литературы: #ref-src(1) → [1]; #ref-src(1, 2) → [1, 2]
#let ref-src(..nums) = {
  let numbers = nums.pos()
  [[#numbers.map(n => str(n)).join(", ")]]
}

/// Диапазон источников: #ref-range(5, 7) → [5–7]
#let ref-range(from, to) = [[#from\–#to]]

/// Таблица по стилю шаблона:
///   • подпись «Таблица N. Название» сверху, обычным шрифтом, по ширине;
///   • границы — одинарные;
///   • «Источник: …» снизу курсивом.
#let article-table(
  columns: (),
  caption: none,
  num: 1,
  source: none,
  ..cells,
) = {
  block(breakable: false, width: 100%, {
    set par(first-line-indent: body-indent, justify: true, leading: body-leading)
    [Таблица #num. #caption]
    v(4pt)
    set par(first-line-indent: 0pt, justify: false, leading: head-leading)
    table(
      columns: columns,
      stroke: 0.5pt + black,
      inset: 6pt,
      align: (col, row) => if row == 0 { center + horizon } else { left + horizon },
      ..cells,
    )
    if source != none {
      v(2pt)
      set par(first-line-indent: 0pt, justify: true, leading: body-leading)
      text(style: "italic")[Источник: #source]
    }
    v(6pt)
  })
}

/// Рисунок с подписью «Рисунок N. Название» под рисунком (жирный, по центру)
/// и опциональным курсивным «Источник: …».
#let article-figure(body, caption: none, num: 1, source: none) = {
  block(breakable: false, width: 100%, {
    set par(first-line-indent: 0pt, justify: false, leading: head-leading)
    align(center)[
      #body
      #v(4pt)
      #text(weight: "bold")[Рисунок #num. #caption]
    ]
    if source != none {
      v(2pt)
      align(center)[#text(style: "italic")[Источник: #source]]
    }
    v(6pt)
  })
}

/// Блок кода/листинга (используется при необходимости).
#let article-listing(body, caption: none, num: 1) = {
  block(breakable: true, width: 100%, {
    set par(first-line-indent: 0pt, justify: false)
    [Листинг #num. #caption]
    v(2pt)
    block(
      fill: luma(248),
      stroke: 0.5pt + luma(180),
      inset: 6pt,
      width: 100%,
      {
        set text(font: article-mono-font, size: 12pt)
        set par(justify: false, leading: 0.65em, first-line-indent: 0pt)
        body
      },
    )
    v(6pt)
  })
}

// ============================================================================
// 📄 НАСТРОЙКА ДОКУМЕНТА
// ============================================================================

#let article-doc(meta, body) = {
  let title-ru = meta.at("title-ru", default: "Название статьи")
  let authors-ru = meta.at("authors-ru", default: ())

  set document(
    title: title-ru,
    author: authors-ru.map(a => a.name).join(", "),
  )

  set text(
    font: article-main-font,
    size: article-font-size,
    lang: "ru",
    region: "RU",
    hyphenate: true,
  )

  set page(
    paper: "a4",
    margin: (
      left: article-margin-left,
      right: article-margin-right,
      top: article-margin-top,
      bottom: article-margin-bottom,
    ),
    numbering: "1",
    number-align: center + bottom,
  )

  // Основной текст: красная строка 1.5 см, межстрочный 1.5, по ширине
  set par(
    justify: true,
    first-line-indent: (amount: body-indent, all: true),
    leading: body-leading,
    spacing: body-leading,
  )

  // Заголовки разделов — обычные «инлайн» в стиле шаблона: жирные, с красной
  // строкой 1.5 см, в одном «логическом абзаце» с основным текстом.
  set heading(numbering: none)
  show heading.where(level: 1): it => {
    block(width: 100%, above: 0.5em, below: 0.3em, {
      set par(first-line-indent: body-indent)
      text(weight: "bold")[#it.body.]
    })
  }
  show heading.where(level: 2): it => {
    block(width: 100%, above: 0.3em, below: 0.2em, {
      set par(first-line-indent: body-indent)
      text(weight: "bold", style: "italic")[#it.body.]
    })
  }

  // Формулы
  set math.equation(
    block: true,
    numbering: "(1)",
    number-align: end + horizon,
  )
  show math.equation.where(block: true): it => {
    v(0.3em)
    it
    v(0.3em)
  }

  // Inline-код
  show raw.where(block: false): box.with(
    fill: luma(245),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  // Списки: без красной строки, плотнее
  show list: it => {
    set par(first-line-indent: 0pt)
    it
  }
  show enum: it => {
    set par(first-line-indent: 0pt)
    it
  }

  body
}

// ============================================================================
// 📄 «ШАПКА» СТАТЬИ — в порядке, точно повторяющем шаблон example1.doc:
//
//   1. УДК                              (правый край, жирный, одинарный)
//   2. Авторы RU (ФИО / Должность / ВУЗ) (правый край, ФИО — жирно)
//   3. Авторы EN                         (правый край, имя — жирно)
//   4. ⬇ две пустые строки
//   5. НАЗВАНИЕ RU (заглавные)           (центр, жирный)
//   6. TITLE EN (заглавные)              (центр, жирный)
//   7. ⬇ пустая строка
//   8. Аннотация: …                      (по ширине, текст курсивом)
//   9. Abstract: …                       (по ширине, текст курсивом)
//   10. ⬇ пустая строка
//   11. Ключевые слова: …                (по ширине, курсивом)
//   12. Key words: …                     (по ширине, курсивом)
//   13. ⬇ пустая строка
// ============================================================================

#let article-header(meta) = {
  let udc = meta.at("udc", default: "")
  let title-ru = meta.at("title-ru", default: "")
  let title-en = meta.at("title-en", default: "")
  let authors-ru = meta.at("authors-ru", default: ())
  let authors-en = meta.at("authors-en", default: ())
  let abstract-ru = meta.at("abstract-ru", default: "")
  let abstract-en = meta.at("abstract-en", default: "")
  let keywords-ru = meta.at("keywords-ru", default: ())
  let keywords-en = meta.at("keywords-en", default: ())

  // 1. УДК
  block(width: 100%, {
    set par(first-line-indent: 0pt, justify: false, leading: head-leading)
    align(right)[#text(weight: "bold")[УДК #udc]]
  })

  // 2. Авторы RU: ФИО (жирно) / Должность / ВУЗ — все по правому краю
  for author in authors-ru {
    block(width: 100%, {
      set par(first-line-indent: 0pt, justify: false, leading: head-leading)
      align(right)[#text(weight: "bold")[#author.name]]
    })
    if author.at("role", default: "") != "" {
      block(width: 100%, {
        set par(first-line-indent: 0pt, justify: false, leading: head-leading)
        align(right)[#author.role]
      })
    }
    if author.at("affiliation", default: "") != "" {
      block(width: 100%, {
        set par(first-line-indent: 0pt, justify: false, leading: head-leading)
        align(right)[#author.affiliation]
      })
    }
  }

  // 3. Авторы EN
  for author in authors-en {
    block(width: 100%, {
      set par(first-line-indent: 0pt, justify: false, leading: head-leading)
      align(right)[#text(weight: "bold")[#author.name]]
    })
    if author.at("role", default: "") != "" {
      block(width: 100%, {
        set par(first-line-indent: 0pt, justify: false, leading: head-leading)
        align(right)[#author.role]
      })
    }
    if author.at("affiliation", default: "") != "" {
      block(width: 100%, {
        set par(first-line-indent: 0pt, justify: false, leading: head-leading)
        align(right)[#author.affiliation]
      })
    }
  }

  // 4. Две пустые строки перед названием
  v(article-font-size * 2)

  // 5. Название RU (центр, заглавные, жирный)
  block(width: 100%, {
    set par(first-line-indent: 0pt, justify: false, leading: head-leading)
    align(center)[#text(weight: "bold")[#upper(title-ru)]]
  })

  // 6. Title EN (центр, заглавные, жирный)
  block(width: 100%, {
    set par(first-line-indent: 0pt, justify: false, leading: head-leading)
    align(center)[#text(weight: "bold")[#upper(title-en)]]
  })

  v(article-font-size)

  // 8. Аннотация RU: префикс обычный, текст курсивом, по ширине, отступ 1.25см
  block(width: 100%, {
    set par(
      first-line-indent: (amount: head-indent, all: true),
      justify: true,
      leading: head-leading,
    )
    [Аннотация: ]
    text(style: "italic")[#abstract-ru]
  })

  // 9. Abstract EN
  block(width: 100%, {
    set par(
      first-line-indent: (amount: head-indent, all: true),
      justify: true,
      leading: head-leading,
    )
    [Abstract: ]
    text(style: "italic")[#abstract-en]
  })

  v(article-font-size)

  // 11. Ключевые слова RU: префикс курсив, текст курсив
  block(width: 100%, {
    set par(
      first-line-indent: (amount: head-indent, all: true),
      justify: true,
      leading: head-leading,
    )
    text(style: "italic")[Ключевые слова]
    [: ]
    text(style: "italic")[#keywords-ru.join("; ").]
  })

  // 12. Key words EN
  block(width: 100%, {
    set par(
      first-line-indent: (amount: head-indent, all: true),
      justify: true,
      leading: head-leading,
    )
    text(style: "italic")[Key words: ]
    text(style: "italic")[#keywords-en.join("; ").]
  })

  v(article-font-size)
}

// ============================================================================
// 📚 БЛОК СПИСКА ЛИТЕРАТУРЫ
//   • Заголовок «Литература:» жирным, с красной строкой 1.5 см
//   • Источники: «1.<TAB>Название» с табуляцией
// ============================================================================

#let article-references(sources) = {
  v(0.5em)
  block(width: 100%, {
    set par(first-line-indent: body-indent, justify: true, leading: body-leading)
    text(weight: "bold")[Литература:]
  })

  for (i, src) in sources.enumerate() {
    block(width: 100%, {
      set par(first-line-indent: body-indent, justify: true, leading: body-leading)
      [#(i + 1). #h(0.5em) #src]
    })
  }
}
