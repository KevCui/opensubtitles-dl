# opensubtitles-dl

> Download subtitles from opensubtitles.org

## Table of Contents

- [Why](#why)
- [Dependency](#dependency)
- [How to use](#how-to-use)
  - [Usage](#usage)
  - [Example](#example)

## Why

I need a simple CLI subtitle downloader that works without an API key. I looked online but couldn’t find a good one... Now, I build this one.

## Dependency

- [curl](https://curl.haxx.se/download.html)
- [pup](https://github.com/EricChiang/pup)
- [fzf](https://github.com/junegunn/fzf)
- [unzip](http://infozip.sourceforge.net/UnZip.html#Downloads)
- [jq](https://jqlang.org/download/)

## How to use

### Usage

```
Usage:
  ./opensubtitles-dl.sh [-n <name>] [-l <lang>] [-d]

Options:
  -n <name>               TV series or Movie name
  -l <lang>               optional, language
                          e.g.: eng, spa, fre...
                          default: eng
  -a                      optional, download all available subtitles
  -d                      enable debug mode
  -h | --help             display this help message
```

### Example

- Download Spanish subtitle of "The Witcher" Season 2 Episode 1:

```
$ ./opensubtitles-dl.sh -n 'the witcher s2.e1' -l spa
[INFO] IMDb ID: tt11277244

> [8913673] [S02E01] The.Witcher.S02E01.720p.WEB.H264-PECULATE_track...
  [8912912] [S02E01] The Witcher S02E01 - A Grain of Truth - 2160p N...
```

- Download all English subtitles of "The Witcher" Season 2 Episode 1:

```
$ ./opensubtitles-dl.sh -n 'the witcher s2.e1' -l eng -a
```

---

<a href="https://www.buymeacoffee.com/kevcui" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-orange.png" alt="Buy Me A Coffee" height="60px" width="217px"></a>