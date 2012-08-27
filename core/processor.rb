# Main namespace
module VisualParadigmExcel

  # The link between Reader and Transformer, this class
  # provides piping from one entity to the other.
	class Processor

    # Internal requires
    require_relative("reader")

    # Defin accessible attributes
    attr_reader :diagram

    # Parametrized constructor, initializes attributes
    # @param [String] p_filepath The path to the .xls File,
    #  which represents a Class Diagram as exported by
    #  Visual Paradigm.
    # @raise ArgumentException If the file is not found
		def initialize(p_filepath)

      # Initialize attributes
      @diagram = nil

      # Create a reader for the Excel File
      @reader = Reader.new(p_filepath)
    end

    # Main functionality, reads the data from the
    # given Excel File and outputs a #Diagram
	  def populate_diagram

      # Parse the Diagram data using the #Reader
      puts "Parsing Diagram data . . ."
      diagram_data = @reader.get_diagram_data

      # Create and populate a Diagram from the parsed data
      puts "Populating Diagram with Classes . . ."
			@diagram = Diagram.new(diagram_data[:name], diagram_data[:artifacts])
      @diagram.populate!
    end

    # Cleanup method
    def perform_cleanup
      @reader.perform_cleanup
    end

	end

end