from __future__ import absolute_import, division, print_function

from ranger.api.commands import *

from ranger_udisk_menu.mounter import mount
import subprocess
import os
import json
import atexit
import socket
from pathlib import Path

import logging

logger = logging.getLogger(__name__)
import traceback

from ranger.ext.img_display import ImageDisplayer, register_image_displayer


@register_image_displayer("mpv")
class MPVImageDisplayer(ImageDisplayer):
    """Implementation of ImageDisplayer using mpv, a general media viewer.
    Opens media in a separate X window.

    mpv 0.25+ needs to be installed for this to work.
    """

    def _send_command(self, path, sock):

        message = '{"command": ["raw","loadfile",%s]}\n' % json.dumps(path)
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.connect(str(sock))
        logger.info("-> " + message)
        s.send(message.encode())
        message = s.recv(1024).decode()
        logger.info("<- " + message)

    def _launch_mpv(self, path, sock):

        proc = subprocess.Popen(
            [
                *os.environ.get("MPV", "mpv").split(),
                "--no-terminal",
                "--force-window",
                "--input-ipc-server=" + str(sock),
                "--image-display-duration=inf",
                "--loop-file=inf",
                "--no-osc",
                "--no-input-default-bindings",
                "--keep-open",
                "--idle",
                "--",
                path,
            ]
        )

        @atexit.register
        def cleanup():
            proc.terminate()
            sock.unlink()

    def draw(self, path, start_x, start_y, width, height):

        path = os.path.abspath(path)
        cache = Path(os.environ.get("XDG_CACHE_HOME", "~/.cache")).expanduser()
        cache = cache / "ranger"
        cache.mkdir(exist_ok=True)
        sock = cache / "mpv.sock"

        try:
            self._send_command(path, sock)
        except (ConnectionRefusedError, FileNotFoundError):
            logger.info("LAUNCHING " + path)
            self._launch_mpv(path, sock)
        except Exception as e:
            logger.exception(traceback.format_exc())
            sys.exit(1)
        logger.info("SUCCESS")


class mount_android(Command):
    """:mount_android

    Mount android MTP
    """

    def execute(self):
        self.fm.run("simple-mtpfs ~/mnt/android -o allow_other")



class unmount_android(Command):
    """:unmount_android

    Mount android MTP
    """

    def execute(self):
        self.fm.run("fusermount -u ~/mnt/android")


class emptytrash(Command):
    """:empty

    Empties the trash
    """

    def execute(self):
        HOME = os.environ["HOME"]
        self.fm.run(f"trash-empty")


def show_error_in_console(msg, fm):
    fm.notify(msg, bad=True)


def navigate_path(fm, selected):
    if not selected:
        return

    selected = os.path.abspath(selected)
    if os.path.isdir(selected):
        fm.cd(selected)
    elif os.path.isfile(selected):
        fm.select_file(selected)
    else:
        show_error_in_console(f"Neither directory nor file: {selected}", fm)
        return


def execute(cmd, input=None):
    stdin = None
    if input:
        stdin = subprocess.PIPE

    proc = subprocess.Popen(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=stdin, text=True
    )
    stdout, stderr = proc.communicate(input=input)

    if proc.returncode != 0:
        raise Exception(
            f"Bad process exit code: {proc.returncode}, stdout={stdout}, stderr={stderr}"
        )

    return stdout, stderr


import re
import curses

import collections

URL = collections.namedtuple("URL", ["user", "hostname", "path"])


def parse_url(url):
    if len(t := url.split(sep="@", maxsplit=1)) > 1:
        user = t[0]
        rest = t[1]
    else:
        user = None
        rest = t[0]
    if len(t := rest.rsplit(sep=":", maxsplit=1)) > 1:
        hostname = t[0]
        path = t[1]
    else:
        hostname = t[0]
        path = None

    return URL(user=user, hostname=hostname, path=path)


def url2str(u: URL):
    res = u.hostname
    if u.user:
        res = f"{u.user}@{res}"
    path = u.path
    if path is None:
        path = ""

    return f"{res}:{path}"


def search_mount_path(mount_path):
    stdout, _ = execute(["mount"])
    return re.search(re.escape(mount_path) + r"\b", stdout)


def hostname2mount_path(hostname):
    mount_path = os.path.expanduser(f"~/.config/ranger/mounts/{hostname}")

    # check whether it is already mounted
    if search_mount_path(mount_path):
        raise Exception(f"Already mounted: {mount_path}")

    os.makedirs(mount_path, exist_ok=True)
    return mount_path


class sshfs_mount(Command):
    def execute(self):
        url = self.arg(1)
        u = parse_url(url)

        mount_path = hostname2mount_path(u.hostname)
        cmd = ["sshfs", url2str(u), mount_path]

        execute(cmd)

        # before navigating we should load it otherwise we see
        # "not accessible"
        d = self.fm.get_directory(mount_path)
        d.load()

        navigate_path(self.fm, mount_path)

    # options:
    # - None
    # - string: just one complete without iterating
    # - list, tuple, generator: to iterate options around
    def tab(self, tabnum):
        u = parse_url(self.rest(1))

        def path_options():
            lst = []
            for path in ["", "/"]:
                lst.append(self.start(1) + url2str(u._replace(path=path)))

            return lst

        # autocomplete hostname
        if u.path is None:
            hostname = select_with_fzf(
                ["fzf", "-q", u.hostname], compose_hostname_list(), self.fm
            )
            # hostname = "ilya-thinkpad"

            # after suspend/init we should manually show the cursor
            # the same way console.open() does
            try:
                curses.curs_set(1)
            except curses.error:
                pass

            if not hostname:
                return None

            u = u._replace(hostname=hostname)
            return path_options()

        # autocomplete path
        return path_options()


def umount(mount_path):
    prefix = os.path.expanduser(f"~/.config/ranger/mounts/")
    if not mount_path.startswith(prefix):
        raise Exception(f"May umount only inside: {prefix}")

    if not search_mount_path(mount_path):
        raise Exception(f"Not mounted: {mount_path}")

    cmd = ["diskutil", "unmount", "force", mount_path]
    execute(cmd)

    os.rmdir(mount_path)


class sshfs_umount(Command):
    def execute(self):
        tab = self.fm.tabs[self.fm.current_tab]
        mount_path = tab.thisfile.path
        umount(mount_path)


def compose_hostname_list():
    # list of possible hostnames
    # stolen from fzf, https://github.com/junegunn/fzf/blob/master/shell/completion.bash
    stdout, _ = execute(
        ["bash"],
        input="""
command cat <(
    command tail -n +1 ~/.ssh/config ~/.ssh/config.d/* /etc/ssh/ssh_config 2> /dev/null | command grep -i '^\s*host\(name\)\? ' | awk '{for (i = 2; i <= NF; i++) print $1 " " $i}' | command grep -v '[*?]') \
        <(command grep -oE '^[[a-z0-9.,:-]+' ~/.ssh/known_hosts | tr ',' '\n' | tr -d '[' | awk '{ print $1 " " $1 }') \
        <(command grep -v '^\s*\(#\|$\)' /etc/hosts | command grep -Fv '0.0.0.0') |
        awk '{if (length($2) > 0) {print $2}}' | sort -u
""",
    )
    return stdout
