LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY debouncer_tb IS
END debouncer_tb;

ARCHITECTURE sim OF debouncer_tb IS
    COMPONENT debouncer
        PORT (
            clk     : IN STD_LOGIC;
            btn_in  : IN STD_LOGIC;
            btn_out : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Local signals
    SIGNAL tb_clk       : STD_LOGIC := '0';
    SIGNAL tb_btn_in    : STD_LOGIC := '0';
    SIGNAL tb_btn_out   : STD_LOGIC;

    -- 100 MHz clock period means 10 ns
    CONSTANT CLK_PERIOD : TIME := 10 ns;

BEGIN
    -- Instantiate design under test (DUT)
    dut : debouncer PORT MAP(
        clk     => tb_clk,
        btn_in  => tb_btn_in,
        btn_out => tb_btn_out
    );

    -- Clock gneneration
    clk_process : PROCESS
    BEGIN
        tb_clk <= '0';
        WAIT FOR CLK_PERIOD / 2; -- 5 ns
        tb_clk <= '1';
        WAIT FOR CLK_PERIOD / 2; -- 5 ns
    END PROCESS;

    -- Bouncy stimulus process
    stim_proc : PROCESS IS
        -- Procedure to simulate bouncy button press
        PROCEDURE press_button_with_bounce IS
        BEGIN
            tb_btn_in <= '1';
            WAIT FOR 400 ns;
            tb_btn_in <= '0';
            WAIT FOR 200 ns;
            tb_btn_in <= '1';
            WAIT FOR 500 ns;
            tb_btn_in <= '0';
            WAIT FOR 300 ns;
            tb_btn_in <= '1'; -- Final stable pressed state
        END PROCEDURE;

        -- Procedure to simulate bouncy button release
        PROCEDURE release_button_with_bounce IS
        BEGIN
            tb_btn_in <= '0';
            WAIT FOR 300 ns;
            tb_btn_in <= '1';
            WAIT FOR 200 ns;
            tb_btn_in <= '0';
            WAIT FOR 400 ns;
            tb_btn_in <= '0'; -- Final stable released state
        END PROCEDURE;
    BEGIN

        -- We start with the button not pressed
        tb_btn_in <= '0';
        WAIT FOR 100 ns;

        -- Now simulate the press of the button
        -- The physical metal springs would make erratic contact
        -- This means our waiting time is chosen randomly here
        -- as defined in our procedure
        press_button_with_bounce;

        -- Finally, the button down would be pressed down properly
        -- We hold this button press for 15 microseconds. 
        -- Since it takes 8 us for the shift register to fill up completely
        WAIT FOR 15 us;

        -- Now simulate the release of the button,
        -- which causes the spring to bounce eratically as well
        release_button_with_bounce;

        -- Now release fully
        WAIT FOR 10 us;

        REPORT "Debouncer Simulation Complete!";

        -- Stop the simulation 
        -- Otherwise the clock process runs forever
        std.env.stop;
    END PROCESS;

END sim;
