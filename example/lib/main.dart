import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:llama_cpp_dart/llama_cpp_dart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    File file = File(result.files.single.path!);

    ContextParams contextParams = ContextParams();
    // int size = 32768;
    // size = 8192 * 4;
    // contextParams.batch = 8192 ~/ 4;
    // contextParams.context = size;
    // contextParams.ropeFreqBase = 57200 * 4;
    // contextParams.ropeFreqScale = 0.75 / 4;
    Llama llama = Llama(file.path, ModelParams(), contextParams);

    const prompt = 'Hello';
    String llmResult = '';

    // Asynchronous generation
    await for (String token in llama.prompt(prompt).take(500)) {
      llmResult += token;
      print(token);
    }

    llama.dispose();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late int sumResult;
  late Future<int> sumAsyncResult;

  @override
  void initState() {
    super.initState();
    sumResult = 0;
    sumAsyncResult = Future.value(1);

    final modelParams = ModelParams();
    modelParams.get();
    // sumResult = llama_cpp_dart.sum(1, 2);
    // sumAsyncResult = llama_cpp_dart.sumAsync(3, 4);
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'This calls a native function through FFI that is shipped as source in the package. '
                  'The native code is built as part of the Flutter Runner build.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                Text(
                  'sum(1, 2) = $sumResult',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                FutureBuilder<int>(
                  future: sumAsyncResult,
                  builder: (BuildContext context, AsyncSnapshot<int> value) {
                    final displayValue =
                        (value.hasData) ? value.data : 'loading';
                    return Text(
                      'await sumAsync(3, 4) = $displayValue',
                      style: textStyle,
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
