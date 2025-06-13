# Various Scripts

This repos is just a backup for various scripts that I wrote for perosnal use. However, if your interested in using some of these, see their description below.

## Scripts list

**/!\ Warning:** be careful, the scripts are far from perfect, they may contain bugs (and some of them, most certaintantly contain bugs); so take care of backing up any work before using them.

**! Notice:** some of the scripts require external command, bash builtins, and/or external apps

The scripts are located in the folder of the same name, [./scripts](./scripts "Link to the scripts folder"); here is their list:

*  `cw.sh`, **c**hange **w**wallpaper; select randomly wallpapers for your monitors, from a folder (inside the script, edit the path to the folder containing your wallapers). Requirements:
    - `feh`, an images viewer and manager that can also set screens wallpapers
    - A bunch of wallpapers, but that's not really a requirement, after all uou can only have and use just a couple of them
*  `junkify.sh`, for the "tout-venant', it creates a folder with a file in it, and open that file in a editor (inside the script, edit the path to the folder where you want to create these "junks"). Requirements:
    - the default text editor is `nani`, but you can define another one
*  `ldmv.py`, **l**ist **d**irectory (and) **m**ov**e listed elements in a folder named `BAK`. Requirements:
    - Python >= 3
    - Apache, MariaDB (but you can modify the script to use `nginx` and/or any other ORM you want)
    - be careful, this script requires `root` privileges to execute as it subprocesses `systemctl`
*  `qac.sh`, **q**uick **a*scii (escape sequences) **c**odes, lists colors and styles escapes sequences to format text in your terminal
*  `qcc.sh`, **q**uick **C** **c**ode, quickly create a folder to write C code, from a template, and open its `main.c` in your terminal (edit the file to define the path to the template folder you want to use, and the terminal you want to use)
*  `qcpp.sh` same as `qcc` but for `c++`
*  `qc.sh`, **q**uick **code** create a folder from template (edit the file to define the path to your templates folders)
*  `qps.sh`, **q**uick **p**roject *s**etup, basically the same as `qc`, but specifically for more sophisticated templates (inside the script, edit the path to your templates)
*  `qrepl.py`, **q**uick **repl** emulate a command line; its purpose is to be be used by other scripts than need such feature (see `qtmp.sh` for example). Requirements:
    - Python >= 3
    - Several Python modules (see the import in the scripts)
*  `qtmp.sh`, **q**uick **tmp** creates a temporary file and ope it in an editor (edit the script to define the various things you want, like the default editor, the default file extension, etc.)
*  `qvps.conf`, this is the configuration file used by `qvps.py`
*  `qvps.py`, **q**uick **v**ersioning **p**roject **s**etup cteates project folders from templates, `git init`s them, `git clone`s them, so that you can `clone`, `push`, etc. locally, it also operates several strings substitution in the instanciated project folder; you can redefine these strings as you see fit, just edit the script. Requirements:
    - Python >= 3
    - several Python modules (see the imports in the scripts)
    - the `uv` Python project manager (but that's not mandatory)
*  `sgi.sh`, **s**elect **g**it **i**gnore presents a menu with all your various `.gitignore` to copy them quickly; edit the script to define the path t your `.gitignore` files

And that's all folks :smile: for the moment... I may or may not add/remove/update these scripts; if you have question or if you need help, please contact me, I'll be pleased to help.
