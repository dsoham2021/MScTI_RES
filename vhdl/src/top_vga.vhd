LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.bram_image_pkg.ALL;

ENTITY top_vga IS
    PORT (
        clk    : IN STD_LOGIC;                      -- 100 MHz board clock
        reset  : IN STD_LOGIC;                      -- Optional but recommended button
        h_sync : OUT STD_LOGIC;                     -- Horizontal Sync to VGA port
        v_sync : OUT STD_LOGIC;                     -- Vertical Sync to VGA port
        vga_r  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- 4-bits for Red
        vga_g  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- 4-bits for Green
        vga_b  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)  -- 4-bits for Blue
    );
END top_vga;

ARCHITECTURE behavioral OF top_vga IS
    SIGNAL clk_div         : INTEGER RANGE 0 TO 3   := 0;
    SIGNAL pxl_tick        : STD_LOGIC              := '0';
    SIGNAL h_count         : INTEGER RANGE 0 TO 799 := 0;
    SIGNAL v_count         : INTEGER RANGE 0 TO 524 := 0;
    SIGNAL video_on        : STD_LOGIC              := '0';
    SIGNAL ram_address     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL video_ram       : frame_buffer_type := INIT_VIDEO_RAM;
    SIGNAL memory_data_out : STD_LOGIC_VECTOR(11 DOWNTO 0);
BEGIN

    -- Generate a tick every 4th cycle to create a 25 MHz pixel clock from the 100 MHz input
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF clk_div = 3 THEN
                clk_div  <= 0;
                pxl_tick <= '1';
            ELSE
                clk_div  <= clk_div + 1;
                pxl_tick <= '0';
            END IF;
        END IF;
    END PROCESS;

    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN -- Make sure we are synchronized to the board's clock
            IF pxl_tick = '1' THEN   -- Act only when our own 25 MHz enable pulses
                IF h_count = 799 THEN
                    h_count <= 0;
                    IF v_count = 524 THEN
                        v_count <= 0;
                    ELSE
                        v_count <= v_count + 1;
                    END IF;
                ELSE
                    h_count <= h_count + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Horizontal Constants:
    -- Active Video: 640 pixels (Counts 0 to 639)
    -- Front Porch: 16 pixels (Counts 640 to 655)
    -- Sync Pulse: 96 pixels (Counts 656 to 751)
    -- Back Porch: 48 pixels (Counts 752 to 799)
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF pxl_tick = '1' THEN -- Keep the value updates synchronized to the 25 MHz pixel grid
                IF h_count >= 656 AND h_count < 752 THEN
                    h_sync <= '0'; -- Active low during sync pulse
                ELSE
                    h_sync <= '1'; -- Idle high at all other times
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Vertical Constants:
    -- Active Video: 480 lines (Counts 0 to 479)
    -- Front Porch: 10 lines (Counts 480 to 489)
    -- Sync Pulse: 2 lines (Counts 490 to 491)
    -- Back Porch: 33 lines (Counts 492 to 524)
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF pxl_tick = '1' THEN -- Keep the value updates synchronized to the 25 MHz pixel grid
                IF v_count >= 490 AND v_count < 492 THEN
                    v_sync <= '0'; -- Active low during sync pulse
                ELSE
                    v_sync <= '1'; -- Idle high at all other times
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Video on signal V2
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF pxl_tick = '1' THEN -- Keep the value updates synchronized to the 25 MHz pixel grid
                -- Turn on the video signal only when we are within the smaller 256 x 256 pixels
                IF h_count < 256 AND v_count < 256 THEN
                    video_on    <= '1';
                    -- The main algorithm here is addr = v_count * 256 + h_count
                    -- We create the address for the RAM in 16 bits using v_count and h_count
                    -- Note that we can concatenate only because we use 256 pixels in total
                    -- So that at maximum only 8 bits are used, which we can left shift directly
                    ram_address <= STD_LOGIC_VECTOR(to_unsigned(v_count, 8)) & STD_LOGIC_VECTOR(to_unsigned(h_count, 8));
                ELSE
                    video_on <= '0';
                END IF;

            END IF;
        END IF;
    END PROCESS;

    -- -- Video on signal V1
    -- We avoid this version because the BRAMs in the FPGA act like async memory with an extra 
    -- register at the output that we cannot bypass. This means that when we ask the BRAM for
    -- a pixel color, it takes exactly one clock cycle for the color data to actually appear on 
    -- the output pins. Because video_on signal is also inside a clocked process, it also gets 
    -- delayed by exactly one clock cycle too. The blanking signal and our pixel colors will 
    -- thus be synchronized when they hit the VGA port.
    -- video_on <= '1' WHEN (h_count < 640 AND v_count < 480) ELSE
    --     '0';

    -- Output the memory data now using the calculated RAM address
    PROCESS (clk)
    BEGIN
        IF rising_edge (clk) THEN
            memory_data_out <= video_ram(to_integer(unsigned(ram_address)));
        END IF;
    END PROCESS;

    -- Combinational concurrent output block
    -- Finally, we output the RGB values concurrently to eliminate any extra delay
    -- to keep the color data aligned with the sync signals. No flip-flops are required.
    vga_r <= memory_data_out(11 DOWNTO 8) WHEN video_on = '1' ELSE
        "0000";
    vga_g <= memory_data_out(7 DOWNTO 4) WHEN video_on = '1' ELSE
        "0000";
    vga_b <= memory_data_out(3 DOWNTO 0) WHEN video_on = '1' ELSE
        "0000";

END behavioral;
