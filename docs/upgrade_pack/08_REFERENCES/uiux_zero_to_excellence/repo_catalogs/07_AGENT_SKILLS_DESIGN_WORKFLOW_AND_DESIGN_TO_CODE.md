# Agent Skills، design workflow و design-to-code — 50 مخزن پیشنهادی

این فهرست برای اکتشاف و مقایسه است، نه توصیه به clone/ادغام مستقیم. همهٔ مخازن در این مرحله به‌صورت آنلاین و commit-by-commit ممیزی نشده‌اند؛ هنگام انتخاب باید existence، آخرین commit/release، license، امنیت وابستگی، پشتیبانی پلتفرم و سازگاری با Flutter/Dart فعلی کنترل شود.

| # | مخزن | کاربرد | نوع استفاده | تصمیم اولیه |
|---:|---|---|---|---|
| 1 | [`anthropics/skills`](https://github.com/anthropics/skills) | Agent Skills examples and spec patterns | Skills | مرجع/بررسی |
| 2 | [`anthropics/claude-code`](https://github.com/anthropics/claude-code) | Claude Code and official skills/plugins | Skills | مرجع/بررسی |
| 3 | [`vercel-labs/agent-skills`](https://github.com/vercel-labs/agent-skills) | engineering/design skills | Skills | مرجع/بررسی |
| 4 | [`github/awesome-copilot`](https://github.com/github/awesome-copilot) | Copilot instructions/agents catalog | Skills | مرجع/بررسی |
| 5 | [`github/spec-kit`](https://github.com/github/spec-kit) | spec-driven development | Workflow | مرجع/بررسی |
| 6 | [`obra/superpowers`](https://github.com/obra/superpowers) | agentic software development workflows | Workflow | مرجع/بررسی |
| 7 | [`wshobson/agents`](https://github.com/wshobson/agents) | agent configs and skills | Workflow | مرجع/بررسی |
| 8 | [`VoltAgent/awesome-claude-skills`](https://github.com/VoltAgent/awesome-claude-skills) | Claude skills directory | Catalog | PoC در شاخه جدا |
| 9 | [`sickn33/antigravity-awesome-skills`](https://github.com/sickn33/antigravity-awesome-skills) | skills catalog | Catalog | PoC در شاخه جدا |
| 10 | [`alirezarezvani/claude-skills`](https://github.com/alirezarezvani/claude-skills) | role-specific skills | Catalog | PoC در شاخه جدا |
| 11 | [`Jeffallan/claude-skills`](https://github.com/Jeffallan/claude-skills) | skills collection | Catalog | PoC در شاخه جدا |
| 12 | [`daymade/claude-code-skills`](https://github.com/daymade/claude-code-skills) | Claude Code skills | Catalog | PoC در شاخه جدا |
| 13 | [`yusufkaraaslan/Skill_Seekers`](https://github.com/yusufkaraaslan/Skill_Seekers) | skill creation/knowledge extraction | Tool | PoC در شاخه جدا |
| 14 | [`agentskills/agentskills`](https://github.com/agentskills/agentskills) | Agent Skills standard; verify canonical repo | Standard | PoC در شاخه جدا |
| 15 | [`openai/openai-cookbook`](https://github.com/openai/openai-cookbook) | OpenAI patterns and examples | Reference | مرجع/بررسی |
| 16 | [`openai/openai-agents-python`](https://github.com/openai/openai-agents-python) | agent orchestration | Reference | مرجع/بررسی |
| 17 | [`openai/openai-python`](https://github.com/openai/openai-python) | SDK reference | Reference | مرجع/بررسی |
| 18 | [`anthropics/anthropic-cookbook`](https://github.com/anthropics/anthropic-cookbook) | Claude use patterns | Reference | مرجع/بررسی |
| 19 | [`google-gemini/gemini-cli`](https://github.com/google-gemini/gemini-cli) | agentic CLI examples | Reference | مرجع/بررسی |
| 20 | [`google-gemini/gemini-cli-extensions`](https://github.com/google-gemini/gemini-cli-extensions) | extension patterns | Reference | مرجع/بررسی |
| 21 | [`microsoft/promptflow`](https://github.com/microsoft/promptflow) | prompt/flow evaluation | Tool | PoC در شاخه جدا |
| 22 | [`microsoft/semantic-kernel`](https://github.com/microsoft/semantic-kernel) | agent/orchestration patterns | Reference | مرجع/بررسی |
| 23 | [`microsoft/autogen`](https://github.com/microsoft/autogen) | multi-agent patterns | Reference | مرجع/بررسی |
| 24 | [`langchain-ai/langchain`](https://github.com/langchain-ai/langchain) | LLM application patterns | Reference | مرجع/بررسی |
| 25 | [`langchain-ai/langgraph`](https://github.com/langchain-ai/langgraph) | stateful agent workflow patterns | Reference | مرجع/بررسی |
| 26 | [`crewAIInc/crewAI`](https://github.com/crewAIInc/crewAI) | multi-agent orchestration | Reference | مرجع/بررسی |
| 27 | [`modelcontextprotocol/servers`](https://github.com/modelcontextprotocol/servers) | MCP server examples | Tool | PoC در شاخه جدا |
| 28 | [`modelcontextprotocol/specification`](https://github.com/modelcontextprotocol/specification) | MCP protocol specification | Standard | PoC در شاخه جدا |
| 29 | [`modelcontextprotocol/typescript-sdk`](https://github.com/modelcontextprotocol/typescript-sdk) | MCP SDK reference | Reference | مرجع/بررسی |
| 30 | [`modelcontextprotocol/python-sdk`](https://github.com/modelcontextprotocol/python-sdk) | MCP SDK reference | Reference | مرجع/بررسی |
| 31 | [`google/ai-edge-litert`](https://github.com/google/ai-edge-litert) | on-device AI reference | Reference | مرجع/بررسی |
| 32 | [`Figma/plugin-samples`](https://github.com/Figma/plugin-samples) | Figma plugin ideas | Design tooling | PoC در شاخه جدا |
| 33 | [`figma/plugin-typings`](https://github.com/figma/plugin-typings) | Figma plugin API types | Design tooling | PoC در شاخه جدا |
| 34 | [`storybookjs/storybook`](https://github.com/storybookjs/storybook) | component workflows | Design ops | PoC در شاخه جدا |
| 35 | [`chromaui/chromatic`](https://github.com/chromaui/chromatic) | visual review workflow | Design ops | PoC در شاخه جدا |
| 36 | [`BuilderIO/figma-html`](https://github.com/BuilderIO/figma-html) | design-to-code exploration | Design tooling | PoC در شاخه جدا |
| 37 | [`BuilderIO/mitosis`](https://github.com/BuilderIO/mitosis) | multi-framework component compiler | Design tooling | PoC در شاخه جدا |
| 38 | [`BuilderIO/figma-to-code`](https://github.com/BuilderIO/figma-to-code) | design-to-code exploration; check current repo | Design tooling | PoC در شاخه جدا |
| 39 | [`openai/skills`](https://github.com/openai/skills) | agent skill patterns; verify availability | Skills | مرجع/بررسی |
| 40 | [`vercel-labs/skills`](https://github.com/vercel-labs/skills) | skills CLI/catalog; verify canonical repo | Skills | مرجع/بررسی |
| 41 | [`anthropics/claude-code-plugins`](https://github.com/anthropics/claude-code-plugins) | plugin examples | Skills | مرجع/بررسی |
| 42 | [`anthropics/claude-code-action`](https://github.com/anthropics/claude-code-action) | CI agent workflow | Workflow | مرجع/بررسی |
| 43 | [`github/gh-aw`](https://github.com/github/gh-aw) | GitHub Agentic Workflows | Workflow | مرجع/بررسی |
| 44 | [`continuedev/continue`](https://github.com/continuedev/continue) | AI coding assistant context | Workflow | مرجع/بررسی |
| 45 | [`sourcegraph/amp`](https://github.com/sourcegraph/amp) | agent coding workflows; verify canonical repo | Workflow | مرجع/بررسی |
| 46 | [`cline/cline`](https://github.com/cline/cline) | coding agent tool patterns | Workflow | مرجع/بررسی |
| 47 | [`RooCodeInc/Roo-Code`](https://github.com/RooCodeInc/Roo-Code) | coding agent workflows | Workflow | مرجع/بررسی |
| 48 | [`Aider-AI/aider`](https://github.com/Aider-AI/aider) | pair-programming agent | Workflow | مرجع/بررسی |
| 49 | [`All-Hands-AI/OpenHands`](https://github.com/All-Hands-AI/OpenHands) | software agent workflow | Workflow | مرجع/بررسی |
| 50 | [`flutter/flutter`](https://github.com/flutter/flutter) | framework source and widget API | Cross-reference | مرجع/بررسی |

## قانون پذیرش
- ابتدا license و فعال‌بودن مخزن را بررسی کنید.
- نمونهٔ UI را برای الگو بخوانید؛ منطق مالی، احراز هویت و ذخیره‌سازی را بدون review وارد نکنید.
- هر dependency تازه باید در ADR با دلیل، حجم، نگهداری، platform support، privacy و تست جایگزین ثبت شود.
- برای Flutter، نسخهٔ سازگار با Flutter/Dart واقعی پروژه را از pub.dev و changelog مخزن بررسی کنید.
