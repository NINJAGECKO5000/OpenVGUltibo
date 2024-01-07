import numpy as np
from PIL import Image

def bmp_to_32bit_array(input_file, output_file):
    # Load the BMP image
    image = Image.open(input_file)

    # Convert the image to a NumPy array
    array = np.array(image)

    # Flatten the array to a 1D array
    flattened_array = array.flatten()

    # Convert the array to a 32-bit array
    bit32_array = flattened_array.astype(np.uint32)

    # Save the 32-bit array to a text file in the specified format
    with open(output_file, 'w') as file:
        file.write("unit cogwarebootimage;\n\ninterface\n\nconst\n  cogwareblob : array[1..{}]\n  of byte = (\n".
                   format(len(bit32_array)))

        for i, value in enumerate(bit32_array, start=1):
            if i % 16 == 0:
                file.write("${:02X},\n".format(value))
            else:
                file.write("${:02X}, ".format(value))

        file.write(");")

if __name__ == "__main__":
    input_file = "Input file"  # Change this to your input BMP file
    output_file = "output_arraycogware.txt"  # Change this to the desired output text file

    bmp_to_32bit_array(input_file, output_file)
