# req-skill 回归验收清单

每次修改 SKILL.md 后，按以下清单跑对应场景验证。

## 快速验证（必须）

### C类输入（采访稿/会议记录）→ prd-updated.md

运行：`./run-skill.sh req-skill-reviewer-workspace/evals/test-complete-1 "请使用req-complete技能处理 docs/interview.md，自动补全，不用问我，直接按行业最佳实践填充"`

- [ ] `output/prd-updated.md` 文件存在且行数 > 50
- [ ] `{低保真原型图}` 在 prd-updated.md 中出现至少 3 次（`grep -c "低保真原型图" output/prd-updated.md`）
- [ ] 文档有版本号（`grep "版本" output/prd-updated.md`）
- [ ] `output/changelog.md` 存在且包含"已解决"和"统计"两个区块
- [ ] `output/review-issues.md` 已有时，其 status 已从 open 更新

### B类输入（不规范PRD）→ prd-updated.md

- [ ] 原文档的模块结构得以保留（章节数不少于原文档）
- [ ] `{低保真原型图}` 出现次数 ≥ 原文档功能模块数
- [ ] TBD 项用 `[TBD-xxx]` 标注而非留空

### req-review → review-issues.md

- [ ] `output/review-issues.md` 存在
- [ ] 所有行 ID 格式为 `ISS-NNN`（`grep -P "ISS-\d{3}" output/review-issues.md`）
- [ ] 文件末尾有"按模块汇总"部分

### req-testcase → test-cases/

- [ ] `output/test-cases/` 目录下有文件
- [ ] TC-ID 格式为 `TC-{大写}-{3位}`（`grep -P "TC-[A-Z]+-\d{3}" output/test-cases/*.md`）
- [ ] 每条用例有 `关联需求` 字段
- [ ] 汇总表存在且计数合理

## 路径验证（修改路径规范后必须）

- [ ] 模型未在 workspace 之外的目录写入文件（检查有无 `skills/req-skill/output/` 目录被创建）
- [ ] shared/ 模板文件被正确读取（检查生成的 prd-updated.md 是否使用了 prd-template.md 的结构）

## 格式稳定性（模型更换时必须）

- [ ] C类输入测试时，`{低保真原型图}` 由模型自身生成（非 repair 脚本插入）
  - 检查方法：在 run-skill.sh 中临时注释掉 repair 步骤，再次运行验证
- [ ] `#### 3.2.N` 编号格式正确（N 从1递增，无跳号或重复）

## 评测数据目录

- tc-1（采访稿）：`req-skill-reviewer-workspace/evals/test-complete-1/`
- tc-4（会议记录）：`req-skill-reviewer-workspace/evals/test-complete-4/`
- run-skill.sh：`/Users/jsonchen/Development/req-skill-test/run-skill.sh`
