library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;
library UNISIM;
use UNISIM.VComponents.all;


--package state_machine_pack is
--
--  type STATE_TYPE is
--  (
--    idle,
--    instr_fetch
--  );
--
--end state_machine_pack;


entity state_machine is
  port(
    clkm:		in std_logic;
  		rstn:		in std_logic;
  		HADDR: in std_logic_vector(31 downto 0);
  		HSIZE: in std_logic_vector(2 downto 0);
  		HTRANS: in std_logic_vector(1 downto 0);
  		HWDATA: in std_logic_vector(31 downto 0);
  		HWRITE: in std_logic;
  		HREADY: OUT std_logic;
  		dmao: in ahb_dma_out_type;
  		
  		dmai: out ahb_dma_in_type
  		);
end state_machine;



architecture state_machine_arch of state_machine is
  
  type state_type is (idle, instr_fetch);

  signal curState, nextState: state_type;
  signal start: std_logic;
  signal ready: std_logic;
  signal HREADY_sig: std_logic;
  

BEGIN 
  
  HREADY <= HREADY_sig; 
  
  combi_nextState: process(curState, ready, start)
  
  begin
    
    case curState is 
      
      when idle => --initial state
        
        HREADY_sig <= '1';
        start <= '0';
        
        if HTRANS = "10" then
          start <= '1';
          
          nextState <= instr_fetch; 
        end if;
        
      when instr_fetch =>
        
        HREADY_sig <= '0';
        start <= '0';
        
        if ready = '1' then
          HREADY_sig <= '1';
          
          nextState <= idle;
        end if;
        
    end case;
  end process;
  
  
  state_register: process(clkm, rstn)
  
  begin
    
    if rstn = '1' then -- ACTIVE HIGH (ask TA)
      curState <= idle;
    
    elsif clkm'event and clkm = '1' then --rising edge (ask TA)
      curState <= nextState;
    
    end if;
    
  end process;
  
END;

