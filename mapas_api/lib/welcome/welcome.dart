import 'package:mapas_api/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  _WelcomeViewState createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  int _currentIndex = 0;
  late double _screenHeight;
  final CarouselController _carouselController = CarouselController();

  List<String> imgList = [
    'https://firebasestorage.googleapis.com/v0/b/driverexpress-ff785.appspot.com/o/carrousel_slider%2Fs1.png?alt=media&token=475ba402-9d9e-4ebf-85dc-f56ce5986a96',
    'https://firebasestorage.googleapis.com/v0/b/driverexpress-ff785.appspot.com/o/carrousel_slider%2Fs2.png?alt=media&token=b92b4bb4-f136-479b-a667-bfcc4b085641',
    'https://firebasestorage.googleapis.com/v0/b/driverexpress-ff785.appspot.com/o/carrousel_slider%2Fs3.png?alt=media&token=e31b032e-70b7-4869-b23a-3f8be86c7a2b',
    'https://firebasestorage.googleapis.com/v0/b/driverexpress-ff785.appspot.com/o/carrousel_slider%2Fs4.png?alt=media&token=615c5ae5-2369-4146-b31c-2f7b07e09726',
    'https://firebasestorage.googleapis.com/v0/b/driverexpress-ff785.appspot.com/o/carrousel_slider%2Fs5.png?alt=media&token=55888516-4429-4d0f-a70c-cbc3a402e718',
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstSeen();
  }

  _checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seen = (prefs.getBool('seen') ?? false);

    if (seen) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginView()));
    }
  }

  _setSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('seen', true);
  }

  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 134, 234, 138),
              Color.fromARGB(255, 41, 76, 1)
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: imgList.length,
                itemBuilder: (context, index, realIndex) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    margin: const EdgeInsets.all(15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.network(
                        imgList[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                    viewportFraction: 0.95,
                    height: _screenHeight * 0.8,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    }),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _currentIndex > 0
                      ? () {
                          _carouselController.previousPage();
                        }
                      : null,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                ...imgList.map((url) {
                  int index = imgList.indexOf(url);
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.green[700]
                          : Colors.grey,
                    ),
                  );
                }).toList(),
                IconButton(
                  onPressed: _currentIndex < imgList.length - 1
                      ? () {
                          _carouselController.nextPage();
                        }
                      : null,
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Opacity(
              opacity: _currentIndex == imgList.length - 1 ? 1 : 0.3,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 41, 76, 1), // Color verde oscuro
                  textStyle: const TextStyle(fontSize: 22),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: _currentIndex == imgList.length - 1
                    ? () {
                        _setSeen();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const LoginView()));
                      }
                    : null,
                child: const Text(
                  "Comenzar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
