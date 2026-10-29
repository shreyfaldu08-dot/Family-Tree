with open('lib/features/dashboard/presentation/dashboard_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Update _buildSingleViewerCard radius 22 -> 26
old_single_section = """  Widget _buildSingleViewerCard({
    required BuildContext context,
    required Person viewer,
  }) {
    return InkWell(
      onTap: () => context.push('/people/${viewer.id}'),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 205,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          color: AppColors.primary,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Full cover portrait of Sara Wilson
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                viewer.effectivePortraitAsset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1B3D6A),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white54, size: 54),
                  ),
                ),
              ),
            ),

            // 2. Cinematic Dual Gradient for Luxury Depth & Text Legibility
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 0.65, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.transparent,
                    const Color(0xFF0F223D).withOpacity(0.55),
                    const Color(0xFF0B192C).withOpacity(0.92),
                  ],
                ),
              ),
            ),

            // 3. Inset Hairline Border for Premium Finish
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.22), width: 0.9),
              ),
            ),"""

new_single_section = """  Widget _buildSingleViewerCard({
    required BuildContext context,
    required Person viewer,
  }) {
    return InkWell(
      onTap: () => context.push('/people/${viewer.id}'),
      borderRadius: BorderRadius.circular(26),
      child: Container(
        height: 205,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          color: AppColors.primary,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Full cover portrait of Sara Wilson
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Image.asset(
                viewer.effectivePortraitAsset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1B3D6A),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white54, size: 54),
                  ),
                ),
              ),
            ),

            // 2. Cinematic Dual Gradient for Luxury Depth & Text Legibility
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 0.65, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.transparent,
                    const Color(0xFF0F223D).withOpacity(0.55),
                    const Color(0xFF0B192C).withOpacity(0.92),
                  ],
                ),
              ),
            ),

            // 3. Inset Hairline Border for Premium Finish
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withOpacity(0.22), width: 0.9),
              ),
            ),"""

assert old_single_section in text, "old_single_section not found"
text = text.replace(old_single_section, new_single_section)
print("Updated _buildSingleViewerCard")

# 2. Update _buildBentoPersonCard
old_bento = """  Widget _buildBentoPersonCard({
    required BuildContext context,
    required String rolePill,
    required String name,
    required String subtitle,
    required String imageAsset,
    required VoidCallback onTap,
    Widget? topTrailingWidget,
    double height = 155,
    double? width,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.14),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
          color: AppColors.primary,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1B3D6A),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white54, size: 36),
                  ),
                ),
              ),
            ),

            // Smooth dark gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.transparent,
                    const Color(0xFF0B192C).withOpacity(0.9),
                  ],
                ),
              ),
            ),

            // Inset hairline border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.18), width: 0.9),
              ),
            ),

            // 1. Role Pill Badge (Top Left)
            Positioned(
              top: 8,
              left: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.24),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white.withOpacity(0.28), width: 0.6),
                    ),
                    child: Text(
                      rolePill,
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Top Trailing Action or Circular Arrow Button (Top Right)
            Positioned(
              top: 7,
              right: 7,
              child: topTrailingWidget ??
                  Container(
                    width: 23,
                    height: 23,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
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
                      size: 12.5,
                      color: AppColors.primary,
                    ),
                  ),
            ),

            // 3. Text Content (Full Bottom Width - No Clipping)
            Positioned(
              left: 8,
              bottom: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
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
                      fontSize: 9.2,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.88),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }"""

new_bento = """  Widget _buildBentoPersonCard({
    required BuildContext context,
    required String rolePill,
    required String name,
    required String subtitle,
    required String imageAsset,
    required VoidCallback onTap,
    Widget? topTrailingWidget,
    double height = 155,
    double? width,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.14),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
          color: AppColors.primary,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1B3D6A),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white54, size: 36),
                  ),
                ),
              ),
            ),

            // Smooth dark gradient overlay for deep contrast & readability
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.transparent,
                    const Color(0xFF0B192C).withOpacity(0.92),
                  ],
                ),
              ),
            ),

            // Inset hairline border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.18), width: 0.9),
              ),
            ),

            // 1. Role Pill Badge (Top Left)
            Positioned(
              top: 8,
              left: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.24),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.28), width: 0.6),
                    ),
                    child: Text(
                      rolePill,
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Top Trailing Action or Circular Arrow Button (Top Right)
            Positioned(
              top: 8,
              right: 8,
              child: topTrailingWidget ??
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.94),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 4,
                          offset: const Offset(0, 1.5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                  ),
            ),

            // 3. Text Content (Full Bottom Width - Natural 2-Line Flow)
            Positioned(
              left: 8,
              bottom: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.15,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 9.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.88),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }"""

assert old_bento in text, "old_bento not found"
text = text.replace(old_bento, new_bento)
print("Updated _buildBentoPersonCard")

# 3. Update _buildAnnualGatheringCard completely
old_gathering = """  Widget _buildAnnualGatheringCard(BuildContext context) {
    return Container(
      height: 164,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background photo
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/family_gathering.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF1B3D6A),
                child: const Center(
                  child: Icon(Icons.people_rounded, size: 40, color: Colors.white54),
                ),
              ),
            ),
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 1.0],
                colors: [
                  Colors.black.withOpacity(0.35),
                  const Color(0xFF0F223D).withOpacity(0.55),
                  const Color(0xFF0B192C).withOpacity(0.92),
                ],
              ),
            ),
          ),

          // Inset hairline border
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Tag & Days Countdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.6),
                          ),
                          child: Text(
                            'ANNUAL REUNION • SUMMER 2026',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: HeritageCurves.pill,
                      ),
                      child: Text(
                        'IN 82 DAYS',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom Content Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Kensington Family Gathering 2026',
                            style: GoogleFonts.poppins(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'July 18 – 20 • Lakeview Estate Grounds, WA',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.88),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildMiniAvatar('assets/images/user_sara_portrait.jpg'),
                              Transform.translate(
                                offset: const Offset(-6, 0),
                                child: _buildMiniAvatar('assets/images/modern_father.jpg'),
                              ),
                              Transform.translate(
                                offset: const Offset(-12, 0),
                                child: _buildMiniAvatar('assets/images/vintage_lady_portrait.jpg'),
                              ),
                              Transform.translate(
                                offset: const Offset(-18, 0),
                                child: _buildMiniAvatar('assets/images/modern_young_man.jpg'),
                              ),
                              Transform.translate(
                                offset: const Offset(-12, 0),
                                child: Text(
                                  '+14 attending',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: HeritageCurves.pill),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reunion RSVP: You are registered as attending!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'RSVP',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, size: 13, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }"""

new_gathering = """  Widget _buildAnnualGatheringCard(BuildContext context) {
    return Container(
      height: 196,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background photo
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Image.asset(
              'assets/images/family_gathering.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF1B3D6A),
                child: const Center(
                  child: Icon(Icons.people_rounded, size: 40, color: Colors.white54),
                ),
              ),
            ),
          ),

          // 2. Cinematic Gradient overlay for depth & readability
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.40, 1.0],
                colors: [
                  Colors.black.withOpacity(0.35),
                  const Color(0xFF0F223D).withOpacity(0.60),
                  const Color(0xFF0A1728).withOpacity(0.95),
                ],
              ),
            ),
          ),

          // 3. Inset hairline border for premium finish
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withOpacity(0.22), width: 0.9),
            ),
          ),

          // 4. Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag & Days Countdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.28), width: 0.6),
                          ),
                          child: Text(
                            'ANNUAL REUNION • SUMMER 2026',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: HeritageCurves.pill,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        'IN 82 DAYS',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Middle: Title & Subtitle (Full width, no horizontal squeeze)
                Text(
                  'Kensington Family Gathering',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'July 18 – 20, 2026 • Lakeview Estate Grounds, WA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.88),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),

                // Bottom Row: Avatars on Left, RSVP Pill Button on Right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 58,
                          height: 24,
                          child: Stack(
                            children: [
                              Positioned(left: 0, child: _buildMiniAvatar('assets/images/user_sara_portrait.jpg')),
                              Positioned(left: 14, child: _buildMiniAvatar('assets/images/modern_father.jpg')),
                              Positioned(left: 28, child: _buildMiniAvatar('assets/images/modern_young_man.jpg')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '+14 attending',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.92),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reunion RSVP: You are registered as attending!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'RSVP',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }"""

assert old_gathering in text, "old_gathering not found"
text = text.replace(old_gathering, new_gathering)
print("Updated _buildAnnualGatheringCard")

# 4. Update Milestone card radius from 16 to 22
text = text.replace(
    'borderRadius: BorderRadius.circular(16),\n        border: Border.all(color: AppColors.border, width: 0.9),',
    'borderRadius: BorderRadius.circular(22),\n        border: Border.all(color: AppColors.border, width: 0.9),'
)
print("Updated Milestone card radius")

# 5. Update Shared vault feed radius from 18 to 24
text = text.replace(
    'borderRadius: BorderRadius.circular(18),\n        border: Border.all(color: AppColors.border, width: 0.9),\n        boxShadow: HeritageShadows.card,\n      ),\n      child: Column(\n        children: [\n          // Item 1: Audio Note',
    'borderRadius: BorderRadius.circular(24),\n        border: Border.all(color: AppColors.border, width: 0.9),\n        boxShadow: HeritageShadows.card,\n      ),\n      child: Column(\n        children: [\n          // Item 1: Audio Note'
)
print("Updated Shared vault feed radius")

# 6. Update Explore Ancestors CTA radius from 20 to 26
text = text.replace(
    'borderRadius: BorderRadius.circular(20),\n          gradient: const LinearGradient(\n            begin: Alignment.topLeft,\n            end: Alignment.bottomRight,\n            colors: [\n              AppColors.primary,',
    'borderRadius: BorderRadius.circular(26),\n          gradient: const LinearGradient(\n            begin: Alignment.topLeft,\n            end: Alignment.bottomRight,\n            colors: [\n              AppColors.primary,'
)
text = text.replace(
    'return InkWell(\n      onTap: () => context.push(\'/tree\'),\n      borderRadius: BorderRadius.circular(20),',
    'return InkWell(\n      onTap: () => context.push(\'/tree\'),\n      borderRadius: BorderRadius.circular(26),'
)
print("Updated Explore Ancestors CTA radius")

# 7. Update Heritage Overview (3-metric summary) radius from 18 to 22
text = text.replace(
    'borderRadius: BorderRadius.circular(18),\n        border: Border.all(color: AppColors.border, width: 0.9),\n        boxShadow: HeritageShadows.card,\n      ),\n      child: Row(\n        children: [\n          Expanded(\n            child: _buildCompactMetricItem(',
    'borderRadius: BorderRadius.circular(22),\n        border: Border.all(color: AppColors.border, width: 0.9),\n        boxShadow: HeritageShadows.card,\n      ),\n      child: Row(\n        children: [\n          Expanded(\n            child: _buildCompactMetricItem('
)
print("Updated Heritage Overview radius")

with open('lib/features/dashboard/presentation/dashboard_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("ALL UPDATES COMPLETED SUCCESSFULLY!")
