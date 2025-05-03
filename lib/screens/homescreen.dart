import 'package:flutter/material.dart';
import 'package:foodorderapplication/models/cartItemModel.dart';
import 'package:foodorderapplication/models/foodcardModel.dart';
import 'package:foodorderapplication/screens/fooddetailscreen.dart';
import 'package:foodorderapplication/screens/loginscreen.dart';
import 'package:foodorderapplication/utils/consts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  String selectedCategory = "Ice-cream";
  var storage = GetStorage();
  var cartItems = <CartItem>[];
  var name = 'Guest';
  @override
  void initState() {
    super.initState();
    loadCartFromStorage();
    fetchCurrentUsername();
  }

  void loadCartFromStorage() {
    List<dynamic>? cartData = storage.read('cart');
    if (cartData != null) {
      setState(() {
        cartItems = cartData.map((item) => CartItem.fromMap(item)).toList();
      });
    }
  }

  Future<List<FoodCard>> fetchFoodItems() async {
    try {
      final response = await Supabase.instance.client.from('foods').select();
      return response.map<FoodCard>((item) => FoodCard.fromMap(item)).toList();
    } catch (e) {
      print("Error fetching food items: $e");
      return [];
    }
  }

  Future<void> fetchCurrentUsername() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      print('No authenticated user.');
      return;
    }

    final response =
        await supabase.from('users').select('name').eq('uid', userId).single();

    final username = response['name'] as String?;
    setState(() {
      name = username ?? 'Guest';
    });
  }

  void saveCartToStorage() {
    List<Map<String, dynamic>> cartData =
        cartItems
            .map(
              (item) => item.toMap(),
            ) // Assuming you have a toJson method in CartItem
            .toList();
    storage.write('cart', cartData); // Save the cart to storage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset(appLogo),
        elevation: 10,
        backgroundColor: Colors.white,
        shadowColor: Colors.grey,
        title: Text(
          'Hello, $name!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Supabase.instance.client.auth.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) {
                    return LoginScreen();
                  },
                ),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Delicious Food",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Discover and enjoy great food",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Divider(),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<FoodCard>>(
                future: fetchFoodItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.data!.isEmpty) {
                    return const Center(child: Text('No food items found.'));
                  }

                  final foodItems = snapshot.data!;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Popular Foods",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Horizontal List
                        SizedBox(
                          height: 350, // Adjust based on your card height
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: foodItems.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return FoodDetailPage(
                                            food: foodItems[index],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    width:
                                        220, // Adjust width for better spacing
                                    child: _buildFoodCard(foodItems[index]),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 12),
                        Text(
                          "Recommended Foods",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Vertical List
                        SizedBox(
                          height: 350, // Adjust based on your card height
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: foodItems.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: SizedBox(
                                  width: 220, // Adjust width for better spacing
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return FoodDetailPage(
                                              food: foodItems[index],
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: _buildFoodCard(foodItems[index]),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryCard(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
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
              food.category,
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
                Chip(
                  label: Text(
                    food.flavor,
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



/*

   onTap: () {
        setState(() {
          cartItems.add(food);
        });

        saveCartToStorage();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Food added to cart successfully!")),
        );
      },

*/