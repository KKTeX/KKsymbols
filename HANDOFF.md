# 引き継ぎファイル — KKsymbols 中央寄せ／基準ボックス改修

> 対象: codex（および後続の作業者）
> 作成: 2026-06-21 / 起点ブランチ: `dev`
> 作成者メモ: 根本原因の診断はソース読解ベースで開始したが、下記「実装・検証状況」のとおり
> コンパイル＆目視＆ピクセル比較まで実施済み。

---

## ⏩ 実装・検証状況（2026-06-21 更新）

**問題1は候補実装が完了し、検証済み。**

- `KKsymbols.sty` に `\kksref` / `\kksrefreset` / 内部 `\kks@withref` を実装（§3 の設計どおり）。
- 適用範囲は **全系統に横展開済み**（maru/kuromaru/nmaru/jegg、seihou/kuroseihou/seimaru/kuroseimaru、
  hishi 系、kakko 系、ichimoji）。`\kks@ShrinkedNumber{#1}`/`{#3}` の描画箇所と、`@no` 系の
  `\settoheight`/`\settodepth`（maru/seihou/kakko/ichimoji 各 var）に `\kks@withref` を注入。
- **重要な使い方の訂正**: ユーザーはローマ数字小文字を **非スター `\maru{\Rrnum{n}}`** で使う
  （スター `*` は付けない）。`\kksref` は非スター経路でも機能する。
- **検証結果**:
  - `\kksref{\Rrnum{6}}\maru{\Rrnum{n}}` は手書き `\maru{\vphantom{\Rrnum{6}}\Rrnum{n}}` と
    **ボックス寸法 w/h/d が完全一致**（n=1,2,3,6,7,8）、かつ赤黒オーバープリントで**赤残差ゼロ**＝描画一致。
  - **後方互換**: `\kksref` 未使用時、既存 `test.tex`（全記号・数字0-26・小文字m）の出力が
    旧 `.sty` と **1ピクセルも違わない**（`magick compare -metric AE` = 0）。
- 検証用ファイル: `test-kksref.tex`（(a)無し/(b)手書き/(c)\kksref の比較）, `sample-kksref.tex`（実用リスト）。
- まだ **コミットは feature ブランチに行う段階**（git 操作は Haiku に委譲、`CLAUDE.md` 規約）。

**問題2（フォント差の中央ズレ＝既定の中央寄せ変更）は未着手。**
ユーザー指示: 既定変更は **別ブランチ `feat/font-stable-centering`** で実装→テスト→ユーザー目視確認→
その後にバージョンアップ可否を判断。§3末尾の案A/Bを参照。

---

## 0. ゴール（ユーザー要望）

1. **問題1**: ローマ数字小文字（`\Rrnum{n}`, KKran パッケージ提供）を囲みコマンドに入れるとき、
   見た目を揃えるために毎回 `\vphantom{\Rrnum{6}}` を引数の中に手書きしないといけない。これを解消する。
2. **問題2**: フォントによって、丸・四角などの「中央」から引数の出力位置がズレる。これを解消する。

ユーザーの指示（重要）:
- **規定値（デフォルト）は変えてよい。ただし別ブランチで行い、テストした上で、ユーザーに確認してからバージョンアップの可否を決める。**
- 単純作業（特に git 操作）は Haiku/Sonnet の subagent に任せる（`CLAUDE.md` 参照）。

---

## 1. パッケージ構造の要点

- 本体: `KKsymbols.sty`（LuaLaTeX 専用、luatexja 依存）。
- Lua: `KKsymbols.lua` … `tsumesuji` オプション（"1" の字幅を詰める）用の `KKS.narrow_ones`。
- ドキュメント: `kksymbols-doc.tex` → `kksymbols-doc.pdf`。
- テスト: `test.tex`（Hiragino フォント前提。`\maru` 等を 0–26 で総当たり出力）。
- ビルド: `make test` / `make doc`（`latexmk -r .latexmkrc`、`$pdf_mode=4` で lualatex）。

### 公開コマンド（すべて1引数、`*` 付きあり）
`\maru \kuromaru \nmaru \jegg \seihou \kuroseihou \seimaru \kuroseimaru \hishi \kurohishi \maruhishi \kuromaruhishi \ichimoji`
括弧系: `\kakko \sumikakko \kakukakko \kikakko \ykakko \nykakko \namikakko \kagikakko \nkagikakko`
回転: `\RotYoko[..] \RotTate[..]`（スコープ依存の持続効果。`\kksref` はこれと同じ流儀で作る）

