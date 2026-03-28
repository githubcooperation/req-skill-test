# req-skill 跨文件一致性审查报告

- **审查时间**：2026-03-27
- **审查范围**：`/Users/jsonchen/Development/req-skill-test/skills/req-skill/`
- **审查方式**：cross-file consistency review（主编排器 ↔ 子 skill ↔ 共享资源）
- **审查人**：req-skill-reviewer

---

## 执行摘要

本次审查聚焦三个维度：
1. 主编排器（`SKILL.md`）的路由是否覆盖所有子 skill
2. 各子 skill 的对外接口契约（输入路径、输出路径、共享资源引用）是否对齐
3. 子 skill 之间的数据流是否一致（上游写什么 → 下游读什么）

**整体评价**：主体结构设计合理，整体文件链路清晰。发现 **6 个一致性问题**，其中 1 个为高优先级（路由遗漏），3 个为中优先级（接口约定分歧），2 个为低优先级（描述细节出入）。

---

## 一、主编排器路由完整性

### 1.1 触发关键词覆盖检查

主编排器 `SKILL.md` frontmatter 中声明了以下触发关键词：

| 子 Skill | 主编排器声明的触发词 | 子 Skill 自身 frontmatter 的触发词 | 是否对齐 |
|----------|---------------------|-------------------------------------|----------|
| req-review | "检查需求文档"、"审查PRD"、"需求有什么问题" | 同上 + "帮我review一下需求"、"看看这个需求写得怎么样"、"需求文档有没有漏洞" | 子 skill 多出 3 个关键词，主编排器未收录 |
| req-complete | "补全需求"、"把缺的信息补上"、"帮我问清楚" | 同上 + "逐条确认"、"需求补充"、"完善一下文档" | 子 skill 多出 3 个关键词，主编排器未收录 |
| req-testcase | "生成测试用例"、"出测试case"、"写测试" | 同上 + "测试覆盖"、"帮我生成测试"、"需要哪些测试用例" | 子 skill 多出 3 个关键词，主编排器未收录 |
| req-wireframe | "生成原型"、"画原型"、"出线框图"、"低保真"、"wireframe"、"原型图" | 同上 + "画界面"、"画页面" | 子 skill 多出 2 个关键词，主编排器未收录 |
| req-flowdoc | "生成流程文档"、"接口说明"、"出流程"、"写接口文档" | 同上 + "流程说明"、"接口文档" | 子 skill 多出 2 个关键词，主编排器未收录 |

**问题 CON-001**（中）：主编排器 frontmatter 中的触发关键词是各子 skill 关键词的子集，用户在主入口使用子 skill 扩展关键词时可能无法被正确路由。建议将主编排器 frontmatter 的 description 与各子 skill 的关键词保持同步，或在主编排器中明确说明"以下只是代表性关键词，意图识别逻辑见正文"。

### 1.2 路由动作描述检查

主编排器正文"意图识别与路由"中对每个子 skill 的路由描述：

```
- 用户只想审查 → 读取 req-review/SKILL.md，执行审查流程
- 用户只想补全 → 读取 req-complete/SKILL.md，执行补全流程
- 用户只想生成测试用例 → 读取 req-testcase/SKILL.md，执行生成流程
- 用户只想生成线框图 → 读取 req-wireframe/SKILL.md，执行线框图生成流程
- 用户只想生成流程文档 → 读取 req-flowdoc/SKILL.md，执行流程文档生成流程
```

所有 5 个子 skill 均有路由，**无遗漏**。

### 1.3 复合意图路由检查

主编排器定义了以下复合意图：

| 用户意图 | 路由链 | 问题 |
|---------|--------|------|
| "检查并补全" | req-review → req-complete | 正常 |
| "从头到尾帮我处理" | req-review → req-complete → req-testcase | 正常（但未包含 req-wireframe） |
| "检查完直接出测试用例" | req-review → req-testcase（跳过补全） | 正常 |
| "全套都来一遍" | req-review → req-complete → req-wireframe → req-testcase | 正常（req-flowdoc 明确说明默认不含，合理） |
| "审查完补全然后出原型" | req-review → req-complete → req-wireframe | 正常 |

**问题 CON-002**（低）："从头到尾帮我处理"路由链（review → complete → testcase）未包含 req-wireframe，但与"全套都来一遍"（review → complete → wireframe → testcase）的差异没有解释。用户可能对"从头到尾"和"全套"的区别感到困惑。建议在主编排器中补充注释说明两者的差异，或统一两者的行为。

---

## 二、子 Skill 接口契约对齐检查

### 2.1 输入文档路径一致性

所有子 skill 均按以下优先级读取输入文档：

