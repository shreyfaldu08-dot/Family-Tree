with open(r'c:\Users\BAPS\Desktop\application 2\lib\features\dashboard\presentation\dashboard_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Read the 3 original blocks
with open(r'c:\Users\BAPS\Desktop\application 2\scratch\original_step_4592.dart', 'r', encoding='utf-8') as f:
    orig_bento = f.read()

with open(r'c:\Users\BAPS\Desktop\application 2\scratch\original_step_4604.dart', 'r', encoding='utf-8') as f:
    orig_overview = f.read()

with open(r'c:\Users\BAPS\Desktop\application 2\scratch\original_step_4600.dart', 'r', encoding='utf-8') as f:
    orig_milestone = f.read()

# Current bento starts at:
#   // ---------------------------------------------------------------------------
#   // 3. Iconic Bento Heritage Cards (Editorial Exhibition & Archival Register)
#   // ---------------------------------------------------------------------------
# and ends before:
#   // ---------------------------------------------------------------------------
#   // 4. Heritage Overview Card (Screen 1 Pale Blue 3-Metric Summary)

marker_bento_start = '  // ---------------------------------------------------------------------------\n  // 3. Iconic Bento Heritage Cards (Editorial Exhibition & Archival Register)\n  // ---------------------------------------------------------------------------'
marker_overview_start = '  // ---------------------------------------------------------------------------\n  // 4. Heritage Overview Card (Screen 1 Pale Blue 3-Metric Summary)\n  // ---------------------------------------------------------------------------'

if marker_bento_start not in content:
    print("ERROR: marker_bento_start not found!")
    exit(1)

bento_idx = content.index(marker_bento_start)
overview_idx = content.index(marker_overview_start)

# Replace Bento
new_content = content[:bento_idx] + orig_bento.strip() + '\n\n' + content[overview_idx:]

# In Heritage Overview Card, find the container:
marker_curr_overview_container = '''    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.9),
        boxShadow: HeritageShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Heritage Overview',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.paleBlue,
                  borderRadius: HeritageCurves.pill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'All Generations (10)',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),'''

if marker_curr_overview_container in new_content:
    new_content = new_content.replace(marker_curr_overview_container, orig_overview.strip())
    print("Replaced Heritage Overview Card styling successfully!")
else:
    print("WARNING: marker_curr_overview_container not found, checking...")

# Current milestone:
marker_curr_milestone_start = '  // ---------------------------------------------------------------------------\n  // 5. Upcoming Reunion Milestone Card (Clean Calendar Event Architecture)\n  // ---------------------------------------------------------------------------'
marker_quick_nav_start = '  // ---------------------------------------------------------------------------\n  // 6. Quick Access Navigation (4 Circular Action Buttons)\n  // ---------------------------------------------------------------------------'

if marker_curr_milestone_start in new_content and marker_quick_nav_start in new_content:
    ms_idx = new_content.index(marker_curr_milestone_start)
    qn_idx = new_content.index(marker_quick_nav_start)
    new_content = new_content[:ms_idx] + orig_milestone.strip() + '\n\n' + new_content[qn_idx:]
    print("Replaced Upcoming Milestone Card successfully!")
else:
    print("ERROR: Milestone markers not found!")
    exit(1)

with open(r'c:\Users\BAPS\Desktop\application 2\lib\features\dashboard\presentation\dashboard_screen.dart', 'w', encoding='utf-8') as f:
    f.write(new_content)

print("dashboard_screen.dart reverted successfully!")
