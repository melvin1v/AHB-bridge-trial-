library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

entity cm0 is 
  port(
    clkm : in std_logic;
    rstn : in std_logic;
    ahbmi : in ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;
    detected : out std_logic
    );
  end cm0;

architecture myarch of cm0 is
  
  component cortex
  -- all the cortex ports must be added! diagram on files, check there for additional ports
    port ( HCLK : in std_ulogic;
      HRESETn : in std_ulogic;
      HREADY : in std_ulogic;
      HRDATA : in std_logic_vector(31 downto 0);
      -- unused inputs
      HRESP : in std_ulogic;
      NMI : in std_ulogic;
      IRQ: in std_logic_vector(15 downto 0);
      RXEV : in std_ulogic;
      -- unused outputs
      HBURST: out std_logic_vector(2 downto 0);
      HMASTLOCK: out std_ulogic;
      HPROT : out std_logic_vector(3 downto 0);
      LOCKUP : out std_ulogic;
      SLEEPING : out std_ulogic;
      SYSRESETREQ : out std_ulogic;
      TXEV : out std_ulogic;
      ---
      HWRITE : out std_ulogic;
      HWDATA : out std_logic_vector(31 downto 0);
      HTRANS : out std_logic_vector(1 downto 0);
      HSIZE : out std_logic_vector(2 downto 0);
      HADDR : out std_logic_vector(31 downto 0)
         );
  end component;
  
  component bridge
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
    end component;
    
  component detect
  port( Clock : in  STD_LOGIC;
        DataBus : in  STD_LOGIC_VECTOR (31 downto 0);
        Detector : out  STD_LOGIC);
  end component;
  
  FOR cort: cortex USE ENTITY work.CORTEXM0DS(module);
  
  FOR AHBlite: bridge USE ENTITY work.AHB_bridge(structural);
  
  FOR detectorbus : detect USE ENTITY work.detectorbus(Behavioral);
  
----------------------------------------------------------------------
--- ARM Cortex-M0 Processor signals-----------------------------------
----------------------------------------------------------------------
  signal HREADYint, HWRITEint : std_ulogic;
  signal HRDATAint, HWDATAint, HADDRint : std_logic_vector(31 downto 0);
  signal HTRANSint : std_logic_vector(1 downto 0);
  signal HSIZEint : std_logic_vector(2 downto 0);
  signal OFFin : std_ulogic := '0';
  signal OFFvect15 : std_logic_vector(15 downto 0) :=(others => '0');
  signal OFFvect3 : std_logic_vector(3 downto 0) :=(others => '0');
  signal OFFvect2 : std_logic_vector(2 downto 0) :=(others => '0'); 
  
  
  BEGIN
    cort : cortex port map(clkm, rstn, HREADYint, HRDATAint, 
    OFFin, OFFin, OFFvect15, OFFin, 
    open, open, open, open, open, open, open,
    HWRITEint, HWDATAint, HTRANSint, HSIZEint, HADDRint);
    
    AHBlite : bridge port map(clkm, rstn, ahbmi, ahbmo, HADDRint, HSIZEint, HTRANSint, HWDATAint, HWRITEint, HRDATAint, HREADYint);
    
    detectorbus : detect port map(clkm, HRDATAint, detected);
  END myarch;