| 子 Skill | 优先使用 | 回退 |
|----------|---------|------|
| req-review | 用户指定路径 | 无（必须用户提供） |
| req-complete | `output/prd-updated.md` | 用户指定的原始文档 |
| req-testcase | `output/prd-updated.md` | 用户指定的原始文档 |
| req-wireframe | `output/prd-updated.md` | 用户指定的原始文档 |
| req-flowdoc | `output/prd-updated.md` | 询问用户原始 PRD 路径 |

主编排器"状态感知"章节也明确说明了同样的优先级逻辑。**该维度对齐良好。**

### 2.2 输出路径一致性

| 产出物 | 主编排器声明路径 | 子 Skill 实际输出路径 | 是否一致 |
|--------|---------------|---------------------|--------|
| 审查缺陷清单 | `output/review-issues.md` | `output/review-issues.md` | 是 |
| 补全后文档 | `output/prd-updated.md` | `output/prd-updated.md` | 是 |
| 变更记录 | `output/changelog.md` | `output/changelog.md` | 是 |
| 线框图 HTML | `output/wireframes/<模块-页面>.html` | `output/wireframes/{文件名}.html` | 是 |
| 线框图截图 | `output/wireframes/<模块-页面>.png` | `output/wireframes/{同名}.png` | 是 |
| 流程文档 | `output/flow-docs/<流程名>.md` | `output/flow-docs/{流程名}.md` | 是 |
| 测试用例 | `output/test-cases/<模块名>.md` | `output/test-cases/{模块文件名}.md` | 是 |

**输出路径完全对齐。**

### 2.3 共享资源引用一致性

主编排器"共享资源"章节声明了以下 5 个共享文件，逐一核对各子 skill 的实际引用：

| 共享文件 | 声明用途 | 引用方 | 实际引用情况 |
|---------|---------|--------|------------|
| `shared/issue-schema.md` | req-review 写入、req-complete 消费 | req-review | 明确说明"严格按 `shared/issue-schema.md` 输出" ✓ |
| `shared/issue-schema.md` | req-review 写入、req-complete 消费 | req-complete | **未直接引用** `shared/issue-schema.md`，第一步仅说明读取 `output/review-issues.md`，假设其格式已符合 schema ✗ |
| `shared/prd-template.md` | req-complete 使用，req-wireframe 替换占位符 | req-complete | "按 `shared/prd-template.md` 的格式输出" ✓ |
| `shared/prd-template.md` | req-complete 使用，req-wireframe 替换占位符 | req-wireframe | **未声明读取 `shared/prd-template.md`**，只声明读取 `shared/wireframe-style.html` ✗ |
| `shared/testcase-template.md` | req-testcase 使用 | req-testcase | "严格按 `shared/testcase-template.md` 的格式输出" ✓ |
| `shared/flow-doc-template.md` | req-flowdoc 使用 | req-flowdoc | "严格按 `shared/flow-doc-template.md` 的结构输出" ✓ |
| `shared/wireframe-style.html` | req-wireframe 用于保持风格一致 | req-wireframe | "读取 `shared/wireframe-style.html` 获取 CSS 变量规范" ✓ |

**问题 CON-003**（中）：主编排器声明 `shared/issue-schema.md` 由 req-complete 消费，但 req-complete/SKILL.md 中没有任何步骤说明读取或验证 `shared/issue-schema.md`，它隐式依赖上游 req-review 已按 schema 正确输出。若两者单独使用（用户直接用 req-complete 而 review 不是本套 skill 输出的），可能出现字段不匹配。建议 req-complete 第一步增加"如果 `output/review-issues.md` 存在，验证其是否符合 `shared/issue-schema.md` 的格式，如缺少 ISS-ID 则自行编号"——其实 req-complete/SKILL.md changelog 章节末尾已有这个 fallback 逻辑（`FIX-001` 编号），但逻辑放在第四步（输出文件）而非第一步（确认输入），导致前三步的提问都基于可能格式不合规的数据。

**问题 CON-004**（中）：主编排器声明 `shared/prd-template.md` 中的 `{低保真原型图}` 占位符由 req-wireframe 替换，但 req-wireframe/SKILL.md 第一步只读取 `shared/wireframe-style.html`，不读取 `shared/prd-template.md`。这意味着 req-wireframe 对占位符的格式认知依赖主编排器说明或注释，而非直接查阅模板。若 prd-template 中的占位符格式变更，req-wireframe 不会感知到。建议在 req-wireframe 第一步中增加读取 `shared/prd-template.md` 的说明，或至少在注释中明确占位符格式来源。

---

## 三、数据流一致性（上下游接口契约）

### 3.1 req-review → req-complete 数据流

