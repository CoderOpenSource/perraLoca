import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapas_api/themes/light_theme.dart';

class TallerScreen extends StatefulWidget {
  const TallerScreen({super.key});

  @override
  _TallerScreenState createState() => _TallerScreenState();
}

class _TallerScreenState extends State<TallerScreen> {
  List<Map<String, dynamic>> allTalleres =
      []; // Inicializadas como listas vacías
  List<Map<String, dynamic>> filteredTalleres = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTalleres();
  }

  void _loadTalleres() async {
    final talleresResponse =
        await http.get(Uri.parse('http://146.190.46.194/usuarios/talleres/'));

    if (talleresResponse.statusCode == 200) {
      var talleres = (json.decode(talleresResponse.body) as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      setState(() {
        allTalleres = talleres;
        filteredTalleres = talleres;
      });
    } else {
      // Manejo de error, podrías mostrar un Snackbar, un dialogo, etc.
      print('Error al obtener talleres: ${talleresResponse.statusCode}');
    }
  }

  void _filterTalleres(String query) {
    if (query.isEmpty) {
      filteredTalleres = allTalleres;
    } else {
      filteredTalleres = allTalleres
          .where((taller) =>
              taller['nombre'].toLowerCase().contains(query.toLowerCase()) ||
              taller['direccion'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightUberTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: TextField(
          onChanged: (value) {
            _searchQuery = value;
            _filterTalleres(_searchQuery);
          },
          decoration: const InputDecoration(
            hintText: 'Buscar taller',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredTalleres.length,
        itemBuilder: (context, index) {
          var taller = filteredTalleres[index];
          return ListTile(
            title: Text(
              taller['nombre'], // Reemplazar con la clave real para el nombre
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            subtitle: Text(
              taller[
                  'direccion'], // Reemplazar con la clave real para la dirección
              style: const TextStyle(
                fontSize: 14.0,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context, taller); // Retorna el taller seleccionado
            },
          );
        },
      ),
    );
  }
}
