import os

path = os.path.join("scripts", "autonomous_enterprise", "temp_grow_bot", "marcus_telegram_bot.py")
with open(path, "r", encoding="utf-8") as f:
    text = f.read()

target = '        else:\n            self.send_response(404)\n            self.end_headers()'
replacement = '''        else:
            self.send_response(404)
            self.end_headers()

    def do_HEAD(self):
        if self.path in ["/", "/health", "/status", "/ping"]:
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()'''

if target in text:
    text = text.replace(target, replacement, 1)
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)
    print("PATCH_OK")
else:
    # Try with CRLF
    target_crlf = target.replace('\n', '\r\n')
    replacement_crlf = replacement.replace('\n', '\r\n')
    if target_crlf in text:
        text = text.replace(target_crlf, replacement_crlf, 1)
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        print("PATCH_CRLF_OK")
    else:
        print("TARGET_NOT_FOUND")

