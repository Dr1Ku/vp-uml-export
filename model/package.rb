# Main namespace
module VisualParadigmExcel

  # A Package contains many #Klasses
  class Package < Artifact

    # Declare accessible attributes
		attr_reader :classes

		# Parametrized constructor, initializes this
		# instance using the supplied parameters.
		# @param [Hash] p_headers Hash of available headers.
		def initialize(p_headers)

			# Call super's constructor
			super(p_headers)

      # Initialize attributes
      @classes = []
    end

    # Adds a given #Klass to this #Package
    # @param [Klass] p_class The Class to Add
    def add_class(p_class)
      @classes << p_class
    end

	end

end