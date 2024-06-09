import subprocess

import subprocess

def install_dependencies():
    try:
        # Update and upgrade packages
        print("Updating package lists...")
        subprocess.run(['sudo', 'apt', 'update'], check=True)

        print("Upgrading packages...")
        subprocess.run(['sudo', 'apt', 'upgrade', '-y'], check=True)

        # Install PlatformIO
        print("Installing PlatformIO...")
        subprocess.run(['pip', 'install', '-U', 'platformio'], check=True)

        # Install esptool
        print("Installing esptool...")
        subprocess.run(['pip', 'install', '-U', 'esptool'], check=True)

        # Install build-essential for C/C++ compilers
        print("Installing build essentials...")
        subprocess.run(['sudo', 'apt-get', 'install', '-y', 'build-essential'], check=True)

        print("All dependencies installed successfully.")

    except subprocess.CalledProcessError as e:
        print(f"An error occurred while installing dependencies: {e}")
    except Exception as e:
        print(f"Error: {e}")

# Example usage:
install_dependencies()



def run_esptool_and_get_chip_info():
    try:
        # Run esptool command and capture output
        result = subprocess.run(['esptool.py', 'read_mac'], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        output = result.stdout.decode('utf-8')

        # Parse output to extract chip information
        for line in output.split('\n'):
            if line.startswith('Chip is'):
                chip_info = line.split('Chip is ')[1]
                return chip_info.split(' ')[0]

    except FileNotFoundError:
        print("esptool.py not found. Ensure it's installed and in your PATH.")
        return None
    except Exception as e:
        print(f"Error: {e}")
        return None

def run_platformio_for_chip(chip_info):
    try:
        target_map = { # Define here all the chip names and their corresponding PlatformIO environment
            'ESP32-D0WD-V3': 'esp32-devkitv1',
            'ESP8266EX': 'esp8266-nodemcu',
            'ESP32-C3': 'esp32c3-xiao',
            'ESP32-S3': 'esp32s3-xiao-cam',
        }

        if chip_info in target_map:
            print(f"Running PlatformIO for {chip_info}")
            target = target_map[chip_info]
            cmd = f'platformio run --target upload -e {target}'
            subprocess.run(cmd, shell=True)
        else:
            print("Chip not recognized for specific PlatformIO environment.")
    except Exception as e:
        print(f"Error running PlatformIO: {e}")

def main():
    install_dependencies()     # Install dependencies first
    chip_name = run_esptool_and_get_chip_info()    # Then detect chip information
    if chip_name:
        print(f"Detected chip: {chip_name}")
        run_platformio_for_chip(chip_name)      # Run PlatformIO command based on detected chip name
    else:
        print("Failed to detect the chip. Double check the connection and try again.")


# Run the main function
if __name__ == "__main__":
    main()
