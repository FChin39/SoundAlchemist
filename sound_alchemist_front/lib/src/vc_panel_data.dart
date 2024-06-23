class VcPanelData {
  String selectedFile;
  String selectedInputDevice;
  String selectedOutputDevice;
  double sliderValue;
  bool isConverting;
  bool isMonitoring;

  VcPanelData({
    this.selectedFile = 'None',
    this.selectedInputDevice = 'Default Input Device',
    this.selectedOutputDevice = 'Default Output Device',
    this.sliderValue = 0,
    this.isConverting = false,
    this.isMonitoring = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'selectedFile': selectedFile,
      'selectedInputDevice': selectedInputDevice,
      'selectedOutputDevice': selectedOutputDevice,
      'sliderValue': sliderValue,
      'isConverting': isConverting,
      'isMonitoring': isMonitoring,
    };
  }
}
