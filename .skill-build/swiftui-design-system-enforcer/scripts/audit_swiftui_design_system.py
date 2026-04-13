#!/usr/bin/env python3
"""Audit changed SwiftUI files against Gaia design-system primitives."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


SEVERITY_ORDER = {"BLOCKER": 0, "DECISION": 1, "WARN": 2}
DS_LIKE_SUFFIXES = (
    "Card",
    "Pill",
    "Badge",
    "Button",
    "Chip",
    "Tile",
    "Banner",
    "Sheet",
)


@dataclass(frozen=True)
class Finding:
    severity: str
    category: str
    path: str
    line: int
    message: str
    suggestion: str


def run_cmd(cmd: list[str], cwd: Path) -> tuple[int, str]:
    try:
        completed = subprocess.run(
            cmd,
            cwd=str(cwd),
            capture_output=True,
            text=True,
            check=False,
        )
    except FileNotFoundError:
        return 1, ""
    return completed.returncode, completed.stdout.strip()


def line_no(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def rel_path(path: Path, repo: Path) -> str:
    try:
        return str(path.resolve().relative_to(repo.resolve()))
    except ValueError:
        return str(path)


def discover_changed_swift_files(repo: Path, staged: bool, base: str | None) -> list[Path]:
    found: set[Path] = set()

    if base:
        code, out = run_cmd(
            ["git", "diff", "--name-only", f"{base}...HEAD", "--", "*.swift"],
            repo,
        )
        if code == 0 and out:
            found.update((repo / p).resolve() for p in out.splitlines())
        return sorted(p for p in found if p.exists())

    diff_cmds = []
    if staged:
        diff_cmds.append(["git", "diff", "--cached", "--name-only", "--", "*.swift"])
    else:
        diff_cmds.extend(
            [
                ["git", "diff", "--name-only", "--", "*.swift"],
                ["git", "diff", "--cached", "--name-only", "--", "*.swift"],
                ["git", "ls-files", "--others", "--exclude-standard", "*.swift"],
            ]
        )

    for cmd in diff_cmds:
        code, out = run_cmd(cmd, repo)
        if code != 0 or not out:
            continue
        found.update((repo / p).resolve() for p in out.splitlines())

    return sorted(p for p in found if p.exists())


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore")


def extract_static_lets(path: Path) -> set[str]:
    if not path.exists():
        return set()
    text = read_text(path)
    return set(re.findall(r"^\s*static let\s+([A-Za-z_][A-Za-z0-9_]*)\s*=", text, re.MULTILINE))


def extract_numeric_tokens(path: Path) -> dict[str, float]:
    tokens: dict[str, float] = {}
    if not path.exists():
        return tokens
    text = read_text(path)
    for match in re.finditer(
        r"^\s*static let\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*CGFloat\s*=\s*(-?[0-9]+(?:\.[0-9]+)?)",
        text,
        re.MULTILINE,
    ):
        tokens[match.group(1)] = float(match.group(2))
    return tokens


def extract_gaia_text_styles(path: Path) -> set[str]:
    styles: set[str] = set()
    if not path.exists():
        return styles
    text = read_text(path)
    for line in text.splitlines():
        match = re.match(r"^\s*case\s+(.+)$", line)
        if not match:
            continue
        payload = match.group(1).split("//", 1)[0]
        for candidate in payload.split(","):
            token = candidate.strip().split("(")[0].split("=")[0].strip()
            if re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", token):
                styles.add(token)
    return styles


def extract_components(repo: Path) -> set[str]:
    components: set[str] = set()
    component_root = repo / "GaiaNative/Components"
    if not component_root.exists():
        return components

    for file in component_root.rglob("*.swift"):
        components.add(file.stem)
        text = read_text(file)
        for match in re.finditer(r"\bstruct\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*View\b", text):
            components.add(match.group(1))
    return components


def token_value_map(tokens: dict[str, float]) -> dict[float, list[str]]:
    mapping: dict[float, list[str]] = {}
    for name, raw in tokens.items():
        key = round(raw, 4)
        mapping.setdefault(key, []).append(name)
    return mapping


def line_at(text: str, line: int) -> str:
    lines = text.splitlines()
    if line <= 0 or line > len(lines):
        return ""
    return lines[line - 1].strip()


def maybe_add(
    findings: list[Finding],
    seen: set[tuple[str, str, int, str]],
    *,
    severity: str,
    category: str,
    path: str,
    line: int,
    message: str,
    suggestion: str,
) -> None:
    key = (severity, category, line, message)
    if key in seen:
        return
    seen.add(key)
    findings.append(
        Finding(
            severity=severity,
            category=category,
            path=path,
            line=line,
            message=message,
            suggestion=suggestion,
        )
    )


def check_direct_color_literals(
    path: Path,
    rel: str,
    text: str,
    findings: list[Finding],
    seen: set[tuple[str, str, int, str]],
) -> None:
    if path.name == "GaiaColor.swift":
        return

    patterns = [
        (
            r"Color\s*\(\s*(?:red|white|hue)\s*:",
            "Direct RGB/HSB Color initializer detected; prefer GaiaColor token.",
        ),
        (
            r"Color\s*\(\s*hex\s*:",
            "Direct hex Color initializer detected; prefer GaiaColor token.",
        ),
        (
            r"#[0-9A-Fa-f]{6}(?:[0-9A-Fa-f]{2})?\b",
            "Hex color literal detected; map to GaiaColor token.",
        ),
    ]

    for pattern, message in patterns:
        for match in re.finditer(pattern, text):
            ln = line_no(text, match.start())
            if line_at(text, ln).startswith("//"):
                continue
            maybe_add(
                findings,
                seen,
                severity="BLOCKER",
                category="color",
                path=rel,
                line=ln,
                message=message,
                suggestion="Replace with `GaiaColor.<token>`.",
            )


def check_font_usage(
    path: Path,
    rel: str,
    text: str,
    findings: list[Finding],
    seen: set[tuple[str, str, int, str]],
) -> None:
    if path.name == "GaiaTypography.swift":
        return

    for match in re.finditer(r"\.font\s*\(([^)]*)\)", text):
        ln = line_no(text, match.start())
        if line_at(text, ln).startswith("//"):
            continue
        arg = match.group(1).strip()
        if "GaiaTypography." in arg or "style.font" in arg:
            continue

        if ".system" in arg or ".custom" in arg:
            maybe_add(
                findings,
                seen,
                severity="BLOCKER",
                category="typography",
                path=rel,
                line=ln,
                message="Direct system/custom font detected outside Gaia typography tokens.",
                suggestion="Use `.gaiaFont(<GaiaTextStyle>)` or `GaiaTypography.<token>`.",
            )
        else:
            maybe_add(
                findings,
                seen,
                severity="WARN",
                category="typography",
                path=rel,
                line=ln,
                message="Non-token `.font(...)` usage detected.",
                suggestion="Prefer `.gaiaFont(<GaiaTextStyle>)`.",
            )

    for match in re.finditer(r"\.(tracking|lineSpacing)\s*\(\s*-?[0-9]+(?:\.[0-9]+)?\s*\)", text):
        ln = line_no(text, match.start())
        if line_at(text, ln).startswith("//"):
            continue
        maybe_add(
            findings,
            seen,
            severity="WARN",
            category="typography",
            path=rel,
            line=ln,
            message=f"Direct `{match.group(1)}` literal detected.",
            suggestion="Prefer typography values embedded in `GaiaTextStyle` via `.gaiaFont(...)`.",
        )


def check_spacing_and_radius(
    rel: str,
    text: str,
    spacing_lookup: dict[float, list[str]],
    radius_lookup: dict[float, list[str]],
    findings: list[Finding],
    seen: set[tuple[str, str, int, str]],
) -> None:
    checks = [
        ("spacing", r"\.padding\s*\(\s*(?:\.\w+\s*,\s*)?(-?[0-9]+(?:\.[0-9]+)?)"),
        ("spacing", r"\b(?:HStack|VStack|ZStack|LazyHStack|LazyVStack)\s*\(\s*spacing:\s*(-?[0-9]+(?:\.[0-9]+)?)"),
        ("radius", r"\.cornerRadius\s*\(\s*(-?[0-9]+(?:\.[0-9]+)?)"),
        ("radius", r"RoundedRectangle\s*\(\s*cornerRadius:\s*(-?[0-9]+(?:\.[0-9]+)?)"),
    ]

    for kind, pattern in checks:
        lookup = spacing_lookup if kind == "spacing" else radius_lookup
        token_type = "GaiaSpacing" if kind == "spacing" else "GaiaRadius"
        for match in re.finditer(pattern, text):
            ln = line_no(text, match.start())
            if line_at(text, ln).startswith("//"):
                continue

            value = float(match.group(1))
            if value <= 0:
                continue
            names = lookup.get(round(value, 4))
            if names:
                maybe_add(
                    findings,
                    seen,
                    severity="WARN",
                    category=kind,
                    path=rel,
                    line=ln,
                    message=f"Literal {kind} value `{value:g}` matches token scale but is hardcoded.",
                    suggestion=f"Replace with `{token_type}.{names[0]}`.",
                )
            else:
                maybe_add(
                    findings,
                    seen,
                    severity="DECISION",
                    category=kind,
                    path=rel,
                    line=ln,
                    message=f"Literal {kind} value `{value:g}` is outside current token scale.",
                    suggestion=f"Use existing `{token_type}` token or request a new token decision.",
                )


def check_system_color_shortcuts(
    rel: str,
    text: str,
    findings: list[Finding],
    seen: set[tuple[str, str, int, str]],
) -> None:
    allowed = {"clear", "primary", "secondary", "tertiary", "quaternary"}
    for pattern in (r"\.foreground(?:Color|Style)\s*\(\s*\.([A-Za-z_][A-Za-z0-9_]*)", r"\.background\s*\(\s*\.([A-Za-z_][A-Za-z0-9_]*)"):
        for match in re.finditer(pattern, text):
            token = match.group(1)
            if token in allowed:
                continue
            ln = line_no(text, match.start())
            if line_at(text, ln).startswith("//"):
                continue
            maybe_add(
                findings,
                seen,
                severity="WARN",
                category="color",
                path=rel,
                line=ln,
                message=f"System color shortcut `.{token}` used directly.",
                suggestion="Prefer explicit `GaiaColor.<token>` when styling branded UI.",
            )


def check_component_decisions(
    path: Path,
    rel: str,
    text: str,
    component_catalog: set[str],
    findings: list[Finding],
    seen: set[tuple[str, str, int, str]],
) -> None:
    is_shared_component = "GaiaNative/Components/" in rel
    for match in re.finditer(r"\bstruct\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*View\b", text):
        name = match.group(1)
        if is_shared_component or name in component_catalog:
            continue
        if not name.endswith(DS_LIKE_SUFFIXES):
            continue
        ln = line_no(text, match.start())
        source_line = line_at(text, ln)
        if source_line.startswith("private struct") or source_line.startswith("fileprivate struct"):
            continue
        maybe_add(
            findings,
            seen,
            severity="DECISION",
            category="component",
            path=rel,
            line=ln,
            message=f"Potential new design-system component `{name}` detected outside shared component catalog.",
            suggestion=(
                "Ask user whether to create a new design-system component/token "
                "or map this to an existing component."
            ),
        )


def render(findings: list[Finding], files: list[Path], repo: Path) -> None:
    print("Design-System Audit Report")
    print(f"Repository: {repo}")
    print(f"Audited files: {len(files)}")
    for file in files:
        print(f" - {rel_path(file, repo)}")

    if not findings:
        print("\nResult: clean")
        print("USER_DECISION_REQUIRED: no")
        return

    print("\nFindings:")
    for finding in findings:
        print(
            f"[{finding.severity}] {finding.path}:{finding.line} "
            f"({finding.category}) {finding.message}"
        )
        print(f"  Fix: {finding.suggestion}")

    counts = {"BLOCKER": 0, "DECISION": 0, "WARN": 0}
    for finding in findings:
        counts[finding.severity] += 1

    print("\nSummary:")
    print(f" - BLOCKER: {counts['BLOCKER']}")
    print(f" - DECISION: {counts['DECISION']}")
    print(f" - WARN: {counts['WARN']}")
    print(f"USER_DECISION_REQUIRED: {'yes' if counts['DECISION'] else 'no'}")

    if counts["DECISION"]:
        print("\nDecision prompt:")
        print("I found unmatched UI pieces that are not clearly mapped to the current design system.")
        print("How do you want to proceed?")
        print("1. Create a new design-system component/token for this pattern.")
        print("2. Link this pattern to an existing component/token.")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Audit changed SwiftUI files against Gaia design-system primitives."
    )
    parser.add_argument("--repo", default=".", help="Path to Gaia-Prototype repository root.")
    parser.add_argument(
        "--files",
        nargs="*",
        help="Optional explicit file list (repo-relative or absolute).",
    )
    parser.add_argument(
        "--staged",
        action="store_true",
        help="Audit staged Swift files instead of unstaged/untracked.",
    )
    parser.add_argument(
        "--base",
        help="Optional git base ref for diff mode (e.g. origin/main).",
    )
    args = parser.parse_args()

    repo = Path(args.repo).expanduser().resolve()
    if not repo.exists():
        print(f"Repository not found: {repo}", file=sys.stderr)
        return 2

    if args.files:
        files = []
        for raw in args.files:
            candidate = Path(raw)
            if not candidate.is_absolute():
                candidate = (repo / candidate).resolve()
            files.append(candidate)
        files = sorted({f for f in files if f.exists() and f.suffix == ".swift"})
    else:
        files = discover_changed_swift_files(repo, staged=args.staged, base=args.base)

    if not files:
        print("Design-System Audit Report")
        print("No Swift files to audit.")
        return 0

    spacing_tokens = extract_numeric_tokens(repo / "GaiaNative/Theme/GaiaSpacing.swift")
    radius_tokens = extract_numeric_tokens(repo / "GaiaNative/Theme/GaiaRadius.swift")
    component_catalog = extract_components(repo)

    spacing_lookup = token_value_map(spacing_tokens)
    radius_lookup = token_value_map(radius_tokens)

    findings: list[Finding] = []
    for file in files:
        text = read_text(file)
        rel = rel_path(file, repo)
        seen: set[tuple[str, str, int, str]] = set()
        check_direct_color_literals(file, rel, text, findings, seen)
        check_font_usage(file, rel, text, findings, seen)
        check_spacing_and_radius(rel, text, spacing_lookup, radius_lookup, findings, seen)
        check_system_color_shortcuts(rel, text, findings, seen)
        check_component_decisions(file, rel, text, component_catalog, findings, seen)

    findings.sort(key=lambda f: (SEVERITY_ORDER[f.severity], f.path, f.line, f.category))
    render(findings, files, repo)

    has_blocker = any(f.severity == "BLOCKER" for f in findings)
    has_decision = any(f.severity == "DECISION" for f in findings)
    has_warn = any(f.severity == "WARN" for f in findings)

    if has_blocker or has_decision:
        return 2
    if has_warn:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
