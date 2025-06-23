# Xunity AI Translator

一个基于 Flutter 的 LLM 翻译服务，提供 HTTP API 和图形用户界面。

## 功能特性

- **HTTP API 端点**: 提供 RESTful 翻译服务
- **图形用户界面**: 直观的配置和监控界面
- **多 LLM 服务支持**: 支持 OpenRouter、OpenAI、Azure OpenAI 等
- **并发控制**: 可配置的并发翻译请求数量
- **翻译日志**: 详细的翻译记录，支持折叠展开
- **自定义提示词**: 支持自定义翻译提示词模板
- **正则表达式提取**: 灵活的翻译结果提取

## 快速开始

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 生成代码

```bash
dart run build_runner build
```

### 3. 运行应用

```bash
flutter run
```

## 配置说明

### 服务配置

- **HTTP 服务端口**: 默认 8080，可自定义
- **并发数量**: 同时处理的翻译请求数量，默认 3

### LLM 服务配置

#### OpenRouter（推荐）

- **提供商**: OpenRouter
- **API 基础 URL**: `https://openrouter.ai/api/v1`
- **模型**: `anthropic/claude-3.5-sonnet`
- **API 密钥**: 需要在 [OpenRouter](https://openrouter.ai/) 获取

#### OpenAI

- **提供商**: OpenAI
- **API 基础 URL**: `https://api.openai.com/v1`
- **模型**: `gpt-4`
- **API 密钥**: 需要在 [OpenAI](https://platform.openai.com/) 获取

#### 自定义服务

- 支持任何 OpenAI 兼容的 API 服务

### 提示词配置

默认提示词模板：

```
Translate the following text from {from} to {to}:

{text}

Translation:
```

支持的变量：

- `{from}`: 源语言
- `{to}`: 目标语言
- `{text}`: 待翻译文本

### 正则表达式配置

默认输出提取正则表达式：`Translation:\s*(.+)`

用于从 LLM 响应中提取翻译结果。

## API 使用

### 翻译端点

```
GET /translate?from=<源语言>&to=<目标语言>&text=<待翻译文本>
```

**参数说明：**

- `from`: 源语言代码（如：en, zh, ja, ko）
- `to`: 目标语言代码
- `text`: 待翻译的文本内容

**示例请求：**

```bash
curl "http://localhost:8080/translate?from=en&to=zh&text=Hello%20World"
```

**响应：**

```
你好世界
```

### 健康检查端点

```
GET /health
```

**响应示例：**

```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

## 测试 API

运行测试脚本：

```bash
dart run test_api.dart
```

确保服务器已启动并运行在配置的端口上。

## 使用流程

1. **配置服务**: 在"配置"标签页中设置 API 密钥和其他参数
2. **启动服务器**: 在"服务控制"标签页中启动 HTTP 服务器
3. **监控日志**: 在"翻译日志"标签页中查看翻译记录
4. **API 调用**: 使用 HTTP 客户端调用翻译 API

## 注意事项

1. **API 密钥安全**: 请妥善保管您的 API 密钥，不要在公共场所泄露
2. **并发限制**: 根据您的 API 服务商限制调整并发数量
3. **网络连接**: 确保网络连接正常，能够访问 LLM 服务
4. **端口占用**: 确保配置的端口未被其他服务占用

## 故障排除

### 服务器启动失败

- 检查端口是否被占用
- 确认防火墙设置

### 翻译失败

- 检查 API 密钥是否正确
- 确认网络连接
- 查看翻译日志中的错误信息

### 配置丢失

- 配置会自动保存到本地存储
- 重新安装应用会重置配置

## 开发

### 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── translation_config.dart
│   └── translation_config.g.dart
├── services/                 # 服务层
│   ├── llm_service.dart
│   ├── enhanced_translation_service.dart
│   └── http_server.dart
├── providers/                # 状态管理
│   └── app_providers.dart
└── widgets/                  # UI 组件
    ├── config_panel.dart
    ├── server_control_panel.dart
    └── translation_logs.dart
```

### 技术栈

- **Flutter**: UI 框架
- **Riverpod**: 状态管理
- **Shelf**: HTTP 服务器
- **Dio**: HTTP 客户端
- **SharedPreferences**: 本地存储

## 许可证

MIT License
