// ============================================================================
// 📚 ШАБЛОН ВКР МАГИСТРА — ГОСТ / МИРЭА
// ============================================================================
// Версия: 2.1 (Модульная архитектура)
// Совместимость: Typst 0.12.0+
//
// Соответствует требованиям:
// - ГОСТ 7.32-2017 (Отчет о НИР)
// - Методические указания МИРЭА (Головин С.А., Муравьёва Е.А., 2023)
// - СМКО МИРЭА 7.5.1/03.П.68-19
//
// Направление: 09.04.04 «Программная инженерия»
// Профиль: «Системная инженерия»
// ============================================================================

// ============================================================================
// 🎨 КОНСТАНТЫ ОФОРМЛЕНИЯ ПО ГОСТ
// ============================================================================

// Размеры полей (ГОСТ: левое 30мм, правое 10мм, верх/низ 20мм)
#let margin-left = 30mm
#let margin-right = 10mm
#let margin-top = 20mm
#let margin-bottom = 20mm

// Размеры шрифтов
#let font-size-main = 14pt
#let font-size-h1 = 18pt
#let font-size-h2 = 16pt
#let font-size-h3 = 14pt
#let font-size-caption = 12pt
#let font-size-code = 11pt

// Интервалы
#let line-spacing = 1.5em
#let par-indent = 1.25cm
#let heading-space-before = 15pt
#let heading-space-after = 10pt

// Шрифты
// Liberation Serif — метрически совместимый с Times New Roman (ГОСТ)
// Порядок: сначала свободные шрифты, затем проприетарные
#let main-font = ("Liberation Serif", "Noto Serif", "DejaVu Serif", "Times New Roman", "PT Serif")
#let mono-font = ("JetBrains Mono", "Fira Code", "Liberation Mono", "DejaVu Sans Mono", "Courier New")

// ============================================================================
// 🔧 ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (экспортируются)
// ============================================================================

/// Ссылка на источник в тексте [номер]
/// Использование: #cite-src(1) или #cite-src(1, 2, 3) для нескольких
/// Методичка стр. 33-34: ссылки в квадратных скобках
#let cite-src(..nums) = {
  let numbers = nums.pos()
  [[#numbers.map(n => str(n)).join(", ")]]
}

/// Диапазон источников [от-до]
/// Использование: #cite-range(1, 5) → [1-5]
#let cite-range(from, to) = {
  [[#from\-#to]]
}

/// Линия для подписи
#let sign-line(width: 3cm) = box(
  width: width,
  stroke: (bottom: 0.5pt + black),
  outset: (bottom: 2pt),
  []
)

/// Блок подписи с расшифровкой
#let signature-block(width: 3.5cm) = {
  grid(
    columns: (width, 0.5cm, width),
    align: center,
    box(width: 100%, stroke: (bottom: 0.5pt + black), outset: (bottom: 2pt))[],
    [/],
    box(width: 100%, stroke: (bottom: 0.5pt + black), outset: (bottom: 2pt))[],
  )
  v(2pt)
  grid(
    columns: (width, 0.5cm, width),
    align: center,
    text(size: 9pt)[(подпись)],
    [],
    text(size: 9pt)[(расшифровка)],
  )
}

/// Рисунок
#let vkr-image(path, caption: none, width: 80%) = {
  figure(
    image(path, width: width),
    caption: caption,
    kind: image,
    supplement: [Рисунок],
  )
}

/// Заглушка для рисунка
#let vkr-placeholder(caption: none, width: 80%, height: 150pt, text-content: [_Здесь будет изображение_]) = {
  figure(
    rect(width: width, height: height, fill: luma(245), stroke: 0.5pt + luma(200),
      align(center + horizon, text-content)),
    caption: caption,
    kind: image,
    supplement: [Рисунок],
  )
}

/// Таблица (короткая)
/// Методичка табл. 5: шрифт содержимого 12пт или 10пт
#let vkr-table(columns: (), caption: none, zebra: false, ..cells) = {
  let fill-fn = if zebra {
    (_, y) => if y > 0 and calc.even(y) { luma(248) }
  } else {
    (_, y) => if y == 0 { luma(240) }
  }
  
  figure(
    block(breakable: false, {
      set text(size: 12pt)  // Методичка: размер шрифта содержимого 12пт
      table(columns: columns, stroke: 0.5pt + black, inset: 8pt,
        align: (col, row) => if row == 0 { center } else { left },
        fill: fill-fn, ..cells)
    }),
    caption: caption,
    kind: table,
    supplement: [Таблица],
  )
}

