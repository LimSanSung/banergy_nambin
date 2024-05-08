import 'package:flutter/material.dart';
import 'package:flutter_banergy/login/login_FirstApp.dart';
import 'package:flutter_banergy/login/login_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_banergy/login/signup/joinwidget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      home: JoinApp(),
    ),
  );
}

class JoinApp extends StatefulWidget {
  const JoinApp({super.key});

  @override
  State<JoinApp> createState() => _JoinAppState();
}

class _JoinAppState extends State<JoinApp> {
  //페이지 부분
  late final PageController _pageController;
  int _currentPageIndex = 0;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _dateController;
  String? _selectedGender;

  late List<Widget> _pages; // Declare _pages here

  // 회원가입 함수
  Future<void> _signup(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String name = _nameController.text;
    final String date = _dateController.text;
    final String? gender = _selectedGender;

    try {
      final response = await http.post(
        Uri.parse('http://192.168.121.174:3000/sign'),
        body: jsonEncode({
          'username': username,
          'password': password,
          'name': name,
          'date': date,
          'gender': gender,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        // 회원가입 성공 시
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text('밴러지 회원가입완료!!'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginApp(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 29, 171, 102),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      } else {
        // 실패 시
        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: const Text('입력한 정보를 확인해주세요.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 29, 171, 102),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('확인'),
                  ),
                ],
              );
            });
      }
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
    _dateController = TextEditingController();
    _formKey = GlobalKey<FormState>();

    // 각 필드에 대한 유효성 검사 함수 정의
    bool isIdValid() {
      String pattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$'; //영어 + 숫자 조합을 위함
      RegExp regex = RegExp(pattern);
      return regex.hasMatch(_usernameController.text) &&
          _usernameController.text.length >= 5; //5글자 이상
    }

    bool isPasswordValid() {
      String pattern =
          r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]+$'; //영어+숫자+특수기호 조합을 위함
      RegExp regex = RegExp(pattern);
      return regex.hasMatch(_passwordController.text) &&
          _passwordController.text.length >= 5;
    }

    bool isConfirmPasswordValid() {
      return _confirmPasswordController
              .text.isNotEmpty && //비었는지 + 위에 입력한 비밀번호와 동일한지 확인
          _confirmPasswordController.text == _passwordController.text;
    }

    bool isNameValid() {
      return _nameController.text.isNotEmpty;
    }

    // 모든 필드에 대한 유효성 검사를 수행하는 함수
    bool isFormValid() {
      return isIdValid() &&
          isPasswordValid() &&
          isConfirmPasswordValid() &&
          isNameValid();
    }

    // Initialize _pages after initializing controllers
    _pages = [
      StepOne(),
      StepTwo(),
      //StepThree(),
      StepFour(),
      StepFive(),
      StepSix(),
    ];
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _nextPage() {
    if (_currentPageIndex < _pages.length - 1) {
      setState(() {
        _currentPageIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      _signup(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              if (_currentPageIndex == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FirstApp()),
                );
              } else {
                _previousPage();
              }
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topCenter, // 페이지뷰를 위로 정렬
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _pages,
                ),
              ),
            ),
            Row(
              children: [
                if (_currentPageIndex != _pages.length - 1)
                  Expanded(
                    // Expanded를 추가하여 사용 가능한 최대 공간 할당
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _nextPage(),
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 29, 171, 102),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text(
                          '다음',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_currentPageIndex == _pages.length - 1)
                  Expanded(
                    // Expanded를 추가하여 사용 가능한 최대 공간 할당
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _signup(context),
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 29, 171, 102),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StepOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Align(
        alignment: Alignment.topCenter,
        child: TextFormField(
          decoration: const InputDecoration(
            hintText: '아이디를 입력해주세요.',
          ),
          validator: (value) {
            String pattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$';
            RegExp regex = RegExp(pattern);
            if (value == null || value.isEmpty) {
              return '아이디를 입력하세요.';
            } else if (!regex.hasMatch(value) || value.length < 5) {
              return '아이디는 5글자 이상의 영어 + 숫자 조합이어야 합니다.';
            }
            return null;
          },
        ),
      ),
    );
  }
}

class StepTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
              hintText: '비밀번호를 입력해주세요.',
            ),
            validator: (value) {
              String pattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]+$';
              RegExp regex = RegExp(pattern);

              if (value == null || value.isEmpty) {
                return '비밀번호를 입력하세요.';
              } else if (!regex.hasMatch(value) || value.length < 5) {
                return '비밀번호는 5글자 이상의 영어 + 숫자 + 특수문자 조합이어야 합니다.';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }
}

class StepThree extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const StepThree({
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: '비밀번호를 다시 입력해주세요.',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호 재확인.';
              } else if (value != passwordController.text) {
                return '비밀번호가 일치하지 않습니다.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class StepFour extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              hintText: '이름을 입력해주세요.',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이름을 입력하세요.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class StepFive extends StatefulWidget {
  String? selectedGender;

  StepFive({Key? key, this.selectedGender}) : super(key: key);

  void setSelectedGender(String? gender) {
    selectedGender = gender;
  }

  @override
  _StepFiveState createState() => _StepFiveState();
}

class _StepFiveState extends State<StepFive> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButton<String>(
            value: widget.selectedGender,
            onChanged: (String? value) {
              setState(() {
                widget.setSelectedGender(value); // 변경된 메서드를 호출하여 값을 설정합니다.
              });
            },
            items: <String>['남성', '여성', '기타']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class StepSix extends StatefulWidget {
  @override
  _StepSixState createState() => _StepSixState();
}

class _StepSixState extends State<StepSix> {
  late final TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = pickedDate.toString().substring(0, 10);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: _dateController,
            decoration: const InputDecoration(
              hintText: '날짜를 선택해주세요.',
            ),
            readOnly: true,
            onTap: () => _selectDate(context),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '날짜를 선택하세요.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

bool isIdValid(String value) {
  String pattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$';
  RegExp regex = RegExp(pattern);
  return regex.hasMatch(value) && value.length >= 5;
}

bool isPasswordValid(String value) {
  String pattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]+$';
  RegExp regex = RegExp(pattern);
  return regex.hasMatch(value) && value.length >= 5;
}
