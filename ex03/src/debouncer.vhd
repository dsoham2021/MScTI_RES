LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY debouncer IS
    PORT (
        clk     : IN STD_LOGIC; -- 100 MHz board clock
        btn_in  : IN STD_LOGIC; -- Bouncy mechanical output
        btn_out : OUT STD_LOGIC -- Clean debounced output
    );
END debouncer;

ARCHITECTURE behavioral OF debouncer IS
    -- Counter for the 1 MHz clock we use to enable (7 bits for 0 to 99)
    SIGNAL clk_div_cnt : INTEGER RANGE 0 TO 99        := 0;
    SIGNAL tick_1MHz   : STD_LOGIC                    := '0';

    -- 8 bit history register (button must be stable for at least
    -- 8 microseconds before being registered as a valid press)
    SIGNAL shift_reg   : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
BEGIN

    -- Clock divider process
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF clk_div_cnt = 99 THEN
                clk_div_cnt <= 0;
                tick_1MHz   <= '1';
            ELSE
                clk_div_cnt <= clk_div_cnt + 1;
                tick_1MHz   <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Shift register process
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            -- We only shift when the 1 MHz tick is fired
            -- Because our shift reg is 8 bits long and each bit is only
            -- shifted every 1 microsecond, we induce a latency of 8 microseconds
            IF tick_1MHz = '1' THEN
                shift_reg <= shift_reg(6 DOWNTO 0) & (btn_in);
            END IF;
        END IF;
    END PROCESS;

    -- Output logic
    -- Equivalent to reduction AND compatible with older VHDL modes
    btn_out <= '1' WHEN shift_reg = x"FF" ELSE
        '0';

END behavioral;
