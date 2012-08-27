# Main namespace
module VisualParadigmExcel

	# Model, represents a Class from a given
	# Visual Paradigm -modelled 'Class' Artifact.
	class Association < Artifact
	
    # Declare accessible attributes
		attr_reader :aggregation_kind, :multiplicity, :from, :to

		# Parametrized constructor, initializes this
		# instance using the supplied parameters.
		# @param [Hash] p_headers Hash of available headers.
		def initialize(p_headers)
		
			# Call super's constructor
			super(p_headers)

      # Assign attributes -- From, to
      @from = p_headers["From"]
      @to = p_headers["To"]

      # Assign attributes -- Multiplicity
      @multiplicity = {
                        total: p_headers["Multiplicity"],
                        from:  p_headers["From Multiplicity"],
                        to:    p_headers["To Multiplicity"]
                      }

      # Assign attributes -- Aggregation Kind
      @aggregation_kind = {
                            from: p_headers["From Aggregation Kind"],
                            to:   p_headers["To Aggregation Kind"]
                          }
    end

    # Populate method, tries to link this association with
    # real instances of #Klass.
    # @param [Array<Attribute>] p_classes Collection of Classes to try on.
    def try_link(p_classes)

      # Initialize helpers
      from_class = nil
      to_class = nil

      # Traverse each possible class
      p_classes.each do |current_class|

        # If outgoing or incoming, respectively
        from_class = current_class if current_class.is_my_id?(@from)
        to_class   = current_class if current_class.is_my_id?(@to)

        # Break if both found
        break if (!from_class.nil?) && (!to_class.nil?)
      end

      # If both found
      if (!from_class.nil?) && (!to_class.nil?)

        # Update own attributes
        @from = from_class
        @to = to_class

        # Update attribute in one or both Classes (one, if a self-refferential Association)
        from_class.associations << self
        to_class.associations   << self unless @from == @to # Only once for self-refferential
      end

    end

	end
	
end	