class VcPanelData {
  String selectedFile = "";
  String selectedInputDevice = "";
  String selectedOutputDevice = "";
  double sliderValue = 0.0;
  bool isConverting = false;
  bool isMonitoring = false;
  int threhold = -60;
  int pitch = 0;
  double indexRate = 0;
  double rmsMixRate = 0.0;
  double blockTime = 0.25;
  double crossfadeLength = 0.05;
  double extraTime = 2.5;
  bool iNoiseReduce = true;
  bool oNoiseReduce = true;

  Map<String, dynamic> toJson() => {
        'pth_path': selectedFile,
        'index_path': selectedFile,
        'sg_input_device': selectedInputDevice,
        'sg_output_device': selectedOutputDevice,
        'threhold': threhold,
        'pitch': pitch,
        'index_rate': indexRate,
        'rms_mix_rate': rmsMixRate,
        'block_time': blockTime,
        'crossfade_length': crossfadeLength,
        'extra_time': extraTime,
        'I_noise_reduce': iNoiseReduce,
        'O_noise_reduce': oNoiseReduce,
      };
}
