# Adapted Rails Core/Generic Extensions -- [String]
class String

  # Adapted from: http://apidock.com/rails/ActiveSupport/Inflector/underscore
  # File activesupport/lib/active_support/inflector/methods.rb, line 76
  def underscore
    word = self.dup # Just in case more preprocessing is wanted
    word.gsub!(/::/, '/')
    word.gsub!(/ /, '_')
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end

  # Adapted from: http://apidock.com/rails/ActiveSupport/Inflector/camelize
  # File activesupport/lib/active_support/inflector/methods.rb, line 54
  def camelize
    string = self.dup
    string = string.sub(/^[a-z\d]*/) { $&.capitalize }
    string.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
  end

  # Strip leading whitespace from each line that is the same as the
  # amount of whitespace on the first line of the string.
  # Leaves _additional_ indentation on later lines intact.
  #
  # From: http://stackoverflow.com/a/5638187
  def unindent
    self.gsub(/^#{self[/\A\s*/]}/, "")
  end

  # Utility method, sanitizes a given string representing a filename
  # by using some regular rules for file and folder names across OSes.
  def self.sanitize_filename(p_string)
    p_string.gsub(/[\/:*?"<>|^;]/, "")
  end

  # Indentation method, wrapper for either #Fixnum.spaces or #Fixnum.tabs
  # @param [Fixnum] p_size The number of indent chars to output (2, 4 etc.)
  # @param [Symbol] p_type The type of indent char, either :spaces or :tabs
  def add_indentation(p_size, p_type)
    delimiter_result = p_size.send(p_type)
    self.insert(0, delimiter_result)
  end

  # In-place variant of #add_indentation
  # @param [Fixnum] p_size @see #add_indentation
  # @param [Symbol] p_type @see #add_indentation
  def add_indentation!(p_size, p_type)
    self.replace(add_indentation(p_size, p_type))
  end

end

# Syntactic Sugar for Fixnum
class Fixnum

  # For indentation purposes
  def spaces
    out_s = ""
    self.times do
      out_s << " "
    end
    out_s
  end

  # For indentation purposes
  def tabs
    out_s = ""
    self.times do
      out_s << "\t"
    end
    out_s
  end

end