# PickWizard — 데이터 안전 (웹 게시본)

스토어·앱 표기(참고)

| 언어 코드 | 앱 표기 제목 |
|-----------|----------------|
| ko | 픽위자드 - 복권 번호 추천 |
| en | PickWizard: Lottery Picks |
| zh | PickWizard：彩票选号助手 |
| ja | PickWizard：宝くじ番号ナビ |
| th | PickWizard: ตัวช่วยเลือกเลขหวย |
| vi | PickWizard: Trợ lý chọn số xổ số |

아래부터 **웹사이트에 붙여 넣을 수 있는 본문**입니다. 언어별로 페이지를 나누거나, 한 페이지에서 앵커·탭으로 구분해 게시하면 됩니다.

---

## 한국어

### 데이터 안전 안내

**PickWizard(픽위자드 - 복권 번호 추천)** 는 사용자를 이해하기 쉽게, **기기 밖으로 전송되거나 다른 회사와 공유될 수 있는 정보**를 중심으로 설명합니다.

**적용 범위:** 현재 배포되는 앱은 소셜 로그인을 사용하지 않습니다. 앱 기능이 바뀌면 이 고지를 함께 갱신합니다.

#### 앱 운영 측에서 다루는 정보

- **이름, 이메일, 전화번호**처럼 본인을 바로 알 수 있는 정보는 수집하지 않습니다.
- **게스트 로그인과 서비스 연동**을 위해, 서버와 주고받는 **가명의 사용자 식별자**가 있을 수 있습니다.
- 게스트 계정과 기기를 연결하기 위해, 운영체제가 제공하는 **기기 식별 값**(예: Android의 기기 식별자, iOS의 Vendor 식별자 등)이 **운영 서버로 전송**될 수 있습니다.

#### 광고 (테스트: Google AdMob / 정식 출시: AppLovin)

