library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seq_mem is
    Generic (
        DATA_WIDTH : positive := 4;     -- 4 BITS DE ENCENDIDO O APAGADO DE LEDS
        ADDR_WIDTH : positive := 5      -- 5 BITS (0 A 31) PARA EL VALOR MAXIMO DE SECUENCIAS (16)
    );
    Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        we       : in  std_logic;
        data_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        addr_rd  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        addr_wr  : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end seq_mem;

architecture Behavioral of seq_mem is
    type memory_type is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);    -- MEMORIA RAM DE LAS DIMENSIONES ESPECIFICADAS
    signal ram_block : memory_type := (others => (others => '0'));  
begin

    process(clk)
    begin
        if rising_edge(clk) then    -- PROCESO SINCRONO AL SYS_CLK
            if rst = '1' then
                ram_block <= (others => (others => '0'));
            else
                if we = '1' then                    -- ESCRIBIR EN LA MEMORIA LOS DATOS DE 4 BITS
                    ram_block(to_integer(unsigned(addr_wr))) <= data_in;
                end if;
            end if;
            data_out <= ram_block(to_integer(unsigned(addr_rd)));   -- LECTURA DE LOS DATOS DE 4 BITS
        end if;
    end process;

end Behavioral;