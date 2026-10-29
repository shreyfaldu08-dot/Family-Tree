file_path = r'c:\Users\BAPS\Desktop\application 2\lib\features\dashboard\presentation\dashboard_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add _siblingPageController and _siblingPageIndex to _DashboardScreenState
target_state = """class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasSpouse = false;
  bool _isGenerationsExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }"""

replacement_state = """class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final PageController _siblingPageController = PageController();
  int _siblingPageIndex = 0;
  bool _hasSpouse = false;
  bool _isGenerationsExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _siblingPageController.dispose();
    super.dispose();
  }"""

assert target_state in content, "target_state not found"
content = content.replace(target_state, replacement_state)
print("Step 1: State variables added")

# 2. Update _buildBentoPersonCard text/arrow positioning for perfect 3-in-a-row display
target_bento_bottom = """            // Text Content (Bottom Left)
            Positioned(
              left: 12,
              bottom: 12,
              right: 44,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.6),
                        ),
                        child: Text(
                          rolePill,
                          style: GoogleFonts.inter(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),

            // Round White Arrow Button (Bottom Right)
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
              ),
            ),"""

replacement_bento_bottom = """            // Text Content (Bottom Left)
            Positioned(
              left: 9,
              bottom: 9,
              right: 34,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.6),
                        ),
                        child: Text(
                          rolePill,
                          style: GoogleFonts.inter(
                            fontSize: 7.8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3.5),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 9.2,
                      color: Colors.white.withOpacity(0.88),
                    ),
                  ),
                ],
              ),
            ),

            // Round White Arrow Button (Bottom Right)
            Positioned(
              right: 7,
              bottom: 7,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 13,
                  color: AppColors.primary,
                ),
              ),
            ),"""

assert target_bento_bottom in content, "target_bento_bottom not found"
content = content.replace(target_bento_bottom, replacement_bento_bottom)
print("Step 2: Bento card bottom updated")

# 3. Replace _buildSiblingsRibbon, _buildAddPersonCard, and _showAddMemberModal
target_siblings_and_add = """  // ---------------------------------------------------------------------------
  // Siblings Ribbon (Option A: Full-Size Bento Cards in Horizontal Ribbon)
  // ---------------------------------------------------------------------------
  Widget _buildSiblingsRibbon(BuildContext context, List<Person> siblings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'My Siblings',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.paleBlue,
                    borderRadius: HeritageCurves.pill,
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Text(
                    'BROTHERS & SISTERS • GEN 9',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '${siblings.length} ${siblings.length == 1 ? "Sibling" : "Siblings"}',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 155,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: siblings.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index < siblings.length) {
                final sib = siblings[index];
                final rolePill = sib.gender == Gender.female ? 'SISTER' : 'BROTHER';
                return _buildBentoPersonCard(
                  context: context,
                  rolePill: rolePill,
                  name: sib.displayName,
                  subtitle: sib.lifeDateSpan,
                  imageAsset: sib.effectivePortraitAsset,
                  width: 165,
                  height: 155,
                  onTap: () => context.push('/people/${sib.id}'),
                );
              } else {
                return _buildAddPersonCard(
                  label: 'Add Sibling',
                  subtitle: 'Generation 9',
                  width: 165,
                  height: 155,
                  onTap: () => _showAddMemberModal(context, generation: 9, role: 'Sibling'),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Reusable Add Person Card (Matches 165x155 Bento Card dimensions)
  // ---------------------------------------------------------------------------
  Widget _buildAddPersonCard({
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    double width = 165,
    double height = 155,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.32),
            width: 1.2,
          ),
          boxShadow: HeritageShadows.card,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.paleBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 24,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Modal Sheet for Adding a New Family Member
  // ---------------------------------------------------------------------------
  void _showAddMemberModal(
    BuildContext context, {
    required int generation,
    required String role,
  }) {
    final nameCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add $role to Family Lineage',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Generation $generation • Living Heritage Archive',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Full Name (e.g. Leo Kensington)',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  Navigator.pop(ctx);
                  if (name.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added $name as $role (Gen $generation)'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                },
                child: Text(
                  'Save to Lineage',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }"""

replacement_siblings = """  // ---------------------------------------------------------------------------
  // Siblings Ribbon (Exactly 3 properly visible per page, no cut-off, with dots when > 3)
  // ---------------------------------------------------------------------------
  Widget _buildSiblingsRibbon(BuildContext context, List<Person> siblings) {
    // Chunk siblings into pages of max 3 items
    final pages = <List<Person>>[];
    for (var i = 0; i < siblings.length; i += 3) {
      final end = (i + 3 > siblings.length) ? siblings.length : i + 3;
      pages.add(siblings.sublist(i, end));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'My Siblings',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.paleBlue,
                    borderRadius: HeritageCurves.pill,
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Text(
                    'BROTHERS & SISTERS • GEN 9',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '${siblings.length} ${siblings.length == 1 ? "Sibling" : "Siblings"}',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (pages.length <= 1)
          // 3 or fewer siblings: Exactly 3 visible across width, no half cut, no scroll
          Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                if (pages.isNotEmpty && i < pages[0].length)
                  Expanded(
                    child: _buildBentoPersonCard(
                      context: context,
                      rolePill: pages[0][i].gender == Gender.female ? 'SISTER' : 'BROTHER',
                      name: pages[0][i].displayName,
                      subtitle: pages[0][i].lifeDateSpan,
                      imageAsset: pages[0][i].effectivePortraitAsset,
                      height: 155,
                      onTap: () => context.push('/people/${pages[0][i].id}'),
                    ),
                  )
                else
                  const Expanded(child: SizedBox.shrink()),
                if (i < 2) const SizedBox(width: 8),
              ],
            ],
          )
        else
          // More than 3 siblings: PageView where each page shows exactly 3 max, with dot pagination below
          Column(
            children: [
              SizedBox(
                height: 155,
                child: PageView.builder(
                  controller: _siblingPageController,
                  itemCount: pages.length,
                  onPageChanged: (idx) {
                    setState(() {
                      _siblingPageIndex = idx;
                    });
                  },
                  itemBuilder: (context, pageIndex) {
                    final pageItems = pages[pageIndex];
                    return Row(
                      children: [
                        for (int i = 0; i < 3; i++) ...[
                          if (i < pageItems.length)
                            Expanded(
                              child: _buildBentoPersonCard(
                                context: context,
                                rolePill: pageItems[i].gender == Gender.female ? 'SISTER' : 'BROTHER',
                                name: pageItems[i].displayName,
                                subtitle: pageItems[i].lifeDateSpan,
                                imageAsset: pageItems[i].effectivePortraitAsset,
                                height: 155,
                                onTap: () => context.push('/people/${pageItems[i].id}'),
                              ),
                            )
                          else
                            const Expanded(child: SizedBox.shrink()),
                          if (i < 2) const SizedBox(width: 8),
                        ],
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Dots below so user can see another page properly
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pages.length, (idx) {
                  final isCurrent = idx == _siblingPageIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isCurrent ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ],
          ),
      ],
    );
  }"""

assert target_siblings_and_add in content, "target_siblings_and_add not found"
content = content.replace(target_siblings_and_add, replacement_siblings)
print("Step 3: Siblings ribbon updated with 3-per-page & dots, Add Sibling removed")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("All updates written successfully!")

