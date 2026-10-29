import re

with open('lib/data/repositories/person_repository.dart', 'r', encoding='utf-8') as f:
    text = f.read()

matches = re.findall(r"id:\s*'([^']+)',\s*displayName:\s*'([^']+)'", text)
for pid, name in matches:
    print(f'{pid}: {name}')

