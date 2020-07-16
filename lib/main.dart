import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool downloading = false;
  var progressString = "0%";
  String downloadStart = "...جاري التنزيل";

  var isDownloadContainerVisible = false;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String downloadableUrl = "https://server11.mp3quran.net/sds/112.mp3";

  String filePath;

  var error = '';

  double progress = 0;
  bool isBtnVisible = false;

  Future<void> downloadFile(String url) async {
    Dio dio = Dio();

    setState(() {
      progressString = "0%";
      downloadStart = "downloading...";
      downloading = true;
      isDownloadContainerVisible = true;
    });
    try {
      await dio.download(url, filePath, onReceiveProgress: (
        rec,
        total,
      ) {
        print("Rec: $rec , Total: $total");
        setState(() {
          progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
        });
      });
      // await dio.downloadUri(
      //   Uri.parse(url),
      //   filePath,
      //   options: Options(
      //       headers: {
      //         'Content-Type': 'application/json',
      //         'SessionToken':
      //             'H4sIAAAAAAAAAJVTPXMbNxAF5VEsSqIoWVY87jypUih3ww8p9rixTDq2EtrWmMxk7IaD3C2PsHDACdijKBeZpMx/yA/IZPIz0qbKpMgvSJVUqVx5D8RZJ8tFzALgPew+7D68/fUftmwNa0c6DRQmwTDlBtsPdQBzNIrLIBYRCq24OQt6zx4PwVr6OlQTjfnwv797n95dYlt9tv6NNsdCJY90bmyfrUxpj7TFF6wp7CM+g4M4FerIwGzAVr7IpXzCU0B2bfCSz3gouUrCIRoiuDtgm0OkGiqEyJqLOHsiw5FIgYKWR/oY1An7jtUGbPVrC+ah0XlmPbLm0/v87C1ELWZcnRU3e2gjhgnPJfYWJ8i6AwoKSYew1CH0OoTnOoT9C1lUzLrncSUga38Ii8shjm3P8dQkXIlXvAhDdudDqKqpxNgUKoIYFB4ZPRGS5O5cZhMKwdFRnECw4eHFJOJpSJ0IVUhcka5uvRP6pby2Yg3W+l91V9xE93yU0xWeb57d+4S5373ni72GbM2Z6JZbybONwhMBeSIoPIE/ftn4q/3byRJjc8M23FmOQgZ9jjB9+UPtq+d48wodZqcrju+PX36e02PVWsjqrd32bme3u7uHNA3IE8iyjG5oXZqKUq7AyxW8IxfzxS6xmwN2g1N7iYLYvfERmFS4fr1i2zzHqTbiFcQj3ZPawmiEbLsyEve1lsCLt2xE9McM6UpqhxcEWwP2cdV2l+jXIBbYmxqtROQTGonU33J5IKU+hdiDzQVYNmI9vJkUrH2wkREZntNedfhhjGyzUulAu9Gtu8OKTdYcQAONeTmH64WdIi5d1f6yjZQrUj0egpmJCDxaV5N0XA1rZmAm2lBwBFTZsYevGR4LfVAVu5TYwOINUvdEMKPNJ20ZrbHHyXPP4CQX5q0eq5aPLyq0Y6f6lKAHaSb1GYAdcXtc6lS3OhqPgKclcBUhmo4PH/vPdYR87GsrG1tFHBcPnpsSWZlp6rvMmjv3bTkPF/IG3gi/3zLf//nT63+XWO0FW55xmcM8Y0XKjut453whA78LvT/ufUFuoVHgxaQhu/5Zd2+/273d7XTae53P97utzp19NzpvAONR/ZE+BgAA',
      //       },
      //       method: "POST",
      //       extra: {

      //       }),
      // );
    } catch (e) {
      print(e);
    }

    setState(() {
      downloading = false;
      progressString = "";
      downloadStart = "";
      isBtnVisible = true;
    });

    print("Download completed");
  }

  Future<void> requestPermission() async {
    try {
      final status = await Permission.storage.request();
      PermissionStatus _permissionStatus = status;
      if (_permissionStatus.isGranted) {
        openFile(downloadableUrl);
      } else if (_permissionStatus.isDenied) {
        showError("");
      } else if (_permissionStatus.isPermanentlyDenied) {
        showError("");
        AppSettings.openAppSettings();
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = "";
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error =
            'Permission denied - please ask the user to enable it from the app settings';
      }
      if (Platform.isIOS) showError("");
    } catch (_) {
      if (Platform.isIOS) showError("");

      return;
    }
  }

  void openFile(String url) async {
    var dir;
    if (Platform.isAndroid) {
      dir = (await getExternalStorageDirectory()).path;
    } else {
      dir = (await getApplicationDocumentsDirectory()).path;
    }
    filePath = "$dir/${url.substring(url.lastIndexOf('/') + 1)}";
    print("file path $filePath");

    File file = new File(filePath);
    var isExist = await file.exists();
    if (isExist) {
      print('file exists----------');
      await OpenFile.open(filePath);
      setState(() {
        isDownloadContainerVisible = false;
        isBtnVisible = false;
      });
    } else {
      print('file does not exist----------');
      downloadFile(url);
    }
  }

  void showError(String error) {
    scaffoldKey.currentState.hideCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(
          error,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Row dismissPopupButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            setState(() {
              isDownloadContainerVisible = false;
              isBtnVisible = false;
            });
          },
        ),
      ],
    );
  }

  Widget ShowOrHideDownloadDialog() {
    return Visibility(
      visible: isDownloadContainerVisible,
      child: Center(
        child: Container(
          height: 120,
          width: 200,
          child: Card(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                dismissPopupButton(),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        downloading ? showDownloadString() : Container(),
                        buildOpenButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Visibility buildOpenButton() {
    return Visibility(
      visible: isBtnVisible,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        child: RaisedButton(
          color: Colors.red,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              "open",
              style: TextStyle(color: Colors.white),
            ),
          ),
          onPressed: () {
            setState(() {
              isDownloadContainerVisible = false;
            });
            print(filePath);
            openFile(downloadableUrl);
          },
        ),
      ),
    );
  }

  Column showDownloadString() {
    return Column(
      children: <Widget>[
        showCircularIndecator(),
        SizedBox(height: 8),
        RichText(
          text: TextSpan(children: <TextSpan>[
            TextSpan(
              text: "$progressString",
              style: TextStyle(color: Colors.black),
            ),
            TextSpan(
              text: downloadStart,
              style: TextStyle(color: Colors.black),
            ),
          ]),
        ),
      ],
    );
  }

  SizedBox showCircularIndecator() =>
      SizedBox(height: 20, width: 20, child: CircularProgressIndicator());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
          height: double.infinity,
          child: Column(
            children: <Widget>[
              Flexible(
                  child: Stack(
                children: <Widget>[Container(), ShowOrHideDownloadDialog()],
              )),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: requestPermission,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
