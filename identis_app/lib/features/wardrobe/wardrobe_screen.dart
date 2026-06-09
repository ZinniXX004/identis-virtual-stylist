import 'package:flutter/material.dart';
import '../../core/theme.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  // --- 1. STATE KATEGORI & FILTER ---
  final List<String> categories = ["Semua", "Atasan", "Bawahan", "Outer", "Sepatu"];
  String selectedCategory = "Semua";
  
  List<String> selectedColors = [];
  List<String> selectedUsages = [];
  
  final List<Map<String, dynamic>> availableColors = [
    {"name": "Hitam", "color": Colors.black}, {"name": "Putih", "color": Colors.white},
    {"name": "Biru", "color": Colors.blue}, {"name": "Merah", "color": Colors.red},
    {"name": "Krem", "color": Colors.brown.shade200}, {"name": "Hijau", "color": Colors.green.shade900},
  ];
  final List<String> availableUsages = ["Sering Dipakai", "Lumayan", "Jarang"];

  // --- 2. DATA LEMARI (Gambar Nyata) ---
  final List<Map<String, dynamic>> userClothes = [
    {
      "name": "Kaos Hitam Basic", "type": "Atasan", "color": Colors.black, "colorName": "Hitam", 
      "usage": "Sering Dipakai", "icon": Icons.checkroom,
      "imageUrl": "https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
      "material": "Katun Combed 30s", "brand": "Uniqlo", "wearCount": 24, "lastWorn": "2 hari yang lalu"
    },
    {
      "name": "Kemeja Flanel Merah", "type": "Atasan", "color": Colors.red, "colorName": "Merah", 
      "usage": "Jarang", "icon": Icons.iron,
      "imageUrl": "https://images.unsplash.com/photo-1598033129183-c4f50c736f10?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
      "material": "Flanel", "brand": "Erigo", "wearCount": 3, "lastWorn": "2 bulan yang lalu"
    },
    {
      "name": "Jeans Denim Biru", "type": "Bawahan", "color": Colors.blue.shade800, "colorName": "Biru", 
      "usage": "Sering Dipakai", "icon": Icons.airline_seat_legroom_extra,
      "imageUrl": "https://images.unsplash.com/photo-1542272604-78044d03be52?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
      "material": "Denim Stretch", "brand": "Levi's", "wearCount": 45, "lastWorn": "Kemarin"
    },
    {
      "name": "Celana Pendek Chino", "type": "Bawahan", "color": Colors.brown.shade200, "colorName": "Krem", 
      "usage": "Lumayan", "icon": Icons.airline_seat_legroom_normal,
      "imageUrl": "https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
      "material": "Twill Cotton", "brand": "H&M", "wearCount": 12, "lastWorn": "1 minggu yang lalu"
    },
    {
      "name": "Jaket Bomber", "type": "Outer", "color": Colors.green.shade900, "colorName": "Hijau", 
      "usage": "Jarang", "icon": Icons.snowing,
      "imageUrl": "https://images.unsplash.com/photo-1551028719-00167b16eac5?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
      "material": "Nylon Parasut", "brand": "ZARA", "wearCount": 5, "lastWorn": "3 minggu yang lalu"
    },
    {
      "name": "Sneakers Putih", "type": "Sepatu", "color": Colors.white, "colorName": "Putih", 
      "usage": "Sering Dipakai", "icon": Icons.snowshoeing,
      "imageUrl": "https://images.unsplash.com/photo-1549298916-b41d501d3772?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
      "material": "Canvas & Leather", "brand": "Nike", "wearCount": 30, "lastWorn": "Hari ini"
    },
  ];

  // --- 3. FUNGSI BOTTOM SHEET FILTER ADVANCE ---
  void _showAdvancedFilter() {
    List<String> tempColors = List.from(selectedColors);
    List<String> tempUsages = List.from(selectedUsages);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 24),
                  const Text("Filter Lemari", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 24),

                  const Text("Status Pemakaian", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12, runSpacing: 12,
                    children: availableUsages.map((usage) {
                      final isSelected = tempUsages.contains(usage);
                      return ChoiceChip(
                        label: Text(usage, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary)),
                        selected: isSelected, selectedColor: AppColors.primary, backgroundColor: Colors.white,
                        side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey.shade300),
                        onSelected: (selected) { setModalState(() { isSelected ? tempUsages.remove(usage) : tempUsages.add(usage); }); },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  const Text("Pilih Warna", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12, runSpacing: 12,
                    children: availableColors.map((colorObj) {
                      final isSelected = tempColors.contains(colorObj["name"]);
                      return InkWell(
                        onTap: () { setModalState(() { isSelected ? tempColors.remove(colorObj["name"]) : tempColors.add(colorObj["name"]); }); },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 16, height: 16, decoration: BoxDecoration(color: colorObj["color"], shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade400, width: 0.5))),
                              const SizedBox(width: 8),
                              Text(colorObj["name"], style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontSize: 13)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),

                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () { setModalState(() { tempColors.clear(); tempUsages.clear(); }); }, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Reset", style: TextStyle(color: AppColors.textPrimary)))),
                      const SizedBox(width: 16),
                      Expanded(child: ElevatedButton(onPressed: () { setState(() { selectedColors = List.from(tempColors); selectedUsages = List.from(tempUsages); }); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Terapkan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- 4. FUNGSI MENAMPILKAN DETAIL (BOTTOM SHEET BESAR) ---
  void _showItemDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // HANDLE
              Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                  bottom: 16,
                ),
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // GAMBAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    item["imageUrl"],
                    width: double.infinity,
                    height: 280,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 280,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // AREA DETAIL YANG BISA SCROLL
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["name"],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "${item["brand"]} • ${item["type"]}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        "Informasi Pakaian",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailInfoCard(
                              "Bahan",
                              item["material"],
                              Icons.texture,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDetailInfoCard(
                              "Warna",
                              item["colorName"],
                              Icons.palette_outlined,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailInfoCard(
                              "Total Dipakai",
                              "${item["wearCount"]} Kali",
                              Icons.loop,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDetailInfoCard(
                              "Terakhir",
                              item["lastWorn"],
                              Icons.history,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          "Riwayat Pemakaian dan insight AI bisa ditambahkan di sini nanti.",
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // FIXED ACTION AREA
              Container(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Mix & Match dengan AI",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.edit,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                              label: const Text(
                                "Edit",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.red,
                              ),
                              label: const Text(
                                "Hapus",
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(
                                  color: Colors.red,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
}

  Widget _buildDetailInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.secondary.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.secondary),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logika Filter Gabungan (Kategori + Warna + Status)
    final filteredClothes = userClothes.where((cloth) {
      final matchCategory = selectedCategory == "Semua" || cloth["type"] == selectedCategory;
      final matchColor = selectedColors.isEmpty || selectedColors.contains(cloth["colorName"]);
      final matchUsage = selectedUsages.isEmpty || selectedUsages.contains(cloth["usage"]);
      return matchCategory && matchColor && matchUsage;
    }).toList();

    // Cek status tombol filter
    final isAdvancedFilterActive = selectedColors.isNotEmpty || selectedUsages.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text("IDENTIS | Lemari", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)), centerTitle: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- CHIPS KATEGORI & TOMBOL FILTER ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(category, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary)),
                            selected: isSelected, selectedColor: AppColors.primary, backgroundColor: AppColors.surface,
                            onSelected: (bool selected) => setState(() => selectedCategory = category),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // TOMBOL FILTER KEMBALI HADIR DI SINI!
                Container(
                  decoration: BoxDecoration(
                    color: isAdvancedFilterActive ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.tune, color: isAdvancedFilterActive ? Colors.white : AppColors.primary, size: 20),
                    onPressed: _showAdvancedFilter, // SEKARANG DIPANGGIL!
                  ),
                ),
              ],
            ),
          ),
          
          // GRID PAKAIAN DENGAN GAMBAR ASLI
          Expanded(
            child: filteredClothes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.secondary),
                        SizedBox(height: 16),
                        Text("Pakaian tidak ditemukan.", style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.70,
                    ),
                    itemCount: filteredClothes.length,
                    itemBuilder: (context, index) {
                      final item = filteredClothes[index];
                      Color badgeColor = item["usage"] == "Sering Dipakai" ? Colors.green : (item["usage"] == "Lumayan" ? Colors.blue : Colors.orange);

                      return InkWell(
                        onTap: () => _showItemDetails(item),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: Image.network(
                                        item["imageUrl"], 
                                        width: double.infinity, height: double.infinity, fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200, child: const Center(child: Icon(Icons.image_not_supported))),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8, right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(8)),
                                        child: Text(item["usage"], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(item["type"], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}