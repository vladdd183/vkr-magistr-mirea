#!/usr/bin/env python3
"""
Заменяем плейсхолдеры (выделенные жёлтым) в комплекте по преддипломной практике
данными студента Сухова В.А. и снимаем жёлтое выделение. Шрифт и стили рантаймов
сохраняются (правится только текст и highlight_color).

Запуск:
    uv run --with python-docx --no-project python3 tools/fix_preddiplomka_yellow.py <doc.docx> [--dry-run]
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

from docx import Document
from docx.enum.text import WD_COLOR_INDEX
from docx.text.paragraph import Paragraph


REPLACEMENTS: list[tuple[str, str]] = [
    ("Иванову Ивану Ивановичу", "Сухову Владиславу Александровичу"),
    ("Иванова И.И", "Сухова В.А"),
    ("Иванов И.И", "Сухов В.А"),
    ("Смирнов С.С", "Краснов А.Е"),
    ("к.т.н., доцент", "д.ф.-м.н., профессор"),
]


def iter_paragraphs(container) -> list[Paragraph]:
    out: list[Paragraph] = []

    def walk(c):
        for p in getattr(c, "paragraphs", []):
            out.append(p)
        for t in getattr(c, "tables", []):
            for row in t.rows:
                for cell in row.cells:
                    walk(cell)

    walk(container)
    return out


def collect_paragraphs(doc):
    paragraphs: list[Paragraph] = []
    paragraphs.extend(iter_paragraphs(doc))
    for section in doc.sections:
        for hf in (
            section.header,
            section.footer,
            section.first_page_header,
            section.first_page_footer,
            section.even_page_header,
            section.even_page_footer,
        ):
            try:
                paragraphs.extend(iter_paragraphs(hf))
            except Exception:
                pass
    return paragraphs


def process_run(run, dry_run: bool, log: list[str]) -> bool:
    if run.font.highlight_color != WD_COLOR_INDEX.YELLOW:
        return False
    old_text = run.text
    new_text = old_text
    for src, dst in REPLACEMENTS:
        new_text = new_text.replace(src, dst)
    changed_text = new_text != old_text
    log.append(f"  run: {old_text!r} -> {new_text!r} (text_changed={changed_text})")
    if not dry_run:
        if changed_text:
            run.text = new_text
        run.font.highlight_color = None
    return True


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("path")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    path = Path(args.path)
    doc = Document(str(path))

    log: list[str] = []
    total = 0
    for p in collect_paragraphs(doc):
        para_text = p.text
        runs_yellow = [r for r in p.runs if r.font.highlight_color == WD_COLOR_INDEX.YELLOW]
        if not runs_yellow:
            continue
        log.append(f"P: {para_text!r}")
        for r in p.runs:
            if process_run(r, args.dry_run, log):
                total += 1

    print("\n".join(log))
    print(f"\n[YELLOW RUNS PROCESSED]: {total}")

    # Also strip yellow highlights from paragraph-mark run properties (pPr/rPr/highlight)
    # which python-docx's Run iterator does not expose. These don't affect visible text
    # but Word still shows the paragraph mark as highlighted.
    W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    W_HIGHLIGHT = f"{{{W_NS}}}highlight"
    W_VAL = f"{{{W_NS}}}val"

    pmark_removed = 0
    parts_to_scan = [doc.part]
    for rel in doc.part.rels.values():
        if rel.reltype.endswith("/header") or rel.reltype.endswith("/footer"):
            parts_to_scan.append(rel.target_part)

    for part in parts_to_scan:
        xml_root = getattr(part, "element", None) or getattr(part, "_element", None)
        if xml_root is None:
            continue
        # iter() in lxml visits all descendants; collect first, then remove
        to_remove = [
            hl for hl in xml_root.iter(W_HIGHLIGHT) if hl.get(W_VAL) == "yellow"
        ]
        for hl in to_remove:
            parent = hl.getparent()
            if parent is not None:
                parent.remove(hl)
                pmark_removed += 1

    print(f"[PARAGRAPH-MARK / LEFTOVER YELLOW HIGHLIGHTS REMOVED]: {pmark_removed}")

    if not args.dry_run:
        doc.save(str(path))
        print(f"[SAVED]: {path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
