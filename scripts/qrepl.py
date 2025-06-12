#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import argparse
import subprocess
import shlex
import re
import logging

from prompt_toolkit import prompt
from prompt_toolkit.styles import Style


# Custom type for argparse return type
type Arguments = argparse.Namespace

# Meta
__app_name__: str = "qrepl"
__author__: str = "idealtitude"
__version__: str = "0.1.0"
__license__: str = "MT108"

# Constants
EXIT_SUCCESS: int = 0
EXIT_FAILURE: int = 1

USER_CWD: str = os.getcwd()
USER_HOME: str = os.path.expanduser("~")
JUNK_LOGS: str = os.path.join(USER_HOME, f"Dev{os.sep}VAR{os.sep}JUNK{os.sep}JUNK_LOGS")

logger = logging.getLogger("junk_logs")


class Qrepl:
    """The internal editor of notes"""

    def __init__(self, current_file: str) -> None:
        self.content: list[str]
        self.do_loop: bool = True
        self.current_file: str = current_file

    def looping(self) -> None:
        while self.do_loop:
            self._prompting()

    def _prompting(self) -> None:
        style = Style.from_dict(
            {
                "bottom-toolbar": "#1F88F0",
                "bottom-toolbar.text": "#1F88F0",
            }
        )

        text = prompt(
            "% ",
            bottom_toolbar=f"File: {os.path.basename(self.current_file)} | Junk: {os.path.basename(USER_CWD)} | q or . to quit, ? or h for help",
            style=style,
        )

        if text == "q" or text == ".":
            self.do_loop = False
            logger.info("Junkify session finished")
            return

        if text == "?" or text == "h":
            self.print_help()
        elif len(text) > 0 and not re.match(r"^\s+$", text):
            exec_cmd(text)

    def print_help(self) -> None:
        print("Not implemented yet...")


def exec_cmd(cmd: list[str] | str) -> None:
    if isinstance(cmd, str):
        temp_cmd: list[str] = shlex.split(cmd)
        cmd = temp_cmd
    try:
        result: subprocess.CompletedProcess = subprocess.run(cmd)
        # if result.returncode == 0:
        # print(f"RESULT: {result}")
        if result.stdout is not None:
            msg: str = result.stdout.strip()
            logger.info(msg)
            print(msg)
        if result.stderr is not None:
            msg: str = result.stderr.strip()
            logger.error(msg)
            print(msg)
    except (subprocess.CalledProcessError, Exception) as ex:
        logger.error(str(ex))
        print(f"\033[101m[ERROR]\033[0m {ex}")


def get_args() -> Arguments:
    """Parsing command line arguments"""
    parser = argparse.ArgumentParser(
        prog=f"{__app_name__}",
        description="An utility to quickly implement a basic repl in any other app",
        epilog=f"Read the documentation to learn how to use {__app_name__}",
    )

    parser.add_argument("-f", "--file", nargs=1, help="A file to edit")

    parser.add_argument(
        "-e",
        "--editor",
        nargs=1,
        help="Specify a the text editor to use (default nano)",
    )

    parser.add_argument(
        "-o",
        "--open",
        action="store_true",
        help="Open the file in the editor",
    )
    parser.add_argument(
        "-v", "--version", action="version", version=f"%(prog)s {__version__}"
    )

    return parser.parse_args()


def main() -> int:
    """Main entry point"""
    args: Arguments = get_args()
    file_path: str = os.path.join(USER_CWD, "unnamed.txt")
    editor: str = "/usr/bin/nano"

    # Logging
    log_file_path: str = os.path.join(JUNK_LOGS, f"{os.path.basename(USER_CWD)}.log")
    qrepl_handle = logging.FileHandler(filename=log_file_path)
    logger.setLevel(logging.INFO)
    # qrepl_handle_format = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    qrepl_handle_format = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
    qrepl_handle.setFormatter(qrepl_handle_format)
    logger.addHandler(qrepl_handle)
    logger.info("Junkify session started")

    if args.file:
        file_path = args.file[0]

    if args.editor:
        editor = args.editor[0]

    if args.open:
        cmd: list[str] = [editor, file_path]
        exec_cmd(cmd)

    print("Type your command and hit Enter; q or . to quit, ? or h for help")
    qrepl: Qrepl = Qrepl(file_path)
    qrepl.looping()

    return EXIT_SUCCESS


if __name__ == "__main__":
    sys.exit(main())
