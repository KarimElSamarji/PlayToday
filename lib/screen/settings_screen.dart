import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String username = '';
  String birthdate = '';
  String email = '';
  String password = '';
  var data;

  bool isEditingUsername = false;
  bool isEditingBirthdate = false;
  bool isEditingEmail = false;
  bool isEditingPassword = false;
  bool isPasswordVisible = false;

  TextEditingController usernameController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        // Document exists, you can access its data
        data = snapshot.data();
        if (data is Map<String, dynamic>) {
          setState(() {
            username = data['username'];
            email = data['email'];
            birthdate = data['birthday'];
            password = data['password'];
          });
        }
      }
    });
  }

  void _saveChanges() {
    // Perform the necessary actions to save the changes
    // e.g., update user information in a database
    setState(() {
      username = usernameController.text;
      birthdate = birthdateController.text;
      email = emailController.text;
      password = passwordController.text;

      isEditingUsername = false;
      isEditingBirthdate = false;
      isEditingEmail = false;
      isEditingPassword = false;
    });

    FirebaseFirestore.instance.collection('users').doc(data['uid']).update({
      'username': username,
      'email': email,
      'birthday': birthdate,
      'password': password
    });

    Fluttertoast.showToast(
      msg: 'Changes saved successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[800],
      textColor: Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    usernameController.text = username;
    birthdateController.text = birthdate;
    emailController.text = email;
    passwordController.text = password;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        titleTextStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSettingsItem(
              label: 'Username',
              value: username,
              isEditing: isEditingUsername,
              controller: usernameController,
              onPressedEdit: () {
                setState(() {
                  isEditingUsername = !isEditingUsername;
                  if (!isEditingUsername) {
                    usernameController.text = username;
                  }
                });
              },
            ),
            const SizedBox(height: 16.0),
            _buildSettingsItem(
              label: 'Birthdate',
              value: birthdate,
              isEditing: isEditingBirthdate,
              controller: birthdateController,
              onPressedEdit: () {
                setState(() {
                  isEditingBirthdate = !isEditingBirthdate;
                  if (!isEditingBirthdate) {
                    birthdateController.text = birthdate;
                  }
                });
              },
            ),
            const SizedBox(height: 16.0),
            _buildSettingsItem(
              label: 'Email',
              value: email,
              isEditing: isEditingEmail,
              controller: emailController,
              onPressedEdit: () {
                setState(() {
                  isEditingEmail = !isEditingEmail;
                  if (!isEditingEmail) {
                    emailController.text = email;
                  }
                });
              },
            ),
            const SizedBox(height: 16.0),
            _buildSettingsItem(
              label: 'Password',
              value: '********',
              isEditing: isEditingPassword,
              controller: passwordController,
              onPressedEdit: () {
                setState(() {
                  isEditingPassword = !isEditingPassword;
                  if (!isEditingPassword) {
                    passwordController.text = password;
                  }
                });
              },
              isPasswordField: true,
              isPasswordVisible: isPasswordVisible,
              onPressedVisibility: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required String label,
    required String value,
    required bool isEditing,
    required TextEditingController controller,
    required VoidCallback onPressedEdit,
    bool isPasswordField = false,
    bool isPasswordVisible = false,
    VoidCallback? onPressedVisibility,
  }) {
    const TextStyle labelStyle = TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    );

    const TextStyle valueStyle = TextStyle(
      fontSize: 16.0,
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            '$label: ',
            style: labelStyle,
          ),
        ),
        if (isEditing)
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller,
              obscureText: isPasswordField && !isPasswordVisible,
              style: valueStyle,
            ),
          )
        else
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: valueStyle,
            ),
          ),
        IconButton(
          icon: Icon(
            isEditing ? Icons.done : Icons.edit,
            color: Colors.blue,
          ),
          onPressed: onPressedEdit,
        ),
        if (isPasswordField)
          IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.blue,
            ),
            onPressed: onPressedVisibility,
          ),
      ],
    );
  }
}
