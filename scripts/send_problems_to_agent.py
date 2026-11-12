# -*- coding: utf-8 -*-
"""
Diagnostics & Problems Harvester for Antigravity Agent
Runs Dart/Flutter analysis, parses compiler/linter diagnostics,
and formats them into PROBLEMS.md for the agent to review and fix instantly.
"""
import os
import sys
import subprocess
import time
from datetime import datetime

def main():
    start_time = time.time()
    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    os.chdir(project_root)

    target = sys.argv[1] if len(sys.argv) > 1 else "lib"

    print("=" * 60)
    print("🔍 Antigravity Diagnostics Harvester: Scanning Workspace...")
    print(f"Target: {target}")
    print("=" * 60)

    # Run dart analyze in machine format
    cmd = f'dart analyze --format=machine "{target}"'
    try:
        proc = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace"
        )
        raw_output = proc.stdout.strip()
    except Exception as e:
        print(f"[ERROR] Failed to execute Dart analyzer: {e}")
        return

    lines = raw_output.splitlines() if raw_output else []
    
    # Filter only machine formatted lines (contains pipe |)
    issues = []
    for line in lines:
        parts = line.split("|")
        if len(parts) >= 8:
            severity = parts[0].strip().upper()
            err_type = parts[1].strip()
            rule_name = parts[2].strip()
            file_path = parts[3].strip()
            line_num = parts[4].strip()
            col_num = parts[5].strip()
            msg = parts[7].strip()

            # Make file path relative for cleaner display
            rel_path = os.path.relpath(file_path, project_root) if os.path.isabs(file_path) else file_path

            issues.append({
                "severity": severity,
                "type": err_type,
                "rule": rule_name,
                "file": rel_path,
                "abs_file": file_path.replace("\\", "/"),
                "line": line_num,
                "col": col_num,
                "message": msg
            })

    elapsed = time.time() - start_time
    total = len(issues)
    errors = sum(1 for i in issues if i["severity"] == "ERROR")
    warnings = sum(1 for i in issues if i["severity"] == "WARNING")
    infos = sum(1 for i in issues if i["severity"] == "INFO")

    print(f"\nScan completed in {elapsed:.1f}s.")
    print(f"Summary: {total} total problems ({errors} Errors, {warnings} Warnings, {infos} Infos)")

    # Write report to PROBLEMS.md
    report_path = os.path.join(project_root, "PROBLEMS.md")
    with open(report_path, "w", encoding="utf-8") as f:
        f.write("# 📋 Antigravity Problems & Diagnostics Report\n\n")
        f.write(f"- **Scan Time**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"- **Target Directory**: `{target}`\n")
        f.write(f"- **Total Issues**: `{total}` (`{errors}` Errors, `{warnings}` Warnings, `{infos}` Infos)\n\n")

        if total == 0:
            f.write("> [!NOTE]\n> ✨ **No problems found!** The codebase is 100% clean, error-free, and healthy.\n")
        else:
            f.write("## ⚠️ Detected Diagnostics\n\n")
            f.write("| Severity | File & Location | Rule | Message |\n")
            f.write("| :--- | :--- | :--- | :--- |\n")
            for item in issues:
                sev_icon = "🔴 ERROR" if item["severity"] == "ERROR" else ("🟡 WARNING" if item["severity"] == "WARNING" else "🔵 INFO")
                file_link = f"[{item['file']}:{item['line']}](file:///{item['abs_file']}#L{item['line']})"
                f.write(f"| {sev_icon} | {file_link} | `{item['rule']}` | {item['message']} |\n")

            f.write("\n\n### Instructions for AI Agent:\n")
            f.write("1. Review each error/warning in the table above.\n")
            f.write("2. Apply precise fixes to the exact line numbers specified.\n")
            f.write("3. Re-run `python scripts/send_problems_to_agent.py` to ensure all issues are resolved.\n")

    print(f"\n[REPORT GENERATED] -> {report_path}")

    if total == 0:
        print("\n✨ SUCCESS: Codebase is 100% clean and error-free!")
        sys.exit(0)
    else:
        print("\n⚠️ Issues found:")
        for idx, item in enumerate(issues[:10], start=1):
            print(f"  {idx}. [{item['severity']}] {item['file']}:{item['line']} - {item['message']} ({item['rule']})")
        if total > 10:
            print(f"  ... and {total - 10} more issues documented in PROBLEMS.md")
        print("\n💡 Now you can tell the AI Agent:")
        print('   "صلح المشاكل في PROBLEMS.md"')
        sys.exit(1 if errors > 0 else 0)

if __name__ == "__main__":
    main()

