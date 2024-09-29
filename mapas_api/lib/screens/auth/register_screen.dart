import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapas_api/screens/auth/cliente_register_screen.dart';
import 'package:mapas_api/screens/auth/taller_register_screen.dart';
import 'package:mapas_api/screens/auth/tecnico_register_screen.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:mapas_api/widgets/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:mapas_api/themes/light_theme.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  TextEditingController emailController = TextEditingController();
  File? _selectedImage;
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  final RegExp _emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  TextEditingController usernameController = TextEditingController();
  int? _userId;
  int? _selectedRole;
  bool _isCreatingUser = false;
  bool? registrationSuccess;
  final Map<String, int> roleMapping = {
    'Cliente': 2,
    'Taller': 3,
    'Tecnico': 4,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text("Registro de Usuario",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: lightUberTheme.primaryColor)),
                const SizedBox(
                  height: 10,
                ),
                _customTextField(usernameController, 'Nombre de Usuario:',
                    'Ingresa un nombre de Usuario:',
                    prefixIcon: const Icon(Icons.person_pin)),
                const SizedBox(height: 20),
                _customTextField(nameController, 'Nombre Completo:',
                    'Ingresa tu nombre completo',
                    prefixIcon: const Icon(Icons.person_outline)),
                const SizedBox(height: 10),
                _customTextField(emailController, 'Correo Electronico:',
                    'Ingresa tu correo electronico',
                    prefixIcon: const Icon(Icons.email)),
                const SizedBox(height: 10),
                _customTextField(
                    passwordController, 'Contraseña:', 'Ingresa tu contraseña',
                    obscure: true, prefixIcon: const Icon(Icons.lock)),
                const SizedBox(height: 10),
                _customTextField(confirmPasswordController,
                    'Confirmar Contraseña:', 'Confirma tu contraseña',
                    obscure: true, prefixIcon: const Icon(Icons.lock_outline)),
                const SizedBox(height: 10),
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 16.0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: lightUberTheme.inputDecorationTheme.fillColor,
                      border: Border.all(
                          color: lightUberTheme.primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(
                          12.0), // Cambiado para coincidir con otros bordes
                    ),
                    child: DropdownButton<int>(
                      value: _selectedRole,
                      hint: const Text(
                        "Selecciona el tipo de Usuario",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      items: roleMapping.entries.map((entry) {
                        return DropdownMenuItem<int>(
                          value: entry.value,
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedRole = newValue;
                          print(_selectedRole);
                        });
                      },
                      isExpanded: true,
                      dropdownColor:
                          lightUberTheme.inputDecorationTheme.fillColor,
                      icon: Icon(Icons.arrow_drop_down,
                          color: lightUberTheme.primaryColor),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C1E),
                      ),
                    )),
                const SizedBox(height: 20),
                Center(
                  child: Text("Agrega una foto de perfil(Opcional):",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: lightUberTheme.primaryColor)),
                ),
                const SizedBox(height: 10),
                ImagePickerWidget(
                  onImagePicked: (image) {
                    setState(() {
                      _selectedImage = image;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _handleRegistration();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightUberTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Registrarse",
                    style: TextStyle(
                        fontSize: 18,
                        color: lightUberTheme.secondaryHeaderColor),
                  ),
                )
              ],
            ),
          ),
          if (_isCreatingUser) _loadingOverlay(),
        ],
      ),
    );
  }

  Widget _loadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text("Espere por favor...",
                style: TextStyle(color: lightUberTheme.primaryColor)),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hintText,
      [Icon? prefixIcon]) {
    return InputDecoration(
      prefixIcon: prefixIcon,
      labelText: label,
      hintText: hintText,
      border: OutlineInputBorder(
        borderSide: BorderSide(
            color: lightUberTheme
                .inputDecorationTheme.focusedBorder!.borderSide.color),
        borderRadius: BorderRadius.circular(20),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: lightUberTheme
                .inputDecorationTheme.enabledBorder!.borderSide.color),
        borderRadius: BorderRadius.circular(20),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: lightUberTheme
                .inputDecorationTheme.focusedBorder!.borderSide.color),
        borderRadius: BorderRadius.circular(20),
      ),
      filled: true,
      fillColor: lightUberTheme.inputDecorationTheme.fillColor,
    );
  }

  Widget _customTextField(
      TextEditingController controller, String label, String hintText,
      {bool obscure = false, Icon? prefixIcon}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: _inputDecoration(label, hintText, prefixIcon),
    );
  }

  Future<void> registerWithDjango() async {
    const url = 'http://146.190.46.194/usuarios/users/';

    Map<String, String> requestBody = {
      'username': usernameController.text.trim(),
      'first_name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
      // Suponiendo que _selectedRole es un int:
      'user_type': _selectedRole.toString(),
    };

    late http.Response response;
    if (_selectedImage != null) {
      String? mimeType = lookupMimeType(_selectedImage!.path);
      MediaType mediaType = MediaType.parse(mimeType!);

      // Usar MultipartRequest para manejar la imagen
      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields.addAll(requestBody)
        ..files.add(await http.MultipartFile.fromPath(
          'foto',
          _selectedImage!.path,
          contentType: mediaType,
        ));

      var streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
      print('Campos a enviar: ${request.fields}');
      print(_selectedImage!.path);
      print(
          'Archivos a enviar: ${request.files.map((file) => file.field).toList()}');
    } else {
      try {
        response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        );
      } catch (error) {
        _showSnackBar('Error de conexión: $error');
        return;
      }
    }

    if (response.statusCode == 201) {
      registrationSuccess = true;
      _showSnackBar('Usuario registrado con éxito', Colors.green);

      var responseBody = json.decode(response.body);
      _userId = responseBody['id'];
    } else {
      registrationSuccess = false;
      var errorMessage = 'Error al registrar el usuario';
      print('Response body: ${response.body}');

      try {
        var responseBody = json.decode(response.body);
        if (responseBody is Map && responseBody.containsKey('detail')) {
          errorMessage = responseBody['detail'];
        }
      } catch (e) {
        print('Error al decodificar la respuesta: $e');
      }
      _showSnackBar(errorMessage);
    }
  }

  Future<void> _handleRegistration() async {
    setState(() {
      _isCreatingUser = true;
    });

    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        nameController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      _showErrorAndResetState("Por favor completa todos los campos");
      return;
    }

    if (!_emailRegex.hasMatch(emailController.text.trim())) {
      _showErrorAndResetState(
          "Por favor, introduce un correo electrónico válido");
      return;
    }

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      _showErrorAndResetState("Las contraseñas no coinciden");
      return;
    }

    // Validación adicional: Supongamos que una contraseña válida tiene al menos 6 caracteres
    if (passwordController.text.trim().length < 6) {
      _showErrorAndResetState("La contraseña debe tener al menos 6 caracteres");
      return;
    }

    await registerWithDjango();
    if (registrationSuccess!) {
      switch (_selectedRole) {
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ClienteRegisterView(userId: _userId!)),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TallerRegisterView(userId: _userId!)),
          );
          break;
        case 4:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TecnicoRegisterView(userId: _userId!)),
          );
          break;
        default:
          // En caso de que `_selectedRole` no sea ninguno de los valores esperados
          // puedes manejar un caso default o simplemente no hacer nada.
          break;
      }
      // Suponiendo que tienes una variable que indica si el registro fue exitoso o no:
    } else {
      setState(() {
        _isCreatingUser = false;
      });
    }
  }

  void _showErrorAndResetState(String errorMessage) {
    _showSnackBar(errorMessage);
    setState(() {
      _isCreatingUser = false;
    });
  }

  void _showSnackBar(String message, [Color backgroundColor = Colors.red]) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _customTextField2(
      TextEditingController controller, String label, String hintText,
      {bool obscure = false, Icon? prefixIcon}) {
    return TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        obscureText: obscure,
        style: const TextStyle(color: Color.fromARGB(255, 2, 65, 30)),
        cursorColor: const Color.fromARGB(255, 41, 76, 1),
        decoration: _inputDecoration(label, hintText, prefixIcon));
  }
}
