# wolfish
A custom built fish shell theme extension

# Install
```
omf cd
cd themes
git clone https://github.com/WolfenGames/wolfish ./wolfish
omf theme wolfish
```

## To customize your shell

In order to display certain versions you will need to enable the following in which ever config file you use:
```
set -g wolfish_display_wtc_lms_version yes
set -g wolfish_display_venv yes
set -g wolfish_display_ruby_version yes
set -g wolfish_display_java_version yes
set -g wolfish_display_maven_version yes
set -g wolfish_display_rust_version yes
set -g wolfish_display_docker_composed_version yes
set -g wolfish_display_docker_version yes

```

To remove them, simply remove from the config file of your choice

# TODO:

- [x] Envronment specific variables to hide certain output from version checks
- [x] Locate python/java projects before doing timeout check
