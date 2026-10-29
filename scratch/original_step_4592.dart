  // ---------------------------------------------------------------------------
  // 3. Iconic Bento Heritage Cards (Founding Patriarch + Vault & Matriarchs + Custodians)
  // ---------------------------------------------------------------------------
  Widget _buildBentoHeritageSection(
    BuildContext context,
    AsyncValue<List<Person>> personsAsync,
  ) {
    final allPersons = personsAsync.valueOrNull ?? [];
    final patriarch = allPersons.where((p) => p.generationHint == 1).firstOrNull ?? allPersons.firstOrNull;
    final matriarch = allPersons.where((p) => p.gender == Gender.female).firstOrNull ?? allPersons.firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Heritage Highlights',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            InkWell(
              onTap: () => context.push('/people'),
              child: Text(
                'Explore All →',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Large Featured Bento Card (Founding Patriarch)
        InkWell(
          onTap: () {
            if (patriarch != null) {
              context.push('/people/${patriarch.id}');
            } else {
              context.push('/tree');
            }
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: 195,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: HeritageShadows.card,
              color: AppColors.primary,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Portrait Photograph of Archibald
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    'assets/images/archibald_portrait.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF1E2E48),
                      child: const Center(
                        child: Icon(Icons.person, color: Colors.white54, size: 54),
                      ),
                    ),
                  ),
                ),

                // Smooth dark gradient overlay for text legibility
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.82),
                      ],
                    ),
                  ),
                ),

                // Card Text Content
                Positioned(
                  left: 18,
                  bottom: 18,
                  right: 70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ROOT ANCESTOR',
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Founding Patriarch',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Generation 1 • Sir Archibald Vansora (1842)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.88),
                        ),
                      ),
                    ],
                  ),
                ),

                // White Round Arrow Button
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 19,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Split 2-Card Row: Vault Documents & Matriarchs
        Row(
          children: [
            // Left Card: Living Vault & Documents
            Expanded(
              child: InkWell(
                onTap: () => context.push('/archive'),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 155,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: HeritageShadows.card,
                    color: const Color(0xFF2C3E50),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/vintage_vault_documents.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF34495E),
                            child: const Icon(Icons.inventory_2_outlined, color: Colors.white54, size: 36),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.82),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        bottom: 14,
                        right: 48,
                        child: Text(
                          'Living Vault &\nDocuments',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Container(
                          width: 32,
                          height: 32,
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Right Card: Pillars & Matriarchs
            Expanded(
              child: InkWell(
                onTap: () {
                  if (matriarch != null) {
                    context.push('/people/${matriarch.id}');
                  } else {
                    context.push('/people');
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 155,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: HeritageShadows.card,
                    color: const Color(0xFF1E2A38),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/matriarch_portrait.jpg',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF2A3A4D),
                            child: const Icon(Icons.person, color: Colors.white54, size: 36),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.82),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        bottom: 14,
                        right: 48,
                        child: Text(
                          'Pillars &\nMatriarchs',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Container(
                          width: 32,
                          height: 32,
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Bottom Bento Bar: "Branch Custodians & Archivists" with 3 overlapping avatars
        InkWell(
          onTap: () => context.push('/people'),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD4E3FA), width: 1.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Branch Custodians & Archivists',
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '3 active lineage stewards managing records',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Overlapping Stack of 3 Circular Avatar Photos
                SizedBox(
                  width: 72,
                  height: 36,
                  child: Stack(
                    children: [
                      // Avatar 1: David (Chief Steward)
                      Positioned(
                        left: 0,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Image.asset(
                              'assets/images/modern_father.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // Avatar 2: Sara (Archivist)
                      Positioned(
                        left: 18,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Image.asset(
                              'assets/images/user_sara_portrait.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // Avatar 3: Lucas (Genealogy Steward)
                      Positioned(
                        left: 36,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Image.asset(
                              'assets/images/modern_young_man.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
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
              ],
            ),
          ),
        ),
      ],
    );
  }