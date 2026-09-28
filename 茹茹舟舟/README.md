# 茹茹舟舟 · 情侣约会记录 App

一款只属于你们俩的私密约会记事本。全部数据 100% 存储在手机本地，**不联网、不上传、无广告、无内购**，主打"记得快 + 留得住回忆"。

- 平台：iPhone · iOS 16.0+
- 技术：原生 SwiftUI（轻量、离线、单手竖屏操作）
- 风格：米白 + 奶杏/浅粉 + 深灰（不超过 3 个主色），大圆角、圆润、留白、轻微动效

---

## 一、已实现功能（对应最终确认的需求）

**核心**
1. 打卡登记：日期时间（默认现在）、1 张封面照片（相册选择，本地存储）、**1–10 分数字滑块**（滑动时弹出表情 😡→😐→😍，丝滑动画 + 触觉反馈）、地点（一键定位 + 手动输入）、文字备注
2. 记录浏览：首页按时间倒序卡片（日期/地点/评分/照片缩略图）→ 详情页（大图 + 完整备注）→ 编辑 / 删除（删除有确认）
3. 统计：总约会次数、历史平均分（1–10）、本月约会次数

**扩展**
4. 标签：预设 5 个 + **自定义**（可增删），支持按标签筛选
5. 日历页：标记有约会的日期，点日期看当天记录
6. 数据备份：导出**打包文件（文字 + 照片全包含）**到"文件"App + **导入恢复**
7. 隐私：面容/指纹解锁**默认开启**，设置里可关闭
8. 纪念日：**可添加多个**，首页显示各纪念日和天数
9. 地点排行：统计最常去的约会地点

---

## 二、目录结构

```
茹茹舟舟/
├── project.yml                 # XcodeGen 工程描述（方式一用）
├── README.md                   # 本文件
└── Sources/                    # 全部 Swift 源码
    ├── RuruZhouzhouApp.swift   # App 入口
    ├── ContentView.swift       # 三栏 Tab + 锁屏逻辑
    ├── Theme.swift             # 配色 / 字体 / 评分表情 / 日期格式
    ├── Models.swift            # 约会记录、纪念日、地点排行模型
    ├── AppStore.swift          # 数据仓库（本地存储 + 统计）
    ├── BackupManager.swift     # 备份导出 / 导入恢复
    ├── Services.swift          # 定位服务 + 面容/指纹解锁
    ├── Helpers.swift           # 图片压缩工具
    ├── Components.swift        # 圆角卡片 / 流式标签 / 统计卡 / 空状态
    ├── RatingSliderView.swift  # 1–10 分表情滑块
    ├── HomeView.swift          # 首页
    ├── RecordCardView.swift    # 记录卡片
    ├── RecordDetailView.swift  # 详情页
    ├── AddRecordView.swift     # 打卡 / 编辑页
    ├── TagPickerView.swift     # 标签选择器
    ├── CalendarView.swift      # 日历页
    ├── SettingsView.swift      # 设置页（纪念日/标签/备份/隐私/排行）
    ├── AddAnniversaryView.swift# 添加纪念日
    ├── LockScreenView.swift    # 锁屏页
    └── Assets.xcassets/        # 占位图标 + 主题色
```

---

## 三、环境要求

| 项目 | 要求 |
|---|---|
| 电脑 | Mac（装 Xcode） |
| Xcode | 15 或更高（16 更佳） |
| 手机 | iPhone，iOS 16.0 及以上 |
| 账号 | 一个免费 Apple ID 即可（无需付费开发者账号） |
| 数据线 | iPhone 原装或 MFi 认证数据线 |

> 首次运行前请确保 iPhone 上已登录 Apple ID（设置 → 顶部头像）。

---

## 四、运行方式（二选一）

### 方式一：用 XcodeGen 一键生成工程（推荐，最快）