/// Длинная таблица (может разрываться)
/// Методичка табл. 5: шрифт содержимого 12пт или 10пт
#let vkr-long-table(columns: (), caption: none, header: (), zebra: false, ..cells) = {
  let fill-fn = if zebra {
    (_, y) => if y > 0 and calc.even(y) { luma(248) }
  } else {
    (_, y) => if y == 0 { luma(240) }
  }
  
  figure(
    block(breakable: true, {
      set text(size: 12pt)  // Методичка: размер шрифта содержимого 12пт
      table(columns: columns, stroke: 0.5pt + black, inset: 8pt,
        align: (col, row) => if row == 0 { center } else { left },
        fill: fill-fn, table.header(repeat: true, ..header), ..cells)
    }),
    caption: caption,
    kind: table,
    supplement: [Таблица],
  )
}

/// Листинг кода
#let vkr-code(code, caption: none, lang: none, line-numbers: true) = {
  figure(
    block(
      fill: luma(248),
      stroke: (left: 3pt + rgb("#492F8C"), rest: 0.5pt + luma(200)),
      inset: 0pt,
      width: 100%,
      breakable: true,
      {
        set text(font: mono-font, size: font-size-code)
        set par(justify: false, leading: 0.6em)
        
        if line-numbers {
          show raw.line: it => {
            box(width: 100%, inset: (x: 8pt, y: 2pt),
              grid(columns: (25pt, 1fr), column-gutter: 8pt,
                align(right, text(fill: luma(150), size: 0.9em, str(it.number))),
                it.body))
          }
        }
        
        raw(code, lang: lang, block: true)
      }
    ),
    caption: caption,
    kind: "listing",
    supplement: [Листинг],
  )
}

/// Листинг из файла
#let vkr-code-file(path, caption: none, lang: auto, line-numbers: true) = {
  let code = read(path)
  let detected-lang = if lang == auto {
    let ext = path.split(".").last()
    (py: "python", js: "javascript", ts: "typescript", rs: "rust", go: "go",
     java: "java", c: "c", cpp: "cpp", sql: "sql", typ: "typst", html: "html",
     css: "css", json: "json", yaml: "yaml", sh: "bash").at(ext, default: none)
  } else { lang }
  
  vkr-code(code, caption: caption, lang: detected-lang, line-numbers: line-numbers)
}

// ============================================================================
// 📄 ФУНКЦИЯ НАСТРОЙКИ ДОКУМЕНТА
// ============================================================================

