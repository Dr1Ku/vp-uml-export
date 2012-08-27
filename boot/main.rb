# Main namespace
module VisualParadigmExcel

  # Primary functionality Wrapper, connects
  # all the bits and pieces
  class Main

    # External requires
    require "pp"
    require "linguistics"

    # Internal requires
    require "./core/processor"
    require "./core/writer"

    # Main entry point, launch method
    def self.go

      # Preinitialization -- load gems etc.
      # Initialize pluralizer to English
      Linguistics::use(:en)

      # Read from input file
      # TODO: Fix relative path
      path_to_input = File.expand_path("../../input/datenmodell.xls", __FILE__)

      # Process the input file, populate the Diagram
      @processor = Processor.new(path_to_input)
      @processor.populate_diagram

      # Output the read Diagram's artifacts as DataMapper Resources
      Writer.new(@processor.diagram).output_datamapper_resources

      # Cleanup
      @processor.perform_cleanup

      # Inform of progress
      puts
      puts "Done !"
    end

  end

end

# Execute !
# TODO: Use command-line parameter for input file
VisualParadigmExcel::Main.go
