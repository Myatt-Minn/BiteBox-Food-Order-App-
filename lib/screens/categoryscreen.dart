import 'package:flutter/material.dart';
import 'package:foodorderapplication/models/categoryModel.dart';
import 'package:foodorderapplication/models/foodcardModel.dart';
import 'package:foodorderapplication/utils/consts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool isLoading = true;
  String searchText = '';
  List<Category> categories = [];
  List<FoodCard> productsByCategory = [];
  List<FoodCard> filteredProducts = [];
  var supabase = Supabase.instance.client;
  @override
  void initState() {
    super.initState();
    fetchCategoriesAndProducts();
  }

  Future<void> fetchCategoriesAndProducts() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Replace these with your real data
    await fetchCategories();
    await getProductsByCategory();

    filteredProducts = productsByCategory;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from('categories').select();

      categories =
          (response as List).map((item) {
            return Category.fromMap(item);
          }).toList();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> getProductsByCategory({String category = "Burgers"}) async {
    try {
      final response = await supabase
          .from('foods')
          .select()
          .eq('category', category);

      productsByCategory =
          (response as List).map((item) {
            return FoodCard.fromMap(item);
          }).toList();

      filteredProducts = productsByCategory;
      setState(() {});
    } catch (e) {
      print('Error fetching products by category: $e');
    }
  }

  void updateSearch(String value) {
    searchText = value;
    filteredProducts =
        productsByCategory
            .where(
              (product) =>
                  product.name.toLowerCase().contains(searchText.toLowerCase()),
            )
            .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.category),
        title: const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 15),
            Expanded(
              // <-- ADD THIS
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                        children: [
                          _buildCategoryIcons(),
                          const SizedBox(height: 20),
                          if (filteredProducts.isEmpty)
                            const Center(child: Text('No Foods Found'))
                          else
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.5,
                                      crossAxisSpacing: 2,
                                      mainAxisSpacing: 2,
                                    ),
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
                                  return _buildFoodCard(product);
                                },
                              ),
                            ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: updateSearch,
      decoration: InputDecoration(
        filled: true,
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        hintText: 'Search',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategoryIcons() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryIcon(category.imageUrl, category.name);
        },
      ),
    );
  }

  Widget _buildCategoryIcon(String imagePath, String label) {
    return GestureDetector(
      onTap: () {
        getProductsByCategory(category: label);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            CircleAvatar(radius: 35, backgroundImage: NetworkImage(imagePath)),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(FoodCard food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.network(food.imageUrl, fit: BoxFit.fill),
                ),

                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${food.rating}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              food.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              food.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '\$${food.price}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
