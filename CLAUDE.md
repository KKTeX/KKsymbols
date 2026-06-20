# CLAUDE.md

このリポジトリで作業する際のガイダンス。

## 作業分担のルール（重要）

- **単純作業（git 操作など）は Haiku ないし Sonnet の subagent でやること。**
- **特に git 操作（branch / add / commit / push / status / log など）は Haiku でやること。**
- Opus は設計・根本原因分析・LaTeX マクロの実装・レビューなど、推論を要する作業に使う。
- バージョン番号・日付の更新やリリース（CTAN アップロード）はユーザー確認後に行う。

## プロジェクト概要

- `KKsymbols` … 文字を丸・四角・菱形・括弧で囲む LaTeX パッケージ（**LuaLaTeX 専用**）。
- 自動スケーリングとベースライン補正で、横書き・縦書きの両方で整った見た目を保つ。
- ライセンス: MIT。著者: Kosei Kawaguchi (KKTeX)。

## ファイル構成

- `KKsymbols.sty` … 本体。バージョン・日付は `\ProvidesPackage`（先頭付近）。
- `KKsymbols.lua` … `tsumesuji` オプション（"1" の字幅詰め）用の Lua。バージョン・日付は冒頭の `provides_module`。
- `kksymbols-doc.tex` / `kksymbols-doc.pdf` … ドキュメント。
- `test.tex` … 動作確認用（Hiragino フォント前提）。
- `Makefile` / `.latexmkrc` … ビルド設定。

## ビルド／テスト

- テスト: `make test`（= `latexmk -r .latexmkrc test.tex` 後に `latexmk -c`）。
- ドキュメント: `make doc`。
- 直接: `latexmk -r .latexmkrc <file>.tex`（`.latexmkrc` で `$pdf_mode=4`＝lualatex、`-halt-on-error`）。
- クリーン: `make clean`（PDF 残す）/ `make distclean`（PDF も削除）。
- CTAN 用 zip: `make zip`。

## 依存

`luatexja`（LuaLaTeX-ja）, `tikz`, `calc`, `luacode`, `kvoptions`。
ローマ数字（`\Rrnum` など）は外部の **KKran** パッケージ提供。

## 実装上の注意

- `\ltjghostbeforejachar` / `\ltjghostafterjachar` を使うため **LuaLaTeX 必須**。
- 囲みコマンドは「非スター（数字・大文字・漢字・かな向け、内枠いっぱいにリサイズ）」と
  「スター `*`（小文字向け、拡大しすぎない）」の2系統を各記号ごとに持つ。
- 中央寄せ・サイズは現状、引数自身のインクボックス（`\settoheight`/`\settodepth`）依存。
- 1系統だけ直して `latexmk` でコンパイル確認 → 問題なければ横展開、が安全な進め方。
- PDF を必ず目視して仮説を検証すること。

## 進行中の作業

`HANDOFF.md` を参照（中央寄せ／基準ボックス `\kksref` 改修の引き継ぎ）。
