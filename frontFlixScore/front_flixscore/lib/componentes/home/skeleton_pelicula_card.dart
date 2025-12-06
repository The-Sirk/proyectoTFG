import 'package:flutter/material.dart';

/// Widget que muestra un skeleton loader mientras se cargan las tarjetas de películas
class SkeletonPeliculaCard extends StatefulWidget {
  const SkeletonPeliculaCard({super.key});

  @override
  State<SkeletonPeliculaCard> createState() => _SkeletonPeliculaCardState();
}

class _SkeletonPeliculaCardState extends State<SkeletonPeliculaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del póster skeleton
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(_animation.value * 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.movie,
                    size: 64,
                    color: Colors.white.withOpacity(_animation.value * 0.2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título skeleton
                    Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(_animation.value * 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtítulo skeleton
                    Container(
                      height: 16,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(_animation.value * 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Rating skeleton
                    Row(
                      children: [
                        Container(
                          height: 24,
                          width: 60,
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(_animation.value * 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 16,
                          width: 100,
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(_animation.value * 0.1),
                            borderRadius: BorderRadius.circular(4),
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
      },
    );
  }
}

/// Widget que muestra múltiples skeletons en un grid o lista
class SkeletonPeliculasList extends StatelessWidget {
  final bool esMovil;
  final int cantidad;

  const SkeletonPeliculasList({
    super.key,
    this.esMovil = true,
    this.cantidad = 6,
  });

  @override
  Widget build(BuildContext context) {
    if (esMovil) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: cantidad,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: SkeletonPeliculaCard(),
          );
        },
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: List.generate(
            cantidad,
            (index) => SizedBox(
              width: (MediaQuery.of(context).size.width - 100) / 3,
              child: const SkeletonPeliculaCard(),
            ),
          ),
        ),
      );
    }
  }
}
