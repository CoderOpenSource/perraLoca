import 'package:carousel_slider/carousel_slider.dart';
import 'package:mapas_api/models/global_data.dart';
import 'package:mapas_api/models/user/sucursal_model.dart';
import 'package:mapas_api/screens/taller/loading_taller_screen4.dart';
import 'package:mapas_api/widgets/appbar.dart';
import 'package:mapas_api/widgets/product_detail.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

bool _hasShownDialog = false;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Lista de imágenes de ejemplo
  List<String> imageUrls = [
    'https://res.cloudinary.com/dkpuiyovk/image/upload/v1697485275/WhatsApp_Image_2023-10-16_at_10.08.56_lriuuu.jpg',
    'https://res.cloudinary.com/dkpuiyovk/image/upload/v1697485275/WhatsApp_Image_2023-10-16_at_10.09.09_dvv8h8.jpg',
    'https://res.cloudinary.com/dkpuiyovk/image/upload/v1697485276/WhatsApp_Image_2023-10-16_at_10.03.26_rwq3by.jpg',
    'https://images6.alphacoders.com/132/1325712.jpeg',
    // Agrega más URLs de imágenes según tus necesidades
  ];
  bool isLoading = true;
  List<dynamic> categories = [];
  String? selectedCategory;
  List<dynamic> products = []; // Esta mantendrá todos los productos
  List<dynamic> displayedProducts =
      []; // Esta mostrará los productos filtrados o todos
  int? selectedSucursalId;
  // Agregamos un dummy de categoría "Todos" al principio de la lista.
  @override
  void initState() {
    super.initState();

    selectedSucursalId = GlobalData().selectedSucursalId;

    if (selectedSucursalId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasShownDialog) {
          _mostrarSucursales(context);
          _hasShownDialog = true;
        }
      });
    } else {
      _filterProductsBySucursal();
    }
    // Agrega "Todos" al inicio de la lista de categorías.
    categories = [
      {
        'nombre': 'Todos',
        'id': -1, // Un ID que no debería existir en tu base de datos
      }
    ];

    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    await fetchCategories();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchCategories() async {
    final response = await http
        .get(Uri.parse('http://137.184.190.92/productos/categorias/'));
    if (response.statusCode == 200) {
      setState(() {
        categories.addAll(
            json.decode(response.body)); // Aquí usamos addAll en lugar de =
        selectedCategory ??= categories[0]['nombre'];
      });
    } else {
      print('Error al obtener las categorías');
    }
  }

  void _filterProductsBySucursal() async {
    print('Sucursal seleccionada: $selectedSucursalId');
    if (selectedSucursalId != null) {
      // Paso 1: Obtener los productos de una sucursal específica
      final inventoryResponse = await http
          .get(Uri.parse('http://137.184.190.92/sucursales/inventarios/'));
      if (inventoryResponse.statusCode == 200) {
        var allInventory = json.decode(inventoryResponse.body) as List;
        var filteredInventory = allInventory.where((inventoryItem) {
          return inventoryItem['sucursal'] == selectedSucursalId;
        }).toList();

        final productDetailsResponse = await http.get(
            Uri.parse('http://137.184.190.92/productos/productosdetalle/'));
        var allProductDetails =
            json.decode(productDetailsResponse.body) as List;

        var relevantProductDetails = allProductDetails.where((productDetail) {
          return filteredInventory
              .map((inventoryItem) => inventoryItem['productodetalle'])
              .contains(productDetail['id']);
        }).toList();

        List<int> productIdsFromDetails =
            relevantProductDetails.map<int>((productDetail) {
          return productDetail['producto']['id'];
        }).toList();

        // Paso 2: Filtramos por descuento_porcentaje mayor a 0
        final productsResponse = await http
            .get(Uri.parse('http://137.184.190.92/productos/productos/'));
        if (productsResponse.statusCode == 200) {
          var allProducts = json.decode(productsResponse.body) as List;

          var productsWithDiscount = allProducts.where((product) {
            var discountPercentageString = product['descuento_porcentaje'];
            double? discountPercentage;
            try {
              discountPercentage = double.parse(discountPercentageString);
            } catch (e) {
              print('Error al convertir descuento_porcentaje a número: $e');
              return false;
            }
            return productIdsFromDetails.contains(product['id']) &&
                discountPercentage > 0;
          }).toList();

          // Paso 3 y 4: Asignar a products y displayedProducts
          setState(() {
            products = productsWithDiscount;
            displayedProducts = List.from(productsWithDiscount);
          });
        } else {
          print('Error al obtener los productos');
        }
      } else {
        print('Error al obtener el inventario');
      }
    } else {
      print('No hay sucursal seleccionada');
    }
  }

  Future<void> _mostrarSucursales(BuildContext context) async {
    // Hacer la solicitud a la API
    final response = await http
        .get(Uri.parse('http://137.184.190.92/sucursales/sucursales/'));
    print('respuesta   ${response.body}');
    if (response.statusCode == 200) {
      // Si la llamada a la API es exitosa, parsear el JSON.
      List<Sucursal> sucursales = (json.decode(response.body) as List)
          .map((data) => Sucursal.fromJson(data))
          .toList();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          // Utiliza MediaQuery para obtener la altura y anchura de la pantalla
          double screenHeight = MediaQuery.of(context).size.height;
          double screenWidth = MediaQuery.of(context).size.width;

          return Dialog(
            backgroundColor: const Color(0xFF1E272E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Bordes redondeados
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              width: screenWidth * 0.9, // Ocupa un 90% del ancho de la pantalla
              height: screenHeight *
                  0.8, // Ocupa un 80% de la altura de la pantalla
              child: Column(
                children: [
                  const Text(
                    "STYLO STORE",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "UBICACIONES",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(), // Línea divisoria
                  Expanded(
                    child: ListView.builder(
                      itemCount: sucursales.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            ListTile(
                              onTap: () {
                                setState(() {
                                  selectedSucursalId = sucursales[index].id;
                                  GlobalData().selectedSucursalId =
                                      selectedSucursalId; // Aquí actualizamos el valor static
                                  _filterProductsBySucursal();
                                });
                                Navigator.pop(context);
                              },
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              title: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.white),
                                  children: <TextSpan>[
                                    const TextSpan(
                                        text: 'Sucursal: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(text: sucursales[index].nombre),
                                  ],
                                ),
                              ),
                              subtitle: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.white),
                                  children: <TextSpan>[
                                    const TextSpan(
                                        text: 'Dirección: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(text: sucursales[index].direccion),
                                  ],
                                ),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TallerLoadingScreen4(
                                        tallerId: sucursales[index].id,
                                        // Aquí pasas los parámetros que necesita LocationScreen, si los hay.
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Ver en el mapa",
                                  style: TextStyle(color: Color(0xFF1E272E)),
                                ),
                              ),
                            ),
                            const Divider(), // Línea divisoria
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
      );
    } else {
      // Si la llamada a la API falla, muestra un error.
      throw Exception('Failed to load sucursales');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 250, 250),
      appBar: AppBarActiTone(
        onStoreIconPressed: () => _mostrarSucursales(context),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height:
                        10, // Espacio entre las recomendaciones y el carrusel
                  ),
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 200, // Cambia esto para modificar la altura
                      autoPlay: true, // Autoplay para el carrusel
                      viewportFraction:
                          1.0, // Esto hará que la imagen ocupe toda la pantalla en ancho
                      // Añadimos estas líneas para los indicadores:
                      enableInfiniteScroll: true,
                      pauseAutoPlayOnTouch: true,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          // Aquí puedes actualizar algún estado relacionado con el índice de la imagen actual si es necesario
                        });
                      },
                    ),
                    items: imageUrls.map((url) {
                      return Container(
                        margin: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              10.0), // Añadimos bordes redondeados
                          boxShadow: const [
                            BoxShadow(
                              color: Colors
                                  .black26, // Cambia este color para la sombra
                              offset: Offset(0.0, 4.0),
                              blurRadius: 5.0,
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10.0)),
                          child: Image.network(
                            url,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                  child: Text('Error al cargar la imagen.'));
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(
                    height:
                        20, // Aumenté el espacio entre el carrusel y el título
                  ),
                  const Text(
                    "🎉 Ropa con Descuento 🎉",
                    style: TextStyle(
                      fontSize: 28, // Aumenté el tamaño de la fuente
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E272E),
                    ),
                  ),
                  const SizedBox(
                    height:
                        15, // Aumenté el espacio entre el título y lo que sigue
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(15.0), // Bordes redondeados
                      color: const Color(0xFF1E272E),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: categories.map((category) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = category['nombre'];
                                int selectedCategoryId = category['id'];

                                // Si la categoría seleccionada es "Todos", mostramos solo productos con descuento.
                                if (selectedCategory == "Todos") {
                                  displayedProducts = products.where((product) {
                                    double descuento = double.parse(
                                        product['descuento_porcentaje']
                                            .toString());
                                    return descuento >
                                        0; // Filtra productos que tienen algún descuento.
                                  }).toList();
                                } else {
                                  // Filtrado por categoría específica y también que tengan descuento.
                                  List<dynamic> filteredProducts =
                                      products.where((product) {
                                    double descuento = double.parse(
                                        product['descuento_porcentaje']
                                            .toString());
                                    return product['categoria'] ==
                                            selectedCategoryId &&
                                        descuento > 0;
                                  }).toList();
                                  displayedProducts = filteredProducts;
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical:
                                      10.0), // Ampliado el padding vertical
                              child: Row(
                                children: [
                                  // Aquí hacemos una elección del ícono basado en la categoría
                                  categoryIcon(
                                      category['nombre'].replaceAll('Ã±', 'ñ')),
                                  const SizedBox(width: 5.0),
                                  Text(
                                    category['nombre'].replaceAll('Ã±', 'ñ'),
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                      fontWeight:
                                          selectedCategory == category['nombre']
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(10.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio:
                          1 / 1.6, // Ajustado para más espacio vertical
                    ),
                    itemCount: displayedProducts.length,
                    itemBuilder: (context, index) {
                      double precio = double.parse(
                          displayedProducts[index]['precio'].toString());
                      double descuento = double.parse(displayedProducts[index]
                              ['descuento_porcentaje']
                          .toString());
                      final discountedPrice =
                          precio - (precio * (descuento / 100));

                      return SizedBox(
                        width: double.infinity,
                        child: Card(
                          color: const Color(0xFF1E272E),
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.all(8.0), // Reducido a 8.0
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(
                                        productId: displayedProducts[index]
                                            ['id']),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    displayedProducts[index]['imagenes'][0]
                                        ['ruta_imagen'],
                                    fit: BoxFit.cover,
                                    height: 90,
                                    width: 100, // Reducido a 80
                                  ),
                                  const SizedBox(height: 4),
                                  Flexible(
                                    child: Text(
                                      displayedProducts[index]['nombre']
                                          .replaceAll('Ã±', 'ñ'),
                                      style: const TextStyle(
                                          fontSize: 12, // Reducido a 12
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (descuento > 1) ...[
                                    Text(
                                      'Antes: Bs${displayedProducts[index]['precio']}',
                                      style: const TextStyle(
                                          fontSize: 10, // Reducido a 10
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      'Ahora: Bs${discountedPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 10, // Reducido a 10
                                          fontWeight: FontWeight.bold,
                                          color: Colors.yellow),
                                    ),
                                  ] else ...[
                                    Text(
                                      'Precio: Bs${displayedProducts[index]['precio']}',
                                      style: const TextStyle(
                                        fontSize: 10, // Reducido a 10
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
    );
  }

  Widget categoryIcon(String categoryName) {
    switch (categoryName) {
      case 'Todos':
        return const Icon(Icons.list, color: Colors.white);
      case 'Niños':
        return const Icon(Icons.boy,
            color: Colors
                .white); // Aquí puedes usar cualquier ícono representativo para niños
      case 'Niñas':
        return const Icon(Icons.girl,
            color: Colors.white); // Y aquí uno para niñas
      case 'Bebes':
        return const Icon(Icons.baby_changing_station,
            color: Colors.white); // Aquí uno para bebés
      default:
        return const SizedBox
            .shrink(); // No muestra ningún ícono si no coincide con las categorías anteriores
    }
  }
}
