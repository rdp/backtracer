# tracer shared for the get_line aspect
#
class Tracer

  def self.get_line(file, line)
    @get_line_procs ||= {}
    if p = @get_line_procs[file]
      return p.call(line)
    end

    unless list = SCRIPT_LINES__[file]
      begin
          raise 'might be a .so file' if file =~ /\.so$/
	  f = open(file)
	  begin
	    SCRIPT_LINES__[file] = list = f.readlines
	  ensure
	    f.close
	  end
      
      rescue
	SCRIPT_LINES__[file] = list = []
      end
    end

    if l = list[line - 1]
      l
    else
      "-\n"
    end
  end

end

SCRIPT_LINES__ = {} unless defined? SCRIPT_LINES__