1. 安装 XcodeGen（只需一次）：
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   brew install xcodegen
   ```
2. 打开"终端"，进入本项目目录：
   ```bash
   cd "茹茹舟舟的目录"
   xcodegen generate
   open RuruZhouzhou.xcodeproj
   ```
3. 接下来按"第五部分 · 真机运行"继续。

### 方式二：手动创建工程（不装任何额外工具）

1. 打开 Xcode → 菜单栏 **File → New → Project…**
2. 选择 **iOS → App**，点 Next，填写：
   - Product Name：`RuruZhouzhou`
   - Interface：`SwiftUI`
   - Language：`Swift`
   - 取消勾选 Use Core Data / Include Tests
3. 保存到任意位置。创建后，在左侧导航里**删除** Xcode 自动生成的两个文件：`ContentView.swift` 和 `RuruZhouzhouApp.swift`（右键 → Delete → Move to Trash）。
4. 把本项目 `Sources/` 文件夹里的**全部 `.swift` 文件**（共 19 个）拖进 Xcode 左侧的 `RuruZhouzhou` 分组里，弹窗勾选 **Copy items if needed** 和 **Create groups**，点 Finish。
5. 同样把 `Sources/Assets.xcassets` 整个文件夹拖进去（替换掉 Xcode 自动生成的同名文件夹，或删除自动生成的后再拖入）。
6. 在左侧点项目名 `RuruZhouzhou` → 选中 TARGETS 下的 `RuruZhouzhou`：
   - **General → Deployment Info → iOS 版本** 改成 `16.0`
   - **General → Display Name** 改成 `茹茹舟舟`
   - **Info** 标签页里确认/添加两行（没有就点 + 号添加）：
     - `Privacy - Location When In Use Usage Description` = `仅在你点击"定位"时获取一次当前位置，用于填写约会地点，不会持续追踪。`
     - `Privacy - Face ID Usage Description` = `使用面容 / 指纹解锁来保护你的私密约会记录。`
7. 继续"第五部分 · 真机运行"。

---

## 五、真机运行（免费 Apple ID 签名）

1. 用数据线把 iPhone 连到 Mac，iPhone 上弹"信任此电脑"选**信任**。
2. 在 Xcode 顶部，把运行目标从模拟器切到你的 iPhone 设备名。
3. 点项目名 → TARGETS → `RuruZhouzhou` → **Signing & Capabilities**：
   - 勾选 **Automatically manage signing**
   - **Team** 下拉选择你的 Apple ID（若没有，点 Add an Account 登录你的免费 Apple ID）
4. 若提示 bundle id 冲突，把 **Bundle Identifier** 改成独一无二的，例如 `com.你的名字.ruruzhouzhou`。
5. 点 ▶️ 运行。第一次会提示"不受信任的开发者"，去 iPhone **设置 → 通用 → VPN 与设备管理** → 点你的开发者名字 → 信任。
6. 之后每次改代码，重新点 ▶️ 即可。

> 免费 Apple ID 签名的 App 有 7 天有效期，到期后在 Xcode 里重新点一下 ▶️ 即可续期，数据不会丢。

---

## 六、权限与数据说明

- **定位权限**：只在打卡页点"定位"按钮那一刻请求一次当前位置，用于反查地名（这一步会经过苹果的系统服务，不发你的照片/备注，也不持续追踪）。
- **面容/指纹**：默认开启，用于打开 App 时解锁，可在"设置 → 隐私"里关闭。
- **照片**：通过系统相册选择器选择，App 会把照片**复制压缩**到自己的沙盒目录（Documents/Photos），不读取你相册里的其他照片、不上传。

### 数据存在哪、会不会丢？
- 文字数据存在 App 沙盒的 `Documents/data.json`，照片存在 `Documents/Photos/`，每次改动自动落盘（原子写入，防写一半损坏）。
- **换机/重装前**：去"设置 → 数据备份 → 生成备份文件 → 导出备份（含照片）"，存到"文件"App 或隔空投送到别处；新机上"从备份恢复"即可完整找回（含照片）。
- 删除 App 会连同沙盒数据一起删除，所以**务必先导出备份**。

---

## 七、常见问题

1. **图标是占位的（奶杏底 + 爱心）**：这是刻意留的占位。想换成可爱小蛇时，把一张 1024×1024 的 PNG 命名为 `AppIcon.png`，放到 `Sources/Assets.xcassets/AppIcon.appiconset/` 里覆盖即可（或在 Xcode 里点 AppIcon 拖入图片）。
2. **模拟器没有面容 ID**：在模拟器上打开会自动跳过解锁；想测解锁逻辑请用真机。
3. **定位要真机**：模拟器也能模拟位置（Features → Location），但反查地名需要联网。
4. **点了"定位"没反应**：去 iPhone 设置 → 茹茹舟舟 → 位置 → 选"使用期间"。
5. **恢复备份会覆盖当前数据**：导入前请确认，避免旧备份覆盖新记录。
6. **界面颜色**：全局只用了 3 个主色（米白背景 / 奶杏·浅粉 / 深灰文字），如想微调，改 `Sources/Theme.swift` 里的数值即可。

---

## 八、后续可调整项（已预留）

- 更换 App 图标（小蛇）
- 评分表情的映射顺序（`Sources/Theme.swift` 里的 `ratingEmoji`）
- 预设标签列表（`Sources/AppStore.swift` 里的 `presetTags`）
- 主题配色（`Sources/Theme.swift`）

祝你们甜甜蜜蜜 💗
