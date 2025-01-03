 LIBRARY IEEE;
 USE IEEE.std_logic_1164.ALL;
 USE ieee.numeric_std.ALL;

 ENTITY BlackjackGame IS
     PORT (
         KEY                 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); --clock(0),reset(1),player_hit(2),player_stand(3)
         SW                  : IN STD_LOGIC_VECTOR(9 DOWNTO 0);  --card(0,1,2,3)
         LEDG                : OUT  STD_LOGIC_VECTOR(7 DOWNTO 0); --win(7)
         LEDR                : OUT  STD_LOGIC_VECTOR(9 DOWNTO 0); --lose(0),tie(9)

         HEX3                 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); --current_display
         HEX1                 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); --dezenas_display
         HEX0                 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) --unidades_display
     );
 END ENTITY BlackjackGame;

 ARCHITECTURE hardware OF BlackjackGame IS
     TYPE estado IS (START, PLAYER_RECEIVE_CARD1, DEALER_RECEIVE_CARD1, PLAYER_RECEIVE_CARD2,
         DEALER_RECEIVE_CARD2, PLAYER_DECISION, DEALER_DECISION,
         DEALER_RECEIVE_CARD, PLAYER_RECEIVE_CARD, COMPARE, PLAYER_BOOM,
         DEALER_BOOM, PLAYER_WIN, PLAYER_LOSE, PLAYER_TIE
     );
     SIGNAL e_atual : estado := START;
     SIGNAL player_sum : unsigned(4 DOWNTO 0) := "00000";
     SIGNAL player_sum_copy : INTEGER := 0;
     SIGNAL player_sum_tens : INTEGER := 0;
     SIGNAL player_sum_units : INTEGER := 0;
     SIGNAL dealer_sum : unsigned(4 DOWNTO 0) := "00000";
     SIGNAL card_value : unsigned (3 DOWNTO 0);
     SIGNAL count_as_player : INTEGER := 0;
     SIGNAL count_as_dealer : INTEGER := 0;
      SIGNAL card : STD_LOGIC_VECTOR(3 DOWNTO 0);


 BEGIN
 PROCESS (KEY(0), KEY(1))
     BEGIN

 IF (KEY(1) = '0') THEN
             e_atual <= START;
             player_sum <= (OTHERS => '0');
             dealer_sum <= (OTHERS => '0');
             LEDG(7) <= '0';
             LEDR(0) <= '0';
             LEDR(9) <= '0';
             count_as_player <= 0;
             count_as_dealer <= 0;
 ELSIF (KEY(0)'event AND KEY(0) = '0') THEN
                 ledr(0)<='1';
             CASE e_atual IS
                 WHEN START =>
                     player_sum <= (OTHERS => '0');
                     dealer_sum <= (OTHERS => '0');
                     LEDG(7) <= '0';
                     LEDR(0) <= '0';
                     LEDR(9) <= '0';
                     count_as_player <= 0;
                     count_as_dealer <= 0;
                     e_atual <= PLAYER_RECEIVE_CARD1;
                 WHEN PLAYER_RECEIVE_CARD1 =>
                     IF (card_value = 11) THEN
                         count_as_player <= count_as_player + 1;
                     END IF;
                     player_sum <= player_sum + card_value;
                     e_atual <= DEALER_RECEIVE_CARD1;
                 WHEN DEALER_RECEIVE_CARD1 =>
                     IF (card_value = 11) THEN
                         count_as_dealer <= count_as_dealer + 1;
                     END IF;
                     dealer_sum <= dealer_sum + card_value;
                     e_atual <= PLAYER_RECEIVE_CARD2;
                 WHEN PLAYER_RECEIVE_CARD2 =>
                     IF (card_value = 11) THEN
                         IF (player_sum + card_value > 21) THEN
                             player_sum <= player_sum + 1;
                         ELSE
                             player_sum <= player_sum + card_value;
                             count_as_player <= count_as_player + 1;
                         END IF;
                     ELSE
                         player_sum <= player_sum + card_value;
                     END IF;
                     e_atual <= DEALER_RECEIVE_CARD2;
                 WHEN DEALER_RECEIVE_CARD2 =>
                     IF (card_value = 11) THEN
                         IF (dealer_sum + card_value > 21) THEN
                             dealer_sum <= dealer_sum + 1;
                         ELSE
                             dealer_sum <= dealer_sum + card_value;
                             count_as_dealer <= count_as_dealer + 1;
                         END IF;
                     ELSE
                         dealer_sum <= dealer_sum + card_value;
                     END IF;
                     e_atual <= PLAYER_DECISION;
                 WHEN PLAYER_DECISION =>
                     IF (KEY(2) = '1') THEN
                         e_atual <= PLAYER_RECEIVE_CARD;
                     ELSIF (KEY(3) = '1') THEN
                         e_atual <= DEALER_DECISION;
                     END IF;
                 WHEN player_RECEIVE_CARD =>
                     IF (card_value = 11 AND player_sum + 11 > 21) THEN
                         player_sum <= player_sum + 1;
                         IF (player_sum > 21) THEN
                             e_atual <= player_BOOM;
                         ELSE
                             e_atual <= player_DECISION;
                         END IF;
                     ELSIF (card_value = 11 AND player_sum + 11 <= 21) THEN
                         player_sum <= player_sum + 11;
                         count_as_player <= count_as_player + 1;
                         e_atual <= player_DECISION;
                     ELSIF (player_sum + card_value > 21 AND count_as_player > 0) THEN
                         player_sum <= player_sum + card_value - 10;
                         count_as_player <= count_as_player - 1;
                         IF (player_sum > 21) THEN
                             e_atual <= player_BOOM;
                         ELSE
                             e_atual <= player_DECISION;
                         END IF;
                     ELSIF (player_sum + card_value > 21 AND count_as_player = 0) THEN
                         player_sum <= player_sum + card_value;
                         e_atual <= player_BOOM;
                     ELSIF (player_sum + card_value <= 21) THEN
                         player_sum <= player_sum + card_value;
                         e_atual <= player_DECISION;
                     END IF;
                 WHEN DEALER_DECISION =>
                     IF dealer_sum < 17 THEN
                         e_atual <= DEALER_RECEIVE_CARD;
                     ELSE
                         e_atual <= COMPARE;
                     END IF;
                     WHEN dealer_RECEIVE_CARD =>
                     IF (card_value = 11 AND dealer_sum + 11 > 21) THEN
                         dealer_sum <= dealer_sum + 1;
                         IF (dealer_sum > 21) THEN
                             e_atual <= dealer_BOOM;
                         ELSE
                             e_atual <= dealer_DECISION;
                         END IF;
                     ELSIF (card_value = 11 AND dealer_sum + 11 <= 21) THEN
                         dealer_sum <= dealer_sum + 11;
                         count_as_dealer <= count_as_dealer + 1;
                         e_atual <= dealer_DECISION;
                     ELSIF (dealer_sum + card_value > 21 AND count_as_dealer > 0) THEN
                         dealer_sum <= dealer_sum + card_value - 10;
                         count_as_dealer <= count_as_dealer - 1;
                         IF (dealer_sum > 21) THEN
                             e_atual <= dealer_BOOM;
                         ELSE
                             e_atual <= dealer_DECISION;
                         END IF;
                     ELSIF (dealer_sum + card_value > 21 AND count_as_dealer = 0) THEN
                         dealer_sum <= dealer_sum + card_value;
                         e_atual <= dealer_BOOM;
                     ELSIF (dealer_sum + card_value <= 21) THEN
                         dealer_sum <= dealer_sum + card_value;
                         e_atual <= dealer_DECISION;
                     END IF;
                 WHEN COMPARE =>
                     IF dealer_sum > player_sum THEN
                         e_atual <= PLAYER_LOSE;
                     ELSIF dealer_sum < player_sum THEN
                         e_atual <= PLAYER_WIN;
                     ELSE
                         e_atual <= PLAYER_TIE;
                     END IF;
                 WHEN PLAYER_BOOM =>
                     e_atual <= PLAYER_LOSE;
                 WHEN DEALER_BOOM =>
                     e_atual <= PLAYER_WIN;
                 WHEN PLAYER_WIN =>
                     LEDG(7) <= '1';
                     e_atual <= START;
                 WHEN PLAYER_LOSE =>
                     LEDR(0) <= '1';
                     e_atual <= START;
                 WHEN PLAYER_TIE =>
                     LEDR(9) <= '1';
                     e_atual <= START;
                 WHEN OTHERS =>
                     e_atual <= START;
             END CASE;
         END IF;
     END PROCESS;

     PROCESS (card)
     BEGIN
         -- Converte cartas de figuras (J, Q, K) para valor 10
         -- E converte o valor da carta para unsigned
         card(0) <= SW(3);
         card(1) <= SW(2);
         card(2) <= SW(1);
         card(3) <= SW(0);
         CASE card IS
             WHEN "0001" => card_value <= to_unsigned(11, 4); -- Ás
             WHEN "1011" => card_value <= to_unsigned(10, 4); -- Valete
             WHEN "1100" => card_value <= to_unsigned(10, 4); -- Dama
             WHEN "1101" => card_value <= to_unsigned(10, 4); -- Rei
             WHEN OTHERS => card_value <= unsigned(card); -- Outros valores
         END CASE;
     END PROCESS;
     PROCESS (card_value)
     BEGIN
         CASE card IS
             WHEN "0001" => HEX3 <= "1111001"; -- 1
             WHEN "0010" => HEX3 <= "0100100"; -- 2
             WHEN "0011" => HEX3 <= "0111000"; -- 3
             WHEN "0100" => HEX3 <= "0011001"; -- 4
             WHEN "0101" => HEX3 <= "0010010"; -- 5
             WHEN "0110" => HEX3 <= "0000010"; -- 6
             WHEN "0111" => HEX3 <= "1111000"; -- 7
             WHEN "1000" => HEX3 <= "0000000"; -- 8
             WHEN "1001" => HEX3 <= "0010000"; -- 9
             WHEN "1010" => HEX3 <= "0001000"; -- A
             WHEN "1011" => HEX3 <= "0000011"; -- b
             WHEN "1100" => HEX3 <= "1000110"; -- C
             WHEN "1101" => HEX3 <= "1000001"; -- d
             WHEN OTHERS => HEX3 <= "1111111"; -- TRAÇO QUANDO INVÁLIDO
         END CASE;
     END PROCESS;
  -- Atualização dos displays fora do processo
  player_sum_copy <= to_integer(player_sum);  -- Cópia como inteiro
  player_sum_tens <= player_sum_copy / 10;
  player_sum_units <= player_sum_copy mod 10;

  PROCESS (player_sum_tens)
  BEGIN
      CASE player_sum_tens IS
          WHEN 0 =>
              HEX1 <= "1000000"; -- 0 em 7 segmentos
          WHEN 1 =>
              HEX1 <= "1111001"; -- 1 em 7 segmentos
          WHEN 2 =>
              HEX1 <= "0110100"; -- 2 em 7 segmentos
          WHEN 3 =>
              HEX1 <= "0110000"; -- 3 em 7 segmentos           
          WHEN OTHERS =>
              HEX1 <= "1111111"; -- Caso padrão, todos os segmentos apagados
      END CASE;
  END PROCESS;

  PROCESS (player_sum_units)
  BEGIN
      CASE player_sum_units IS
          WHEN 0 =>
             HEX0 <= "1000000"; -- 0 em 7 segmentos
          WHEN 1 =>
             HEX0 <= "1111001"; -- 1 em 7 segmentos
          WHEN 2 =>
             HEX0 <= "0110100"; -- 2 em 7 segmentos
          WHEN 3 =>
             HEX0 <= "0110000"; -- 3 em 7 segmentos
          WHEN 4 =>
             HEX0 <= "0011001"; -- 4 em 7 segmentos
          WHEN 5 =>
             HEX0 <= "0010010"; -- 5 em 7 segmentos
          WHEN 6 =>
             HEX0 <= "0000010"; -- 6 em 7 segmentos
          WHEN 7 =>
             HEX0 <= "1111000"; -- 7 em 7 segmentos
          WHEN 8 =>
             HEX0 <= "0000000"; -- 8 em 7 segmentos
          WHEN 9 =>
             HEX0 <= "0010000"; -- 9 em 7 segmentos
          WHEN OTHERS =>
             HEX0 <= "1111111"; -- Caso padrão, todos os segmentos apagados
      END CASE;
  END PROCESS;

 END ARCHITECTURE hardware;