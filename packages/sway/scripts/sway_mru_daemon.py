#!/usr/bin/env python3

import json
import os
import subprocess
import sys
import tempfile
import time


def get_state_path() -> str:
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR")
    if runtime_dir and os.path.isdir(runtime_dir):
        return os.path.join(runtime_dir, "sway_mru.json")
    return os.path.join(tempfile.gettempdir(), f"sway_mru_{os.getuid()}.json")


def get_pause_path() -> str:
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR")
    if runtime_dir and os.path.isdir(runtime_dir):
        return os.path.join(runtime_dir, "sway_mru_pause")
    return os.path.join(tempfile.gettempdir(), f"sway_mru_pause_{os.getuid()}")


def is_paused(max_age_sec: float = 2.0) -> bool:
    path = get_pause_path()
    try:
        st = os.stat(path)
        return (time.time() - st.st_mtime) <= max_age_sec
    except FileNotFoundError:
        return False
    except Exception:
        return False


def load_mru(path: str) -> list[int]:
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        if isinstance(data, list):
            return [int(x) for x in data]
    except Exception:
        pass
    return []


def save_mru(path: str, mru: list[int]) -> None:
    tmp_path = f"{path}.tmp"
    with open(tmp_path, "w", encoding="utf-8") as f:
        json.dump(mru, f)
    os.replace(tmp_path, path)


def subscribe_events() -> subprocess.Popen:
    # Subscribe to window focus changes and shutdown to exit cleanly
    return subprocess.Popen(
        [
            "swaymsg",
            "-m",
            "-t",
            "subscribe",
            '["window","shutdown"]',
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        bufsize=1,
        universal_newlines=True,
    )


def main() -> int:
    state_path = get_state_path()
    mru: list[int] = load_mru(state_path)

    backoff = 0.5
    while True:
        proc = subscribe_events()
        if proc.stdout is None:
            time.sleep(backoff)
            backoff = min(backoff * 2, 5.0)
            continue

        try:
            for line in proc.stdout:
                line = line.strip()
                if not line:
                    continue
                try:
                    event = json.loads(line)
                except json.JSONDecodeError:
                    continue

                change = event.get("change")
                if event.get("type") == "shutdown":
                    return 0

                if event.get("event") == "window" or event.get("type") == "window":
                    # Only react to focus events
                    if change != "focus":
                        continue
                    # Ignore focus updates while cycling is in progress
                    if is_paused():
                        continue
                    container = event.get("container") or {}
                    con_id = container.get("id")
                    # Track only real windows with an id and either app_id or window
                    is_real_window = (
                        isinstance(con_id, int)
                        and (container.get("app_id") is not None or container.get("window") is not None)
                    )
                    if not is_real_window:
                        continue

                    # Move to front (MRU) and uniquify
                    if con_id in mru:
                        mru.remove(con_id)
                    mru.insert(0, con_id)
                    # Keep the list reasonably bounded
                    if len(mru) > 512:
                        mru = mru[:512]
                    try:
                        save_mru(state_path, mru)
                    except Exception:
                        pass
        finally:
            try:
                proc.kill()
            except Exception:
                pass

        time.sleep(backoff)
        backoff = min(backoff * 2, 5.0)


if __name__ == "__main__":
    sys.exit(main())