### `*`（スター）の意味 — ここが核心
- 非スター `\maru` → 内部 `\maru@new`。**引数を内枠の総高さ(h+d)いっぱいにリサイズ**して詰める（数字・大文字・漢字・かな向け）。
- スター `\maru*` → 内部 `\maru@new@no`。`\settoheight`+`\settodepth` で引数の総高 `zenkou` を測り、
  `\shukushou@adj@new@no@*` で「内容が小さいときは拡大しすぎない（`\scalebox{.9}` 止まり／幅で縮小）」**小文字向け**の制御をする。
  ドキュメント上「小文字アルファベットのときは必ずスターを使え」と明記（`kksymbols-doc.tex` の maru series 節）。

---

## 2. 根本原因の分析（Opus 推論）

**問題1と問題2は同一の根に由来する。**
囲みコマンドは、引数の **サイズ決定** と **垂直方向の中央寄せ** を、
*引数そのもののインクボックス（`\settoheight`/`\settodepth` の値）* に基づいて行っている。

- ローマ数字小文字 `ⅰ ⅵ ⅷ`（= 実体は小文字 i,v,x 列）は字ごとに高さ・幅・深さが異なる。
  - スター経路の `\shukushou@adj@new@no@*` は「総高 < 内枠」のとき幅で縮小 or `.9` 固定 → **字ごとにサイズがばらつく**。
  - 中央寄せは各字のインクボックス基準 → **字ごとに上下位置がばらつく**。
  - → ユーザーは `\vphantom{\Rrnum{6}}` を前置し、**全字に共通の基準ボックス（= "ⅵ" の高さ・深さ）** を与えて見た目を揃えている。
    （`\vphantom` は幅0なので幅は実内容のまま、高さ・深さだけ "ⅵ" に固定される。これが効くポイント。）
- フォント差で「中央からズレる」のも同根: インクボックスの中心と「視覚的中心」の関係はフォント依存。
  固定の `\raisebox{-.12\zw}`（横）/`-.5\zw`（縦）マジック定数（`\vertical@adj@maru@new` 他）も一因。

### 中央寄せの実装位置（横・`\maru@new` 例、`KKsymbols.sty` L423–468 付近）
```
\raisebox{\vertical@adj@maru@new}{        % 横 -.12\zw / 縦 -.5\zw（固定）
  \vbox to \maru@boxwidth@new{ \vss
    \hbox to \maru@boxwidth@new{ \hss
      \tikz[baseline=(char.base)]{ \node[circle,...] (char){
        \vbox to \maru@boxwidth@inner{ \vss
          \hbox to \maru@boxwidth@inner{ \hss CONTENT \hss }
        \vss }
      };}
    \hss }
  \vss }
}
```
CONTENT = `\shukushou@adj@new{<幅>}{<内枠>}{\kks@ShrinkedNumber{#1}}`。
内枠 `\vbox to inner{\vss \hbox \vss}` が **CONTENT のインクボックスを中央寄せ**している。

---

## 3. 提案する統一設計（候補実装）

「グリフ依存の寸法」を「**一定の基準ボックス**」に置き換える。これで問題1・2を同時に解く。

### 機構: `\kksref`
```latex
% 既定は空 = 従来動作（後方互換）
\def\kks@ref@material{}
\DeclareRobustCommand{\kksref}[1]{\def\kks@ref@material{#1}}   % スコープ依存（\RotYoko と同流儀）
\DeclareRobustCommand{\kksrefreset}{\def\kks@ref@material{}}
% 内容に基準ボックスの高さ・深さを与えるラッパ（ユーザーの手書き \vphantom{ref}#1 と等価）
\def\kks@withref#1{\ifx\kks@ref@material\@empty #1\else\vphantom{\kks@ref@material}#1\fi}
```

### 適用方法（最小侵襲・後方互換）
各囲みマクロで:
1. 寸法測定 `\settoheight{...}{#1}` / `\settodepth{...}{#1}` の被測定を `\kks@withref{#1}` に置換。
   - `\settowidth` は `#1` のまま（`\vphantom` は幅0なので結果同じ。幅は実内容で取りたい）。
2. 実際に描画する `\kks@ShrinkedNumber{#1}` を `\kks@withref{\kks@ShrinkedNumber{#1}}` に置換。

これは **ユーザーがやっている `\vphantom{\Rrnum{6}}#1` をパッケージが自動注入する** のと等価。
`\kks@ref@material` が空（既定）なら一切変化なし → 後方互換。

### 使い方（問題1の解消）
```latex
{\kksref{\Rrnum{6}}%
  \maru*{\Rrnum{1}}\maru*{\Rrnum{2}}\maru*{\Rrnum{8}}}   % もう \vphantom 不要
```
enumerate のラベルでも一括設定できる:
```latex
\setlist[...]{label=\maru*{\Rrnum*}}   % 直前で \kksref{\Rrnum{6}} をスコープ指定
```
> API は他に「オプション引数 `\maru*[\Rrnum{6}]{\Rrnum{3}}`」案もある。
> 今回の候補は **スコープ設定 `\kksref`** を主とする（リストのラベルで一括指定しやすい）。
> オプション引数案も併設するかは要検討（codex 判断可）。

