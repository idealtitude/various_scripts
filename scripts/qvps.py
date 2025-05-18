#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
qvps is an alternative to the `qps` utility with main difference being that it create a ccopy
of the template in `/$HOME/Dev/VCS`, and do a `git init` in that copy, then it does a `git clone`
in the current working directory.
"""

from typing import Any

import sys
import os
import shutil
import subprocess
import string
#import re
import argparse
import configparser

# App infos
__app_name__     : str = "qvps"
__app_author__   : str = "idealtitude"
__app_version__  : str = "0.1.0"
# Constants
EXIT_SUCCESS     : int = 0
EXIT_FAILURE     : int = 1
APP_DESCR        : str = f"""{__app_name__} innstantiate a copy of project from a template, in the VCS folder, git inits it, and clone that project in the current working directory"""
USER_CWD         : str = os.getcwd()
VCS_PATH        : str = os.path.join(os.getenv("HOME"), "Dev/VCS")
TPL_PATH        : str = os.path.join(os.getenv("HOME"), "Dev/RES/tpl")
CONF_FILE_PATH   : str = os.path.join(os.getenv("HOME"), f".local/share/{__app_name__}/{__app_name__}.conf")


# Templates listing
def list_templates(tpl_path: str) -> list[str]|None:
    """
    This function lists all the folders in VCS_PATH which contains
    all the available templates that the user can choose, by default, but this can be override with the  `-t` option from the command line

    Returns
    -------
    list
        a list of strings representing the type available templates
    """
    tpls: list[str]| None = None

    try:
        tpls = os.listdir(tpl_path)
    except FileNotFoundError as e:
        return None

    return tpls


def get_config(config_file_path: str) -> dict[str, dict[str, str]]:
    """
    Get the default configuration

    Parameters
    ----------
    string
        a path to the configuration file

    Returns
    ------
    Union
        wether a dictionary with the configuration, or False
    """
    config: dict[str, dict[str, str]] = {}

    confparser: configparser.ConfigParser = configparser.ConfigParser()
    confparser.read(config_file_path)
    tmp_conf: list[str] = confparser.sections()
    for key in tmp_conf:
        config[key] = {}
        for k, v in confparser[key].items():
            config[key][k] = v

    return config

def check_config(config: dict[str, str]) -> tuple[bool, list[str]]:
    """Check if the configuration is ok"""
    res: tuple[bool, list[str]] = (False, ())

    if not config.get("Templates"):
        res[0] = True
        res[1].append("The \"Templates\" section has not been found in the configuration")
    else:
        if not config["Templates"].get("path"):
            res[0] = True
            res[1].append("The key \"path\" has not been found in the \"Templates\" section the configuration")
    if not config.get("VCS"):
        res[0] = True
        res[1].append("The \"VCS\" section has not been found in the configuration")
    else:
        if not config["VCS"].get("path"):
            res[0] = True
            res[1].append("The key \"path\" has not been found in the \"VCS\"section of the configuration")

    return res

# Cleaning project name
def clean_project_name(project_name: str) -> str:
    clean_name = project_name.strip()
    clean_name = clean_name.replace(' ', '_')
    authorized_chars = [*string.ascii_letters, *string.digits, '-', '_']
    for letter in clean_name:
        if letter not in authorized_chars:
            clean_name = clean_name.replace(letter, '')
    return clean_name

def process_cmd(tpl_path: str, vcs_path, project_path: str, project_type: str, project_name: str) -> bool:
    """Processing the command with all the arguments"""
    # Create path of the template to copy
    tpl = os.path.join(tpl_path, project_type)
    if not os.path.isdir(tpl):
        print(tpl)
        print(f"No {project_type} template found in {tpl_path}")
        return False

    # Create destination path in VCS
    proj = os.path.join(vcs_path, project_name)
    if os.path.exists(proj):
        print(f"A folder withe the name {project_name} already exists  {project_path}")
        return False

    try:
     shutil.copytree(tpl, proj)
    except FileExistsError as ex:
        print(f"Failed to copy the project in VCS folder: {ex}")
        return False

    '''
    1. `git init`
        2. `git add .`
        3. `git commit -m 'Initial Commit'`
        4. `git branch -M main`
    * `cd` to the working directory, then:
        1. `git clone /$HOME/Dev/VCS/Myproject`
        2. `git remote add local /$HOME/Dev/VCS/MyProject`
    '''
    # ### git init
    # cd in proj
    os.chdir(proj)
    # subprocess `git init`
    gitinit_   = subprocess.call(["git", "init"])
    gitadd_    = subprocess.call(["git", "add", '.'])
    gitcommit_ = subprocess.call(["git", "commit", "-m", "'Initial Commit'"])
    gitbranch_ = subprocess.call(["git", "branch", "-M", "main"])
    # if update_file != 0:
    #     print("Failed to execute `git init` in {proj}")

    # cd back in project
    os.chdir(project_path)
    # git clone, etc.
    gitclone_proj = subprocess.call(["git", "clone", proj])
    lproj = os.path.join(project_path, project_name)
    os.chdir(lproj)
    gitremote_proj = subprocess.call(["git", "remote", "add", "local", proj])

    print(f"Everythings done! You can `cd {lproj}, and start working on your new project...")

    return True

# Command line arguments
def get_args() -> Any:
    """Parsing command line arguments"""
    parser: Any = argparse.ArgumentParser(
        prog=f"{__app_name__}", description=APP_DESCR, epilog=f"Do `{__app_name__} --help` to display the help"
    )

    parser.add_argument("-n", "--name", nargs=1, help="Name of project")
    parser.add_argument("-t", "--type", nargs=1, help="Type of project")
    parser.add_argument("-l", "--list-templates", action="store_true", help="List available templates")
    parser.add_argument("-T", "--templates-path", nargs=1, help="Provides a path to a specific template")
    parser.add_argument("-r", "--remote", nargs=1, help="Defines a specific path where to create the git repository, instead of the pre-defined VCS folder")
    parser.add_argument("-o", "--origin", nargs=1, help="Defines a specific path where to clone the git repository, instead of the current working directory")
    parser.add_argument("-c", "--config", nargs=1, help="Defines a specific path for an alternate configuration file")
    parser.add_argument(
        "-v", "--version", action="version", version=f"%(prog)s {__app_version__}"
    )

    return parser.parse_args()


def qvps_init() -> bool:
    """Initialisation of qvps"""
    #sys.tracebacklimit = 0

    # Command line arguments
    args: argparse.Namespace = get_args()

    # App default configuration path
    conf_path: str = CONF_FILE_PATH
    # TODO: change or delete this later
    # Fallback on local confi file
    if not os.path.isfile(conf_path):
        conf_path = "./qvps.conf"
    elif args.config:
        # User defined config file
        conf_path = args.config

    # Final chekc of the config file path
    if not os.path.isfile(conf_path):
        raise FileNotFoundError(f"The configuration file has not been found at {conf_path}")

    # Configuration content
    conf: dict[str, list[str]] = get_config(conf_path)

    # Checking conf
    conf_ok: tuple[bool, list[str]] = check_config(conf)
    if conf_ok[0]:
        for e in conf_ok[1]:
            print(e)
        print("Configuration is not valid, exiting now...")
        return EXIT_FAILURE

    # List templates
    if args.list_templates:
        if "Templates" in conf.keys():
            tpls = list_templates(conf["Templates"]["path"])
            if tpls is None:
                raise FileNotFoundError(f"The template folder has not been found at {conf["Templates"]}")
        else:
            raise KeyError(f"The key \"Templates\" has not been found in the configuration")

        for tpl in tpls:
            print(tpl)

        return EXIT_SUCCESS

    ### Process command line arguments ###
    tpl_path: str  = conf["Templates"]["path"]
    vcs_path: str  = conf["VCS"]["path"]
    project_path: str = USER_CWD
    project_type: str = "nil"
    project_name: str = "nil"

    if args.templates_path:
        tpl_path = args.template[0]

    if args.remote:
        vcs_path = args.remote[0]

    if args.origin:
        project_path = args.origin[0]

    if args.type:
        project_type = args.type[0]

    if args.name:
        project_name = args.name[0]

    if project_type == 'nil':
        print("No project type has been defined; use the `-t` option to define one")
        return EXIT_FAILURE

    if project_name == 'nil':
        print("The project name has not been defined; use the `-n` option to define it")
        return EXIT_FAILURE

    project_name = clean_project_name(project_name)

    # FInal chekc of the command arguments
    if not os.path.isdir(tpl_path):
        raise FileNotFoundError(f"The template directory does not exists; expected location: {tpl_path}")
    if not os.path.isdir(vcs_path):
        raise FileNotFoundError(f"The VCS directory does not exists; expected location: {vcs_path}")

    # Everything OK, let's proceed to execute the command
    exec_vcs: bool = process_cmd(tpl_path, vcs_path, project_path, project_type, project_name)

    if not exec_vcs:
        return False

    return True

def main() -> int:
    """Entry point, main function."""
    init: bool = qvps_init()

    if not init:
        return EXIT_FAILURE

    return EXIT_SUCCESS

if __name__ == "__main__":
    sys.exit(main())
