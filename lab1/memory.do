run 10 ns
force clk 0 0, 1 50ns -repeat 100ns
run 10 ns
force dataIn 8'b11110000
force writeEn 1'b1
run 50 ns
force address 8'b00000001
force dataIn 8'b10000000
run 50 ns
force readEn 1'b1
force writeEn 1'b0
force dataIn 8'b11000000
run 50 ns
force address 8'b00000000
run 50 ns