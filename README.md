# KKsymbols

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Enclosing characters in various shapes for LuaLaTeX / 文字の囲み記号作成パッケージ**

---

## Overview / 概要

`KKsymbols` is a LaTeX package for enclosing characters in circles, squares, diamonds, or brackets. It features automatic scaling and baseline correction to ensure a consistent appearance in both horizontal and vertical writing modes.<br>
`KKsymbols` は、文字を丸、四角、菱形、括弧などで囲むためのコマンドを提供するパッケージです。自動スケーリングとベースライン補正機能を備えており、横書き・縦書きのどちらでも適切な外観を維持します。

- **Version**: 2.3.0
- **Date**: 2026-08-20
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
  - On every enclosure whose star is the safe-sizing route, an explicit star accepts arbitrary material and applies one common horizontal/vertical shrink factor until it fits the actual outline. The calculation follows that command's configured line width, so `\maru*{abc}`, `\seimaru*{cmj}`, and `\hishi*{j}` remain inside their frames without distorting the glyphs. `\jegg` is the exception: its star still means a gray background only.
  - スターが安全サイズ経路を選ぶ各囲みコマンドでは、明示スターに複数文字など任意の内容を渡せます。実際の枠形状と指定線幅に収まるまで縦横共通の倍率で縮小するため、`\maru*{abc}`、`\seimaru*{cmj}`、`\hishi*{j}` でも字形を歪めず枠内に収まります。例外は `\jegg` で、そのスターは従来どおり網掛けだけを選びます。

- **Recommended Style for Lowercase Roman Numerals / 小文字ローマ数字の推奨スタイル**
  - Use the **non-starred** enclosure commands together with a **single group-wide** `\kksref{\Rrnum{6}}`. The default automatic reference is the x-height of the current font, which is essentially the height of `v` and `x`, so on its own it leaves the numerals containing `i` on a different reference — a 2.23pt spread at 10pt with Hiragino Mincho Pro W3. An explicit star is not an alignment control either: it only makes the whole sequence one step smaller. One group-wide `\kksref{\Rrnum{6}}` brings the spread to 0 at every font size, in horizontal and vertical writing alike. If the range includes numerals containing `l` or `d` (50, 500, 1888, ...), use `\kksref{\Rrnum{50}}` instead.
  - 小文字ローマ数字は、**非スター版**のコマンドに `\kksref{\Rrnum{6}}` を**グループ内で一括指定**する書き方を推奨します。既定の自動基準は現在フォントの x ハイト相当で `v`・`x` 自身の高さとほぼ一致するため、それだけでは `i` を含む字との基準差が残ります（ヒラギノ明朝 Pro W3 の 10pt で 2.23pt）。明示スターも揃えるための指定ではなく、全体が一段小さくなるだけです。一括指定すれば、どのフォントサイズでも、また縦組みでも差は 0 になります。`l`・`d` を含む範囲（50, 500, 1888 など）まで揃える場合は `\kksref{\Rrnum{50}}` を使います。

- **Egg-Specific Lowercase Sizing / 楕円囲み専用の小文字サイズ**
  - `\jegg` scales a lowercase letter uniformly against the ellipse it actually draws, so `c` keeps a visibly lowercase height next to `C`, wide letters such as `m` and `w` fit inside the outline, and ascenders and descenders stay enclosed. The usable interior follows `jegglinewidth` and `linewidth`, so a thicker outline reduces the letter a little further. The star of `\jegg` still selects only the gray background.
  - `\jegg` の小文字は、実際に描かれる楕円に合わせて縦横比を保ったまま縮小されます。`c` は `C` の隣でも小文字らしい高さを保ち、`m` や `w` のような幅の広い字も、上下に伸びる字も枠内に収まります。基準となる内側の領域は `jegglinewidth`・`linewidth` に追従するため、線が太いほど文字は少し小さくなります。`\jegg` のスターは従来どおり網掛けの選択のみです。

- **Configurable Frame Line Width / 枠線の太さ指定**
  - Set a common frame thickness with `linewidth=<dimension>`, or override it for each TikZ-drawn enclosure with options such as `marulinewidth=<dimension>` and `hishilinewidth=<dimension>`. The default `auto` value preserves the historical appearance.
  - `linewidth=<寸法>` で枠線の太さを一括指定でき、`marulinewidth=<寸法>` や `hishilinewidth=<寸法>` などでコマンドごとの太さも指定できます。既定値の `auto` では従来の見た目を維持します。

- **Compatibility fixes / 互換性に関する修正**
  - The public `\maruhishi` command now reaches its intended rounded-diamond implementation instead of the filled `\kurohishi` implementation. This corrects a pre-existing miswiring and intentionally changes `\maruhishi` output. Safe-sizing stars throughout the maru, seihou, hishi, bracket, and `\ichimoji` families now use the uniform fit described above. A pre-existing context-dependent sizing leak in `\jegg*` has also been fixed, including when `autolowercase=0`.
  - 公開コマンド `\maruhishi` が誤って黒菱形の実装へ接続されていた不具合を修正したため、同コマンドの出力は意図した角丸菱形へ変わります。maru・seihou・hishi・括弧・`\ichimoji` 各系列の安全サイズ用スターは、上記の縦横均等フィットを使用します。また、`\jegg*` のサイズが直前のコマンドに左右される既存不具合も修正され、これは `autolowercase=0` の場合にも適用されます。

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
- `LuaLaTeX-ja`, `tikz`, `calc`, `luacode`, `kvoptions`

---

## Usage / 使用方法

For detailed usage and examples, please refer to the documentation file: `kksymbols-doc.tex`.<br>
具体的な使用方法や例については、ドキュメントファイル `kksymbols-doc.tex` を参照してください。
