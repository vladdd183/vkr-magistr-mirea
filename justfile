# ============================================================================
# 📚 КОМАНДЫ ДЛЯ ВКР МАГИСТРА МИРЭА
# ============================================================================

# Скомпилировать PDF
build:
    typst compile main.typ

# Watch режим (автообновление)
watch:
    typst watch main.typ

# Удалить PDF
clean:
    rm -f main.pdf

# Открыть PDF
open:
    xdg-open main.pdf 2>/dev/null || open main.pdf 2>/dev/null || start main.pdf

# Скомпилировать и открыть
run: build open

# ============================================================================
# 📥 РАБОТА С ИСХОДНЫМИ МАТЕРИАЛАМИ (input/)
# ============================================================================

# Показать статус папки input
input-status:
    @echo "📥 Материалы в input/:"
    @echo ""
    @echo "📝 Черновики (drafts/):"
    @ls -la input/drafts/ 2>/dev/null | grep -v "^total\|^d\|gitkeep" || echo "   (пусто)"
    @echo ""
    @echo "💻 Код (code/):"
    @ls -la input/code/ 2>/dev/null | grep -v "^total\|^d\|gitkeep" || echo "   (пусто)"
    @echo ""
    @echo "📊 Данные (data/):"
    @ls -la input/data/ 2>/dev/null | grep -v "^total\|^d\|gitkeep" || echo "   (пусто)"
    @echo ""
    @echo "📚 Источники (references/):"
    @ls -la input/references/ 2>/dev/null | grep -v "^total\|^d\|gitkeep" || echo "   (пусто)"

# Подсчитать объём материалов
input-stats:
    @echo "📊 Статистика материалов:"
    @echo ""
    @echo "Черновики:"
    @find input/drafts -type f ! -name ".gitkeep" -exec wc -l {} + 2>/dev/null | tail -1 || echo "   0 строк"
    @echo ""
    @echo "Код:"
    @find input/code -type f ! -name ".gitkeep" -exec wc -l {} + 2>/dev/null | tail -1 || echo "   0 строк"
    @echo ""
    @echo "Всего файлов:"
    @find input -type f ! -name ".gitkeep" ! -name "README.md" | wc -l

# Скопировать изображения из input/data в images/
copy-images:
    @echo "📷 Копирование изображений..."
    @cp input/data/*.png images/ 2>/dev/null || true
    @cp input/data/*.jpg images/ 2>/dev/null || true
    @cp input/data/*.jpeg images/ 2>/dev/null || true
    @cp input/data/*.svg images/ 2>/dev/null || true
    @cp -r input/data/screenshots/* images/ 2>/dev/null || true
    @cp -r input/data/diagrams/* images/ 2>/dev/null || true
    @echo "✅ Готово. Изображения в images/:"
    @ls images/ | grep -v ".gitkeep" || echo "   (пусто)"

# ============================================================================
# 📁 СТРУКТУРА И СПРАВКА
# ============================================================================

# Показать структуру проекта
tree:
    @echo "📁 Структура проекта:"
    @echo ""
    @echo "  main.typ              — точка входа"
    @echo "  meta.typ              — данные студента"
    @echo "  template.typ          — шаблон (не трогай!)"
    @echo "  sources.typ           — список источников"
    @echo ""
    @echo "  chapters/"
    @echo "    00-annotation.typ   — аннотация"
    @echo "    01-intro.typ        — введение"
    @echo "    02-research.typ     — раздел 1"
    @echo "    03-design.typ       — раздел 2"
    @echo "    04-tech.typ         — раздел 3"
    @echo "    05-conclusion.typ   — заключение"
    @echo ""
    @echo "  appendices/           — приложения"
    @echo "  images/               — изображения"
    @echo ""
    @echo "  input/                — ⛔ ИСХОДНЫЕ МАТЕРИАЛЫ (только чтение!)"
    @echo "    drafts/             — черновики текстов"
    @echo "    code/               — исходный код"
    @echo "    data/               — данные, скриншоты"
    @echo "    references/         — источники литературы"

# Справка
help:
    @echo "📚 Команды для ВКР магистра МИРЭА"
    @echo ""
    @echo "🔨 Сборка:"
    @echo "  just build        — скомпилировать PDF"
    @echo "  just watch        — автообновление при изменениях"
    @echo "  just run          — скомпилировать и открыть"
    @echo "  just open         — открыть PDF"
    @echo "  just clean        — удалить PDF"
    @echo ""
    @echo "📥 Материалы (input/):"
    @echo "  just input-status — показать что есть в input/"
    @echo "  just input-stats  — статистика по материалам"
    @echo "  just copy-images  — скопировать картинки в images/"
    @echo ""
    @echo "📁 Прочее:"
    @echo "  just tree         — показать структуру"
    @echo "  just help         — эта справка"
