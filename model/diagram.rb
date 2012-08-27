# Main namespace
module VisualParadigmExcel

  # TODO: SRP-ize

  # TODO: Fact - Space as example of borked assoc
  # TODO: SourceGroup - AggregationService as example of navigable bla assoc

  # TODO: Property named "id" => "internal_id"

  # TODO: AssociationClass as Artifact
  # TODO: Handling of Association named "<<implements>>"

  # TODO: Class Stereotype -- <<type>>, <<interface>>, <<enumeration>>

  # TODO: Association Types (Aggregation, Composition) -- when none => Module
  # TODO: Class name begins with I => Module
  # TODO: Class name includes Service => Module


  # TODO: NOTEs -- Anchor is a note attached to
  # TODO: Comments ?

	# A Diagram represents a wrapper around
	# a Visual Paradigm exported Class Diagram
	class Diagram

    # Internal requires
    #noinspection RubyResolve
    %w{ package class generalization attribute association}.each do |current_file|
      require "./model/#{current_file}"
    end

		# Declare accessible attributes
    #noinspection RubyResolve
		attr_accessor :name, :packages, :classes

		# Parametrized constructor, initializes this
		# instance using the supplied parameters.
		# @param [String] p_name The diagram's name
		# @param [Array] p_artifact_headers Array of (Hash representations of this diagram's artifacts)
		# @raise [ArgumentError] If anything is fishy with the parameters
		def initialize(p_name, p_artifact_headers)

			# Check parameters
			raise ArgumentError.new("Noname diagram!") unless p_name.is_a?(String)
			raise ArgumentError.new("No artifacts in the diagram!") unless p_artifact_headers.is_a?(Array)
		
			# Update attributes
			@name = p_name
      @artifact_headers = p_artifact_headers
      @artifact_header_names = []

      # Initialize attributes
      @current_artifact_header = nil

      # Initialize constants

      # Edge case represents an Artifact whose Class Name isn't the
      # same in the Excel File, e.g. A Header named "Class" translates
      #                              to the "Klass" Class :> in Ruby
      @constants = {
                     edge_cases: { Class: "Klass" }
                   }.freeze

      # Artifact types -- All Subclasses of #Artifact are given
      # a collection in which they are stored
      Artifact.subclasses.each do |artifact_subclass|

        # Get the Name of the Class (without the Module Name)
        # Split trick courtesy of https://groups.google.com/group/comp.lang.ruby/browse_thread/thread/3d60715227031856
        artifact_subclass_name = artifact_subclass.name
        artifact_subclass_name = (artifact_subclass_name.split("::").last || "")

        # Check for edge cases -- Create instance var named "classes" and not "klasses"
        @constants[:edge_cases].keys.each do |edge_case_key|
          if artifact_subclass_name.eql?(@constants[:edge_cases][edge_case_key])
            artifact_subclass_name = edge_case_key.to_s
          end
        end

        # Store all relevant Header Names (e.g. Class, Package..) for later parsing
        @artifact_header_names << artifact_subclass_name

        # Pluralize current Subclass Name (since it's a collection/Array), initialize it
        #noinspection RubyResolve
        artifact_subclass_pluralized = artifact_subclass_name.en.plural.downcase
        instance_variable_set("@#{artifact_subclass_pluralized}", [])
      end
    end

    # Populate method, sorts the read artifacts
    # into "type buckets", which are then used
    # to craft semi-proper representations of Classes.
    def populate!

      # Process artifacts and refine them into Classes
			process_artifacts
      refine_classes
      assign_class_generalizations
    end

    private

      # Populate method, moves the gathered artifact headers
      # into specific collections where they can be seperately
      # processed afterwards.
			def process_artifacts

				# Loop through all passed artifacts, add them
        # to the specific collection
				@artifact_headers.each do |artifact_header|
          @current_artifact_header = artifact_header
          process_current_header
        end

        # Empty the artifact headers afterwards
        remove_array_instance_var("artifact_headers")
      end

      # Converter method, either creates a new #Artifact
      # from the given headers or stores it for later
      # processing (to ensure validity).
      def process_current_header

        # Iterate through all #Artifact Types
        @artifact_header_names.each do |artifact_header_name|

          # Store ArtifactType Header into local variable
          artifact_type = @current_artifact_header["ArtifactType"]

          # Try to match the current artifact header's name with current iterated item
          is_match = artifact_header_name.eql?(artifact_type)
          if is_match

            # Initialize parameter Array to be sent to #create_and_pack_new_model_item
            create_params = [ artifact_header_name ]

            # Add extra parameter to Array if it's an edge case
            @constants[:edge_cases].keys.each do |edge_case_key|
              if artifact_header_name.eql?(edge_case_key.to_s)
                create_params << @constants[:edge_cases][edge_case_key]
              end
            end

            # Call create method with the given parameters
            self.send(:create_and_pack_new_model_item, create_params)

          end # is_match
        end # @artifact_header_names.each

      end

      # Populate method for Classes, adds Associations and Attributes.
      #noinspection RubyResolve
      # ^ RubyMine Fix, since it's a bit meta up in here :>
      def refine_classes

        # Try to fit Classes into Packages, add Attributes to Classes
        @classes.each do |current_class|
          current_class.try_match_package(@packages)
          current_class.try_add_attribute(@attributes)
        end

        # Link Classes together
        @associations.each do |current_association|
          current_association.try_link(@classes)
        end

        # Empty collections and dereference
        remove_array_instance_var("attributes")
        remove_array_instance_var("associations")
      end

      # Populate method, assigns the #superclass attribute
      # of a given #Klass
      #noinspection RubyResolve
      # ^ RubyMine Fix, since it's a bit meta up in here :>
      def assign_class_generalizations

        # Iterate through each generalizations and try to
        # assign the #superclass attribute of the specific Class
        @generalizations.each do |generalization|
          generalization.try_assign_superclass(@classes)
        end
      end

      # Wrapper method for a call to a given #Artifact 's #new Method.
      # @param [Array] p_args An Array containing:
      #                         [0] The name of the Artifact to create (Class etc.)
      #                         [1] Optional alternate name for edge cases
      def create_and_pack_new_model_item(*p_args)

        # Since passing an Array, flatten it
        p_args.flatten!

        # Parse parameters
        artifact_name = p_args.shift
        alternate_name = p_args.shift

        # Adjust item name, taking the optional alternative into account
        item_name = (alternate_name.nil? ? artifact_name : alternate_name)

        # Try to get the #Artifact #Klass which was passed
        artifact_class = VisualParadigmExcel.const_get(item_name)
        if artifact_class.is_a?(Class)

          # Create new instance of the given Artifact
          new_artifact = artifact_class.send(:new, @current_artifact_header)
          unless new_artifact.nil?

            # Prepare model item container name (@classes, @associations etc.)
            # And get its current value, if defined
            #noinspection RubyResolve
            model_item_container_name = artifact_name.en.plural.downcase
            model_item_container = get_instance_var_if_def(model_item_container_name)

            # Eventually add newly created Artifact to the found container
            unless model_item_container.nil?
              model_item_container << new_artifact
            end
          end
        end # if artifact_class.is_a?

      end

      # Wrapper for a #Object::instance_variable_defined? and
      # #Object::instance_variable_get call
      # @param [String] p_var_name The Name of the instance variable to get
      # @return [Object] The instance variable, as if it came from an explicit @<..> call
      def get_instance_var_if_def(p_var_name)

        # Adjust parameter to comply to Kernel format
        var_name = "@#{p_var_name}"

        # Initialize result, get instance variable's value, if defined
        result = nil
        result = instance_variable_get(var_name) if instance_variable_defined?(var_name)

        # Return result
        result
      end

      # Utility Method to clear and remove an #Array Instance Variable
      # @param [String] p_var_name The instance variable to remove
      def remove_array_instance_var(p_var_name)

        # If defined, get, clear and remove
        var_value = get_instance_var_if_def(p_var_name)
        unless var_value.nil?
          remove_instance_variable("@#{p_var_name}")
        end
      end

  end

end