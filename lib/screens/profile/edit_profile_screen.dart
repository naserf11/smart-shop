import 'package:flutter/material.dart';

class EditProfileScreen
    extends StatefulWidget {

  const EditProfileScreen({
    super.key,
  });

  @override
  State<EditProfileScreen>
      createState() =>
          _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  final nameController =
      TextEditingController(
    text: "Mohamed Yasir",
  );

  final emailController =
      TextEditingController(
    text:
        "yasir@email.com",
  );

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          "Edit Profile",
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(
          children: [

            TextField(
              controller:
                  nameController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Full Name",
              ),
            ),

            const SizedBox(
                height: 20),

            TextField(
              controller:
                  emailController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Email",
              ),
            ),

            const Spacer(),

            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                      context);
                },
                child:
                    const Text(
                  "Save Changes",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}