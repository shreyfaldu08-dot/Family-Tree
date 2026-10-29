path = r'lib/features/dashboard/presentation/dashboard_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read().replace('\r\n', '\n')

old_bento_stack = """            // Optional top trailing widget (e.g. remove spouse button)
            if (topTrailingWidget != null)
              Positioned(
                top: 10,
                right: 10,
                child: topTrailingWidget,
              ),

            // Text Content (Bottom Left)
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

new_bento_stack = """            // 1. Role Pill Badge (Top Left)
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
            ),"""

assert old_bento_stack in content, "old_bento_stack not found"
content = content.replace(old_bento_stack, new_bento_stack)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Bento card stack updated successfully!")

