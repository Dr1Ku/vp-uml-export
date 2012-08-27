# Main namespace
module VisualParadigmExcel

	# Model, represents an Attribute for a given Class
	class Attribute < Artifact
	
    # Declare accessible attributes
		attr_reader :visibility, :type, :scope
	
		# Parametrized constructor, initializes this
		# instance using the supplied parameters.
		# @param [Hash] p_headers Hash of available headers.
		def initialize(p_headers)
		
			# Call super's constructor
			super(p_headers)

      # Assign attributes
      @visibility = p_headers["Visibility"]
      @type = p_headers["Type"]
      @scope = p_headers["Scope"]

      # Reinitialize nil values
      @type ||= "[N/A]"
		end
		
	end

end