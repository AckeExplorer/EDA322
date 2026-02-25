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

    signal mImRead : std_logic;
    signal mDmRead : std_logic;
    signal mDmWrite : std_logic;
    signal mPcLd : std_logic;
    signal mFlagLd : std_logic;
    signal mAccLd : std_logic;
    signal mInReady : std_logic;
    signal mOutValid : std_logic;
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

    -- Next-state logic and outputs
    process(state, op, e_flag, z_flag, inValid, outReady)
    begin
        if master_load_enable = '1' then
            imRead <= mImRead;
            dmRead <= mDmRead;
            dmWrite <= mDmWrite;
            pcLd <= mPcLd;
            flagLd <= mFlagLd;
            accLd <= mAccLd;
            inReady <= mInReady;
            outValid <= mOutValid;
        end if;
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
                mDmRead <= '0';
                mDmWrite <= '0';
                aluOp <= A_XOR;
                mFlagLd <= '0';
                accSel <= '0';
                mAccLd <= '0';
                mInReady <= '0';
                mOutValid <= '0';
                -- request instruction
                imRead <= '1';
                mPcLd <= '1';
                -- after fetch, go decode
                next_state <= S_DECODE;

            when S_DECODE =>
                -- Default: advance PC
                imRead <= '0';
                mPcLd <= '0';

                -- decode opcode and choose path
                case op is
                    when O_NOOP =>
                        -- nothing more, return to fetch
                        next_state <= S_FETCH;

                    when O_LBI =>
                        -- immediate / move from IM to ACC
                        next_state <= S_DECODE2;
                    when O_ADD | O_SUB | O_AND | O_XOR | O_CMP | O_LB | O_LB1 =>
                        mDmRead <= '1';
                        next_state <= S_EXEC;
                    when O_SB1 =>
                        mDmRead <= '1';
                        next_state <= S_ME;
                    when others =>
                        next_state <= S_EXEC;

                end case;
            when S_DECODE2 =>
                -- This state is only for LBI, which needs to load from DMEM  to get the immediate value, then load to ACC
                busSel <= B_DMEM;
                next_state <= S_EXEC;

            when S_EXEC =>
                mDmRead <= 0';
                case op is
                    when O_IN =>
                        mInReady <= '1';
                        if inValid = '1' then
                            mAccLd <= '1';
                            next_state <= S_FETCH;
                        end if;
                    when O_OUT =>
                        mOutValid <= '1';
                        if outReady = '1' then
                            next_state <= S_FETCH;
                        end if;
                    when O_MOV =>
                        busSel <= B_IMEM;
                        mAccLd <= '1';
                        accSel <= '1';
                        next_state <= S_FETCH;
                    when O_J =>
                        mPcLd <= '1';
                        pcSel <= '1';
                        next_state <= S_FETCH;
                    when O_JE =>
                        mPcLd <= e_flag;
                        pcSel <= '1';
                        next_state <= S_FETCH;
                    when O_JNZ =>
                        mPcLd <= not z_flag;
                        pcSel <= '1';
                        next_state <= S_FETCH;
                    when O_XOR =>
                        aluOp <= A_XOR;
                        mFlagLd <= '1';
                        busSel <= B_DMEM;
                        accSel <= '0';
                        mAccLd <= '1';
                        next_state <= S_FETCH;
                    when O_AND =>
                        aluOp <= A_AND;
                        busSel <= B_DMEM;
                        mFlagLd <= '1';
                        accSel <= '0';
                        mAccLd <= '1';
                        next_state <= S_FETCH;
                    when O_ADD =>
                        aluOp <= A_ADD;
                        busSel <= B_DMEM;
                        mFlagLd <= '1';
                        accSel <= '0';
                        mAccLd <= '1';
                        next_state <= S_FETCH;
                    when O_SUB =>
                        aluOp <= A_SUB;
                        busSel <= B_DMEM;
                        mFlagLd <= '1';
                        accSel <= '0';
                        mAccLd <= '1';
                        next_state <= S_FETCH;
                    when O_CMP =>
                        mFlagLd <= '1';
                        busSel <= B_DMEM;
                        next_state <= S_FETCH;
                    when O_LB | O_LBI =>
                        busSel <= B_DMEM;
                        mAccLd <= '1';
                        accSel <= '1';
                        next_state <= S_FETCH;
                    when others =>
                        next_state <= S_FETCH;
                    
                end case;
                
            when S_ME =>
                case op is
                    when O_SB =>
                        busSel <= B_IMEM;
                        mDmWrite <= '1';
                        next_state <= S_FETCH;
                    when O_SB1 =>
                        busSel <= B_DMEM;
                        mDmWrite <= '1';
                        next_state <= S_FETCH;
                    when others =>
                        next_state <= S_FETCH;
                end case;
            when others =>
                next_state <= S_FETCH;
        end case;
    end process;

end behavioral;