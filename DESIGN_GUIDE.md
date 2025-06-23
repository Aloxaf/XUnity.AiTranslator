# Xunity AI Translator 设计指南

## 设计理念

本应用采用现代化的深色主题设计，专为桌面环境优化，提供专业、精致的用户体验。

## 设计特色

### 🎨 颜色方案

- **主色调**: Indigo (#6366F1) - 现代感十足的紫蓝色
- **辅助色**: Purple (#8B5CF6) - 用于渐变和强调
- **背景色**:
  - 主背景 (#0A0A0A) - 深黑色，减少眼部疲劳
  - 卡片背景 (#1A1A1A) - 深灰色，提供层次感
  - 内容背景 (#0F0F0F) - 更深的灰色，用于嵌套内容
- **文本色**:
  - 主文本 (#E5E5E5) - 高对比度白色
  - 次要文本 (白色 60% 透明度) - 层次分明
  - 提示文本 (#666666) - 低对比度灰色

### 🎯 设计系统

#### 1. 布局结构

- **侧边栏导航**: 280px 宽度，固定在左侧
- **主内容区**: 自适应宽度，32px 内边距
- **卡片间距**: 24px 垂直间距，16px 水平间距

#### 2. 组件设计

##### 侧边栏导航

- 渐变 Logo 图标 (64x64px)
- 应用名称分两行显示
- 导航项目采用圆角矩形 (12px)
- 激活状态有边框和背景色
- 版本信息显示在底部

##### 卡片组件

- 圆角半径: 16px
- 内边距: 24px
- 边框: 半透明灰色 (#808080 50% 透明度)
- 阴影: 无 (扁平化设计)

##### 按钮设计

- 主按钮: Indigo 背景，白色文字
- 危险按钮: 红色背景 (#EF4444)
- 圆角半径: 12px
- 内边距: 垂直 14px，水平 24px

##### 输入框设计

- 填充背景: #1A1A1A
- 圆角半径: 12px
- 边框: 默认灰色，聚焦时为主色调
- 标签文字在上方，独立显示

### 🌟 视觉亮点

#### 1. 状态指示器

- **在线状态**: 绿色圆点 (#10B981)
- **离线状态**: 灰色圆点 (#6B7280)
- **错误状态**: 红色 (#EF4444)
- **成功状态**: 绿色 (#10B981)

#### 2. 标签和徽章

- 圆角矩形设计
- 半透明背景
- 对应状态的边框色
- 小字体 (10-12px)

#### 3. 翻译日志

- 可折叠的动画效果
- 状态色彩编码
- 语言方向标签
- 时长和时间戳显示
- 内容区域语法高亮

#### 4. API 端点展示

- 代码块样式
- 可选择文本
- 复制按钮
- 分类图标

## 响应式设计

### 桌面优化

- 最小宽度: 1200px
- 侧边栏固定，主内容区自适应
- 充分利用水平空间

### 交互设计

- 悬停效果: 轻微的颜色变化
- 点击反馈: Material Design 涟漪效果
- 动画: 200ms 缓动动画
- 加载状态: 禁用按钮样式

## 可访问性

### 对比度

- 文本对比度符合 WCAG AA 标准
- 交互元素有明确的视觉反馈

### 键盘导航

- 所有交互元素支持 Tab 导航
- 焦点状态有明确的视觉指示

### 屏幕阅读器

- 语义化的 HTML 结构
- 适当的 ARIA 标签

## 组件库

### 自定义组件

- `_buildConfigCard()` - 配置卡片
- `_buildTextField()` - 自定义输入框
- `_buildDropdownField()` - 自定义下拉框
- `_buildApiEndpoint()` - API 端点展示
- `_buildContentSection()` - 内容区域
- `_buildInfoChip()` - 信息标签

### 动画组件

- `AnimatedRotation` - 展开图标旋转
- `SizeTransition` - 内容区域展开/收起
- `AnimationController` - 自定义动画控制

## 最佳实践

### 1. 颜色使用

- 主色调用于重要操作和状态
- 语义化颜色 (成功、警告、错误)
- 保持足够的对比度

### 2. 间距规范

- 8px 基础单位
- 常用间距: 8px, 12px, 16px, 24px, 32px

### 3. 文字排版

- 标题: 粗体，较大字号
- 正文: 常规字重，14px
- 说明文字: 12px，低对比度

### 4. 图标使用

- Material Design 图标
- 20px 标准尺寸
- 语义化选择

## 技术实现

### 主题配置

```dart
ThemeData.dark().copyWith(
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF6366F1),
    secondary: Color(0xFF8B5CF6),
    surface: Color(0xFF1A1A1A),
    background: Color(0xFF0A0A0A),
  ),
  // ... 其他配置
)
```

### 自定义颜色

```dart
// 主色调
const Color(0xFF6366F1)  // Indigo
const Color(0xFF8B5CF6)  // Purple

// 状态色
const Color(0xFF10B981)  // Success Green
const Color(0xFFEF4444)  // Error Red
const Color(0xFF3B82F6)  // Info Blue

// 背景色
const Color(0xFF0A0A0A)  // Main Background
const Color(0xFF1A1A1A)  // Card Background
const Color(0xFF0F0F0F)  // Content Background
```

这种设计风格既现代又专业，适合作为桌面应用的界面，提供了优秀的用户体验和视觉享受。
