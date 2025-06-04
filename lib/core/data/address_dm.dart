class AddressData {
  final String id;
  final String address; // For street
  final String city;
  final String zipCode;
  final String state;
  final String? landmark; // Added landmark as optional

  const AddressData({
    required this.id,
    required this.address,
    required this.city,
    required this.zipCode,
    required this.state,
    this.landmark,
  });
}
