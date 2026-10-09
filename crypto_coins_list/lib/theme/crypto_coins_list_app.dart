import 'package:flutter/material.dart';
import 'package:crypto_coins_list/features/crypto_list/view/view.dart';
import 'package:crypto_coins_list/router/router.dart';
import 'package:crypto_coins_list/theme/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CryptoCurrenciensList',
      theme: darkTheme,
      routes: routes,
      home: const CryptoListScreen(title: 'Crypto Currenciens List'),
    );
  }
}
