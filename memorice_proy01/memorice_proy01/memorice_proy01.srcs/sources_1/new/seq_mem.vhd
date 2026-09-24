library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seq_mem is
    Generic (
        DATA_WIDTH : integer := 4; 
        MEM_DEPTH  : integer := 16
    );
    Port (
        clk     : in  std_logic;                              
        rst     : in  std_logic;                         
        we      : in  std_logic;                                    
        data_in : in  std_logic_vector(DATA_WIDTH-1 downto 0);  
        addr_rd : in  integer range 0 to MEM_DEPTH-1;                
        addr_wr : in  integer range 0 to MEM_DEPTH-1;               
        data_out: out std_logic_vector(DATA_WIDTH-1 downto 0)        
    );
end seq_mem;

architecture Behavioral of seq_mem is
    type memory_type is array (0 to MEM_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    
    signal ram_block : memory_type := (others => (others => '0'));

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ram_block <= (others => (others => '0'));
            elsif we = '1' then
                ram_block(addr_wr) <= data_in;
            end if;
            
            data_out <= ram_block(addr_rd);
        end if;
    end process;

end Behavioral;