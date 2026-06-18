import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  bool hidePassword = true;

  final TextEditingController
      fullNameController =
          TextEditingController(
    text: "Mohamed Yasir",
  );

  final TextEditingController
      passwordController =
          TextEditingController(
    text: "12345678",
  );

  final TextEditingController
      phoneController =
          TextEditingController(
    text: "01XXXXXXXXXX",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Edit Profile"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 20),

            Stack(
              alignment:
                  Alignment.bottomRight,

              children: [

                const CircleAvatar(
                  radius: 65,
                  backgroundColor:
                      Color(0xffeeeeee),
                  child: Icon(
                    Icons.person,
                    size: 70,
                    color: Colors.grey,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    // Add image picker later
                  },

                  child: Container(
                    padding:
                        const EdgeInsets
                            .all(10),

                    decoration:
                        const BoxDecoration(
                      color:
                          Colors.orange,
                      shape:
                          BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.camera_alt,
                      color:
                          Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            _buildField(
              icon: Icons.person_outline,
              label: "Full Name",
              controller:
                  fullNameController,
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  passwordController,

              obscureText:
                  hidePassword,

              decoration:
                  InputDecoration(
                filled: true,
                fillColor:
                    const Color(
                        0xfff4f4f4),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(12),
                  borderSide:
                      BorderSide.none,
                ),

                prefixIcon:
                    const Icon(
                  Icons.lock_outline,
                ),

                labelText:
                    "Password",

                suffixIcon:
                    IconButton(
                  icon: Icon(
                    hidePassword
                        ? Icons
                            .visibility
                        : Icons
                            .visibility_off,
                  ),

                  onPressed: () {
                    setState(() {
                      hidePassword =
                          !hidePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 15),

            _buildField(
              icon: Icons.phone_outlined,
              label:
                  "Phone Number",
              controller:
                  phoneController,
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(
                          context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Profile Updated",
                      ),
                    ),
                  );
                },

                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      Colors.green,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                                12),
                  ),
                ),

                child: const Text(
                  "Save",
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required TextEditingController
        controller,
  }) {
    return TextField(
      controller: controller,

      decoration: InputDecoration(
        filled: true,
        fillColor:
            const Color(0xfff4f4f4),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
                  12),
          borderSide:
              BorderSide.none,
        ),

        prefixIcon: Icon(icon),

        labelText: label,
      ),
    );
  }
}



