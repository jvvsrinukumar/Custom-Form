import 'package:custom_form/core/data/address_dm.dart';
import 'package:custom_form/ui/address_entry/address_entry_page.dart';
import 'package:custom_form/ui/login/login_page.dart';
import 'package:custom_form/ui/phone_number/phone_number_page.dart';
import 'package:custom_form/ui/register/register_page.dart';
import 'package:custom_form/ui/login_phone/login_phone_page.dart'; // Add this import
import 'package:flutter/material.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Navigation'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          ElevatedButton(
            child: const Text('Login Page'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            child: const Text('Address Page (No Data)'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddressEntryPage()),
              );
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            child: const Text('Address Page (With Data)'),
            onPressed: () {
              // Create a sample AddressData object
              const sampleAddress = AddressData(
                id: '1',
                address: '123 Main St',
                city: 'Anytown',
                zipCode: '12345',
                state: 'CA',
                landmark: 'Near the park',
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddressEntryPage(initialAddressData: sampleAddress),
                ),
              );
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            child: const Text('Register Page'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            child: const Text('Phone Number Page'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PhoneNumberPage()),
              );
            },
          ),
          const SizedBox(height: 16.0), // Add some spacing if needed
          ElevatedButton(
            child: const Text('Login with Phone'), // New Button
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPhonePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