| 检查项 | req-review 输出约定 | req-complete 读取约定 | 是否对齐 |
|--------|-------------------|---------------------|--------|
| 文件路径 | `output/review-issues.md` | `output/review-issues.md` | 是 |
| ISS-ID 格式 | `ISS-{三位序号}` | 引用 ISS-ID 进行追溯和 TBD 标记 | 是 |
| status 字段初始值 | `open` | 更新为 `resolved` / `tbd` | 是 |
| 排序要求 | 先 P0 再 P1 再 P2 | 按同样顺序提问 | 是 |
| Markdown 表格列顺序 | `ID \| 模块 \| 类型 \| 严重度 \| 定位 \| 描述 \| 状态` | 解析 module、severity、status 字段 | 是（字段名对应） |

**该链路对齐良好。**

### 3.2 req-complete → req-testcase 数据流

| 检查项 | req-complete 输出约定 | req-testcase 读取约定 | 是否对齐 |
|--------|---------------------|---------------------|--------|
| 文件路径 | `output/prd-updated.md` | `output/prd-updated.md` | 是 |
| TBD 标记格式 | `[TBD-{ISS-ID}]` | 扫描 `[TBD-` 标记 | 是 |
| 版本号 | 版本号递增（v1.0 / v2.0...） | 读取版本号填入用例文件头部 | 是 |

**该链路对齐良好。**

### 3.3 req-complete → req-wireframe 数据流

| 检查项 | req-complete 输出约定 | req-wireframe 读取约定 | 是否对齐 |
|--------|---------------------|----------------------|--------|
| 文件路径 | `output/prd-updated.md` | `output/prd-updated.md` | 是 |
| 占位符格式 | `{低保真原型图}`（继承自 `shared/prd-template.md`） | 扫描 `{低保真原型图}` | 是 |
| 版本号更新方式 | 整数递增（v1.0 → v2.0） | 小数递增（v1.0 → v1.1） | **不一致** |

**问题 CON-005**（中）：版本号递增方式在不同子 skill 中不一致。req-complete 第五步口头汇总写"版本 v{N}.0"，req-wireframe 第四步写"版本号递增（v1.0 → v1.1）"。这意味着同一文档（`output/prd-updated.md`）经过 req-complete 补全后版本号是 v2.0，经过 req-wireframe 嵌入线框图后版本号变成 v2.1，但如果 req-wireframe 单独运行（没有经过 req-complete），它会从 v1.0 改为 v1.1。版本号语义不统一会造成混乱。建议在主编排器或 `shared/prd-template.md` 中统一定义版本号递增规则（例如：major version 由 req-complete 管理，minor version 由 req-wireframe 管理）。

### 3.4 req-complete → req-flowdoc 数据流

| 检查项 | req-complete 输出约定 | req-flowdoc 读取约定 | 是否对齐 |
|--------|---------------------|---------------------|--------|
| 文件路径 | `output/prd-updated.md` | `output/prd-updated.md` | 是 |
| TBD 标记格式 | `[TBD-{ISS-ID}]` | req-flowdoc 使用 `TBD` 和 `TBD（说明）` 格式，与上游不同 | **弱不一致** |

**问题 CON-006**（低）：req-complete 输出文档中的待定项标记为 `[TBD-ISS-001]`（带方括号和 ISS 引用），而 req-flowdoc 生成的流程文档中的待定项标记为 `TBD` 或 `TBD（原因说明）`（不带方括号，无 ISS 引用）。这两种格式在流程文档里同时存在时，工具链下游若需要批量处理 TBD 项，需要识别两种不同的语法。影响有限（req-flowdoc 是终态产物，没有下游消费其 TBD），但建议统一说明，或在 req-flowdoc 中注明"此处 TBD 格式与 prd-updated.md 中的 [TBD-xxx] 格式有意区分"。

---

## 四、路径约定一致性

### 4.1 相对路径说明

所有子 skill 均有以下路径约定说明（以不同表述出现）：

> "本文件中所有文件路径均相对于 skill 根目录（即 `req-skill/`），而非当前子目录"

| 子 Skill | 是否有路径说明 |
|----------|-------------|
| req-review | 有 ✓ |
| req-complete | 有 ✓ |
| req-testcase | 有 ✓ |
| req-wireframe | 有 ✓ |
| req-flowdoc | 有 ✓ |

**路径约定一致，统一良好。**

### 4.2 output/ 目录相对于谁

主编排器说明"所有产出物统一写入项目根目录下的 `output/` 目录"，各子 skill 均直接引用 `output/xxx` 路径。