#let vkr-doc(meta, body) = {
  // Извлекаем метаданные
  let student = meta.at("student", default: "ФИО студента")
  let title = meta.at("title", default: "Тема работы")
  
  // Метаданные PDF
  set document(title: title, author: student)
  
  // Язык и шрифт
  set text(font: main-font, size: font-size-main, lang: "ru", region: "RU", hyphenate: true)
  
  // Страница
  set page(
    paper: "a4",
    margin: (left: margin-left, right: margin-right, top: margin-top, bottom: margin-bottom),
    numbering: "1",
    number-align: center + bottom,
  )
  
  // Абзацы
  set par(justify: true, first-line-indent: par-indent, leading: line-spacing, spacing: line-spacing)
  
  // Заголовки
  set heading(numbering: "1.1.1")
  
  // Сброс счётчиков при новом разделе
  show heading.where(level: 1): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: "listing")).update(0)
    counter(math.equation).update(0)
    
    pagebreak(weak: true)
    v(0pt)
    
    block(width: 100%, {
      set text(size: font-size-h1, weight: "bold")
      set par(first-line-indent: 0pt, leading: 1em)
      // ГОСТ: все заголовки 1 уровня по левому краю с отступом 1,25 см
      if it.numbering != none {
        pad(left: par-indent)[#counter(heading).display() #h(0.5em) #upper(it.body)]
      } else {
        // Ненумерованные заголовки тоже по левому краю (методичка, табл. 3)
        pad(left: par-indent)[#upper(it.body)]
      }
    })
    v(heading-space-after)
  }
  
  show heading.where(level: 2): it => {
    v(heading-space-before)
    block(width: 100%, {
      set text(size: font-size-h2, weight: "bold")
      set par(first-line-indent: 0pt)
      pad(left: par-indent)[#counter(heading).display() #h(0.5em) #it.body]
    })
    v(heading-space-after)
  }
  
  show heading.where(level: 3): it => {
    v(heading-space-before)
    block(width: 100%, {
      set text(size: font-size-h3, weight: "bold")
      set par(first-line-indent: 0pt)
      pad(left: par-indent)[#counter(heading).display() #h(0.5em) #it.body]
    })
    v(heading-space-after)
  }
  
  // Рисунки
  set figure.caption(separator: [ — ])
  
  show figure.where(kind: image): it => {
    block(breakable: false, width: 100%, {
      set par(first-line-indent: 0pt)
      align(center)[
        #it.body
        #v(6pt)
        #text(size: font-size-caption)[
          Рисунок #context {
            let ch = counter(heading.where(level: 1)).get().first()
            if ch == 0 { ch = 1 }
            let num = counter(figure.where(kind: image)).get().first()
            [#ch.#num]
          }
          #if it.caption != none [ — #it.caption.body]
        ]
      ]
      v(6pt)
    })
  }
  
  // Таблицы
  show figure.where(kind: table): it => {
    block(breakable: false, width: 100%, {
      set par(first-line-indent: 0pt)
      v(6pt)
      text(size: font-size-main, style: "italic")[
        Таблица #context {
          let ch = counter(heading.where(level: 1)).get().first()
          if ch == 0 { ch = 1 }
          let num = counter(figure.where(kind: table)).get().first()
          [#ch.#num]
        }
        #if it.caption != none [ — #it.caption.body]
      ]
      v(6pt)
      it.body
      v(6pt)
    })
  }
  
  // Листинги
  show figure.where(kind: "listing"): it => {
    block(breakable: true, width: 100%, {
      set par(first-line-indent: 0pt)
      v(6pt)
      text(size: font-size-main, style: "italic")[
        Листинг #context {
          let ch = counter(heading.where(level: 1)).get().first()
          if ch == 0 { ch = 1 }
          let num = counter(figure.where(kind: "listing")).get().first()
          [#ch.#num]
        }
        #if it.caption != none [ — #it.caption.body]
      ]
      v(6pt)
      it.body
      v(6pt)
    })
  }
  
  // Формулы
  // Методичка стр. 32: "Над и под каждой формулой должно быть оставлено не менее одной свободной строки"
  set math.equation(
    block: true,
    numbering: num => context {
      let ch = counter(heading.where(level: 1)).get().first()
      if ch == 0 { ch = 1 }
      [(#ch.#num)]
    },
    number-align: end + horizon,
  )
  
  // Отступы до и после формул (минимум 1 строка = 1em при полуторном интервале)
  show math.equation.where(block: true): it => {
    v(0.5em)
    it
    v(0.5em)
  }
  
  // Списки
  set list(indent: par-indent, marker: [—])
  set enum(indent: par-indent)
  
  // Inline код
  show raw.where(block: false): box.with(
    fill: luma(245), inset: (x: 3pt, y: 0pt), outset: (y: 3pt), radius: 2pt)
  
  body
}

// ============================================================================
// 📄 ТИТУЛЬНЫЙ ЛИСТ
// ============================================================================

#let vkr-title-page(meta) = {
  let student = meta.at("student", default: "ФИО студента")
  let group = meta.at("group", default: "Группа")
  let title = meta.at("title", default: "Тема работы")
  let direction = meta.at("direction", default: "09.04.04 «Программная инженерия»")
  let profile = meta.at("profile", default: "Системная инженерия")
  let supervisor = meta.at("supervisor", default: (name: "ФИО руководителя", title: "к.т.н., доцент"))
  let reviewer = meta.at("reviewer", default: (name: "ФИО рецензента", title: "к.т.н., доцент"))
  let head = meta.at("head", default: (name: "ФИО зав. кафедрой", title: "д.т.н., профессор"))
  let department = meta.at("department", default: "Кафедра")
  let institute = meta.at("institute", default: "Институт")
  let university = meta.at("university", default: "МИРЭА — Российский технологический университет")
  let year = meta.at("year", default: str(datetime.today().year()))
  let city = meta.at("city", default: "Москва")
  
  set page(numbering: none)
  
  align(center)[
    #text(size: 12pt)[
      МИНОБРНАУКИ РОССИИ \
      Федеральное государственное бюджетное образовательное учреждение \
      высшего образования \
      *«#university»* \
      #v(0.5em)
      #institute \
      #department
    ]
  ]
  
  v(1fr)
  
  align(center)[
    #text(size: 14pt, weight: "bold")[
      ВЫПУСКНАЯ КВАЛИФИКАЦИОННАЯ РАБОТА \
      (МАГИСТЕРСКАЯ ДИССЕРТАЦИЯ)
    ]
    #v(1em)
    #text(size: 12pt)[на тему:]
    #v(0.5em)
    #text(size: 16pt, weight: "bold")[«#title»]
  ]
  
  v(1fr)
  
  align(right)[
    #table(columns: (auto, auto), stroke: none, inset: (x: 0pt, y: 3pt), align: (right, left),
      [Направление подготовки:], [#direction],
      [Профиль:], [#profile],
    )
  ]
  
  v(1em)
  
  align(right)[
    #table(columns: (auto, auto), stroke: none, inset: (x: 0pt, y: 3pt), align: (right, left),
      [Выполнил студент:], [#student],
      [Группа:], [#group],
      [], [],
      [Научный руководитель:], [#supervisor.title],
      [], [#supervisor.name],
      [], [],
      [Рецензент:], [#reviewer.title],
      [], [#reviewer.name],
    )
  ]
  
  v(1em)
  
  align(center)[
    #block(width: 70%)[
      #align(left)[
        Допущен к защите: \
        Заведующий кафедрой \
        #text(style: "italic")[#head.title] \
        #head.name
      ]
      #v(0.8em)
      #signature-block()
    ]
  ]
  
  v(1fr)
  
  align(center)[#city, #year]
  
  pagebreak()
}

// ============================================================================
// 📄 ЗАДАНИЕ (заглушка)
// ============================================================================

#let vkr-assignment(meta) = {
  // Методичка стр. 22: на странице задания номер не указывается
  set page(numbering: none)
  
  let student = meta.at("student", default: "ФИО студента")
  let title = meta.at("title", default: "Тема работы")
  let supervisor = meta.at("supervisor", default: (name: "ФИО руководителя", title: "к.т.н., доцент"))
  
  // Заголовок по левому краю с отступом (методичка, табл. 3)
  block(width: 100%, {
    set text(size: font-size-h1, weight: "bold")
    pad(left: par-indent)[
      ЗАДАНИЕ \
      НА ВЫПУСКНУЮ КВАЛИФИКАЦИОННУЮ РАБОТУ
    ]
  })
  v(2em)
  text[_Данная страница — заглушка. Замените на отсканированное задание._]
  v(1em)
  [Студент: #student]
  v(0.5em)
  [Тема работы: «#title»]
  v(0.5em)
  [Научный руководитель: #supervisor.name, #supervisor.title]
  
  pagebreak()
}

// ============================================================================
// 📄 АННОТАЦИЯ
// ============================================================================

#let vkr-annotation(body) = {
  // Методичка стр. 5: "Аннотация не нумеруется!"
  set page(numbering: none)
  
  // Заголовок по левому краю с отступом (как все заголовки 1 уровня)
  block(width: 100%, {
    set text(size: font-size-h1, weight: "bold")
    pad(left: par-indent)[АННОТАЦИЯ]
  })
  v(heading-space-after * 2)
  
  body
  
  v(1em)
  
  table(columns: (auto, auto), stroke: none, inset: (x: 0pt, y: 4pt),
    [Расчётно-пояснительная записка:], [#sign-line(width: 1.5cm) страниц],
    [Количество рисунков:], [#sign-line(width: 1.5cm) шт.],
    [Количество таблиц:], [#sign-line(width: 1.5cm) шт.],
    [Количество приложений:], [#sign-line(width: 1.5cm) шт.],
    [Количество источников:], [#sign-line(width: 1.5cm) шт.],
  )
  
  pagebreak()
}

// ============================================================================
// 📄 СОДЕРЖАНИЕ
// ============================================================================

#let vkr-toc() = {
  set page(numbering: "1")
  counter(page).update(4)
  
  // Заголовок по левому краю с отступом (методичка, табл. 3)
  block(width: 100%, {
    set text(size: font-size-h1, weight: "bold")
    pad(left: par-indent)[СОДЕРЖАНИЕ]
  })
  v(heading-space-after)
  
  show outline.entry.where(level: 1): it => {
    v(0.3em)
    strong(it)
  }
  
  outline(title: none, depth: 3, indent: auto)
  
  pagebreak()
}

// ============================================================================
// 📄 СПИСОК СОКРАЩЕНИЙ
// ============================================================================

#let vkr-abbreviations(items) = {
  heading(level: 1, numbering: none, outlined: true)[Список используемых сокращений]
  
  set par(first-line-indent: 0pt)
  
  table(columns: (auto, 1fr), stroke: none, inset: (x: 0pt, y: 4pt),
    ..items.map(a => ([*#a.abbr*], a.full)).flatten())
  
  pagebreak()
}

// ============================================================================
// 📄 СПИСОК ИСТОЧНИКОВ
// ============================================================================

#let vkr-sources(sources) = {
  // Методичка табл. 6: заголовок по центру, обычный шрифт, все прописные
  // НО: это противоречит табл. 3 для заголовков 1 уровня
  // Используем стандартный heading чтобы попасть в содержание
  heading(level: 1, numbering: none, outlined: true)[Список используемых источников]
  
  set par(first-line-indent: 0pt)
  
  if type(sources) == str and (sources.ends-with(".yaml") or sources.ends-with(".bib")) {
    // Файл библиографии
    show bibliography: it => {
      set par(first-line-indent: 0pt)
      it
    }
    bibliography(sources, title: none, style: "gost-r-705-2008-numeric")
  } else if type(sources) == array {
    // Ручной список (массив строк или content)
    for (i, src) in sources.enumerate() {
      grid(columns: (auto, 1fr), gutter: 0.5em, [#(i + 1).], [#src])
      v(0.3em)
    }
  }
  
  pagebreak()
}

// ============================================================================
// 📄 ПРИЛОЖЕНИЯ
// ============================================================================

#let vkr-appendix(letter, title, body) = {
  pagebreak()
  
  // Методичка стр. 36: "Приложение" по центру
  // Но заголовок приложения — это заголовок 1 уровня, значит по левому краю
  // Компромисс: слово "ПРИЛОЖЕНИЕ X" по центру (как в методичке рис. 27), заголовок ниже
  align(center)[
    #text(size: font-size-h1, weight: "bold")[ПРИЛОЖЕНИЕ #letter]
  ]
  v(heading-space-after)
  
  // Название приложения по левому краю с отступом
  block(width: 100%, {
    set text(size: font-size-h2, weight: "bold")
    pad(left: par-indent)[#title]
  })
  v(heading-space-after * 2)
  
  body
}

#let vkr-appendices-toc(items) = {
  heading(level: 1, numbering: none, outlined: true)[Приложения]
  
  set par(first-line-indent: 0pt)
  
  // Методичка стр. 36: исключаются буквы Е, З, Й, О, Ч, Ь, Ы, Ъ
  let letters = ("А", "Б", "В", "Г", "Д", "Ж", "И", "К", "Л", "М", "Н", "П", "Р", "С", "Т", "У", "Ф", "Х", "Ц", "Ш", "Щ", "Э", "Ю", "Я")
  
  table(columns: (auto, 1fr), stroke: none, inset: (x: 0pt, y: 6pt),
    ..items.enumerate().map(((i, title)) => {
      let letter = letters.at(i, default: str(i + 1))
      ([*Приложение #letter*], title)
    }).flatten())
}
