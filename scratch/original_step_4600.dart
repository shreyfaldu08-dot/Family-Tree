  // ---------------------------------------------------------------------------
  // 5. Featured Navy Milestone Card (Screen 1 Appointment Style)
  // ---------------------------------------------------------------------------
  Widget _buildUpcomingMilestoneCard(
    BuildContext context,
    AsyncValue<List<dynamic>> eventsAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Family Milestone',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textOnDarkSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '08',
                  style: GoogleFonts.poppins(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'May 2026, Thursday',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '10:30 AM • Annual Heritage Gathering',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textOnDarkSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Image.asset(
                'assets/images/vintage_heirloom.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.auto_stories,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }