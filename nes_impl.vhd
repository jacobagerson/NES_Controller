library IEEE;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

entity top is
  port (
    data : in std_logic;
    latch : out std_logic;
    controller_clk : out std_logic;
	jump_but : out std_logic;
	start_but : out std_logic;
	duck_but : out std_logic;
	dataout : out std_logic_vector(7 downto 0)
  );
end top;

architecture synth of top is

component HSOSC is
    generic (
        CLKHF_DIV : String := "0b00"); -- Divide 48MHz clock by 2N (0-3)
    port(
        CLKHFPU : in std_logic := 'X'; -- Set to 1 to power up
        CLKHFEN : in std_logic := 'X'; -- Set to 1 to enable output
        CLKHF : out std_logic := 'X'); -- Clock output
end component;

signal counter : unsigned(19 downto 0) := 20b"0"; --makes all 0 at beginning
signal clk : std_logic;
signal NESclk : std_logic;
signal NEScounter : unsigned(7 downto 0);-- := 8b"0";
signal data_out : std_logic_vector(7 downto 0);

begin
    osc : HSOSC
    generic map ( CLKHF_DIV => "0b00")
    port map (
        CLKHFPU => '1',
        CLKHFEN => '1',
        CLKHF => clk
);

process (clk)
    begin
        if (rising_edge(clk)) then
counter <= counter + '1';
end if;
end process;

NESclk <= counter(8);

NEScounter <= counter(16 downto 9); --use this as it will give us the desired frequency

latch <= '1' when (NEScounter=8d"255") else
'0';

controller_clk <= NESclk when NEScounter < 8d"8" else '0'; --controller clock

process(controller_clk)
begin  
if (rising_edge(controller_clk)) then
data_out(0) <= data;
data_out(1) <= data_out(0);
data_out(2) <= data_out(1);
data_out(3) <= data_out(2);
data_out(4) <= data_out(3);
data_out(5) <= data_out(4);
data_out(6) <= data_out(5);
data_out(7) <= data_out(6);
end if;
end process;

dataout <= not data_out when NEScounter = 8d"8";
jump_but <= '1' when dataout(7) = '1' else '0';
start_but <= '1' when dataout(4) = '1' else '0';
duck_but <= '1' when dataout(6) = '1' else '0';

end;
