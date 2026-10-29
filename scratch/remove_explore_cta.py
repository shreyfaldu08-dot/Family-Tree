file_path = 'lib/features/dashboard/presentation/dashboard_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Remove call from build method
call_target = """              const SizedBox(height: 24),

              // =============================================================
              // 6. BIG CTA BUTTON: EXPLORE ALL ANCESTORS
              // =============================================================
              _buildExploreAncestorsCta(context),"""

if call_target in content:
    content = content.replace(call_target, "")
    print("Removed _buildExploreAncestorsCta call")
else:
    print("WARNING: call_target not found!")

# 2. Remove method definition
method_start = "  // ---------------------------------------------------------------------------\n  // 6. Big CTA Button: Explore All Documented Ancestors (Luxury Dusk Blue Banner)\n  // ---------------------------------------------------------------------------\n  Widget _buildExploreAncestorsCta(BuildContext context) {"
method_end = "\n}\n\n\n// ---------------------------------------------------------------------------"

start_idx = content.find(method_start)
end_idx = content.find(method_end)

if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + content[end_idx:]
    print("Removed _buildExploreAncestorsCta method definition")
else:
    print(f"WARNING: method indices not found: start_idx={start_idx}, end_idx={end_idx}")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated dashboard_screen.dart successfully!")

