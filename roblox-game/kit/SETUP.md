# 組み立て手順（SETUP）

Roblox Studioで、このキットを動くゲームにする手順です。
上から順番に進めれば、「友達と入って対戦できる」ところまで行けます。

## このキットで遊べるようになること

- ロビーで集まる → 2人以上そろったら土俵へ移動 → カウントダウンで試合開始
- 「おす」攻撃（Fキー、スマホは画面ボタン）で相手を押し出す
- 土俵から落ちたら負け。最後まで残った人が勝ち
- 能力は3種類（ダッシュ＝逃げる／パワー＝押し出す／アンカー＝耐える）。ロビーの台に乗って選ぶ
- 試合ごとにコインがもらえる（参加10・優勝50）。コインは保存される
- 無料コードの入力欄つき（最初のコードは RELEASE と START）

## 手順1：場所（マップ）を作る

Studioで「新規」→「ベースプレート」を開いた状態から始めます。

1. **ロビーのスポーン**：挿入メニューから「SpawnLocation」を置く → 名前を **LobbySpawn** に変える
2. **土俵**：「Part」を置く → 形を「Cylinder（円柱）」にして、平たく大きくする（目安：直径40、高さ2）→ 名前を **Ring** に変える → プロパティで **Anchored（固定）** にチェック
3. **土俵の上の出現場所**：「Part」を4つ置く → 名前を **ArenaSpawn1〜ArenaSpawn4** にする → 土俵の上に並べる → 4つとも **Anchored** にチェック、**CanCollide（衝突）** のチェックを外し、**Transparency（透明度）** を 0.5 にする
4. **能力の台**：「Part」を3つ、ロビーの近くに置く → 名前を **Pad_Dash**（青）、**Pad_Power**（赤）、**Pad_Anchor**（緑）にする → 3つとも **Anchored** にチェック。台の上に文字の看板を置くと分かりやすいです（ダッシュ／パワー／アンカー）

※ 名前は1文字でも違うと動きません。コピーして貼るのが確実です。

## 手順2：スクリプトを貼る

`scripts` フォルダの中身を、Studioのエクスプローラーで次の場所に作って貼ります。
貼るときは、ファイルの中身を全部コピーして、Studio側の中身と置き換えてください。

| ファイル | Studioで作るもの | 置く場所 |
|---|---|---|
| GameData.lua | ModuleScript（名前：GameData） | ServerScriptService |
| PlayerData.lua | Script（名前：PlayerData） | ServerScriptService |
| RoundManager.lua | Script（名前：RoundManager） | ServerScriptService |
| ShoveServer.lua | Script（名前：ShoveServer） | ServerScriptService |
| AbilityPads.lua | Script（名前：AbilityPads） | ServerScriptService |
| ClientControls.lua | LocalScript（名前：ClientControls） | StarterPlayerScripts |

## 手順3：コイン保存を有効にする（大事）

Studioのままではコインが保存されません。次の設定を1回だけします。

1. 「ゲーム設定（Game Settings）」を開く
2. 「セキュリティ（Security）」を開く
3. 「StudioでAPIサービスへのアクセスを有効化（Enable Studio Access to API Services）」をオンにする

公開したゲームでは、保存は自動で働きます。

## 手順4：テストする

1. 上の「プレイ」ボタンで、自分1人で歩き回れるか確認する（1人では試合は始まらず、ロビーの案内表示に「あと1人で開始」と出ます）
2. **2人テスト**：「テスト（Test）」タブ → ローカルサーバーでプレイヤー数を2にして開始。2人そろうと土俵へ移動して試合が始まります
3. 確認すること：
   - Fキー（スマホでは「おす」ボタン）で相手が吹き飛ぶか
   - 土俵から落ちるとロビーに戻り、「○○が落ちた！」と表示されるか
   - 最後の1人になると「勝ちは○○！」と出て、コインが増えるか
   - ロビーの台に乗って能力を変え、Qキー（スマホでは「能力」ボタン）で使えるか
   - 左下の入力欄に RELEASE と入れてコインがもらえるか

## 手順5：公開とサムネイル

1. 「ファイル」→「Robloxに公開（Publish to Roblox）」で名前と説明を付けて公開する（最初は自分と友達だけ入れる設定で十分です）
2. ゲームのページ（Creator Dashboard）の「サムネイル」に、モコが作った画像（game-thumbnail.png）を登録する
   - 専用サムネイルがないゲームは、ホームのおすすめに出してもらえません。必ず登録してください

## 調整できる数字

- 試合の人数・制限時間・コインの量：RoundManager の上の CONFIG
- 押す力・届く距離・間隔：ShoveServer の上の数字
- 無料コードと金額：GameData の CODES（公開前に好きな言葉へ変更を）

## うまくいかないとき

- **試合が始まらない**：ArenaSpawn1〜4 と Ring、LobbySpawn の名前を確認（スペル違いが一番多い原因です）
- **コインが保存されない**：手順3の設定を確認
- **エラーが出た**：「表示（View）」→「出力（Output）」の赤い文字を、このスレッドに貼ってください。一緒に直します
