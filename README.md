# KKsymbols

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Enclosing characters in various shapes for LuaLaTeX / 文字の囲み記号作成パッケージ**

---

## Overview / 概要

`KKsymbols` is a LaTeX package for enclosing characters in circles, squares, diamonds, or brackets. It features automatic scaling and baseline correction to ensure a consistent appearance in both horizontal and vertical writing modes.<br>
`KKsymbols` は、文字を丸、四角、菱形、括弧などで囲むためのコマンドを提供するパッケージです。自動スケーリングとベースライン補正機能を備えており、横書き・縦書きのどちらでも適切な外観を維持します。

- **Version**: 2.0.2
- **Date**: 2026-01-20
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
- `LuaLaTeX-ja`, `tikz`, `clac`

---

## Usage / 使用方法

For detailed usage and examples, please refer to the documentation file: `kksymbols-doc.tex`.<br>
具体的な使用方法や例については、ドキュメントファイル `kksymbols-doc.tex` を参照してください。

---

## License / ライセンス

This package is licensed under the **MIT License**.<br>
本パッケージは **MITライセンス** のもとで公開されています。

```text
Copyright (c) 2025 Kosei Kawaguchi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
