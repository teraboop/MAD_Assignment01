import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _display = '0';
  double? _firstOperand;
  String? _pendingOperator;
  bool _shouldResetDisplay = false;
  String _equationText = '';

  static const Color _oliveBackground = Color(0xFF808000);
  static const Color _deepRedButton = Color(0xFF8B0000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _oliveBackground,
      body: Column(children: [
      Expanded(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          alignment: Alignment.bottomRight,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: _deepRedButton, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: _deepRedButton.withValues(alpha: 0.4),
                blurRadius: 8.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            _display,
            style: const TextStyle(
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      SizedBox(height: 360,
      child: Column(
        children: [
          Expanded(child: _buildRow(['C', '±', '%', 'AC'])),
          Expanded(child: _buildRow(['7', '8', '9', '/'])),
          Expanded(child: _buildRow(['4', '5', '6', 'x'])),
          Expanded(child: _buildRow(['1', '2', '3', '-'])),
          Expanded(child: _buildRow(['0', '.', '=', '+'])),
        ],
      ),
      ),
      ]),
    );
  }


  Widget _buildRow(List<String> labels) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: labels.map((label) {
      return SizedBox(
        width: 64,
        height: 64,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _deepRedButton,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _onButtonPressed(label),
          child: Text(label),
        ),
      );
    }).toList(),
  );}

  void _handleOperator(String op) {
    final typedValue = double.parse(_display);

    if (_pendingOperator == null) {
      _firstOperand = typedValue;
    } else {
      _firstOperand = _compute(_firstOperand!, typedValue, _pendingOperator!);
      _display = _formatResult(_firstOperand!);
    }

    _pendingOperator = op;
    _shouldResetDisplay = true;
  }

  void _handleEquals() {
    if (_pendingOperator == null) return;
    final typedValue = double.parse(_display);
    _firstOperand = _compute(_firstOperand!, typedValue, _pendingOperator!);
    _display = _formatResult(_firstOperand!);
    _pendingOperator = null;
    _shouldResetDisplay = true;
  }

  void _handleClearEntry() {
    _display = '0';
    _shouldResetDisplay = true;
    _firstOperand = null;
    _pendingOperator = null;
  }

  void _handleSignToggle() {
    if (_display.startsWith('-')) {
      _display = _display.substring(1);
    } else if (_display != '0') {
      _display = '-$_display';
    }
  }

  void _handlePercent() {
    final typedValue = double.parse(_display);
    _display = _formatResult(typedValue / 100);
  }

  void _handleAllClear() {
    _display = '0';
    _firstOperand = null;
    _pendingOperator = null;
    _shouldResetDisplay = false;
  }

  void _handleDigit(String digit) {
    if (_shouldResetDisplay) {
      _display = digit;
      _shouldResetDisplay = false;
    } else if (_display == '0') {
      _display = digit;
    } else {
      _display += digit;
    }
  }

  void _handleDecimal() {
    if (_shouldResetDisplay) {
      _display = '0.';
      _shouldResetDisplay = false;
    } else if (!_display.contains('.')) {
      _display += '.';
    }
  }

  void _onButtonPressed(String label) {
    if (label.isEmpty) return; // dummy/disabled button
    setState(() {
      if (_isDigit(label)) {
        _handleDigit(label);
      } else if (label == '.') {
        _handleDecimal();
      } else if (label == 'C') {
        _handleClearEntry();
      } else if (label == 'AC') {
        _handleAllClear();
      } else if (label == '±') {
        _handleSignToggle();
      } else if (label == '%') {
        _handlePercent();
      } else if (label == '=') {
        _handleEquals();
      } else {
        _handleOperator(label); // +, -, x, /
      }
    });
  }

bool _isDigit(String label) => RegExp(r'^[0-9]$').hasMatch(label);

  double _compute(double a, double b, String op) {
    switch (op) {
      case '+': return a + b;
      case '-': return a - b;
      case 'x': return a * b;
      case '/': return b == 0 ? 0 : a / b;
      default: return b;
    }
  }

  String _formatResult(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(8).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}
