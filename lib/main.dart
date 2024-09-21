import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_no_internet_widget/flutter_no_internet_widget.dart';
import 'package:hyrockers_gaming/firebase_options.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyrockers Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  InternetWidget(
          whenOffline: () => print('No Internet'), offline: FullScreenWidget(
        child: Scaffold(
          backgroundColor: Colors.white,
          body:  Center(child: Image.asset("assets/offline.png", height: MediaQuery.of(context).size.height
              , fit : BoxFit.cover, width:MediaQuery.of(context).size.width )),
        ),
      ),
          whenOnline: () => MyHomePage(),
          loadingWidget: const Center(child: CircularProgressIndicator()),
          online : Splash()) //Screen to navigate to once the splashScreen is done.
    );
  }
}


class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  void dispose(){
    super.dispose();
  }

  void initState(){
    super.initState();
    startTimer();
  }
  void startTimer() {
    // Create a periodic timer that runs the specified function every 30 seconds
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      // Call your function here
      Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=> MyHomePage()));
      print("Executing function every 30 seconds...");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        color: Color(0xfffcfcfe),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Image(
            image: AssetImage('assets/vidkl.gif'),
            fit: BoxFit.contain
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final String oneSignalAppId = "7b69fc8d-8420-4113-a1a3-de6b69810dad";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late final WebViewController controller;
  double progress = 0.0;

  void initState(){
    super.initState();
    OneSignal.initialize(oneSignalAppId);
    OneSignal.Notifications.requestPermission(true);
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progres) {
            setState(() {
              progress = progres / 100;
            });
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},

          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://cycledekhoj.in/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )..loadRequest(Uri.parse('https://hyrockersgaming.com/'));
    setState(() {

    });
    _firebaseMessaging.requestPermission();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _lastPressedAt;
  int c = 0 ;

  @override
  Widget build(BuildContext context) {
    int backButtonPressCount = 0;
    return  WillPopScope(
      onWillPop: () async {
        if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > Duration(seconds: 2)) {
          if (await controller.canGoBack()) {
            controller.goBack();
          } else {
            _lastPressedAt = DateTime.now();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Press back again to exit'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return false; // Do not exit the app
        } else {
          return true; // Allow exit the app
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          key: _scaffoldKey,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(10.0), // Set the desired height
            child: AppBar(
              backgroundColor: Colors.black,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(4.0), // Set the desired height
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 52.0),
            child: FloatingActionButton(
              onPressed: _refreshWebView,
              backgroundColor: Colors.white,
              child: Icon(Icons.replay_circle_filled_outlined,color: Colors.blueAccent,),
            ),
          ),
          body: WebViewWidget(controller: controller,
          ),
        ),
      ),
    );
  }

  Future<void> _refreshWebView() async {
    print("gghjjj");
    await controller.reload();
  }


  @override
  void dispose() {
    // TODO: Dispose a BannerAd object

    super.dispose();
  }
}