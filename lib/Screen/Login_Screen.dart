import 'package:flutter/material.dart';
import 'package:paytm_demo/Db_Helper/User_Db_Helper.dart';
import 'package:paytm_demo/Model/User_Model.dart';
import 'package:paytm_demo/Screen/Home_Screen.dart';
import 'package:paytm_demo/Screen/SignUp_Screen.dart';
import 'package:paytm_demo/Units/Validation.dart';
import 'package:paytm_demo/Units/strings.dart';
import 'package:paytm_demo/Widgets/TextUnit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login_Screen extends StatefulWidget {
  @override
  _Login_ScreenState createState() => _Login_ScreenState();
}

class _Login_ScreenState extends State<Login_Screen> {
  final formKey = new GlobalKey<FormState>();
  TextEditingController numberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FocusNode _numberFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool isCheck = false;
  bool userVaild = false;

  var dbHelper;
  String number, password;
  List<User> user_data;
  bool _toggleVisibility = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbHelper = DBHelper();
    fetch_data();
    // userTotalData = user_data;
  }

  void fetch_data() async {
    user_data = await dbHelper.getUser();
  }

  setSharedPref(String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("defaultUser");
    prefs.setString('defaultUser', number);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[900],
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Form(
            key: formKey,
            child: mainLayout(),
          ),
        ),
      ),
    );
  }

  Widget mainLayout() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height:50.0),
              loginText(),
              payText(),
              numberText(),
              numberTextField(),
              passwordText(),
              passwordTextField(),
              needText(),
              loginButton(),
              SizedBox(
                height: 10,
              ),
              createAccount(),
              SizedBox(
                height: 10,
              ),
              termAndConditionText()
            ],
          ),
        )
      ],
    );
  }



  Widget loginText() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CustomText(
        text: strings.loginOrCreateAccount,
        FontSize: 22,
        FontWeights: FontWeight.bold,
      ),
    );
  }

  Widget payText() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: CustomText(
        text: strings.payUsingUpi,
        FontSize: 16,
        color: Colors.blueGrey,
      ),
    );
  }

  Widget numberText() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 10),
      child: CustomText(
        text: strings.mobileNumber,
        color: Colors.blueGrey,
        FontSize: 17,
      ),
    );
  }

  Widget numberTextField() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: TextFormField(
        controller: numberController,
        onSaved: (val) => number = val,
        focusNode: _numberFocus,
        textInputAction: TextInputAction.next,
        validator: (value) =>validateNumber(value),
        onFieldSubmitted: (term) {
          _fieldFocusChange(context, _numberFocus, _passwordFocus);
        },
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget passwordText() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 10),
      child: CustomText(
        text: strings.password,
        color: Colors.blueGrey,
        FontSize: 17,
      ),
    );
  }

  Widget passwordTextField() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: TextFormField(
        controller: passwordController,
        onSaved: (val) => password = val,
        focusNode: _passwordFocus,
        textInputAction: TextInputAction.done,
        obscureText: _toggleVisibility,
        validator: (value) =>validatePassword(value),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _toggleVisibility = !_toggleVisibility;
              });
            },
            icon: _toggleVisibility
                ? Icon(Icons.visibility_off)
                : Icon(Icons.visibility),
          ),
        ),
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget needText() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.topRight,
        child: CustomText(
          text: strings.needHelp,
          color: Colors.lightBlue,
          FontSize: 16,
          FontWeights: FontWeight.w800,
        ),
      ),
    );
  }

  Widget loginButton() {
    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: () async {
          await validate_user();
          if (userVaild == true) {
            setSharedPref(number);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Home_Screen(number: number)));
          } else {
            return failAlert(context);
          }
        },
        child: Container(
          height: 50,
          width: 340,
          color: Colors.blue,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_open,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              CustomText(
                text: strings.proceedLogin,
                FontSize: 20,
                FontWeights: FontWeight.bold,
                color: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget createAccount() {
    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Signup_Screen()));
        },
        child: CustomText(
          text: strings.createAccount,
          color: Colors.lightBlue,
          FontSize: 18,
        ),
      ),
    );
  }

  Widget termAndConditionText() {
    return CustomText(
      text: strings.termAndCondition,
      maxLine: 2,
      color: Colors.grey,
    );
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void validate_user() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      for (int i = 0; i < user_data.length; i++) {
        print(user_data[i].number);
        print(number);
        if (user_data[i].number == number || user_data[i].password == password) {
          setState(() {
            userVaild = true;
          });
          break;
        }
      }
    }
  }

  clearName() {
    numberController.text='';
    passwordController.text='';
  }


  Future<void> failAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(text: strings.loginFail,FontSize: 16,),
          content: CustomText(text: strings.failMsg,FontSize: 14,),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

  }

}
