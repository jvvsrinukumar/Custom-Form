import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:custom_form/core/data/user_model.dart';
import 'package:custom_form/ui/profile_page/cubit/profile_page_cubit.dart';
import 'package:custom_form/ui/profile_page/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a static initial user for the profile page
    final User initialUser = User(
      firstName: 'SpongeBob',
      lastName: 'SquarePants',
      email: 'spongebob@example.com',
      password: 'krabbypatty', // Will be displayed in a disabled field
    );

    return MaterialApp(
      title: 'User Profile App', // Updated title
      theme: ThemeData(
        primarySwatch: Colors.deepOrange, // Changed theme color
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider(
        create: (context) => ProfilePageCubit(initialUser),
        child: const ProfilePage(),
      ),
    );
  }
}
