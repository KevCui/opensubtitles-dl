# opensubtitles-dl

> Download subtitles from opensubtitles.org

## Table of Contents

- [Why](#why)
- [Dependency](#dependency)
- [How to use](#how-to-use)
  - [Usage](#usage)
  - [Example](#example)

## Why

I need a simple CLI subtitle downloader and it should work without using API key. I searched around online but didn't find a good one... Now, I have one.

## Dependency

- [curl](https://curl.haxx.se/download.html)
- [pup](https://github.com/EricChiang/pup)
- [fzf](https://github.com/junegunn/fzf)
- [unzip](http://infozip.sourceforge.net/UnZip.html#Downloads)

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
$ ./opensubtitles-dl.sh -n 'the witcher s02e01' -l spa
> [11277244] "The Witcher" A Grain of Truth (TV Episode 2021) - IMDb
  [5180504] The Witcher (TV Series 2019– ) - Episodes - IMDb
  [8071662] "The Witcher" The End's Beginning (TV Episode 2019) - IMDb
  [8343768] "The Witcher" Four Marks (TV Episode 2019) - IMDb
  [0092319] Beauty and the Beast (TV Series 1987–1990) - IMDb
  [2177461] A Discovery of Witches (TV Series 2018–2022) - IMDb
  [2919798] The Suspicions of Mr Whicher: The Murder in Angel Lane - IMDb
  [8111088] The Mandalorian (TV Series 2019– ) - IMDb

> [8913673] [S02E01] The.Witcher.S02E01.720p.WEB.H264-PECULATE_track...
  [8912912] [S02E01] The Witcher S02E01 - A Grain of Truth - 2160p N...

Archive:  8913673.zip
  inflating: The.Witcher.S02E01.720p.WEB.H264-PECULATE_track10_[spa].srt
```

- Download all English subtitles of "The Witcher" Season 2 Episode 1:

```
$ ./opensubtitles-dl.sh -n 'the witcher s02e01' -l a
> [11277244] "The Witcher" A Grain of Truth (TV Episode 2021) - IMDb
  [5180504] The Witcher (TV Series 2019– ) - Episodes - IMDb
  [8071662] "The Witcher" The End's Beginning (TV Episode 2019) - IMDb
  [8343768] "The Witcher" Four Marks (TV Episode 2019) - IMDb
  [0092319] Beauty and the Beast (TV Series 1987–1990) - IMDb
  [2177461] A Discovery of Witches (TV Series 2018–2022) - IMDb
  [2919798] The Suspicions of Mr Whicher: The Murder in Angel Lane - IMDb
  [8111088] The Mandalorian (TV Series 2019– ) - IMDb

Archive:  8912474.zip
  inflating: The.Witcher.S02E01.1080p.NF.WEB-DL.DDP5.1.Atmos.x264-TEPES.srt

Archive:  8912473.zip
  inflating: The.Witcher.S02E01.1080p.NF.WEB-DL.DDP5.1.Atmos.x264-TEPES-HI.srt

Archive:  8911224.zip
  inflating: The.Witcher.S02E01.1080p.WEB-DL.AAC.2.0.x264-Telly_track3_[eng].srt

Archive:  8911223.zip
  inflating: The.Witcher.S02E01.1080p.WEB-DL.AAC.2.0.x264-Telly_track3_[eng].srt
```

---

<a href="https://www.buymeacoffee.com/kevcui" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-orange.png" alt="Buy Me A Coffee" height="60px" width="217px"></a>