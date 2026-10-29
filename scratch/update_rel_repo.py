file_path = 'lib/data/repositories/relationship_repository.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add William as son of Arthur & Evelyn (Julian's brother)
content = content.replace(
    "    addParentChild('p_gen6_evelyn', 'p_gen7_julian');",
    "    addParentChild('p_gen6_evelyn', 'p_gen7_julian');\n    addParentChild('p_gen6_arthur', 'p_gen7_william');\n    addParentChild('p_gen6_evelyn', 'p_gen7_william');"
)

# 2. Add Richard as son of William
content = content.replace(
    "    addParentChild('p_gen7_helena', 'p_gen8_david');",
    "    addParentChild('p_gen7_helena', 'p_gen8_david');\n    addParentChild('p_gen7_william', 'p_gen8_richard');"
)

# 3. Change Oliver & Clara's parents from David & Sophia to Richard
content = content.replace(
    "    addParentChild('p_gen8_david', 'p_gen9_oliver');\n    addParentChild('p_gen8_sophia', 'p_gen9_oliver');\n    addParentChild('p_gen8_david', 'p_gen9_clara');\n    addParentChild('p_gen8_sophia', 'p_gen9_clara');",
    "    addParentChild('p_gen8_richard', 'p_gen9_oliver');\n    addParentChild('p_gen8_richard', 'p_gen9_clara');"
)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated relationship_repository.dart successfully!")

