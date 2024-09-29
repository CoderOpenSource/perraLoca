import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mapas_api/main.dart';
import 'package:mapas_api/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  String? _error;

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    // Obten el token FCM aquí
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $fcmToken');
    try {
      final response = await http.post(
        Uri.parse(
            'http://146.190.46.194/usuarios/login/'), // Asegúrate de que esta URL es correcta
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'email': emailController.text,
          'password': passwordController.text,
          'fcm_token': fcmToken, // Incluye el token FCM aquí
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access'] as String?;
        final refreshToken = data['refresh'] as String?;
        final userDataMap = data['user_data'] as Map<String, dynamic>?;

        if (accessToken != null &&
            refreshToken != null &&
            userDataMap != null) {
          // Almacenar el token de acceso y el token de actualización.
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('accessToken', accessToken);
          prefs.setString('refreshToken', refreshToken);

          // Guardar datos del usuario.
          prefs.setInt('userId', userDataMap['id'] as int);
          prefs.setString('userType', userDataMap['user_type'] as String);

          print("-----TOKEN--------------$accessToken");
          print('mapeo del usuario $userDataMap');
          // Navegar a la pantalla principal de la aplicación.
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const MyApp()));
        } else {
          setState(() {
            _error = 'Datos de usuario incompletos o nulos.';
          });
        }
      } else {
        setState(() {
          _error = 'Error: ${response.statusCode}. ${response.reasonPhrase}';
        });
      }
    } catch (error) {
      print('Authentication error: $error');
      setState(() {
        _error = 'Error de autenticación: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _loadingOverlay() {
    return _isLoading
        ? Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Espere por favor...",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          )
        : const SizedBox
            .shrink(); // Oculta el indicador de carga si no se está cargando
  }

  @override
  Widget build(BuildContext context) {
    // Colores del tema
    Color primaryColor = Theme.of(context).primaryColor;
    Color onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    Color secondaryTextColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Text(
                      'MecanoMobile',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 300,
                    width: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://res.cloudinary.com/dkpuiyovk/image/upload/v1698951170/coche-autonomo_alqtqz.png',
                        ),
                        fit: BoxFit.fill, // Aquí cambiamos a fill
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    color: Colors.black.withOpacity(0.7),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Iniciar sesión:",
                              style: TextStyle(
                                  color: onPrimaryColor, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: emailController,
                            style: TextStyle(color: secondaryTextColor),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email_sharp,
                                  color: secondaryTextColor),
                              labelText: 'Correo electrónico',
                              labelStyle: TextStyle(color: secondaryTextColor),
                              hintText: 'Correo electrónico',
                              hintStyle: TextStyle(color: secondaryTextColor),
                            ).copyWith(
                              border:
                                  Theme.of(context).inputDecorationTheme.border,
                              enabledBorder: Theme.of(context)
                                  .inputDecorationTheme
                                  .enabledBorder,
                              focusedBorder: Theme.of(context)
                                  .inputDecorationTheme
                                  .focusedBorder,
                              // y cualquier otro campo que quieras copiar de inputDecorationTheme
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: passwordController,
                            obscureText: _obscureText,
                            style: TextStyle(color: secondaryTextColor),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.password,
                                  color: secondaryTextColor),
                              labelText: 'Contraseña',
                              labelStyle: TextStyle(color: secondaryTextColor),
                              hintText: 'Contraseña',
                              hintStyle: TextStyle(color: secondaryTextColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: secondaryTextColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ).copyWith(
                              border:
                                  Theme.of(context).inputDecorationTheme.border,
                              enabledBorder: Theme.of(context)
                                  .inputDecorationTheme
                                  .enabledBorder,
                              focusedBorder: Theme.of(context)
                                  .inputDecorationTheme
                                  .focusedBorder,
                              // y cualquier otro campo que quieras copiar de inputDecorationTheme
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.all(12),
                              ),
                              child: const Text(
                                "Iniciar sesión",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                "¿Has olvidado la contraseña?",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterView()),
                                );
                              },
                              child: const Text(
                                "¿No tienes una cuenta? Regístrate",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                          if (_error != null)
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          _loadingOverlay(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
