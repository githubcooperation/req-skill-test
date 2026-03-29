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
- req-testcase 分文件粒度 = 卡片的上一级（即 `###` 或 `##` 模块），一个模块一个文件
- req-wireframe 的 `{低保真原型图}` 对应一个需求卡片（一个页面/屏幕），不是一个功能点

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

| 子技能 | 输出文件 | 命名规则 | 示例 |
|--------|---------|---------|------|
| req-review | `output/review-issues.md` | 固定名 | — |
| req-complete | `output/prd-updated.md` | 固定名 | — |
| req-testcase | `output/test-cases/{模块名}.md` | 小写英文/拼音 + 连字符 | `user-register.md` |
| req-wireframe | `output/wireframes/{模块-卡片-屏幕}.html/.png` | 小写英文/拼音 + 连字符 | `yuyue-liucheng-quanbu.html` |
| req-flowdoc | `output/flow-docs/{流程名}.md` | 小写英文/拼音 + 连字符 | `user-login.md` |
