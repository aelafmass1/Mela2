import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';

class ProfileUploadScreen extends StatefulWidget {
  final UserModel userModel;
  const ProfileUploadScreen({super.key, required this.userModel});

  @override
  State<ProfileUploadScreen> createState() => _ProfileUploadScreenState();
}

class _ProfileUploadScreenState extends State<ProfileUploadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
