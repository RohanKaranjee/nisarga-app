import 'package:flutter/material.dart';
import '../../widgets/gradient_header.dart';
import '../../../core/theme/app_colors.dart';

class HomeRemediesScreen extends StatefulWidget {
  const HomeRemediesScreen({super.key});

  @override
  State<HomeRemediesScreen> createState() => _HomeRemediesScreenState();
}

class _HomeRemediesScreenState extends State<HomeRemediesScreen> {
  int? _expandedIndex;

  final List<Map<String, dynamic>> _remedies = [
    {
      "title": "Cinnamon Tea",
      "category": "Cycle Regulation",
      "description": "Helps regulate menstrual cycles and reduce heavy bleeding",
      "ingredients": ["1 tsp cinnamon powder", "1 cup hot water", "Honey (optional)"],
      "preparation": "Mix cinnamon powder in hot water. Let it steep for 5 minutes. Add honey if desired. Drink once daily.",
      "benefits": "Regulates insulin, reduces inflammation",
      "precautions": "Avoid if allergic to cinnamon. Consult doctor if pregnant."
    },
    {
      "title": "Ginger Tea",
      "category": "Cramp Relief",
      "description": "Natural pain reliever for menstrual cramps",
      "ingredients": ["1 inch fresh ginger", "1 cup water", "Lemon juice", "Honey"],
      "preparation": "Boil ginger in water for 10 minutes. Strain and add lemon and honey. Drink warm.",
      "benefits": "Reduces inflammation, relieves pain",
      "precautions": "May interact with blood thinners."
    },
    {
      "title": "Fenugreek Seeds",
      "category": "Hormonal Balance",
      "description": "Helps balance hormones and regulate periods",
      "ingredients": ["1 tsp fenugreek seeds", "1 cup water"],
      "preparation": "Soak seeds overnight. Drink the water in the morning on empty stomach.",
      "benefits": "Regulates hormones, improves insulin sensitivity",
      "precautions": "May cause stomach upset initially."
    },
    {
      "title": "Turmeric Milk",
      "category": "Anti-inflammatory",
      "description": "Reduces inflammation and balances hormones",
      "ingredients": ["1/2 tsp turmeric powder", "1 cup warm milk", "Pinch of black pepper", "Honey"],
      "preparation": "Mix turmeric and black pepper in warm milk. Add honey. Drink before bed.",
      "benefits": "Anti-inflammatory, antioxidant",
      "precautions": "Safe for most people."
    },
    {
      "title": "Flaxseed",
      "category": "Hormonal Balance",
      "description": "Rich in omega-3 and helps with hormone regulation",
      "ingredients": ["1-2 tbsp ground flaxseed", "Water or smoothie"],
      "preparation": "Add ground flaxseed to your breakfast, smoothie, or yogurt daily.",
      "benefits": "Regulates estrogen, improves insulin sensitivity",
      "precautions": "Drink plenty of water."
    },
    {
      "title": "Apple Cider Vinegar",
      "category": "PCOS Management",
      "description": "Helps improve insulin sensitivity",
      "ingredients": ["1 tbsp apple cider vinegar", "1 cup water", "Honey (optional)"],
      "preparation": "Dilute ACV in water. Drink before meals twice daily.",
      "benefits": "Improves insulin response, aids weight loss",
      "precautions": "Always dilute. May damage tooth enamel."
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Remedies')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const GradientHeader(
              icon: Icons.spa_outlined,
              title: 'Home Remedies',
              subtitle: 'Natural solutions for menstrual health',
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Note: These remedies are complementary and should not replace medical treatment. Consult your doctor before trying new remedies.',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _remedies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final remedy = _remedies[index];
                final isExpanded = _expandedIndex == index;
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: Key(index.toString()),
                      initiallyExpanded: isExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _expandedIndex = expanded ? index : null;
                        });
                      },
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(remedy['category'], style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                          ),
                          const SizedBox(height: 8),
                          Text(remedy['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(remedy['description'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 8),
                              ...(remedy['ingredients'] as List<String>).map((i) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.circle, size: 6, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(i, style: const TextStyle(fontSize: 12, color: Colors.black87))),
                                  ],
                                ),
                              )),
                              const SizedBox(height: 16),
                              
                              const Text('Preparation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 8),
                              Text(remedy['preparation'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 16),
                              
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Benefits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(remedy['benefits'], style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Precautions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber)),
                                    const SizedBox(height: 4),
                                    Text(remedy['precautions'], style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('General Lifestyle Tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildTipListTile('Stay hydrated - drink 8-10 glasses of water daily'),
                  _buildTipListTile('Regular exercise for at least 30 minutes daily'),
                  _buildTipListTile('Maintain consistent sleep schedule (7-9 hours)'),
                  _buildTipListTile('Practice stress management through yoga or meditation'),
                  _buildTipListTile('Maintain a balanced diet rich in whole foods'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTipListTile(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Icon(Icons.circle, size: 8, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14))),
        ],
      ),
    );
  }
}
