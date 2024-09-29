import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapas_api/screens/auth/login_screen.dart';
import 'dart:convert';
import 'package:mapas_api/themes/light_theme.dart';
import 'package:mapas_api/widgets/search_screen.dart';

class TecnicoRegisterView extends StatefulWidget {
  final int userId;
  const TecnicoRegisterView({Key? key, required this.userId}) : super(key: key);

  @override
  _TecnicoRegisterViewState createState() => _TecnicoRegisterViewState();
}

class _TecnicoRegisterViewState extends State<TecnicoRegisterView> {
  String? _selectedEspecialidad;
  bool _isCreatingUser = false;
  String? _nombreTaller;
  String? _idTaller;
  final List<DropdownMenuItem<String>> _dropdownMenuItems = [
    const DropdownMenuItem(
        value: 'mecanico_general', child: Text('Mecánico General')),
    const DropdownMenuItem(value: 'electrico', child: Text('Eléctrico')),
    const DropdownMenuItem(value: 'tornero', child: Text('Tornero')),
    const DropdownMenuItem(value: 'pintor', child: Text('Pintor')),
    const DropdownMenuItem(value: 'chapista', child: Text('Chapista')),
    const DropdownMenuItem(value: 'gomero', child: Text('Gomero')),
    // Añade más ítems según sea necesario
  ];
  bool? registrationSuccess;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  "Completemos tu registro:",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: lightUberTheme.primaryColor,
                    // Reemplaza con tu color
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Taller al que pertenece:",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: lightUberTheme.primaryColor
                      // Reemplaza con tu color
                      ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TallerScreen(),
                      ),
                    );
                    if (result != null) {
                      print(result);
                      _idTaller = result['id'].toString();
                      _nombreTaller = result['nombre'];
                      setState(() {});
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: _nombreTaller,
                        hintText: 'Buscar Taller',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Seleccione una especialidad',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedEspecialidad,
                  items: _dropdownMenuItems,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedEspecialidad = newValue;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isCreatingUser ? null : _handleRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightUberTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Registrarse",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      // Reemplaza con tu color
                    ),
                  ),
                ),
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

  Future<void> registerWithDjango() async {
    const url = 'http://146.190.46.194/usuarios/tecnicos/';

    // Creamos un Map para el cuerpo de la petición
    Map<String, String> requestBody = {
      'especialidad': _selectedEspecialidad!,
      'user': widget.userId.toString(),
      'taller': _idTaller!,
    };

    late http.Response response; // La respuesta se procesará más tarde

    // Realizamos la petición POST sin imagen
    response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    // Evaluamos la respuesta
    if (response.statusCode == 201) {
      // HTTP 201 significa que se creó correctamente
      _showSnackBar('Usuario registrado con éxito', Colors.green);
      registrationSuccess = true;
    } else {
      var errorMessage = 'Error al registrar el usuario';
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

    if (_selectedEspecialidad == null) {
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
