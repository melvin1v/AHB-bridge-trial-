Library ieee;
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


Entity data_swapper is
  port(
    DMAO: in ahb_dma_out_type;
    HRDATA: out std_logic_vector (31 downto 0)
  );
END data_Swapper;

Architecture ds of data_swapper is

signal MY_DMAO:  std_logic_vector (31 downto 0);

BEGIN
    MY_DMAO<= DMAO.rdata;  
    HRDATA(7 downto 0) <= MY_DMAO(31 downto 24);--byte 0 to byte 3
    HRDATA(15 downto 8)<= MY_DMAO(23 downto 16); -- byte 1 to byte 2
    HRDATA(23 downto 16)<= MY_DMAO(15 downto 8); --byte 2 to byte 1
    HRDATA(31 downto 24)<= MY_DMAO(7 downto 0);-- byte 3 to byte 0
    
END ds;


