with open(r'c:\Users\BAPS\Desktop\application 2\lib\data\repositories\person_repository.dart', 'r', encoding='utf-8') as f:
    text = f.read()

import re
matches = re.findall(r"id:\s*'([^']+)'(?:(?!final Person).)*?generationHint:\s*(\d+)", text, re.DOTALL)
print('Gen 9 persons:', [m[0] for m in matches if m[1] == '9'])

