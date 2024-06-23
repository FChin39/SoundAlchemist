import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'vc_panel_data.dart';

class VcPanel extends StatefulWidget {
  const VcPanel({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VcPanelState createState() => _VcPanelState();
}

class _VcPanelState extends State<VcPanel> {
  final VcPanelData _data = VcPanelData();
  List<String> _inputDevices = [];
  List<String> _outputDevices = [];
  String _selectedInputDevice = "";
  String _selectedOutputDevice = "";

  @override
  void initState() {
    super.initState();
    _getAudioDevices();
  }

  Future<void> _getAudioDevices() async {
    await _fetchInputDevices();
    await _fetchOutputDevices();
  }

  Future<void> _fetchInputDevices() async {
    final url = Uri.parse('http://localhost:6231/inputDevices');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> devices = jsonDecode(response.body);
        setState(() {
          _inputDevices = devices.cast<String>();
          if (_inputDevices.isNotEmpty) {
            _selectedInputDevice = _inputDevices.first; // 设置默认值为第一个设备
          }
        });
      } else {
        throw Exception('Failed to load input devices');
      }
    } catch (e) {
      print('Error fetching input devices: $e');
    }
  }

  Future<void> _fetchOutputDevices() async {
    final url = Uri.parse('http://localhost:6231/outputDevices');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> devices = jsonDecode(response.body);
        setState(() {
          _outputDevices = devices.cast<String>();
          if (_outputDevices.isNotEmpty) {
            _selectedOutputDevice = _outputDevices.first; // 设置默认值为第一个设备
          }
        });
      } else {
        throw Exception('Failed to load output devices');
      }
    } catch (e) {
      print('Error fetching output devices: $e');
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _data.selectedFile = result.files.single.name;
      });
      _sendDataToServer();
    }
  }

  void _toggleConversion() {
    setState(() {
      _data.isConverting = !_data.isConverting;
    });
    _sendDataToServer();
  }

  void _toggleMonitoring() {
    setState(() {
      _data.isMonitoring = !_data.isMonitoring;
    });
    _sendDataToServer();
  }

  void _updateSliderValue(double value) {
    setState(() {
      _data.sliderValue = value;
    });
    _sendDataToServer();
  }

  void _updateInputDevice(String? newValue) {
    setState(() {
      _selectedInputDevice = newValue!;
      _data.selectedInputDevice = newValue;
    });
    _sendDataToServer();
    FocusScope.of(context).requestFocus(FocusNode()); // 取消焦点
  }

  void _updateOutputDevice(String? newValue) {
    setState(() {
      _selectedOutputDevice = newValue!;
      _data.selectedOutputDevice = newValue;
    });
    _sendDataToServer();
    FocusScope.of(context).requestFocus(FocusNode()); // 取消焦点
  }

  Future<void> _sendDataToServer() async {
    final url = Uri.parse('http://localhost:6231');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(_data.toJson()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to post data');
      }
    } catch (e) {
      print('Error posting data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SoundAlchemist RVC Panel'),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 600,
              minHeight: 800,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 音色选择
                Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Selected File:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(child: Text(_data.selectedFile)),
                            ElevatedButton(
                              onPressed: _pickFile,
                              child: const Text('Browse'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // 输入和输出设备选择
                Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // 输入设备选择
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Input Device:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              DropdownButton<String>(
                                value: _selectedInputDevice.isEmpty
                                    ? null
                                    : _selectedInputDevice,
                                hint: const Text('Select Input Device'),
                                items: _inputDevices.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onTap: _fetchInputDevices, // 点击时更新输入设备列表
                                onChanged: _updateInputDevice,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // 输出设备选择
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Output Device:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              DropdownButton<String>(
                                value: _selectedOutputDevice.isEmpty
                                    ? null
                                    : _selectedOutputDevice,
                                hint: const Text('Select Output Device'),
                                items: _outputDevices.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onTap: _fetchOutputDevices, // 点击时更新输出设备列表
                                onChanged: _updateOutputDevice,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 音调调整
                Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Pitch Adjustment:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 300, // 限制音调调整组件的宽度
                          child: Slider(
                            value: _data.sliderValue,
                            min: -10,
                            max: 10,
                            divisions: 20,
                            label: _data.sliderValue.round().toString(),
                            onChanged: _updateSliderValue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 操作按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                      width: 180,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _toggleConversion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _data.isConverting ? Colors.purple : null,
                          foregroundColor:
                              _data.isConverting ? Colors.white : null,
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: Text(_data.isConverting
                            ? 'Stop Conversion'
                            : 'Start Conversion'),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _toggleMonitoring,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _data.isMonitoring ? Colors.purple : null,
                          foregroundColor:
                              _data.isMonitoring ? Colors.white : null,
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: Text(_data.isMonitoring
                            ? 'Stop Monitoring'
                            : 'Start Monitoring'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
