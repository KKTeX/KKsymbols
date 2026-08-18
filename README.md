# KKsymbols

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Enclosing characters in various shapes for LuaLaTeX / 文字の囲み記号作成パッケージ**

---

## Overview / 概要

`KKsymbols` is a LaTeX package for enclosing characters in circles, squares, diamonds, or brackets. It features automatic scaling and baseline correction to ensure a consistent appearance in both horizontal and vertical writing modes.<br>
`KKsymbols` は、文字を丸、四角、菱形、括弧などで囲むためのコマンドを提供するパッケージです。自動スケーリングとベースライン補正機能を備えており、横書き・縦書きのどちらでも適切な外観を維持します。

- **Version**: 2.2.2
- **Date**: 2026-06-26
- **Author**: Kosei Kawaguchi (a.k.a. KKTeX)
- **License**: MIT
- **Repository**: [https://github.com/KKTeX/KKsymbols](https://github.com/KKTeX/KKsymbols)
- **Support**: p.c.aces1056@gmail.com

---

## Acknowledgements / Credits
In developing this package, I made extensive use of the advice I received from Mr. Yusuke Terada.

I recommend you to refer to his article when you develop new-type symbols on LaTeX.

- **Link**: [https://doratex.hatenablog.jp/entry/20211205/1638697391](https://doratex.hatenablog.jp/entry/20211205/1638697391)
---

## Key Features / 特徴

- **Various Enclosures / 多彩な囲み形状**
  - Easily enclose text in circles, squares, diamonds, and brackets.
  - 丸、四角、菱形、括弧による囲み文字を簡単に作成できます。

- **Smart Scaling & Alignment / 自動調整機能**
  - Features automatic scaling and baseline correction for perfect alignment with surrounding text.
  - 文字サイズに合わせた自動スケーリングと、ベースラインの自動補正機能を搭載しています。

- **Automatic Lowercase Detection / 小文字の自動判定**
  - An argument that fully expands to exactly one lowercase ASCII letter, including one-letter results from `KKran`, automatically uses the lowercase-safe sizing path. Multi-letter strings such as `abc` and `\Rrnum{8}` keep the normal path unless an explicit star is used. Set `autolowercase=0` to disable automatic selection and use stars manually.
  - 完全展開後が小文字ASCIIちょうど1字の引数（`KKran` の展開結果が1字の場合を含む）は、小文字向けサイズに自動調整されます。`abc` や `\Rrnum{8}` のような複数文字は通常経路のままで、必要なら明示的にスターを使用できます。自動選択を無効にする場合は `autolowercase=0` を指定します。

- **Configurable Frame Line Width / 枠線の太さ指定**
  - Set a common frame thickness with `linewidth=<dimension>`, or override it for each TikZ-drawn enclosure with options such as `marulinewidth=<dimension>` and `hishilinewidth=<dimension>`. The default `auto` value preserves the historical appearance.
  - `linewidth=<寸法>` で枠線の太さを一括指定でき、`marulinewidth=<寸法>` や `hishilinewidth=<寸法>` などでコマンドごとの太さも指定できます。既定値の `auto` では従来の見た目を維持します。

- **Compatibility fixes / 互換性に関する修正**
  - The public `\maruhishi` command now reaches its intended rounded-diamond implementation instead of the filled `\kurohishi` implementation. This corrects a pre-existing miswiring and intentionally changes `\maruhishi` output. Explicit stars on the four diamond commands now select an aspect-ratio-preserving lowercase path that fits the glyph inside the diamond. A pre-existing context-dependent sizing leak in `\jegg*` has also been fixed, including when `autolowercase=0`.
  - 公開コマンド `\maruhishi` が誤って黒菱形の実装へ接続されていた不具合を修正したため、同コマンドの出力は意図した角丸菱形へ変わります。菱形4コマンドの明示スターは、字形の縦横比を保ちつつ菱形内へ収める小文字向け経路を選ぶようになりました。また、`\jegg*` のサイズが直前のコマンドに左右される既存不具合も修正され、これは `autolowercase=0` の場合にも適用されます。

- **Multi-Directional Support / 縦書き・横書き両対応**
  - Works seamlessly in both horizontal and vertical writing modes.
  - 横書きだけでなく、縦書き環境でも崩れることなく使用可能です。

- **Modern Engine Support / LuaLaTeX専用**
  - Optimized specifically for LuaLaTeX.
  - LuaLaTeXに最適化された設計となっています。

---

## Prerequisites / 前提条件

> This package is **LuaLaTeX-only**.  
> 本パッケージは **LuaLaTeX専用** です。

**Dependencies / 依存パッケージ:**
- `LuaLaTeX-ja`, `tikz`, `clac`, `luacode`, `kvoptions`

---

## Usage / 使用方法

For detailed usage and examples, please refer to the documentation file: `kksymbols-doc.tex`.<br>
具体的な使用方法や例については、ドキュメントファイル `kksymbols-doc.tex` を参照してください。
