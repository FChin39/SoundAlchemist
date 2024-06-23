import sounddevice as sd

def is_valid_device(device):
    """Returns True if the device is likely to be a usable audio device."""
    name = device['name'].lower()
    if "virtual" in name or "loopback" in name:
        return False
    return True

def clean_device_name(name):
    """Clean the device name to ensure it can be properly displayed."""
    return ''.join(e for e in name if e.isalnum() or e.isspace()).strip()

def get_input_devices():
    devices = sd.query_devices()
    input_devices = [clean_device_name(device['name']) for device in devices if device['max_input_channels'] > 0 and is_valid_device(device)]
    unique_input_devices = list(dict.fromkeys(input_devices))  # Remove duplicates while preserving order
    return unique_input_devices

def get_output_devices():
    devices = sd.query_devices()
    output_devices = [clean_device_name(device['name']) for device in devices if device['max_output_channels'] > 0 and is_valid_device(device)]
    unique_output_devices = list(dict.fromkeys(output_devices))  # Remove duplicates while preserving order
    return unique_output_devices