### 問題2（フォント差の中央ズレ）— **別ブランチ・要確認**
既定の中央寄せ基準を「グリフのインク」ではなく「**フォント正規化された基準**」にする:
- 案A: 既定 `\kks@ref@material` を現フォントの数字メトリクス（例 `0` や `8`）相当の strut にする。
- 案B: cap-height / x-height をフォントから取得して strut を作る。
これは **既定出力が変わる**ため、ユーザー指示により:
1. 専用ブランチで実装、2. テスト、3. ユーザーに目視確認、4. その後にバージョンアップ可否を判断。

---

## 4. ブランチ計画

- `feat/kksref-reference-box` … §3 の `\kksref` 機構＋自動 vphantom 注入（**後方互換**、問題1）。
- `feat/font-stable-centering` … §3 末尾の既定中央寄せ変更（**既定変更**、問題2）。`feat/kksref-...` から派生させると基準ボックス機構を再利用できる。

各ブランチで `test-kksref.tex`（後述）をコンパイルし目視確認。バージョン番号・日付（`.sty` L28, `.lua` L1–5）は **ユーザー確認後** に上げる。

---

## 5. 触るマクロ一覧（grep の起点）

`\settoheight`/`\settodepth`/`\kks@ShrinkedNumber` を含むマクロすべて:
- maru 系: `\maru@new`(L423) `\maru@new@no`(L469) `\kuromaru@new`(L516) `\kuromaru@new@no`(L563)
  `\nmaru@new`(L612) `\nmaru@new@no`(L659) `\jegg@new`(L708) `\jegg@new@black`(L756)
- seihou 系: `\seihou@new`(L835) `\seihou@new@no`(L880) `\kuroseihou@new`(L926) `\kuroseihou@new@no`(L972)
  `\seimaru@new`(L1020) `\seimaru@new@no`(L1066) `\kuroseimaru@new`(L1113) `\kuroseimaru@new@no`(L1160)
- hishi 系: `\hishi@new`(L1209) `\hishi@new@no`(L1250) `\maruhishi@new`(L1297) `\maruhishi@new@no`(L1339)
  `\kurohishi@new`(L1387) `\kurohishi@new@no`(L1430) `\kuromaruhishi@new`(L1479) `\kuromaruhishi@new@no`(L1523)
- kakko 系: `\kakko@byouga@internal`(L1595) `\kakko@byouga@internal@no`(L1620)
  `\kakko@byouga@internal@tate`(L1650) `\kakko@byouga@internal@tate@no`(L1685)
- ichimoji: `\ichimoji@new`(L1744) `\ichimoji@new@no`(L1773)

> 行番号は v2.1.4 時点。編集後はズレるので grep で再特定すること。
> まず `\maru`(maru系) 1系統だけ改修してコンパイル確認 → 問題なければ横展開、が安全。

---

## 6. テスト計画

新規 `test-kksref.tex` を作る（KKran 非依存でも動くよう、ローマ数字は KKran があれば `\Rrnum`、無ければ
リテラル `ⅰⅱ…` か `\textit{i,ii,iii,iv,v,vi,vii,viii}` でフォールバック）。確認項目:
1. **問題1再現**: `\kksref` 無し vs `\vphantom{\Rrnum{6}}` 手書き vs `\kksref{\Rrnum{6}}` の3列を `\fbox` 付きで並べ、
   `\kksref` 版が手書き版と一致することを目視。
2. **後方互換**: `\kksref` を使わない既存 `test.tex` の出力が **完全に不変**であること（pdf 比較 or 目視）。
3. **問題2**: 複数フォント（明朝/ゴシック/丸ゴシック）で `\maru{8}` 等の中央寄せを比較。
4. 縦書き（`\RotTate`）でも破綻しないこと。

コンパイル: `latexmk -r .latexmkrc test-kksref.tex`（または `make` に倣う）。`-halt-on-error`。

---

## 7. 未解決・要確認事項

- API は `\kksref`（スコープ設定）を主とするか、オプション引数も併設するか。
- 問題2の既定中央寄せ変更の具体案（数字メトリクス基準 / cap-height 基準）と、既存ドキュメントの見た目への影響。
- `\jegg`（スター無しでも小文字対応、スターで黒背景になる特殊例）への適用可否。
- バージョン番号・日付の更新は **ユーザー確認後**。

---

## 8. 検証時の注意

- LuaLaTeX 専用（`\ltjghostbeforejachar` 等を使うため）。
- `test.tex` は Hiragino 前提。フォントが無い環境では `test-kksref.tex` のフォント指定を差し替える。
- 根本原因の診断はソース読解ベース。**必ず PDF を目視**して仮説を検証してから本実装を広げること。
