# Aptos 猜数字游戏 (Guessing Game)

一个基于Aptos区块链的去中心化猜数字游戏，使用最新的Fungible Asset (FA) 标准。

## 🎯 项目特色

- **FA标准支持**: 使用最新的Fungible Asset标准，为2025年6月30日的代币迁移做好准备
- **管理员系统**: 完整的代币管理和游戏配置功能
- **现代化UI**: 响应式设计，支持钱包连接
- **智能合约**: 使用Move语言编写，安全可靠

## 📁 项目结构

```
AGPTCodexProject/
├── aptos_guess_game/           # Move智能合约
│   ├── sources/
│   │   ├── guessing_game.move      # 主合约文件
│   │   └── guessing_game_tests.move # 测试文件
│   └── Move.toml               # 项目配置
├── frontend/                   # 前端界面
│   ├── admin.html             # 管理员页面
│   └── index.html             # 玩家页面
├── aptos                      # Aptos CLI v7.4.0
└── README.md
```

## 🚀 快速开始

### 1. 环境准备

确保你有以下工具：
- Node.js (用于本地服务器)
- 支持Aptos的钱包 (如Petra Wallet)

### 2. 智能合约

智能合约已部署到Devnet：
- **合约地址**: `0xe8212f3e57916bcb45f037d6de15e56cf97107669a767d8232f4aa359e061dda`
- **模块名**: `guessing_game`
- **网络**: Devnet

### 3. 运行前端

```bash
# 启动本地服务器
cd frontend
python3 -m http.server 8000
# 或使用Node.js
npx serve .
```

然后访问：
- 管理员页面: http://localhost:8000/admin.html
- 玩家页面: http://localhost:8000/index.html

## 🎮 游戏规则

1. **管理员设置**:
   - 初始化游戏配置
   - 设置允许的FA代币类型
   - 创建新游戏并设定参与费用

2. **玩家参与**:
   - 连接钱包
   - 选择1-99之间的数字
   - 支付参与费用加入游戏

3. **游戏结束**:
   - 当10名玩家参与后自动结束
   - 系统生成随机数字
   - 猜测最接近的玩家获得95%奖池
   - 5%作为手续费分配

## 🔧 开发工具

### 编译合约
```bash
./aptos move compile
```

### 运行测试
```bash
./aptos move test
```

### 发布合约
```bash
./aptos init --network devnet
./aptos move publish
```

## 📋 主要功能

### 智能合约功能
- `initialize`: 初始化游戏配置
- `set_token_allowed`: 设置允许的代币类型
- `new`: 创建新游戏
- `join`: 玩家加入游戏
- `get_game_info`: 查询游戏信息
- `is_token_allowed`: 检查代币是否被允许

### 前端功能
- 钱包连接/断开
- 游戏配置管理
- 代币权限设置
- 游戏创建和参与
- 实时状态显示

## 🔄 FA标准迁移

本项目已完全适配Aptos的Fungible Asset标准：

- ✅ 使用`primary_fungible_store`进行代币转账
- ✅ 支持FA metadata管理
- ✅ 兼容新版Aptos CLI v7.4.0
- ✅ 为2025年6月30日的APT迁移做好准备

## 🧪 测试

项目包含完整的单元测试：
- 基本游戏流程测试
- 代币权限验证测试
- 错误处理测试

所有测试均通过，确保合约的安全性和可靠性。

## 📝 版本历史

- **v1.0.0**: 初始版本，支持FA标准
- 使用Aptos CLI v7.4.0
- 部署到Devnet成功

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这个项目！

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件
