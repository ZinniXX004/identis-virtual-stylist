import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  // --- 1. STATE FILTER UTAMA ---
  final List<String> categories = ["Semua", "Atasan", "Bawahan", "Outer", "Aksesoris"];
  String selectedCategory = "Semua";
  
  // State untuk Filter Harga & Warna
  RangeValues currentPriceRange = const RangeValues(0, 1500000);
  List<String> selectedColors = [];
  final List<Map<String, dynamic>> availableColors = [
    {"name": "Hitam", "color": Colors.black},
    {"name": "Putih", "color": Colors.white},
    {"name": "Biru", "color": Colors.blue},
    {"name": "Krem", "color": Colors.brown.shade200},
    {"name": "Abu-abu", "color": Colors.grey},
  ];

  // --- 2. DUMMY DATA LENGKAP (Ada Angka Harga & Warna Asli) ---
  final List<Map<String, dynamic>> partnerProducts = [
    {"name": "Oversized Blazer", "brand": "Brand Nike x Uniqlo", "priceStr": "Rp 499.000", "price": 499000, "match": "98% Match (Tipe Tubuhmu)", "category": "Outer", "colorName": "Hitam"},
    {"name": "Slim Fit Chino Pants", "brand": "ZARA Man", "priceStr": "Rp 599.000", "price": 599000, "match": "95% Match (Undertone Warm)", "category": "Bawahan", "colorName": "Krem"},
    {"name": "Classic Denim Jacket", "brand": "Levi's", "priceStr": "Rp 899.000", "price": 899000, "match": "92% Match (MBTI Cocok)", "category": "Outer", "colorName": "Biru"},
    {"name": "Linen Casual Shirt", "brand": "H&M Premium", "priceStr": "Rp 349.000", "price": 349000, "match": "96% Match (Smart Casual)", "category": "Atasan", "colorName": "Putih"},
    {"name": "Pleated Midi Skirt", "brand": "Uniqlo", "priceStr": "Rp 399.000", "price": 399000, "match": "90% Match (Vibe Feminin)", "category": "Bawahan", "colorName": "Hitam"},
    {"name": "Minimalist Watch", "brand": "Daniel Wellington", "priceStr": "Rp 1.299.000", "price": 1299000, "match": "88% Match (Aksesoris)", "category": "Aksesoris", "colorName": "Abu-abu"},
  ];

  // --- 3. FUNGSI MEMUNCULKAN MODAL FILTER ADVANCE ---
  void _showAdvancedFilter() {
    // Menyimpan state sementara di dalam modal sebelum di-Apply
    RangeValues tempPriceRange = currentPriceRange;
    List<String> tempColors = List.from(selectedColors);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder( // Agar modal bisa update UI-nya sendiri (geser slider)
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 24),
                  const Text("Filter Produk", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 24),

                  // FILTER RENTANG HARGA
                  const Text("Rentang Harga", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Rp ${tempPriceRange.start.toInt()}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      Text("Rp ${tempPriceRange.end.toInt()}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  RangeSlider(
                    values: tempPriceRange,
                    min: 0,
                    max: 1500000,
                    divisions: 15,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.secondary.withOpacity(0.3),
                    onChanged: (RangeValues values) {
                      setModalState(() => tempPriceRange = values);
                    },
                  ),
                  const SizedBox(height: 24),

                  // FILTER WARNA
                  const Text("Pilih Warna", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: availableColors.map((colorObj) {
                      final isSelected = tempColors.contains(colorObj["name"]);
                      return InkWell(
                        onTap: () {
                          setModalState(() {
                            isSelected ? tempColors.remove(colorObj["name"]) : tempColors.add(colorObj["name"]);
                          });
                        },
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
                              Container(
                                width: 16, height: 16,
                                decoration: BoxDecoration(
                                  color: colorObj["color"],
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade400, width: 0.5),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                colorObj["name"],
                                style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),

                  // TOMBOL TERAPKAN
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              tempPriceRange = const RangeValues(0, 1500000);
                              tempColors.clear();
                            });
                          },
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text("Reset", style: TextStyle(color: AppColors.textPrimary)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Terapkan ke state utama lalu tutup modal
                            setState(() {
                              currentPriceRange = tempPriceRange;
                              selectedColors = List.from(tempColors);
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text("Terapkan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // SafeArea padding bawah
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- 4. LOGIKA FILTERING GABUNGAN (Kategori + Harga + Warna) ---
    final filteredProducts = partnerProducts.where((product) {
      final matchCategory = selectedCategory == "Semua" || product["category"] == selectedCategory;
      final matchPrice = product["price"] >= currentPriceRange.start && product["price"] <= currentPriceRange.end;
      final matchColor = selectedColors.isEmpty || selectedColors.contains(product["colorName"]);
      
      return matchCategory && matchPrice && matchColor;
    }).toList();

    // Cek apakah filter warna/harga sedang aktif
    final isAdvancedFilterActive = selectedColors.isNotEmpty || currentPriceRange.start > 0 || currentPriceRange.end < 1500000;

    return Scaffold(
      appBar: AppBar(
        title: const Text("IDENTIS | Katalog", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner AI (Dibuat ringkas agar hemat tempat)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                SizedBox(width: 12),
                Expanded(child: Text("Dikurasi oleh AI berdasarkan profilmu.", style: TextStyle(fontSize: 12, color: AppColors.textPrimary))),
              ],
            ),
          ),

          // --- BARIS KATEGORI & TOMBOL FILTER ADVANCE ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Horizontal Chips
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
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surface,
                            onSelected: (bool selected) {
                              setState(() => selectedCategory = category);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Tombol Filter Advance
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isAdvancedFilterActive ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.tune, color: isAdvancedFilterActive ? Colors.white : AppColors.primary, size: 20),
                    onPressed: _showAdvancedFilter,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // --- GRID PRODUK TER-FILTER ---
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: AppColors.secondary),
                        SizedBox(height: 16),
                        Text("Produk tidak ditemukan.", style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                          border: Border.all(color: AppColors.secondary.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(15))),
                                child: const Icon(Icons.checkroom, size: 48, color: AppColors.secondary),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product["match"], style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(product["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text(product["brand"], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(product["priceStr"], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary)),
                                      const Icon(Icons.shopping_bag_outlined, size: 18, color: AppColors.primary),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
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