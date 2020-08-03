#
# clop.cr
#
#    (c) 2020, Jun Makino
#
# A self-documented CLI tool for Crystal
#

require "yaml"

macro clop_init_old(l, f, d, strname)
     {{system("head  -#{l-1} #{f}>  #{d}/.tmp.cr")}}
     {{system("echo CLOPPARSER.parse\\(#{strname}\\) >>  #{d}/.tmp.cr")}}
     {{system("crystal   #{d}/.tmp.cr")}}
end

macro clop_init_localtest0(l, f, d, strname)
     {{run("./clop_process", l, f, d, strname)}}
end
macro clop_init_localtest(l, f, d, strname)
     {{system("sh ./clop_process.sh #{l} #{f} #{d} #{strname}")}}
end

macro clop_init(l, f, d, strname)
     {{system("sh ./lib/clop/src/clop_process.sh #{l} #{f} #{d} #{strname}")}}
end

class CLOPPARSER
  @@data=YAML.parse("")
  def self.optiontag(i)
    sprintf("Option%03d", i)
  end
  def self.add_option_tag(s)
    sh = s + <<-EOF
  Short name:		-h
  Long name:  		--help
  Value type:  		bool
  Variable name:	help
  Description:		Print help
  Long description:
    Print long help
EOF

    ss=""
    i=0
    inoptions=false
    previous_line_was_newoption = false
    sh.each_line{|x|
      if /^(\s)*(Short name|Long name):/ =~ x
        inoptions=true
        unless  previous_line_was_newoption
          ss += "  "+CLOPPARSER.optiontag(i)+":\n"
          i+= 1
        end
        previous_line_was_newoption=true
      else
        previous_line_was_newoption=false
        if x =~/(^\s+)(Description:)\s+(.*)/ || x =~/(^\s+)(Long description:)\s*(.*)/
          x = $1+$2+"\n"+$1+"    "+"|"
          x += "\n"+$1+"    "+$3 if $3.size > 0
        end
      end
      ss += "  " if inoptions
      ss += x+"\n"
    }
    ss
  end
  def self.generate_option_class(data)
    print "class CLOP\n"
    print "  property "
    firstarg=true
    i=0
    while data[CLOPPARSER.optiontag(i)]?
      opt=data[CLOPPARSER.optiontag(i)]
      print ", " unless firstarg
      firstarg=false
      if opt["Variable name"] == nil
        STDERR.print "Variable name missing in option defition of ", opt.to_s,"\n"
        exit -1
      end
      print ":", opt["Variable name"]
      i+=1
    end
    print "\n\n"
      
    
    print "  def initialize(optionstr,argv)\n"
    print "    CLOPPARSER.parseandprinthelp(optionstr,argv)\n"
    i=0
#    p! CLOPPARSER.optiontag(i)
#    p! data[CLOPPARSER.optiontag(i)]
    while data[CLOPPARSER.optiontag(i)]?
      opt=data[CLOPPARSER.optiontag(i)]
      if opt["Variable name"]?
        vtype = opt["Value type"]?
        vtype = "float" if vtype == nil
        vtype = vtype.to_s
        short = opt["Short name"]?
        long = opt["Long name"]?
        value = opt["Default value"]?
        print "    @",opt["Variable name"]," = "
        if vtype =~ /int vector/ 
          print "(CLOP.get_iv_val(\"#{value}\", \"#{vtype}\", \"#{short}\", \"#{long}\",argv))"
        elsif vtype =~ /float vector/ 
          print "(CLOP.get_fv_val(\"#{value}\", \"#{vtype}\", \"#{short}\", \"#{long}\",argv))"
        elsif vtype =~ /float/ 
          print "(CLOP.get_float_val(\"#{value}\", \"#{vtype}\", \"#{short}\", \"#{long}\",argv))"
        elsif vtype =~ /int/   
          print "(CLOP.get_int_val(\"#{value}\", \"#{vtype}\", \"#{short}\", \"#{long}\",argv))"
        elsif vtype =~ /bool/   
          print "(CLOP.get_bool_val(\"#{value}\", \"#{vtype}\", \"#{short}\", \"#{long}\",argv))"
        elsif vtype =~ /string/   
          print "(CLOP.get_string_val(\"#{value}\", \"#{vtype}\", \"#{short}\", \"#{long}\",argv))"
        end
        print "\n"
      end
      i+=1
    end
    print "  end\n"
  end
  
  def self.help(data, type)
    if type == "Long"
      STDERR.print data["Long description"], "\n" if data["Long description"]
    else
      STDERR.print data["Description"], "\n" if data["Description"]
    end
    i=0
    STDERR.print "Short   and   Long options             Type  Default Description\n"
    while data[CLOPPARSER.optiontag(i)]?
      opt=data[CLOPPARSER.optiontag(i)]
      STDERR.print sprintf("%4s ", opt["Short name"]?  ),
                   sprintf("%25s ", opt["Long name"]?),
                   sprintf("%12s ", opt["Value type"]?),
                   sprintf("%8s ", opt["Default value"]?)
      if type == "Long"
        print "\n", opt["Long description"]
      else
        print opt["Description"]
      end
      print "\n"
      i+=1
    end
  end

  def self.check_and_print_help(data, argv)
    long = false
    short=false
    i=0
    argv.each{|x|
      short = true if x == "-h"
      long = true if  x == "--help"
      i+=1
    }
    if long || short
      self.help(data, long ?  "Long" : "Short")
      exit 0
    end
  end
      
  def self.parseandprinthelp(s, argv)
    data = YAML.parse(CLOPPARSER.add_option_tag(s))
    self.check_and_print_help(data,argv)
  end
    
  def self.parse(s)
    data = YAML.parse(CLOPPARSER.add_option_tag(s))
    self.generate_option_class(data)
    print <<-END
  def self.getval(value, vtype, short, long, argv) : String
    argv.each_with_index{|x,i|
       if short == x || long == x
         if vtype =="bool"
           value = "true"
         else
           value = argv[i+1].to_s
         end
       end
    }
    if value == "none"
      STDERR.print "Option ", short,"(",long,") need some value to be given\n"
      STDERR.print "Try -h for the list of options\n"
      exit -1
    end
#    value = "\\"" + value.to_s + "\\"" if vtype == "string"
    value = "false" if value==nil && vtype == "bool"
    value
  end
  def self.get_float_val(value, vtype, short, long, argv) : Float64
     self.getval(value, vtype, short, long, argv).to_f64
  end 
  def self.get_int_val(value, vtype, short, long, argv) : Int64
     self.getval(value, vtype, short, long, argv).to_i64
  end
  def self.get_fv_val(value, vtype, short, long, argv) : Array(Float64)
     self.getval(value, vtype, short, long, argv).split(",").map{|x| x.to_f}
  end
  def self.get_iv_val(value, vtype, short, long, argv) : Array(Int64)
     self.getval(value, vtype, short, long, argv).split(",").map{|x| x.to_i64}
  end
  def self.get_bool_val(value, vtype, short, long, argv) : Bool
     self.getval(value, vtype, short, long, argv) == "true"
  end
  def self.get_string_val(value, vtype, short, long, argv) : String
     self.getval(value, vtype, short, long, argv).to_s
  end


END
    print "end\n"
  end
end

