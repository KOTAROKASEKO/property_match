from PIL import Image
import os

def create_icons():
    # Create Icons directory if it doesn't exist
    if not os.path.exists('Icons'):
        os.makedirs('Icons')

    # Open the source icon
    try:
        source_icon = Image.open('icon.png')
    except FileNotFoundError:
        print("Error: icon.png not found in the current directory")
        return
    except Exception as e:
        print(f"Error opening image: {e}")
        return

    # Define the required sizes and names
    icon_sizes = {
        'Icon-192.png': (192, 192),
        'Icon-512.png': (512, 512),
        'Icon-maskable-192.png': (192, 192),
        'Icon-maskable-512.png': (512, 512),
        'favicon.png': (16,16),
    }

    # Create each icon variant
    for filename, size in icon_sizes.items():
        try:
            # Create a copy of the source icon and resize it
            resized_icon = source_icon.copy()
            resized_icon = resized_icon.resize(size, Image.Resampling.LANCZOS)
            
            # Save the resized icon
            output_path = os.path.join('Icons', filename)
            resized_icon.save(output_path, 'PNG')
            print(f"Created {output_path}")
        except Exception as e:
            print(f"Error creating {filename}: {e}")

if __name__ == "__main__":
    create_icons()