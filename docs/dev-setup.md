# Setting up a machine for development

## Packages from Pop!_Shop

From within `Pop!_Shop`, remove the following packages;

* `firefox` (default debian distribution)

 install the following packages (where possible, choose `flatpak` distribution);

* `flatseal`
* `chrome`
* `firefox`
* `vs code`

## JetBrains ToolBox

Based on [Toolbox App installation](https://www.jetbrains.com/help/toolbox-app/toolbox-app-silent-installation.html#tba_installation).

```bash
sudo apt install libfuse2
```

Extract the package and run the installer;

```bash
tar -xzf jetbrains-toolbox-<build>.tar.gz && cd jetbrains-toolbox-<build>/bin && ./jetbrains-toolbox
```

Download [JetBrains toolbox app](https://www.jetbrains.com/toolbox-app/), log in and install;

* `PhpStorm`
* `RubyMine`
* `DataGrip`