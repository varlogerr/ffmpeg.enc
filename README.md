# <a id="top"></a> VEncoder

Single and batch encoder for videos.

This script is currently under development and can be changed at any moment.

* [Demo](#demo)
* [Development](#development)
* [Plans](#plans-if-ever)

## Demo

```sh
# encode 1 video with default preset
vencoder.sh ./src.mp4 ./enc.mkv
# encode all videos with default preset
vencoder.sh ./src ./dest
# encode all directory videos from with
# `screen720p` preset
vencoder.sh ./src ./dest -p screen720p
# encode all directory videos with custom 
# configuration
vencoder.sh ./src ./dest -f ./myconf.conf
# print help
vencoder.sh -h
```

[To top]

## Development

* install dependencies

  ```sh
  git clone https://github.com/varlogerr/toolbox.sh.vendor.git ./vendor/vendor
  cd ./vendor/vendor
  git checkout <latest-tag>
  cd -
  # initialize the project
  ./vendor/vendor/bin/vendor.sh --init .
  # install dependencies. after initialization
  # there will be only vendor itself as a dependency
  ./vendor/vendor/bin/vendor.sh
  ```
* (optional) add `vendor/.bin` to the `PATH`
* make changes
* add / edit tests and run them with
  ```sh
  ./vendor/.bin/tester.sh run
  ```
* when completed run

  ```sh
  # see release types
  ./vendor/.bin/preprod.sh --help
  ./vendor/.bin/preprod.sh RELEASE_TYPE
  ```

[To top]

## Plans (if ever)

* Make interface:

  ```sh
  vencoder.sh SOURCE... [-d DEST] [-p PRESET] [-f CONFFILE...]
  vencoder.sh SOURCE... [-d DEST] \
    [-p PRESET] [-f CONFFILE...] - <<< "SOURCELIST"
  ```
* Think of merging PRESET and CONFFILE under one flag
* Extend base preset settings

[To top]

[To top]: #top
