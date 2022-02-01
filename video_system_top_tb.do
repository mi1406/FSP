# name of work directory
vlib work

# simulate AudioToVga_tb (entity name)
vsim video_system_top_tb

# log all wave signals
#log * -r

# open waveform viewer
#view wave

## clock and reset
#add wave -divider -height 32 Clock_and_Reset
#add wave -radix default -height 32 sim:/AV_SYSTEM_TOP_TB/clk
#add wave -radix default -height 32 sim:/AV_SYSTEM_TOP_TB/sresetn

## pixel stream module
#add wave -divider -height 32 PixelStream
#add wave -radix default -height 32 sim:/AV_SYSTEM_TOP_TB/dviDataEn
#add wave -radix default -height 32 sim:/AV_SYSTEM_TOP_TB/vgaClk
#add wave -radix default -height 32 sim:/AV_SYSTEM_TOP_TB/pixelRGBdata
#add wave -radix default -height 32 sim:/AV_SYSTEM_TOP_TB/DUV_i/hSync
#add wave -radix default -height 32 sim:/AV_SYSTEM_TOP_TB/DUV_i/vSync

# three frames
run 500 ms