file_path = 'lib/features/dashboard/presentation/dashboard_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Remove the call in _buildFamilyConnectionSection
call_target = """        const SizedBox(height: 14),

        // Subsection 4: Ancestral Origins & 246-Year Migration Journey (Card 2)
        _buildAncestralOriginsAndMigrationCard(context),"""

if call_target in content:
    content = content.replace(call_target, "")
    print("Removed call to _buildAncestralOriginsAndMigrationCard")
else:
    print("WARNING: call_target not found!")

# 2. Remove the methods _buildAncestralOriginsAndMigrationCard and _buildMigrationStopItem
method_start = "  // ---------------------------------------------------------------------------\n  // Card 2: Ancestral Origins & 246-Year Migration Journey"
method_end = "  // ---------------------------------------------------------------------------\n  // 6. Big CTA Button: Explore All Documented Ancestors (Luxury Dusk Blue Banner)"

start_idx = content.find(method_start)
end_idx = content.find(method_end)

if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + content[end_idx:]
    print("Removed methods _buildAncestralOriginsAndMigrationCard and _buildMigrationStopItem")
else:
    print(f"WARNING: method indices not found: start_idx={start_idx}, end_idx={end_idx}")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Finished updating dashboard_screen.dart")

