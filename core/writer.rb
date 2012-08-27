# Main namespace
module VisualParadigmExcel

  # A Writer has the task of outputting
  # the read #Klass es into usable DataMapper-formatted
  # Ruby source files
  class Writer

    # TODO: Formatters -- DataMapper, PORO etc.

    # External requires
    require "date"
    require "fileutils"

    # Internal requires
    require "./core/extensions"
    require "./model/diagram"

    # Parametrized constructor, initializes attributes
    # based upon the received parameters.
    # @param [Diagram] p_diagram A parsed representation of
    #   a Visual Paradigm Diagram
    # @raise [ArgumentError] If the passed Diagram is not valid
    def initialize(p_diagram)

      # Check parameters
      raise ArgumentError.new("No Diagram provided!") if p_diagram.nil?

      # Assign attributes
      @diagram = p_diagram

      # Assign constants
      @constants = {
                     output_path: "../../output",
                     indent_size: 2, # tabs or spaces
                     indent_type: :spaces # also available: :tabs
                   }.freeze
    end

    # Main entry point, outputs the parsed Classes as
    # DataMapper-ready resources.
    # @param [String] p_path Optional path to the output folder,
    #   by default the projects 'output' Folder.
    def output_datamapper_resources(p_path = nil)

      # Recalibrate arguments
      p_path ||= File.expand_path(@constants[:output_path], __FILE__)

      # Get current timestamp, update Path
      now_str = DateTime.now.strftime("%Y-%m-%d_%H-%M")
      p_path_before = "#{@constants[:output_path]}/#{now_str}"
      p_path = "#{p_path}/#{now_str}"

      # Eventually delete stale Folder, create anew
      FileUtils.remove_dir(p_path) if File.exists?(p_path)
      Dir.mkdir(p_path)

      # Prerequisite: Check #Diagram for parsed #Klasses
      raise RuntimeError("Empty Diagram!") if @diagram.classes.empty?

      # Iterate over each parsed Class
      @diagram.classes.each do |current_class|

        # And output it to the chosen filepath
        write_class(current_class, p_path, p_path_before)
      end

    end

    private

      # Main Writer method, outputs the given #Klass to
      # its own DataMapper-formatted Ruby source file.
      # @param [Class] p_class The Class to use.
      # @param [String] p_root_path The root path to which the Class will be stored
      # @param [String] p_root_path_before The non-expanded output Path
      def write_class(p_class, p_root_path, p_root_path_before)

        # Check parameters
        raise ArgumentError.new("No Class provided!") if p_class.nil?

        # Prepare helpers -- Package name (if available)
        package_name_underscore = nil
        unless p_class.package.nil?

          # Underscore-ize package name, prepare package output path
          package_name_underscore = String.sanitize_filename(p_class.package.name.underscore)
          package_path = "#{p_root_path}/#{package_name_underscore}"

          # Eventually create Folder for package
          Dir.mkdir(package_path) unless File.exists?(package_path)
        end

        # Class Name
        class_name_underscore = String.sanitize_filename(p_class.name.underscore)
        class_name_camelcase  = String.sanitize_filename(p_class.name.camelize)

        # Prepare output path and file
        output_file_path = "#{class_name_underscore}.rb"
        output_file_path.insert(0, "#{package_name_underscore}/") unless package_name_underscore.nil?

        output_path = "#{p_root_path}/#{output_file_path}"
        output_file = File.new(output_path, "w")

        # Log output
        puts "'#{p_root_path_before}/#{output_file_path}'"

        # Prepare Associations first, since there are multiple types thereof (has, belongs)
        associations_str = write_associations_for(p_class)

        # Create Class header
        class_header = class_name_camelcase.dup
        class_header << " < #{p_class.superclass.name.camelize}" if p_class.subclassed?
        class_header << " # Marked as 'Abstract'" if p_class.abstract?

        # Create Class body
        class_body = <<-CLASS_BODY.unindent
          class #{class_header}

            # Mark as a DataMapper Resource
            include DataMapper::Resource

            # Auto-generated ID property
            property :id, Serial

            # Attributes
            #{write_attributes_for(p_class)}

            # Associations -- belongs
            #{associations_str[:belongs]}

            # Associations -- has
            #{associations_str[:has]}

          end # class #{class_name_camelcase}
        CLASS_BODY

        # Write header and body to file
        output_file << class_body

        # Close file
        output_file.close
      end

      # Helper method, outputs the different attributes
      # (named properties in DM terminology) for the given Class.
      # @param [Klass] p_class The Class to use
      # @raise [ArgumentError] If something is not alright with the passed parameters
      def write_attributes_for(p_class)

        # Check parameter
        raise ArgumentError.new("Class not provided!") if p_class.nil?

        # Prepare output
        out_s = ""

        # Iterate through Attributes, adding to the output
        p_class.attributes.each_with_index do |attribute, idx|

          # Prepare helper Strings
          property_name = attribute.name.strip.underscore
          property_type = attribute.type.capitalize
          property_extras = ", :accessor => :#{attribute.visibility.to_sym}"

          # Output property String, with indentation
          property_str = "property :#{property_name}, #{property_type}#{property_extras}\n"
          add_indentation_to(property_str) if idx > 0

          out_s << property_str
        end

        # Return output, with last newline stripped
        out_s.chop
      end

      # Helper method, outputs the different associations
      # for the given Class.
      # @param [Klass] p_class The Class to use.
      # @raise [ArgumentError] If something is not alright with the passed parameters
      #noinspection RubyResolve
      def write_associations_for(p_class)

        # Check parameter
        raise ArgumentError.new("Class not provided!") if p_class.nil?

        # Prepare output and helpers
        out_s = { has: "", belongs: "" }
        written_count = { has: 0, belongs: 0 }

        # Iterate through Associations, adding them to the output
        p_class.associations.each_with_index do |association|

          # Create actual associations, based on their defined multiplicity
          if (association.multiplicity[:to] != nil) && (association.to != p_class)

            # Check for multiplicity 1, build count helper String
            is_one = association.multiplicity[:to].eql?(1) # Yes, as a Fixnum
            count = is_one ? "1" : "n"

            # Eventually pluralize the target Class' name
            target_name = association.to.name

            # Output the String, take the Association's name into Account, if present
            has_str = "has #{count}, :#{target_name}"
            has_str << " # #{association.name}" unless association.name.nil?
            has_str << "\n"

            # Eventually add indentation
            if written_count[:has] > 0
              add_indentation_to(has_str)
            end
            written_count[:has] += 1

            # Add to result
            out_s[:has] << has_str
          end

          # Decide if :belongs_to is necessary
          belongs_to_str = ""
          if association.to.eql?(p_class)

            # Output the String, take the Association's name into Account, if present
            belongs_to_str = "belongs_to :#{association.from.name}"
            belongs_to_str << " # #{association.name}" unless association.from.name.nil?
            belongs_to_str << "\n"

            # Eventually add indentation
            if written_count[:belongs] > 0
              add_indentation_to(belongs_to_str)
            end
            written_count[:belongs] += 1
          end

          # Add to result
          out_s[:belongs] << belongs_to_str
        end

        # Clear last newline characters
        out_s[:has].chop!
        out_s[:belongs].chop!

        # Return result
        out_s
      end

    # Wrapper method for #String#add_indentation!, using the  defined constants.
    # @param [String] p_str The String to add indentation to (in-place)
    def add_indentation_to(p_str)
      p_str.add_indentation!(@constants[:indent_size], @constants[:indent_type])
    end

  end

end