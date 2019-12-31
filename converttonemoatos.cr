#
# converttonemoatos.cr
#
# convert snapshot output files of vdwtest to nemo stoa format
#
# Usage: crystal run  converttonemoatos.cr [input files] 
# output is to stdout
def converttonemoatos(fname)
  ifile = File.open(fname, "r")
  t = ifile.gets.to_s.chomp
  a=Array(Array(String)).new
  n.times{
    a.push ifile.gets.to_s.chomp.split
  }
  print n,"\n3\n",t,"\n"
  n.times{|i| print a[i][1],"\n"}
  2.times{|k|
    n.times{|i| 
      3.times{|j| print a[i][k*3+2+j], " "}
      print "\n"
    }
  }
end

ARGV.each{|x|
  STDERR.print "file name = ", x, "\n"
  converttonemoatos(x)
}
