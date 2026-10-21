#!/usr/bin/env python3
"""Generate docs/module-interfaces.md from the entity declarations in rtl/*.vhd."""
import glob, os, re

root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
out = ["# Module Interfaces", "",
       "Generated from the entity declarations by `scripts/gen_module_docs.py` (do not edit by hand).",
       "All modules are synchronous to `clk` (single 50 MHz domain), VHDL-2008, synchronous reset `rst` (active high).", ""]

for f in sorted(glob.glob(os.path.join(root, "rtl", "*.vhd"))):
    rel = "rtl/" + os.path.basename(f)
    if f.endswith("aes_pkg.vhd"):
        continue
    src = open(f).read()
    m = re.search(r"entity\s+(\w+)\s+is(.*?)end entity", src, re.S | re.I)
    if not m:
        continue
    name, body = m.group(1), m.group(2)
    head = re.match(r"((?:--[^\n]*\n)+)", src)
    out.append("## `%s`  (`%s`)" % (name, rel))
    if head:
        text = "".join(l[3:] if l.startswith("-- ") else l[2:] for l in head.group(1).splitlines(True)).rstrip()
        out.append("```text\n" + text + "\n```")
    g = re.search(r"generic\s*\((.*?)\)\s*;\s*port", body, re.S | re.I)
    if g:
        out.append("\n**Generics**\n\n| Name | Type | Default |\n|---|---|---|")
        for decl in re.split(r";\s*\n", g.group(1).strip()):
            decl = re.sub(r"--.*", "", decl).strip()
            mm = re.match(r"(\w+)\s*:\s*([\w ]+?)(?:\s*:=\s*(.+))?$", decl, re.S)
            if mm:
                out.append("| `%s` | `%s` | `%s` |" % (mm.group(1), mm.group(2).strip(),
                                                      (mm.group(3) or "").strip().replace("\n", " ")[:60]))
    p = re.search(r"port\s*\((.*)\)\s*;", body, re.S | re.I)
    out.append("\n**Ports**\n\n| Name | Dir | Type | Note |\n|---|---|---|---|")
    for line in p.group(1).splitlines():
        line = line.strip()
        if not line or line.startswith("--"):
            continue
        note = ""
        if "--" in line:
            line, note = line.split("--", 1)
            note = note.strip()
        line = line.rstrip(";").strip()
        mm = re.match(r"([\w, ]+)\s*:\s*(in|out)\s+(.+)$", line, re.I)
        if mm:
            for n in [x.strip() for x in mm.group(1).split(",")]:
                out.append("| `%s` | %s | `%s` | %s |" % (n, mm.group(2).lower(), mm.group(3).strip(), note))
    out.append("")

open(os.path.join(root, "docs", "module-interfaces.md"), "w").write("\n".join(out))
print("docs/module-interfaces.md:", sum(1 for l in out if l.startswith("## ")), "modules")
