import 'package:flutter/foundation.dart';

const bool isProduction = bool.fromEnvironment('dart.vm.product');

void dPrint(String msg) {
  if (!isProduction) {
    debugPrint('[${DateTime.now()}] $msg');
  }
}

void dtPrint(String title, String msg) {
  if (!isProduction) {
    debugPrint(
        '[$title/${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}.${DateTime.now().millisecond}] $msg');
  }
}

void dsPrint(String msg) {
  if (!isProduction) {
    String hms = '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';
    // String milli = '${DateTime.now().millisecond}${DateTime.now().microsecond}';
    String milli = '${DateTime.now().millisecond}';
    // debugPrint(StackTrace.current.toString());
    var frame = StackTrace.current.toString().split("\n")[1];
    var subStr = frame.substring(frame.indexOf(' ')).trim();
    var caller = subStr.substring(0, subStr.indexOf(' '));

    debugPrint('[$hms.$milli/$caller] $msg');
  }
}

void testPrint() {
  // debugPrint(StackTrace.current.toString());
  CustomTrace programInfo = CustomTrace(StackTrace.current);
  debugPrint(
      '${programInfo.fileName}, function: ${programInfo.functionName}, caller function: ${programInfo.callerFunctionName}, line: ${programInfo.lineNumber}, column(yay!): ${programInfo.columnNumber}');
}

// https://stackoverflow.com/questions/49966808/how-to-get-the-name-of-the-current-and-calling-function-in-dart

class CustomTrace {
  final StackTrace _trace;

  String fileName;
  String functionName;
  String callerFunctionName;
  int lineNumber;
  int columnNumber;

  CustomTrace(this._trace) {
    _parseTrace();
  }

  String _getFunctionNameFromFrame(String frame) {
    /* Just giving another nickname to the frame */
    var currentTrace = frame;

    /* To get rid off the #number thing, get the index of the first whitespace */
    var indexOfWhiteSpace = currentTrace.indexOf(' ');

    /* Create a substring from the first whitespace index till the end of the string */
    var subStr = currentTrace.substring(indexOfWhiteSpace);

    /* Grab the function name using reg expr */
    var indexOfFunction = subStr.indexOf(RegExp(r'[A-Za-z0-9]'));

    /* Create a new substring from the function name index till the end of string */
    subStr = subStr.substring(indexOfFunction);

    indexOfWhiteSpace = subStr.indexOf(' ');

    /* Create a new substring from start to the first index of a whitespace. This substring gives us the function name */
    subStr = subStr.substring(0, indexOfWhiteSpace);

    return subStr;
  }

  void _parseTrace() {
    /* The trace comes with multiple lines of strings, (each line is also known as a frame), so split the trace's string by lines to get all the frames */
    var frames = this._trace.toString().split("\n");

    /* The first frame is the current function */
    this.functionName = _getFunctionNameFromFrame(frames[0]);

    /* The second frame is the caller function */
    this.callerFunctionName = _getFunctionNameFromFrame(frames[1]);

    /* The first frame has all the information we need */
    var traceString = frames[0];

    /* Search through the string and find the index of the file name by looking for the '.dart' regex */
    var indexOfFileName = traceString.indexOf(RegExp(r'[A-Za-z]+.dart'));

    var fileInfo = traceString.substring(indexOfFileName);

    var listOfInfos = fileInfo.split(":");

    /* Splitting fileInfo by the character ":" separates the file name, the line number and the column counter nicely.
      Example: main.dart:5:12
      To get the file name, we split with ":" and get the first index
      To get the line number, we would have to get the second index
      To get the column number, we would have to get the third index
    */

    this.fileName = listOfInfos[0];
    this.lineNumber = int.parse(listOfInfos[1]);
    var columnStr = listOfInfos[2];
    columnStr = columnStr.replaceFirst(")", "");
    this.columnNumber = int.parse(columnStr);
  }
}
