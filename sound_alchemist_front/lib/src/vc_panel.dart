import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'vc_panel_data.dart';

class VcPanel extends StatefulWidget {
  const VcPanel({super.key});

  @override
  _VcPanelState createState() => _VcPanelState();
}

class _VcPanelState extends State<VcPanel> {
  final VcPanelData _data = VcPanelData();
  List<String> _inputDevices = [];
  List<String> _outputDevices = [];
  String _selectedInputDevice = "";
  String _selectedOutputDevice = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeDefaultDevices();
  }

  Future<void> _loadConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _data.selectedFile = prefs.getString('selectedFile') ?? "";
      _selectedInputDevice = prefs.getString('selectedInputDevice') ?? "";
      _selectedOutputDevice = prefs.getString('selectedOutputDevice') ?? "";
      _data.sliderValue = prefs.getDouble('sliderValue') ?? 0.0;
      _data.isMonitoring = prefs.getBool('isMonitoring') ?? false;
      _data.isConverting = prefs.getBool('isConverting') ?? false;
      _data.pitch = prefs.getInt('pitch') ?? 0;
    });
  }

  Future<void> _saveConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFile', _data.selectedFile);
    await prefs.setString('selectedInputDevice', _selectedInputDevice);
    await prefs.setString('selectedOutputDevice', _selectedOutputDevice);
    await prefs.setDouble('sliderValue', _data.sliderValue);
    await prefs.setBool('isMonitoring', _data.isMonitoring);
    await prefs.setBool('isConverting', _data.isConverting);
    await prefs.setInt('pitch', _data.pitch);
  }

  Future<void> _initializeDefaultDevices() async {
    setState(() {
      _isLoading = true;
    });
    await _getAudioDevices();
    await _loadConfig();

    if (_inputDevices.isNotEmpty && _selectedInputDevice.isEmpty) {
      _selectedInputDevice = _inputDevices.first;
    }

    if (_outputDevices.isNotEmpty && _selectedOutputDevice.isEmpty) {
      _selectedOutputDevice = _outputDevices.first;
    }

    setState(() {
      _data.isMonitoring = false;
      _data.isConverting = false;
      _isLoading = false;
    });

    if (_selectedInputDevice.isNotEmpty) {
      _updateInputDevice(_selectedInputDevice);
    }
    if (_selectedOutputDevice.isNotEmpty) {
      _updateOutputDevice(_selectedOutputDevice);
    }

    await _saveConfig();
    await _sendDataToServer();
  }

  Future<void> _getAudioDevices() async {
    try {
      await _fetchInputDevices();
      await _fetchOutputDevices();
    } catch (e) {
      _showErrorDialog("Error loading audio devices: $e");
    }
  }

  Future<void> _fetchInputDevices() async {
    final url = Uri.parse('http://localhost:6242/inputDevices');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> devices =
            jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _inputDevices = devices
              .cast<String>()
              .where((device) => device.contains('MME'))
              .toList();
        });
      } else {
        throw Exception('Failed to load input devices');
      }
    } catch (e) {
      throw Exception('Error fetching input devices: $e');
    }
  }

  Future<void> _fetchOutputDevices() async {
    final url = Uri.parse('http://localhost:6242/outputDevices');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> devices =
            jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _outputDevices = devices
              .cast<String>()
              .where((device) => device.contains('MME'))
              .toList();
        });
      } else {
        throw Exception('Failed to load output devices');
      }
    } catch (e) {
      throw Exception('Error fetching output devices: $e');
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _data.selectedFile = result.files.single.path!;
      });
      await _saveConfig();
      await _sendDataToServer();
    }
  }

  Future<void> _toggleConversion() async {
    if (_data.selectedFile.isEmpty) {
      _showErrorDialog(
          "Please select a model file before starting conversion.");
      return;
    }
    if (_selectedInputDevice.isEmpty || _selectedOutputDevice.isEmpty) {
      _showErrorDialog(
          "Please select both input and output devices before starting conversion.");
      return;
    }

    setState(() {
      _data.isConverting = !_data.isConverting;
    });
    try {
      await _sendDataToServer();
      if (_data.isConverting) {
        await _startConversion();
      } else {
        await _stopConversion();
      }
      await _saveConfig();
    } catch (e) {
      _showErrorDialog("Failed to toggle conversion: $e");
    }
  }

  Future<void> _toggleMonitoring() async {
    if (_selectedInputDevice.isEmpty || _selectedOutputDevice.isEmpty) {
      _showErrorDialog(
          "Please select both input and output devices before starting monitoring.");
      return;
    }

    setState(() {
      _data.isMonitoring = !_data.isMonitoring;
    });
    try {
      await _sendDataToServer();
      await _saveConfig();
    } catch (e) {
      _showErrorDialog("Failed to toggle monitoring: $e");
    }
  }

  Future<void> _updateSliderValue(double value) async {
    setState(() {
      _data.sliderValue = value;
    });
    await _saveConfig();
    await _sendDataToServer();
  }

  Future<void> _updatePitchValue(int value) async {
    setState(() {
      _data.pitch = value;
    });
    await _saveConfig();
    await _sendDataToServer();
  }

  Future<void> _updateInputDevice(String? newValue) async {
    if (newValue == null || newValue.isEmpty) return;
    setState(() {
      _selectedInputDevice = newValue;
      _data.selectedInputDevice = newValue;
    });
    await _saveConfig();
    await _sendDataToServer();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> _updateOutputDevice(String? newValue) async {
    if (newValue == null || newValue.isEmpty) return;
    setState(() {
      _selectedOutputDevice = newValue;
      _data.selectedOutputDevice = newValue;
    });
    await _saveConfig();
    await _sendDataToServer();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> _sendDataToServer() async {
    if (_selectedInputDevice.isEmpty || _selectedOutputDevice.isEmpty) {
      _showErrorDialog("Input and output devices cannot be empty.");
      return;
    }

    final url = Uri.parse('http://localhost:6242/config');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          ..._data.toJson(),
          'inputDevice': _selectedInputDevice,
          'outputDevice': _selectedOutputDevice
        }),
      );
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to post data. Status code: ${response.statusCode}. Response body: ${response.body}');
      }
    } catch (e) {
      print('Exception caught: $e'); // Add this line for more debug information
      throw Exception('Error posting data: $e');
    }
  }

  Future<void> _startConversion() async {
    final url = Uri.parse('http://localhost:6242/start');
    try {
      final response = await http.post(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to start conversion');
      }
    } catch (e) {
      throw Exception('Error starting conversion: $e');
    }
  }

  Future<void> _stopConversion() async {
    final url = Uri.parse('http://localhost:6242/stop');
    try {
      final response = await http.post(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to stop conversion');
      }
    } catch (e) {
      throw Exception('Error stopping conversion: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isConversionOrMonitoringDisabled = _data.isConverting || _isLoading;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SoundAlchemist RVC Panel'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
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
                                'Selected Model:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      _data.selectedFile.isNotEmpty
                                          ? _data.selectedFile
                                          : 'No file selected',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: isConversionOrMonitoringDisabled
                                        ? null
                                        : _pickFile,
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
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text(
                                          'Input Device:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 10),
                                        DropdownButton<String>(
                                          value: _selectedInputDevice.isEmpty
                                              ? null
                                              : _selectedInputDevice,
                                          hint:
                                              const Text('Select Input Device'),
                                          items:
                                              _inputDevices.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 320),
                                                child: Text(
                                                  value,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged:
                                              isConversionOrMonitoringDisabled
                                                  ? null
                                                  : _updateInputDevice,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text(
                                          'Output Device:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 10),
                                        DropdownButton<String>(
                                          value: _selectedOutputDevice.isEmpty
                                              ? null
                                              : _selectedOutputDevice,
                                          hint: const Text(
                                              'Select Output Device'),
                                          items: _outputDevices
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 320),
                                                child: Text(
                                                  value,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged:
                                              isConversionOrMonitoringDisabled
                                                  ? null
                                                  : _updateOutputDevice,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  ElevatedButton(
                                    onPressed: isConversionOrMonitoringDisabled
                                        ? null
                                        : _getAudioDevices,
                                    child: const Text('Update Devices'),
                                  ),
                                ],
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
                                width: 600,
                                child: Slider(
                                  value: _data.pitch.toDouble(),
                                  min: -20,
                                  max: 20,
                                  divisions: 40,
                                  label: _data.pitch.round().toString(),
                                  onChanged: isConversionOrMonitoringDisabled
                                      ? null
                                      : (double value) {
                                          _updatePitchValue(value.toInt());
                                        },
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
                          // SizedBox(
                          //   width: 180,
                          //   height: 60,
                          //   child: ElevatedButton(
                          //     onPressed: _toggleMonitoring,
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor:
                          //           _data.isMonitoring ? Colors.purple : null,
                          //       foregroundColor:
                          //           _data.isMonitoring ? Colors.white : null,
                          //       textStyle: const TextStyle(fontSize: 18),
                          //     ),
                          //     child: Text(_data.isMonitoring
                          //         ? 'Stop Monitoring'
                          //         : 'Start Monitoring'),
                          //   ),
                          // ),
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
