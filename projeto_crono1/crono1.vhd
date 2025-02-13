library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity crono1 is
	port (
		     clock : in std_logic;
		     reset : in std_logic;
		     iniciar : in std_logic;
		     parar : in std_logic;
		     reiniciar : in std_logic;
		     display_7seg : out std_logic_vector(6 downto 0);
		     anodos : out std_logic_vector(3 downto 0) -- 6 anodos
	     );
end entity crono1;

architecture comportamento of crono1 is

  -- Frequência do clock do AX301
	constant clock_freq : integer := 50000000;

  -- Contador para gerar o sinal de 1 segundo
	constant clock_div_value : integer := clock_freq / 2;
	signal clock_div_cont : integer range 0 to clock_div_value;
	signal clock_1s : std_logic;

  -- Contador para o cronômetro
	signal segundos : integer range 0 to 59;
	signal minutos : integer range 0 to 9;

  -- Sinal para habilitar a contagem
	signal contar : std_logic;

  -- Contador para multiplexar os displays
	signal display_cont : integer range 0 to 2;

begin

  -- Divisor de clock
	process (clock, reset)
	begin
		if reset = '0' then
			clock_div_cont <= 0;
			clock_1s <= '1';
		elsif rising_edge(clock) then
			if clock_div_cont < clock_div_value then
				clock_div_cont <= clock_div_cont + 1;
			else
				clock_div_cont <= 0;
				clock_1s <= not clock_1s;
			end if;
		end if;
	end process;

  -- Codificador para 7 segmentos
	process (segundos, minutos, display_cont)
		variable digito : integer;
	begin
		case display_cont is
			when 0 => digito := minutos / 10;
			when 1 => digito := minutos mod 10;
			when 2 => digito := segundos / 10;
			when others => digito := segundos mod 10;
		end case;

		case digito is
			when 0 => display_7seg <= "1000000";
			when 1 => display_7seg <= "1111001";
			when 2 => display_7seg <= "0100100";
			when 3 => display_7seg <= "0110000";
			when 4 => display_7seg <= "0011001";
			when 5 => display_7seg <= "0010010";
			when 6 => display_7seg <= "0000010";
			when 7 => display_7seg <= "1111000";
			when 8 => display_7seg <= "0000000";
			when 9 => display_7seg <= "0010000";
			when others => display_7seg <= "1111111";
		end case;
	end process;

  -- Multiplexador dos displays
	process (clock_1s)
	begin
		if rising_edge(clock_1s) then
			if display_cont < 2 then
				display_cont <= display_cont + 1;
			else
				display_cont <= 0;
			end if;
		end if;
	end process;

  -- Habilitar anodos dos displays (3 primeiros displays)
	anodos <= "0001" when display_cont = 0 else
		  "0010" when display_cont = 1 else
		  "0100";

  -- Lógica do cronômetro
	process (clock_1s, reset)
	begin
		if reset = '0' then
			segundos <= 0;
			minutos <= 0;
			contar <= '0';
		elsif rising_edge(clock_1s) then
			if iniciar = '0' then
				contar <= '0';
			elsif parar = '0' then
				contar <= '0';
			end if;

			if reiniciar = '0' then
				segundos <= 0;
				minutos <= 0;
			elsif contar = '0' then
				if segundos < 59 then
					segundos <= segundos + 1;
				else
					segundos <= 0;
					if minutos < 9 then
						minutos <= minutos + 1;
					else
						minutos <= 0;
					end if;
				end if;
			end if;
		end if;
	end process;

end architecture comportamento;
