## req-skill 跨文件一致性审查报告（无 skill 基线版）

共识别 8 个问题（0 个高严重/阻塞，4 个中，4 个低）

**整体结论**：五个子 Skill 的路由无遗漏、文件引用无悬空、核心数据契约无矛盾，整体质量良好。主要问题集中在复合意图路由语义对齐、降级场景覆盖，以及跨子 Skill 的用户体验一致性三个方向。

---

### 中级问题（需关注）

**C-4：ISS-ID / FIX-ID 跨 skill 编号体系可能不一致**
req-testcase 的 TBD 引用格式硬编码 `ISS-` 前缀，未考虑 req-complete 降级路径中的 `FIX-` 前缀，上下游编号体系可能不一致。

**C-5：req-wireframe 无占位符时缺少降级处理**
当 `prd-updated.md` 中不含 `{低保真原型图}` 占位符时（用户提交的是自有格式 PRD），req-wireframe 找不到任何占位符，但缺少降级处理说明。

**C-7：req-complete 自动补全模式遗漏 business-rules.md**
req-complete 自动补全模式只引用了 `security-best-practices.md`，遗漏了 `reference/business-rules.md`——若团队填写了项目特有业务参数，自动补全时无法优先使用。

**C-8：乱序执行时 prd-updated.md 版本号失准**
req-wireframe 执行后会更新 `prd-updated.md` 的版本号；如果用户单独乱序执行（先 testcase 再 wireframe），测试用例文件中记录的文档版本号会与实际版本失准。

---

### 低级问题（建议优化）

**C-1："从头到尾帮我处理" 跳过 req-wireframe**
"从头到尾帮我处理"的执行链（review → complete → testcase）跳过了 req-wireframe，与"全套都来一遍"不一致且无文字说明。

**C-2：req-testcase 已有文件覆盖选项比其他 skill 少**
req-testcase 已有文件覆盖选项比 req-wireframe / req-flowdoc 少一个"指定重新生成哪些"，三者控制粒度不一致。

**C-3：req-testcase / req-wireframe / req-flowdoc 缺少下一步引导语**
这三个 skill 完成后缺少下一步引导语，与 req-review、req-complete 的交互风格不一致。

**C-6：出参固定字段在两处重复定义**
出参固定字段在 `req-flowdoc/SKILL.md` 和 `shared/flow-doc-template.md` 中重复定义，未来修改需同步两处，存在漂移风险。
