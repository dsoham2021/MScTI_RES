LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY top IS
    PORT (
        clk      : IN STD_LOGIC;                     -- 100 MHz board clock
        reset    : IN STD_LOGIC;                     -- Center button (BTNC)
        btn_up   : IN STD_LOGIC;                     -- Up button (BTNU)
        btn_down : IN STD_LOGIC;                     -- Down button (BTND)
        led      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- 16 Physical LEDs
    );
END top;

ARCHITECTURE structural OF top IS

    -- Declare debouncer
    COMPONENT debouncer IS
        PORT (
            clk     : IN STD_LOGIC;
            btn_in  : IN STD_LOGIC;
            btn_out : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Declare up_down_counter
    COMPONENT up_down_counter IS
        PORT (
            clk        : IN STD_LOGIC;
            reset      : IN STD_LOGIC;
            Count_up   : IN STD_LOGIC;
            Count_down : IN STD_LOGIC;
            count_out  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    -- Declare internal signals to connect the two
    SIGNAL clean_up   : STD_LOGIC;
    SIGNAL clean_down : STD_LOGIC;

BEGIN

    -- Instantiate the debouncer for the UP button
    debounce_up_inst : debouncer
    PORT MAP(
        clk     => clk,
        btn_in  => btn_up,  -- Raw bouncy input from board
        btn_out => clean_up -- Clean internal signal
    );

    -- Instantiate the debouncer for the DOWN button
    debounce_down_inst : debouncer
    PORT MAP(
        clk     => clk,
        btn_in  => btn_down,  -- Raw bouncy input from board
        btn_out => clean_down -- Clean internal signal
    );

    -- Instantiate the up_down_counter
    counter_inst : up_down_counter
    PORT MAP(
        clk        => clk,
        reset      => reset,      -- We don't debounce the reset line in this case
        Count_up   => clean_up,   -- Feed in the clean debounced signal
        Count_down => clean_down, -- Feed in the clean debounced signal
        count_out  => led         -- Route the counter output directly to the LEDs
    );

END structural;
