import i3ipc

sway = i3ipc.Connection()
LOCKED_WS = "10"  # The workspace you want to keep "read-only"
previous_workspace = "1"  # fallback default


def on_workspace_focus(self, e):
    if e.current.name == LOCKED_WS:
        # Send focus back to the previous workspace
        sway.command("workspace back_and_forth")
    else:
        global previous_workspace
        previous_workspace = e.current.name


def on_window_move(self, e):
    global previous_workspace
    if not previous_workspace:
        return

    moved_to = None

    # Best method: refresh tree with small delay
    tree = sway.get_tree()
    container = tree.find_by_id(e.container.id)

    if container:
        ws = container.workspace()
        if ws:
            moved_to = ws.name

    # Fallback if above fails
    if not moved_to:
        try:
            ws = e.container.workspace()
            if ws:
                moved_to = ws.name
        except:
            pass

    if moved_to == LOCKED_WS:
        sway.off(on_workspace_focus)
        sway.command(f"workspace {LOCKED_WS}")
        sway.command(f'move container to workspace "{previous_workspace}"')
        # Optional: focus the workspace we moved back to
        sway.command(f"workspace {previous_workspace}")
        sway.on("workspace::focus", on_workspace_focus)


# Listen for both focus shifts and window movements
sway.on("workspace::focus", on_workspace_focus)
sway.on("window::move", on_window_move)
sway.main()
