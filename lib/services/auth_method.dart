import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthMethod {
  Future<String> signupUser({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
  }) async {
    String res = '';
    try {
      // Supabase Auth sign up
      final response = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );

      final user = response.user;
      String uid = user!.id; // Get the user ID

      // Insert user information into Supabase table 'users'
      await Supabase.instance.client.from('users').insert({
        'uid': uid,
        'name': name.trim(),
        'email': email.trim(),
        'password': password.trim(),
      });
      res = 'success';
      return res;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),

          behavior:
              SnackBarBehavior.floating, // makes it float like Get.snackbar
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
    return res;
  }

  Future<String> loginUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    String res = '';
    try {
      // Attempt to sign in with email and password using Supabase
      await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      res = 'success';
      return res;
    } catch (e) {
      // Handle login errors
      if (e.toString().contains('user-not-found')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This user is not registered.'),

            behavior:
                SnackBarBehavior.floating, // makes it float like Get.snackbar
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (e.toString().contains('incorrect-password')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your password is incorrect'),

            behavior:
                SnackBarBehavior.floating, // makes it float like Get.snackbar
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User not Signed Up/Incorrect Password'),

            behavior:
                SnackBarBehavior.floating, // makes it float like Get.snackbar
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
    return res;
  }
}
