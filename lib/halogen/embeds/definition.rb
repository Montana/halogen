module Halogen
  module Embeds
    class Definition < Halogen::Definition # :nodoc:
      # @return [true] if nothing is raised
      #
      # @raise [Halogen::InvalidDefinition] if the definition is invalid
      #
      def validate
        super

        return true if procedure

        fail InvalidDefinition, "Embed #{name} must be defined with a proc"
      end

      # Check whether this definition should be embedded for the given instance
      #
      # @param instance [Object]
      #
      # @return [true, false]
      #
      def enabled?(instance)
        return false unless super

        if instance.respond_to?(:embed?)
          instance.embed?(name.to_s)
        else
          embed_via_options?(instance)
        end
      end

      private

      # @param instance [Object]
      #
      # @return [true, false]
      #
      def embed_via_options?(instance)
        opts = instance.embed_options

        # Definition name must appear in instance embed option keys
        return false unless opts.include?(name.to_s)

        # Check value of embed option for definition name
        !%w(0 false).include?(opts.fetch(name.to_s).to_s)
      end
    end
  end
end
