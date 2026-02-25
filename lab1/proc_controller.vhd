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
    type state_t is (S_FETCH, S_DECODE, S_DECODE2, S_EXEC, S_ME);
    signal state, next_state: state_t := S_FETCH;

    -- local decoded alias
    signal op : op_t;
begin

    op <= opcode;

    -- State register
    process(clk, resetn)
    begin
        if resetn = '0' then
            state <= S_FETCH;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    -- Next-state logic and outputs
    process(state, op, e_flag, z_flag, inValid, outReady)
    begin
        -- defaults
        busSel <= B_IMEM;
        pcSel <= '0';
        pcLd <= '0';
        imRead <= '0';
        dmRead <= '0';
        dmWrite <= '0';
        aluOp <= A_XOR;
        flagLd <= '0';
        accSel <= '0';
        accLd <= '0';
        inReady <= '0';
        outValid <= '0';
        next_state <= S_FETCH;

        case state is
            when S_FETCH =>
                -- defaults
                busSel <= B_IMEM;
                pcSel <= '0';
                dmRead <= '0';
                dmWrite <= '0';
                aluOp <= A_XOR;
                flagLd <= '0';
                accSel <= '0';
                accLd <= '0';
                inReady <= '0';
                outValid <= '0';
                -- request instruction
                imRead <= '1';
                pcLd <= '1';
                -- after fetch, go decode
                next_state <= S_DECODE;

            when S_DECODE =>
                -- Default: advance PC
                imRead <= '0';
                pcLd <= '0';

                -- decode opcode and choose path
                case op is
                    when O_NOOP =>
                        -- nothing more, return to fetch
                        next_state <= S_FETCH;

                    when O_LBI =>
                        -- immediate / move from IM to ACC
                        next_state <= S_DECODE2;
                    when O_ADD | O_SUB | O_AND | O_XOR | O_CMP | LB | LB1 =>
                        dmRead <= '1';
                        next_state <= S_EXEC;
                    when O_SB1 =>
                        dmRead <= '1';
                        next_state <= S_ME;
                    when others =>
                        next_state <= S_EXEC;

                end case;
            when S_DECODE2 =>
                -- This state is only for LBI, which needs to load from DMEM (not IMEM) to get the immediate value, then load to ACC
                busSel <= B_DMEM;
                next_state <= S_EXEC;

            when S_EXEC =>
                case op is
                    when O_IN =>
                        inReady <= '1';
                        if inValid = '1' then
                            accLd <= '1';
                            next_state <= S_FETCH;
                        end if;
                    when O_OUT =>
                        outValid <= '1';
                        if out_ready = '1' then
                            next_state <= S_FETCH;
                        end if;
                    when O_MOV =>
                        busSel <= B_IMEM;
                        accLd <= '1';
                        accSel <= '1';
                        next_state <= S_FETCH;
                    when J =>
                        pcLd <= '1';
                        pcSel <= '1';
                        next_state <= S_FETCH;
                    when JE =>
                        pcLd <= e_flag;
                        pcSel <= '1';
                        next_state <= S_FETCH;
                    when JNZ =>
                        pcLd <= not z_flag;
                        pcSel <= '1';
                        next_state <= S_FETCH;
                    when O_XOR =>
                        aluOp <= A_XOR;
                        flagLd <= '1';
                        busSel <= B_DMEM;
                        accSel <= '0';
                        accLd <= '1';
                        next_state <= S_FETCH;
                    when O_AND =>
                        aluOp <= A_AND;
                        busSel <= B_DMEM;
                        flagLd <= '1';
                        accSel <= '0';
                        accLd <= '1';
                        next_state <= S_FETCH;
                    when O_ADD =>
                        aluOp <= A_ADD;
                        busSel <= B_DMEM;
                        flagLd <= '1';
                        accSel <= '0';
                        accLd <= '1';
                        next_state <= S_FETCH;
                    when O_SUB =>
                        aluOp <= A_SUB;
                        busSel <= B_DMEM;
                        flagLd <= '1';
                        accSel <= '0';
                        accLd <= '1';
                        next_state <= S_FETCH;
                    when O_CMP =>
                        flagLd <= '1';
                        busSel <= B_DMEM;
                        next_state <= S_FETCH;
                    when O_LB | O_LBI =>
                        busSel <= B_DMEM;
                        accLd <= '1';
                        accSel <= '1';
                        next_state <= S_FETCH;
                        
                    when O_IN =>
                        -- request external data; if valid load, else wait
                        inReady <= '1';
                        if inValid = '1' then
                            accLd <= '1';
                            next_state <= S_FETCH;
                        else
                            next_state <= S_WAIT_IN;
                        end if;

                    when O_OUT =>
                        -- present ACC/Bus to external
                        outValid <= '1';
                        next_state <= S_WAIT_OUT;

                    when O_J =>
                        pcSel <= '1';
                        pcLd <= '1';
                        next_state <= S_FETCH;

                    when O_JE =>
                        pcSel <= ( '1' when e_flag = '1' else '0' );
                        pcLd <= '1';
                        next_state <= S_FETCH;

                    when O_JNZ =>
                        pcSel <= ( '1' when z_flag = '0' else '0' );
                        pcLd <= '1';
                        next_state <= S_FETCH;

                    when O_LB =>
                        -- read from data memory, then writeback
                        dmRead <= '1';
                        next_state <= S_DM_WB;

                    when O_SB | O_SBI =>
                        -- store to data memory (one cycle write)
                        dmWrite <= '1';
                        next_state <= S_FETCH;

                    when others =>
                        next_state <= S_FETCH;
                    
                end case;

            when others =>
                next_state <= S_FETCH;
        end case;
    end process;

end behavioral;