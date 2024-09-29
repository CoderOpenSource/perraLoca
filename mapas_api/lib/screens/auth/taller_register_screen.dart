import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapas_api/models/global_marcar_ubicacion.dart';
import 'package:mapas_api/screens/auth/login_screen.dart';
import 'package:mapas_api/screens/taller/loading_taller_screen.dart';
import 'package:mapas_api/themes/light_theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TallerRegisterView extends StatefulWidget {
  final int userId;
  const TallerRegisterView({super.key, required this.userId});

  @override
  _TallerRegisterViewState createState() => _TallerRegisterViewState();
}

class _TallerRegisterViewState extends State<TallerRegisterView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController direccionController = TextEditingController();
  bool _isCreatingUser = false;
  bool? registrationSuccess;
  TimeOfDay? selectedOpeningTime;
  TimeOfDay? selectedClosingTime;
  LatLng? ubicacionDelTaller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text("Finalicemos el registro del Taller:",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: lightUberTheme.primaryColor)),
                const SizedBox(
                  height: 10,
                ),
                _customTextField(nameController, 'Nombre del Taller:',
                    'Ingresa el nombre del Taller:',
                    prefixIcon: const Icon(Icons.person_pin)),
                const SizedBox(height: 20),
                _customTextField(direccionController, 'Direccion:',
                    'Ingrese la dirección del taller',
                    prefixIcon: const Icon(Icons.person_outline)),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Centra los elementos horizontalmente
                    children: [
                      Text(
                        "Proporciona la ubicacion del Taller:",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: lightUberTheme.primaryColor),
                      ),
                      const SizedBox(
                          width: 10), // Espacio entre el ícono y el texto
                      IconButton(
                        icon: Icon(
                          Icons.location_on_rounded,
                          color: lightUberTheme.primaryColor,
                          size: 40,
                        ),
                        onPressed: () async {
                          // Aquí, 'await' captura el resultado cuando la pantalla del mapa hace 'Navigator.pop'
                          final resultado = await Navigator.push<LatLng>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TallerLoadingScreen(),
                            ),
                          );
                          // Si 'resultado' no es nulo, entonces actualizamos la ubicación del taller con el valor obtenido.
                          if (resultado != null) {
                            setState(() {
                              ubicacionDelTaller = resultado;
                              print('resultado: $resultado');
                            });
                            // Aquí podrías hacer algo con la ubicación del taller, como mostrarla en un mapa o almacenarla en una base de datos.
                          } else {
                            ubicacionDelTaller =
                                GlobalData().ubicacion_marcador;
                            print('resultado $ubicacionDelTaller');
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text("Horarios de Atención:",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: lightUberTheme.primaryColor)),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: _selectOpeningTime,
                  child: Text(selectedOpeningTime?.format(context) ??
                      'Selecciona hora de apertura'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _selectClosingTime,
                  child: Text(selectedClosingTime?.format(context) ??
                      'Selecciona hora de cierre'),
                ),
                const SizedBox(height: 10),
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
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Espere por favor...",
                style: TextStyle(color: Color.fromARGB(255, 59, 9, 59))),
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

  _selectOpeningTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedOpeningTime) {
      setState(() {
        selectedOpeningTime = picked;
      });
    }
  }

  _selectClosingTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedClosingTime) {
      setState(() {
        selectedClosingTime = picked;
      });
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes:00'; // Formato hh:mm:ss
  }

  Future<void> registerWithDjango() async {
    const url = 'http://146.190.46.194/usuarios/talleres/';

    // Verificar si se seleccionaron las horas y la ubicación del taller
    if (selectedOpeningTime == null ||
        selectedClosingTime == null ||
        ubicacionDelTaller == null) {
      _showSnackBar(
          "Por favor selecciona las horas de apertura, cierre y la ubicación del taller");
      return;
    }

    // Asegúrate de que la latitud y la longitud estén en formato String para ser incluidas en el cuerpo de la solicitud
    String latitud = ubicacionDelTaller!.latitude.toString();
    String longitud = ubicacionDelTaller!.longitude.toString();

    Map<String, dynamic> requestBody = {
      'user': widget.userId.toString(),
      'direccion': direccionController.text.trim(),
      'nombre': nameController.text.trim(),
      'hora_apertura': formatTimeOfDay(selectedOpeningTime!),
      'hora_cierre': formatTimeOfDay(selectedClosingTime!),
      'latitud': latitud,
      'longitud': longitud,
    };

    late http.Response response;

    response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 201) {
      registrationSuccess = true;
      _showSnackBar('Taller registrado con éxito',
          backgroundColor: Colors.green);
    } else {
      var errorMessage = 'Error al registrar el taller';
      try {
        var responseBody = json.decode(response.body);
        print(
            'Error Response: $responseBody'); // Imprimir la respuesta del servidor
        if (responseBody is Map && responseBody.containsKey('detail')) {
          errorMessage = responseBody['detail'];
        }
      } catch (e) {
        print('Error al decodificar la respuesta: $e');
      }
      _showSnackBar(errorMessage);
    }
  }

  _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ??
            Colors
                .red, // Si no se especifica un color, usamos rojo como predeterminado
      ),
    );
  }

  Future<void> _handleRegistration() async {
    setState(() {
      _isCreatingUser = true;
    });

    if (direccionController.text.trim().isEmpty ||
        nameController.text.trim().isEmpty ||
        selectedOpeningTime == null ||
        selectedClosingTime == null) {
      _showErrorAndResetState("Por favor completa todos los campos");
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
}
