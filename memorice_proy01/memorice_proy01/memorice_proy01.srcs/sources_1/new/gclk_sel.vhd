library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gclk_sel is
    Port (
        sysclk : in  std_logic;
        lvl    : in  std_logic_vector(1 downto 0);
        sclk   : out std_logic
    );
end gclk_sel;

architecture Behavioral of gclk_sel is
    constant L_FACIL : integer := 46874999;
    constant L_MEDIO : integer := 31249999;
    constant L_DIFIC : integer := 15624999;
    constant L_RESER : integer := 7812499;

    signal counter  : integer range 0 to 50000000 := 0;
    signal aux_sclk : std_logic := '0';
begin

    process(sysclk)
        variable limite : integer range 0 to 50000000 := L_FACIL;
    begin 
        if rising_edge(sysclk) then
            case lvl is
                when "00" => limite := L_FACIL;
                when "01" => limite := L_MEDIO;
                when "10" => limite := L_DIFIC;
                when "11" => limite := L_RESER;
                when others => limite := L_FACIL;
            end case;

            if counter < limite then
                counter <= counter + 1;
            else
                counter  <= 0;
                aux_sclk <= not aux_sclk; 
            end if;
            
        end if;
    end process;

    sclk <= aux_sclk;

end Behavioral;