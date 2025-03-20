import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gr_miniplayer/ui/login_page/login_page_model.dart';

// unfortunately I have to break my "Stateless only" rule because forms need state in flutter.
class LoginPageView extends StatefulWidget {
  const LoginPageView({super.key, required this.viewModel});

  final LoginPageModel viewModel;

  @override
  State<LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<LoginPageView> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 64, minHeight: 64),
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: ListenableBuilder(
          listenable: widget.viewModel, // to respond to error message changes
          builder: (context, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.viewModel.error != null) // error text if present
                  Text(
                    widget.viewModel.error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                TextFormField( // username field
                  controller: usernameController,
                  autocorrect: false,
                  autofillHints: ['username'],
                  maxLength: 64,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    counterText: '', // hide text length display
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username cannot be blank';
                    } 
                    return null;
                  },
                ),
                TextFormField( // password field
                  controller: passwordController,
                  obscureText: true,
                  autocorrect: false,
                  autofillHints: ['password'],
                  maxLength: 64,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    counterText: '', // hide text length display
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password cannot be blank';
                    } 
                    return null;
                  },
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton( // login button
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.viewModel.login(usernameController.text, passwordController.text);
                          usernameController.clear(); // clear username and
                          passwordController.clear(); // password from memory after login
                        }
                      }, 
                      child: Text('Login'),
                    ),
                    Spacer(),
                    ElevatedButton( // cancel button
                      onPressed: () {
                        usernameController.clear(); // clear username and
                        passwordController.clear(); // password from memory before close
                        widget.viewModel.close();
                      }, 
                      child: Text('Cancel')
                    ),
                  ],
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}