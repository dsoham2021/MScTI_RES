LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY alu IS
    PORT (
        A : IN signed(31 DOWNTO 0) := (OTHERS => '0');
        B : IN signed(31 DOWNTO 0) := (OTHERS => '0');
        F : IN STD_LOGIC_VECTOR (2 DOWNTO 0);

        R : OUT signed(31 DOWNTO 0) := (OTHERS => '0');
        S : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END alu;

ARCHITECTURE behavioral OF alu IS
BEGIN

    PROCESS (A, B, F)
        -- Variables are required for instant updates and setting S before passing the result R
        VARIABLE TEMP_SUM : signed (32 DOWNTO 0)          := (OTHERS => '0');
        VARIABLE R_VAR    : signed(31 DOWNTO 0)           := (OTHERS => '0');
        VARIABLE S_VAR    : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        -- Clear defaults at start for safety
        TEMP_SUM := (OTHERS => '0');
        R_VAR    := (OTHERS => '0');
        S_VAR    := (OTHERS => '0');

        CASE F IS
            WHEN "000" => R_VAR := (OTHERS => '0'); -- Function: 0
            WHEN "001" => R_VAR := A;               -- Function: A
            WHEN "010" => R_VAR := NOT A;           -- Function: NOT A
            WHEN "011" => R_VAR := A AND B;         -- Function: bitwise AND
            WHEN "100" => R_VAR := A OR B;          -- Function: bitwise OR
            WHEN "101" => R_VAR := A XOR B;         -- Function: bitwise XOR
            WHEN "110" =>
                R_VAR    := A + B; -- Function: A + B
                TEMP_SUM := signed('0' & A) + signed('0' & B);
            WHEN "111" =>
                R_VAR                := A - B; -- Function: A - B
                TEMP_SUM             := signed('0' & A) - signed('0' & B);
            WHEN OTHERS => R_VAR := (OTHERS => '0');
        END CASE;

        -- S_VAR is (Zero, Sign, Overflow, Carry)
        -- Zero flag
        IF R_VAR = 0 THEN
            S_VAR(3) := '1';
        END IF;

        -- Sign flag
        S_VAR(2) := R_VAR(31);

        -- Addition Overflow
        IF F = "110" THEN
            IF (A(31) = '0' AND B(31) = '0' AND R_VAR(31) = '1') OR
                (A(31) = '1' AND B(31) = '1' AND R_VAR(31) = '0') THEN
                S_VAR(1) := '1';
            END IF;

        -- Subtraction Overflow
        ELSIF F = "111" THEN
            IF (A(31) = '0' AND B(31) = '1' AND R_VAR(31) = '1') OR
                (A(31) = '1' AND B(31) = '0' AND R_VAR(31) = '0') THEN
                S_VAR(1) := '1';
            END IF;
        END IF;

        -- Carry flag
        S_VAR(0) := TEMP_SUM(32);

        R <= R_VAR; -- Update the variable at the end
        S <= S_VAR; -- Update the variable at the end
    END PROCESS;

END behavioral;
