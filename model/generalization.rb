# Main namespace
module VisualParadigmExcel

  # A Package contains many #Klasses
  class Generalization < Artifact

    # Declare accessible attributes
		attr_reader :general_class, :specific_class

		# Parametrized constructor, initializes this
		# instance using the supplied parameters.
		# @param [Hash] p_headers Hash of available headers.
		def initialize(p_headers)

			# Call super's constructor
			super(p_headers)

      # Initialize attributes
      @general_class = p_headers["General"]
      @specific_class = p_headers["Specific"]
    end

    # Main functionality method, "binds" the two given Klasses
    # represented by this Generalization, in which the #Klass#superclass
    # Attribute of the specific #Klass is updated
    # @param [Array<Klass>] p_classes A List of #Klass es to search / The Klass-Space
    def try_assign_superclass(p_classes)

      # When both attributes present,
      if (@general_class != nil) && (@specific_class != nil)

        # Iterate through all proposed Classes, trying to match
        # both the generic as well as the specific Class ID to
        # a given instance of a #Klass
        p_classes.each do |current_class|
          @general_class  = current_class if current_class.is_my_id?(@general_class)
          @specific_class = current_class if current_class.is_my_id?(@specific_class)
        end

        # If both Classes were found, assign #superclass of the specific class
        if (@general_class.is_a?(Klass)) && (@specific_class.is_a?(Klass))
          @specific_class.superclass = @general_class
        end

      end
    end


	end

end