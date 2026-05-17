def generate_vhd_package():
    filename = "bram_image_pkg.vhd"

    with open(filename, "w") as f:
        # Write the VHDL Header
        f.write("library IEEE;\n")
        f.write("use IEEE.STD_LOGIC_1164.ALL;\n\n")
        f.write("package bram_image_pkg is\n")
        f.write(
            "    type frame_buffer_type is array (0 to 65535) of std_logic_vector(11 downto 0);\n"
        )
        f.write("    constant INIT_VIDEO_RAM : frame_buffer_type := (\n")

        # Generate the 256x256 pixels
        for y in range(256):
            for x in range(256):
                # Calculate 1D memory index
                index = (y * 256) + x

                # Algorithm pattern design
                # Red: XOR fractal pattern (0 to 15)
                r = (x ^ y) >> 4
                # Green: Horizontal gradient (0 to 15)
                g = x >> 4
                # Blue: Vertical gradient (0 to 15)
                b = y >> 4

                # Format to a 3-character hex string (e.g., "F0A")
                hex_color = f"{r:X}{g:X}{b:X}"

                # Write the line. The last element must NOT have a comma.
                if index == 65535:
                    f.write(f'        {index} => x"{hex_color}"\n')
                else:
                    f.write(f'        {index} => x"{hex_color}",\n')

        # Write the VHDL Footer
        f.write("    );\n")
        f.write("end package;\n")

    print(f"Successfully generated {filename} with 65,536 pixels!")


if __name__ == "__main__":
    generate_vhd_package()
