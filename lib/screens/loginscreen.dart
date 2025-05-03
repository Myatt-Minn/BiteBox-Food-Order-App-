import 'package:flutter/material.dart';
import 'package:foodorderapplication/screens/navigationscreen.dart';
import 'package:foodorderapplication/screens/signupscreen.dart';
import 'package:foodorderapplication/services/auth_method.dart';
import 'package:foodorderapplication/utils/consts.dart';
import 'package:foodorderapplication/widgets/text_fields.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void navigatetoSignUp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SignUpScreen()));
  }

  void loginUser() async {
    String email = _emailcontroller.text.trim();
    String password = _passwordcontroller.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showSnackBar(context, 'Email and password cannot be empty');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethod().loginUser(
      context: context,
      email: email,
      password: password,
    );

    setState(() {
      _isLoading = false;
    });

    if (res == 'success') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => NavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 16),
            reverse: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 80),
                Image.asset(appLogo, width: 150),
                const SizedBox(height: 64),
                TextFieldInput(
                  textEditingController: _emailcontroller,
                  hint: "Please Enter the Email",
                  keyboardtype: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                TextFieldInput(
                  textEditingController: _passwordcontroller,
                  hint: "Please Enter the Password",
                  keyboardtype: TextInputType.text,
                  isPass: true,
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: loginUser,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      color: primaryColor,
                    ),
                    child:
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : const Text("Login"),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                      child: const Text("Dont have an account?"),
                    ),
                    GestureDetector(
                      onTap: navigatetoSignUp,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) {
                          return NavigationScreen();
                        },
                      ),
                    );
                  },
                  child: Text("Use as a guest!"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
