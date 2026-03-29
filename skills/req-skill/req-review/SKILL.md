---
name: req-review
description: >
  审查需求文档，找出模糊、遗漏、矛盾、不可测试等问题，输出结构化缺陷清单。
  当用户提到"检查需求文档"、"审查PRD"、"需求有什么问题"、"帮我review一下需求"、
  "看看这个需求写得怎么样"、"需求文档有没有漏洞"时触发。
  只负责发现问题，不修改原文档，不给出解决方案。
---

# 需求文档审查

> 📁 **路径速查**：skill 内部文件（shared/ 等）相对于 `req-skill/`；output 文件相对于 workspace 根目录；用 `Glob("**/<filename>")` 定位 shared 文件最可靠。

## 职责

读取需求文档，系统化地找出其中的质量问题，输出一份结构化的缺陷清单。

你只做一件事：**找问题**。不修改原文档，不给建议方案，不替用户做决定。

## 执行流程

### 第一步：确认输入

从用户消息中提取需求文档的文件路径。如果用户没有提到路径，询问："请告诉我需求文档的文件路径。"

读取该文件内容。如果文件不存在或无法读取，告知用户并停止。

### 第二步：加载审查规则

依次加载以下两份规则：

> **路径约定**
> - skill 内部文件（shared/、reference/）：相对于 `req-skill/` 根目录
>   - 正确：`req-review/generic-rules.md`、`reference/business-rules.md`、`shared/issue-schema.md`
> - output 文件：相对于 workspace 根目录（eval 工作目录）
>   - 正确：`output/review-issues.md`
>   - 从本目录访问：`../../output/review-issues.md`
> - 推荐：用 `Glob("**/issue-schema.md")` 等方式定位 shared 文件，无需计算层级

1. **通用规则**：读取 `req-review/generic-rules.md`（即 `req-skill/req-review/generic-rules.md`），这是内置的、不依赖项目的通用审查维度
2. **项目规则**：读取 `reference/business-rules.md`（即 `req-skill/reference/business-rules.md`，**不是** `req-skill/req-review/reference/business-rules.md`），这是项目团队自定义的业务规则

如果 `reference/business-rules.md` 不存在，只使用通用规则，不报错。如果文件存在但内容全是 HTML 注释模板（没有实际业务规则），也视为空文件，只使用通用规则，但在口头汇总中追加提示："项目业务规则文件（reference/business-rules.md）尚未填写，建议补充项目特有规则以提升审查精度。"

### 第三步：逐章节审查

按文档的标题层级（H1/H2/H3）逐章节扫描，对每个章节执行以下检查：

**通用规则检查**（来自 `generic-rules.md`）：
- 每条规则逐一比对当前章节内容
- 发现问题时，记录为一条缺陷

**项目规则检查**（来自 `business-rules.md`）：
- 如果项目规则中定义了与当前模块相关的业务规则，逐条检查是否在文档中有明确说明
- 文档中提到但与业务规则矛盾的，记录为 `contradiction` 类型
- 业务规则要求但文档中未提及的，记录为 `missing` 类型

**跨章节一致性检查**：
- 同一概念在不同章节的描述是否一致
- 状态流转是否完整（有入口必有出口，有正向必有回退）
- 术语使用是否统一

### 第四步：输出缺陷清单

**严格**按 `shared/issue-schema.md` 中定义的结构输出缺陷清单到 `output/review-issues.md`。

**格式规范**：读取 `shared/issue-schema.md`（用 Glob 定位），严格按其中定义的字段和枚举值生成每行缺陷条目。必填字段：id（ISS-NNN格式）、module、type、severity、location、description、status（初始值 open）。

输出格式使用 Markdown 表格，表头为：`| ID | 模块 | 类型 | 严重度 | 定位 | 描述 | 状态 |`

输出前排序：先按严重程度（P0 > P1 > P2），同级别内按模块归组。

**写完后自检（逐条确认，不达标立即补充）：**
1. ✅ 每行 ID 格式为 `ISS-NNN`（三位数字，如 ISS-001）
2. ✅ `type` 字段值仅来自：ambiguous / missing / contradiction / untestable / incomplete_flow / missing_constraint
3. ✅ `severity` 字段值仅为 P0 / P1 / P2
4. ✅ `description` 是一句话问题陈述，不含原文大段引用
5. ✅ `status` 初始值均为 `open`
6. ✅ 至少扫描了 PRD 的每个 H2 章节

**严重度判定指南**：
- 有明确行业默认值的缺失项（如验证码有效期），除非影响核心支付/安全流程，否则定为 P1 而非 P0
- P0 仅用于：核心业务流程完全缺失、关键数据字段未定义导致无法开发、存在直接矛盾导致无法实现
- 边界模糊时倾向于降级（P1 而非 P0），让用户决定是否升级

### 第五步：口头汇总

输出文件后，在对话中给出简短的口头汇总：

```
审查完成。共发现 {总数} 个问题：
- P0（阻塞性）：{数量} 个
- P1（重要）：{数量} 个
- P2（改进）：{数量} 个

主要集中在 {问题最多的2-3个模块}。

缺陷清单已写入 output/review-issues.md。
要继续补全这些缺口吗？
```

## 审查原则

- **只记录事实，不加主观评价**。写"未说明验证码有效期"，不写"这里写得太随意了"
- **每条缺陷独立可消费**。req-complete 读到任何一条缺陷，不需要看其他条目就能理解问题
- **宁可多记不可漏记**。不确定是不是问题时，以 P2 级别记录下来，让用户决定
- **尊重原文的合理性**。如果某处描述虽然简略但逻辑完整、不影响开发测试，不标记为缺陷

## 长文档处理

如果文档超过 3000 字：
- 分章节处理，每个 H2 章节作为一个审查单元
- 先完成所有章节的审查，最后做一遍跨章节一致性检查
- 在口头汇总中标注"已按章节分段审查"
