# mackerel-alert-pi

## 概要

Infinite Loopの[Cristal-Signal-Pi](http://crystal-signal.com)で[mackerel.io](https://mackerel.io)のアラートを定期監視するスクリプトです。
mackerelのRead権限のapikeyがあれば、運用開始できます。

## 動作仕様

1分間隔でmackerelのアラートを監視し、アラートが発生していたら、Crystal-Signal-Piの近くにいる人へお知らせします。

### 色

* 緑点灯：正常
* 緑点滅：正常、音声通知オフ
* 紫点滅：Unknown発生中
* 黄点滅：Warning発生中
* 赤点滅：Critical発生中
* 青点滅：mackerelアクセス不可
* 橙点滅：ネットワーク接続不可
* 無点灯：電源オフ・初回ポーリング開始待ち
* 優先順位は、無<-橙<-青<-赤<-黄<-紫<-緑

### 点滅間隔

* ベース間隔 3秒
* アラート数でベース間隔を割り算した周期
* 上限値 30アラートで最小間隔0.1秒

### 音声

* mackerelのアラート発生中は、音声で継続的にお知らせ
* 正常時：無音
* アラート

### 監視周期

* 1分間隔

### ボタン

* 通常押し：音声通知オフ
* 長押し：音声通知オン

## 動作前提条件

mackerel-alert-piの動作前提条件は、以下です。

* ハードウェア
  * RaspberryPi
  * microSDカード
  * スイッチ付き電源用microUSBケーブル
  * 小型スピーカー
  * Crystal-Signal-Pi
* OS
  * Raspbian
* ネットワーク設定
  * インストールファイルのダウンロードとmackerelへのアラート定期取得用のため、インターネットへ接続可能であること
* ミドルウェアインストール
  * Crystal-Signal-Piの[インストールマニュアル(http://crystal-signal.com/other/Crystal_Signal_Pi_software.pdf)]のinstall.sh

## インストール

```
$ ./install.sh 
Usage: ./install.sh <mackerel-api-key> <team-name>
```

* <mackerel-api-key>：mackerelの管理画面で発行したRead権限のapikey 
* <team-name>：チーム名　音声のお知らせ時に使用
* crontabにrun.shのスケジュールを追加
* /var/lib/crystal-signal/scriptsにVoiceOff.sh、VoiceOn.shを追加
* /var/lib/crystal-signal/ScriptsSettings.jsonとSettings.jsonを上書き
* logsディレクトリ作成

## 動作確認

* run.shを実行すると、標準出力に実行結果が表示されるので、ログ確認ください。
