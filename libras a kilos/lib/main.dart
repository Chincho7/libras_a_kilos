import 'dart:io' show Platform;
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'custom_keyboard.dart';
import 'pages/formula_page.dart';
import 'services/ad_helper.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Force portrait mode for all devices
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize MobileAds first
    await MobileAds.instance.initialize();

    // Handle ATT for iOS before running the app
    if (Platform.isIOS) {
      await Future.delayed(const Duration(seconds: 1));
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }

    // Run the app before initializing ads
    runApp(const MyApp());

    // Initialize ads after the app is running
    final adHelper = AdHelper();
    await adHelper.initialize();
  } catch (e, stackTrace) {
    print('Error: $e');
    print('StackTrace: $stackTrace');
    // Run the app even if there's an error with ads
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Libras a Kilogramos',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        primaryColor: Color(0xFFD4CE38), // Changed from systemGreen to #d4ce38
        brightness: Brightness.light,
      ),
      home: ConversionScreen(),
    );
  }
}

class ConversionScreen extends StatefulWidget {
  const ConversionScreen({super.key});

  @override
  _ConversionScreenState createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  final TextEditingController _librasController = TextEditingController();
  final TextEditingController _kilosController = TextEditingController();
  bool _isLibras = true;
  final AdHelper _adHelper = AdHelper();

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    // Remove the delayed initialization here since it's handled in main()
  }

  void _convertLibrasToKilos(String value) {
    if (value.isEmpty) {
      _kilosController.text = '';
      return;
    }
    final double? libras = double.tryParse(value);
    if (libras != null) {
      final double kilos =
          libras * 0.45359237; // Conversion factor for pounds to kg
      String result =
          kilos.toStringAsFixed(3).replaceAll(RegExp(r'\.?0+$'), '');
      _kilosController.text = result;
    }
  }

  void _convertKilosToLibras(String value) {
    if (value.isEmpty) {
      _librasController.text = '';
      return;
    }
    final double? kilos = double.tryParse(value);
    if (kilos != null) {
      final double libras =
          kilos * 2.20462262; // Conversion factor for kg to pounds
      String result =
          libras.toStringAsFixed(3).replaceAll(RegExp(r'\.?0+$'), '');
      _librasController.text = result;
    }
  }

  void _swapFields() {
    setState(() {
      _isLibras = !_isLibras;
      final libras = _librasController.text;
      final kilos = _kilosController.text;

      if (_isLibras) {
        _librasController.text = kilos;
        _convertKilosToLibras(kilos);
      } else {
        _kilosController.text = libras;
        _convertLibrasToKilos(libras);
      }
    });
  }

  void _onKeyTap(String key) {
    final controller = _isLibras ? _librasController : _kilosController;
    if (key == 'backspace') {
      if (controller.text.isNotEmpty) {
        controller.text =
            controller.text.substring(0, controller.text.length - 1);
      }
    } else {
      if (key == '.' && controller.text.contains('.')) {
        return;
      }
      if (key == '-') {
        if (controller.text.contains('-') || controller.text.isNotEmpty) {
          return;
        }
      }
      controller.text += key;
    }

    if (_isLibras) {
      _convertLibrasToKilos(controller.text);
    } else {
      _convertKilosToLibras(controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final horizontalPadding = isTablet ? 32.0 : 16.0;

    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Libras a Kilogramos'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => const FormulaPage(),
              ),
            );
          },
          child: const Icon(
            CupertinoIcons.info_circle,
            color: Color(0xFFD4CE38), // Changed from systemGreen to #d4ce38
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          // Changed from Column to ListView
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16.0,
              ),
              child: ConstrainedBox(
                // Added ConstrainedBox
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 600 : double.infinity,
                  maxHeight: size.height - (isTablet ? 200 : 100),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Changed to min
                  children: [
                    const SizedBox(height: 8.0),
                    SizedBox(
                      width: double.infinity,
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          if (hasFocus) {
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                          }
                        },
                        child: CupertinoTextField(
                          controller:
                              _isLibras ? _librasController : _kilosController,
                          prefix: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              _isLibras ? 'lb' : 'kg',
                              style: const TextStyle(
                                  color: CupertinoColors.systemGrey),
                            ),
                          ),
                          placeholder: _isLibras
                              ? 'Ingrese Libras'
                              : 'Ingrese Kilogramos',
                          readOnly: true,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBackground,
                            border: Border.all(
                              color: CupertinoColors.systemGrey3,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: GestureDetector(
                        onTap: _swapFields,
                        child: const Icon(
                          CupertinoIcons.arrow_up_arrow_down,
                          size: 48.0,
                          color: Color(
                              0xFFD4CE38), // Changed from systemGreen to #d4ce38
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: double.infinity,
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          if (hasFocus) {
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                          }
                        },
                        child: CupertinoTextField(
                          controller:
                              _isLibras ? _kilosController : _librasController,
                          prefix: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              _isLibras ? 'kg' : 'lb',
                              style: const TextStyle(
                                  color: CupertinoColors.systemGrey),
                            ),
                          ),
                          placeholder: _isLibras
                              ? 'Ingrese Kilogramos'
                              : 'Ingrese Libras',
                          readOnly: true,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBackground,
                            border: Border.all(
                              color: CupertinoColors.systemGrey3,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: CupertinoButton.filled(
                        onPressed: () {
                          _librasController.clear();
                          _kilosController.clear();
                        },
                        child: const Text(
                          'Borrar',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomKeyboard(onKeyTap: _onKeyTap), // Single keyboard instance
                ValueListenableBuilder<bool>(
                  valueListenable: _adHelper.bannerAdLoaded,
                  builder: (context, isLoaded, child) {
                    print('Banner ad state changed: $isLoaded');
                    if (isLoaded && _adHelper.bannerAd != null) {
                      return Container(
                        alignment: Alignment.bottomCenter,
                        width: _adHelper.bannerAd!.size.width.toDouble(),
                        height: _adHelper.bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _adHelper.bannerAd!),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _adHelper.dispose();
    _librasController.dispose();
    _kilosController.dispose();
    super.dispose();
  }
}
