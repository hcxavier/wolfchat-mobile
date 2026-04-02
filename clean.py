import os
import re

# Remove MD files
for f in ['AGENTS.md', 'PLANO_FIX_GROQ_DROPDOWN.md', 'PLANO_THINKING_FIX.md']:
    if os.path.exists(f):
        os.remove(f)

# Modifica analysis_options.yaml
yaml_content = """include: package:very_good_analysis/analysis_options.yaml

linter:
  rules:
    public_member_api_docs: false
"""
with open('analysis_options.yaml', 'w') as f:
    f.write(yaml_content)

# Remove comentarios
for root, dirs, files in os.walk('.'):
    if '.git' in root:
        continue
    for file in files:
        if file.endswith(('.dart', '.swift', '.cpp', '.cc', '.h')):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            with open(filepath, 'w', encoding='utf-8') as f:
                for line in lines:
                    if re.match(r'^\s*//', line):
                        continue
                    f.write(line)
