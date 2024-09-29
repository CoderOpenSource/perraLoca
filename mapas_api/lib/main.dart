import 'package:mapas_api/models/theme_provider.dart';


import 'package:flutter_overlay_window/flutter_overlay_window.dart';


import 'package:mapas_api/screens/auth/login_screen.dart';


import 'package:mapas_api/screens/client/loading_client_screen.dart';


import 'package:mapas_api/screens/taller/loading_taller_screen2.dart';


import 'package:mapas_api/screens/taller/postulacion_detalle_screen.dart';


import 'package:mapas_api/screens/taller/solicitud_detalle_screen.dart';


import 'package:mapas_api/services/firebase_messaging.dart';


import 'package:mapas_api/services/traffic_service.dart';


import 'package:mapas_api/themes/dark_theme.dart';


import 'package:mapas_api/themes/light_theme.dart';


import 'package:flutter/material.dart';


import 'package:provider/provider.dart';


import 'package:shared_preferences/shared_preferences.dart';


import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:mapas_api/blocs/blocs.dart';


import 'package:firebase_core/firebase_core.dart';


import 'package:firebase_messaging/firebase_messaging.dart';


void main() async {

  WidgetsFlutterBinding

      .ensureInitialized(); // Asegura la inicialización de los widgets


  await Firebase.initializeApp(); // Inicializa Firebase


  FirebaseMessaging.onBackgroundMessage(backgroundHandler);


  runApp(

    MultiBlocProvider(

      providers: [

        BlocProvider(create: (context) => GpsBloc()),

        BlocProvider(create: (context) => LocationBloc()),

        BlocProvider(

            create: (context) =>

                MapBloc(locationBloc: BlocProvider.of<LocationBloc>(context))),

        BlocProvider(

            create: (context) => SearchBloc(trafficService: TrafficService())),

      ],

      child: ChangeNotifierProvider(

        create: (_) => ThemeProvider(),

        child: const MyApp(),

      ),

    ),

  );

}


Future<void> backgroundHandler(RemoteMessage message) async {

  print("Handling a background message: ${message.messageId}");

}


class MyApp extends StatefulWidget {

  const MyApp({Key? key}) : super(key: key);


  @override

  _MyAppState createState() => _MyAppState();

}


class _MyAppState extends State<MyApp> {

  late Future<SharedPreferences> prefsFuture;


  OverlayEntry? overlayEntry;


  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


  bool? _isAuthenticated;


  @override

  void initState() {

    super.initState();


    prefsFuture = SharedPreferences.getInstance();


    _checkAuthentication();


    _registerOnMessageHandler();


    _registerOnMessageOpenedAppHandler();

  }


