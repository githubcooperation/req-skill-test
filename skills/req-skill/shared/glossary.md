# req-skill 词汇表

本词汇表定义 req-skill 各子技能共用的术语边界，所有子技能遇到以下术语时以本文件为准。

## 文档层级与术语映射

| 术语 | Markdown 层级 | 典型标题示例 | 说明 |
|------|-------------|------------|------|
| **模块 (Module)** | `##` 或 `###` | `## 3. 功能模块` / `### 3.2 员工端` | 一个功能域，包含多个需求卡片 |
| **需求卡片 (Requirement Card)** | `#### 3.2.N` | `#### 3.2.1 体检预约` | req-complete 输出的原子单位；一个卡片对应一个页面/屏幕 |
| **功能点 (Feature)** | 段落内规则 | "业务规则 > 规则3" | 测试用例的 `关联需求` 字段的粒度 |
| **测试模块 (Test Module)** | — | `output/test-cases/{模块名}.md` | req-testcase 输出文件的粒度，通常对应一个 `##`/`###` 模块 |

## 模块识别规则（供各子技能使用）

- 优先识别 `#### 3.2.N` 作为需求卡片（req-complete 标准输出格式）
- 若文档无 `#### 3.2.N` 格式，则以 `### N.x` 作为模块，以 `#### N.x.y` 子章节作为卡片
- req-testcase 分文件粒度：
  - 默认 = 卡片的上一级（即 `###` 或 `##` 模块），一个模块一个文件
  - 当同一上级模块下卡片 ≥ 5 时，按卡片拆分（每个 `#### 3.2.N` 单独一个文件），避免单文件过大
- req-wireframe 的 `{低保真原型图}` 对应一个需求卡片（一个页面/屏幕），不是一个功能点

## ISS-ID / FIX-NNN 编号生命周期

| ID 类型 | 生成者 | 消费者 | 生命周期 |
|---------|--------|--------|---------|
| `ISS-NNN` | req-review（写入 review-issues.md） | req-complete（读取、处理、更新状态） | req-review → req-complete → changelog，止于补全阶段 |
| `FIX-NNN` | req-complete（当无前置 review-issues 时自行编号） | 仅 changelog 内部追溯 | 仅存在于 changelog 中，不传递到下游技能 |

**下游技能不消费 ISS/FIX ID**：
- req-testcase 的"关联需求"字段使用三级格式 `模块名 > 卡片名 > 具体规则描述`，不引用 ISS/FIX ID
- req-wireframe 基于 `{低保真原型图}` 占位符定位，不消费 changelog
- req-flowdoc 基于第 4 章内容定位，不消费 changelog

## ISS-ID → PRD → TC 追踪链路

```
review-issues.md         output/prd-updated.md        output/test-cases/
ISS-001 (open)    →→→   [TBD-ISS-001] 或已填充内容   →→→   TC-UR-001 (关联需求: 模块 > 卡片 > 规则)
ISS-002 (open)    →→→   对应修改段落                  →→→   TC-UR-002
```

- `review-issues.md` 中的 `ISS-NNN` 由 req-review 生成
- `prd-updated.md` 中用 `[TBD-ISS-NNN]` 标记待解决项
- `test-cases/*.md` 中的 `关联需求` 字段应精确到"模块名 > 卡片名 > 具体规则"三级
- `changelog.md` 记录每轮 ISS-ID 的处理结果（resolved / tbd / skipped）

## 输出文件命名规则

**统一规则**：小写 + 连字符，优先使用通用英文词汇，无通用英文名的中文概念使用拼音。

**同批输出不混用**：同一子技能同一次执行产生的文件，命名风格必须统一——要么全用英文，要么全用拼音。选择依据：如果该批输出中大部分概念都有通用英文名，则全用英文（无英文名的用拼音）；反之则全用拼音。

| 子技能 | 输出文件 | 示例 |
|--------|---------|------|
| req-review | `output/review-issues.md` | 固定名 |
| req-complete | `output/prd-updated.md` | 固定名 |
| req-testcase | `output/test-cases/{模块名}.md` | `user-register.md` |
| req-wireframe | `output/wireframes/{模块-卡片-屏幕}.html/.png` | `task-list-all.html` |
| req-flowdoc | `output/flow-docs/{流程名}.md` | `order-payment.md` |
