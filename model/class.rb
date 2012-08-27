# Main namespace
module VisualParadigmExcel

	# Model, represents a Class from a given
	# Visual Paradigm -modelled Class.
	class Klass < Artifact
	
    # Declare accessible attributes
		attr_reader :attributes, :associations, :package
    attr_accessor :superclass
	
		# Parametrized constructor, initializes this
		# instance using the supplied parameters.
		# @param [Hash] p_headers Hash of available headers.
		def initialize(p_headers)
		
			# Call super's constructor
			super(p_headers)

      # Initialize Array attributes
      %w(attributes associations).each do |instance_var|
        instance_variable_set("@#{instance_var}", [])
      end

      # Initialize attributes
      @package    = nil
      @superclass = nil

      @associations = []
      @attributes   = []

			# Populate attributes
      @is_abstract = !p_headers["Abstract"].eql?("No")
		end
		
		# Utility method, queries if this
		# #Klass has a baseclass or not.
		# @return [Boolean] true, if has a superclass, false if not.
		def subclassed?
			!@superclass.nil?
    end

    # Utility method, queries if this
    # Klass has been marked as 'abstract' or not.
    # @return [Boolean] true, if has a superclass, false if not.
    def abstract?
      @is_abstract
    end

    # Populate method, tries to populate the @attributes
    # collection with any of the given attributes.
    # @param [Array<Attribute>] p_attributes Collection of Attributes to try on.
    def try_add_attribute(p_attributes)

      # Traverse attributes, if the ID matches, add it
      p_attributes.each do |current_attribute|
        @attributes << current_attribute if is_my_id?(current_attribute.parent_id)
      end
    end

    # Populate method, tries to populate the @package
    # attribute with a given Package collection. In other
    # words, tries to add this Class into a #Package.
    # @param [Array<Packages>] p_packages An Array of Packages to check
    def try_match_package(p_packages)

      # Iterate through proposed packages
      p_packages.each do |package|

        # Check if the package is this Class' parent
        if is_parent?(package)

          # Update attributes -- in self and Package
          @package = package
          package.classes << self
        end
      end
    end

	end
	
end	