  void _registerOnMessageHandler() {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      // Aquí puedes verificar el tipo de mensaje y mostrar un widget adecuado


      if (message.data.containsKey('solicitud_id')) {

        _mostrarNotificacionSolicitudEnPrimerPlano(message);

      } else if (message.data.containsKey('postulacion_id')) {

        _mostrarNotificacionSolicitudEnPrimerPlano2(message);

      }

    });

  }


  void _registerOnMessageOpenedAppHandler() {

    print('notifiacion abierta');


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {

      if (message.data.containsKey('solicitud_id')) {

        String solicitudIdStr = message.data['solicitud_id'];


        int solicitudId = int.tryParse(solicitudIdStr) ?? 0;


        String clienteIdStr = message.data['cliente_id'];


        int clienteId = int.tryParse(clienteIdStr) ?? 0;


        // Navegar a un widget específico y pasar el solicitudId


        navigatorKey.currentState?.push(

          MaterialPageRoute(

            builder: (context) => SolicitudDetalleScreen(

              solicitudId: solicitudId,

              clienteId: clienteId,

              aceptado: false,

            ),

          ),

        );

      }


      if (message.data.containsKey('postulacion_id')) {

        String postulacionIdStr = message.data['postulacion_id'];


        int postulacionId = int.tryParse(postulacionIdStr) ?? 0;


        String tallerIdStr = message.data['taller_id'];


        int tallerId = int.tryParse(tallerIdStr) ?? 0;


        // Navegar a un widget específico y pasar el solicitudId


        navigatorKey.currentState?.push(

          MaterialPageRoute(

            builder: (context) => PostulacionDetalleScreen(

              postulacionId: postulacionId,

              tallerId: tallerId,

              aceptado: false,

            ),

          ),

        );

      }

    });

  }


  Future<void> _checkAuthentication() async {

    final prefs = await SharedPreferences.getInstance();


    final token = prefs.getString('accessToken');


    setState(() {

      _isAuthenticated = token != null && token.isNotEmpty;

    });

  }


  @override

  Widget build(BuildContext context) {

    return Consumer<ThemeProvider>(

      builder: (context, themeProvider, child) {

        return MaterialApp(

          navigatorKey: navigatorKey,

          debugShowCheckedModeBanner: false,

          title: 'Flutter Demo',

          theme: themeProvider.isDarkMode ? darkUberTheme : lightUberTheme,

          home: _isAuthenticated != true

              ? const LoginView() // Si no está autenticado, devuelve el LoginView


              : FutureBuilder<SharedPreferences>(

                  future: SharedPreferences.getInstance(),

                  builder: (context, snapshot) {

                    if (snapshot.connectionState == ConnectionState.waiting) {

                      // Mientras espera, muestra el indicador de carga


                      return const CircularProgressIndicator();

                    } else if (snapshot.hasError) {

                      // Si hay un error, muestra un widget de error


                      print(snapshot

                          .error); // Deberías reemplazar esto por un widget de error adecuado


                      return const ErrorIndicator(); // Suponiendo que tengas un widget para mostrar errores

                    } else if (snapshot.hasData) {

                      // Cuando se completa la operación asíncrona


                      final userType = snapshot.data!.getString('userType');


                      switch (userType) {

                        case 'cliente':


                          // Si el userType es 'cliente', muestra ClienteScreen


                          return const ClienteLoadingScreen(); // Debes reemplazar esto por tu pantalla de cliente


                        case 'taller':

                          return const TallerLoadingScreen2();


                        default:


                          // Para cualquier otro caso, puedes devolver un widget de 'No encontrado' o similar


                          return const NotFoundScreen(); // Un widget para cuando el userType no coincide

                      }

                    } else {

                      // En caso de que snapshot.data sea nulo


                      return const ErrorIndicator(); // Suponiendo que tengas un widget para mostrar errores

                    }

                  },

                ),

        );

      },

    );

  }


  void _mostrarNotificacionSolicitudEnPrimerPlano(RemoteMessage message) {

    WidgetsBinding.instance!.addPostFrameCallback((_) {

      // El MaterialApp ya debe estar construido en este punto.


      if (overlayEntry == null) {

        // Obtienes el OverlayState del contexto del MaterialApp.


        OverlayState? overlayState = navigatorKey.currentState!.overlay;


        // Creas el OverlayEntry.


        overlayEntry = _crearOverlayEntry(message);


        // Verificas que el OverlayState no sea nulo.


        if (overlayState != null) {

          overlayState.insert(overlayEntry!);

        } else {

          print('No se encontró un Overlay en el contexto actual');

        }

      }

    });

  }


  void _mostrarNotificacionSolicitudEnPrimerPlano2(RemoteMessage message) {

    WidgetsBinding.instance!.addPostFrameCallback((_) {

      // El MaterialApp ya debe estar construido en este punto.


      if (overlayEntry == null) {

        // Obtienes el OverlayState del contexto del MaterialApp.


        OverlayState? overlayState = navigatorKey.currentState!.overlay;


        // Creas el OverlayEntry.


        overlayEntry = _crearOverlayEntry2(message);


        // Verificas que el OverlayState no sea nulo.


        if (overlayState != null) {

          overlayState.insert(overlayEntry!);

        } else {

          print('No se encontró un Overlay en el contexto actual');

        }

      }

    });

  }


  OverlayEntry _crearOverlayEntry(RemoteMessage message) {

    int solicitudId = int.tryParse(message.data['solicitud_id']) ?? 0;


    int clienteId = int.tryParse(message.data['cliente_id']) ?? 0;


    // Obtiene los colores del tema actual


    Color themeColor = lightUberTheme

        .primaryColor; // Este es un ejemplo, ajusta según la configuración de tu tema


    return OverlayEntry(

      builder: (overlayContext) => Positioned(

        top: MediaQuery.of(overlayContext).padding.top,

        left: 0,

        right: 0,

        child: SafeArea(

          child: Container(

            padding:

                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),

            margin: const EdgeInsets.all(8.0),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(20.0),

              border: Border.all(color: themeColor),

            ),

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: [

                Text(

                  "Tienes una nueva solicitud de asistencia.",

                  style: TextStyle(color: themeColor, fontSize: 20),

                ),

                Row(

                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [

                    TextButton(

                      child: Text('Ignorar',

                          style: TextStyle(color: Colors.white)),

                      style: TextButton.styleFrom(

                        backgroundColor: Colors.red,

                      ),

                      onPressed: () {

                        _removeOverlay(); // Remueve el overlay

                      },

                    ),

                    SizedBox(

                      width: 100,

                    ),

                    TextButton(

                      child: Text('Ver', style: TextStyle(color: Colors.white)),

                      style: TextButton.styleFrom(

                        backgroundColor: themeColor,

                      ),

                      onPressed: () {

                        _removeOverlay(); // Remueve el overlay


                        navigatorKey.currentState?.push(

                          MaterialPageRoute(

                            builder: (context) => SolicitudDetalleScreen(

                              solicitudId: solicitudId,

                              clienteId: clienteId,

                              aceptado: false,

                            ),

                          ),

                        );

                      },

                    ),

                  ],

                ),

              ],

            ),

          ),

        ),

      ),

    );

  }


  OverlayEntry _crearOverlayEntry2(RemoteMessage message) {

    String postulacionIdStr = message.data['postulacion_id'];


    int postulacionId = int.tryParse(postulacionIdStr) ?? 0;


    String tallerIdStr = message.data['taller_id'];


    int tallerId = int.tryParse(tallerIdStr) ?? 0;


    // Obtiene los colores del tema actual


    Color themeColor = lightUberTheme

        .primaryColor; // Este es un ejemplo, ajusta según la configuración de tu tema


    return OverlayEntry(

      builder: (overlayContext) => Positioned(

        top: MediaQuery.of(overlayContext).padding.top,

        left: 0,

        right: 0,

        child: SafeArea(

          child: Container(

            padding:

                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),

            margin: const EdgeInsets.all(8.0),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(20.0),

              border: Border.all(color: themeColor),

            ),

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: [

                Text(

                  "Un taller te envio una postulación.",

                  style: TextStyle(color: themeColor, fontSize: 20),

                ),

                Row(

                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [

                    TextButton(

                      child: Text('Ignorar',

                          style: TextStyle(color: Colors.white)),

                      style: TextButton.styleFrom(

                        backgroundColor: Colors.red,

                      ),

                      onPressed: () {

                        _removeOverlay(); // Remueve el overlay

                      },

                    ),

                    SizedBox(

                      width: 100,

                    ),

                    TextButton(

                      child: Text('Ver', style: TextStyle(color: Colors.white)),

                      style: TextButton.styleFrom(

                        backgroundColor: themeColor,

                      ),

                      onPressed: () {

                        _removeOverlay(); // Remueve el overlay


                        navigatorKey.currentState?.push(

                          MaterialPageRoute(

                            builder: (context) => PostulacionDetalleScreen(

                              postulacionId: postulacionId,

                              tallerId: tallerId,

                              aceptado: false,

                            ),

                          ),

                        );

                      },

                    ),

                  ],

                ),

              ],

            ),

          ),

        ),

      ),

    );

  }


  void _removeOverlay() {

    overlayEntry?.remove();


    overlayEntry =

        null; // Asegúrate de volver a poner a null la variable para futuras notificaciones

  }


  void _mostrarSolicitudEnPrimerPlano(RemoteMessage message) {

    // Obtén los datos de la solicitud


    int solicitudId = int.tryParse(message.data['solicitud_id']) ?? 0;


    int clienteId = int.tryParse(message.data['cliente_id']) ?? 0;


    // Muestra un diálogo o un widget personalizado


    showDialog(

      context: navigatorKey.currentContext!,

      builder: (context) => AlertDialog(

        title: Text("Nueva Solicitud"),

        content: Text("Tienes una nueva solicitud de asistencia."),

        actions: <Widget>[

          TextButton(

            child: Text("Ignorar"),

            onPressed: () => Navigator.of(context).pop(),

          ),

          TextButton(

            child: Text("Ver"),

            onPressed: () {

              Navigator.of(context).pop(); // Cierra el diálogo


              // Redirigir a la pantalla de detalles


              navigatorKey.currentState?.push(

                MaterialPageRoute(

                  builder: (context) => SolicitudDetalleScreen(

                    solicitudId: solicitudId,

                    clienteId: clienteId,

                    aceptado: false,

                  ),

                ),

              );

            },

          ),

        ],

      ),

    );

  }

}


class ErrorIndicator extends StatelessWidget {

  const ErrorIndicator({super.key});


  @override

  Widget build(BuildContext context) {

    // Un simple placeholder para un widget de error


    return const Center(child: Text('Error occurred!'));

  }

}


class NotFoundScreen extends StatelessWidget {

  const NotFoundScreen({super.key});


  @override

  Widget build(BuildContext context) {

    // Un simple placeholder para un widget 'No encontrado'


    return const Center(child: Text('User type not found!'));

  }

}

