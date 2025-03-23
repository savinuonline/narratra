import 'package:flutter/material.dart';
import 'package:frontend/pages/add_account.dart';
import 'package:frontend/pages/update_mali.dart';
import 'package:frontend/settingsBackend/theme_provider.dart';
import 'package:ionicons/ionicons.dart';
import 'package:frontend/settingsBackend/theme_provider.dart';
import 'package:frontend/helpers/theme.dart';
import 'package:provider/provider.dart';

class ActionsPage extends StatefulWidget {
  const ActionsPage({super.key});

  @override
  State<ActionsPage> createState() => _ActionsPageState();
}

class _ActionsPageState extends State<ActionsPage> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final provider = Provider.of<ThemeProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
          Text(
            "Actions",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500
            ),
          ),

        const SizedBox(height: 10,),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.shade100,
                  ),
                  child: Icon(Ionicons.moon_outline, size: 26,
                  color: const Color.fromARGB(255, 214, 7, 7),
                  ),
                
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Dark Mode", 
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    )),
                  ],
                ),
                const Spacer(),
                Switch.adaptive(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    provider.toggleTheme(value);
                  },
                  activeColor: const Color.fromARGB(255, 20, 195, 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10,),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.shade100,
                  ),
                  child: Icon(Ionicons.person_add_outline, size: 26,
                  color: const Color.fromARGB(255, 214, 7, 7),),
                
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Add Account", 
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    )),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddAccount()),
                    );
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 227, 227, 227),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Ionicons.chevron_forward_outline),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 10,),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.shade100,
                  ),
                  child: Icon(Ionicons.mail_outline, size: 26,
                  color: const Color.fromARGB(255, 214, 7, 7),),
                
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Update Email", 
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    )),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UpdateMali()),
                    );
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 227, 227, 227),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Ionicons.chevron_forward_outline),
                  ),
                )  
              ],
            ),
          )

      ]
    );  
  }
}