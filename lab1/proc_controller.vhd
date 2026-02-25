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

    signal iImRead, iDmRead, iDmWrite, iPcLd, iFlagLd, iAccLd, iInReady, iOutValid: std_logic;

begin

    op <= opcode;

    -- State register
    process(clk, resetn)
    begin
        if resetn = '0' then
            state <= S_FETCH;
        elsif rising_edge(clk) and master_load_enable = '1' then
            state <= next_state;
        end if;
    end process;

    process(master_load_enable)
    begin
        if master_load_enable = 1 then
            imRead <= iImRead;
            dmRead <= iDmRead;
            dmWrite <= iDmWrite;
            pcLd <= iPcLd;
            flagLd <= iFlagLd;
            accLd <= iAccLd;
            inReady <= iInReady;
            outValid <= iOutValid;
        else then
            imRead <= '0';
            dmRead <= '0';
            dmWrite <= '0';
            pcLd <= '0';
            flagLd <= '0';
            accLd <= '0';
            inReady <= '0';
            outValid <= '0';  
        end if;
    end process;


    -- Next-state logic and outputs
    process(state, op, e_flag, z_flag, inValid, outReady)
    begin
        
        -- defaults
        busSel <= "0000";
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
                busSel <= "0000";
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
                iImRead <= '1';
                iPcLd <= '1';
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
                        iDmRead <= '1';
                        busSel <= B_IMEM;
                        next_state <= S_DECODE2;
                    when O_ADD | O_SUB | O_AND | O_XOR | O_CMP | O_LB =>
                        iDmRead <= '1';
                        busSel <= B_IMEM;
                        next_state <= S_EXEC;
                    when O_SBI =>
                        iDmRead <= '1';
                        busSel <= B_IMEM;
                        next_state <= S_ME;
                    when others =>
                        next_state <= S_EXEC;

                end case;
            when S_DECODE2 =>
                -- This state is only for LBI, which needs to load from DMEM  to get the immediate value, then load to ACC
                busSel <= B_DMEM;
                next_state <= S_EXEC;

            when S_EXEC =>
                dmRead <= '0';
                case op is
                    when O_IN =>
                        iInReady <= '1';
                        busSel <= B_EXT;
                        if inValid = '1' then
                            accLd <= '1';
                            next_state <= S_FETCH;
                        end if;
                    when O_OUT =>
                        busSel <= '0000';
                        iOutValid <= '1';
                        if outReady = '1' then
                            next_state <= S_FETCH;
                        end if;
                    when O_MOV =>
                        busSel <= B_IMEM;
                        accLd <= '1';
                        accSel <= '1';
                        next_state <= S_FETCH;
                    when O_J =>
                        iPcLd <= '1';
                        pcSel <= '1';
                        busSel <= B_ACC;
                        next_state <= S_FETCH;
                    when O_JE =>
                        iPcLd <= e_flag;
                        pcSel <= '1';
                        busSel <= B_IMEM;
                        next_state <= S_FETCH;
                    when O_JNZ =>
                        iPcLd <= not z_flag;
                        pcSel <= '1';
                        busSel <= B_IMEM;
                        next_state <= S_FETCH;
                    when O_XOR =>
                        aluOp <= A_XOR;
                        iFlagLd <= '1';
                        busSel <= B_DMEM;
                        accSel <= '0';
                        iAccLd <= '1';
                        next_state <= S_FETCH;
                    when O_AND =>
                        aluOp <= A_AND;
                        busSel <= B_DMEM;
                        iFlagLd <= '1';
                        accSel <= '0';
                        iAccLd <= '1';
                        next_state <= S_FETCH;
                    when O_ADD =>
                        aluOp <= A_ADD;
                        busSel <= B_DMEM;
                        iFlagLd <= '1';
                        accSel <= '0';
                        iAccLd <= '1';
                        next_state <= S_FETCH;
                    when O_SUB =>
                        aluOp <= A_SUB;
                        busSel <= B_DMEM;
                        iFlagLd <= '1';
                        accSel <= '0';
                        iAccLd <= '1';
                        next_state <= S_FETCH;
                    when O_CMP =>
                        iFlagLd <= '1';
                        busSel <= B_DMEM;
                        next_state <= S_FETCH;
                    when O_LB | O_LBI =>
                        busSel <= B_DMEM;
                        iAccLd <= '1';
                        accSel <= '1';
                        next_state <= S_FETCH;
                    when others =>
                        next_state <= S_FETCH;
                    
                end case;
                
            when S_ME =>
                case op is
                    dmRead <= '0';
                    iDmWrite <= '1';
                    next_state <= S_FETCH;
                    when O_SB =>
                        busSel <= B_IMEM;
                    when O_SBI =>
                        busSel <= B_DMEM;
                end case;
            when others =>
                next_state <= S_FETCH;
        end case;
    end process;

end behavioral;