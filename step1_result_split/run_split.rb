require 'fileutils'

out_index = 0
384.times do |idx|
  infile = sprintf("../step1_result/bits%03d.txt", idx)
  outpattern = sprintf("tmp.",idx)
  cmd = "split -l 49152 #{infile} #{outpattern}"
  p cmd
  system(cmd)
  suffix = %w(aa ab ac ad ae af ag ah)
  suffix.each do |s|
    outfile = outpattern + s
    renamed = sprintf("bits%04d.txt", out_index)
    FileUtils.mv(outfile, renamed)
    out_index += 1
  end
end

