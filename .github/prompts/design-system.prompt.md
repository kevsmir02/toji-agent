---
description: Run the UI/UX Pro Max Reasoning Engine to generate a new adaptive design system for this project.
---

I need to generate a new design system for this project using the UI Reasoning Engine.

Please gather the following information from me if not already provided:
1. What type of application or project is this? (e.g. "SaaS dashboard", "e-commerce", "fintech banking")
2. Are there any specific styling preferences? (e.g. "dark mode only", "minimalist", "luxury")
3. What is the name of this project?

Once you have this, execute the following command:
```bash
python3 .github/skills/ui-reasoning-engine/scripts/search.py "<product type + preferences>" --design-system --persist -p "<Project Name>"
```

After generating the files, output the "Architecture Lock" containing the Style, Core Colors, and Typography, and wait for my visual confirmation before proceeding.