- **테스트 광고(AdMob):** 앱에는 **Google Mobile Ads(AdMob)** 가 포함될 수 있으나, **실제 수익화가 아닌 테스트 광고**를 보여 주거나 개발·검증 목적으로만 사용합니다. 해당 구간에서 **광고 ID**, 기기·앱 관련 정보, 광고 표시·측정·부정 이용 방지에 필요한 정보가 **Google LLC 및 협력사**로 전송·처리될 수 있습니다. Google 정책과 기기 설정에 따라 **대략적인 위치**, **앱 안 광고 관련 활동**, **진단·성능** 정보가 포함될 수 있습니다. [Google 개인정보처리방침](https://policies.google.com/privacy) 및 광고 관련 안내를 참고해 주세요.

- **정식 출시(스토어 프로덕션):** **AppLovin(앱러빙)** 을 통한 광고로 전환할 계획입니다. AppLovin SDK가 동작하는 빌드에서는 광고 게재·측정·분석 등을 위해 **기기·앱 식별자, 광고 관련 상호작용** 등이 **AppLovin 및 연결된 광고 네트워크**로 전송·처리될 수 있습니다. [AppLovin 개인정보 처리방침](https://www.applovin.com/privacy/)을 참고해 주세요.

#### 기기 안에만 남는 정보

앱 설정, 생성해 두신 번호 조합 등은 **원칙적으로 사용자 기기에만 저장**됩니다. 위에서 말한 것처럼 서버나 광고 회사로 보내지 않는 한, 이 안내의 「전송·공유」 대상에 넣지 않습니다.

#### 데이터 판매

사용자 데이터를 **판매하지 않습니다**.

#### 보안

인터넷으로 주고받는 구간에서는 **전송 중 암호화**(예: TLS)를 사용합니다.

#### 문의·삭제

앱을 삭제하시거나 **Chartrho@gmail.com** 으로 연락 주시면, 삭제나 문의를 요청하실 수 있습니다. 처리 절차는 관련 법령과 내부 방침에 따릅니다.

#### 이용약관·개인정보 안내 화면

이 버전에서는 이용약관과 개인정보 관련 안내를 **앱 안의 텍스트**로 주로 보여 드립니다. 나중에 앱 안에서 웹 페이지를 띄우는 방식이 바뀌면, 그에 맞게 이 고지도 업데이트할 수 있습니다.

---

## English

### Data safety notice

**PickWizard: Lottery Picks** explains, in plain language, information that **may leave your device** or **be shared with other companies**.

**Scope:** The version of the app described here does **not** include social sign-in. We will update this notice if the app changes.

#### Information we handle as the app operator

- We do **not** collect direct identifiers such as your **name, email address, or phone number**.
- For **guest sign-in and service features**, a **pseudonymous user identifier** may be exchanged with our servers.
- To link guest accounts with your device, **device identifiers provided by the platform** (e.g., Android device identifiers, iOS Identifier for Vendor, as applicable) may be **sent to our servers**.

#### Advertising (test: Google AdMob / production: AppLovin)

- **Test ads (AdMob):** The app may include **Google Mobile Ads (AdMob)**, but we use it for **test ads and development/QA only**, not for production monetization. When those ads run, information such as your **advertising ID**, device- and app-related data, and data used to **serve, measure, and protect** ads may be sent to **Google LLC and its partners**. Depending on Google’s policies and your device settings, this may include **approximate location**, **in-app ad-related activity**, and **diagnostics or performance-related** data. See [Google’s Privacy Policy](https://policies.google.com/privacy) and Google’s advertising-related disclosures.

- **Production (store release):** We plan to use **AppLovin** for ads in **official production builds** distributed on app stores. When the AppLovin SDK is active, information such as **device/app identifiers and ad-related interactions** may be sent to **AppLovin and its advertising partners** for delivery, measurement, analytics, and related purposes. See [AppLovin’s Privacy Policy](https://www.applovin.com/privacy/).

#### Information that stays on your device

App settings and number sets you create are generally **stored only on your device**. Unless that data is sent off the device as described above, it is **not** treated here as transmitted or shared.

#### Sale of data

We **do not sell** user data.

#### Security

We use **encryption in transit** (e.g., TLS) for network communications where applicable.

#### Contact and deletion

You may request deletion or contact us by **uninstalling the app** and/or emailing **Chartrho@gmail.com**. We handle requests in line with applicable law and our internal policies.

#### Terms and privacy screens

In this version, terms and privacy-related information are shown mainly as **in-app text**. If we later embed web content that collects data, we will update this notice accordingly.

---

## 日本語

### データの安全性について

**PickWizard：宝くじ番号ナビ** は、**端末の外に送信されたり、他社と共有されたりしうる情報**を、わかりやすく説明します。

**対象バージョン:** 本リリースではソーシャルログインは利用できません。アプリの内容が変わる場合は、本ページも更新します。

#### アプリ運営側が取り扱う情報

- **氏名、メールアドレス、電話番号**など、本人を直接特定する情報は収集しません。
- **ゲストログインやサービス連携**のため、運営サーバーと**仮名のユーザー識別子**を送受信する場合があります。
- ゲストアカウントと端末を紐付けるため、プラットフォームが提供する**端末識別子**（例：Android の端末識別子、iOS の Identifier for Vendor など）が**運営サーバーに送信**される場合があります。

#### 広告（テスト：Google AdMob／本番：AppLovin）

- **テスト広告（AdMob）：** **Google Mobile Ads（AdMob）** が含まれる場合がありますが、**本番の収益化ではなくテスト広告**および開発・検証目的でのみ使用します。その際、**広告 ID**、端末・アプリ関連情報、広告の配信・測定・不正対策に必要な情報が **Google LLC およびパートナー**に送信・処理される場合があります。Google のポリシーや設定により、**おおよその位置情報**、**アプリ内の広告関連の活動**、**診断・パフォーマンス**情報が含まれる場合があります。[Google のプライバシー ポリシー](https://policies.google.com/privacy) 等をご参照ください。

- **ストア本番リリース：** **AppLovin** による広告へ移行する予定です。AppLovin SDK が動作するビルドでは、広告配信・測定・分析等のため、**端末・アプリ識別子や広告関連のやり取り**などが **AppLovin および接続された広告ネットワーク**に送信・処理される場合があります。[AppLovin のプライバシーポリシー](https://www.applovin.com/privacy/) をご参照ください。

#### 端末内にのみ保存される情報

アプリの設定や生成した番号の組み合わせは、**原則としてユーザーの端末内にのみ**保存されます。上記のようにサーバーや広告事業者へ送信されない限り、本ページの「送信・共有」の対象には含めません。

#### データの販売

ユーザーデータを**販売しません**。

#### セキュリティ

ネットワーク通信では、**転送中の暗号化**（TLS 等）を用います。

#### お問い合わせ・削除

アプリをアンインストールするか、**Chartrho@gmail.com** までご連絡いただくことで、削除やお問い合わせを行えます。対応は適用法令および社内方針に従います。

#### 利用規約・プライバシーに関する表示

本バージョンでは、利用規約やプライバシーに関する説明を**アプリ内のテキスト**で主に表示します。今後、アプリ内で Web コンテンツを埋め込む方式が変わる場合は、本ページもそれに合わせて更新する場合があります。

---

## 简体中文

### 数据安全说明

**PickWizard：彩票选号助手** 以下列方式说明**可能离开您设备或与第三方共享**的信息。

**适用范围：** 当前发布的应用版本**不包含**社交账号登录。如应用功能发生变化，我们将更新本说明。

#### 由应用运营方处理的信息

- 我们不收集**姓名、电子邮箱、电话号码**等可直接识别您身份的信息。
- 为实现**游客登录与服务功能**，可能与我们的服务器交换**假名（匿名化）用户标识符**。
- 为将游客账户与设备关联，操作系统提供的**设备标识**（例如 Android 设备标识、iOS 的 Identifier for Vendor 等）**可能被发送至我们的服务器**。

#### 广告（测试：Google AdMob / 正式版：AppLovin）

- **测试广告（AdMob）：** 应用可能包含 **Google Mobile Ads（AdMob）**，但仅用于**测试广告**及开发、验证目的，**不用于正式版的商业变现**。在此情形下，**广告 ID**、设备及应用相关信息，以及用于**展示、衡量与保护广告**的数据可能被发送至 **Google LLC 及其合作伙伴**并被处理。视 Google 政策及设备设置而定，还可能包括**大致位置**、**应用内广告相关活动**、**诊断与性能**信息。详见 [Google 隐私权政策](https://policies.google.com/privacy)及 Google 广告相关披露。

- **应用商店正式版：** 计划在**正式上架的生产版本**中通过 **AppLovin** 投放广告。当 AppLovin SDK 运行时，为广告投递、衡量与分析等目的，**设备/应用标识符及广告相关互动**等信息可能被发送至 **AppLovin 及其广告合作伙伴**并被处理。详见 [AppLovin 隐私政策](https://www.applovin.com/privacy/)。

#### 仅保存在设备上的信息

应用设置、您生成的号码组合等，**原则上仅保存在您的设备上**。除非按上文所述被传输出设备，否则不视为本说明中的「传输或共享」对象。

#### 出售数据

我们**不出售**用户数据。

#### 安全

在适用情况下，网络通信采用**传输加密**（如 TLS）。

#### 联系与删除

您可通过**卸载应用**和/或发送邮件至 **Chartrho@gmail.com** 提出删除或咨询请求。我们将依据适用法律及内部政策处理。

#### 条款与隐私展示方式

本版本主要通过**应用内文本**展示用户条款与隐私相关说明。若日后在应用内嵌入会收集数据的网页内容，我们将相应更新本说明。

---

## Tiếng Việt

### Thông báo về an toàn dữ liệu

**PickWizard: Trợ lý chọn số xổ số** giải thích bằng ngôn ngữ dễ hiểu về thông tin **có thể rời khỏi thiết bị của bạn** hoặc **được chia sẻ với bên thứ ba**.

**Phạm vi:** Phiên bản ứng dụng được mô tả tại đây **không** có đăng nhập mạng xã hội. Chúng tôi sẽ cập nhật thông báo này nếu ứng dụng thay đổi.

#### Thông tin do nhà phát hành ứng dụng xử lý

- Chúng tôi **không** thu thập thông tin định danh trực tiếp như **họ tên, email hoặc số điện thoại**.
- Đối với **đăng nhập khách và tính năng dịch vụ**, mã **định danh người dùng giả danh (pseudonymous)** có thể được trao đổi với máy chủ của chúng tôi.
- Để liên kết tài khoản khách với thiết bị, **mã định danh thiết bị do nền tảng cung cấp** (ví dụ mã định danh trên Android, Identifier for Vendor trên iOS, tùy nền tảng) **có thể được gửi tới máy chủ** của chúng tôi.

#### Quảng cáo (thử nghiệm: Google AdMob / phát hành chính thức: AppLovin)

- **Quảng cáo thử nghiệm (AdMob):** Ứng dụng có thể tích hợp **Google Mobile Ads (AdMob)** nhưng chỉ dùng cho **quảng cáo thử nghiệm** và mục đích phát triển/kiểm thử, **không** dùng để kiếm tiền trên bản sản xuất. Khi các quảng cáo đó chạy, thông tin như **Advertising ID**, dữ liệu thiết bị/ứng dụng và dữ liệu phục vụ **hiển thị, đo lường và bảo vệ** quảng cáo có thể được gửi tới **Google LLC và đối tác**. Tùy chính sách Google và cài đặt thiết bị, có thể gồm **vị trí gần đúng**, **hoạt động liên quan quảng cáo trong app**, dữ liệu **chẩn đoán/hiệu năng**. Xem [Chính sách quyền riêng tư của Google](https://policies.google.com/privacy) và tài liệu quảng cáo của Google.

- **Bản phát hành chính thức (cửa hàng ứng dụng):** Chúng tôi dự kiến dùng **AppLovin** cho quảng cáo trên **bản production** phân phối qua cửa hàng. Khi SDK AppLovin hoạt động, thông tin như **mã định danh thiết bị/ứng dụng và tương tác liên quan quảng cáo** có thể được gửi tới **AppLovin và đối tác quảng cáo** nhằm phân phối, đo lường, phân tích và mục đích liên quan. Xem [Chính sách quyền riêng tư của AppLovin](https://www.applovin.com/privacy/).

#### Thông tin chỉ lưu trên thiết bị

Cài đặt ứng dụng và bộ số bạn tạo thường **chỉ được lưu trên thiết bị**. Trừ khi được gửi ra ngoài thiết bị như mô tả ở trên, chúng **không** được coi là đã truyền hoặc chia sẻ trong thông báo này.

#### Bán dữ liệu

Chúng tôi **không bán** dữ liệu người dùng.

#### Bảo mật

Chúng tôi dùng **mã hóa khi truyền** (ví dụ TLS) cho giao tiếp mạng khi áp dụng được.

#### Liên hệ và xóa

Bạn có thể yêu cầu xóa hoặc liên hệ bằng cách **gỡ cài đặt ứng dụng** và/hoặc gửi email tới **Chartrho@gmail.com**. Chúng tôi xử lý theo luật hiện hành và chính sách nội bộ.

#### Cách hiển thị điều khoản và quyền riêng tư

Phiên bản này chủ yếu hiển thị điều khoản và thông tin liên quan quyền riêng tư bằng **văn bản trong ứng dụng**. Nếu sau này nhúng nội dung web thu thập dữ liệu, chúng tôi sẽ cập nhật thông báo này cho phù hợp.

---

## ภาษาไทย

### แจ้งเกี่ยวกับความปลอดภัยของข้อมูล

**PickWizard: ตัวช่วยเลือกเลขหวย** อธิบายด้วยภาษาที่เข้าใจง่ายว่าข้อมูลใดบ้างที่**อาจถูกส่งออกจากอุปกรณ์ของคุณ**หรือ**แชร์กับบริษัทอื่น**

**ขอบเขต:** เวอร์ชันแอปที่อธิบายที่นี่**ไม่มี**การล็อกอินด้วยโซเชียล หากแอปมีการเปลี่ยนแปลง เราจะอัปเดตข้อความนี้

#### ข้อมูลที่ผู้ให้บริการแอปจัดการ

- เรา**ไม่เก็บ**ข้อมูลระบุตัวตนโดยตรง เช่น **ชื่อ อีเมล หรือเบอร์โทรศัพท์**
- สำหรับ**ล็อกอินแบบแขกและฟีเจอร์บริการ** ตัว**ระบุผู้ใช้แบบไม่ระบุชื่อ (pseudonymous)** อาจถูกแลกเปลี่ยนกับเซิร์ฟเวอร์ของเรา
- เพื่อเชื่อมบัญชีแขกกับอุปกรณ์ **ตัวระบุอุปกรณ์ที่ระบบปฏิบัติการให้** (เช่น ตัวระบุอุปกรณ์บน Android, Identifier for Vendor บน iOS ตามแพลตฟอร์ม) **อาจถูกส่งไปยังเซิร์ฟเวอร์**ของเรา

#### โฆษณา (ทดสอบ: Google AdMob / เวอร์ชันเผยแพร่จริง: AppLovin)

- **โฆษณาทดสอบ (AdMob):** แอปอาจมี **Google Mobile Ads (AdMob)** แต่ใช้เพื่อ**โฆษณาทดสอบ**และการพัฒนา/ตรวจสอบเท่านั้น **ไม่**ใช้เพื่อสร้างรายได้บนเวอร์ชันโปรดักชันจริง เมื่อโฆษณาเหล่านั้นทำงาน ข้อมูลเช่น **Advertising ID** ข้อมูลอุปกรณ์/แอป และข้อมูลสำหรับ**แสดง วัดผล และป้องกันการละเมิด**โฆษณา อาจถูกส่งและประมวลผลโดย **Google LLC และพันธมิตร** ขึ้นกับนโยบาย Google และการตั้งค่าอุปกรณ์ อาจรวม**ตำแหน่งโดยประมาณ** **กิจกรรมที่เกี่ยวกับโฆษณาในแอป** และข้อมูล**การวินิจฉัยหรือประสิทธิภาพ** ดู [นโยบายความเป็นส่วนตัวของ Google](https://policies.google.com/privacy) และเอกสารโฆษณาของ Google

- **เผยแพร่จริงบนร้านค้า:** เราวางแผนใช้ **AppLovin** สำหรับโฆษณาใน**บิลด์โปรดักชันที่เผยแพร่บนร้านแอป** เมื่อ SDK ของ AppLovin ทำงาน ข้อมูลเช่น**ตัวระบุอุปกรณ์/แอปและการมีปฏิสัมพันธ์ที่เกี่ยวกับโฆษณา** อาจถูกส่งไปยัง **AppLovin และพันธมิตรโฆษณา** เพื่อการแสดง วัดผล วิเคราะห์ และวัตถุประสงค์ที่เกี่ยวข้อง ดู [นโยบายความเป็นส่วนตัวของ AppLovin](https://www.applovin.com/privacy/)

#### ข้อมูลที่เก็บเฉพาะในอุปกรณ์

การตั้งค่าแอปและชุดตัวเลขที่คุณสร้าง โดยทั่วไป**เก็บไว้ในอุปกรณ์ของคุณเท่านั้น** หากไม่ได้ส่งออกนอกอุปกรณ์ตามที่อธิบายข้างต้น จะ**ไม่**ถือว่าเป็นข้อมูลที่ส่งหรือแชร์ในคำชี้แจงนี้

#### การขายข้อมูล

เรา**ไม่ขาย**ข้อมูลผู้ใช้

#### ความปลอดภัย

เราใช้**การเข้ารหัสระหว่างส่ง** (เช่น TLS) สำหรับการสื่อสารทางเครือข่ายเมื่อใช้งานได้

#### การติดต่อและการลบ

คุณสามารถขอลบหรือติดต่อได้โดย**ถอนการติดตั้งแอป** และ/หรือส่งอีเมลไปที่ **Chartrho@gmail.com** เราดำเนินการตามกฎหมายที่ใช้บังคับและนโยบายภายใน

#### วิธีแสดงข้อกำหนดและความเป็นส่วนตัว

ในเวอร์ชันนี้ ข้อกำหนดและข้อมูลที่เกี่ยวกับความเป็นส่วนตัวแสดงเป็นหลักในรูปแบบ**ข้อความในแอป** หากภายหลังมีการฝังเว็บที่เก็บข้อมูล เราจะอัปเดตคำชี้แจงนี้ให้สอดคล้องกัน

---

## 내부 참고 (Play Console·운영 전용)

웹에 **게시하지 마세요.** 심사·설문 대응용입니다.

### 용어 정리(본 앱)

| 용어 | 적용 |
|------|------|
| 수집 | 기기 밖(운영 서버·제3자)으로 전송되어 처리되는 항목. 앱이 직접 보내지 않아도 SDK가 전송하면 신고 대상. |
| 공유 | 테스트 빌드: Google AdMob 가이드에 맞게 체크. 프로덕션: AppLovin·연동 네트워크 가이드에 맞게 체크. |
| 기기 내 전용 | Hive·SharedPreferences 등 전송 없이 기기에만 남는 데이터는 본 웹 고지 본문에서 「전송·공유」 대상에서 제외한 서술과 동일. |

**코드·배포 계획:** 소셜 로그인 비활성, 게스트/API 사용. 광고는 **AdMob으로 테스트 광고만** 사용하고, **스토어 정식(프로덕션) 빌드는 AppLovin(앱러빙) 전환 예정**. 별도 Firebase Crashlytics 등 1자 크래시 SDK 없음.

### Play Console 설문 체크 시

1. 운영 서버: `User IDs`, `Device or other IDs` 등 **수집**, 목적은 앱 기능(계정·API).
2. **AdMob(테스트·내부 빌드):** Google 문서에 따라 `Device or other IDs`, `Approximate location`(해당 시), `App activity`/진단 등 검토 후 **수집·공유·목적** 체크(해당 빌드에 SDK가 포함된 경우).
3. **AppLovin(프로덕션 예정):** AppLovin 및 [MAX / 연동 네트워크](https://www.applovin.com/privacy/) 데이터 공개 가이드에 맞춰 **수집·공유·목적** 체크. 프로덕션에서 AdMob을 제거·비활성화하면 해당 항목은 실제 빌드에 맞게 조정.
4. 데이터 판매: 정책에 맞게 **아니오**.
5. 앱·SDK 변경 시 설문과 **웹 게시본(위 본문)** 동시 갱신.
