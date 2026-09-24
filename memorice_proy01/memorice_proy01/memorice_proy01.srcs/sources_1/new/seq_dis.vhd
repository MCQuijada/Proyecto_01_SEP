library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seq_dis is
    Generic (
        MEM_DEPTH : integer := 16 
    );
    Port (
        sclk           : in  std_logic;                
        enable_display : in  std_logic;                    
        num_seq        : in  integer range 1 to MEM_DEPTH; 
        data_from_mem  : in  std_logic_vector(3 downto 0); 
        
        addr_rd        : out integer range 0 to MEM_DEPTH-1;
        led           : out std_logic_vector(3 downto 0);
        seq_done       : out std_logic               
    );
end seq_dis;

architecture Behavioral of seq_dis is
    signal read_ptr : integer range 0 to MEM_DEPTH-1 := 0;
begin

    process(sclk)
    begin
        if rising_edge(sclk) then
            if enable_display = '1' then
                leds    <= data_from_mem;
                addr_rd <= read_ptr;
                
                if read_ptr < num_seq - 1 then
                    read_ptr <= read_ptr + 1;
                    seq_done <= '0';
                else
                    read_ptr <= 0;
                    seq_done <= '1';
                end if;
            else
                read_ptr <= 0;
                addr_rd  <= 0;
                leds     <= "0000";
                seq_done <= '0';
            end if;
        end if;
    end process;

end Behavioral;