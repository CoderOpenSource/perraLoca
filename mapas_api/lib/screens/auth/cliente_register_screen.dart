import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapas_api/screens/auth/login_screen.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:mapas_api/widgets/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:mapas_api/themes/light_theme.dart';

class ClienteRegisterView extends StatefulWidget {
  final int userId;
  const ClienteRegisterView({super.key, required this.userId});

  @override
  _ClienteRegisterViewState createState() => _ClienteRegisterViewState();
}

class _ClienteRegisterViewState extends State<ClienteRegisterView> {
  File? _selectedImage;
  TextEditingController telefonoController = TextEditingController();
  TextEditingController direccionController = TextEditingController();
  TextEditingController marcaController = TextEditingController();
  TextEditingController modeloController = TextEditingController();
  bool _isCreatingUser = false;
  bool? registrationSuccess;
  String? _selectedYear;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text("Completemos tu registro:",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: lightUberTheme.primaryColor)),
                const SizedBox(
                  height: 10,
                ),
                _customTextField2(telefonoController, 'Telefono:',
                    'Ingresa tu número de telefono:',
                    prefixIcon: const Icon(Icons.person_pin)),
                const SizedBox(height: 20),
                _customTextField(
                    direccionController, 'Dirección:', 'Ingresa tu dirección:',
                    prefixIcon: const Icon(Icons.person_outline)),
                const SizedBox(height: 10),
                Center(
                  child: Text("Datos de tu Vehiculo:",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: lightUberTheme.primaryColor)),
                ),
                _customTextField(marcaController, 'Marca:',
                    'Ingresa la marca de tu vehiculo:',
                    prefixIcon: const Icon(Icons.car_repair_sharp)),
                const SizedBox(height: 20),
                _customTextField(modeloController, 'Modelo:',
                    'Ingresa el modelo de tu vehiculo:',
                    prefixIcon: const Icon(Icons.electric_moped_outlined)),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Año del vehículo',
                    icon: Icon(Icons.date_range),
                  ),
                  value: _selectedYear,
                  items: List.generate(35, (index) {
                    int year = 1990 + index;
                    return DropdownMenuItem(
                      value: year.toString(),
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text("Añade una foto del Vehiculo:",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: lightUberTheme.primaryColor)),
                ),
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
    const clienteUrl = 'http://146.190.46.194/usuarios/clientes/';
    const vehiculoUrl =
        'http://146.190.46.194/vehiculos/vehiculos/'; // Asumiendo que este es el endpoint para vehículos

    // Datos del cliente
    Map<String, String> clienteRequestBody = {
      'user': widget.userId.toString(),
      'direccion': direccionController.text.trim(),
      'telefono': telefonoController.text.trim(),
    };

    // Realizamos la petición POST para el cliente
    http.Response clienteResponse = await http.post(
      Uri.parse(clienteUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(clienteRequestBody),
    );

    // Evaluamos la respuesta del cliente
    if (clienteResponse.statusCode == 201) {
      var responseBody = json.decode(clienteResponse.body);
      var clienteId =
          responseBody['id']; // Asumiendo que obtienes un 'id' como respuesta

      // Ahora registramos el vehículo
      String? mimeType;
      MediaType? mediaType;
      if (_selectedImage != null) {
        mimeType = lookupMimeType(_selectedImage!.path);
        mediaType = MediaType.parse(mimeType!);
      }

      var vehiculoRequest =
          http.MultipartRequest('POST', Uri.parse(vehiculoUrl))
            ..fields['cliente'] = clienteId.toString()
            ..fields['marca'] = marcaController.text
                .trim() // Asegúrate de tener un controller para cada campo
            ..fields['modelo'] = modeloController.text.trim()
            ..fields['año'] = _selectedYear!;

      if (_selectedImage != null) {
        vehiculoRequest.files.add(await http.MultipartFile.fromPath(
          'foto',
          _selectedImage!.path,
          contentType: mediaType,
        ));
      }

      var streamedVehiculoResponse = await vehiculoRequest.send();
      http.Response vehiculoResponse =
          await http.Response.fromStream(streamedVehiculoResponse);

      if (vehiculoResponse.statusCode == 201) {
        registrationSuccess = true;
        _showSnackBar('Cliente y vehículo registrados con éxito', Colors.green);
      } else {
        var errorMessage = 'Error al registrar el vehículo';
        try {
          var vehiculoResponseBody = json.decode(vehiculoResponse.body);
          if (vehiculoResponseBody is Map &&
              vehiculoResponseBody.containsKey('detail')) {
            errorMessage = vehiculoResponseBody['detail'];
          }
        } catch (e) {
          print('Error al decodificar la respuesta del vehículo: $e');
        }
        _showSnackBar(errorMessage);
        setState(() {
          _isCreatingUser = false;
        });
      }
    } else {
      var errorMessage = 'Error al registrar el cliente';
      try {
        var clienteResponseBody = json.decode(clienteResponse.body);
        if (clienteResponseBody is Map &&
            clienteResponseBody.containsKey('detail')) {
          errorMessage = clienteResponseBody['detail'];
        }
      } catch (e) {
        print('Error al decodificar la respuesta del cliente: $e');
      }
      _showSnackBar(errorMessage);
      setState(() {
        _isCreatingUser = false;
      });
    }
  }

  Future<void> _handleRegistration() async {
    setState(() {
      _isCreatingUser = true;
    });
    print(direccionController.text.trim());
    print(telefonoController.text.trim());
    print(marcaController.text.trim());
    print(modeloController.text.trim());
    if (direccionController.text.trim().isEmpty ||
        telefonoController.text.trim().isEmpty ||
        marcaController.text.trim().isEmpty ||
        modeloController.text.trim().isEmpty ||
        _selectedYear == null) {
      _showErrorAndResetState("Por favor completa todos los campos");
      return;
    }

    if (_selectedImage == null) {
      _showErrorAndResetState(
          "Por favor selecciona una imagen para el vehículo");
      return;
    }

    await registerWithDjango();

    // Suponiendo que tienes una variable que indica si el registro fue exitoso o no:
    if (registrationSuccess!) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    } else {
      _showErrorAndResetState("Error en el registro");
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
        style: TextStyle(color: lightUberTheme.primaryColor),
        cursorColor: lightUberTheme.primaryColor,
        decoration: _inputDecoration(label, hintText, prefixIcon));
  }
}
