import os
import re

path = os.path.expanduser(
    "~/.var/app/com.rustdesk.RustDesk/config/rustdesk/RustDesk2.toml"
)
os.makedirs(os.path.dirname(path), exist_ok=True)

updates = {
    "custom-rendezvous-server": "rustdesk.maplenetwork.ca",
    "relay-server": "rustdesk.maplenetwork.ca",
    "key": "vQ3+y2WKhab2hGtdSPqBP6rYVtiZwj7xXV3yZSNubAE=",
    "access-mode": "full",
}

content = ""
if os.path.exists(path):
    with open(path, "r") as f:
        content = f.read()

# 1. Remove duplicate top-level keys before any section headers
first_section = re.search(r"^\[", content, flags=re.MULTILINE)
top_level = content[: first_section.start()] if first_section else content
rest = content[first_section.start() :] if first_section else ""

for k in updates:
    top_level = re.sub(rf"^{re.escape(k)}\s*=.*\n?", "", top_level, flags=re.MULTILINE)
content = top_level + rest

# 2. Ensure [options] section exists
if not re.search(r"^\[options\]", content, flags=re.MULTILINE):
    content = content.rstrip() + "\n\n[options]\n"

# 3. Update or append keys strictly within the [options] block
options_pattern = r"(^\[options\]\s*\n)([\s\S]*?)(?=^\[|\Z)"
match = re.search(options_pattern, content, flags=re.MULTILINE)

if match:
    header, body = match.group(1), match.group(2)
    for k, v in updates.items():
        k_pattern = rf"^{re.escape(k)}\s*=.*$"
        replacement = f"{k} = '{v}'"
        if re.search(k_pattern, body, flags=re.MULTILINE):
            body = re.sub(k_pattern, replacement, body, flags=re.MULTILINE)
        else:
            body = body.rstrip() + f"\n{replacement}\n"

    content = content[: match.start()] + header + body + content[match.end() :]

with open(path, "w") as f:
    f.write(content)
