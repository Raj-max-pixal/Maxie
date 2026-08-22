import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/pets/presentation/providers/pet_provider.dart';
import 'package:maxie_mobile/features/pets/data/models/pet_model.dart';
import 'package:maxie_mobile/features/shared/widgets/glass_card.dart';

class PetShopScreen extends ConsumerWidget {
  const PetShopScreen({super.key});

  static const List<Map<String, dynamic>> _availablePets = [
    {'type': PetType.maxie, 'emoji': '🤖', 'desc': 'Your intelligent AI companion', 'price': 0},
    {'type': PetType.cat, 'emoji': '🐱', 'desc': 'A lazy but lovable feline friend', 'price': 100},
    {'type': PetType.dog, 'emoji': '🐶', 'desc': 'A loyal and energetic pup', 'price': 150},
    {'type': PetType.panda, 'emoji': '🐼', 'desc': 'A sleepy cuddly bear', 'price': 200},
    {'type': PetType.fox, 'emoji': '🦊', 'desc': 'A curious clever trickster', 'price': 250},
    {'type': PetType.rabbit, 'emoji': '🐰', 'desc': 'A playful hoppy friend', 'price': 150},
    {'type': PetType.penguin, 'emoji': '🐧', 'desc': 'A funny waddling pal', 'price': 200},
    {'type': PetType.dragon, 'emoji': '🐉', 'desc': 'A brave fiery protector', 'price': 500},
    {'type': PetType.slime, 'emoji': '🫧', 'desc': 'A bouncy calm blob', 'price': 100},
    {'type': PetType.robot, 'emoji': '🤖', 'desc': 'A logical mechanical friend', 'price': 300},
    {'type': PetType.capybara, 'emoji': '🐹', 'desc': 'A chill relaxed buddy', 'price': 200},
    {'type': PetType.axolotl, 'emoji': '🦎', 'desc': 'A cute sassy water friend', 'price': 250},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final petsState = ref.watch(petEngineProvider);
    final ownedTypes = petsState.pets.map((p) => p.type).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Shop'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.amber.shade600),
                const SizedBox(width: 4),
                Text(
                  '${petsState.coins}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _availablePets.length,
        itemBuilder: (context, index) {
          final pet = _availablePets[index];
          final type = pet['type'] as PetType;
          final isOwned = ownedTypes.contains(type);
          final price = pet['price'] as int;
          final canAfford = petsState.coins >= price;

          return GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pet['emoji'] as String,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    petTypeName(type),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pet['desc'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  if (isOwned)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Owned ✓',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: canAfford
                            ? () async {
                                await ref.read(petEngineProvider.notifier).addPet(type);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${petTypeName(type)} adopted! 🎉'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.monetization_on, size: 16, color: Colors.amber.shade600),
                            const SizedBox(width: 4),
                            Text('$price'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String petTypeName(PetType type) {
    switch (type) {
      case PetType.maxie: return 'MAXie';
      case PetType.cat: return 'Cat';
      case PetType.dog: return 'Dog';
      case PetType.panda: return 'Panda';
      case PetType.fox: return 'Fox';
      case PetType.rabbit: return 'Rabbit';
      case PetType.penguin: return 'Penguin';
      case PetType.dragon: return 'Dragon';
      case PetType.slime: return 'Slime';
      case PetType.robot: return 'Robot';
      case PetType.capybara: return 'Capybara';
      case PetType.axolotl: return 'Axolotl';
    }
  }
}