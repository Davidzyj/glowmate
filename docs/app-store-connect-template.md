# App Store Connect Template - GlowMate

## App Record

- App name: GlowMate
- Chinese display name: 柔光伴侣
- Japanese display name: グロウメイト
- Bundle ID: `com.zhouyajie.glowmate`
- SKU suggestion: `glowmate-ios-100`
- Version: `1.0.0`
- Primary language: English
- Category: Photo & Video
- Secondary category: Utilities
- Support email: `jay212315@gmail.com`
- Support URL: `https://davidzyj.github.io/glowmate/en/support.html`
- Privacy Policy URL: `https://davidzyj.github.io/glowmate/en/privacy.html`
- Chinese Support URL: `https://davidzyj.github.io/glowmate/zh-Hans/support.html`
- Chinese Privacy Policy URL: `https://davidzyj.github.io/glowmate/zh-Hans/privacy.html`
- Japanese Support URL: `https://davidzyj.github.io/glowmate/ja/support.html`
- Japanese Privacy Policy URL: `https://davidzyj.github.io/glowmate/ja/privacy.html`

## English Listing

- Name: GlowMate
- Subtitle: Offline soft light meter
- Promotional text: Measure lighting locally, apply screen fill light, and save practical presets for selfies, food, products, meetings, and night rooms.
- Description:
GlowMate is a local-only iPhone tool for better lighting before you take a photo or start a video.

Use the camera preview to estimate brightness on your device, then apply a practical screen fill-light setup. Adjust brightness and tone, open a full-screen soft light, take and save a photo, use scene presets, and restore recent local records.

Key features:
- Offline lighting meter
- Take a photo and save it to your photo library
- Screen soft light with warm, natural, cool, and blush tones
- Scene presets for selfies, food, products, meetings, and night rooms
- Rear torch control on supported devices
- Local lighting records
- English, Simplified Chinese, and Japanese interface

GlowMate does not require an account, backend, analytics, ads, or tracking. Camera frames are processed locally and are not uploaded.
- Keywords: lighting,selfie,soft light,fill light,camera,photo,video,torch,offline

## Simplified Chinese Listing

- Name: 柔光伴侣
- Subtitle: 离线拍照补光工具
- Promotional text: 本地测光、推荐补光参数、开启屏幕柔光，适合自拍、食物、商品、会议和夜晚房间。
- Description:
柔光伴侣是一款 iPhone 本地补光工具，帮助你在拍照或录视频之前把光调得更自然。

App 会使用相机预览在设备本地估算亮度，并推荐实用的屏幕补光参数。你可以调节亮度和色调，开启全屏柔光，拍照并保存到相册，选择场景预设，并恢复最近使用过的本地记录。

核心功能：
- 离线测光
- 拍照并保存到系统相册
- 屏幕柔光，支持暖肤光、自然白、冷白光和蜜桃光
- 自拍、食物、商品、视频会议、夜晚房间场景预设
- 支持设备上的后置手电筒控制
- 本地补光记录
- 支持简体中文、英文和日语

柔光伴侣不需要账号，不接后端，不包含分析、广告或追踪。相机画面只在本机处理，不会上传。
- Keywords: 补光,自拍,柔光,测光,拍照,视频,手电筒,离线,相机

## Japanese Listing

- Name: グロウメイト
- Subtitle: オフライン補助光メーター
- Promotional text: 端末内で測光し、画面ソフトライトを適用。セルフィー、料理、商品、会議、夜の部屋に使えます。
- Description:
GlowMateは、写真や動画を撮る前に光を整えるためのiPhone向けローカルツールです。

カメラプレビューを使って端末内で明るさを推定し、実用的な画面補助光の設定を提案します。明るさと色を調整し、全画面ソフトライトを開き、写真を撮影して保存し、シーンプリセットや最近のローカル履歴を利用できます。

主な機能：
- オフライン測光
- 写真を撮影して写真ライブラリに保存
- ウォーム肌、ナチュラル白、クール白、ブラッシュの画面ソフトライト
- セルフィー、料理、商品、ビデオ会議、夜の部屋のプリセット
- 対応端末での背面ライト制御
- ローカル履歴
- 英語、簡体字中国語、日本語に対応

GlowMateはアカウント、バックエンド、分析、広告、トラッキングを使用しません。カメラフレームは端末内で処理され、アップロードされません。
- Keywords: ライト,セルフィー,補助光,測光,写真,動画,カメラ,オフライン

## App Privacy

- Data collected: None.
- Tracking: No.
- Account required: No.
- Analytics: No.
- Ads: No.
- Third-party SDKs: No.
- Camera: Used only for local preview-based lighting estimation. Frames are not uploaded or stored.
- Photos add-only access: Used only when the user taps Take & Save Photo. Captured photos are saved to the system Photos library and are not uploaded or stored by the app.
- Local storage: Language choice, light configuration, and recent lighting records are stored on device.

## Review Information

- Demo account: Not required.
- Notes:
GlowMate is a local-only iPhone app. It uses camera preview frames only on device to estimate lighting and recommend screen fill-light settings. When the user taps Take & Save Photo, the app requests add-only Photos permission and saves the captured photo to the system library. It does not create accounts, contact a backend, include analytics/ads/tracking SDKs, or upload photos/video. The Privacy Policy and Support links are opened only after the user taps them.

## Compliance And Age Rating

- Encryption: App declares `ITSAppUsesNonExemptEncryption` as `false`.
- User-generated public content: No.
- Social features: No.
- Purchases/subscriptions: No.
- Location: No.
- Health/medical: No.
- Gambling/contests: No.
- Unrestricted web access: No general browser; only support/privacy links.
- Suggested age rating: 4+.

## Screenshot Assets

- Real simulator screenshot script: `scripts/capture-screenshots.sh`
- Output directory: `screenshots/iphone-6.5/en/`
- Screenshot mode: Debug-only launch arguments `--glowmate-screenshots --glowmate-screen <tab>`.

## Manual Owner Steps

- Confirm Apple Developer team and signing in Xcode.
- Create or select the App Store Connect app record.
- Upload archive from Xcode Organizer or Transporter.
- Enable GitHub Pages for the created repository if the workflow has not already deployed.
- Confirm final support/privacy URLs after Pages deployment.
- Fill contact phone/name in App Review information.
- Choose final pricing and release timing.
