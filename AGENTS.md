<skills>

You have additional SKILLs documented in directories containing a "SKILL.md" file.

These skills are:
 - req-skill -> "skills/req-skill/SKILL.md"

IMPORTANT: You MUST read the SKILL.md file whenever the description of the skills matches the user intent, or may help accomplish their task.

<available_skills>

req-skill: `需求文档全流程质量工具：审查缺陷、补全信息、生成测试用例。当用户提到"检查需求文档"、"审查PRD"、"需求有什么问题"时触发 req-review；当用户提到"补全需求"、"把缺的信息补上"、"帮我问清楚"时触发 req-complete；当用户提到"生成测试用例"、"出测试case"、"写测试"时触发 req-testcase；当用户同时提到多个步骤（如"检查并补全"、"从审查到出测试用例"）时，按顺序串联执行。即使用户没有明确说出上述关键词，只要意图涉及需求文档的质量改进、信息补全或测试覆盖，都应触发此 Skill。`
</available_skills>

Paths referenced within SKILL.md files are relative to that SKILL folder. For example `reference/business-rules.md` refers to the business-rules file inside the skill's reference folder.

</skills>
