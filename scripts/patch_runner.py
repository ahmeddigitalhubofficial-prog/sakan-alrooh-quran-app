import os
import sys
import subprocess

if not os.environ.get("SHOREBIRD_TOKEN"):
    os.environ["SHOREBIRD_TOKEN"] = "sb_api_Umrd7G3GSx8sOq-TKQN-qlNhpPKFXCup1LTEqI3nCqg"

def run_patch(release_version="1.2.0+35"):
    shorebird_cmd = "shorebird.bat" if os.name == "nt" else "shorebird"
    cmd = [
        shorebird_cmd,
        "patch",
        "android",
        f"--release-version={release_version}",
        "--allow-native-diffs",
        "--allow-asset-diffs",
        "--json"
    ]
    print(f"Starting Shorebird non-interactive patch for {release_version}...")
    sys.stdout.flush()

    res = subprocess.run(cmd, env=os.environ)
    print(f"\nPatch finished with exit code: {res.returncode}")
    return res.returncode

if __name__ == "__main__":
    ver = sys.argv[1] if len(sys.argv) > 1 else "1.2.0+35"
    sys.exit(run_patch(ver))
