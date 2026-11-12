import os

appdata = os.environ.get("APPDATA")
startup_dir = os.path.join(appdata, "Microsoft", "Windows", "Start Menu", "Programs", "Startup")
target = os.path.join(startup_dir, "start_sakan_bot.cmd")

vbs_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "start_bot_silent.vbs"))

content = f'@echo off\r\nstart "" wscript.exe "{vbs_path}"\r\n'

with open(target, "w", encoding="utf-8") as f:
    f.write(content)

print("Startup script created successfully at:", target)
