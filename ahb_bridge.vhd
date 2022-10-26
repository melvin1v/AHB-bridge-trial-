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

entity AHB_bridge is
  port(
     -- Clock and Reset -----------------
     clkm : in std_logic;
     rstn : in std_logic;
     -- AHB Master records --------------
     ahbmi : in ahb_mst_in_type;
     ahbmo : out ahb_mst_out_type;
     -- ARM Cortex-M0 AHB-Lite signals -- 
     HADDR : in std_logic_vector (31 downto 0); -- AHB transaction address
     HSIZE : in std_logic_vector (2 downto 0); -- AHB size: byte, half-word or word
     HTRANS : in std_logic_vector (1 downto 0); -- AHB transfer: non-sequential only
     HWDATA : in std_logic_vector (31 downto 0); -- AHB write-data
     HWRITE : in std_logic; -- AHB write control
     HRDATA : out std_logic_vector (31 downto 0); -- AHB read-data
     HREADY : out std_logic -- AHB stall signal
     );
end;
architecture structural of AHB_bridge is
--declare a component for state_machine
component sm
  port(
    clkm:		in std_logic;
  		rstn:		in std_logic;
  		HADDR: in std_logic_vector(31 downto 0);
  		HSIZE: in std_logic_vector(2 downto 0);
  		HTRANS: in std_logic_vector(1 downto 0);
  		HWDATA: in std_logic_vector(31 downto 0);
  		HWRITE: in std_logic;
  		HREADY: out std_logic;
  		dmao: in ahb_dma_out_type;	
  		dmai: out ahb_dma_in_type
  		);
	end component;
	
--declare a component for ahbmst

component master
  port(
    rst  : in  std_ulogic;
    clk  : in  std_ulogic;
    dmai : in ahb_dma_in_type;
    dmao : out ahb_dma_out_type;
    ahbi : in  ahb_mst_in_type;
    ahbo : out ahb_mst_out_type 
  );
end component; 

--declare a component for data_swapper 
component swap
  port(
    DMAO: in ahb_dma_out_type;
    HRDATA: out std_logic_vector (31 downto 0));
  end component;

FOR state_m: sm USE ENTITY work.state_machine(state_machine_arch);
FOR ahb_mst: master USE ENTITY gaisler.ahbmst(rtl);
FOR d_swapper : swap USE ENTITY work.data_swapper(ds);

signal dmai_int : ahb_dma_in_type;
signal dmao_int : ahb_dma_out_type;
signal HREADY_int :  std_logic;
begin
  HREADY <= HREADY_int;
--instantiate state_machine component and make the connections
  state_m : sm port map(clkm, rstn, HADDR, HSIZE, HTRANS, HWDATA, HWRITE, HREADY_int, dmao_int, dmai_int);
  
--instantiate the ahbmst component and make the connections 
  ahb_mst : master port map(rstn, clkm, dmai_int, dmao_int, ahbmi, ahbmo);
  
--instantiate the data_swapper component and make the connections
  d_swapper : swap port map(dmao_int, HRDATA);

end structural;

