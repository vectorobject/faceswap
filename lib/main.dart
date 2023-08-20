import 'package:faceswap/settings.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'global.dart';
import 'home_view.dart';
import 'generated/l10n.dart';
import 'window_frame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Global.init();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(900, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Settings.darkTheme,
      builder: (context, value, child) => MaterialApp(
        builder: (context, child) {
          return WindowFrame(child: child!);
        },
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          S.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale != null) {
            for (var item in supportedLocales) {
              if (item.toLanguageTag() == locale.toLanguageTag()) {
                return item;
              }
            }
            for (var item in supportedLocales) {
              if (item.languageCode == locale.languageCode &&
                  item.countryCode == locale.countryCode) {
                return item;
              }
            }
            for (var item in supportedLocales) {
              if (item.languageCode == locale.languageCode) {
                return item;
              }
            }
          }
          return const Locale('en', '');
        },
        supportedLocales: S.delegate.supportedLocales,
        debugShowCheckedModeBanner: false,
        title: 'FaceSwap',
        themeMode: Settings.darkTheme.value ? ThemeMode.dark : ThemeMode.light,
        theme: FlexThemeData.light(
          colors: const FlexSchemeColor(
            primary: Color(0xff00296b),
            primaryContainer: Color(0xffa0c2ed),
            secondary: Color(0xffd26900),
            secondaryContainer: Color(0xffffd270),
            tertiary: Color(0xff5c5c95),
            tertiaryContainer: Color(0xffc8dbf8),
            appBarColor: Color(0xffc8dcf8),
            error: null,
          ),
          surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
          blendLevel: 7,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 10,
            blendOnColors: false,
            useTextTheme: true,
            drawerBackgroundSchemeColor: SchemeColor.onPrimary,
            menuSchemeColor: SchemeColor.primary,
          ),
          keyColors: const FlexKeyColors(),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
        ),
        darkTheme: FlexThemeData.dark(
          colors: const FlexSchemeColor(
            primary: Color(0xffb1cff5),
            primaryContainer: Color(0xff3873ba),
            secondary: Color(0xffffd270),
            secondaryContainer: Color(0xffd26900),
            tertiary: Color(0xffc9cbfc),
            tertiaryContainer: Color(0xff535393),
            appBarColor: Color(0xff00102b),
            error: null,
          ),
          surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
          blendLevel: 13,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 20,
            useTextTheme: true,
            drawerBackgroundSchemeColor: SchemeColor.onPrimary,
            menuSchemeColor: SchemeColor.primary,
          ),
          keyColors: const FlexKeyColors(),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
        ),
        home: const HomeView(),
      ),
    );
  }
}
