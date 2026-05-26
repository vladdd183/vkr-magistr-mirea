#!/usr/bin/env python3
"""
Пересчёт метрик качества конфигурационной системы vladOS-v2 по исходному коду.

Цель скрипта — дать воспроизводимые числа для вставки в ВКР:
  - R (переиспользование)
  - M (модульность)
  - S (сокращение кода)
  - C (избыточность/дублирование)
  - Q_CM (интегральный индекс качества)

Скрипт НЕ требует внешних пакетов.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re
from typing import Dict, Iterable, List, Optional, Set, Tuple


# =============================================================================
# Настройки (при необходимости можно менять)
# =============================================================================

REPO_ROOT = Path(__file__).resolve().parents[1]
VLADOS_ROOT = REPO_ROOT / "input" / "code" / "vladOS-v2"

# Базовая оценка объёма изолированной конфигурации на 1 хост (используется для S).
# В исходном тексте ВКР это «экспертная оценка изолированного варианта».
ISOLATED_LOC_PER_HOST = 500

# Весовые коэффициенты для Q_CM
W_R = 0.35
W_M = 0.25
W_S = 0.25
W_C = 0.15

# Параметры детектора дублирования для C
DUP_KGRAM = 3
DUP_MIN_LINE_LEN = 20


# =============================================================================
# Вспомогательные функции
# =============================================================================


def loc_total_lines(path: Path) -> int:
    """LOC как число строк файла (wc -l style), включая комментарии и пустые строки."""
    with path.open("r", encoding="utf-8", errors="ignore") as f:
        return sum(1 for _ in f)


def norm_ws(s: str) -> str:
    return " ".join(s.strip().split())


_RE_ONLY_PUNCT = re.compile(r"^[\[\]{}();,]*$")


def is_trivial_structural_line(s: str) -> bool:
    """Фильтр для строк, которые дают ложные срабатывания дублирования."""
    return _RE_ONLY_PUNCT.match(s) is not None


def iter_filtered_code_lines_for_dup(path: Path) -> List[str]:
    """
    Линии для детектора дублирования:
      - без пустых строк
      - без комментариев, начинающихся с '#'
      - без тривиальной пунктуации
      - без коротких строк (порог DUP_MIN_LINE_LEN)
    """
    out: List[str] = []
    with path.open("r", encoding="utf-8", errors="ignore") as f:
        for raw in f:
            s = raw.rstrip("\n")
            st = s.strip()
            if not st:
                continue
            if st.startswith("#"):
                continue
            ns = norm_ws(s)
            if not ns:
                continue
            if is_trivial_structural_line(ns):
                continue
            if len(ns) < DUP_MIN_LINE_LEN:
                continue
            out.append(ns)
    return out


# =============================================================================
# Модули (nixos)
# =============================================================================


@dataclass(frozen=True)
class ModuleInfo:
    key: str
    path: Path
    loc: int


def discover_nixos_modules() -> Dict[str, ModuleInfo]:
    """
    Ожидаем структуру:
      modules/nixos/<category>/default.nix            -> key = <category>
      modules/nixos/<category>/<name>/default.nix     -> key = <category>.<name>
    """
    modules_root = VLADOS_ROOT / "modules" / "nixos"
    modules: Dict[str, ModuleInfo] = {}

    for p in modules_root.rglob("default.nix"):
        rel = p.relative_to(modules_root)
        parts = rel.parts

        if len(parts) == 2:
            key = parts[0]  # например: security, users
        elif len(parts) == 3:
            key = f"{parts[0]}.{parts[1]}"  # например: services.docker
        else:
            # Не ожидаем более глубоких вложений в рамках ВКР-метрик
            continue

        modules[key] = ModuleInfo(key=key, path=p, loc=loc_total_lines(p))

    return modules


# =============================================================================
# Профили
# =============================================================================


@dataclass(frozen=True)
class ProfileDef:
    name: str
    extends: Optional[str]
    suites: List[str]
    hardware: List[str]
    services: List[str]
    desktop: Optional[str]


_RE_EXTENDS = re.compile(r'extends\s*=\s*"([^"]+)"')
_RE_DESKTOP = re.compile(r'desktop\s*=\s*("([^"]+)"|null)')
_RE_ARRAY_ASSIGN = re.compile(
    r"(?ms)^\s*(suites|hardware|services|programs)\s*=\s*\[(.*?)\]\s*;"
)
_RE_STR = re.compile(r'"([^"]+)"')


def _parse_profile_file(path: Path) -> ProfileDef:
    text = path.read_text("utf-8", errors="ignore")

    extends: Optional[str] = None
    m = _RE_EXTENDS.search(text)
    if m:
        extends = m.group(1)

    desktop: Optional[str] = None
    m = _RE_DESKTOP.search(text)
    if m:
        if m.group(2) is None:
            # desktop = null
            desktop = None
        else:
            desktop = m.group(2)

    arrays: Dict[str, List[str]] = {k: [] for k in ["suites", "hardware", "services", "programs"]}
    for m in _RE_ARRAY_ASSIGN.finditer(text):
        key = m.group(1)
        body = m.group(2)
        arrays[key] = _RE_STR.findall(body)

    # programs в рамках текущих метрик не используются, но парсим для полноты
    return ProfileDef(
        name=path.stem,
        extends=extends,
        suites=arrays["suites"],
        hardware=arrays["hardware"],
        services=arrays["services"],
        desktop=desktop,
    )


def load_profiles() -> Dict[str, ProfileDef]:
    profiles_root = VLADOS_ROOT / "lib" / "profiles"
    desktop_paths = [p for p in (profiles_root / "desktop").glob("*.nix") if not p.name.startswith("_")]
    server_paths = [p for p in (profiles_root / "server").glob("*.nix") if not p.name.startswith("_")]

    profiles: Dict[str, ProfileDef] = {}

    # desktop/*.nix -> профиль с именем = stem (см. lib/profiles/desktop/_desktop.nix)
    for p in desktop_paths:
        prof = _parse_profile_file(p)
        profiles[prof.name] = prof

    # server/*.nix -> профиль с именем = "server-" + stem (см. lib/profiles/server/_server.nix)
    for p in server_paths:
        prof = _parse_profile_file(p)
        server_name = f"server-{p.stem}"
        profiles[server_name] = ProfileDef(
            name=server_name,
            extends=prof.extends,
            suites=prof.suites,
            hardware=prof.hardware,
            services=prof.services,
            desktop=prof.desktop,
        )

    return profiles


@dataclass(frozen=True)
class ExpandedProfile:
    suites: List[str]
    hardware: List[str]
    services: List[str]
    desktop: Optional[str]


def expand_profile(name: str, profiles: Dict[str, ProfileDef]) -> ExpandedProfile:
    """
    Простейшая модель наследования (как в lib/profiles/default.nix):
      - списки suites/hardware/services объединяются (union)
      - desktop наследуется, если не задано в дочернем профиле
    """
    visited: Set[str] = set()

    def _go(n: str) -> ExpandedProfile:
        if n in visited:
            raise RuntimeError(f"Циклическое наследование профилей: {n}")
        visited.add(n)

        p = profiles.get(n)
        if p is None:
            return ExpandedProfile(suites=[], hardware=[], services=[], desktop=None)

        parent = ExpandedProfile(suites=[], hardware=[], services=[], desktop=None)
        if p.extends:
            parent = _go(p.extends)

        suites = sorted(set(parent.suites + p.suites))
        hardware = sorted(set(parent.hardware + p.hardware))
        services = sorted(set(parent.services + p.services))
        desktop = p.desktop if p.desktop is not None else parent.desktop

        return ExpandedProfile(suites=suites, hardware=hardware, services=services, desktop=desktop)

    return _go(name)


# =============================================================================
# Suites: зависимые модули
# =============================================================================


def suite_dependencies(suite_name: str) -> Set[str]:
    """
    Для метрик достаточно фиксированных зависимостей, которые явно прописаны в suite-модулях.
    """
    deps: Set[str] = set()

    if suite_name == "common":
        deps |= {"system.boot", "system.locale", "system.networking", "security", "programs.nh"}

    if suite_name == "desktop":
        deps |= {"suites.common", "hardware.audio", "hardware.bluetooth", "desktop.plasma"}

    if suite_name == "development":
        deps |= {"suites.common", "services.docker"}

    if suite_name == "devops":
        deps |= {"suites.common", "services.docker"}

    if suite_name == "server":
        deps |= {"suites.common", "security"}

    return deps


# =============================================================================
# Hosts: извлечение профилей и дополнительных включений
# =============================================================================


_RE_APPLY_PROFILE = re.compile(r'applyProfile\s*"([^"]+)"')
_RE_COMBINE_PROFILES = re.compile(r"combineProfiles\s*\[\s*([^\]]*?)\s*\]", re.S)


def extract_profiles_from_host(host_default_nix: Path) -> List[str]:
    text = host_default_nix.read_text("utf-8", errors="ignore")

    # 1) applyProfile "name"
    m = _RE_APPLY_PROFILE.search(text)
    if m:
        return [m.group(1)]

    # 2) combineProfiles [ "a" "b" ... ]
    m = _RE_COMBINE_PROFILES.search(text)
    if m:
        body = m.group(1)
        return _RE_STR.findall(body)

    raise RuntimeError(f"Не удалось найти applyProfile/combineProfiles в {host_default_nix}")


def host_has_users_block(host_default_nix: Path) -> bool:
    text = host_default_nix.read_text("utf-8", errors="ignore")
    return "${namespace}.users" in text


def extract_explicit_enables_from_host(host_default_nix: Path, modules: Dict[str, ModuleInfo]) -> Set[str]:
    """
    Достаём явные включения модулей из host/default.nix.

    Поддерживаем:
      - ${namespace}.services.<name>.enable = true;
      - ${namespace}.security.sops.enable = true;
      - ${namespace}.suites = { devops = { enable = true; ... }; ... };
      - ${namespace}.suites.<name> = { enable = true; ... };
      - ${namespace}.services.<name> = { enable = true; ... };
    """
    text = host_default_nix.read_text("utf-8", errors="ignore")

    found: Set[str] = set()

    # enable-поля вида ${namespace}.category.name.enable = true;
    for m in re.finditer(r"\$\{namespace\}\.([a-zA-Z0-9_-]+(?:\.[a-zA-Z0-9_-]+)*)\.enable\s*=\s*true\s*;", text):
        key = m.group(1)
        if key in modules:
            found.add(key)

    # блоки вида ${namespace}.category.name = { ... enable = true; ... };
    for key in modules.keys():
        if "." not in key:
            continue
        # Точечная нотация ключа: services.github-runners
        # В nix это: ${namespace}.services.github-runners = { enable = true; ... };
        # Делаем простую проверку наличия подпоследовательности и enable=true.
        needle = f"${{namespace}}.{key} ="
        if needle in text:
            # Упрощённо: если рядом в тексте есть enable = true; — считаем включенным.
            # Это достаточно для текущих host/default.nix, где блоки короткие.
            idx = text.find(needle)
            window = text[idx : idx + 800]
            if re.search(r"\benable\s*=\s*true\s*;", window):
                found.add(key)

    # Специальный случай: ${namespace}.suites = { devops = { enable = true; ... }; };
    # Ищем все "имя = { ... enable = true; ... }" внутри этого блока.
    suites_block_idx = text.find("${namespace}.suites")
    if suites_block_idx != -1:
        window = text[suites_block_idx : suites_block_idx + 3000]
        # Наивно, но подходит: перечисление в одном блоке, без глубокой вложенности
        for m in re.finditer(r"\b([a-zA-Z0-9_-]+)\s*=\s*\{[^{}]*?\benable\s*=\s*true\s*;", window, re.S):
            suite_name = m.group(1)
            key = f"suites.{suite_name}"
            if key in modules:
                found.add(key)

    # Специальный случай: вложенное включение security.sops через
    # ${namespace}.security = { ... sops = { enable = true; ... }; ... };
    if "security.sops" in modules:
        sec_idx = text.find("${namespace}.security")
        if sec_idx != -1:
            window = text[sec_idx : sec_idx + 2000]
            if re.search(r"\bsops\s*=\s*\{[^{}]*?\benable\s*=\s*true\s*;", window, re.S):
                found.add("security.sops")

    return found


def discover_hosts() -> Dict[str, Path]:
    """
    Возвращает: hostName -> path/to/default.nix
    """
    systems_root = VLADOS_ROOT / "systems" / "x86_64-linux"
    out: Dict[str, Path] = {}
    for p in systems_root.glob("*/default.nix"):
        out[p.parent.name] = p
    return out


def modules_for_host(
    host_default_nix: Path,
    modules: Dict[str, ModuleInfo],
    profiles: Dict[str, ProfileDef],
) -> Set[str]:
    profs = extract_profiles_from_host(host_default_nix)

    enabled: Set[str] = set()

    for prof_name in profs:
        exp = expand_profile(prof_name, profiles)

        # suites -> suites.<name> + dependencies
        for s in exp.suites:
            enabled.add(f"suites.{s}")
            enabled |= suite_dependencies(s)

        # hardware -> hardware.<name>
        for h in exp.hardware:
            enabled.add(f"hardware.{h}")

        # services -> services.<name>
        for s in exp.services:
            enabled.add(f"services.{s}")

        # desktop -> desktop.<name>
        if exp.desktop:
            enabled.add(f"desktop.{exp.desktop}")

    # Явные включения из host/default.nix
    enabled |= extract_explicit_enables_from_host(host_default_nix, modules)

    # users (модуль без enable-флага) считаем используемым, если есть блок ${namespace}.users
    if "users" in modules and host_has_users_block(host_default_nix):
        enabled.add("users")

    # Оставляем только те ключи, которые реально существуют в modules/nixos
    enabled = {k for k in enabled if k in modules}

    # Замыкание зависимостей: если включили suite.* явно, подтягиваем зависимости
    changed = True
    while changed:
        changed = False
        suites = [k.split(".", 1)[1] for k in enabled if k.startswith("suites.")]
        for s in suites:
            for dep in suite_dependencies(s):
                if dep in modules and dep not in enabled:
                    enabled.add(dep)
                    changed = True

    return enabled


# =============================================================================
# C: оценка дублирования
# =============================================================================


def compute_duplication_ratio() -> Tuple[int, int, float]:
    """
    Детектор дублирования на основе k-грамм (DUP_KGRAM) по «содержательным» строкам.

    Возвращает:
      - LOC_dup: число строк, попавших в дублированные k-граммы (кроме первого вхождения)
      - LOC_total: общее число строк, участвовавших в анализе
      - ratio: LOC_dup / LOC_total
    """
    include_paths = [
        VLADOS_ROOT / "modules",
        VLADOS_ROOT / "lib",
        VLADOS_ROOT / "systems",
        VLADOS_ROOT / "homes",
        VLADOS_ROOT / "shells",
        VLADOS_ROOT / "flake.nix",
        VLADOS_ROOT / "topology.nix",
        VLADOS_ROOT / "topology",
    ]

    files: List[Path] = []
    for base in include_paths:
        if base.is_file():
            files.append(base)
        else:
            files.extend([p for p in base.rglob("*.nix") if p.is_file()])

    files = [p for p in files if p.name != "hardware-configuration.nix"]

    per_file: Dict[Path, List[str]] = {}
    for p in files:
        lines = iter_filtered_code_lines_for_dup(p)
        if lines:
            per_file[p] = lines

    total = sum(len(v) for v in per_file.values())
    if total == 0:
        return 0, 0, 0.0

    k = DUP_KGRAM
    shingles: Dict[Tuple[str, ...], List[Tuple[Path, int]]] = {}

    for p, lines in per_file.items():
        if len(lines) < k:
            continue
        for i in range(len(lines) - k + 1):
            sh = tuple(lines[i : i + k])
            shingles.setdefault(sh, []).append((p, i))

    dup_positions: Set[Tuple[Path, int]] = set()
    for occ in shingles.values():
        if len(occ) < 2:
            continue
        # Первое вхождение считаем «оригиналом», остальные — «дубликаты».
        for (p, i) in occ[1:]:
            for j in range(k):
                dup_positions.add((p, i + j))

    dup = len(dup_positions)
    return dup, total, dup / total


# =============================================================================
# Запуск
# =============================================================================


def main() -> None:
    if not VLADOS_ROOT.exists():
        raise SystemExit(f"Не найден каталог vladOS-v2: {VLADOS_ROOT}")

    modules = discover_nixos_modules()
    profiles = load_profiles()
    hosts = discover_hosts()

    # Метрики считаем по тем хостам, у которых есть systems/.../default.nix
    host_modules: Dict[str, Set[str]] = {}
    for host, path in sorted(hosts.items()):
        host_modules[host] = modules_for_host(path, modules, profiles)

    # U(m)
    U: Dict[str, int] = {k: 0 for k in modules.keys()}
    for ms in host_modules.values():
        for k in ms:
            U[k] += 1

    # R
    numerator = sum(modules[k].loc * (U[k] - 1) for k in modules.keys())
    denom = sum(modules[k].loc * U[k] for k in modules.keys())
    R = (numerator / denom) if denom else 0.0

    # M
    M = sum(1 for k in modules.keys() if U[k] >= 2) / len(modules) if modules else 0.0

    # S (как в тексте ВКР: сравнение host-LOC vs оценка изолированного варианта)
    host_loc_modular = sum(loc_total_lines(p) for p in hosts.values())
    host_loc_isolated = len(hosts) * ISOLATED_LOC_PER_HOST
    S = 1.0 - (host_loc_modular / host_loc_isolated) if host_loc_isolated else 0.0

    # C
    loc_dup, loc_total, C = compute_duplication_ratio()

    # Q_CM
    Q = W_R * R + W_M * M + W_S * S - W_C * C

    # Печать отчёта
    print("=== vladOS-v2: пересчёт метрик ===")
    print(f"repo: {VLADOS_ROOT}")
    print(f"hosts ({len(hosts)}): {', '.join(sorted(hosts.keys()))}")
    print()

    print("— Модули (nixos)")
    print(f"  count: {len(modules)}")
    print(f"  total LOC (sum of module files): {sum(m.loc for m in modules.values())}")
    print()

    print("— U(m): сколько хостов использует модуль")
    for k in sorted(modules.keys()):
        print(f"  {k:24s} U={U[k]}  LOC={modules[k].loc}")
    print()

    A3 = sum(modules[k].loc for k in modules.keys() if U[k] == 3)
    A2 = sum(modules[k].loc for k in modules.keys() if U[k] == 2)
    A1 = sum(modules[k].loc for k in modules.keys() if U[k] == 1)
    A0 = sum(modules[k].loc for k in modules.keys() if U[k] == 0)

    print("— Агрегации по U(m)")
    print(f"  sum LOC(U=3): {A3}")
    print(f"  sum LOC(U=2): {A2}")
    print(f"  sum LOC(U=1): {A1}")
    print(f"  sum LOC(U=0): {A0}")
    print(f"  numerator Σ LOC(m)*(U-1): {numerator}")
    print(f"  denom     Σ LOC(m)*U:      {denom}")
    print()

    print("— Метрики")
    print(f"  R  = {R:.6f} (≈ {R:.2f})")
    print(f"  M  = {M:.6f} (≈ {M:.2f})")
    print(f"  S  = 1 - ({host_loc_modular}/{host_loc_isolated}) = {S:.6f} (≈ {S:.2f})")
    print(f"  C  = {loc_dup}/{loc_total} = {C:.6f} (≈ {C:.2f})")
    print(f"  Q  = {Q:.6f} (≈ {Q:.2f})")
    print()

    print("— Детали для вставки в формулы")
    print(f"  Для R: (A3*2 + A2)/denom = ({A3}*2 + {A2})/{denom}")
    print(f"  Для S: host_LOC_modular={host_loc_modular}, host_LOC_isolated={host_loc_isolated} (={len(hosts)}*{ISOLATED_LOC_PER_HOST})")
    print(f"  Для C: LOC_dup={loc_dup}, LOC_total={loc_total}, k={DUP_KGRAM}, min_line_len={DUP_MIN_LINE_LEN}")


if __name__ == '__main__':
    main()

