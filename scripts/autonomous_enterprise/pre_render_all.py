# -*- coding: utf-8 -*-
import sys
import os
import time

sys.path.append(os.path.join(os.path.dirname(__file__)))
from managing_director import ManagingDirector

def main():
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    md = ManagingDirector(root_dir)
    print("Starting pre-render of all 7 days of Quranic Viral Reels & Stories...")
    for day in range(1, 8):
        t0 = time.time()
        print(f"--- Preparing Day #{day} ---")
        pkg = md.prepare_daily_package(day)
        reel_size = os.path.getsize(pkg["reel_path"]) / (1024 * 1024)
        story_size = os.path.getsize(pkg["story_path"]) / 1024
        print(f"Day #{day} Ready in {time.time()-t0:.2f}s | Reel: {reel_size:.2f} MB | Story: {story_size:.1f} KB")

if __name__ == "__main__":
    main()
