LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY alu_tb IS
END alu_tb;

ARCHITECTURE sim OF alu_tb IS
    COMPONENT alu
        PORT (
            A : IN signed(31 DOWNTO 0);
            B : IN signed(31 DOWNTO 0);
            F : IN STD_LOGIC_VECTOR (2 DOWNTO 0);

            R : OUT signed(31 DOWNTO 0);
            S : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
        );
    END COMPONENT;

    -- Local signals at safe default values
    SIGNAL tb_A : signed(31 DOWNTO 0)           := (OTHERS => '0');
    SIGNAL tb_B : signed(31 DOWNTO 0)           := (OTHERS => '0');
    SIGNAL tb_F : STD_LOGIC_VECTOR (2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tb_R : signed(31 DOWNTO 0);
    SIGNAL tb_S : STD_LOGIC_VECTOR (3 DOWNTO 0);

BEGIN
    -- Instantiate design under test (DUT)
    dut : alu PORT MAP(
        A => tb_A,
        B => tb_B,
        F => tb_F,
        R => tb_R,
        S => tb_S
    );

    stim_proc : PROCESS
    BEGIN
        -- --- TEST CASES ---
        -- We try to implement directed testing along with edge cases here.
        -- We try to provide full coverage of all the paths for F from 000 till 111
        -- We target boundary values to force the zero, sign, overflow and carry flags to toggle
        -- And for logical operations, we use alternative bit patterns to prove 
        -- that every individual wire in the 32-bit bus operates independently

        -- Test 1: Simple Addition (2 + 3 = 5)
        tb_A <= to_signed(2, 32);
        tb_B <= to_signed(3, 32);
        tb_F <= "110";  -- Addition
        WAIT FOR 10 ns; -- Wait for combinational gates to settle

        ASSERT (tb_R = to_signed(5, 32))
        REPORT "Failed Test 1: Simple addition result incorrect!" SEVERITY ERROR;
        ASSERT (tb_S = "0000")
        REPORT "Failed Test 1: Simple addition flags incorrect!" SEVERITY ERROR;

        -- -------------------------------

        -- Test 2: Addition overflow (2147483647 + 1) 
        -- Min max values of 32 bit signed are [-2,147,483,648, +2,147,483,647]
        -- We first make sure the S bits are not
        tb_A <= to_signed(2147483647, 32);
        tb_B <= to_signed(1, 32);
        tb_F <= "110"; -- Addition
        WAIT FOR 10 ns;

        -- Result should overflow and thus be 1 followed by 31 zeroes
        -- This means the value of the result is now -2,147,483,648
        -- Moreover, the overflow bit must be set now for the status output S
        -- Also the sign bit will be set because the MSB is now 1
        -- S is (3: Zero, 2: Sign, 1: Overflow, 0: Carry)
        ASSERT (tb_R = to_signed(-2147483648, 32))
        REPORT "Failed Test 2: Addition overflow result mismatch!" SEVERITY ERROR;
        ASSERT (tb_S = "0110")
        REPORT "Failed Test 2: Addition overflow status flags mismatch!" SEVERITY ERROR;

        -- -------------------------------

        -- Test 3: Subtraction carry (0 - 1) 
        tb_A <= to_signed(0, 32);
        tb_B <= to_signed(1, 32);
        tb_F <= "111"; -- Subtraction
        WAIT FOR 10 ns;

        -- In this case a borrow occurs and the carry bit must be 1
        -- S is (3: Zero, 2: Sign, 1: Overflow, 0: Carry)
        ASSERT (tb_R = to_signed(-1, 32))
        REPORT "Failed Test 3: Subtraction carry result mismatch!" SEVERITY ERROR;
        ASSERT (tb_S = "0101")
        REPORT "Failed Test 3: Subtraction carry status flags mismatch!" SEVERITY ERROR;

        -- -------------------------------

        -- Test 4: Zero function and flag
        tb_A <= to_signed(123, 32);
        tb_F <= "000"; -- Zero Function
        WAIT FOR 10 ns;

        ASSERT (tb_R = to_signed(0, 32))
        REPORT "Failed Test 4: Zero function result!" SEVERITY ERROR;
        ASSERT (tb_S = "1000")
        REPORT "Failed Test 4: Status bit for zero not set!" SEVERITY ERROR;

        -- -------------------------------

        -- Test 5: Identitify function
        -- in binary values, which allows us to easily verify and check results in a readable manner
        tb_A <= signed'(X"AAAAAAAA");
        tb_F <= "001"; -- Identitiy Function
        WAIT FOR 10 ns;

        ASSERT (tb_R = signed'(X"AAAAAAAA"))
        REPORT "Failed Test 5: Identity function result!" SEVERITY ERROR;
        ASSERT (tb_S = "0100") -- Because MSB of A is 1 in this case
        REPORT "Failed Test 5: Incorrect status bit for sign in identity function test!" SEVERITY ERROR;

        -- -------------------------------

        -- For the following tests, we use the values X"AAAAAAAA" and X"55555555" in hex, which converts to
        -- for A: X"AAAAAAAA": 10101010101010101010101010101010
        -- for B: X"55555555": 01010101010101010101010101010101
        -- Result of NOT A is X"55555555", AND is X"00000000" and OR is X"FFFFFFFF" and XOR is also X"FFFFFFFF"
        -- which allows us to quickly and easily verify our results for the following bitwise operations

        -- Test 6: NOT A function
        tb_A <= signed'(X"AAAAAAAA");
        tb_F <= "010"; -- NOT A
        WAIT FOR 10 ns;

        ASSERT (tb_R = signed'(X"55555555"))
        REPORT "Failed Test 6: !" SEVERITY ERROR;
        ASSERT (tb_S = "0000") -- The MSB is now 0, so the sign flag turns off
        REPORT "Failed Test 6: !" SEVERITY ERROR;

        -- -------------------------------

        -- Test 7: bit wise A AND B
        tb_A <= signed'(X"AAAAAAAA");
        tb_B <= signed'(X"55555555");
        tb_F <= "011"; -- AND
        WAIT FOR 10 ns;

        ASSERT (tb_R = signed'(X"00000000"))
        REPORT "Failed Test 7: Result incorrect for A AND B!" SEVERITY ERROR;
        ASSERT (tb_S = "1000") -- S: [Z, S, O, C]
        REPORT "Failed Test 7: Status bits wrong for A AND B!" SEVERITY ERROR;

        -- -------------------------------

        -- Test 8: bit wise A OR B
        tb_A <= signed'(X"AAAAAAAA");
        tb_B <= signed'(X"55555555");
        tb_F <= "100"; -- OR
        WAIT FOR 10 ns;

        ASSERT (tb_R = signed'(X"FFFFFFFF"))
        REPORT "Failed Test 8: Result incorrect for A OR B!" SEVERITY ERROR;
        ASSERT (tb_S = "0100") -- S: [Z, S, O, C]
        REPORT "Failed Test 8: Status bits wrong for A OR B!" SEVERITY ERROR;

        -- -------------------------------

        -- Test 9: bit wise A XOR B
        tb_A <= signed'(X"AAAAAAAA");
        tb_B <= signed'(X"55555555");
        tb_F <= "101"; -- XOR
        WAIT FOR 10 ns;

        ASSERT (tb_R = signed'(X"FFFFFFFF"))
        REPORT "Failed Test 9: Result incorrect for A XOR B!" SEVERITY ERROR;
        ASSERT (tb_S = "0100") -- S: [Z, S, O, C]
        REPORT "Failed Test 9: Status bits wrong for A XOR B!" SEVERITY ERROR;

        -- -------------------------------

        -- Stop simulation smoothly
        REPORT "ALU Simulation Complete!";
        WAIT;
    END PROCESS;
END sim;
