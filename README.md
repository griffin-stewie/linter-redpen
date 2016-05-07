# linter-redpen - Atom package

A plugin for Atom Linter providing an interface to [RedPen](http://redpen.cc/).

![screencast of package](https://gyazo.com/71a103608be3dd8abc3f14992ba21a43.gif)

## Installation

```
$ apm install linter-redpen
```

## Usage

### Install `RedPen` CLI

This package requires RedPen CLI version 1.5 or greater.
Install with [Homebrew](http://brew.sh/ "Homebrew — The missing package manager for OS X")
```
$ brew install redpen
```

Or you can install `RedPen` CLI manually from [here](http://redpen.cc/docs/latest/index.html")

### Set Up Paths If needs

This package needs set up some paths from Settings

- Path for RedPen CLI
    - `redpen` is default
- Path for Configuration XML File
    - RedPen CLI needs configuration XML file for validation. you can set your configuration XML file.
- Locale for Configuration XML File    
    - uses auto detect configuration XML file
- JAVA_HOME Path
    - RedPen CLI needs JAVA_HOME path.

If you prefer to use RedPen server than CLI. You can set your RedPen Server endpoint on `Path for RedPen CLI` fieald.

### Run

1. open a text file as bellow
    - Markdown
    - Textile
    - Plain
    - AsciiDoc
2. You can see report pane at bottom.

### Searching Configuration XML

linter-redpen searches configuration XML. searching order is

1. `Path for Configuration XML File` on settings
1. in the same directory as the target text file
1. in the project root directory
1. directly under `REDPEN_HOME`
1. directly under `REDPEN_HOME/conf/`

Configuration XML File name shold be

- `redpen-conf.xml`
- `redpen-conf-{LOCALE}.xml`
   - ex: `redpen-conf-ja.xml` OR `redpen-conf-en.xml`

You can set your `{LOCALE}` on settings.