**潜在问题**：`output/` 是相对于"项目根目录"，而子 skill 文件路径约定是相对于"skill 根目录（req-skill/）"，这两个根目录不同。如果 skill 本身被放置在与项目根目录不同的位置，执行时需要两个不同的相对路径基点，容易混淆。当前文件中没有统一说明如何区分这两个根目录。这是一个潜在的执行歧义，但在正常使用中（skill 放在 Claude Code 的 skills/ 目录，项目文档在另一个工作目录）影响不大。

---

## 五、问题汇总

| ID | 位置 | 严重度 | 类型 | 描述 |
|----|------|--------|------|------|
| CON-001 | 主编排器 SKILL.md frontmatter | 中 | 不完整 | 主编排器触发关键词是子 skill 的子集，各子 skill 额外关键词未同步到主入口 |
| CON-002 | 主编排器 SKILL.md 复合意图路由 | 低 | 不一致 | "从头到尾"与"全套"的路由链差异未说明，用户理解成本高 |
| CON-003 | req-complete/SKILL.md 第一步 | 中 | 接口契约缺失 | req-complete 未声明验证输入是否符合 `shared/issue-schema.md`，ISS-ID fallback 逻辑位置过晚（第四步才出现） |
| CON-004 | req-wireframe/SKILL.md 第一步 | 中 | 引用遗漏 | req-wireframe 未读取 `shared/prd-template.md`，对 `{低保真原型图}` 占位符的格式依赖隐式知识而非明确引用 |
| CON-005 | req-complete/SKILL.md 第五步 vs req-wireframe/SKILL.md 第四步 | 中 | 规范冲突 | 版本号递增方式不一致：req-complete 用整数版本（v2.0），req-wireframe 用小数版本（v1.1） |
| CON-006 | req-flowdoc/SKILL.md TBD 标注约定 vs req-complete/SKILL.md TBD 处理 | 低 | 弱不一致 | TBD 标记格式在两个子 skill 中不同（`[TBD-ISS-001]` vs `TBD（说明）`），无统一规范 |

---

## 六、修改建议（按优先级）

### 高优先级

无高优先级问题（路由完整，无功能性遗漏）。

### 中优先级

**CON-001**：在主编排器 frontmatter 的 description 中补充各子 skill 的额外触发关键词（"画界面"、"画页面"、"逐条确认"、"流程说明"、"接口文档"等），或在 description 末尾加一句"各子 skill 的完整触发词见对应 SKILL.md"。

**CON-003**：将 req-complete/SKILL.md 第一步的输入验证逻辑前移：在读取 `output/review-issues.md` 后立即检查 ISS-ID 字段是否存在，若缺失则自动补全编号为 `FIX-001`、`FIX-002`，而不是等到第四步写 changelog 时才处理。

**CON-004**：在 req-wireframe/SKILL.md 第一步"确认输入文档"中增加一行："同时确认文档中使用的占位符格式为 `{低保真原型图}`（可参考 `shared/prd-template.md` 的 3.2.x 章节）"，使引用来源明确。

**CON-005**：在主编排器的"共享资源"或输出目录说明中增加版本号规范：
- req-complete 每次补全：major version +1（v1.0 → v2.0）
- req-wireframe 嵌入线框图：minor version +1（v1.0 → v1.1）
- 并在两个子 skill 的输出步骤中明确引用此规范。

### 低优先级

**CON-002**：在复合意图路由中为"从头到尾帮我处理"添加注释，说明其与"全套都来一遍"的区别（前者不含线框图生成，后者含）。

**CON-006**：在主编排器或 `shared/` 目录下统一说明 TBD 的两种形式：
- 文档内未解决项（prd-updated.md）：使用 `[TBD-ISS-001]` 格式
- 独立产出物内的待确认字段（flow-docs/、test-cases/）：使用 `TBD` 或 `TBD（说明）` 格式

---

## 七、未发现问题的检查项（确认正常）

- 所有子 skill 均有"路径说明"注释，路径约定一致
- 主编排器"状态感知"覆盖了 6 种 output 目录状态，与各子 skill 的"已有文件处理"逻辑对应
- req-review 的输出格式与 `shared/issue-schema.md` 定义完全对齐
- req-testcase 的输出格式与 `shared/testcase-template.md` 定义完全对齐
- req-flowdoc 的输出格式与 `shared/flow-doc-template.md` 定义完全对齐（出参固定字段完全一致）
- req-testcase 的用例 ID 格式（`TC-{模块缩写}-{三位序号}`）在 SKILL.md 和 testcase-template.md 中描述一致
- req-review 的严重度判定（P0/P1/P2）与 `shared/issue-schema.md` 的定义一致
- 所有子 skill 均有"已有文件的处理"章节，行为一致（提示用户选择覆盖/增量/取消）
- req-flowdoc 的出参固定字段与 `shared/flow-doc-template.md` 完全吻合（code/success/message/timestamp/result 均有）
