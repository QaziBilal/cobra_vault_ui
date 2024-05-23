import 'dart:async';
import 'dart:io';

import 'package:audio_recorder/model/Recording.dart';
import 'package:audio_recorder/model/Recording1.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Record audiorecord;
  late AudioPlayer audioPlayer;
  bool isrecording = false;
  String? audioPath = "";
  late Timer _timer;
  int _secondsElapsed = 0;
  bool isplay = false;

  List<Recording1> _list1 = [];

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void stopTimer() {
    _timer.cancel();
    setState(() {
      _secondsElapsed = 0;
    });
  }

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    audiorecord = Record();
    getExternalStorage();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    audiorecord.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<void> startRecording() async {
    try {
      if (await audiorecord.hasPermission()) {
        final appDocDirectory = await getExternalStorageDirectory();
        String recordingpath =
            '${appDocDirectory!.path}/Standard Recording_${_list1.length + 1}.m4a';
        await audiorecord.start(path: recordingpath);
        startTimer();
        setState(() {
          isrecording = true;
          audioPath = recordingpath;
        });
      }
    } catch (e) {
      print("Error Start Recording : $e");
    }
  }

  Future<void> stopRecoring() async {
    try {
      await audiorecord.stop();

      stopTimer();
      getExternalStorage();
      setState(() {
        isrecording = false;
      });
    } catch (e) {
      print("Error Stop Recording = $e");
    }
  }

  Future<void> playRecording() async {
    try {
      Source urlsource = UrlSource(audioPath!);
      await audioPlayer.play(urlsource);
      print("Url Source:  $urlsource");
    } catch (e) {
      print("Error Play Recording = $e");
    }
  }

  Future<void> playLatestRecording(String audionewPath) async {
    try {
      Source urlsource = UrlSource(audionewPath);
      await audioPlayer.play(urlsource);
    } catch (e) {
      print("Error Play Recording = $e");
    }
  }

  Future<void> getExternalStorage() async {
    final directory = await getExternalStorageDirectory();
    final path = directory!.path;

    final files = Directory(path).listSync();

    _list1.clear();

    for (var file in files) {
      if (file is File) {
        final filepath = file.path;
        final fileName = filepath.split('/').last;
        _list1.add(Recording1(path: file.path, name: fileName));
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Audio Recorder"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 2,
                  child: _list1.length == null
                      ? Center(
                          child: Text(
                          "No Data!",
                          style: TextStyle(fontSize: 20),
                        ))
                      : ListView.builder(
                          itemCount: _list1.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text("${_list1[index].name}"),
                              trailing: IconButton(
                                  icon: Icon(Icons.play_arrow),
                                  onPressed: () {
                                    setState(() {
                                      isplay = true;
                                    });
                                    playLatestRecording(_list1[index].path);
                                  }),
                            );
                          })),
              SizedBox(
                height: 50,
              ),
              Text(
                'Recording Time: $_secondsElapsed seconds',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                  onPressed: isrecording ? stopRecoring : startRecording,
                  child: isrecording
                      ? const Text(
                          "Stop Recording",
                          style: TextStyle(fontSize: 20),
                        )
                      : Text("Start Recording",
                          style: TextStyle(fontSize: 20))),
              SizedBox(
                height: 100,
              ),
            ]),
      ),
    );
  }
}
