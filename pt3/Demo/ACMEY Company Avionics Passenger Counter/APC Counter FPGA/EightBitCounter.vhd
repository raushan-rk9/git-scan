-------------------------------------------------------------------------------
-- Title      : EightBitCounter.vhd
-- Project    : FAA Training course 
-------------------------------------------------------------------------------
-- File       : EightBitCounter.vhd
-- Author     : Jane Doe 
-- Company    : ACMEY Co.
-- Created    : 2008-05-19
-- Last update: 2008-05-21
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: This module contains and 8-bit up/down counter with parallel
-- load and asynchronous reset. When enable is true the counter will load if
-- load is true otherwise it will count up or down depending on state of up_down
-------------------------------------------------------------------------------
-- Copyright (c) 2009 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author     Description
-- 2007-05-19  1.0      Jane Doe Created
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;  -- Reference the Std_logic_1164 system
USE ieee.numeric_std.ALL;

ENTITY EightBitCounter IS
  
  GENERIC (
    CNT_WIDTH : INTEGER := 8);                    -- Counter Width
  PORT (
    reset     : IN  STD_LOGIC;                    --Active high reset
    clk       : IN  STD_LOGIC;                    --Input clock
    load      : IN  STD_LOGIC;                    --Load Pulse SIGNAL
    enable    : IN  STD_LOGIC;                    --count enable
    up_down   : IN  STD_LOGIC;                    --1=count up, 0=count down
    data_in   : IN  STD_LOGIC_VECTOR(CNT_WIDTH-1 DOWNTO 0);  --Parallel load input data
    count_out : OUT STD_LOGIC_VECTOR(CNT_WIDTH-1 DOWNTO 0)   --Counter output
    );
END ENTITY EightBitCounter;

ARCHITECTURE rtl OF EightBitCounter IS

  SIGNAL counter : UNSIGNED(data_in'RANGE);

BEGIN

  gen_counter : PROCESS(clk, reset)
  BEGIN
    IF (reset = '1') THEN
      counter <= (OTHERS => '0');
    ELSIF (clk'EVENT AND clk = '1') THEN
      IF (enable = '1') THEN
        IF (load = '1') THEN
          counter <= UNSIGNED(data_in);
        ELSE
          IF (up_down = '1') THEN
            counter <= counter + 1;
          ELSE
            counter <= counter - 1;
          END IF;
        END IF;
      END IF;
    END IF;
  END PROCESS gen_counter;

  count_out <= STD_LOGIC_VECTOR(counter);

  
END ARCHITECTURE rtl;
