LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY up_down_counter IS
    PORT (
        clk        : IN STD_LOGIC;
        reset      : IN STD_LOGIC;
        Count_up   : IN STD_LOGIC;
        Count_down : IN STD_LOGIC;
        Count_out  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END up_down_counter;

ARCHITECTURE behavioral OF up_down_counter IS
    -- Internal mathematical counter used
    SIGNAL counter   : unsigned(15 DOWNTO 0) := (OTHERS => '0');

    -- We track the state using registers for the edge detection
    SIGNAL up_prev   : STD_LOGIC             := '0';
    SIGNAL down_prev : STD_LOGIC             := '0';
BEGIN

    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            -- Synchronous reset (no async here)
            IF reset = '1' THEN
                counter <= (OTHERS => '0');
            ELSE
                -- Check for a rising edge, which if detected, 
                -- then increment the counter.
                -- In this implementation using ELSIF, we give the 
                -- up button priority if both are pressed simultaneously
                IF up_prev = '0' AND Count_up = '1' THEN
                    counter <= counter + 1;
                ELSIF down_prev = '0' AND Count_down = '1' THEN
                    counter <= counter - 1;
                END IF;
            END IF;

            -- Update history regs for the next clock cycle
            up_prev   <= Count_up;
            down_prev <= Count_down;
        END IF;
    END PROCESS;

    -- Output block
    -- Map the internal unsigned signal to the output standard logic port
    count_out <= STD_LOGIC_VECTOR(counter);

END behavioral;
