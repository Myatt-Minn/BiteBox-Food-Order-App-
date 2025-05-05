import 'package:flutter/material.dart';
import 'package:foodorderapplication/models/cartItemModel.dart';
import 'package:foodorderapplication/screens/loginscreen.dart';
import 'package:foodorderapplication/utils/consts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Cartscreen extends StatefulWidget {
  final VoidCallback? onCartCleared;
  const Cartscreen({super.key, this.onCartCleared});

  @override
  State<Cartscreen> createState() => _FoodCardPageState();
}

class _FoodCardPageState extends State<Cartscreen> {
  var storage = GetStorage();
  var cartItems = <CartItem>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCartFromStorage();
  }

  void loadCartFromStorage() {
    List<dynamic>? cartData = storage.read('cart');
    if (cartData != null) {
      setState(() {
        cartItems = cartData.map((item) => CartItem.fromMap(item)).toList();
      });
    }
  }

  Future<void> checkLogin(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login First'),
          content: Text('Please login first to continue.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  double calculateTotalPrice() {
    double total = 0;
    for (var item in cartItems) {
      total += item.totalPrice;
    }
    return total;
  }

  Future<void> showNameInputDialog(BuildContext context) async {
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Phone and Address'),
          content: SizedBox(
            height: 100,
            child: Column(
              children: [
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  maxLength: 11, // <- Limit input to 11 characters
                  decoration: InputDecoration(
                    hintText: "Enter Phone Number ..",
                    counterText:
                        '', // Hides the default counter below the field
                  ),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(hintText: "Enter Address .."),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Cancel'),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Confirm'),
                ),
              ),
              onPressed: () async {
                String phone = phoneController.text.trim();
                if (phone.length > 11) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Phone number cannot exceed 11 digits.'),
                    ),
                  );
                  return;
                }

                await postCartItemsToSupabase(
                  phone,
                  addressController.text.trim(),
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> postCartItemsToSupabase(String phone, String address) async {
    try {
      if (cartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sorry, Cart is Empty. Please add items first"),
          ),
        );
        return;
      }

      List<Map<String, dynamic>> cartData =
          cartItems.map((item) => item.toMap()).toList();

      // Insert cart items into the Supabase database
      await Supabase.instance.client.from('orders').insert({
        'items': cartData, // items field is JSONB in Supabase
        'uid': Supabase.instance.client.auth.currentUser!.id,
        'totalPrice': calculateTotalPrice(),
        'phone': phone,
        'address': address,
      });

      // Clear local cart after successful post
      setState(() {
        cartItems.clear();
      });

      // Remove from local storage
      storage.remove('cart');
      widget.onCartCleared?.call();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Congrats, Your Order has been uploaded successfully! ",
          ),
        ),
      );
    } catch (e) {
      print("Error posting cart items: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to post cart items.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.shopping_cart),
        title: Text("Cart"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  cartItems.clear();
                });
                storage.remove('cart');
                widget.onCartCleared?.call();
              },
              child: Row(
                children: [
                  Text("Clear Cart"),
                  SizedBox(width: 4),
                  Icon(Icons.delete, color: primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          return _buildCartItem(cartItems[index], index);
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "\$${calculateTotalPrice()}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (Supabase.instance.client.auth.currentUser == null) {
                  checkLogin(context);
                } else {
                  showNameInputDialog(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 125,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text(
                "Checkout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.food.imageUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.food.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.food.price} × ${item.quantity} = \$${item.totalPrice}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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
}
