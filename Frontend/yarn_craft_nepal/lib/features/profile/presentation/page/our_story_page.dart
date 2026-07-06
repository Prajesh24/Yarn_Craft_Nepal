import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OurStoryPage extends ConsumerWidget {
  const OurStoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // SliverAppBar with hero image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF111827),
                  size: 20,
                ),
              ),
            ),
            title: const Text(
              'YarnCraft Nepal',
              style: TextStyle(
                color: Color(0xFF1B6B61),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background — "Bridging the Gap" hero image
                  Image.asset(
                    'assets/images/bridging_gap_bg.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
                        ),
                      ),
                    ),
                  ),
                  // Dark overlay so the title stays readable
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.25),
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                  // Overlay text at bottom-left
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Bridging the\nGap',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'From traditional loom to modern living room.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Our Heritage
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Text(
                    'Our Heritage',
                    style: TextStyle(
                      color: Color(0xFF1B6B61),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'At YarnCraft Nepal, we believe in the profound connection between the maker '
                    'and the material. For generations, Nepali artisans have woven stories into '
                    'fabric, using techniques passed down through centuries.\n\n'
                    'Our mission is to preserve this rich heritage while empowering local '
                    'communities through fair trade practices, bringing you textiles that are '
                    'not just beautiful, but deeply meaningful.',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Fair Trade card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B6B61),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.verified_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fair Trade',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Ethical sourcing and fair compensation for every artisan.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Feature cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _FeatureCard(
                    icon: Icons.eco_outlined,
                    title: '100% Natural',
                    subtitle: 'Sourced sustainably from the Himalayas.',
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _FeatureCard(
                    icon: Icons.people_outline,
                    title: 'Community First',
                    subtitle: 'Reinvesting in rural education and healthcare.',
                  ),
                ),

                const SizedBox(height: 32),

                // Stats
                const _StatRow(value: '150+', label: 'MASTER ARTISANS'),
                const Divider(
                  color: Color(0xFFE5E7EB),
                  indent: 20,
                  endIndent: 20,
                ),
                const _StatRow(value: '20', label: 'RURAL COOPERATIVES'),
                const Divider(
                  color: Color(0xFFE5E7EB),
                  indent: 20,
                  endIndent: 20,
                ),
                const _StatRow(value: '100%', label: 'NATURAL FIBERS'),

                const SizedBox(height: 32),

                // Faces of YarnCraft
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Faces of YarnCraft',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const _ArtisanCard(
                  imageAsset: 'assets/images/maya_gurung_bg.png',
                  name: 'Maya Gurung',
                  title: 'MASTER WEAVER, PATAN',
                  quote:
                      '"Every thread I weave carries a prayer for my family. '
                      'This craft is my voice, and through it, I speak to the world."',
                ),

                const SizedBox(height: 16),

                const _ArtisanCard(
                  imageAsset: 'assets/images/rajesh_bg.png',
                  name: 'Rajesh Shrestha',
                  title: 'DYE SPECIALIST, BHAKTAPUR',
                  quote:
                      '"Extracting colors from nature requires patience. '
                      'It\'s a slow process that reminds us to respect '
                      'the earth that provides for us."',
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Feature card

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5F3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF1B6B61), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Stat row

class _StatRow extends StatelessWidget {
  final String value;
  final String label;

  const _StatRow({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1B6B61),
              fontSize: 40,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Artisan card

class _ArtisanCard extends StatelessWidget {
  final String? imageAsset;
  final String name;
  final String title;
  final String quote;

  const _ArtisanCard({
    required this.imageAsset,
    required this.name,
    required this.title,
    required this.quote,
  });

  Widget _placeholder() => Container(
    width: double.infinity,
    height: 200,
    color: const Color(0xFF2C3E50),
    child: const Icon(Icons.person, color: Colors.white54, size: 60),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imageAsset != null
                ? Image.asset(
                    imageAsset!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),

          const SizedBox(height: 14),

          // Name + large quote mark
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '99',
                style: TextStyle(
                  color: Color(0xFFE5E7EB),
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            quote,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
