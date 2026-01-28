#!/usr/bin/env python3

import json
import os
import subprocess
import sys
import tempfile
from typing import List, Optional, Tuple


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


def swaymsg_get_tree() -> dict:
    proc = subprocess.run(["swaymsg", "-t", "get_tree"], capture_output=True, text=True, check=True)
    return json.loads(proc.stdout)


def swaymsg_get_workspaces() -> List[dict]:
    proc = subprocess.run(["swaymsg", "-t", "get_workspaces"], capture_output=True, text=True, check=True)
    return json.loads(proc.stdout)


def run_swaymsg(cmd: str) -> None:
    subprocess.run(["swaymsg", cmd], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def load_mru(path: str) -> List[int]:
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        if isinstance(data, list):
            return [int(x) for x in data]
    except Exception:
        pass
    return []


def flatten_nodes(node: dict) -> List[dict]:
    res = []
    stack = [node]
    while stack:
        n = stack.pop()
        res.append(n)
        for key in ("nodes", "floating_nodes"):
            children = n.get(key) or []
            for c in children:
                stack.append(c)
    return res


def find_workspace_and_windows(tree: dict, workspace_name: Optional[str]) -> Tuple[Optional[int], List[dict]]:
    if not workspace_name:
        return None, []
    nodes = flatten_nodes(tree)
    workspace = next((n for n in nodes if n.get("type") == "workspace" and n.get("name") == workspace_name), None)
    if workspace is None:
        return None, []
    ws_nodes = flatten_nodes(workspace)
    windows = [
        n
        for n in ws_nodes
        if n.get("type") == "con" and isinstance(n.get("id"), int) and (n.get("app_id") is not None or n.get("window") is not None)
    ]
    return workspace.get("id"), windows


def current_focused_id(tree: dict) -> Optional[int]:
    nodes = flatten_nodes(tree)
    focused = next((n for n in nodes if n.get("focused")), None)
    return focused.get("id") if focused else None


def main() -> int:
    direction = sys.argv[1] if len(sys.argv) > 1 else "next"
    if direction not in ("next", "prev"):
        print("Usage: sway_mru_cycle.py [next|prev]", file=sys.stderr)
        return 1

    state_path = get_state_path()
    mru = load_mru(state_path)

    tree = swaymsg_get_tree()
    workspaces = swaymsg_get_workspaces()
    focused_ws_name = None
    for ws in workspaces:
        if ws.get("focused"):
            focused_ws_name = ws.get("name")
            break

    ws_id, windows = find_workspace_and_windows(tree, focused_ws_name)
    if ws_id is None or not windows:
        return 0

    # Build list of window ids in MRU order filtered to current workspace
    ws_window_ids = {w["id"] for w in windows if isinstance(w.get("id"), int)}
    ordered = [wid for wid in mru if wid in ws_window_ids]

    # Add any windows not yet tracked to the end to ensure they are reachable
    tracked = set(ordered)
    for w in windows:
        wid = w["id"]
        if wid not in tracked:
            ordered.append(wid)

    if not ordered:
        return 0

    focused_id = current_focused_id(tree)
    if focused_id not in ordered:
        # Focused may be a container parent; fallback to first
        target_idx = 0
    else:
        idx = ordered.index(focused_id)
        if direction == "next":
            target_idx = (idx + 1) % len(ordered)
        else:
            target_idx = (idx - 1) % len(ordered)

    target = ordered[target_idx]
    # Touch pause file to signal daemon to ignore transient focus changes while cycling
    try:
        with open(get_pause_path(), "w", encoding="utf-8") as f:
            f.write("pause")
    except Exception:
        pass
    run_swaymsg(f"[con_id={target}] focus")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())


