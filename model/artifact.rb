# Main namespace
module VisualParadigmExcel

	# Root Model, represents the base for a given
	# modelled aspect, such as a Class, Association etc.
	# Exposes the Visual Paradigm-assigned Model ID.
	class Artifact

		# Declare visible attributes
		attr_reader :id, :model_id, :parent_id, :name

		# Constructor, initializes this instance
		# using the provided (header:value) pairs.
		# @param [Hash] p_headers Headers for this artifact
		def initialize(p_headers)

      # Populate attributes
			@id = p_headers["ID"]
      @model_id = p_headers["Model ID"]
      @parent_id = p_headers["Parent ID"]
      @name = p_headers["Name"]
    end

    # Equality override, turns out Visual Paradigm's export
    # is a bit lax in regard to ID / Model ID specifications.
    # @param [Artifact] p_artifact The Artifact to test for equality.
    # @return [Boolean] true, if equal. false, conversely.
    def eql?(p_artifact)
      ( (@id == p_artifact.id) || (@model_id == p_artifact.model_id) )
    end

    # Equality helper, @see #eql? for explanation. Tests against a
    # given ID and not another Artifact.
    # @param [Fixnum] p_id An ID to compare to
    # @return [Boolean] true, if equal. false, conversely
    def is_my_id?(p_id)
      ( (@id == p_id) || (@model_id == p_id) )
    end

    # Parent equality helper, @see #eql? as well. Tests against a
    # given #Artifact for parent equality
    # @param [Artifact] p_other_artifact A other Artifact to compare with
    def is_parent?(p_other_artifact)
      p_other_artifact.is_my_id?(self.parent_id)
    end

    # Called when this Class is inherited, populates
    # a Collection containing all the Subclasses.
    #
    # Thanks to http://www.ruby-forum.com/topic/171181
    def self.inherited(into)
      (@subclasses ||= []) << into
    end

    # Accessor for @subclasses
    def self.subclasses
      @subclasses
    end

	end

end	