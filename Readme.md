## SoundAlchemist

### Overview

Unlike research-based projects, SoundAlchemist is an engineering project focused on productization and user experience. The project is based on the framework provided by the [RVC Project](https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI).

The key differences between SoundAlchemist and the RVC Project are:

1. **Trained new models**, improving voice conversion performance.
2. **Designed and developed API interfaces** that support both cloud and local deployment (this feature has been merged into the RVC Project).
3. **Implemented a more user-friendly interface** using Flutter.
4. **Optimized various details** to enhance user experience and streamline interactions.

With SoundAlchemist, users can smoothly apply voice conversion technology in real-world scenarios.

### How to Use

1. Download the pre-trained models from Hugging Face and replace the `assets` folder under the `sound_alchemist_server` directory with the extracted files.

   [Model Checkpoints](https://huggingface.co/XiaokaiQin/SoundAlchemistAssets/tree/main)

2. Follow the prompts in your editor to install the required dependencies.

3. Run `api.py` in the `sound_alchemist_server` directory:

   ```
   python api.py
   ```

4. Launch Flutter from the `sound_alchemist_front` directory:

   ```
   flutter run -d windows
   ```

5. Choose the model `20240611.pth` in the assets file.

6. Once set up, you can start converting voices by clicking the buttons in the interface.

**Enjoy!**

