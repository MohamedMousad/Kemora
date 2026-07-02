import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  final g = GoogleSignIn();
  await g.signIn();
}
