library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.chacc_pkg.all;

entity proc_controller is
    port (
        clk: in std_logic;
        resetn: in std_logic;
        master_load_enable: in std_logic;
        opcode: in std_logic_vector(3 downto 0);
        e_flag: in std_logic;
        z_flag: in std_logic;
        inValid: in std_logic;
        outReady: in std_logic;

       	busSel: out std_logic_vector(3 downto 0);
        pcSel: out std_logic;
        pcLd: out std_logic;
        imRead: out std_logic;
        dmRead: out std_logic;
        dmWrite: out std_logic;
        aluOp: out std_logic_vector(1 downto 0);
        flagLd: out std_logic;
        accSel: out std_logic;
        accLd: out std_logic;
        inReady: out std_logic;
        outValid: out std_logic
    );
end proc_controller;

architecture behavioral of proc_controller is
    type state_t is (FE, DE1, DE2, EX, ME);
    signal state, next_state: state_t := FE;

    -- local decoded alias
    signal op : op_t;

begin

    op <= opcode;

    -- State register
    process(clk, resetn)
    begin
        if resetn = '0' then
            state <= FE;
        elsif rising_edge(clk) and master_load_enable = '1' then
            state <= next_state;
        end if;
    end process;

    -- Next-state logic and outputs
    process(state, op, e_flag, z_flag, inValid, outReady, master_load_enable)
    begin
        
        -- defaults
        busSel <= "0000";
        dmRead <= '0';

        case state is
            when FE =>
                -- defaults
                busSel <= "0000";
                pcSel <= '0';
                dmRead <= '0';
                dmWrite <= '0';
                flagLd <= '0';
                accLd <= '0';
                inReady <= '0';
                outValid <= '0';
                -- request instruction
                if master_load_enable = '1' then imRead <= '1'; else imRead <= '0'; end if;
                if master_load_enable = '1' then pcLd <= '1'; else pcLd <= '0'; end if;
                -- after fetch, go decode
                next_state <= DE1;

            when DE1 =>
                -- Default: advance PC
                imRead <= '0';
                pcLd <= '0';

                -- decode opcode and choose path
                case op is
                    when O_NOOP =>
                        -- nothing more, return to fetch
                        next_state <= FE;

                    when O_LBI =>
                        -- immediate / move from IM to ACC
                        if master_load_enable = '1' then DmRead <= '1'; else DmRead <= '0'; end if;
                        busSel <= B_IMEM;
                        next_state <= DE2;
                    when O_ADD | O_SUB | O_AND | O_XOR | O_CMP | O_LB =>
                        if master_load_enable = '1' then DmRead <= '1'; else DmRead <= '0'; end if;
                        busSel <= B_IMEM;
                        next_state <= EX;
                    when O_SBI =>
                        if master_load_enable = '1' then DmRead <= '1'; else DmRead <= '0'; end if;
                        busSel <= B_IMEM;
                        next_state <= ME;
                    when O_SB =>
                        next_state <= ME;
                    when others =>
                        next_state <= EX;

                end case;
            when DE2 =>
                -- This state is only for LBI, which needs to load from DMEM  to get the immediate value, then load to ACC
                if master_load_enable = '1' then DmRead <= '1'; else DmRead <= '0'; end if;
                busSel <= B_DMEM;
                next_state <= EX;

            when EX =>
                dmRead <= '0';
                case op is
                    when O_IN =>
                        if master_load_enable = '1' then inReady <= '1'; else inReady <= '0'; end if;
                        busSel <= B_EXT;
                        accSel <= '1';
                        if inValid = '1' then
                            if master_load_enable = '1' then accLd <= '1'; else accLd <= '0'; end if;
                            next_state <= FE;
                        else
                            next_state <= EX;
                        end if;
                    when O_OUT =>
                        busSel <= "0000";
                        if master_load_enable = '1' then outValid <= '1'; else outValid <= '0'; end if;
                        if outReady = '1' then
                            next_state <= FE;
                        else
                            next_state <= EX;
                        end if;
                    when O_MOV =>
                        busSel <= B_IMEM;
                        if master_load_enable = '1' then accLd <= '1'; else accLd <= '0'; end if;
                        accSel <= '1';
                        next_state <= FE;
                    when O_J =>
                        if master_load_enable = '1' then pcLd <= '1'; else pcLd <= '0'; end if;
                        pcSel <= '1';
                        busSel <= B_ACC;
                        next_state <= FE;
                    when O_JE =>
                        if master_load_enable = '1' then pcLd <= e_flag; else pcLd <= '0'; end if;
                        pcSel <= '1';
                        busSel <= B_IMEM;
                        next_state <= FE;
                    when O_JNZ =>
                        if master_load_enable = '1' then pcLd <= not z_flag; else pcLd <= '0'; end if;
                        pcSel <= '1';
                        busSel <= B_IMEM;
                        next_state <= FE;
                    when O_XOR =>
                        aluOp <= A_XOR;
                        if master_load_enable = '1' then flagLd <= '1'; else flagLd <= '0'; end if;
                        busSel <= B_DMEM;
                        accSel <= '0';
                        if master_load_enable = '1' then accLd <= '1'; else accLd <= '0'; end if;
                        next_state <= FE;
                    when O_AND =>
                        aluOp <= A_AND;
                        busSel <= B_DMEM;
                        if master_load_enable = '1' then flagLd <= '1'; else flagLd <= '0'; end if;
                        accSel <= '0';
                        if master_load_enable = '1' then accLd <= '1'; else accLd <= '0'; end if;
                        next_state <= FE;
                    when O_ADD =>
                        aluOp <= A_ADD;
                        busSel <= B_DMEM;
                        if master_load_enable = '1' then flagLd <= '1'; else flagLd <= '0'; end if;
                        accSel <= '0';
                        if master_load_enable = '1' then accLd <= '1'; else accLd <= '0'; end if;
                        next_state <= FE;
                    when O_SUB =>
                        aluOp <= A_SUB;
                        busSel <= B_DMEM;
                        if master_load_enable = '1' then flagLd <= '1'; else flagLd <= '0'; end if;
                        accSel <= '0';
                        if master_load_enable = '1' then accLd <= '1'; else accLd <= '0'; end if;
                        next_state <= FE;
                    when O_CMP =>
                        if master_load_enable = '1' then flagLd <= '1'; else flagLd <= '0'; end if;
                        busSel <= B_DMEM;
                        next_state <= FE;
                    when O_LB | O_LBI =>
                        busSel <= B_DMEM;
                        if master_load_enable = '1' then accLd <= '1'; else accLd <= '0'; end if;
                        accSel <= '1';
                        next_state <= FE;
                    when others =>
                        next_state <= FE;
                    
                end case;
                
            when ME =>
                dmRead <= '0';
                if master_load_enable = '1' then DmWrite <= '1'; else DmWrite <= '0'; end if;
                next_state <= FE;
                case op is
                    when O_SB =>
                        busSel <= B_IMEM;
                    when O_SBI =>
                        busSel <= B_DMEM;
                    when others =>
                        busSel <= "0000";
                end case;
            when others =>
                next_state <= FE;
        end case;
    end process;

end behavioral;